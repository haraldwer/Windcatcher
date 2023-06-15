extends Node

func _ready():
	
	var cr = $Simulation/ColorRect
	var water = $Plane
	var sim_tex = $Simulation.get_texture()
	var col_tex = $Collision.get_texture()
	cr.material.set_shader_parameter('sim_tex', sim_tex)
	cr.material.set_shader_parameter('col_tex', col_tex)
	water.mesh.surface_get_material(0).set_shader_parameter('simulation', sim_tex)
	water.mesh.surface_get_material(0).set_shader_parameter('simulation2', sim_tex)
	
	pass
