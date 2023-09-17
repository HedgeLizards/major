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
	for p in modules.keys():
		if modules[p].index == -1:
			modules[p].queue_free()
			modules.erase(p)
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
		if near_solid.has(p) and !modules.has(p):
			create_free_at(p)

func create_free_at(p: Vector2i):
	var free = Free.instantiate()
	
	free.position.x = p.x
	free.position.y = -0.4
	free.position.z = p.y
	
	add_child(free)

	modules[p] = free
	

func toggle_frees():
	var tween = create_tween().set_parallel().set_trans(Tween.TRANS_SINE)
	for p in modules:
		var module = modules[p]
		if module.index == -1:
			tween.tween_property(module.get_surface_override_material(0), 'albedo_color:a', 0.0 if placing == null else 0.5, 0.2)

func enable_building():
	building = true
	
	raycast_grid(get_viewport().get_mouse_position())

func enable_placeholder(index, rotation_y = 0):
	get_node('../SFX/Module Grab').play()
	
	if placing != null:
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

func raycast_grid(mouse_position):
	if !building:
		return
	
	var intersection_point = Plane.PLANE_XZ.intersects_ray(
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
			(placing != null && modules[hovered_point].index != -1):
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

func disable_placeholder():
	if placing == null:
		return
	
	$Placeholder.queue_free()
	
	placing = null
	hovered_point = null
	
	toggle_frees()

func disable_building():
	disable_placeholder()
	
	building = false

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
			
			grabbed_position = event.position
		else:
			if event.pressed || event.position == grabbed_position:
				grabbed_position = null
				
				return
			
			get_node('../SFX/Module Place').play()
			
			add_module.rpc(placing, hovered_point, $Placeholder.rotation.y + PI / 2)
			
			toggle_frees() # disable_placeholder() instead if moving existing module or not enough resources left
	elif event is InputEventKey:
		if event.echo || !event.pressed:
			return
		
		match event.keycode:
			KEY_R:
				if placing != 0 && placing != 3:
					return
				
				get_node('../SFX/Module Rotate').play()
				
				$Placeholder.rotation.y += (PI if event.shift_pressed else -PI) / 2
			KEY_BACKSPACE, KEY_DELETE:
				disable_placeholder()
			KEY_ESCAPE:
				disable_placeholder()

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

	module.position.x = point.x
	module.position.z = point.y
	module.rotation.y = rot
	add_child(module)
	if modules.has(point):
		modules[point].queue_free()
	modules[point] = module
	create_frees()

@rpc("any_peer", "call_local", "reliable")
func remove_module(point: Vector2i):
	modules[point].queue_free()
	modules.erase(point)
	create_frees()

func _notification(what):
	if what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN:
		raycast_grid(get_viewport().get_mouse_position())

func _physics_process(delta: float):
	if input.rot != 0:
		raycast_grid(get_viewport().get_mouse_position())


func _integrate_forces(state):
	var velocity = Vector2()

	state.angular_velocity = Vector3(0, -input.rot * rotation_speed,0).rotated(Vector3(0, 1, 0), rotation.y)

	state.linear_velocity = Vector3(0, 0, -input.speed * forward_speed).rotated(Vector3(0, 1, 0), rotation.y)
