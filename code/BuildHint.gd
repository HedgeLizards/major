extends Label

func _ready():
	var screen_scale = DisplayServer.screen_get_scale(DisplayServer.window_get_current_screen())
	
	offset_bottom = -160 * screen_scale
	scale *= screen_scale

func _on_resized():
	pivot_offset = size / Vector2(2, 1)
