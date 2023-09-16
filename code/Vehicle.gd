extends Node3D

var hovered_cell
var forward_speed := 5
var rotation_speed := 1.0 * PI

@onready var camera = $Camera3D
@onready var input := $PlayerInput

# Set by the authority, synchronized on spawn.
@export var player := 1 :
	set(id):
		player = id
		# Give authority over the player input to the appropriate peer.
		$PlayerInput.set_multiplayer_authority(id)

func _unhandled_input(event):
	if !event is InputEventMouseMotion:
		return
	
	var mouse_position = event.position
	var intersection_point = Plane.PLANE_XZ.intersects_ray(
		camera.project_ray_origin(mouse_position),
		camera.project_ray_normal(mouse_position)
	)
	var new_hovered_cell
	
	if intersection_point == null:
		pass
	elif intersection_point.x >= -1 && intersection_point.x < 0 && intersection_point.z >= -1 && intersection_point.z < 0:
		new_hovered_cell = 1
	elif intersection_point.x >= 0 && intersection_point.x < 1 && intersection_point.z >= -1 && intersection_point.z < 0:
		new_hovered_cell = 2
	elif intersection_point.x >= 0 && intersection_point.x < 1 && intersection_point.z >= 0 && intersection_point.z < 1:
		new_hovered_cell = 3
	elif intersection_point.x >= -1 && intersection_point.x < 0 && intersection_point.z >= 0 && intersection_point.z < 1:
		new_hovered_cell = 4
	
	if new_hovered_cell == hovered_cell:
		return
	
	if hovered_cell != null:
		get_node("Body/Cell%d" % hovered_cell).get_surface_override_material(0).albedo_color = Color(0, 0.5, 1, 0.5)
	
	hovered_cell = new_hovered_cell
	
	if hovered_cell != null:
		get_node("Body/Cell%d" % hovered_cell).get_surface_override_material(0).albedo_color = Color(1, 0.5, 0, 0.5)


func _physics_process(delta: float):
	var inp: Vector2 = input.inp
	var rot := rotation_speed * inp.x * delta
	var speed := forward_speed * inp.y * delta
	$Body.rotation.y += rot
	var vel := Vector2(0, speed).rotated($Body.rotation.y)
	position.x -= vel.x
	position.z += vel.y
