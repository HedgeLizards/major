extends Node3D

@onready var Bullet = preload("res://scenes/bullet.tscn")


func shoot(pos: Vector3, rot: Vector3):
	do_shoot.rpc(pos, rot)

@rpc("any_peer", "call_local", "reliable")
func do_shoot(pos: Vector3, rot: Vector3):
	var bullet = Bullet.instantiate()
	bullet.position = pos
	bullet.rotation = rot
	add_child(bullet)
