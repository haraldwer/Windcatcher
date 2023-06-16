extends Node3D

func _ready():
	$Volume.material_override.set_shader_parameter('box_bounds', scale)
	pass 
