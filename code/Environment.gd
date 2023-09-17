extends GridMap

enum Tile {Open, Rock}

var map = {}

func tile_at(p: Vector2i) -> Tile:
	return map.get(p, Tile.Rock)

func view(p: Vector2i):
	set_cell_item(Vector3i(p.x, 0, p.y), grid_index_for(tile_at(p)))

func grid_index_for(tile: Tile) -> int:
	if tile == Tile.Open:
		return 1
	if tile == Tile.Rock:
		return 0
	return -1


func dig_tile(p: Vector2i) -> void:
	map[p] = Tile.Open

func dig(v: Vector3) -> void:
	var lv := to_local(v).floor()
	var p := Vector2(lv.x, lv.z)
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


