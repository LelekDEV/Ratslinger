// SHADER CODE FROM https://godotshaders.com/shader/gradient-pixel-glint-2/
// CC0, shadecore_dev
shader_type canvas_item;

uniform sampler2D main_color;

uniform float shine_progress : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float shine_size : hint_range(0.01, 1.0, 0.01) = 0.1;
uniform float shine_angle : hint_range(0.0, 89.9, 0.1) = 45.0;

float scale(float value, float inMin, float inMax, float outMin, float outMax) {
    return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
}

void fragment() {
	vec2 pixelation = 1.0 / TEXTURE_PIXEL_SIZE;
	vec2 pixelated_uv = floor(UV * pixelation) / pixelation;
	COLOR = texture(TEXTURE, UV);
    
	float slope = tan(radians(shine_angle));

	float progress = scale(shine_progress, 0.0, 1.0, -1.0 - shine_size - shine_size * slope, 1.0 * slope + shine_size + shine_size * slope);

	float shine_distance = (slope * pixelated_uv.x - pixelated_uv.y - progress) / (sqrt(slope * slope + 1.0));

	float shine_color_coord = clamp((shine_distance / (2.0 * shine_size)) + 0.5, 0.0, 1.0);

	vec4 gradient = texture(main_color, vec2(shine_color_coord, 0.5));

	float shine = step(shine_distance, shine_size) - step(shine_distance, -shine_size);

	COLOR.rgb = mix(COLOR.rgb, gradient.rgb, shine * gradient.a);
}