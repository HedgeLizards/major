extends CanvasLayer

var screen_scale = DisplayServer.screen_get_scale(DisplayServer.window_get_current_screen())

func _ready():
	$VBoxContainer1.scale *= screen_scale
	$VBoxContainer2.scale *= screen_scale
	$VBoxContainer3.scale *= screen_scale
	$VBoxContainer4.scale *= screen_scale
	$VBoxContainer5.scale *= screen_scale
	$VBoxContainer6.scale *= screen_scale
	$Build.scale *= screen_scale

func _on_drill_pressed():
	pass # Replace with function body.

func _on_engine_pressed():
	pass # Replace with function body.

func _on_wheel_pressed():
	pass # Replace with function body.

func _on_gun_pressed():
	pass # Replace with function body.

func _on_shield_pressed():
	pass # Replace with function body.

func _on_mine_pressed():
	pass # Replace with function body.

func _on_build_toggled(button_pressed):
	var tween = create_tween().set_parallel().set_trans(Tween.TRANS_SINE)
	
	if button_pressed:
		for i in 6:
			var v_box_container = get_child(i)
			
			tween.tween_property(v_box_container, 'offset_right', (6 - i) * -100 * screen_scale, 0.5)
			tween.tween_property(v_box_container, 'modulate:a', 1, 0.5)
	else:
		for i in 6:
			var v_box_container = get_child(i)
			
			tween.tween_property(v_box_container, 'offset_right', 0, 0.5)
			tween.tween_property(v_box_container, 'modulate:a', 0, 0.5)

func _on_drill_mouse_entered():
	$VBoxContainer1/Label1.visible = true
	$VBoxContainer1/Label2.visible = true

func _on_drill_mouse_exited():
	$VBoxContainer1/Label1.visible = false
	$VBoxContainer1/Label2.visible = false

func _on_engine_mouse_entered():
	$VBoxContainer2/Label1.visible = true
	$VBoxContainer2/Label2.visible = true

func _on_engine_mouse_exited():
	$VBoxContainer2/Label1.visible = false
	$VBoxContainer2/Label2.visible = false

func _on_wheel_mouse_entered():
	$VBoxContainer3/Label1.visible = true
	$VBoxContainer3/Label2.visible = true

func _on_wheel_mouse_exited():
	$VBoxContainer3/Label1.visible = false
	$VBoxContainer3/Label2.visible = false

func _on_gun_mouse_entered():
	$VBoxContainer4/Label1.visible = true
	$VBoxContainer4/Label2.visible = true

func _on_gun_mouse_exited():
	$VBoxContainer4/Label1.visible = false
	$VBoxContainer4/Label2.visible = false

func _on_shield_mouse_entered():
	$VBoxContainer5/Label1.visible = true
	$VBoxContainer5/Label2.visible = true

func _on_shield_mouse_exited():
	$VBoxContainer5/Label1.visible = false
	$VBoxContainer5/Label2.visible = false

func _on_mine_mouse_entered():
	$VBoxContainer6/Label1.visible = true
	$VBoxContainer6/Label2.visible = true

func _on_mine_mouse_exited():
	$VBoxContainer6/Label1.visible = false
	$VBoxContainer6/Label2.visible = false
