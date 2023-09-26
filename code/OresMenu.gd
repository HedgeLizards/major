extends VBoxContainer

var ores = {
	'Blue': 0,
	'Green': 0,
	'Red': 0,
	'Yellow': 0,
}

func _ready():
	var screen_scale = DisplayServer.screen_get_scale(DisplayServer.window_get_current_screen())
	
	offset_bottom = -10 * screen_scale
	scale *= screen_scale
	
	add({ 'Blue': 25, 'Green': 25, 'Red': 25, 'Yellow': 25 })

func add(some_ores):
	for ore in some_ores.keys():
		ores[ore] += some_ores[ore]
		
		get_node(ore).get_node('Label').text = str(ores[ore])
	
	get_node('../BuildMenu').update_modules()

func remove(some_ores):
	for ore in some_ores.keys():
		ores[ore] -= some_ores[ore]
		
		get_node(ore).get_node('Label').text = str(ores[ore])
	
	get_node('../BuildMenu').update_modules()

func has(some_ores):
	for ore in some_ores:
		if ores[ore] < some_ores[ore]:
			return false
	
	return true
