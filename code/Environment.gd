extends Node3D


enum Tile {Open, Rock}

var mesh_map = {}
var map = {}

func tile_at(p: Vector2i) -> Tile:
	return map.get(p, Tile.Rock)

func view(p: Vector2i):
	var old_mesh: Node3D = mesh_map.get(p)
	if old_mesh:
		old_mesh.queue_free()
	var new_mesh: Node3D = mesh_for(tile_at(p))
	mesh_map[p] = new_mesh
	new_mesh.position.x = p.x
	new_mesh.position.z = p.y
	add_child(new_mesh)

func mesh_for(tile: Tile):
	if tile == Tile.Open:
		return preload("res://scenes/tiles/ground.tscn").instantiate()
	elif tile == Tile.Rock:
		return preload("res://scenes/tiles/rock.tscn").instantiate()
	assert(false, "unknown tile")

func dig_tile(p: Vector2i) -> void:
	map[p] = Tile.Open

func dig(v: Vector2) -> void:
	var p: Vector2i = v.floor()
	dig_tile(p)
	view(p)

# Called when the node enters the scene tree for the first time.
func _ready():
	for x in range(-50, 50):
		for y in range(-50, 50):
			var p := Vector2i(x, y)
			if p.length() < 6:
				dig_tile(p)
			view(p)


