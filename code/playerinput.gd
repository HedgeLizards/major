extends MultiplayerSynchronizer


@export var rot: float = 0.0
@export var speed: float = 0.0

func _ready():
	# Only process for the local player.
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	speed = Input.get_axis("backward", "forward")
	rot = Input.get_axis("left", "right")
#	if inp != Vector2(0, 0):
#		print(inp)
