class_name WorldGen
extends Node3D

@export var Characters : Array
@export var IslandType : PackedScene
@export var WindType : PackedScene
var SpawnedIslands : Array[Node3D]

const WORLD_SIZE = 300.0
const ISLAND_DIST = 60.0
const WIND_MIN_HEIGHT = 20.0
const WIND_MAX_HEIGHT = 35.0
const WIND_RAD = 20.0

func check_location(loc : Vector3) -> bool:
	for island in SpawnedIslands:
		var dist = loc.distance_squared_to(island.global_position)
		if dist < ISLAND_DIST * ISLAND_DIST:
			return false
	return true

func find_location() -> Vector3:
	for i in 100:
		var loc = Vector3(
			randf_range(0.0, WORLD_SIZE) - WORLD_SIZE * 0.5, 0.0,
			randf_range(0.0, WORLD_SIZE) - WORLD_SIZE * 0.5)
		if check_location(loc):
			return loc
	return Vector3.ZERO

func spawn_islands():
	for char in Characters.size():
		var instance = IslandType.instantiate()
		add_child(instance)
		instance.global_position = find_location()
		SpawnedIslands.append(instance)
		instance.generate()
	pass

func spawn_wind():
	
	# Every island has a couple of connections
	
	for island in SpawnedIslands:
		var target
		while !target or target == island:
			target = SpawnedIslands.pick_random()
		print("Spawning wind")
		var instance = WindType.instantiate()
		add_child(instance)
		var target_pos = target.global_position + Vector3(target.Size, 0.0, target.Size) * 0.5
		var island_pos = island.global_position + Vector3(island.Size, 0.0, island.Size) * 0.5
		instance.global_position = (island_pos + target_pos) * 0.5
		instance.look_at(target_pos)
		instance.global_rotation.x += PI * 0.5
		instance.global_position.y += randf_range(WIND_MIN_HEIGHT, WIND_MAX_HEIGHT)
		instance.scale = Vector3(WIND_RAD, target_pos.distance_to(island_pos) * 0.2, WIND_RAD)
	pass

func _ready():
	spawn_islands()
	spawn_wind()
	pass
