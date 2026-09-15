extends CanvasLayer

class_name Clavier

signal pseudo_valide(pseudo: String)
signal pseudo_annule()

var pseudo := ""
var liste_touches = []

func _ready():
	hide() # Le clavier est invisible au début
	_generer_touches()

func ouvrir(pseudo_initial := ""):
	pseudo = pseudo_initial
	$Fond/ZoneEdition.text = pseudo
	_montrer_touches()
	show()

func fermer():
	_cacher_touches()
	hide()

func _cacher_touches() -> void:
	for touche in liste_touches:
		touche.hide()

func _montrer_touches() -> void:
	for touche in liste_touches:
		touche.show()

func _generer_touches():
	var fond_clavier = $Fond/FondClavier
	var jeton_scene: PackedScene = load("res://Scenes/MenuPrincipal/Campagne/GamePlay/Plateau/Pile/Jeton/jeton.tscn")

	# Alphabet A → Z
	var ligne = 0
	var colonne = 0
	var j = jeton_scene.instantiate()
	var h = j.hauteur()
	var l = j.largeur()
	var ref = $Fond/FondClavier.get_position() + Vector2(10,10)
	for ligne_texte in ['AZERTYUIO','QSDFGHJKL','WXCVBNPM']:
		for lettre in ligne_texte:
			# print(lettre)
			var indice = ord(lettre) - ord("A")
			var jeton = jeton_scene.instantiate()
			liste_touches.append(jeton) 
			fond_clavier.add_child(jeton)

			jeton.hide()
			jeton.choisir_reference(indice)
			jeton.choisir_jeton(indice)
			jeton.position_initiale_nom = Vector2(0,-25)
			jeton.set_scale(Vector2(1.5, 1.5))
			jeton.choisir_position(ref + Vector2(l * 1.6 * colonne, h * 1.6 * ligne))

			# Quand on clique sur le jeton → ajouter la lettre
			jeton.connect("clique_gauche", Callable(self, "on_jeton_clique_gauche"))

			colonne += 1
		ligne += 1
		colonne = 0

func _ajouter_caractere(c):
	pseudo += c
	$Fond/ZoneEdition.text = pseudo

func on_jeton_clique_gauche(indice):
	# On récupère la lettre correspondante
	if pseudo.length() < 10:
		var lettre = char(ord("A") + indice)
		_ajouter_caractere(lettre)

func _on_valider_pressed() -> void:
	LogService.log_debug("Clavier : _on_Valider_pressed", " - pseudo=",pseudo)
	emit_signal("pseudo_valide", pseudo)
	fermer()

func _on_effacer_pressed() -> void:
	LogService.log_debug("Clavier : _on_Effacer_pressed")
	if pseudo.length() > 0:
		pseudo = pseudo.substr(0, pseudo.length() - 1)
		$Fond/ZoneEdition.text = pseudo

func _on_annuler_pressed() -> void:
	LogService.log_debug("Clavier : _on_Annuler_pressed")
	emit_signal("pseudo_annule")
	fermer()
