shader_type canvas_item;

uniform sampler2D sim_tex;
uniform sampler2D col_tex;

uniform float phase = 0.2f;
uniform float attenuation = 0.999f;
uniform float deltaUV = 3.0f;
uniform float precision = 10000.0f;
uniform float resolution = 2048.0;

void fragment() {
	float dv = 1.0f / resolution;
	float du = 1.0f / resolution;
	vec3 duv = vec3(du, dv, 0.0f) * deltaUV;
	
	vec3 c = texture(sim_tex, UV).rgb;
	
	float p = (2.0f * c.r - c.g + phase * (
		texture(sim_tex, UV - duv.zy).r +
		texture(sim_tex, UV + duv.zy).r +
		texture(sim_tex, UV - duv.xz).r +
		texture(sim_tex, UV + duv.xz).r - 4.0f * c.r)) * attenuation;
		
	vec2 col_uv = vec2(UV.x, 1.0f - UV.y);
	float col = texture(col_tex, col_uv).r;
	float prevCol = texture(sim_tex, UV).b;
	
	if (col > 0.0f && abs(prevCol) < 1.0f / precision) {
		p += col * 0.5f;
	}
	
	if (prevCol > 0.0f && abs(col) < 1.0f / precision) {
		p -= prevCol * 0.5f;
	}
		
	COLOR = vec4(p, c.r, col, 1);
}