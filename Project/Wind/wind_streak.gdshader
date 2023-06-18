shader_type spatial;
render_mode cull_disabled, unshaded, depth_draw_never;

uniform sampler2D depth_texture : source_color, hint_depth_texture;

uniform vec4 Color : source_color = vec4(1.0f);
uniform float Alpha = 0.7f; 

uniform float EdgeSize = 0.5f;
uniform float StreakLength = 1.5f;
uniform float StreakSpeed = 0.2f;
uniform float StreakSize = 0.1f;

uniform vec3 NoiseScale = vec3(1.0f); 
uniform float NoiseMul = 0.2f;
uniform float PointMul = 0.5f; 

uniform float SlowNoiseScale = 0.01f; 

uniform float DepthFade = 20.0f; 
uniform float CamFade = 2.0f; 
uniform float CamOffset = 1.0f; 

varying mat4 CAMERA;

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

float rand_off(vec3 world, float time)
{
	 return (world.x + world.y + world.z) * 10.0f + time * SlowNoiseScale;
}

void vertex() {
	
	float pos_offset = rand_off(NODE_POSITION_WORLD, TIME); 

	float p_x = perlin3D(NODE_POSITION_WORLD + pos_offset);
	float p_y = perlin3D(NODE_POSITION_WORLD + pos_offset * 2.0f);
	vec3 point = vec3(p_x, 0.0f, p_y) * PointMul; 
	
	float x = perlin3D(VERTEX * NoiseScale + pos_offset);
	float y = perlin3D(VERTEX * NoiseScale + pos_offset * 2.0f);
	vec3 noise = vec3(x, 0.0f, y) * NoiseMul;
	
	VERTEX += point + noise;
	
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

void fragment() {

	float top_edge = smoothstep(1.0, 1.0 - EdgeSize, UV.y);
	float bottom_edge = smoothstep(0.0f, EdgeSize, UV.y);
	float edge_mul = min(top_edge, bottom_edge);
	
	float pos_offset = rand_off(NODE_POSITION_WORLD, TIME); 
	
	float streak_y = min(fract(UV.y + TIME * StreakSpeed + pos_offset) * StreakLength, 1.0f);
	float top = smoothstep(1.0, 1.0 - StreakSize * StreakLength, streak_y);
	float bottom = smoothstep(0.0f, StreakSize * StreakLength, streak_y);
	float streak_mul = min(top, bottom);
	
	float streak = edge_mul * streak_mul;
	
	vec4 data = get_data(depth_texture, SCREEN_UV, INV_PROJECTION_MATRIX, CAMERA);
	float view_depth = (vec4(VERTEX.xyz, 1.0f) * PROJECTION_MATRIX).z;
	float cam_mul = clamp((view_depth - CamOffset) / CamFade, 0.0f, 1.0f);
	float depth_diff = (data.w - view_depth);
	float depth_mul = clamp(depth_diff / DepthFade, 0.0f, 1.0f);
	float fade = min(cam_mul, depth_mul);
	
	float x = UV.x; 
	float dist = 1.0f - abs((x - 0.5f) * 2.0f);
	float edge_fade = clamp((dist * 3.0f - 1.0f) * streak, 0.0f, 1.0f);
	float edge = step(1.0f, edge_fade);
	
	ALPHA = edge * fade * Alpha;
	ALBEDO = vec3(1.0f); 
	
}
