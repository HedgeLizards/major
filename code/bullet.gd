extends Node3D

var speed: float = 70
var max_spread : float = 1
var spread

signal bullet_hit

func _ready():
	spread = randf_range(-max_spread, max_spread)
	connect("bullet_hit", SFX.play_sound_hit)

func _on_timer_timeout():
	queue_free()

func _physics_process(delta):
	position += Vector3(0, 0, -delta * speed).rotated(Vector3(0, 1, 0), rotation.y + deg_to_rad(spread))
	# This line is modified to include the spread in bullet's direction.

# This function isn't called anywhere right now, but
# should ideally be called when colliding with another player or other boundary.
func hit():
	emit_signal("bullet_hit")
