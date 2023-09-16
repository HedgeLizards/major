extends Node3D

var Placeholder = preload('res://scenes/placeholder.tscn')
var core_row = 1
var core_column = 1
var hovered_row
var hovered_column
var forward_speed := 5
var rotation_speed := 1.0 * PI

@onready var grid = [
	[null, null, null],
	[null, $Body/Engine, null],
	[null, null, null],
]
@onready var camera = $Camera3D

func _ready():
	for r in grid.size():
		for c in grid[0].size():
			if grid[r][c] == null:
				var placeholder = Placeholder.instantiate()
				
				grid[r][c] = placeholder
				
				placeholder.position.z = r - core_row
				placeholder.position.x = c - core_column
				
				$Body.add_child(placeholder)

func _unhandled_input(event):
	if !event is InputEventMouseMotion:
		return
	
	var mouse_position = event.position
	var intersection_point = Plane.PLANE_XZ.intersects_ray(
		camera.project_ray_origin(mouse_position),
		camera.project_ray_normal(mouse_position)
	)
	var new_hovered_row
	var new_hovered_column
	
	if intersection_point != null:
		intersection_point = (intersection_point - position).rotated(Vector3.UP, -$Body.rotation.y)
		
		new_hovered_row = floor(intersection_point.z + 0.5) + core_row
		new_hovered_column = floor(intersection_point.x + 0.5) + core_column
		
		if new_hovered_row < 0 || new_hovered_row >= grid.size() || \
			new_hovered_column < 0 || new_hovered_column >= grid[0].size() || \
			grid[new_hovered_row][new_hovered_column].name == 'Engine':
			new_hovered_row = null
			new_hovered_column = null
	
	if new_hovered_row == hovered_row && new_hovered_column == hovered_column:
		return
	
	if hovered_row != null:
		grid[hovered_row][hovered_column].get_surface_override_material(0).albedo_color = Color(0, 0.5, 1, 0.5)

	hovered_row = new_hovered_row
	hovered_column = new_hovered_column

	if hovered_row != null:
		grid[hovered_row][hovered_column].get_surface_override_material(0).albedo_color = Color(1, 0.5, 0, 0.5)


func _physics_process(delta: float):
	var inp := Input.get_vector("right", "left", "forward", "backward")
	var rot := rotation_speed * inp.x * delta
	var speed := forward_speed * inp.y * delta
	$Body.rotation.y += rot
	var vel := Vector2(0, speed).rotated($Body.rotation.y)
	position.x -= vel.x
	position.z += vel.y
