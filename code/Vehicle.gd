extends Node3D

func is_local():
	return $Body.is_local()

func enable_building():
	$Body.enable_building()
	
func lock_pointing_hand():
	$Body.lock_pointing_hand = true

func enable_placeholder(index):
	$Body.enable_placeholder(index)

func unlock_pointing_hand():
	$Body.lock_pointing_hand = false

func disable_building():
	$Body.lock_pointing_hand = false
	
	$Body.disable_building()
