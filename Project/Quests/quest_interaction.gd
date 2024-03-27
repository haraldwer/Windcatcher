class_name QuestInteraction
extends Node3D

@export var DialogType:PackedScene

func on_enter(body):
	# disable player controls
	var parent = body.get_parent()
	if parent:
		var controller = parent.get_node("Controller")
		if controller:
			controller.enabled = false
	
	var dialogUI = DialogType.instantiate()
	get_parent().add_child(dialogUI)
	pass


func on_exit(body):
	pass
