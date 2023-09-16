extends Node

const PORT := 12023

const world_scene: PackedScene = preload("res://scenes/world.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.server_relay = false 
	if DisplayServer.get_name() == "headless":
		print("Automatically starting dedicated server.")
		_on_host_button_pressed.call_deferred()



func _on_host_button_pressed():
	print("host pressed")
	var peer: MultiplayerPeer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server.")
		return
	multiplayer.multiplayer_peer = peer
	start_game()


func _on_join_button_pressed():
	var address: String = %AddressField.text
	
	if address == "":
		OS.alert("Need a remote to connect to.")
		return
	var peer: MultiplayerPeer = ENetMultiplayerPeer.new()
	peer.create_client(address, PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer client.")
		return
	multiplayer.multiplayer_peer = peer
	start_game()

func start_game():
	print("starting game")
	$UI.hide()
#	var world := world_scene.instantiate()
#	add_child(world, true)
	if multiplayer.is_server():
		change_level.call_deferred(load("res://scenes/world.tscn"))

# Call this function deferred and only on the main authority (server).
func change_level(scene: PackedScene):
	# Remove old level if any.
	var level = $World
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	# Add new level.
	level.add_child(scene.instantiate())

