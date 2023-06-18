extends Node3D

func _ready():
	for child in get_children():
		if child.name.begins_with("Streak"):
			child.position.y = randf_range(-0.1, 0.1);
			child.rotation.y = randf_range(0, 360)
	pass

func on_enter(body):
	var parent = body.get_parent()
	if parent:
		var wind = parent.get_node("Wind")
		if wind:
			wind.on_enter(self); 
	pass


func on_exit(body):
	var parent = body.get_parent()
	if parent:
		var wind = parent.get_node("Wind")
		if wind:
			wind.on_exit(self); 
	pass
