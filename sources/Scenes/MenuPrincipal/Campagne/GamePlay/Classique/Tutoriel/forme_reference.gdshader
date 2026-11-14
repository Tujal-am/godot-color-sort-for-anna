shader_type canvas_item;
// Forme indépendante en objets Godot : aucune découpe d'une maquette RGB.
uniform vec2 dimensions = vec2(32.0, 32.0);
uniform float rayon = 6.0;
uniform vec4 haut = vec4(0.58, 0.29, 0.95, 1.0);
uniform vec4 bas = vec4(0.39, 0.14, 0.82, 1.0);
uniform bool contour_seul = false;
uniform bool pointilles = false;
void fragment() {
	float modulation = COLOR.a;
	vec2 p = UV * dimensions - dimensions * 0.5;
	vec2 q = abs(p) - dimensions * 0.5 + vec2(rayon);
	float d = length(max(q, vec2(0.0))) + min(max(q.x,q.y),0.0) - rayon;
	vec4 face = mix(haut, bas, UV.y);
	float alpha = 1.0-smoothstep(-0.65, 0.65, d);
	if (contour_seul) {
		alpha *= smoothstep(-2.0,-1.0,d);
		if (pointilles) {
			float v = abs(p.x)/(dimensions.x*0.5) > abs(p.y)/(dimensions.y*0.5) ? p.y+dimensions.y*0.5 : p.x+dimensions.x*0.5;
			alpha *= 1.0-smoothstep(6.0,7.0,mod(v,12.0));
		}
	}
	COLOR = vec4(face.rgb, face.a * alpha * modulation);
}
