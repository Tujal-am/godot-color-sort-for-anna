shader_type canvas_item;
uniform float ratio : hint_range(0.0, 1.0) = 0.0;
void fragment() {
 float r = clamp(ratio, 0.0, 1.0);
 float radius = min(0.5, 6.0 / max(1.0, 112.0 * r));
 float left_edge = radius;
 float right_edge = max(left_edge, r - radius);
 float d_left = length((UV - vec2(left_edge, 0.5)) * vec2(112.0 * r / 12.0, 1.0));
 float d_right = length((UV - vec2(right_edge, 0.5)) * vec2(112.0 * r / 12.0, 1.0));
 float edge = min(min(UV.x, r - UV.x) * 12.0, min(UV.y, 1.0 - UV.y) * 12.0);
 float alpha = step(0.0, r) * smoothstep(0.0, 1.0, edge);
 COLOR = mix(vec4(0.843, 0.929, 0.125, 1.0), vec4(0.98, 1.0, 0.47, 1.0), UV.y) * alpha;
}
