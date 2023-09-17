extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	test_fire();
	test_drill();

func test_fire():
	if Input.is_action_just_pressed("fire"):
		$Fire.play();

func test_drill():
	if Input.is_action_pressed("drill"):
		if !$Drill.playing:
			$Drill.play();
	if Input.is_action_just_released("drill"):
		if $Drill.playing:
			$Drill.stop();
	
