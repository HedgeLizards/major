extends MeshInstance3D

var index = -1

func _ready():
	set_surface_override_material(0, get_surface_override_material(0).duplicate())
