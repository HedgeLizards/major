extends MultiplayerSynchronizer


@export var inp := Vector2(0, 0)

func _ready():
	# Only process for the local player.
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	inp = Input.get_vector("right", "left", "forward", "backward")
#	if inp != Vector2(0, 0):
#		print(inp)
