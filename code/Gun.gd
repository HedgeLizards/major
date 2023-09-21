extends Node3D

var index = 3
var solid = false
var powered = false

signal gun_shot

var canShoot : bool = true
var cooldown : float = .15
var timer : float = 0

func _ready():
	var sfx = get_node('../../SFX')
	connect("gun_shot", sfx.play_sound_shoot)

func _process(_delta):
	if get_node("..").is_local() && Input.is_action_pressed("shoot") && canShoot:
		get_tree().call_group("creators", "shoot", global_position, global_rotation)
		emit_signal("gun_shot")
		canShoot = false;
		timer = cooldown;
	
	if !canShoot:
		timer -= _delta;
		if timer <= 0:
			canShoot = true;
