extends Node3D

@export var max_volume = -10

const MAIN = "Main";
const COMBAT = "Combat";


var tracks = [MAIN, COMBAT];
var current_track = MAIN;
var tween;

func _ready():
	for track in tracks:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(track), max_volume if track == current_track else -50)

func crossfade_buses(to_bus_name, duration):
	if to_bus_name == current_track:
		return
	
	current_track = to_bus_name
	
	var fadeout_duration = duration * AudioServer.get_bus_volume_db(AudioServer.get_bus_index(current_track)) / -50
	var fadein_duration = fadeout_duration / 40
	
	if tween != null:
		tween.kill()
	
	tween = create_tween().set_parallel()
	
	for track in tracks:
		var index = AudioServer.get_bus_index(track)
		
		if track == current_track:
			tween.tween_method(func(value): AudioServer.set_bus_volume_db(index, value), AudioServer.get_bus_volume_db(index), max_volume, fadein_duration)
		else:
			tween.tween_method(func(value): AudioServer.set_bus_volume_db(index, value), AudioServer.get_bus_volume_db(index), -50.0, fadeout_duration)

func _process(delta):
	test_music();
	mute_music();

func test_music():
	if Input.is_action_just_pressed("debug_music_change"):
		crossfade_buses(COMBAT if current_track == MAIN else MAIN, 4)
		print(current_track);

func mute_music():
	if Input.is_action_just_pressed("debug_music_mute"):
		$MAIN.stop();
		$COMBAT.stop();
