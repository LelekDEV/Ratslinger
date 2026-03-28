// SHADER CODE FROM https://godotshaders.com/shader/wall-destruction-block-break/
shader_type canvas_item;

uniform float progress_fall : hint_range(0.0, 1.0) = 0.0;     
uniform float progress_rotation : hint_range(0.0, 10.0) = 0.0; // Aumentei o range para rotações infinitas
uniform float progress_scatter : hint_range(0.0, 6.0) = 0.0; 
uniform float progress_fade : hint_range(0.0, 1.0) = 0.0;     

uniform vec2 grid_size = vec2(10.0, 10.0);

// Física
uniform float gravity = 6.0;
uniform float ground_level : hint_range(0.0,2.0) = 0.9;
uniform float stack_variation = 0.15;
uniform float slide_on_ground = 0.3;

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

const float scale = 2.1;

void vertex() {
    VERTEX *= 1. + scale;
}

void fragment() {
    float total_scale = 1.0 + scale;
    vec2 local_uv = (UV - REGION_RECT.xy) / REGION_RECT.zw;
    vec2 adjusted_local_uv = (local_uv - 0.5) * total_scale + 0.5;
    
    vec4 final_color = vec4(0.0);
    vec2 my_cell = floor(adjusted_local_uv * grid_size);
    bool found = false;

    for (int y = -17; y <= 5; y++) { // Aumentei a margem vertical para não sumir ao espalhar muito
        for (int x = -8; x <= 8; x++) { // Aumentei a margem horizontal para o scatter alto
            vec2 check_cell = my_cell + vec2(float(x), float(y));

            if (check_cell.x < 0.0 || check_cell.x >= grid_size.x || check_cell.y < 0.0 || check_cell.y >= grid_size.y) {
                continue;
            }

            float r_delay = rand(check_cell) * 0.2;
            float r_scatter = rand(check_cell + vec2(1.1, 0.0));
            float r_rotate = rand(check_cell + vec2(0.0, 1.1));
            float r_stack = rand(check_cell + vec2(1.1, 1.1));
            float r_slide = rand(check_cell + vec2(2.2, 0.0));

            // --- REMOVIDO O CLAMP DE 0-1 ---
            // Agora os valores podem crescer além de 1.0
            float p_fall = clamp((progress_fall - r_delay) / (0.8), 0.0, 1.0);
            float p_rot = max(progress_rotation - r_delay, 0.0); 
            float p_scat = max(progress_scatter - r_delay, 0.0);

            vec2 cell_center = (check_cell + vec2(0.5)) / grid_size;

            // --- Posição Vertical ---
            float fall_dist = gravity * p_fall * p_fall;
            float personal_ground = ground_level + (r_stack - 0.5) * stack_variation;
            
            float final_y = min(cell_center.y + fall_dist, personal_ground);
            bool is_on_ground = (cell_center.y + fall_dist) >= personal_ground;

            // --- Posição Horizontal (Scatter Destravado) ---
            // O scatter agora flui livremente conforme progress_scatter aumenta
            float lateral_move = (r_scatter - 0.5) * 0.4 * p_scat;
            float ground_slide_val = (r_slide - 0.5) * slide_on_ground * (is_on_ground ? p_scat : 0.0);
            float final_x = cell_center.x + lateral_move + ground_slide_val;

            vec2 offset = vec2(final_x - cell_center.x, final_y - cell_center.y);

            // --- Rotação (Destravada e Infinita) ---
            // p_rot agora não para em 1.0, permitindo múltiplas voltas
            float angle = (r_rotate - 0.5) * 6.0 * p_rot;
            float c = cos(angle); float s = sin(angle);

            // Mapeamento inverso
            vec2 rel_uv = adjusted_local_uv - cell_center - offset;
            vec2 rotated_rel_uv = vec2(rel_uv.x * c - rel_uv.y * s, rel_uv.x * s + rel_uv.y * c);
            vec2 orig_local_uv = cell_center + rotated_rel_uv;

            if (floor(orig_local_uv * grid_size) == check_cell) {
                vec2 atlas_uv = orig_local_uv * REGION_RECT.zw + REGION_RECT.xy;
                vec4 tex_color = texture(TEXTURE, atlas_uv);
                
                if (tex_color.a > 0.0) {
                    float local_fade = clamp((progress_fade - r_delay) / 0.8, 0.0, 1.0);
                    final_color = vec4(tex_color.rgb, tex_color.a * (1.0 - local_fade));
                    found = true; 
                    break;
                }
            }
        }
        if (found) break;
    }
    COLOR = final_color;
}
