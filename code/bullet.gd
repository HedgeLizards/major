extends Node3D

var speed: float = 40

signal bullet_hit

func _ready():
	connect("bullet_hit", SFX.play_sound_hit)

func _on_timer_timeout():
	queue_free()

func _physics_process(delta):
	position += Vector3(0, 0, -delta * speed).rotated(Vector3(0, 1, 0), rotation.y)
	
func hit():
	emit_signal("bullet_hit")
