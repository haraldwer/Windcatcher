shader_type spatial;
render_mode unshaded, shadows_disabled, depth_test_disabled;

uniform sampler2D depth_texture : source_color, hint_depth_texture;
varying mat4 CAMERA;

void vertex() {
  POSITION = vec4(VERTEX, 1.0);
  CAMERA = INV_VIEW_MATRIX;
}

void fragment() {
	
	float depth = texture(depth_texture, SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z;
	
	vec4 world = CAMERA * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	vec3 world_position = world.xyz / world.w;
	
	ALBEDO = vec3(linear_depth / 300.0f);
}
