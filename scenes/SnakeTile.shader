shader_type canvas_item;

vec4 sample_glow_pixel(sampler2D tex, vec2 uv) {
    float hdr_threshold = 1.0; // Pixels with higher color than 1 will glow
    return max(texture(tex, uv) - hdr_threshold, vec4(0.0));
}

void fragment() {
    vec2 ps = SCREEN_PIXEL_SIZE;
    // Get blurred color from pixels considered glowing
    vec4 col0 = sample_glow_pixel(SCREEN_TEXTURE, SCREEN_UV + vec2(-ps.x, 0));
    vec4 col1 = sample_glow_pixel(SCREEN_TEXTURE, SCREEN_UV + vec2(ps.x, 0));
    vec4 col2 = sample_glow_pixel(SCREEN_TEXTURE, SCREEN_UV + vec2(0, -ps.y));
    vec4 col3 = sample_glow_pixel(SCREEN_TEXTURE, SCREEN_UV + vec2(0, ps.y));

    vec4 col = texture(SCREEN_TEXTURE, SCREEN_UV);
    vec4 glowing_col = 0.25 * (col0 + col1 + col2 + col3);

    COLOR = vec4(col.rgb + glowing_col.rgb, col.a);
}