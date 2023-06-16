extends Node3D

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
