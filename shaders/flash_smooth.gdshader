shader_type canvas_item;

uniform float value: hint_range(0.0, 1.0) = 0;
uniform vec3 color: source_color = vec3(1, 1, 1);

void fragment()
{
	vec4 tex = texture(TEXTURE, UV);
	COLOR = vec4(
		mix(tex.r, color.r, value), 
		mix(tex.g, color.g, value), 
		mix(tex.b, color.b, value), 
		tex.a
	);
}
