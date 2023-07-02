extends Node3D

const MAX_SPEED = 50.0
const MIN_SPEED = 5.0
const FADE_START = 0.2

var movement
@onready var mesh := $PropellerMesh
@onready var plane := $PropellerPlane

func _ready():
	movement = get_parent().get_parent()
	pass

func _process(delta):
	
	if !movement or !mesh or !plane:
		return
		
	var part = movement.speed / movement.MAX_SPEED
	var lerp =  MIN_SPEED + (MAX_SPEED - MIN_SPEED) * part
	mesh.rotation.x += lerp * delta
	
	var fade = max(0.0, (part - FADE_START) / (1.0 - FADE_START))
	mesh.material_override.set_shader_parameter('Alpha', 1.0 - fade)
	plane.get_active_material(0).set_shader_parameter('Alpha', fade);
	
	pass
