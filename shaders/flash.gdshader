shader_type canvas_item;

uniform bool active = false;
uniform vec3 color: source_color = vec3(1, 1, 1);

void fragment()
{
	if (active) COLOR = vec4(color, texture(TEXTURE, UV).a);
}
