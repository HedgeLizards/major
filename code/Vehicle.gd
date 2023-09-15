extends Node3D

var hovered_cell

@onready var camera = $Camera3D

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
		get_node("Cell%d" % hovered_cell).get_surface_override_material(0).albedo_color = Color(0, 0.5, 1, 0.5)
	
	hovered_cell = new_hovered_cell
	
	if hovered_cell != null:
		get_node("Cell%d" % hovered_cell).get_surface_override_material(0).albedo_color = Color(1, 0.5, 0, 0.5)
