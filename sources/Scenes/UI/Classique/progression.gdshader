shader_type canvas_item;
uniform float ratio : hint_range(0.0, 1.0) = 0.0;
uniform vec3 start_color : source_color = vec3(0.098, 0.725, 0.686);
uniform vec3 end_color : source_color = vec3(0.318, 0.824, 0.765);
void fragment() {
	float width = 112.0 * clamp(ratio, 0.0, 1.0);
	float radius = min(6.0, width * 0.5);
	vec2 p = UV * vec2(112.0, 12.0);
	vec2 q = abs(p - vec2(width, 12.0) * 0.5) - vec2(width, 12.0) * 0.5 + radius;
	float distance = length(max(q, vec2(0.0))) + min(max(q.x, q.y), 0.0) - radius;
	float alpha = (1.0 - smoothstep(-0.7, 0.7, distance)) * step(0.001, width);
	vec3 tint = mix(start_color, end_color, clamp(p.x / max(width, 0.001), 0.0, 1.0));
	tint = mix(tint, vec3(1.0), 0.22 * (1.0 - smoothstep(1.0, 5.0, p.y)));
	COLOR = vec4(tint, alpha);
}
