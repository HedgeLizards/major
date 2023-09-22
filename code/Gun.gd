extends Node3D

var index = 3
var solid = false
var powered = false

signal gun_shot

var canShoot : bool = true
var cooldown : float = .15
var timer : float = 0

func _ready():
	connect("gun_shot", SFX.play_sound_shoot)

func _process(_delta):
	if Input.is_action_pressed("shoot"):
		$AnimationPlayer.play();
	else:
		$AnimationPlayer.stop();
	
	if get_node("..").is_local() && Input.is_action_pressed("shoot") && canShoot:
		get_tree().call_group("creators", "shoot", $GunMesh/BulletSpawn.global_position, global_rotation)
		emit_signal("gun_shot")
		canShoot = false;
		timer = cooldown;
	
	if !canShoot:
		timer -= _delta;
		if timer <= 0:
			canShoot = true;
