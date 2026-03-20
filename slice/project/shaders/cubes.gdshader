shader_type spatial;

// Must match max_boxes in the GDScript.
const int MAX_BOXES = 64;

uniform vec3 box_mins[MAX_BOXES];
uniform vec3 box_maxs[MAX_BOXES];
uniform int  box_count;
uniform uint color_seed;

uniform float saturation : hint_range(0.0, 1.0) = 0.75;
uniform float brightness : hint_range(0.0, 1.0) = 0.9;

// --- Helpers ---

uint wang_hash(uint seed) {
    seed = (seed ^ 61u) ^ (seed >> 16u);
    seed *= 9u;
    seed = seed ^ (seed >> 4u);
    seed *= 0x27d4eb2du;
    seed = seed ^ (seed >> 15u);
    return seed;
}

vec3 hue_to_rgb(float h) {
    h = fract(h) * 6.0;
    float r = clamp(abs(h - 3.0) - 1.0, 0.0, 1.0);
    float g = clamp(2.0 - abs(h - 2.0), 0.0, 1.0);
    float b = clamp(2.0 - abs(h - 4.0), 0.0, 1.0);
    return vec3(r, g, b);
}

vec3 hsv_to_rgb(float h, float s, float v) {
    return mix(vec3(1.0), hue_to_rgb(h), s) * v;
}

// --- Varyings ---

varying vec3 world_pos;

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    int best_box = 0;
    float best_dist = 1e9;
    float best_center_dist = 1e9;

    for (int i = 0; i < box_count; i++) {
        vec3 d = max(box_mins[i] - world_pos, world_pos - box_maxs[i]);
        float dist = length(max(d, vec3(0.0)));

        vec3 center = (box_mins[i] + box_maxs[i]) * 0.5;
        float center_dist = length(world_pos - center);

        // If this box is meaningfully closer, prefer it outright.
        // If it's a near-tie (within epsilon), prefer the closer center.
        if (dist < best_dist - 0.001 ||
            (abs(dist - best_dist) < 0.001 && center_dist < best_center_dist)) {
            best_dist = dist;
            best_center_dist = center_dist;
            best_box = i;
        }
    }

	uint h = wang_hash(uint(best_box) * 2654435761u + color_seed);
    float hue = float(h) / 4294967295.0;

    ALBEDO    = hsv_to_rgb(hue, saturation, brightness);
    ROUGHNESS = 0.85;
    METALLIC  = 0.0;
}
