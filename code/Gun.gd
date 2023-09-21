extends Node3D

var index = 3
var solid = false
var powered = false

func _input(_event):
	if get_node("..").is_local() && Input.is_action_just_pressed("shoot"):
		get_tree().call_group("creators", "shoot", global_position, global_rotation)
