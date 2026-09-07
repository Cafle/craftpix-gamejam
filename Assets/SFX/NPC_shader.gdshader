shader_type canvas_item;

uniform vec3 skin : source_color = vec3(0.9, 0.72, 0.56);
uniform vec3 dark_skin : source_color = vec3(0.88, 0.7, 0.54);
uniform vec3 shirt : source_color = vec3(0.2, 0.4, 0.7);
uniform vec3 shirt_light : source_color = vec3(0.3, 0.5, 0.8);
uniform vec3 shirt_dark : source_color = vec3(0.1, 0.3, 0.6);
uniform vec3 leg : source_color = vec3(0.88, 0.7, 0.54);
uniform vec3 leg_dark : source_color = vec3(0.8, 0.62, 0.46);
uniform vec3 ruffle1 : source_color = vec3(0.8, 0.62, 0.46);
uniform vec3 ruffle2 : source_color = vec3(0.8, 0.62, 0.46);
uniform vec3 ruffle_dark : source_color = vec3(0.8, 0.62, 0.46);
uniform vec3 hair : source_color = vec3(0.35, 0.18, 0.08);

uniform float tolerance : hint_range(0.0, 0.3) = 0.08;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    if      (distance(tex.rgb, vec3(1.0, 0.0, 1.0)) < tolerance) tex.rgb = hair;
    else if (distance(tex.rgb, vec3(0.0, 1.0, 0.0)) < tolerance) tex.rgb = shirt_light;
    else if (distance(tex.rgb, vec3(1.0, 0.0, 0.0)) < tolerance) tex.rgb = skin;
	else if (distance(tex.rgb, vec3(0.6, 0.0, 0.0)) < tolerance) tex.rgb = skin;
    else if (distance(tex.rgb, vec3(0.0, 0.0, 1.0)) < tolerance) tex.rgb = shirt;
    else if (distance(tex.rgb, vec3(1.0, 1.0, 0.0)) < tolerance) tex.rgb = shirt_dark;
	else if (distance(tex.rgb, vec3(0.0, 0.0, 0.36)) < tolerance) tex.rgb = ruffle1;
	else if (distance(tex.rgb, vec3(0.0, 0.0, 0.57)) < tolerance) tex.rgb = ruffle2;
	else if (distance(tex.rgb, vec3(0.0, 0.0, 0.0)) < tolerance) tex.rgb = ruffle_dark;
    else if (distance(tex.rgb, vec3(0.0, 0.10, 1.0)) < tolerance) tex.rgb = leg;
    else if (distance(tex.rgb, vec3(0.0, 0.07, 0.7)) < tolerance) tex.rgb = leg_dark;

    COLOR = tex;
}