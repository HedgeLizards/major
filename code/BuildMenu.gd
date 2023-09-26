extends Control

var costs = [
	{ 'Red': 1, 'Yellow': 1 }, # Drill
	{ 'Green': 2, 'Yellow': 3 }, # Battery
	{ 'Blue': 2, 'Yellow': 1 }, # Wheel
	{ 'Blue': 1, 'Red': 2, 'Yellow': 1 }, # Gun
	{ 'Green': 2 }, # Shield
]
var screen_scale = DisplayServer.screen_get_scale(DisplayServer.window_get_current_screen())

func _ready():
	$VBoxContainer6.free() # TEMPORARY
	
	for child in get_children():
		child.scale *= screen_scale
	
	set_up_costs()

func enable_placeholder(index):
	for child in get_node('../../Players').get_children():
		if child.is_local():
			child.enable_placeholder(index)
			
			return

func show_labels(index):
	var v_box_container = get_child(index)
	var number_of_h_box_containers = v_box_container.get_child_count() - 1
	
	v_box_container.pivot_offset.y += number_of_h_box_containers * 34
	
	for i in number_of_h_box_containers:
		v_box_container.get_child(i).visible = true
	
	for child in get_node('../../Players').get_children():
		if child.is_local():
			child.lock_pointing_hand()
			
			return

func hide_labels(index):
	var v_box_container = get_child(index)
	var number_of_h_box_containers = v_box_container.get_child_count() - 1
	
	v_box_container.pivot_offset.y -= number_of_h_box_containers * 34
	
	for i in number_of_h_box_containers:
		v_box_container.get_child(i).visible = false
	
	for child in get_node('../../Players').get_children():
		if child.is_local():
			child.unlock_pointing_hand()
			
			return

func _on_build_toggled(button_pressed):
	var number_of_v_box_containers = get_child_count() - 1
	var tween = create_tween().set_parallel().set_trans(Tween.TRANS_SINE)
	
	if button_pressed:
		for i in number_of_v_box_containers:
			var v_box_container = get_child(i)
			
			tween.tween_property(v_box_container, 'offset_right', (number_of_v_box_containers - i) * -100 * screen_scale, 0.4)
			tween.tween_property(v_box_container, 'modulate:a', 1, 0.4)
		
		for child in get_node('../../Players').get_children():
			if child.is_local():
				child.enable_building()
				
				return
	else:
		for i in number_of_v_box_containers:
			var v_box_container = get_child(i)
			
			tween.tween_property(v_box_container, 'offset_right', 0, 0.4)
			tween.tween_property(v_box_container, 'modulate:a', 0, 0.4)
		
		for child in get_node('../../Players').get_children():
			if child.is_local():
				child.disable_building()
				
				return

func set_up_costs():
	for i in get_child_count() - 1:
		var v_box_container = get_child(i)
		var ores = costs[i]
		var keys = ores.keys()
		var h_box_container = v_box_container.get_child(0)
		
		for j in ores.size():
			if j > 0:
				var new_h_box_container = h_box_container.duplicate()
				
				h_box_container.add_sibling(new_h_box_container)
				h_box_container = new_h_box_container
			
			h_box_container.get_child(0).text = '%dx' % ores[keys[j]]
			h_box_container.get_child(1).texture = load('res://sprites/GEM_%s.png' % keys[j])

func update_modules():
	var ores_menu = get_node('../OresMenu')
	
	for i in get_child_count() - 1:
		var v_box_container = get_child(i)
		var ores = costs[i]
		var keys = ores.keys()
		var number_of_ores = ores.size()
		var disabled = false
		
		for j in number_of_ores + 1:
			var child = v_box_container.get_child(j)
			
			if j == number_of_ores:
				child.disabled = disabled
			elif ores_menu.has({ keys[j]: ores[keys[j]] }):
				child.get_child(0).remove_theme_color_override('font_color')
			else:
				child.get_child(0).add_theme_color_override('font_color', Color.RED)
				
				disabled = true

func deconstruct_module(index):
	var ores_menu = get_node('../OresMenu')
	
	ores_menu.add(costs[index])

func construct_module(index):
	var ores_menu = get_node('../OresMenu')
	
	ores_menu.remove(costs[index])
	
	return ores_menu.has(costs[index])
