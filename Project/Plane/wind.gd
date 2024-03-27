class_name Wind
extends Node

var area_count = 0
var wind_dir = Vector3.ZERO

func get_wind() -> Vector3:
	return wind_dir

func on_enter(area):
	print("Enter wind volume")
	area_count += 1
	wind_dir = (area.global_transform.basis.y).normalized()
	pass
	
func on_exit(area):
	print("Exit wind volume")
	area_count -= 1
	if area_count == 0:
		wind_dir = Vector3.ZERO
	if area_count < 0:
		printerr("Wind volume count error")
	pass
