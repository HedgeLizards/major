extends MeshInstance3D

func _ready():
	set_surface_override_material(0, get_surface_override_material(0).duplicate())
