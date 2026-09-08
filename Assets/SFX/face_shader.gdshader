shader_type canvas_item;

uniform vec3 skin : source_color = vec3(0.9, 0.72, 0.56);
uniform float tolerance : hint_range(0.0, 0.3) = 0.08;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	if      (distance(tex.rgb, vec3(1.0, 0.0, 0.0)) < tolerance) tex.rgb = skin;
	else if (distance(tex.rgb, vec3(0.6, 0.0, 0.0)) < tolerance) tex.rgb = skin;
	else if (distance(tex.rgb, vec3(1.0, 0.0, 0.196)) < tolerance) tex.rgb = skin;
	else if (distance(tex.rgb, vec3(0.698, 0.063, 0.188)) < tolerance) tex.rgb = skin;
	COLOR = tex;
}