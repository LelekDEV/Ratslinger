shader_type canvas_item;

uniform vec4 outline_color : source_color;
uniform bool is_visible = false;
uniform float thickness;
varying vec4 v_vertex_color;

void vertex()
{
	v_vertex_color = COLOR;
}

void fragment()
{
	if (is_visible)
	{
		float size_x = thickness/float(textureSize(TEXTURE, 0).x);
		float size_y = thickness/float(textureSize(TEXTURE, 0).y);
		vec4 sprite_color = texture(TEXTURE, UV);
		float alpha = -4.0 * sprite_color.a;
		alpha += texture(TEXTURE, UV + vec2(size_x, 0)).a;
		alpha += texture(TEXTURE, UV + vec2(-size_x, 0)).a;
		alpha += texture(TEXTURE, UV + vec2(0, size_y)).a;
		alpha += texture(TEXTURE, UV + vec2(0, -size_y)).a;
		//For outlining corners
		//Change the -4.0 to -8.0 in alpa if adding these lines
		//alpha += texture(TEXTURE, UV + vec2(size_x, size_y)).a;
		//alpha += texture(TEXTURE, UV + vec2(-size_x, size_y)).a;
		//alpha += texture(TEXTURE, UV + vec2(-size_x, -size_y)).a;
		//alpha += texture(TEXTURE, UV + vec2(size_x, -size_y)).a;
		vec4 final_color = mix(sprite_color, outline_color, clamp(alpha, 0.0, 1.0));
		COLOR = v_vertex_color * vec4(final_color.rgb, clamp(abs(alpha) + sprite_color.a, 0.0, 1.0));
	}
}