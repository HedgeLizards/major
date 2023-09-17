extends RigidBody3D

var Free = preload('res://scenes/modules/free.tscn')
var Drill = preload('res://scenes/modules/drill.tscn')
var Battery = preload('res://scenes/modules/battery.tscn')
var Wheel = preload('res://scenes/modules/wheel.tscn')
var Gun = preload('res://scenes/modules/gun.tscn')
var Shield = preload('res://scenes/modules/shield.tscn')
var Mine = preload('res://scenes/modules/mine.tscn')
var invalid = preload('res://resources/invalid.tres')

var core_row = 1
var core_column = 1
var building = false
var placing
var hovered_row:
	set(value):
		hovered_row = value
		
		DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW if hovered_row == null else DisplayServer.CURSOR_POINTING_HAND)
var hovered_column

var forward_speed := 5
var rotation_speed := 1.0 * PI

@onready var camera = %Camera3D
@onready var grid = [
	[null, null, null],
	[null, $Core, null],
	[null, null, null],
]
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
	for r in grid.size():
		for c in grid[0].size():
			if grid[r][c] == null && (
				(r > 0 && grid[r - 1][c] != null && grid[r - 1][c].index != -1) || \
				(r < grid.size() - 1 && grid[r + 1][c] != null && grid[r + 1][c].index != -1) || \
				(c > 0 && grid[r][c - 1] != null && grid[r][c - 1].index != -1) || \
				(c < grid[0].size() - 1 && grid[r][c + 1] != null && grid[r][c + 1].index != -1)
			):
				create_free_at(r, c)

func create_free_at(row, column):
	var free = Free.instantiate()
	
	free.position.x = column - core_column
	free.position.y = -0.4
	free.position.z = row - core_row
	
	add_child(free)
	
	grid[row][column] = free

func toggle_frees():
	var tween = create_tween().set_parallel().set_trans(Tween.TRANS_SINE)
	
	for r in grid.size():
		for c in grid[0].size():
			if grid[r][c] != null && grid[r][c].index == -1:
				tween.tween_property(grid[r][c].get_surface_override_material(0), 'albedo_color:a', 0.0 if placing == null else 0.5, 0.2)

func enable_building():
	building = true
	
	raycast_grid(get_viewport().get_mouse_position())

func enable_placeholder(index):
	get_node('../SFX/Module Grab').play()
	
	if placing != null:
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
		hovered_row = null
		hovered_column = null
	else:
		intersection_point = to_local(intersection_point)
		
		hovered_row = floor(intersection_point.z + 0.5) + core_row
		hovered_column = floor(intersection_point.x + 0.5) + core_column
		
		if hovered_row < 0 || hovered_row >= grid.size() || \
			hovered_column < 0 || hovered_column >= grid[0].size() || \
			grid[hovered_row][hovered_column] == null || \
			(placing == null && grid[hovered_row][hovered_column].index < 0) || \
			(placing != null && grid[hovered_row][hovered_column].index != -1):
			hovered_row = null
			hovered_column = null
	
	if placing == null:
		return
	
	var placeholder_mesh_child = $Placeholder.get_child(0)
	
	if hovered_row == null:
		for i in placeholder_mesh_child.get_surface_override_material_count():
			placeholder_mesh_child.set_surface_override_material(i, invalid)
		
		$Placeholder.position.x = intersection_point.x
		$Placeholder.position.z = intersection_point.z
	else:
		for i in placeholder_mesh_child.get_surface_override_material_count():
			placeholder_mesh_child.set_surface_override_material(i, null)
		
		$Placeholder.position.x = hovered_column - core_column
		$Placeholder.position.z = hovered_row - core_row

func disable_placeholder():
	if placing == null:
		return
	
	$Placeholder.queue_free()
	
	placing = null
	hovered_row = null
	hovered_column = null
	
	toggle_frees()

func disable_building():
	disable_placeholder()
	
	building = false

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		raycast_grid(event.position)
	elif event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_LEFT || event.pressed || hovered_row == null:
			return
		
		if placing == null:
			var module = grid[hovered_row][hovered_column]
			
			create_free_at(hovered_row, hovered_column)
			
			enable_placeholder(module.index)
			
			module.queue_free()
		else:
			get_node('../SFX/Module Place').play()
			
			var module = [
				Drill,
				Battery,
				Wheel,
				Gun,
				Shield,
				Mine,
			][placing].instantiate()
			
			module.position.x = hovered_column - core_column
			module.position.z = hovered_row - core_row
			
			add_child(module)
			
			grid[hovered_row][hovered_column].queue_free()
			grid[hovered_row][hovered_column] = module
			
			if hovered_row == 0:
				core_row += 1
				
				var row = []
				
				row.resize(grid[0].size())
				
				grid.push_front(row)
			
			if hovered_row == grid.size() - 1:
				var row = []
				
				row.resize(grid[0].size())
				
				grid.push_back(row)
			
			if hovered_column == 0:
				core_column += 1
				
				for row in grid:
					row.push_front(null)
			
			if hovered_column == grid[0].size() - 1:
				for row in grid:
					row.push_back(null)
			
			create_frees()
			
			toggle_frees() # disable_placeholder() instead if moving existing module or not enough resources left
	elif event is InputEventKey:
		if event.keycode == KEY_ESCAPE:
			disable_placeholder()

func _notification(what):
	if what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN:
		raycast_grid(get_viewport().get_mouse_position())

func _physics_process(delta: float):
	if input.rot != 0:
		raycast_grid(get_viewport().get_mouse_position())


func _integrate_forces(state):
	var velocity = Vector2()

	state.angular_velocity = Vector3(0, -input.rot * rotation_speed,0).rotated(Vector3(0, 1, 0), rotation.y)
#	rotation.y += input.rot * rotation_speed

	state.linear_velocity = Vector3(0, 0, -input.speed * forward_speed).rotated(Vector3(0, 1, 0), rotation.y)
