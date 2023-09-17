extends Area3D

var index = 0

func _physics_process(_delta):
	for body in get_overlapping_bodies():
		if body.has_method("dig"):
			body.dig.rpc($DigCenter.global_position)
