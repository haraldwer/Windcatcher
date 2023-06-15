extends Node

var plane
var movement
var mouse_movement = Vector2.ZERO

func _ready():
	plane = get_parent()
	movement = plane.get_node("CharacterBody")
	pass

func _input(event):
	if event is InputEventMouseMotion:
		mouse_movement = event.relative
	pass

func _process(delta):
	var input = Vector2.ZERO
	input += Vector2.RIGHT * Input.get_axis("right", "left")
	input += Vector2.UP * Input.get_axis("up", "down")
	movement._set_input(input, -mouse_movement)
	mouse_movement = Vector2.ZERO
	pass


