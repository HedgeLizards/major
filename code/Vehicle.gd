extends Node3D

var Free = preload('res://scenes/free.tscn')
var Drill = preload('res://scenes/drill.tscn')
var Battery = preload('res://scenes/battery.tscn')
var Wheel = preload('res://scenes/wheel.tscn')
var Gun = preload('res://scenes/gun.tscn')
var Shield = preload('res://scenes/shield.tscn')
var Mine = preload('res://scenes/mine.tscn')
var invalid = preload('res://resources/invalid.tres')

var core_row = 1
var core_column = 1
var placing
var hovered_row
var hovered_column

var forward_speed := 5
var rotation_speed := 1.0 * PI

@onready var camera = $Camera3D
@onready var grid = [
	[null, null, null],
	[null, $Body/Core, null],
	[null, null, null],
]
@onready var input := $PlayerInput

# Set by the authority, synchronized on spawn.
@export var player := 1 :
	set(id):
		player = id
		# Give authority over the player input to the appropriate peer.
		$PlayerInput.set_multiplayer_authority(id)

func is_local():
	return player == multiplayer.get_unique_id()

func _ready():
	if is_local:
		camera.make_current()
	
	for r in grid.size():
		for c in grid[0].size():
			if grid[r][c] != null:
				continue
			
			var free = Free.instantiate()
			
			free.position.x = c - core_column
			free.position.y = -0.4
			free.position.z = r - core_row
			
			$Body.add_child(free)
			
			grid[r][c] = free

func toggle_frees():
	var tween = create_tween().set_parallel().set_trans(Tween.TRANS_SINE)
	
	for r in grid.size():
		for c in grid[0].size():
			if grid[r][c] != null && grid[r][c].available:
				tween.tween_property(grid[r][c].get_surface_override_material(0), 'albedo_color:a', 0.0 if placing == null else 0.5, 0.2)

func enable_placeholder(index):
	if placing != null:
		$Body/Placeholder.free()
	
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
	
	$Body.add_child(placeholder_mesh)
	
	toggle_frees()
	
	move_placeholder(get_viewport().get_mouse_position())

func move_placeholder(mouse_position):
	if placing == null:
		return
	
	var intersection_point = Plane.PLANE_XZ.intersects_ray(
		camera.project_ray_origin(mouse_position),
		camera.project_ray_normal(mouse_position)
	)
	
	if intersection_point == null:
		hovered_row = null
		hovered_column = null
	else:
		intersection_point = (intersection_point - position).rotated(Vector3.UP, -$Body.rotation.y)
		
		hovered_row = floor(intersection_point.z + 0.5) + core_row
		hovered_column = floor(intersection_point.x + 0.5) + core_column
		
		if hovered_row < 0 || hovered_row >= grid.size() || \
			hovered_column < 0 || hovered_column >= grid[0].size() || \
			grid[hovered_row][hovered_column] == null || !grid[hovered_row][hovered_column].available:
			hovered_row = null
			hovered_column = null
	
	if hovered_row == null:
		$Body/Placeholder.set_surface_override_material(0, invalid)
		
		$Body/Placeholder.position.x = intersection_point.x
		$Body/Placeholder.position.z = intersection_point.z
	else:
		$Body/Placeholder.set_surface_override_material(0, null)
		
		$Body/Placeholder.position.x = hovered_column - core_column
		$Body/Placeholder.position.z = hovered_row - core_row

func disable_placeholder():
	$Body/Placeholder.queue_free()
	
	placing = null
	hovered_row = null
	hovered_column = null
	
	toggle_frees()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		move_placeholder(event.position)
	elif event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_LEFT || !event.pressed || hovered_row == null:
			return
		
		var component = [
			Drill,
			Battery,
			Wheel,
			Gun,
			Shield,
			Mine,
		][placing].instantiate()
		
		component.position.x = hovered_column - core_column
		component.position.z = hovered_row - core_row
		
		$Body.add_child(component)
		
		grid[hovered_row][hovered_column] = component
		
		disable_placeholder()
	elif event is InputEventKey:
		if event.keycode == KEY_ESCAPE && placing != null:
			disable_placeholder()

func _notification(what):
	if what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN:
		move_placeholder(get_viewport().get_mouse_position())

func _physics_process(delta: float):
	var inp: Vector2 = input.inp
	if inp.x != 0:
		move_placeholder(get_viewport().get_mouse_position())
	var rot := rotation_speed * inp.x * delta
	var speed := forward_speed * inp.y * delta
	$Body.rotation.y += rot
	var vel := Vector2(0, speed).rotated($Body.rotation.y)
	position.x -= vel.x
	position.z += vel.y
