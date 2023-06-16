shader_type spatial;
render_mode unshaded, shadows_disabled, depth_test_disabled;

uniform sampler2D depth_tex : hint_depth_texture, filter_linear_mipmap;
uniform vec3 color : source_color;
uniform vec3 box_bounds = vec3(0.5f);
uniform float edge_fade = 0.2f;
uniform float noise_scale = 0.2f;
uniform float flat_noise_scale = 0.5f;
uniform float flat_shape_fade = 0.5f;
uniform float density_mul = 3.0f;
uniform float density_max = 1.0f;
uniform int min_iter = 8;
uniform int max_iter = 32;
uniform float iter_dist = 100.0f;
uniform float iter_pow = 0.3f; 

vec4 permute(vec4 x){return mod(((x*34.0)+1.0)*x, 289.0);}
vec4 taylorInvSqrt(vec4 r){return 1.79284291400159 - 0.85373472095314 * r;}
vec3 fade(vec3 t) {return t*t*t*(t*(t*6.0-15.0)+10.0);}

float perlin3D(vec3 P){
  vec3 Pi0 = floor(P); // Integer part for indexing
  vec3 Pi1 = Pi0 + vec3(1.0); // Integer part + 1
  Pi0 = mod(Pi0, 289.0);
  Pi1 = mod(Pi1, 289.0);
  vec3 Pf0 = fract(P); // Fractional part for interpolation
  vec3 Pf1 = Pf0 - vec3(1.0); // Fractional part - 1.0
  vec4 ix = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
  vec4 iy = vec4(Pi0.yy, Pi1.yy);
  vec4 iz0 = Pi0.zzzz;
  vec4 iz1 = Pi1.zzzz;

  vec4 ixy = permute(permute(ix) + iy);
  vec4 ixy0 = permute(ixy + iz0);
  vec4 ixy1 = permute(ixy + iz1);

  vec4 gx0 = ixy0 / 7.0;
  vec4 gy0 = fract(floor(gx0) / 7.0) - 0.5;
  gx0 = fract(gx0);
  vec4 gz0 = vec4(0.5) - abs(gx0) - abs(gy0);
  vec4 sz0 = step(gz0, vec4(0.0));
  gx0 -= sz0 * (step(0.0, gx0) - 0.5);
  gy0 -= sz0 * (step(0.0, gy0) - 0.5);

  vec4 gx1 = ixy1 / 7.0;
  vec4 gy1 = fract(floor(gx1) / 7.0) - 0.5;
  gx1 = fract(gx1);
  vec4 gz1 = vec4(0.5) - abs(gx1) - abs(gy1);
  vec4 sz1 = step(gz1, vec4(0.0));
  gx1 -= sz1 * (step(0.0, gx1) - 0.5);
  gy1 -= sz1 * (step(0.0, gy1) - 0.5);

  vec3 g000 = vec3(gx0.x,gy0.x,gz0.x);
  vec3 g100 = vec3(gx0.y,gy0.y,gz0.y);
  vec3 g010 = vec3(gx0.z,gy0.z,gz0.z);
  vec3 g110 = vec3(gx0.w,gy0.w,gz0.w);
  vec3 g001 = vec3(gx1.x,gy1.x,gz1.x);
  vec3 g101 = vec3(gx1.y,gy1.y,gz1.y);
  vec3 g011 = vec3(gx1.z,gy1.z,gz1.z);
  vec3 g111 = vec3(gx1.w,gy1.w,gz1.w);

  vec4 norm0 = taylorInvSqrt(vec4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
  g000 *= norm0.x;
  g010 *= norm0.y;
  g100 *= norm0.z;
  g110 *= norm0.w;
  vec4 norm1 = taylorInvSqrt(vec4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
  g001 *= norm1.x;
  g011 *= norm1.y;
  g101 *= norm1.z;
  g111 *= norm1.w;

  float n000 = dot(g000, Pf0);
  float n100 = dot(g100, vec3(Pf1.x, Pf0.yz));
  float n010 = dot(g010, vec3(Pf0.x, Pf1.y, Pf0.z));
  float n110 = dot(g110, vec3(Pf1.xy, Pf0.z));
  float n001 = dot(g001, vec3(Pf0.xy, Pf1.z));
  float n101 = dot(g101, vec3(Pf1.x, Pf0.y, Pf1.z));
  float n011 = dot(g011, vec3(Pf0.x, Pf1.yz));
  float n111 = dot(g111, Pf1);

  vec3 fade_xyz = fade(Pf0);
  vec4 n_z = mix(vec4(n000, n100, n010, n110), vec4(n001, n101, n011, n111), fade_xyz.z);
  vec2 n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y);
  float n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x); 
  return 2.2 * n_xyz;
}

vec2 random(vec2 uv){
    uv = vec2( dot(uv, vec2(127.1,311.7) ),
               dot(uv, vec2(269.5,183.3) ) );
    return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

float perlin2D(vec2 uv) {
    vec2 uv_index = floor(uv);
    vec2 uv_fract = fract(uv);

    vec2 blur = smoothstep(0.0, 1.0, uv_fract);

    return mix( mix( dot( random(uv_index + vec2(0.0,0.0) ), uv_fract - vec2(0.0,0.0) ),
                     dot( random(uv_index + vec2(1.0,0.0) ), uv_fract - vec2(1.0,0.0) ), blur.x),
                mix( dot( random(uv_index + vec2(0.0,1.0) ), uv_fract - vec2(0.0,1.0) ),
                     dot( random(uv_index + vec2(1.0,1.0) ), uv_fract - vec2(1.0,1.0) ), blur.x), blur.y) + 0.5;
}


vec2 rand2(vec2 coord) {
	return fract(sin(vec2(dot(coord, vec2(127.1, 311.7)), dot(coord, vec2(269.5, 183.3)))) * 43758.5453);
}

float voronoi(vec2 coord) {
	vec2 i = floor(coord);
	vec2 f = fract(coord);
	float min_dist = 999999.0;
	for (float x = -1.0; x <= 1.0; ++x) {
		for (float y = -1.0; y <= 1.0; ++y) {
			vec2 node = rand2(i + vec2(x, y)) + vec2(x, y);
			float dist = sqrt(pow((f - node).x, 2) + pow((f - node).y, 2));
			min_dist = min(min_dist, dist);
		}
	}
	return min_dist;
}

float volume_bounds(vec3 relative)
{
	return max(abs(relative.y),
		sqrt(relative.x * relative.x + relative.z * relative.z));
	//return max(max(abs(relative.x),abs(relative.y)),abs(relative.z));
}

float density(vec3 pos, vec3 node_pos)
{
	vec3 relative = (pos - node_pos) / (box_bounds * 0.5f);
	float bounds = volume_bounds(relative);
	
	float edge = (bounds - (1.0f - edge_fade)) / edge_fade;
	float fade = clamp(1.0f - edge, 0.0f, 1.0f);
	if (fade < 0.001f)
		return 0.0f; 
	
	float noise = perlin3D(pos * noise_scale);
	
	float flat_noise = perlin2D(vec2(pos.x, pos.z) * flat_noise_scale);
	float flat_shape = clamp((flat_noise * flat_noise - edge) * flat_shape_fade, 0.0f, 1.0f);
	
	float top_y = (relative.y + 0.2f) * 0.8f + bounds * bounds;
	float top_y_weight = 1.0f - clamp(top_y, 0.0f, 1.0f);
	float bottom_y_weight = 1.0f - clamp((-relative.y - 0.5f) * 2.0f, 0.0f, 1.0f);
	float y_weight = min(top_y_weight, bottom_y_weight);
	
	float density = clamp(noise + y_weight, 0.0f, 1.0f) * flat_shape;
	return density * density_mul; //step(0.1f, density) * density_mul;
}

void fragment() {
	
	vec3 world_vert = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0f)).xyz;
	
	float depth = texture(depth_tex, SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float scene_dist = -view.z;
	
	float node_vert_dist = distance(NODE_POSITION_WORLD, world_vert); 
	vec3 ray_dir = normalize(world_vert - CAMERA_POSITION_WORLD); 
	vec3 ray_start = world_vert - ray_dir * node_vert_dist * 2.0f;
	float ray_length = distance(ray_start, world_vert);
	float ray_camera_dist = distance(ray_start, CAMERA_POSITION_WORLD);
	
	float vert_dist = max(abs(VERTEX.z) - ray_length, 0.0f);
	float iter_alpha = pow(clamp(vert_dist / iter_dist, 1.0f, 0.0f), iter_pow);
	int iterations = int(mix(float(max_iter), float(min_iter), iter_alpha));
	
	float weight = 1.0f / float(iterations);
	float step_length = ray_length * weight; 
	float total_density = 0.0f; 
	for (int i = 0; i < iterations; i++)
	{
		// Check scene depth
		float ray_depth = (step_length * float(i));
		//if (ray_camera_dist + ray_depth > scene_dist)
		//	break; 
			
		vec3 pos = ray_start + ray_dir * ray_depth;
		float density = density(pos, NODE_POSITION_WORLD); 
		total_density += density * weight;
	}

	ALBEDO = color; 
	ALPHA = step(0.1 ,total_density); // clamp(total_density, 0.0f, density_max);	
	//ALBEDO = vec3(density(world_vert, NODE_POSITION_WORLD));
	//ALBEDO = vec3(volume_bounds(world_vert, NODE_POSITION_WORLD));
	//ALBEDO = vec3(scene_depth / 5.0f); 
	//ALPHA = 0.9f; 
}
