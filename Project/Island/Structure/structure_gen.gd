extends Node

@export var dock:PackedScene 
@export var building:PackedScene 

func generate():
	var island = get_parent()
	var i1 = dock.instantiate()
	island.add_child(i1)
	i1.generate()
	
	
	var i2 = building.instantiate()
	island.add_child(i2)
	i2.generate()
	pass
