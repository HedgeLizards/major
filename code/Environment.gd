extends GridMap

class TileType:
	func maxhealth():
		return 1.0
	func modelid():
		return -1
	func destructible():
		return false

class Open:
	extends TileType
	func modelid():
		return 1

class Rock:
	extends TileType
	func modelid():
		return 0
	func destructible():
		return true

class Edge:
	extends TileType
	func modelid():
		return 2

var OPEN: TileType = Open.new()
var ROCK: TileType = Rock.new()
var EDGE: TileType = Edge.new()

class Tile:
	var typ
	var health
	func _init(typ):
		self.health = typ.maxhealth()
		self.typ = typ

var EDGE_TILE = Tile.new(EDGE)

var map = {}

func tile_at(p: Vector2i) -> Tile:
	return map.get(p, EDGE_TILE)

func view(p: Vector2i):
	set_cell_item(Vector3i(p.x, 0, p.y), tile_at(p).typ.modelid())


@rpc("authority", "call_local", "reliable")
func clear_tile(p: Vector2i):
	map[p] = Tile.new(OPEN)
	view(p)

func dig_tile(p: Vector2i, damage: float) -> void:
	var tile := tile_at(p)
	if multiplayer.is_server() && tile.typ.destructible():
		tile.health -= damage
		if tile.health <= 0:
			clear_tile.rpc(p)

@rpc("any_peer", "call_local", "reliable")
func dig(v: Vector3, damage: float) -> void:
	var lv := to_local(v).floor()
	var p := Vector2(lv.x, lv.z)
	dig_tile(p, damage)

# Called when the node enters the scene tree for the first time.
func _ready():
	var rad: int = 20
	for x in range(-rad, rad):
		for y in range(-rad, rad):
			var p := Vector2i(x, y)
			map[p] = Tile.new(ROCK)
			if p.length() < 6:
				map[p] = Tile.new(OPEN)

	for x in range(-rad-10, rad+10):
		for y in range(-rad-10, rad+10):
			var p := Vector2i(x, y)
			view(p)


