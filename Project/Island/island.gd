extends Node3D

const SIZE = 100
const SUBDIVISIONS = 20
const NOISE_SCALE = 1
const HEIGHT_BASE = 15
const HEIGHT_SCALE = 10
const CENTER_HEIGHT_SCALE = 35
@export var height_noise:Noise
@export var center_curve:Curve

func _ready():
	generate()
	pass

func get_height(wx, wy) -> float:
	# Sample noise
	var height = height_noise.get_noise_2d(wx * NOISE_SCALE, wy * NOISE_SCALE) * HEIGHT_SCALE
	# Apply center curve
	var center_x = (wx - global_position.x) / SIZE - 0.5
	var center_y = (wy - global_position.z) / SIZE - 0.5
	
	var center_dist = Vector2(center_x, center_y).length()
	var center_val = center_curve.sample(center_dist * 2)
	var center_height = center_val * CENTER_HEIGHT_SCALE
	var adjusted_height = center_height + height * center_val - HEIGHT_BASE
	return adjusted_height
	
func generate():
	get_node('Terrain').generate()
	get_node('Structures').generate()
	get_node('Vegetation').generate()
	pass

func _process(delta):
	pass
