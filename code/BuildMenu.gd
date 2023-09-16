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
	var number_of_v_box_containers = get_child_count() - 1
	var tween = create_tween().set_parallel().set_trans(Tween.TRANS_SINE)
	
	if button_pressed:
		for i in number_of_v_box_containers:
			var v_box_container = get_child(i)
			
			tween.tween_property(v_box_container, 'offset_right', (number_of_v_box_containers - i) * -100 * screen_scale, 0.4)
			tween.tween_property(v_box_container, 'modulate:a', 1, 0.4)
	else:
		for i in number_of_v_box_containers:
			var v_box_container = get_child(i)
			
			tween.tween_property(v_box_container, 'offset_right', 0, 0.4)
			tween.tween_property(v_box_container, 'modulate:a', 0, 0.4)

func show_labels(index):
	var v_box_container = get_child(index)
	var number_of_labels = v_box_container.get_child_count() - 1
	
	v_box_container.pivot_offset.y += number_of_labels * 30
	
	for i in number_of_labels:
		v_box_container.get_child(i).visible = true


func hide_labels(index):
	var v_box_container = get_child(index)
	var number_of_labels = v_box_container.get_child_count() - 1
	
	v_box_container.pivot_offset.y -= number_of_labels * 30
	
	for i in number_of_labels:
		v_box_container.get_child(i).visible = false
