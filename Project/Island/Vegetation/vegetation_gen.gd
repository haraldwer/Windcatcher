class_name VegetationGen
extends Node

const DENSITY = 0.01
const VEGETATION_START = 0.5
const RAND_ROT = 0.1
const RAND_SCALE = 0.2

@export var vegetation:Array[PackedScene]

func place_vegetation():
	var island = get_parent()
	
	var pos = island.global_position
	var x = randf_range(pos.x, pos.x + island.Size)
	var y = randf_range(pos.z, pos.z + island.Size)
	
	var height = island.get_height(x, y)
	if height > VEGETATION_START:
		var veg = vegetation.pick_random()
		var instance = veg.instantiate()
		island.add_child(instance)
		instance.global_position = Vector3(x, height, y)
		instance.global_rotation.y = randf_range(0, PI * 2)
		instance.global_rotation.x = randf_range(-RAND_ROT, RAND_ROT)
		instance.global_rotation.z = randf_range(-RAND_ROT, RAND_ROT)
		instance.global_scale(Vector3.ONE * (1 + randf_range(-RAND_SCALE, RAND_SCALE)))
	
	pass

func generate():
	
	var island = get_parent()
	var area = island.Size * island.Size
	print("Vegetation ", area * DENSITY)
	for n in area * DENSITY:
		place_vegetation()
	
	pass
