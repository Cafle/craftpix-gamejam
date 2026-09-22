shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture, filter_nearest;
uniform float offset : hint_range(0.0, 0.1) = 0.02;
uniform float coffset : hint_range(0.0, 0.1) = 0.02;
uniform float strength : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 a = texture(screen_tex, SCREEN_UV);
    vec4 b = texture(screen_tex, SCREEN_UV + vec2(offset, coffset));
    COLOR = mix(a, b, strength * 0.5);
}