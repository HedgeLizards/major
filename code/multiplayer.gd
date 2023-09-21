extends Node

const PORT := 12023

const world_scene: PackedScene = preload("res://scenes/world.tscn")
enum Status {Start, HostLobby, ClientConnecting, ClientLobby, Game}
var status = Status.Start

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.server_relay = false 
	if DisplayServer.get_name() == "headless":
		print("Automatically starting dedicated server.")
		_on_host_button_pressed.call_deferred()



func _on_host_button_pressed() -> void:
	print("host pressed")
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server.")
		return
	multiplayer.multiplayer_peer = peer
	start_lobby()


func _on_join_button_pressed():
	var address: String = %AddressField.text
	
	if address == "":
		OS.alert("Need a remote to connect to.")
		return
	multiplayer.connected_to_server.connect(start_lobby)
	multiplayer.connection_failed.connect(back_to_main)
	multiplayer.server_disconnected.connect(back_to_main)
	var peer: MultiplayerPeer = ENetMultiplayerPeer.new()
	if peer.create_client(address, PORT) != 0:
		OS.alert("Failed to start multiplayer client.")
		return
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer client.")
		return
#	print("join status ", peer.get_connection_status())
	multiplayer.multiplayer_peer = peer
	$UI/Connecting.show()
#	start_lobby()

func back_to_main():
	multiplayer.multiplayer_peer = null
	$Lobby.hide()
	$UI.show()
	$UI/Connecting.hide()

func start_lobby():
	$UI.hide()
	$Lobby.show()
	
	$Lobby/HostControls.visible = multiplayer.is_server()
	if multiplayer.is_server():
		$Lobby/HostControls/IpAddresses.text = "\n".join(IP.get_local_addresses())
 
@rpc("authority", "call_local", "reliable")
func start_game():
	print("starting game")
	$UI.hide()
	$Lobby.hide()
#	var world := world_scene.instantiate()
#	add_child(world, true)
	multiplayer.multiplayer_peer.refuse_new_connections = true
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



func _on_start_button_pressed():
	start_game.rpc()

