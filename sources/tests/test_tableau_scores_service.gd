extends GutTest

var service
const RACINE_TEST = "tests/test_tableau_scores_service"

func _nettoyer_fichier_scores() -> void:
	FichiersJsonService.effacer_racine_utilisateur()

func _lire_fichier_scores():
	return FichiersJsonService.read_json_file("scores.json")

func _creer_service(scores = null):
	_nettoyer_fichier_scores()
	if scores != null:
		FichiersJsonService.write_json_file("scores.json", scores)
	service = add_child_autofree(load("res://Singletons/Sauvegarde/tableau_scores_service.gd").new())
	return service

func _assert_score_eq(score_actuel : Dictionary, score_attendu : Dictionary) -> void:
	assert_eq(score_actuel.get("nom"), score_attendu.get("nom"))
	assert_eq(int(score_actuel.get("rang")), int(score_attendu.get("rang")))
	assert_eq(int(score_actuel.get("score")), int(score_attendu.get("score")))
	assert_eq(score_actuel.get("score_txt"), score_attendu.get("score_txt"))

func _assert_liste_scores_eq(liste_actuelle : Array, liste_attendue : Array) -> void:
	assert_eq(liste_actuelle.size(), liste_attendue.size())
	for index in range(liste_attendue.size()):
		_assert_score_eq(liste_actuelle[index], liste_attendue[index])

func before_each():
	FichiersJsonService.definir_racine_utilisateur(RACINE_TEST)
	_nettoyer_fichier_scores()

func after_each():
	_nettoyer_fichier_scores()
	FichiersJsonService.reinitialiser_racine_utilisateur()

func test_ready_cree_le_fichier_initial_si_absent():
	_creer_service()

	var score_initial = {
		"nom": "Alain Konu",
		"rang": 1,
		"score": 0,
		"score_txt": "0"
	}

	assert_true(FichiersJsonService.json_file_exists("scores.json"))
	_assert_liste_scores_eq(service.liste_des_scores, [score_initial])
	_assert_liste_scores_eq(_lire_fichier_scores(), [score_initial])

func test_ready_charge_le_fichier_existant():
	var scores = [
		{"nom": "Alice", "rang": 1, "score": 2500, "score_txt": "2.500"},
		{"nom": "Bob", "rang": 2, "score": 1000, "score_txt": "1.000"}
	]

	_creer_service(scores)

	_assert_liste_scores_eq(service.liste_des_scores, scores)
	_assert_liste_scores_eq(_lire_fichier_scores(), scores)

func test_retourner_le_joueur_et_le_joueur_existe_gerent_present_et_absent():
	_creer_service([
		{"nom": "Alice", "rang": 1, "score": 1500, "score_txt": "1.500"},
		{"nom": "Bob", "rang": 2, "score": 400, "score_txt": "400"}
	])

	assert_eq(int(service._retourner_le_joueur("Alice").get("score")), 1500)
	assert_eq(service._retourner_le_joueur("Inconnu"), {})
	assert_true(service.le_joueur_existe("Alice"))
	assert_false(service.le_joueur_existe("Inconnu"))

func test_ajouter_un_nouveau_joueur_refuse_un_nom_vide_ou_deja_pris():
	_creer_service([
		{"nom": "Alice", "rang": 1, "score": 1500, "score_txt": "1.500"}
	])

	assert_false(service.ajouter_un_nouveau_joueur(""))
	assert_false(service.ajouter_un_nouveau_joueur("Alice"))
	assert_eq(service.liste_des_scores.size(), 1)

func test_ajouter_un_nouveau_joueur_l_ajoute_au_tableau_et_persiste_le_classement():
	_creer_service([
		{"nom": "Alice", "rang": 1, "score": 3000, "score_txt": "3.000"},
		{"nom": "Bob", "rang": 2, "score": 1000, "score_txt": "1.000"}
	])

	assert_true(service.ajouter_un_nouveau_joueur("Charlie"))
	assert_true(service.le_joueur_existe("Charlie"))
	assert_eq(int(service.lire_score_joueur("Charlie")), 0)
	assert_eq(service.lire_score_txt_joueur("Charlie"), "0")
	assert_eq(service.lire_rang_joueur("Charlie"), 3)
	assert_eq(_lire_fichier_scores().size(), 3)

func test_lire_rang_score_et_score_txt_renvoient_les_valeurs_attendues():
	_creer_service([
		{"nom": "Alice", "rang": 1, "score": 1500, "score_txt": "1.500"}
	])

	assert_eq(service.lire_rang_joueur("Alice"), 1)
	assert_eq(service.lire_rang_joueur("Inconnu"), 0)
	assert_eq(int(service.lire_score_joueur("Alice")), 1500)
	assert_eq(int(service.lire_score_joueur("Inconnu")), 0)
	assert_eq(service.lire_score_txt_joueur("Alice"), "1.500")
	assert_eq(service.lire_score_txt_joueur("Inconnu"), "0")

func test_lire_les_trophees_couvre_le_podium_et_le_hors_podium_sur_la_plateforme_courante():
	_creer_service([
		{"nom": "Alice", "rang": 1, "score": 3000, "score_txt": "3.000"},
		{"nom": "Bob", "rang": 4, "score": 10, "score_txt": "10"}
	])

	var trophee_premier = ""
	var trophee_hors_podium = ""
	if OS.has_feature("web"):
		trophee_premier = "N°1"
		trophee_hors_podium = "N°X"
	else:
		trophee_premier = String.chr(0x1F3C6)
		trophee_hors_podium = String.chr(0x25FD)

	assert_eq(service.lire_le_trophee_du_rang(1), trophee_premier)
	assert_eq(service.lire_le_trophee_du_rang(4), trophee_hors_podium)
	assert_eq(service.lire_le_trophee_du_joueur("Alice"), trophee_premier)
	assert_eq(service.lire_le_trophee_du_joueur("Inconnu"), trophee_hors_podium)

func test_modifier_score_joueur_met_a_jour_le_score_le_texte_et_les_rangs():
	_creer_service([
		{"nom": "Alice", "rang": 1, "score": 2000, "score_txt": "2.000"},
		{"nom": "Bob", "rang": 2, "score": 1000, "score_txt": "1.000"},
		{"nom": "Charlie", "rang": 3, "score": 500, "score_txt": "500"}
	])

	service.modifier_score_joueur("Bob", 2500)

	assert_eq(int(service.lire_score_joueur("Bob")), 2500)
	assert_eq(service.lire_score_txt_joueur("Bob"), "2.500")
	assert_eq(service.lire_rang_joueur("Bob"), 1)
	assert_eq(service.lire_rang_joueur("Alice"), 2)
	assert_eq(service.lire_rang_joueur("Charlie"), 3)
	assert_eq(int(service._retourner_le_joueur("Bob").get("rang")), 1)
	assert_eq(int(_lire_fichier_scores()[1].get("score")), 2500)

func test_incrementer_score_joueur_gere_les_egalites_et_retourner_classement_trie_par_rang():
	_creer_service([
		{"nom": "Alice", "rang": 1, "score": 2000, "score_txt": "2.000"},
		{"nom": "Bob", "rang": 2, "score": 1000, "score_txt": "1.000"},
		{"nom": "Charlie", "rang": 3, "score": 1000, "score_txt": "1.000"}
	])

	service.incrementer_score_joueur("Bob", 1000)

	assert_eq(int(service.lire_score_joueur("Bob")), 2000)
	assert_eq(service.lire_score_txt_joueur("Bob"), "2.000")
	assert_eq(service.lire_rang_joueur("Alice"), 1)
	assert_eq(service.lire_rang_joueur("Bob"), 1)
	assert_eq(service.lire_rang_joueur("Charlie"), 3)

	var classement = service.retourner_classement()
	assert_eq(classement.size(), 3)
	assert_eq(classement[0].get("rang"), 1)
	assert_eq(classement[1].get("rang"), 1)
	assert_eq(classement[2].get("rang"), 3)

func test_modifier_et_incrementer_ignorent_un_joueur_inconnu():
	_creer_service([
		{"nom": "Alice", "rang": 1, "score": 2000, "score_txt": "2.000"}
	])

	var avant = service.liste_des_scores.duplicate(true)
	service.modifier_score_joueur("Inconnu", 9999)
	service.incrementer_score_joueur("Inconnu", 500)

	assert_eq(service.liste_des_scores, avant)
	assert_eq(_lire_fichier_scores(), avant)

func test_remise_a_zero_remet_tous_les_scores_a_zero_et_persiste():
	_creer_service([
		{"nom": "Alice", "rang": 1, "score": 2000, "score_txt": "2.000"},
		{"nom": "Bob", "rang": 2, "score": 1000, "score_txt": "1.000"}
	])

	service.remise_a_zero()

	for joueur in service.liste_des_scores:
		assert_eq(int(joueur.get("score")), 0)
		assert_eq(joueur.get("score_txt"), "0")

	for joueur in _lire_fichier_scores():
		assert_eq(int(joueur.get("score")), 0)
		assert_eq(joueur.get("score_txt"), "0")

func test_nombre_avec_separateur_de_milliers_formate_zero_et_les_grands_nombres():
	_creer_service()

	assert_eq(service.nombre_avec_separateur_de_milliers(0, "."), "0")
	assert_eq(service.nombre_avec_separateur_de_milliers(1234, "."), "1.234")
	assert_eq(service.nombre_avec_separateur_de_milliers(1234567, "."), "1.234.567")
