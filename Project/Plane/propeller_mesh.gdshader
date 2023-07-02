shader_type spatial;
render_mode unshaded;

uniform float Alpha = 1.0f;
uniform vec3 Color : source_color = vec3(0.9f); 

void fragment() {
	ALBEDO = Color; 
	EMISSION = Color * 0.3f;
	ALPHA = Alpha * Alpha;
}
