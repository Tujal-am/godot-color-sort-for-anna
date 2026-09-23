extends Node

class_name Jeton

signal clique_gauche(reference_parent)

var _jetons = {
	0: ['A', Color('RED')],
	#0: [String.chr(0x1F3C6), Color('RED')],
	1: ['B', Color('BLUE_VIOLET')],
	2: ['C', Color('FOREST_GREEN')],
	3: ['D', Color('AQUA')],
	4: ['E', Color('SADDLE_BROWN')],
	5: ['F', Color('DEEP_SKY_BLUE')],
	6: ['G', Color('MAGENTA')],
	7: ['H', Color('TOMATO')],
	8: ['I', Color('BLUE')],
	9: ['J', Color('CORNFLOWER_BLUE')], # 'J' est hors cadre !
	10: ['K', Color('VIOLET')],
	11: ['L', Color('TEAL')],
	12: ['M', Color('SLATE_GRAY')],
	13: ['N', Color('SANDY_BROWN')],
	14: ['O', Color('DARK_GRAY')],
	15: ['P', Color('BLACK')],
	16: ['Q', Color('CHARTREUSE')],
	17: ['R', Color('CRIMSON')],
	18: ['S', Color('DARK_GREEN')],
	19: ['T', Color('DARK_ORANGE')],
	20: ['U', Color('DEEP_PINK')],
	21: ['V', Color('HOT_PINK')],
	22: ['W', Color('MAROON')],
	23: ['X', Color('MEDIUM_SLATE_BLUE')],
	24: ['Y', Color('TURQUOISE')],
	25: ['Z', Color('SPRING_GREEN')],
	Plateau.ESPACE: [' ', Color('DARK_MAGENTA')] # DARK_VIOLET # DARK_MAGENTA # INDIGO # REBECCA_PURPLE # WEB_PURPLE
}

@export var indice_jeton = Plateau.ESPACE
var _couleur : Color
var nom : String
var position_initiale_carre : Vector2 #(0,0)
var position_initiale_nom : Vector2 #(0,-16)
var reference_parent # Reference pour que le parent identifie le jeton.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Enregistrer les positions initiales
	position_initiale_carre = $Carre.position
	position_initiale_nom = $Nom.position

func choisir_reference(reference : int) -> void:
	reference_parent = reference

func choisir_jeton(indice : int, redimensionner : bool = false) -> void:
	if indice in _jetons:
		indice_jeton = indice
		nom = _jetons[indice_jeton][0]
		_couleur = _jetons[indice_jeton][1]
		self._choisir_les_couleurs()
		$Nom.text = nom
		if redimensionner:
			if nom == 'J':
				# La lettre 'J' sort de son carré
				var font_size = $Nom.get_theme_font_size("font_size")
				$Nom.add_theme_font_size_override("font_size", font_size - 2)
				position_initiale_nom.y -= 3
			#if String.chr(0x1F3C6):
				## L'EMOJI sort de son carré
				#var font_size = $Nom.get_theme_font_size("font_size")
				#$Nom.add_theme_font_size_override("font_size", font_size - 8)

func _choisir_les_couleurs() -> void:
	if _couleur.get_luminance() > 0.5:
		# Couleur claire => assombrir la sélection
		$Selection.color = _couleur.darkened(0.3)
	else:
		# Couleur foncée => éclaircir la sélection
		$Selection.color = _couleur.lightened(0.3)
	$SoudureHaute.color = _couleur.darkened(0.3)
	$SoudureBasse.color = _couleur.darkened(0.3)
	$Carre.color = _couleur

func choisir_position(nouvelle_position : Vector2) -> void:
	$Selection.set_position(position_initiale_carre + Vector2(-4, -4) + nouvelle_position)
	$SoudureHaute.set_position(position_initiale_carre + Vector2(0, -2) + nouvelle_position)
	$Carre.set_position(position_initiale_carre + nouvelle_position)
	$SoudureBasse.set_position(position_initiale_carre + Vector2(0, $Carre.size.y) + nouvelle_position)
	# LogService.log_debug("Jeton.choisir_position : $Carre.position = ", $Carre.get_position())
	
	$Nom.set_position(position_initiale_nom + nouvelle_position)
	# LogService.log_debug("Jeton.choisir_position : $Nom.position = ", $Nom.get_position())

func hauteur() -> int:
	return $Carre.size.y

func largeur() -> int:
	return $Carre.size.x

func couleur() -> Color:
	return _couleur

func couleur_selection() -> Color:
	return $Selection.color

func position() -> Vector2:
	return $Carre.position

func est_vide() -> bool:
	return indice_jeton == Plateau.ESPACE

func souder_en_haut() -> void:
	$SoudureHaute.show()

func hide() -> void:
	$Carre.hide()
	$Nom.hide()

func show() -> void:
	$Carre.show()
	$Nom.show()

func set_scale(valeur) -> void:
	$Selection.set_scale(valeur)
	$SoudureHaute.set_scale(valeur)
	$Carre.set_scale(valeur)
	$SoudureBasse.set_scale(valeur)
	$Nom.set_scale(valeur)

func souder_en_bas() -> void:
	$SoudureBasse.show()

func dessouder() -> void:
	$SoudureHaute.hide()
	$SoudureBasse.hide()

func selectionner():
	$Selection.show()

func deselectionner():
	$Selection.hide()

func _on_carre_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# LogService.log_debug("Clique souris sur : ", $Nom.text)
			clique_gauche.emit(reference_parent)
