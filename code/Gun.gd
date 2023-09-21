extends Node3D

var index = 3
var solid = false
var powered = false

var canShoot : bool = true
var cooldown : float = .15
var timer : float = 0

func _process(_delta):
	if get_node("..").is_local() && Input.is_action_pressed("shoot") and canShoot:
		get_tree().call_group("creators", "shoot", global_position, global_rotation)
		$SND_FIRE.play();
		canShoot = false;
		timer = cooldown;
	
	if !canShoot:
		timer -= _delta;
		if timer <= 0:
			canShoot = true;
