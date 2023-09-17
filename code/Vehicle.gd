extends Node3D

func is_local():
	return $Body.is_local()

func enable_placeholder(index):
	$Body.enable_placeholder(index)

func disable_placeholder():
	$Body.disable_placeholder()
