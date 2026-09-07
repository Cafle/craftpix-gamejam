shader_type canvas_item;

const int MAX_COLORS = 8;

uniform vec3 key_colors[MAX_COLORS] : source_color;
uniform vec3 new_colors[MAX_COLORS] : source_color;
uniform int active_count = 0;
uniform float tolerance : hint_range(0.0, 0.5) = 0.05;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    for (int i = 0; i < active_count; i++) {
        if (distance(tex.rgb, key_colors[i]) < tolerance) {
            tex.rgb = new_colors[i];
            break;
        }
    }
    COLOR = tex;
}