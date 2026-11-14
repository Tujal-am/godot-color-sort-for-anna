extends "res://Scenes/MenuPrincipal/Campagne/GamePlay/Plateau/Pile/Jeton/jeton.gd"

## Overrides locaux du jeton RC20 pour la forme/couleur de la référence approuvée.
## Script et nœuds natifs réutilisés ; aucune modification du vrai jeton du jeu.
const DEGRADES := {
	0: [Color8(235, 81, 58), Color8(213, 61, 42)],
	1: [Color8(155, 80, 248), Color8(98, 35, 207)],
	2: [Color8(133, 188, 76), Color8(79, 137, 42)],
	3: [Color8(97, 199, 230), Color8(69, 157, 199)]
}

const JETON_NATIF := preload("res://Scenes/MenuPrincipal/Campagne/GamePlay/Plateau/Pile/Jeton/jeton.tscn")
const FORME := preload("res://Scenes/MenuPrincipal/Campagne/GamePlay/Classique/Tutoriel/forme_reference.gdshader")
const POLICE := preload("res://Art/UI/Fonts/DejaVu/DejaVuSans-Bold.ttf")

func _enter_tree() -> void:
	if get_child_count() > 0:
		return
	# Vraie instance du PackedScene RC20 : réutiliser ses enfants, sans copier
	# leur définition graphique ni changer la scène du vrai plateau.
	var instance := JETON_NATIF.instantiate()
	for enfant in instance.get_children():
		enfant.owner = null
		instance.remove_child(enfant)
		add_child(enfant)
		if enfant is Control:
			enfant.mouse_filter = Control.MOUSE_FILTER_IGNORE
	instance.free()

func _ready() -> void:
	super._ready()
	var mat := ShaderMaterial.new()
	mat.shader = FORME
	$Carre.material = mat
	$Nom.add_theme_font_override("font",POLICE)
	$Nom.add_theme_font_size_override("font_size",20)
	$Nom.add_theme_color_override("font_shadow_color",Color(0,0,0,0))

func choisir_jeton(indice: int, redimensionner: bool = false) -> void:
	super.choisir_jeton(indice, redimensionner)
	if DEGRADES.has(indice):
		$Carre.material.set_shader_parameter("haut", DEGRADES[indice][0])
		$Carre.material.set_shader_parameter("bas", DEGRADES[indice][1])

func configurer_dimensions(dimensions: Vector2, corps: int) -> void:
	$Carre.size = dimensions
	$Carre.material.set_shader_parameter("dimensions", dimensions)
	$Carre.material.set_shader_parameter("rayon", dimensions.y * 0.18)
	$Nom.position = Vector2.ZERO
	$Nom.size = dimensions
	$Nom.add_theme_font_size_override("font_size", corps)
