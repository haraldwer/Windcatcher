extends MeshInstance3D

func get_vertex(x, y, dx, dy) -> Vector3:
	# Find coord for specific point
	var nx = x + dx
	var ny = y + dy
	# World uv
	var island = get_parent()
	var face_size = island.SIZE / island.SUBDIVISIONS
	var offset = Vector3(nx, 0.0, ny) * face_size
	var uv = offset + island.global_position
	var height = island.get_height(uv.x, uv.z)
	return offset + Vector3.UP * height

func generate():
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var island = get_parent()
	for x in island.SUBDIVISIONS:
		for y in island.SUBDIVISIONS:
			# Two triangles, four corners
			st.add_vertex(get_vertex(x, y, 0, 0))
			st.add_vertex(get_vertex(x, y, 1, 0))
			st.add_vertex(get_vertex(x, y, 0, 1))
			st.add_vertex(get_vertex(x, y, 1, 1))
			st.add_vertex(get_vertex(x, y, 0, 1))
			st.add_vertex(get_vertex(x, y, 1, 0))
	
	st.generate_normals()
	st.generate_tangents()
	
	mesh = st.commit()
	
	var collider := get_node("CollisionBody/CollisionShape")
	collider.shape = mesh.create_trimesh_shape()
	
	pass
