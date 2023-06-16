extends Node3D

const MIN_SIZE = 5
const MAX_SIZE = 10
const MIN_HEIGHT = 5
const MAX_HEIGHT = 7
const HEIGHT_BASE = 2

const SPAWN_HEIGHT_MIN = 3
const SPAWN_HEIGHT_MAX = 15

func try_place() -> bool:
	var island = get_parent()
	var pos = island.global_position
	var x = randf_range(pos.x, pos.x + island.SIZE)
	var y = randf_range(pos.z, pos.z + island.SIZE)
	var height = island.get_height(x, y)
	if height > SPAWN_HEIGHT_MIN && height < SPAWN_HEIGHT_MAX:
		global_position = Vector3(x, height - HEIGHT_BASE, y)
		return true
	return false

func generate():
	
	var size = Vector3(
		randf_range(MIN_SIZE, MAX_SIZE), 
		randf_range(MIN_HEIGHT, MAX_HEIGHT),
		randf_range(MIN_SIZE, MAX_SIZE))
	var rot = randf_range(0, PI * 2)
	global_rotation.y = rot
	scale = size
	
	for i in 20:
		if try_place():
			break
	
	pass
