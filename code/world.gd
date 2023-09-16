extends Node3D

const SPAWN_RANDOM := 5.0

enum Tile {Open, Rock}

var mesh_map = {}

func tile_at(p: Vector2i) -> Tile:
	if p.length() > 6 || p.length() == 0:
		return Tile.Rock
	else:
		return Tile.Open

func view(p: Vector2i):
	var old_mesh: Node3D = mesh_map.get(p)
	if old_mesh:
		old_mesh.queue_free()
	var new_mesh: Node3D = mesh_for(tile_at(p))
	mesh_map[p] = new_mesh
	new_mesh.position.x = p.x
	new_mesh.position.z = p.y
	$Environment.add_child(new_mesh)

func mesh_for(tile: Tile):
	if tile == Tile.Open:
		return preload("res://scenes/tiles/ground.tscn").instantiate()
	elif tile == Tile.Rock:
		return preload("res://scenes/tiles/rock.tscn").instantiate()
	assert(false, "unknown tile")

func _ready():
	# We only need to spawn players on the server.
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(add_player)
		multiplayer.peer_disconnected.connect(del_player)

		# Spawn already connected players.
		for id in multiplayer.get_peers():
			add_player(id)

		# Spawn the local player unless this is a dedicated server export.
		if not OS.has_feature("dedicated_server"):
			add_player(1)
	
	for x in range(-20, 20):
		for y in range(-20, 20):
			view(Vector2i(x, y))


func _exit_tree():
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(del_player)


func add_player(id: int):
	var character = preload("res://scenes/vehicle.tscn").instantiate()
	# Set player id.
	character.player = id
	# Randomize character position.
	var pos := Vector2.from_angle(randf() * 2 * PI)
	character.position = Vector3(pos.x * SPAWN_RANDOM * randf(), 0.5, pos.y * SPAWN_RANDOM * randf())
	character.name = str(id)
	$Players.add_child(character, true)


func del_player(id: int):
	if not $Players.has_node(str(id)):
		return
	$Players.get_node(str(id)).queue_free()
