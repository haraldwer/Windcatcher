extends Camera3D

# Const
const INTERP_SPEED = 5.0
const LOOK_INTERP_SPEED = 5.0

var offset = Transform3D.IDENTITY
var look = Transform3D.IDENTITY
var body

func _ready():
	body = get_parent().get_node("CharacterBody")
	offset = transform
	pass

func _physics_process(delta):
	if body:
		# Imagine local offset
		# Translate through body
		# This is target
		var target = body.global_transform * offset
		global_transform = global_transform.interpolate_with(target, delta * INTERP_SPEED)
		
		var looktarget = body.global_transform * Transform3D(Basis.IDENTITY, Vector3.FORWARD * 100.0)
		look = look.interpolate_with(looktarget, delta * LOOK_INTERP_SPEED)
		look_at(look.origin)
		
	pass
