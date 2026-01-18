shader_type canvas_item;

uniform bool flash_active = false;
uniform bool strip_active = false;

uniform vec3 flash_color : source_color = vec3(1);
uniform vec4 strip_color : source_color = vec4(1);

uniform float spacing = 6.0;
uniform float speed = -20.0;

void fragment()
{
	vec4 tex = texture(TEXTURE, UV);

	if (flash_active) COLOR = vec4(flash_color, tex.a);
	else if (strip_active)
	{
		vec2 textureSize = vec2(textureSize(TEXTURE, 0));
		
		float pixel_x = floor(UV.x * textureSize.x);
		float pixel_y = floor(UV.y * textureSize.y);
		
		float anim = mod(pixel_y + mod(pixel_x, 2) + TIME * speed, spacing);
		
		float mask = step(anim, 1.0);
		
		if (mask == 1.0) COLOR = mix(tex, strip_color, strip_color.a) * tex.a;
	}
}
