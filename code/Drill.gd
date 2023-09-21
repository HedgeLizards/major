extends Area3D

var index = 0
var solid = false
var powered = false

signal start_digging
signal stop_digging

func _ready():
	$AnimationPlayer.stop();
	
	connect("start_digging", SFX.play_sound_digging)
	connect("stop_digging", SFX.stop_sound_digging)

func _physics_process(delta: float):
	var is_digging = false;
	
	for body in get_overlapping_bodies():
		if body.has_method("dig"):
			is_digging = true;
			body.dig($DigCenter.global_position, delta)
	
	if is_digging:
		# Replace this with the signal stuff
		#emit_signal("start_digging")
		
		if !$SND_DRILL_LOOP.playing:
			$SND_DRILL_LOOP.play();
		if !$CPUParticles3D.emitting:
			$CPUParticles3D.emitting = true
		if !$AnimationPlayer.is_playing():
			$AnimationPlayer.play()
	else:
		#emit_signal("stop_digging")
		
		if $SND_DRILL_LOOP.playing:
			$SND_DRILL_LOOP.stop();
		if $CPUParticles3D.emitting:
			$CPUParticles3D.emitting = false
		if $AnimationPlayer.is_playing():
			$AnimationPlayer.stop()
