extends GutTest

const DOSSIER := "res://Scenes/MenuPrincipal/Campagne/Statistiques/"
const SCENE_STATISTIQUES = preload(DOSSIER + "statistiques.tscn")
const SCENE_CARTE_SCORE = preload(DOSSIER + "carte_score.tscn")
const SCENE_CARTE_CAMPAGNE = preload(DOSSIER + "carte_campagne.tscn")
const SCENE_CARTE_NIVEAU = preload(DOSSIER + "carte_niveau.tscn")
const SCENE_CARTE_MODE = preload(DOSSIER + "carte_mode.tscn")
const SCENE_CARTE_PLATEAU = preload(DOSSIER + "carte_plateau.tscn")
const RACINE_TEST := "tests/test_statistiques_ui"
const ICONES := "res://Art/UI/icons/grades/"

var sauvegarde_joueur_initiale: Dictionary
var fichier_sauvegarde_initial: String
var configuration_initiale: Dictionary
var liste_des_scores_initiale: Array

func _donnees_joueur() -> Dictionary:
	return {
		"nom": "Joueur Test",
		"nom_campagne": "campagne_test",
		"campagne": {
			"niveau_2": [{"nom": "R3", "difficulte": 2}],
			"niveau_3": [{"nom": "R1", "difficulte": 1}, {"nom": "R2", "difficulte": 2}]
		},
		"enregistrement_campagne": [{
			"campagne": "campagne_test",
			"date_debut": 1700000000,
			"date_fin": 0,
			"score": {"niveau": 20, "niveau_parfait": 0},
			"niveaux": [
				{
					"niveau": "niveau_1",
					"date_debut": 1700000000,
					"date_fin": 1700001000,
					"score": {"niveau": 100, "niveau_parfait": 50},
					"plateaux": [
						{"nom": "A1", "date_debut": 1700000010, "date_fin": 1700000020, "duree": 10, "difficulte": 1, "statut": "reussi", "gameplay": "CLASSIQUE", "score": {"duree": 20, "ratio_reussite": 80}},
						{"nom": "B", "date_debut": 1700000020, "date_fin": 1700000031, "duree": 11, "difficulte": 2, "statut": "abandonné", "gameplay": "QUI_PERD_GAGNE", "score": {"duree": 5, "ratio_reussite": 10}},
						{"nom": "B", "date_debut": 1700000030, "date_fin": 1700000045, "duree": 15, "difficulte": 2, "statut": "reussi", "gameplay": "QUI_PERD_GAGNE", "score": {"duree": 30, "ratio_reussite": 90}},
						{"nom": "C", "date_debut": 1700000040, "date_fin": 1700000049, "duree": 9, "difficulte": 3, "statut": "reussi", "gameplay": "CLASSIQUE", "score": {"duree": 15, "ratio_reussite": 70}}
					]
				},
				{
					"niveau": "niveau_2",
					"date_debut": 1700002000,
					"date_fin": 0,
					"score": {"niveau": 20, "niveau_parfait": 0},
					"plateaux": [
						{"nom": "D", "date_debut": 1700002010, "date_fin": 1700002025, "duree": 15, "difficulte": 2, "statut": "reussi", "gameplay": "CLASSIQUE", "score": {"duree": 25, "ratio_reussite": 85}},
						{"nom": "A2", "date_debut": 1700002020, "date_fin": 1700002028, "duree": 8, "difficulte": 4, "statut": "reussi", "gameplay": "QUI_PERD_GAGNE", "score": {"duree": 40, "ratio_reussite": 95}}
					]
				}
			]
		}],
		"plateaux_libres": {}
	}

func _activer_joueur(donnees: Dictionary) -> void:
	SauvegardeBddJoueursService._sauvegarde_joueur = donnees
	FichiersJsonService.write_json_file("test_statistiques_ui.json", donnees)
	assert_true(SauvegardeBddJoueursService.choisir_le_joueur("Joueur Test", "test_statistiques_ui.json"))

func before_each() -> void:
	FichiersJsonService.definir_racine_utilisateur(RACINE_TEST)
	FichiersJsonService.effacer_racine_utilisateur()
	sauvegarde_joueur_initiale = SauvegardeBddJoueursService._sauvegarde_joueur.duplicate(true)
	fichier_sauvegarde_initial = SauvegardeBddJoueursService.fichier_sauvegarde
	configuration_initiale = SauvegardeConfigurationService.configuration_du_jeu.duplicate(true)
	liste_des_scores_initiale = SauvegardeTableauDesScoresService.liste_des_scores.duplicate(true)
	SauvegardeConfigurationService.configuration_du_jeu["date_debut_campagne"] = "2020-01-01 00:00:00"
	SauvegardeTableauDesScoresService.liste_des_scores = [
		{"nom": "Joueur Test", "rang": 1, "score": 1000, "score_txt": "1.000"}
	]
	_activer_joueur(_donnees_joueur())

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

func _ecran() -> Control:
	return add_child_autofree(SCENE_STATISTIQUES.instantiate())

func _valeur(ecran: Node, chemin: String) -> String:
	return ecran.get_node("Scroll/Content/" + chemin).text

# ------------------------------------------------------------------
# Formateurs

func test_pourcentage_une_decimale_sous_dix_pour_cent() -> void:
	var ecran := _ecran()

	assert_eq(ecran.str_arrondir_pourcentage(0.0), "0.0%")
	assert_eq(ecran.str_arrondir_pourcentage(0.05), "5.0%")
	assert_eq(ecran.str_arrondir_pourcentage(0.034), "3.4%")

func test_pourcentage_sans_decimale_a_partir_de_dix_pour_cent() -> void:
	var ecran := _ecran()

	assert_eq(ecran.str_arrondir_pourcentage(0.1), "10%")
	assert_eq(ecran.str_arrondir_pourcentage(0.625), "63%")
	assert_eq(ecran.str_arrondir_pourcentage(0.8333), "83%")
	assert_eq(ecran.str_arrondir_pourcentage(1.0), "100%")

func test_temps_en_millisecondes_sous_une_seconde() -> void:
	var ecran := _ecran()

	assert_eq(ecran.str_arrondir_temps_en_s(0.0), "0ms")
	assert_eq(ecran.str_arrondir_temps_en_s(0.5), "500ms")
	assert_eq(ecran.str_arrondir_temps_en_s(0.1234), "123ms")

func test_temps_en_secondes_avec_une_decimale_sous_dix_secondes() -> void:
	var ecran := _ecran()

	assert_eq(ecran.str_arrondir_temps_en_s(1.0), "1.0s")
	assert_eq(ecran.str_arrondir_temps_en_s(2.26), "2.3s")
	assert_eq(ecran.str_arrondir_temps_en_s(9.4), "9.4s")

func test_temps_en_secondes_entieres_sous_une_minute() -> void:
	var ecran := _ecran()

	assert_eq(ecran.str_arrondir_temps_en_s(10.0), "10s")
	assert_eq(ecran.str_arrondir_temps_en_s(11.4), "11s")
	assert_eq(ecran.str_arrondir_temps_en_s(59.0), "59s")

func test_temps_en_minutes_et_secondes_sous_une_heure() -> void:
	var ecran := _ecran()

	assert_eq(ecran.str_arrondir_temps_en_s(60.0), "1min 0s")
	assert_eq(ecran.str_arrondir_temps_en_s(68.0), "1min 8s")
	assert_eq(ecran.str_arrondir_temps_en_s(125.4), "2min 5s")
	assert_eq(ecran.str_arrondir_temps_en_s(3599.0), "59min 59s")

func test_temps_en_heures_et_minutes_a_partir_d_une_heure() -> void:
	var ecran := _ecran()

	assert_eq(ecran.str_arrondir_temps_en_s(3600.0), "1h 0min")
	assert_eq(ecran.str_arrondir_temps_en_s(3725.0), "1h 2min")
	assert_eq(ecran.str_arrondir_temps_en_s(86400.0), "24h 0min")

func test_temps_arrondi_ne_deborde_pas_sur_soixante_secondes() -> void:
	var ecran := _ecran()

	assert_eq(ecran.str_arrondir_temps_en_s(119.6), "2min 0s")
	assert_eq(ecran.str_arrondir_temps_en_s(3599.6), "1h 0min")

# ------------------------------------------------------------------
# Cartes

func test_carte_score_ecrit_chaque_indicateur() -> void:
	var carte: Control = add_child_autofree(SCENE_CARTE_SCORE.instantiate())

	carte.nom_grade("Bronze")
	carte.nom_joueur("Alice")
	carte.score("1 234")
	carte.rapidite("12%")
	carte.reussite("34%")
	carte.niveau("56%")
	carte.parfait("7.8%")
	carte.campagne("90%")

	assert_eq(carte.get_node("GradeIdentite/NomGrade").text, "Bronze")
	assert_eq(carte.get_node("GradeIdentite/PlayerName").text, "Alice")
	assert_eq(carte.get_node("Score/Valeur").text, "1 234")
	assert_eq(carte.get_node("Rapidite/Valeur").text, "12%")
	assert_eq(carte.get_node("Reussite/Valeur").text, "34%")
	assert_eq(carte.get_node("Niveau/Valeur").text, "56%")
	assert_eq(carte.get_node("Parfait/Valeur").text, "7.8%")
	assert_eq(carte.get_node("Campagne/Valeur").text, "90%")

func test_carte_score_choisit_la_medaille_selon_le_grade() -> void:
	var carte: Control = add_child_autofree(SCENE_CARTE_SCORE.instantiate())

	for grade in ["bronze", "argent", "or", "diamant"]:
		carte.medaille(grade)
		assert_eq(carte.get_node("GradeIdentite/Medaille").texture.resource_path, ICONES + "medaille_%s_48.png" % grade)

func test_carte_score_ignore_la_casse_du_grade() -> void:
	var carte: Control = add_child_autofree(SCENE_CARTE_SCORE.instantiate())

	carte.medaille("DIAMANT")

	assert_eq(carte.get_node("GradeIdentite/Medaille").texture.resource_path, ICONES + "medaille_diamant_48.png")

func test_carte_score_conserve_la_medaille_pour_un_grade_inconnu() -> void:
	var carte: Control = add_child_autofree(SCENE_CARTE_SCORE.instantiate())
	carte.medaille("or")
	var texture_or = carte.get_node("GradeIdentite/Medaille").texture

	carte.medaille("platine")

	assert_eq(carte.get_node("GradeIdentite/Medaille").texture, texture_or)

func test_carte_campagne_ecrit_chaque_indicateur() -> void:
	var carte: Control = add_child_autofree(SCENE_CARTE_CAMPAGNE.instantiate())

	carte.completion("63%")
	carte.temps("1min 8s")
	carte.serie_max("4")
	carte.reussite("83%")

	assert_eq(carte.get_node("Completion/Valeur").text, "63%")
	assert_eq(carte.get_node("Temps/Valeur").text, "1min 8s")
	assert_eq(carte.get_node("SerieMax/Valeur").text, "4")
	assert_eq(carte.get_node("Reussite/Valeur").text, "83%")

func test_carte_niveau_ecrit_chaque_indicateur() -> void:
	var carte: Control = add_child_autofree(SCENE_CARTE_NIVEAU.instantiate())

	carte.en_cours("2")
	carte.completion("67%")
	carte.taux_reussite_minimum("75%")
	carte.difficulte_reussite_minimum("1")
	carte.taux_reussite_maximum("100%")
	carte.difficulte_reussite_maximum("2")

	assert_eq(carte.get_node("EnCours/Valeur").text, "2")
	assert_eq(carte.get_node("Completion/Valeur").text, "67%")
	assert_eq(carte.get_node("Tableau/ReussiteMinimum/Pourcent").text, "75%")
	assert_eq(carte.get_node("Tableau/ReussiteMinimum/Difficulte").text, "1")
	assert_eq(carte.get_node("Tableau/ReussiteMaximum/Pourcent").text, "100%")
	assert_eq(carte.get_node("Tableau/ReussiteMaximum/Difficulte").text, "2")

func _verifier_carte_de_plateaux(carte: Control) -> void:
	carte.nb_plateaux("6")
	carte.nb_essais("8")
	carte.temps_moyen("11s")
	carte.taux_reussite("83%")
	carte.plus_rapide_temps("8.0s")
	carte.plus_rapide_difficulte("4")
	carte.plus_lent_temps("15s")
	carte.plus_lent_difficulte("2")
	carte.plus_galere_essais("3")
	carte.plus_galere_difficulte("5")

	assert_eq(carte.get_node("Nombre/Valeur").text, "6")
	assert_eq(carte.get_node("Essais/Valeur").text, "8")
	assert_eq(carte.get_node("TempsMoyen/Valeur").text, "11s")
	assert_eq(carte.get_node("Reussite/Valeur").text, "83%")
	assert_eq(carte.get_node("Tableau/PlusRapide/Temps").text, "8.0s")
	assert_eq(carte.get_node("Tableau/PlusRapide/Difficulte").text, "4")
	assert_eq(carte.get_node("Tableau/PlusLent/Temps").text, "15s")
	assert_eq(carte.get_node("Tableau/PlusLent/Difficulte").text, "2")
	assert_eq(carte.get_node("Tableau/PlusGalere/Essais").text, "3")
	assert_eq(carte.get_node("Tableau/PlusGalere/Difficulte").text, "5")

func test_carte_plateau_ecrit_chaque_indicateur() -> void:
	_verifier_carte_de_plateaux(add_child_autofree(SCENE_CARTE_PLATEAU.instantiate()))

func test_carte_mode_ecrit_chaque_indicateur() -> void:
	_verifier_carte_de_plateaux(add_child_autofree(SCENE_CARTE_MODE.instantiate()))

func test_carte_mode_applique_le_titre_avant_et_apres_ready() -> void:
	var carte: Control = SCENE_CARTE_MODE.instantiate()
	carte.titre("Classique")
	add_child_autofree(carte)
	assert_eq(carte.get_node("Titre").text, "Classique")

	carte.titre("Qui perd gagne")
	assert_eq(carte.get_node("Titre").text, "Qui perd gagne")
	assert_eq(carte._titre, "Qui perd gagne")

# ------------------------------------------------------------------
# Écran

func test_l_ecran_affiche_le_score_du_joueur() -> void:
	var ecran := _ecran()

	assert_eq(_valeur(ecran, "Score/GradeIdentite/PlayerName"), "Joueur Test")
	assert_eq(_valeur(ecran, "Score/GradeIdentite/NomGrade"), "bronze")
	assert_eq(_valeur(ecran, "Score/Score/Valeur"), "735")

func test_l_ecran_separe_les_milliers_du_score_par_une_espace() -> void:
	var donnees := _donnees_joueur()
	donnees["enregistrement_campagne"][0]["niveaux"][0]["plateaux"][0]["score"]["ratio_reussite"] = 1500
	_activer_joueur(donnees)

	var ecran := _ecran()

	assert_eq(_valeur(ecran, "Score/Score/Valeur"), "2 155")

func test_l_ecran_affiche_les_pourcentages_du_score_arrondis() -> void:
	var ecran := _ecran()

	assert_eq(_valeur(ecran, "Score/Rapidite/Valeur"), ecran.str_arrondir_pourcentage(StatsService.score_pourcentage_rapidite()))
	assert_eq(_valeur(ecran, "Score/Reussite/Valeur"), ecran.str_arrondir_pourcentage(StatsService.score_pourcentage_reussite()))
	assert_eq(_valeur(ecran, "Score/Niveau/Valeur"), ecran.str_arrondir_pourcentage(StatsService.score_pourcentage_niveau()))
	assert_eq(_valeur(ecran, "Score/Parfait/Valeur"), ecran.str_arrondir_pourcentage(StatsService.score_pourcentage_niveau_parfait()))
	assert_eq(_valeur(ecran, "Score/Campagne/Valeur"), ecran.str_arrondir_pourcentage(StatsService.score_pourcentage_fin_campagne()))

func test_l_ecran_affiche_les_statistiques_de_campagne() -> void:
	var ecran := _ecran()

	assert_eq(_valeur(ecran, "Campagne/Completion/Valeur"), "63%")
	assert_eq(_valeur(ecran, "Campagne/Temps/Valeur"), "1min 8s")
	assert_eq(_valeur(ecran, "Campagne/Reussite/Valeur"), "83%")
	assert_eq(_valeur(ecran, "Campagne/SerieMax/Valeur"), "4")

func test_l_ecran_affiche_les_statistiques_de_niveau() -> void:
	var ecran := _ecran()
	var infos: Dictionary = StatsService.niveau_taux_reussite_infos()

	assert_eq(_valeur(ecran, "Niveau/EnCours/Valeur"), "2")
	assert_eq(_valeur(ecran, "Niveau/Completion/Valeur"), "67%")
	assert_eq(_valeur(ecran, "Niveau/Tableau/ReussiteMinimum/Pourcent"), "75%")
	assert_eq(_valeur(ecran, "Niveau/Tableau/ReussiteMinimum/Difficulte"), str(infos.get("taux_min_niveau")))
	assert_eq(_valeur(ecran, "Niveau/Tableau/ReussiteMaximum/Pourcent"), "100%")
	assert_eq(_valeur(ecran, "Niveau/Tableau/ReussiteMaximum/Difficulte"), str(infos.get("taux_max_niveau")))

func test_l_ecran_affiche_les_statistiques_de_tous_les_plateaux() -> void:
	var ecran := _ecran()

	# 5 plateaux joués (réussis) pour 6 essais (dont 1 abandonné) ; temps cumulé de tous les essais / plateaux réussis
	assert_eq(_valeur(ecran, "Plateau/Nombre/Valeur"), "5")
	assert_eq(_valeur(ecran, "Plateau/Essais/Valeur"), "6")
	assert_eq(_valeur(ecran, "Plateau/TempsMoyen/Valeur"), "14s")
	assert_eq(_valeur(ecran, "Plateau/Reussite/Valeur"), "83%")
	assert_eq(_valeur(ecran, "Plateau/Tableau/PlusRapide/Temps"), "8.0s")
	assert_eq(_valeur(ecran, "Plateau/Tableau/PlusRapide/Difficulte"), "4")
	assert_eq(_valeur(ecran, "Plateau/Tableau/PlusLent/Temps"), "26s")
	assert_eq(_valeur(ecran, "Plateau/Tableau/PlusLent/Difficulte"), "2")
	assert_eq(_valeur(ecran, "Plateau/Tableau/PlusGalere/Essais"), "2 essais")
	assert_eq(_valeur(ecran, "Plateau/Tableau/PlusGalere/Difficulte"), "2")

func test_l_ecran_affiche_les_statistiques_du_gameplay_classique() -> void:
	var ecran := _ecran()

	assert_eq(_valeur(ecran, "Classique/Nombre/Valeur"), "3")
	assert_eq(_valeur(ecran, "Classique/Essais/Valeur"), "3")
	assert_eq(_valeur(ecran, "Classique/TempsMoyen/Valeur"), "11s")
	assert_eq(_valeur(ecran, "Classique/Reussite/Valeur"), "100%")
	assert_eq(_valeur(ecran, "Classique/Tableau/PlusRapide/Temps"), "9.0s")
	assert_eq(_valeur(ecran, "Classique/Tableau/PlusRapide/Difficulte"), "3")
	assert_eq(_valeur(ecran, "Classique/Tableau/PlusLent/Temps"), "15s")
	assert_eq(_valeur(ecran, "Classique/Tableau/PlusLent/Difficulte"), "2")
	assert_eq(_valeur(ecran, "Classique/Tableau/PlusGalere/Essais"), "1 essai")
	assert_eq(_valeur(ecran, "Classique/Tableau/PlusGalere/Difficulte"), "1")

func test_l_ecran_affiche_les_statistiques_du_gameplay_qui_perd_gagne() -> void:
	var ecran := _ecran()

	assert_eq(_valeur(ecran, "QuiPerdGagne/Nombre/Valeur"), "2")
	assert_eq(_valeur(ecran, "QuiPerdGagne/Essais/Valeur"), "3")
	assert_eq(_valeur(ecran, "QuiPerdGagne/TempsMoyen/Valeur"), "17s")
	assert_eq(_valeur(ecran, "QuiPerdGagne/Reussite/Valeur"), "67%")
	assert_eq(_valeur(ecran, "QuiPerdGagne/Tableau/PlusRapide/Temps"), "8.0s")
	assert_eq(_valeur(ecran, "QuiPerdGagne/Tableau/PlusRapide/Difficulte"), "4")
	assert_eq(_valeur(ecran, "QuiPerdGagne/Tableau/PlusLent/Temps"), "26s")
	assert_eq(_valeur(ecran, "QuiPerdGagne/Tableau/PlusLent/Difficulte"), "2")
	assert_eq(_valeur(ecran, "QuiPerdGagne/Tableau/PlusGalere/Essais"), "2 essais")
	assert_eq(_valeur(ecran, "QuiPerdGagne/Tableau/PlusGalere/Difficulte"), "2")

func test_l_ecran_s_affiche_sans_enregistrement_de_campagne() -> void:
	var donnees := _donnees_joueur()
	donnees["enregistrement_campagne"] = []
	_activer_joueur(donnees)

	var ecran := _ecran()

	assert_eq(_valeur(ecran, "Niveau/EnCours/Valeur"), "0")
	assert_eq(_valeur(ecran, "Plateau/Nombre/Valeur"), "0")
	assert_eq(_valeur(ecran, "Plateau/Essais/Valeur"), "0")
	assert_eq(_valeur(ecran, "Plateau/Reussite/Valeur"), "0.0%")
	assert_eq(_valeur(ecran, "Campagne/SerieMax/Valeur"), "0")
	assert_eq(_valeur(ecran, "Classique/Nombre/Valeur"), "0")
	assert_eq(_valeur(ecran, "Classique/Essais/Valeur"), "0")
	assert_eq(_valeur(ecran, "QuiPerdGagne/Nombre/Valeur"), "0")
	assert_eq(_valeur(ecran, "QuiPerdGagne/Essais/Valeur"), "0")

func test_retour_ramene_au_menu_de_campagne_tant_que_la_campagne_n_est_pas_terminee() -> void:
	var ecran := _ecran()
	assert_false(ProgressionCampagneService.la_campagne_est_terminee())

	ecran.get_node("Scroll/Content/Retour").emit_signal("pressed")
	await wait_process_frames(3)

	assert_not_null(get_tree().current_scene)
	assert_eq(get_tree().current_scene.scene_file_path, "res://Scenes/MenuPrincipal/Campagne/campagne.tscn")

func test_retour_ramene_au_menu_principal_quand_la_campagne_est_terminee() -> void:
	var donnees := _donnees_joueur()
	donnees["campagne"] = {}
	_activer_joueur(donnees)
	var ecran := _ecran()
	assert_true(ProgressionCampagneService.la_campagne_est_terminee())

	ecran.get_node("Scroll/Content/Retour").emit_signal("pressed")
	await wait_process_frames(3)

	assert_not_null(get_tree().current_scene)
	assert_eq(get_tree().current_scene.scene_file_path, "res://Scenes/MenuPrincipal/menu_principal.tscn")
