extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func play_sound_shoot():
	$SND_SHOOT.play();
		
func play_sound_drill():
	if !$SND_DRILL_LOOP.playing:
		$SND_DRILL_LOOP.play();

func play_sound_hit():
	$SND_HIT.play();
