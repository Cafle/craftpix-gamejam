shader_type canvas_item;

uniform vec3 key_color1 : source_color = vec3(1.0, 0.0, 0.0);
uniform vec3 new_color1 : source_color = vec3(0.0, 1.0, 0.0);
uniform vec3 key_color2 : source_color = vec3(1.0, 0.0, 0.0);
uniform vec3 new_color2 : source_color = vec3(0.0, 1.0, 0.0);
uniform float tolerance : hint_range(0.0, 0.5) = 0.1;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    if (distance(tex.rgb, key_color1) < tolerance) {
        tex.rgb = new_color1;
    }
	if (distance(tex.rgb, key_color2) < tolerance) {
        tex.rgb = new_color2;
    }
    COLOR = tex;
}