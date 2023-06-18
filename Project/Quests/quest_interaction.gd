extends Node3D

func on_enter(body):
	# disable player controls
	var parent = body.get_parent()
	if parent:
		var controller = parent.get_node("Controller")
		if controller:
			controller.enabled = false
	pass


func on_exit(body):
	pass
