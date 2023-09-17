extends Area3D

var available = false

func _physics_process(_delta):
	for body in get_overlapping_bodies():
		if body.has_method("dig"):
			body.dig($DigCenter.global_position)
