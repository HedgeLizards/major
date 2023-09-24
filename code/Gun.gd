extends Node3D

var index = 3
var solid = false
var powered = false

var can_shoot : bool = true
var cooldown : float = .3 # Cooldown between bursts
var timer : float = 0
var original_burst_count : int = 3 # Shots per burst
var burst_count = original_burst_count
var burst_interval : float = .05 # Time between shots in a burst
var burst_timer : float = 0

signal gun_shot

func _ready():
	connect("gun_shot", SFX.play_sound_shoot)
	$AnimationPlayer.stop()

func _process(delta):
	# Handle Animation Player
	#if Input.is_action_pressed("shoot"):
		
	#else:

	# Check if the gun can shoot a burst
	if get_node("..").is_local() && Input.is_action_pressed("shoot") && can_shoot:
		can_shoot = false
		timer = cooldown
		
	# Handle burst firing
	if !can_shoot and burst_count > 0:
		burst_timer += delta
		if burst_timer >= burst_interval:
			$AnimationPlayer.stop()
			get_tree().call_group("creators", "shoot", $GunMesh/BulletSpawn.global_position, global_rotation)
			emit_signal("gun_shot")
			burst_count -= 1
			burst_timer = 0
			$AnimationPlayer.play()
	
	# Reset burst count and handle cooldown
	if !can_shoot and burst_count <= 0:
		#$AnimationPlayer.stop()
		timer -= delta
		if timer <= 0:
			can_shoot = true
			burst_count = original_burst_count # Reset burst count
