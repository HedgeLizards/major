extends Node3D

func is_local():
	return $Body.is_local()

func enable_building():
	$Body.enable_building()

func enable_placeholder(index):
	$Body.enable_placeholder(index)

func disable_building():
	$Body.disable_building()
