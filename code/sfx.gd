extends Node3D

var canShoot : bool = true
var cooldown : float = .15
var timer : float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	test_fire(delta);
	test_drill();
	test_sound_collect();
	test_sound_grab();
	test_sound_rotate();
	test_sound_place();

func test_fire(delta):
	if Input.is_action_pressed("debug_fire") and canShoot:
		$Fire.play();
		canShoot = false;
		timer = cooldown;
	
	if !canShoot:
		timer -= delta;
		if timer <= 0:
			canShoot = true;

func test_drill():
	if Input.is_action_pressed("debug_drill"):
		if !$Drill.playing:
			$Drill.play();
	if Input.is_action_just_released("debug_drill"):
		if $Drill.playing:
			$Drill.stop();

func test_sound_collect():
	if Input.is_action_just_pressed("debug_ore_collect"):
		$"Ore Collect".play();

func test_sound_grab():
	if Input.is_action_just_pressed("debug_module_grab"):
		$"Module Grab".play();

func test_sound_rotate():
	if Input.is_action_just_pressed("debug_module_rotate"):
		$"Module Rotate".play();

func test_sound_place():
	if Input.is_action_just_pressed("debug_module_place"):
		$"Module Place".play();
