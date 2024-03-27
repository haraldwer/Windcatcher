class_name Dock
extends Node3D

const MAX_DEPTH = 5
const STEP_SIZE = 5
const HEIGHT = 1
const RAND_ROT = 0.1
const SCALE = 1.5

@export var dock_meshes:Array[Mesh]
@export var material:Material

func create_dock(x, y, angle):
	var instance = MeshInstance3D.new()
	add_child(instance)
	instance.mesh = dock_meshes.pick_random()
	instance.material_override = material
	instance.global_position = Vector3(x, HEIGHT, y)
	
	instance.global_rotation.y = angle
	instance.global_scale(SCALE * Vector3.ONE)
	pass

func generate():
	
	var island = get_parent()
	
	var x = island.global_position.x + island.Size / 2
	var y = island.global_position.z + island.Size / 2
	
	var angle = randf_range(0, PI * 2)
	var dx = cos(angle) * STEP_SIZE
	var dy = sin(angle) * STEP_SIZE
	
	while island.get_height(x, y) > -MAX_DEPTH:
		create_dock(x, y, angle)
		x += dx
		y += dy
	
	pass
