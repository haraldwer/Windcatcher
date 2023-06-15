shader_type spatial;
render_mode shadows_disabled, depth_draw_never;

uniform vec3 color : source_color;
uniform vec3 foam_color : source_color;
uniform float foam_range;
uniform float wave_speed;
uniform float noise_scale;

uniform sampler2D depth_tex : hint_depth_texture, filter_linear_mipmap;

varying mat4 CAMERA;

vec2 random(vec2 uv){
    uv = vec2( dot(uv, vec2(127.1,311.7) ),
               dot(uv, vec2(269.5,183.3) ) );
    return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

float noise(vec2 uv) {
    vec2 uv_index = floor(uv);
    vec2 uv_fract = fract(uv);
    vec2 blur = smoothstep(0.0, 1.0, uv_fract);
    return mix( mix( dot( random(uv_index + vec2(0.0,0.0) ), uv_fract - vec2(0.0,0.0) ),
                     dot( random(uv_index + vec2(1.0,0.0) ), uv_fract - vec2(1.0,0.0) ), blur.x),
                mix( dot( random(uv_index + vec2(0.0,1.0) ), uv_fract - vec2(0.0,1.0) ),
                     dot( random(uv_index + vec2(1.0,1.0) ), uv_fract - vec2(1.0,1.0) ), blur.x), blur.y) + 0.5;
}


void vertex() {
	CAMERA = VIEW_MATRIX;
}

void fragment() {
	
	float depth = texture(depth_tex, SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV, depth) * 2.0 - 1.0;
	vec4 world = CAMERA * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	vec3 world_position = world.xyz / world.w;
	
	vec3 pixel_ndc = vec3(SCREEN_UV, FRAGCOORD.z) * 2.0 - 1.0;
	vec4 pixel_world = CAMERA * INV_PROJECTION_MATRIX * vec4(pixel_ndc, 1.0);
	vec3 pixel_position = pixel_world.xyz / pixel_world.w;
	
	float dist = distance(world_position, pixel_position) / foam_range;
	float foam_depth = 1.0f - clamp(dist, 0.0f, 1.0f);
	
	
	float wave = TIME * wave_speed; 
	float foam_dist = foam_depth - wave;
	float foam_dist_mod = abs(mod(foam_dist, 1.0f) - 0.5f);	
	float foam_dist_fix = foam_dist_mod * foam_depth; 
	float foam_noise = foam_dist_fix * noise(UV * noise_scale);
	float foam = step(0.2, foam_noise) * (1.0f - step(0.8, foam_noise));
	
	ALBEDO = mix(color, foam_color, foam); 
} 

