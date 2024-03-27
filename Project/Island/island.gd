class_name Island
extends Node3D

const MIN_SIZE = 100
const MAX_SIZE = 100
const PRECISION = 0.5
const NOISE_SCALE = 1
const HEIGHT_BASE = 15
const HEIGHT_SCALE = 10
const CENTER_HEIGHT_SCALE = 35
@export var height_noise:Noise
@export var center_curve:Curve

var Size;

func get_height(wx, wy) -> float:
	# Sample noise
	var height = height_noise.get_noise_2d(wx * NOISE_SCALE, wy * NOISE_SCALE) * HEIGHT_SCALE
	
	# Apply center curve
	var center_x = (wx - global_position.x - Size * 0.5) / Size
	var center_y = (wy - global_position.z - Size * 0.5) / Size
	var center_dist = Vector2(center_x, center_y).length() * 2.0
	
	var center_val = center_curve.sample(center_dist)
	var center_height = center_val * CENTER_HEIGHT_SCALE
	var adjusted_height = center_height + height * center_val - HEIGHT_BASE
	return adjusted_height
	
func generate():
	Size = randf_range(MIN_SIZE, MAX_SIZE)
	print("Size ", Size)
	get_node('Terrain').generate()
	get_node('Structures').generate()
	get_node('Vegetation').generate()
	pass
