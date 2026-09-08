shader_type canvas_item;

uniform float bulge : hint_range(0.0, 1.0) = 0.4;
uniform float radius : hint_range(0.0, 0.5) = 0.5;

void fragment() {
    vec2 centered = UV - vec2(0.5);
    float dist = length(centered);

    // pull samples inward toward the center, more so near the edge
    float warp = 1.0 - bulge * (1.0 - dist * 2.3);
    vec2 warped_uv = centered * warp + vec2(0.5);

    vec4 tex = texture(TEXTURE, warped_uv);
    tex.a *= step(dist, radius);
    COLOR = tex;
}
