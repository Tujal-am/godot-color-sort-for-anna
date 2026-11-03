extends GutTest

const SCENE_SCORES = preload("res://Scenes/MenuPrincipal/Scores/scores.tscn")
var espace_insecable := String.chr(0x00A0)

var liste_des_scores_initiale: Array
var _avertissements_de_casse := 0

func before_each() -> void:
	liste_des_scores_initiale = SauvegardeTableauDesScoresService.liste_des_scores.duplicate(true)

func after_each() -> void:
	var scene_courante := get_tree().current_scene
	if scene_courante != null:
		scene_courante.queue_free()
	SauvegardeTableauDesScoresService.liste_des_scores = liste_des_scores_initiale

func _joueur(nom: String, rang: int, score: int) -> Dictionary:
	return {"nom": nom, "rang": rang, "score": score, "score_txt": str(score)}

func _ecran_avec(scores: Array) -> Control:
	SauvegardeTableauDesScoresService.liste_des_scores = scores
	var ecran: Control = add_child_autofree(SCENE_SCORES.instantiate())
	_avertissements_de_casse = 0
	for erreur in get_errors():
		if erreur.contains_text("Case mismatch"):
			erreur.handled = true
			_avertissements_de_casse += 1
	return ecran

func _ligne(ecran: Node, rang: int) -> Node:
	var panneau := ecran.get_node("ClassementDynamique")
	var carte := panneau.get_child(0) if rang == 1 else panneau.get_child(1)
	return carte.get_node("Rang%d" % rang)

func _nom(ecran: Node, rang: int) -> String:
	return _ligne(ecran, rang).get_node("Nom").text

func _score(ecran: Node, rang: int) -> String:
	return _ligne(ecran, rang).get_node("Score").text

func test_les_medailles_se_chargent_sans_avertissement_de_casse() -> void:
	_ecran_avec([_joueur("A", 1, 5), _joueur("B", 2, 4)])

	assert_eq(_avertissements_de_casse, 0, "ASSET_DIR doit avoir la même casse que le dossier 'Art/UI/Scores/'")

func test_l_ecran_construit_un_classement_de_cinq_lignes() -> void:
	var ecran := _ecran_avec([])

	var panneau := ecran.get_node("ClassementDynamique")
	assert_eq(panneau.get_child_count(), 2)
	assert_eq(panneau.get_child(0).get_child_count(), 1)
	assert_eq(panneau.get_child(1).get_child_count(), 4)
	for rang in range(1, 6):
		assert_not_null(_ligne(ecran, rang), "Rang%d" % rang)

func test_un_classement_vide_affiche_des_tirets() -> void:
	var ecran := _ecran_avec([])

	for rang in range(1, 6):
		assert_eq(_nom(ecran, rang), "-")
		assert_eq(_score(ecran, rang), "-")

func test_les_joueurs_sont_affiches_dans_l_ordre_du_classement() -> void:
	var ecran := _ecran_avec([
		_joueur("Charlie", 3, 300),
		_joueur("Alice", 1, 900),
		_joueur("Bob", 2, 500)
	])

	assert_eq(_nom(ecran, 1), "Alice")
	assert_eq(_score(ecran, 1), "900")
	assert_eq(_nom(ecran, 2), "Bob")
	assert_eq(_score(ecran, 2), "500")
	assert_eq(_nom(ecran, 3), "Charlie")
	assert_eq(_score(ecran, 3), "300")

func test_les_places_vides_sont_completees_par_des_tirets() -> void:
	var ecran := _ecran_avec([_joueur("Alice", 1, 10), _joueur("Bob", 2, 5)])

	assert_eq(_nom(ecran, 2), "Bob")
	assert_eq(_nom(ecran, 3), "-")
	assert_eq(_score(ecran, 3), "-")
	assert_eq(_nom(ecran, 5), "-")

func test_seuls_les_cinq_meilleurs_sont_affiches() -> void:
	var scores: Array = []
	for i in range(1, 8):
		scores.append(_joueur("J%d" % i, i, 1000 - i))
	var ecran := _ecran_avec(scores)

	assert_eq(_nom(ecran, 5), "J5")
	assert_eq(ecran.get_node("ClassementDynamique").get_child(1).get_child_count(), 4)

func test_les_joueurs_ex_aequo_sont_tous_affiches() -> void:
	var ecran := _ecran_avec([
		_joueur("Alice", 1, 900),
		_joueur("Bob", 2, 500),
		_joueur("Charlie", 2, 500)
	])

	assert_eq(_nom(ecran, 2), "Bob")
	assert_eq(_nom(ecran, 3), "Charlie")
	assert_eq(_score(ecran, 3), "500")

func test_les_scores_sont_separes_par_des_espaces_insecables() -> void:
	var ecran := _ecran_avec([_joueur("Alice", 1, 1234567), _joueur("Bob", 2, 12345), _joueur("Eve", 3, 999)])

	assert_eq(_score(ecran, 1), "1" + espace_insecable + "234" + espace_insecable + "567")
	assert_eq(_score(ecran, 2), "12" + espace_insecable + "345")
	assert_eq(_score(ecran, 3), "999")

func test_format_score_fr_gere_les_bornes() -> void:
	var ecran: Control = _ecran_avec([])

	assert_eq(ecran._format_score_fr(0), "0")
	assert_eq(ecran._format_score_fr(999), "999")
	assert_eq(ecran._format_score_fr(1000), "1" + espace_insecable + "000")
	assert_eq(ecran._format_score_fr(100000), "100" + espace_insecable + "000")
	assert_eq(ecran._format_score_fr(1000000), "1" + espace_insecable + "000" + espace_insecable + "000")

func test_chaque_ligne_affiche_la_medaille_de_son_rang() -> void:
	var ecran := _ecran_avec([
		_joueur("A", 1, 5), _joueur("B", 2, 4), _joueur("C", 3, 3), _joueur("D", 4, 2), _joueur("E", 5, 1)
	])

	assert_eq(_ligne(ecran, 1).get_node("Medaille").texture.resource_path, "res://Art/UI/Scores/medaille_rang_1_72x88_transparente.png")
	for rang in range(2, 6):
		assert_eq(_ligne(ecran, rang).get_node("Medaille").texture.resource_path, "res://Art/UI/Scores/medaille_rang_%d_58x58.png" % rang)

func test_un_ex_aequo_reprend_la_medaille_du_rang_partage() -> void:
	var ecran := _ecran_avec([_joueur("A", 1, 5), _joueur("B", 2, 4), _joueur("C", 2, 4)])

	assert_eq(_ligne(ecran, 3).get_node("Medaille").texture.resource_path, "res://Art/UI/Scores/medaille_rang_2_58x58.png")

func test_le_premier_est_mis_en_avant_avec_une_police_plus_grande() -> void:
	var ecran := _ecran_avec([_joueur("A", 1, 5), _joueur("B", 2, 4)])

	assert_gt(_ligne(ecran, 1).get_node("Nom").get_theme_font_size("font_size"), _ligne(ecran, 2).get_node("Nom").get_theme_font_size("font_size"))
	assert_gt(_ligne(ecran, 1).get_node("Score").get_theme_font_size("font_size"), _ligne(ecran, 2).get_node("Score").get_theme_font_size("font_size"))

func test_le_classement_ne_capte_pas_les_clics() -> void:
	var ecran := _ecran_avec([_joueur("A", 1, 5)])

	assert_eq(ecran.get_node("ClassementDynamique").mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_eq(_ligne(ecran, 1).mouse_filter, Control.MOUSE_FILTER_IGNORE)

func test_retour_charge_le_menu_principal() -> void:
	var ecran := _ecran_avec([])

	ecran.get_node("Retour").emit_signal("pressed")
	await wait_process_frames(3)

	assert_not_null(get_tree().current_scene)
	assert_eq(get_tree().current_scene.scene_file_path, "res://Scenes/MenuPrincipal/menu_principal.tscn")
