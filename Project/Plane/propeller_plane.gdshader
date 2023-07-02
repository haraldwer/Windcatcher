shader_type spatial;
render_mode unshaded, cull_disabled;

uniform float RotSpeed = 2.0f; 
uniform float Alpha = 1.0f; 
uniform float Step = 0.3f;
uniform float Albedo = 1.0f; 

void fragment() {
	
	ALBEDO = vec3(Albedo);
	
	vec2 uv = (UV - 0.5f) * 2.0f; 
	float dist = distance(uv, vec2(0.0f));
	
	float tot_rot = 1.0f; 
	vec2 normalized = uv / dist;
	for (int i = 0; i < 4; i++)
	{
		float rot_time = TIME * RotSpeed + (PI * 2.0f * float(i) / 4.0f);
		float x = distance(normalized.x, cos(rot_time));
		float y = distance(normalized.y, sin(rot_time)); 
		float rot = clamp(max(x, y) * 5.0f, 0.0f, 1.0f);
		tot_rot = min(rot, tot_rot); 
	}
	
	float line = 1.0f - clamp(distance(dist * dist * dist * 1.5f, 0.5f), 0.0f, 1.0f);
	float middle = pow(1.0f - dist, 3.0f) * 2.0f;
	float opacity = clamp(max(line, middle), 0.0f, 1.0f);
	float rot_op = max(opacity * tot_rot, middle);
	
	ALPHA = step(Step, rot_op) * Alpha * Alpha; 
}
