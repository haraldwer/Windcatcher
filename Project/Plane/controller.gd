class_name Controller
extends Node

var plane
var movement
var mouse_movement = Vector2.ZERO
var enabled = true

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	plane = get_parent()
	movement = plane.get_node("CharacterBody")
	pass

func _input(event):
	if event is InputEventMouseMotion:
		mouse_movement = event.relative
	pass

func _process(delta):
	if enabled: 
		var input = Vector2.ZERO
		input += Vector2.RIGHT * Input.get_axis("right", "left")
		input += Vector2.UP * Input.get_axis("up", "down")
		movement._set_input(input, -mouse_movement)
		mouse_movement = Vector2.ZERO
	else:
		movement._set_input(Vector2(0.0, -1.0), Vector2.ZERO)
	pass
