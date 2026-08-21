extends Node

const PLATEAU_TEST := "AB.CA.BC.  "

var succes := true

func _ready() -> void:
	_tester_decision_globale()
	await _tester_plateau_et_clavier()
	print("TEST_ACTIVATION_GLOBALE_THEME: ", "PASS" if succes else "FAIL")
	get_tree().quit(0 if succes else 1)

func _tester_decision_globale() -> void:
	var piles := PlateauDecodeurService.new().decoder_plateau(PLATEAU_TEST)
	_verifier(Plateau.determiner_theme_visuel_effectif(
			Jeton.THEME_CLASSIQUE, piles, {}) == Jeton.THEME_CLASSIQUE,
			"Le thème par défaut doit rester classique.")
	_verifier(Plateau.determiner_theme_visuel_effectif(
			Jeton.THEME_CLASSIQUE, piles, {
				Jeton.THEME_ORIGINEL_ROND_V1: {0: [&"test"]},
			}) == Jeton.THEME_CLASSIQUE,
			"Une demande classique doit rester classique.")
	_verifier(Plateau.determiner_theme_visuel_effectif(
			Jeton.THEME_ORIGINEL_ROND_V1, piles, {}) == Jeton.THEME_CLASSIQUE,
			"Un catalogue vide doit provoquer un fallback global.")
	_verifier(Plateau.determiner_theme_visuel_effectif(
			Jeton.THEME_ORIGINEL_ROND_V1, piles, {
				Jeton.THEME_ORIGINEL_ROND_V1: {
					0: [&"test_a"],
					1: [&"test_b"],
				},
			}) == Jeton.THEME_CLASSIQUE,
			"Un catalogue partiel doit provoquer un fallback global.")
	_verifier(Plateau.determiner_theme_visuel_effectif(
			Jeton.THEME_ORIGINEL_ROND_V1, piles, _catalogue_complet()) \
			== Jeton.THEME_ORIGINEL_ROND_V1,
			"Un catalogue complet doit autoriser le thème demandé.")

func _tester_plateau_et_clavier() -> void:
	var plateau_scene: PackedScene = load("res://Scenes/Plateau/plateau.tscn")
	var plateau_partiel = plateau_scene.instantiate()
	plateau_partiel.theme_visuel_demande = Jeton.THEME_ORIGINEL_ROND_V1
	plateau_partiel.catalogue_variantes = {
		Jeton.THEME_ORIGINEL_ROND_V1: {
			0: [&"test_a"],
			1: [&"test_b"],
		},
	}
	add_child(plateau_partiel)
	plateau_partiel.commencer_un_nouveau_plateau(PLATEAU_TEST)
	await get_tree().process_frame
	_verifier(plateau_partiel.theme_visuel_effectif == Jeton.THEME_CLASSIQUE,
			"Un catalogue partiel doit rendre le plateau entier classique.")
	for pile in plateau_partiel.liste_piles:
		for jeton in pile.liste_jetons:
			_verifier(jeton.theme_visuel == Jeton.THEME_CLASSIQUE,
					"Le fallback ne doit jamais être décidé jeton par jeton.")
	plateau_partiel.free()

	var plateau = plateau_scene.instantiate()
	_verifier(plateau.theme_visuel_demande == Jeton.THEME_CLASSIQUE,
			"Sans demande explicite, le thème demandé doit être classique.")
	plateau.theme_visuel_demande = Jeton.THEME_ORIGINEL_ROND_V1
	plateau.catalogue_variantes = _catalogue_complet()
	add_child(plateau)
	plateau.commencer_un_nouveau_plateau(PLATEAU_TEST)
	await get_tree().process_frame
	_verifier(plateau.theme_visuel_effectif == Jeton.THEME_ORIGINEL_ROND_V1,
			"Le thème complet doit être effectif sur le plateau.")
	for pile in plateau.liste_piles:
		for jeton in pile.liste_jetons:
			_verifier(jeton.theme_visuel == plateau.theme_visuel_effectif,
					"Tous les jetons doivent recevoir le même thème effectif.")
			_verifier(jeton.get_node("Carre/Visuel").visible == false,
					"Cette étape ne doit afficher aucun visuel illustré.")
	var premiere_pile = plateau.liste_piles[0]
	_verifier(premiere_pile.liste_jetons[0].largeur() == 32,
			"Carre doit conserver une largeur de 32 pixels.")
	_verifier(premiere_pile.liste_jetons[0].hauteur() == 32,
			"Carre doit conserver une hauteur de 32 pixels.")
	_verifier(absf(premiere_pile.liste_jetons[0].position().y \
			- premiere_pile.liste_jetons[1].position().y) == 34,
			"Le pas vertical doit rester de 34 pixels.")
	plateau.free()

	var clavier_scene: PackedScene = load("res://Scenes/MenuPrincipal/Clavier/clavier.tscn")
	var clavier = clavier_scene.instantiate()
	add_child(clavier)
	await get_tree().process_frame
	_verifier(not clavier.visible and clavier.liste_touches.size() == 26,
			"Le clavier historique doit rester masqué et complet.")
	for touche in clavier.liste_touches:
		_verifier(touche.theme_visuel == Jeton.THEME_CLASSIQUE,
				"Les touches du clavier doivent rester classiques.")
		_verifier(not touche.get_node("Carre").visible \
				and not touche.get_node("Nom").visible,
				"La visibilité historique des touches doit être conservée.")
		_verifier(touche.get_node("Carre").scale == Vector2(1.5, 1.5),
				"Le clavier doit conserver son échelle 1,5.")
	clavier.free()

func _catalogue_complet() -> Dictionary:
	return {
		Jeton.THEME_ORIGINEL_ROND_V1: {
			0: [&"test_a"],
			1: [&"test_b"],
			2: [&"test_c"],
		},
	}

func _verifier(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		succes = false
