shader_type spatial;
render_mode unshaded, shadows_disabled, depth_test_disabled, depth_draw_never, cull_disabled;

uniform sampler2D depth_texture : source_color, hint_depth_texture;
uniform sampler2D screen_texture : source_color, hint_screen_texture;

uniform float weight = 0.5f; 
uniform int extent = 5; 
uniform float diff_step = 0.1f; 
uniform float depth_thres = 1.0f;
uniform float dist_thres = 1.0f;
uniform float max_dist = 100.0f; 
uniform float fade_dist = 50.0f; 
uniform float height_offset = 10.0f; 
uniform float height_mul = 1.0f; 

varying mat4 CAMERA;

void vertex() {
  POSITION = vec4(VERTEX, 1.0);
  CAMERA = INV_VIEW_MATRIX;
}

vec4 get_data(sampler2D tex, vec2 uv, mat4 inv_proj, mat4 cam) {
	float depth = texture(tex, uv).x;
	vec3 ndc = vec3(uv * 2.0 - 1.0, depth);
	vec4 view = inv_proj * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z;
	
	vec4 world = cam * inv_proj * vec4(ndc, 1.0);
	vec3 world_position = world.xyz / world.w;
	return vec4(world_position, linear_depth);
}

float manhattan(vec3 first, vec3 second) {
	vec3 d = first - second;
	return max(max(abs(d.x), abs(d.y)), abs(d.z));
}

void fragment() {
	
	vec4 base = get_data(depth_texture, SCREEN_UV, INV_PROJECTION_MATRIX, CAMERA);
	vec2 coord = FRAGCOORD.xy;
	vec2 texel = vec2(1.0f) / VIEWPORT_SIZE;
	
	const vec2 offsets[8] = {
		vec2(1, 0),
		vec2(1,0),
		vec2(0, 1),
		vec2(0,-1),
			
		vec2(1, 1) * 0.65f,
		vec2(-1,1) * 0.65f,
		vec2(1,-1) * 0.65f,
		vec2(-1,-1) * 0.65f
	};
	
	float total_diff = 0.0f; 
	float total_c = 0.0f;
	for (int j = 0; j < extent; j++)
	{
		for (int i = 0; i < 8; i++)
		{
			vec2 offset = offsets[i] * (float(j) + 1.0f);
			vec4 data = get_data(depth_texture, (coord + offset) * texel, INV_PROJECTION_MATRIX, CAMERA); 
			float extent_mul =  1.0f - (float(j) / float(extent));
			float height_fade = clamp((data.y - height_offset) * height_mul, 0.0f, 1.0f); 
			float val = extent_mul * height_fade; 
			
			float depth_diff = abs(base.w - data.w) / base.w;
			if (depth_diff > depth_thres)
				total_diff += val * (1.0f - weight); 
			
			float dist = manhattan(base.xyz, data.xyz) / base.w;
			if (dist > dist_thres)
				total_diff += val * weight;
			
			total_c += val; 
		}
	}
	
	if (total_c < 0.01f)
		discard;
		
	total_diff /= total_c;
	
	// Fade
	float cam_dist = distance(base.xyz, CAMERA_POSITION_WORLD);
	float cam_fade = clamp(1.0f - (cam_dist - 100.0f) / fade_dist, 0.0f, 1.0f);
	//total_diff *= cam_fade;
	
	ALBEDO = vec3(0.0f);// texture(screen_texture, SCREEN_UV).rgb;
	ALPHA = step(diff_step, total_diff);
}
