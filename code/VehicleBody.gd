extends RigidBody3D

var Free = preload('res://scenes/modules/free.tscn')
var Drill = preload('res://scenes/modules/drill.tscn')
var Battery = preload('res://scenes/modules/battery.tscn')
var Wheel = preload('res://scenes/modules/wheel.tscn')
var Gun = preload('res://scenes/modules/gun.tscn')
var Shield = preload('res://scenes/modules/shield.tscn')
var Mine = preload('res://scenes/modules/mine.tscn')
var invalid = preload('res://resources/invalid.tres')

var building = false
var placing
var hovered_point:
	set(value):
		hovered_point = value
		
		if lock_pointing_hand:
			DisplayServer.cursor_set_shape(DisplayServer.CURSOR_POINTING_HAND)
		else:
			DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW if hovered_point == null else DisplayServer.CURSOR_POINTING_HAND)
var existing_point
var existing_rotation_y
var grabbed_position
var lock_pointing_hand = false

var forward_speed := 5
var rotation_speed := 1.0 * PI

@onready var camera = %Camera3D
@onready var modules = {Vector2i(0, 0): $Core}
@onready var input := %PlayerInput

# Set by the authority, synchronized on spawn.
@export var player := 1 :
	set(id):
		player = id
		# Give authority over the player input to the appropriate peer.
		%PlayerInput.set_multiplayer_authority(id)

func is_local():
	return player == multiplayer.get_unique_id()

func _ready():
	if is_local():
		camera.make_current()
	
	create_frees()

func create_frees():
	var near_solid = {} # use as Set
	var near_power = {}
	var free_points = []
	for p in modules.keys():
		if modules[p].index == -1:
			free_points.push_back(p)
		else:
			if modules[p].solid:
				near_solid[p + Vector2i(0, 1)] = true
				near_solid[p + Vector2i(0, -1)] = true
				near_solid[p + Vector2i(1, 0)] = true
				near_solid[p + Vector2i(-1, 0)] = true
			if modules[p].powered:
				near_power[p + Vector2i(0, 1)] = true
				near_power[p + Vector2i(0, -1)] = true
				near_power[p + Vector2i(1, 0)] = true
				near_power[p + Vector2i(-1, 0)] = true
				near_power[p + Vector2i(1, 1)] = true
				near_power[p + Vector2i(1, -1)] = true
				near_power[p + Vector2i(-1, 1)] = true
				near_power[p + Vector2i(-1, -1)] = true
	for p in near_power:
		if near_solid.has(p):
			if free_points.has(p):
				free_points.erase(p)
			elif !modules.has(p):
				create_free_at(p)
	for p in free_points:
		modules[p].queue_free()
		modules.erase(p)

func create_free_at(p: Vector2i):
	var free = Free.instantiate()
	
	free.position.x = p.x
	free.position.y = -0.4
	free.position.z = p.y
	
	add_child(free)

	modules[p] = free
	

func toggle_frees():
	var tween
	for p in modules:
		var module = modules[p]
		if module.index == -1:
			if tween == null:
				tween = create_tween().set_parallel().set_trans(Tween.TRANS_SINE)
			tween.tween_property(module.get_surface_override_material(0), 'albedo_color:a', 0.0 if placing == null else 0.5, 0.2)

func enable_building():
	building = true
	
	raycast_grid(get_viewport().get_mouse_position())

func enable_placeholder(index, rotation_y = 0):
	get_node('../SFX/SND_MODULE_GRAB').play()
	
	if placing != null:
		if existing_point != null:
			cancel_module_movement.rpc(placing, existing_point, existing_rotation_y)
		
		if index == 0 || index == 3:
			rotation_y = $Placeholder.rotation.y + PI / 2
		
		$Placeholder.free()
	
	placing = index
	
	var placeholder_mesh_parent = [
		Drill,
		Battery,
		Wheel,
		Gun,
		Shield,
		Mine,
	][placing].instantiate()
	var placeholder_mesh = placeholder_mesh_parent.get_child(0)
	
	placeholder_mesh.name = 'Placeholder'
	placeholder_mesh.rotation.y += rotation_y
	placeholder_mesh_parent.remove_child(placeholder_mesh)
	
	add_child(placeholder_mesh)
	
	toggle_frees()
	
	raycast_grid(get_viewport().get_mouse_position())
	
	existing_point = null
	
	update_build_hint()

func raycast_grid(mouse_position):
	if !building:
		return
	
	var intersection_point = Plane(0, 1, 0, 0.8 if placing == null else 0.2).intersects_ray(
		camera.project_ray_origin(mouse_position),
		camera.project_ray_normal(mouse_position)
	)
	
	if intersection_point == null:
		hovered_point = null
	else:
		intersection_point = to_local(intersection_point)
		
		hovered_point = Vector2i(floor(intersection_point.x + 0.5), floor(intersection_point.z + 0.5))
		if !modules.has(hovered_point) || \
			(placing == null && modules[hovered_point].index < 0) || \
			(placing != null && (modules[hovered_point].index != -1 || !is_module_valid(placing, hovered_point, true))):
			hovered_point = null
	
	if placing == null:
		return
	
	var placeholder_mesh_child = $Placeholder.get_child(0)
	
	if hovered_point == null:
		if !placeholder_mesh_child.has_meta('material_0'):
			for i in placeholder_mesh_child.get_surface_override_material_count():
				placeholder_mesh_child.set_meta('material_%d' % i, placeholder_mesh_child.get_surface_override_material(i))
				placeholder_mesh_child.set_surface_override_material(i, invalid)
		
		$Placeholder.position.x = intersection_point.x
		$Placeholder.position.z = intersection_point.z
	else:
		if placeholder_mesh_child.has_meta('material_0'):
			for i in placeholder_mesh_child.get_surface_override_material_count():
				placeholder_mesh_child.set_surface_override_material(i, placeholder_mesh_child.get_meta('material_%d' % i))
				placeholder_mesh_child.remove_meta('material_%d' % i)
		
		$Placeholder.position.x = hovered_point.x
		$Placeholder.position.z = hovered_point.y

func update_build_hint():
	var build_hint = get_node('../../../UserInterface/BuildHint')
	
	if placing == null:
		build_hint.visible = false
		
		return
	
	var actions = PackedStringArray()
	
	if placing == 0 || placing == 3:
		actions.push_back('[R] to rotate')
	
	if existing_point != null:
		actions.push_back('[Backspace] to deconstruct')
	
	actions.push_back('[Escape] to cancel')
	
	build_hint.text = '     '.join(actions)
	build_hint.visible = true

func disable_placeholder():
	if placing == null:
		return
	
	$Placeholder.queue_free()
	
	placing = null
	hovered_point = null
	
	toggle_frees()
	
	raycast_grid(get_viewport().get_mouse_position())
	
	update_build_hint()

func disable_building():
	building = false
	
	if placing != null && existing_point != null:
		cancel_module_movement.rpc(placing, existing_point, existing_rotation_y)
	
	disable_placeholder()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		raycast_grid(event.position)
	elif event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_LEFT || hovered_point == null:
			return
		
		if placing == null:
			if !event.pressed:
				return
			
			var module = modules[hovered_point]
			var point: Vector2i = hovered_point
			
			remove_module.rpc(point)
			
			enable_placeholder(module.index, module.rotation.y)
			
			existing_point = point
			existing_rotation_y = module.rotation.y
			
			update_build_hint()
			
			grabbed_position = event.position
		else:
			if event.pressed || event.position == grabbed_position:
				grabbed_position = null
				
				return
			
			get_node('../SFX/SND_MODULE_PLACE').play()
			
			add_module.rpc(placing, hovered_point, $Placeholder.rotation.y + PI / 2)
	elif event is InputEventKey:
		if event.echo || !event.pressed:
			return
		
		match event.keycode:
			KEY_R:
				if placing != 0 && placing != 3:
					return
				
				get_node('../SFX/SND_MODULE_ROTATE').play()
				
				$Placeholder.rotation.y += (PI if event.shift_pressed else -PI) / 2
				
				raycast_grid(get_viewport().get_mouse_position())
			KEY_BACKSPACE, KEY_DELETE:
				if placing != null && existing_point != null:
					if are_all_modules_valid():
						get_node('../../../UserInterface/BuildMenu').deconstruct_module(placing)
					else:
						cancel_module_movement.rpc(placing, existing_point, existing_rotation_y)
				
				disable_placeholder()
			KEY_ESCAPE:
				if placing != null && existing_point != null:
					cancel_module_movement.rpc(placing, existing_point, existing_rotation_y)
				
				disable_placeholder()

@rpc("any_peer", "call_local", "reliable")
func cancel_module_movement(placing, point, rot, module = null):
	if module == null || module is EncodedObjectAsID:
		module = [
			Drill,
			Battery,
			Wheel,
			Gun,
			Shield,
			Mine,
		][placing].instantiate()
		
		module.rotation.y = rot
	
	module.position.x = point.x
	module.position.z = point.y
	
	add_child(module)
	
	modules[point].queue_free()
	modules[point] = module
	
	existing_point = null
	
	create_frees()

func is_module_valid(index, point, new):
	var offsets = [Vector2i(1, 0), Vector2i(0, -1), Vector2i(-1, 0), Vector2i(0, 1)]
	
	if index == 0 || index == 3:
		offsets = [offsets[roundi(fposmod(($Placeholder.rotation.y if new else modules[point].rotation.y - PI / 2), TAU) / (PI / 2)) % 4]]
	elif new:
		return true
	
	var near_solid = false
	
	for offset in offsets:
		var neighbour = point + offset
		
		if modules.has(neighbour) && modules[neighbour].solid:
			near_solid = true
			
			break
	
	if near_solid:
		for offset in [
			Vector2i(-1, -1),
			Vector2i(0, -1),
			Vector2i(1, -1),
			Vector2i(-1, 0),
			Vector2i(1, 0),
			Vector2i(-1, 1),
			Vector2i(0, 1),
			Vector2i(1, 1),
		]:
			var neighbour = point + offset
			
			if modules.has(neighbour) && modules[neighbour].powered:
				return true
	
	return false

func are_all_modules_valid():
	for p in modules:
		var module = modules[p]
		
		if module.index >= 0 && !is_module_valid(module.index, p, false):
			return false
	
	return dfs_from_core([Vector2i(0, 0)], Vector2i(0, 0)).size() == modules.size()

func dfs_from_core(reachable_from_core, point):
	for offset in [Vector2i(1, 0), Vector2i(0, -1), Vector2i(-1, 0), Vector2i(0, 1)]:
		var neighbour = point + offset
		
		if modules.has(neighbour) && !reachable_from_core.has(neighbour):
			reachable_from_core.push_back(neighbour)
			
			if modules[neighbour].index != -1:
				dfs_from_core(reachable_from_core, neighbour)
	
	return reachable_from_core

@rpc("any_peer", "call_local", "reliable")
func add_module(placing: int, point: Vector2i, rot: float):
	var module: Node3D = [
		Drill,
		Battery,
		Wheel,
		Gun,
		Shield,
		Mine,
	][placing].instantiate()
	
	module.rotation.y = rot
	
	var free = modules[point]
	
	modules[point] = module
	
	if are_all_modules_valid():
		free.queue_free()
		
		module.position.x = point.x
		module.position.z = point.y
		
		add_child(module)
		
		create_frees()
		
		if existing_point == null && is_local() && get_node('../../../UserInterface/BuildMenu').construct_module(placing):
			toggle_frees()
		else:
			disable_placeholder()
	elif existing_point == null:
		module.queue_free()
		
		modules[point] = free
	else:
		modules[point] = free
		
		cancel_module_movement.rpc(placing, existing_point, existing_rotation_y, module)
		
		disable_placeholder()

@rpc("any_peer", "call_local", "reliable")
func remove_module(point: Vector2i):
	modules[point].queue_free()
	modules.erase(point)
	create_frees()

func _notification(what):
	if what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN:
		raycast_grid(get_viewport().get_mouse_position())

func _physics_process(_delta: float):
	if input.rot != 0:
		raycast_grid(get_viewport().get_mouse_position())


func _integrate_forces(state):

	state.angular_velocity = Vector3(0, -input.rot * rotation_speed,0).rotated(Vector3(0, 1, 0), rotation.y)

	state.linear_velocity = Vector3(0, 0, -input.speed * forward_speed).rotated(Vector3(0, 1, 0), rotation.y)
