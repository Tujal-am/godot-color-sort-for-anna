shader_type canvas_item;

// Paramètre accessible depuis l'inspecteur et le script GDScript
uniform float progress : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    vec4 texture_color = texture(TEXTURE, UV);
    
    // Recentrer les coordonnées UV de [0,1] vers [-1,1]
    vec2 pos = UV * 2.0 - 1.0;
    
    // Calculate angle relative to top (12 o'clock)
    float angle = atan(pos.x, -pos.y); // Angle entre -PI et PI
    // Si l'angle est négatif, on lui ajoute 2*PI pour avoir un intervalle continu [0, 2*PI]
    if (angle < 0.0) { angle += 2.0 * PI; }
    
    // Normalisation entre 0.0 (12h) et 1.0 (360°)
    float current_progress = angle / (2.0 * PI);
    
    // Masquer les pixels qui dépassent le pourcentage
    if (current_progress <= progress) {
        COLOR = texture_color;
    } else {
        COLOR = vec4(0.0); // Transparence totale
    }
}