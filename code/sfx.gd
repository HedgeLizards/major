extends Node3D

var drill_count : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func play_sound_shoot():
	$SND_SHOOT.play();

func play_sound_digging():
	drill_count += 1
	if !$SND_DRILL_LOOP.playing:
		$SND_DRILL_LOOP.play()

func stop_sound_digging():
	drill_count = max(0, drill_count - 1)
	if drill_count == 0 and $SND_DRILL_LOOP.playing:
		$SND_DRILL_LOOP.stop()

func play_sound_hit():
	$SND_HIT.play();
