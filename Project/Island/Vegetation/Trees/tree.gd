extends Node3D

@export var top_chance = 50

func _ready():
	if randf_range(0, 100) > top_chance:
		var top = get_node("Tree00Top")
		top.free()
	pass 

