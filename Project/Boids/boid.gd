class_name Boid
extends Object

@export var SeparationWeight = 1
func separation(flock : Array) -> Vector3:
	return Vector3.ZERO * SeparationWeight

@export var CohesionWeight = 1
func cohesion(flock : Array) -> Vector3:
	return Vector3.ZERO * CohesionWeight

@export var AllignmentWeight = 1
func allignment(flock : Array) -> Vector3:
	return Vector3.ZERO * AllignmentWeight

@export var AvoidanceWeight = 1
func avoidance(flock : Array) -> Vector3:
	return Vector3.ZERO * AvoidanceWeight
