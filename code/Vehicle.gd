extends Node3D

func enable_placeholder(ind):
	$Body.enable_placeholder(ind)

func is_local():
	return $Body.is_local()
