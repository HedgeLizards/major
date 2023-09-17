extends Node3D

var speed: float = 40



func _on_timer_timeout():
	queue_free()

func _physics_process(delta):
	position += Vector3(0, 0, -delta * speed).rotated(Vector3(0, 1, 0), rotation.y)
