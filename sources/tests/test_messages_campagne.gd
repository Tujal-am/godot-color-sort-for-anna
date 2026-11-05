extends GutTest

const SCENE_MESSAGES_CAMPAGNE = preload("res://Scenes/MenuPrincipal/Campagne/MessagesCampagne/messages_campagne.tscn")
const RACINE_TEST := "tests/test_messages_campagne"
const SCENE_STATISTIQUES := "res://Scenes/MenuPrincipal/Campagne/Statistiques/statistiques.tscn"

var sauvegarde_joueur_initiale: Dictionary
var fichier_sauvegarde_initial: String
var configuration_initiale: Dictionary
var liste_des_scores_initiale: Array

func before_each() -> void:
	FichiersJsonService.definir_racine_utilisateur(RACINE_TEST)
	FichiersJsonService.effacer_racine_utilisateur()
	sauvegarde_joueur_initiale = SauvegardeBddJoueursService._sauvegarde_joueur.duplicate(true)
	fichier_sauvegarde_initial = SauvegardeBddJoueursService.fichier_sauvegarde
	configuration_initiale = SauvegardeConfigurationService.configuration_du_jeu.duplicate(true)
	liste_des_scores_initiale = SauvegardeTableauDesScoresService.liste_des_scores.duplicate(true)
	SauvegardeConfigurationService.configuration_du_jeu["date_debut_campagne"] = "2020-01-01 00:00:00"
	SauvegardeTableauDesScoresService.liste_des_scores = [{"nom": "Joueuse test", "rang": 1, "score": 0, "score_txt": "0"}]
	SauvegardeBddJoueursService._sauvegarde_joueur = {
		"nom": "Joueuse test",
		"campagne": {},
		"nombre_de_parties": {},
		"enregistrement_campagne": [{
			"campagne": "campagne_test",
			"date_debut": 1700000000,
			"date_fin": 0,
			"score": {"niveau": 0, "niveau_parfait": 0},
			"niveaux": [{
				"niveau": "niveau_1",
				"date_debut": 1700000000,
				"date_fin": 1700001000,
				"score": {"niveau": 100, "niveau_parfait": 50},
				"plateaux": [{"nom": "A1", "date_debut": 1700000010, "date_fin": 1700000020, "duree": 10, "difficulte": 1, "statut": "reussi", "gameplay": "CLASSIQUE", "score": {"duree": 20, "ratio_reussite": 80}}]
			}]
		}],
		"plateaux_libres": {}
	}
	SauvegardeBddJoueursService.fichier_sauvegarde = "joueuse_test.json"
	FichiersJsonService.write_json_file("joueuse_test.json", SauvegardeBddJoueursService._sauvegarde_joueur)

func after_each() -> void:
	var scene_courante := get_tree().current_scene
	if scene_courante != null:
		scene_courante.queue_free()
	SauvegardeBddJoueursService._sauvegarde_joueur = sauvegarde_joueur_initiale
	SauvegardeBddJoueursService.fichier_sauvegarde = fichier_sauvegarde_initial
	SauvegardeConfigurationService.configuration_du_jeu = configuration_initiale
	SauvegardeTableauDesScoresService.liste_des_scores = liste_des_scores_initiale
	FichiersJsonService.effacer_racine_utilisateur()
	FichiersJsonService.reinitialiser_racine_utilisateur()

func _messages() -> MessagesCampagne:
	return add_child_autofree(SCENE_MESSAGES_CAMPAGNE.instantiate())

func _texte(panneau: Node, carte: String, numero: int) -> String:
	return panneau.get_node("%s/ListeItems/Item%d/Texte" % [carte, numero]).text

func _detail_plateau() -> Dictionary:
	return {
		"duree": {"reference": 12, "recommence": 8.54, "realise": 9.14, "points": 1250},
		"ratio_reussite": {"ratio": 80, "points": 1500}
	}

func _detail_niveau() -> Dictionary:
	var detail := _detail_plateau()
	detail["niveau"] = {"longueur": 3, "points": 1000}
	detail["niveau_parfait"] = {"bonus": "oui", "points": 500}
	return detail

func _detail_campagne() -> Dictionary:
	var detail := _detail_niveau()
	detail["campagne"] = {"points": 2000}
	return detail

func _scene_apres_changement() -> String:
	await wait_process_frames(3)
	return get_tree().current_scene.scene_file_path

func test_fin_de_campagne_affiche_le_panneau_de_victoire_de_campagne() -> void:
	var menu: MessagesCampagne = add_child_autofree(SCENE_MESSAGES_CAMPAGNE.instantiate())

	menu._on_progression_campagne_service_fin_campagne()

	assert_true(menu.get_node("Centrer").visible)
	assert_true(menu.get_node("Centrer/PanneauVictoireCampagne").visible)

func test_passer_un_plateau_redonne_la_main_a_la_campagne_sans_panneau() -> void:
	var menu: MessagesCampagne = add_child_autofree(SCENE_MESSAGES_CAMPAGNE.instantiate())
	var continuations: Array[bool] = []
	menu.score_continuer.connect(func() -> void: continuations.append(true))

	menu.afficher_passer_un_plateau()

	assert_eq(continuations, [])
	assert_false(menu.get_node("Centrer").visible)

func test_messages_de_victoire_affichent_le_panneau_de_fin_de_campagne() -> void:
	var menu: MessagesCampagne = add_child_autofree(SCENE_MESSAGES_CAMPAGNE.instantiate())
	var continuations: Array[bool] = []
	menu.score_continuer.connect(func() -> void: continuations.append(true))

	menu.afficher_gagner_un_plateau()
	menu.afficher_fin_niveau()
	menu.afficher_fin_campagne()

	assert_eq(continuations, [])
	assert_eq(continuations, [])

func test_les_panneaux_de_score_sont_caches_au_depart() -> void:
	var menu := _messages()

	assert_false(menu.get_node("Centrer").visible)
	for nom in ["PanneauDefaite", "PanneauVictoirePlateau", "PanneauVictoireNiveau", "PanneauVictoireCampagne"]:
		assert_false(menu.get_node("Centrer/" + nom).visible, nom)

func test_afficher_plateau_invalide_n_affiche_rien() -> void:
	var menu := _messages()

	menu.afficher_plateau_invalide()

	assert_false(menu.get_node("Centrer").visible)

func test_afficher_abandonner_un_plateau_montre_le_panneau_de_defaite() -> void:
	var menu := _messages()

	menu.afficher_abandonner_un_plateau()

	assert_true(menu.get_node("Centrer").visible)
	assert_true(menu.get_node("Centrer/PanneauDefaite").visible)

func test_continuer_apres_defaite_masque_le_panneau_et_rend_la_main() -> void:
	var menu := _messages()
	var continuations: Array[bool] = []
	menu.score_continuer.connect(func() -> void: continuations.append(true))
	menu.afficher_abandonner_un_plateau()

	menu._on_panneau_defaite_continuer()

	assert_false(menu.get_node("Centrer").visible)
	assert_false(menu.get_node("Centrer/PanneauDefaite").visible)
	assert_eq(continuations, [true])

func test_continuer_apres_victoire_de_plateau_masque_le_panneau_et_rend_la_main() -> void:
	var menu := _messages()
	var continuations: Array[bool] = []
	menu.score_continuer.connect(func() -> void: continuations.append(true))
	menu.afficher_detail_score(_detail_plateau())

	menu._on_panneau_victoire_plateau_continuer()

	assert_false(menu.get_node("Centrer").visible)
	assert_false(menu.get_node("Centrer/PanneauVictoirePlateau").visible)
	assert_eq(continuations, [true])

func test_les_boutons_continuer_des_panneaux_declenchent_les_gestionnaires() -> void:
	var menu := _messages()
	var continuations: Array[bool] = []
	menu.score_continuer.connect(func() -> void: continuations.append(true))
	for nom in ["PanneauDefaite", "PanneauVictoirePlateau"]:
		var panneau: Control = menu.get_node("Centrer/" + nom)
		panneau.show()
		panneau._create_time_ms = Time.get_ticks_msec() - panneau.SEUIL_CLICK_BOUTON_EN_MS - 1
		panneau.get_node("Control/Bouton").emit_signal("pressed")

	assert_eq(continuations, [true, true])

func test_le_score_de_la_progression_est_affiche_par_le_menu() -> void:
	var menu := _messages()

	ProgressionCampagneService.detail_score_plateau.emit(_detail_plateau())

	assert_true(menu.get_node("Centrer").visible)
	assert_true(menu.get_node("Centrer/PanneauVictoirePlateau").visible)
	assert_eq(menu.get_node("Centrer/PanneauVictoirePlateau/ScorePoints/Points").text, "2.750")

func test_afficher_detail_score_choisit_le_panneau_selon_le_contenu() -> void:
	var menu := _messages()
	var plateau: Control = menu.get_node("Centrer/PanneauVictoirePlateau")
	var niveau: Control = menu.get_node("Centrer/PanneauVictoireNiveau")
	var campagne: Control = menu.get_node("Centrer/PanneauVictoireCampagne")

	menu.afficher_detail_score(_detail_plateau())
	assert_eq([plateau.visible, niveau.visible, campagne.visible], [true, false, false])

	plateau.hide()
	menu.afficher_detail_score(_detail_niveau())
	assert_eq([plateau.visible, niveau.visible, campagne.visible], [false, true, false])

	niveau.hide()
	menu.afficher_detail_score(_detail_campagne())
	assert_eq([plateau.visible, niveau.visible, campagne.visible], [false, false, true])

func test_detail_score_plateau_ecrit_points_temps_et_ratio() -> void:
	var menu := _messages()
	var panneau: Control = menu.get_node("Centrer/PanneauVictoirePlateau")

	menu.afficher_detail_score_plateau(_detail_plateau())

	assert_eq(panneau.get_node("ScorePoints/Points").text, "2.750")
	assert_eq(_texte(panneau, "Temps", 1), "Référence : 12s")
	assert_eq(_texte(panneau, "Temps", 2), "Recommencé : 8.5s")
	assert_eq(_texte(panneau, "Temps", 3), "Réalisé : 9.1s")
	assert_eq(_texte(panneau, "Temps", 4), "1.250 points")
	assert_eq(_texte(panneau, "Ratio", 1), "Réalisé : 80%")
	assert_eq(_texte(panneau, "Ratio", 2), "1.500 points")

func test_detail_score_niveau_ecrit_aussi_longueur_et_bonus() -> void:
	var menu := _messages()
	var panneau: Control = menu.get_node("Centrer/PanneauVictoireNiveau")

	menu.afficher_detail_score_niveau(_detail_niveau())

	assert_eq(panneau.get_node("ScorePoints/Points").text, "4.250")
	assert_eq(_texte(panneau, "Temps", 4), "1.250 points")
	assert_eq(_texte(panneau, "Ratio", 2), "1.500 points")
	assert_eq(_texte(panneau, "Niveau", 1), "Longueur: 3")
	assert_eq(_texte(panneau, "Niveau", 2), "1.000 points")
	assert_eq(_texte(panneau, "NiveauParfait", 1), "Bonus:  oui")
	assert_eq(_texte(panneau, "NiveauParfait", 2), "500 points")

func test_detail_score_campagne_ecrit_aussi_le_bonus_de_campagne() -> void:
	var menu := _messages()
	var panneau: Control = menu.get_node("Centrer/PanneauVictoireCampagne")

	menu.afficher_detail_score_campagne(_detail_campagne())

	assert_eq(panneau.get_node("ScorePoints/Points").text, "6.250")
	assert_eq(_texte(panneau, "Niveau", 1), "Longueur: 3")
	assert_eq(_texte(panneau, "NiveauParfait", 2), "500 points")
	assert_eq(_texte(panneau, "Campagne", 1), "2.000 points")
	assert_true(menu.get_node("Centrer").visible)

func test_lire_score_plateau_score_additionne_toutes_les_composantes() -> void:
	var menu := _messages()

	assert_eq(menu.lire_score_plateau_score({}), "0")
	assert_eq(menu.lire_score_plateau_score(_detail_plateau()), "2.750")
	assert_eq(menu.lire_score_plateau_score(_detail_niveau()), "4.250")
	assert_eq(menu.lire_score_plateau_score(_detail_campagne()), "6.250")

func test_lire_score_plateau_temps_arrondit_et_formate() -> void:
	var menu := _messages()

	assert_eq(menu.lire_score_plateau_temps({}), {"reference": "-", "recommence": "-", "realise": "-", "points": "0"})
	assert_eq(menu.lire_score_plateau_temps(_detail_plateau().get("duree")), {
		"reference": "12", "recommence": "8.5", "realise": "9.1", "points": "1.250"
	})

func test_lire_score_plateau_ratio_reussite_formate_les_points() -> void:
	var menu := _messages()

	assert_eq(menu.lire_score_plateau_ratio_reussite({}), {"ratio": "-", "points": "0"})
	assert_eq(menu.lire_score_plateau_ratio_reussite({"ratio": 80, "points": 1500}), {"ratio": "80", "points": "1.500"})

func test_lire_score_niveau_et_niveau_parfait_ont_des_valeurs_par_defaut() -> void:
	var menu := _messages()

	assert_eq(menu.lire_score_niveau({}), {"longueur": "-", "points": "0"})
	assert_eq(menu.lire_score_niveau({"longueur": 4, "points": 12345}), {"longueur": "4", "points": "12.345"})
	assert_eq(menu.lire_score_niveau_parfait({}), {"bonus": "-", "points": "0"})
	assert_eq(menu.lire_score_niveau_parfait({"bonus": "non", "points": 0}), {"bonus": "non", "points": "0"})

func test_lire_score_campagne_formate_les_points() -> void:
	var menu := _messages()

	assert_eq(menu.lire_score_campagne({}), "0")
	assert_eq(menu.lire_score_campagne({"points": 1234567}), "1.234.567")

func test_continuer_apres_victoire_de_campagne_ouvre_les_statistiques() -> void:
	var menu := _messages()
	var continuations: Array[bool] = []
	menu.score_continuer.connect(func() -> void: continuations.append(true))

	await menu._on_panneau_victoire_campagne_continuer()
	assert_false(menu.get_node("Centrer").visible)
	assert_eq(continuations, [true])
	assert_eq(await _scene_apres_changement(), SCENE_STATISTIQUES)

func test_continuer_apres_victoire_de_niveau_reprend_sans_afficher_un_partage() -> void:
	var menu := _messages()
	var continuations: Array[bool] = []
	menu.score_continuer.connect(func() -> void: continuations.append(true))
	var panneau_niveau: Control = menu.get_node("Centrer/PanneauVictoireNiveau")
	panneau_niveau.show()

	await menu._on_panneau_victoire_niveau_continuer()

	assert_false(panneau_niveau.visible)
	assert_false(menu.get_node("Centrer").visible)
	assert_eq(continuations, [true])

func test_le_bouton_statistiques_ouvre_l_ecran_de_statistiques() -> void:
	var menu := _messages()

	menu._on_bouton_statistiques_pressed()

	assert_eq(await _scene_apres_changement(), SCENE_STATISTIQUES)
