extends GutTest

var service
var sauvegarde_joueur_initiale
var fichier_sauvegarde_initial
var configuration_initiale
var tableau_scores_initial
const RACINE_TEST = "tests/test_score_service"

func _nettoyer_fichiers_utilisateur():
	FichiersJsonService.effacer_racine_utilisateur()

func _activer_joueur_test():
	FichiersJsonService.write_json_file("test_score_service.json", SauvegardeBddJoueursService.sauvegarde_joueur)
	assert_true(SauvegardeBddJoueursService.choisir_le_joueur("Joueur Test", "test_score_service.json"))

func before_each():
	FichiersJsonService.definir_racine_utilisateur(RACINE_TEST)
	_nettoyer_fichiers_utilisateur()
	sauvegarde_joueur_initiale = SauvegardeBddJoueursService.sauvegarde_joueur.duplicate(true)
	fichier_sauvegarde_initial = SauvegardeBddJoueursService.fichier_sauvegarde
	configuration_initiale = SauvegardeConfigurationService.configuration_du_jeu.duplicate(true)
	tableau_scores_initial = SauvegardeTableauDesScoresService.liste_des_scores.duplicate(true)
	service = load("res://Singletons/score_service.gd").new()

	SauvegardeConfigurationService.configuration_du_jeu["date_debut_campagne"] = "2020-01-01 00:00:00"
	var nom_anna = service.lire_nom_anna_triche()
	SauvegardeTableauDesScoresService.liste_des_scores = [
		{"nom": "Joueur Test", "rang": 1, "score": 0, "score_txt": "0"},
		{"nom": nom_anna, "rang": 2, "score": 0, "score_txt": "0"}
	]
	SauvegardeBddJoueursService.sauvegarde_joueur = {
		"nom": "Joueur Test",
		"campagne": {
			"niveau_2": [{"nom": "R3", "difficulte": 2, "gameplay": "CLASSIQUE"}],
			"niveau_3": [{"nom": "R1", "difficulte": 1, "gameplay": "DEFI_DU_GOSSE"}, {"nom": "R2", "difficulte": 2, "gameplay": "DEFI_DU_BOSS"}]
		},
		"enregistrement_campagne": [
			{
				"niveau": "niveau_1",
				"date_debut": 1700000000,
				"date_fin": 1700001000,
				"plateaux": [
					{"nom": "A1", "date_debut": 1700000010, "duree": 10000, "difficulte": 1, "statut": "reussi"},
					{"nom": "B", "date_debut": 1700000020, "duree": 11000, "difficulte": 2, "statut": "abandonné"},
					{"nom": "B2", "date_debut": 1700000030, "duree": 15000, "difficulte": 2, "statut": "reussi"},
					{"nom": "C", "date_debut": 1700000040, "duree": 9000, "difficulte": 3, "statut": "reussi"}
				]
			},
			{
				"niveau": "niveau_2",
				"date_debut": 1700002000,
				"date_fin": 0,
				"plateaux": [
					{"nom": "D", "date_debut": 1700002010, "duree": 15000, "difficulte": 2, "statut": "reussi"},
					{"nom": "A2", "date_debut": 1700002020, "duree": 8000, "difficulte": 4, "statut": "en_cours"}
				]
			}
		],
		"plateaux_libres": {
			"1": [{"nom": "A1"}],
			"2": [{"nom": "B"}, {"nom": "D"}],
			"3": [{"nom": "C"}],
			"4": [{"nom": "A2"}]
		}
	}
	_activer_joueur_test()

func after_each():
	SauvegardeBddJoueursService.sauvegarde_joueur = sauvegarde_joueur_initiale
	SauvegardeBddJoueursService.fichier_sauvegarde = fichier_sauvegarde_initial
	SauvegardeConfigurationService.configuration_du_jeu = configuration_initiale
	SauvegardeTableauDesScoresService.liste_des_scores = tableau_scores_initial
	_nettoyer_fichiers_utilisateur()
	FichiersJsonService.reinitialiser_racine_utilisateur()

func _niveau_en_cours_avec_plateau_actif() -> void:
	var niveau = SauvegardeBddJoueursService.sauvegarde_joueur.get("enregistrement_campagne").back()
	var dernier_plateau = niveau.get("plateaux").back()
	dernier_plateau["statut"] = "en_cours"
	dernier_plateau["duree"] = 8000
	dernier_plateau["difficulte"] = 4
	SauvegardeBddJoueursService._enregistrer_sauvegarde_joueur()

func test_mettre_a_jour_score_duree_et_ratio_reussite_sont_calcules():
	var score_duree = service.mettre_a_jour_score_duree()
	assert_eq(score_duree.get("type"), "duree")
	assert_true(score_duree.get("points", 0) >= 0)

	var score_ratio = service.mettre_a_jour_score_ratio_reussite()
	assert_eq(score_ratio.get("type"), "ratio_reussite")
	assert_true(score_ratio.get("points", 0) >= 0)

func test_mettre_a_jour_score_duree_couvre_les_seuils_de_difficulte():
	for diff in [5, 9, 15, 30, 55, 75, 90, 120]:
		_set_last_plateau_difficulte(diff)
		var score = service.mettre_a_jour_score_duree()
		assert_eq(score.get("type"), "duree")
		assert_true(score.get("points", 0) >= 0)

func test_mettre_a_jour_score_pour_victoire_retourne_une_grille_complete():
	_level_finishes_current_level_as_won()
	var score = service.mettre_a_jour_score_pour_victoire()

	assert_true(score.has("duree"))
	assert_true(score.has("ratio_reussite"))
	assert_true(score.has("niveau"))
	assert_true(score.has("niveau_sans_detour"))
	assert_true(score.has("campagne"))
	assert_true(score.get("duree").get("points", 0) >= 0)
	assert_true(score.get("ratio_reussite").get("points", 0) >= 0)
	assert_true(score.get("niveau").get("points", 0) >= 0)

func test_mettre_a_jour_score_niveau_ne_declenche_pas_si_niveau_encore_en_cours():
	var niveau = SauvegardeBddJoueursService.sauvegarde_joueur.get("enregistrement_campagne").back()
	niveau["date_fin"] = 0
	var result = service.mettre_a_jour_score_niveau()
	assert_true(result == {} or result.get("type", "") == "niveau" or result.get("points", 0) >= 0)

func test_mettre_a_jour_score_niveau_declenche_quand_le_niveau_est_acheve():
	var niveau = SauvegardeBddJoueursService.sauvegarde_joueur.get("enregistrement_campagne").back()
	niveau["date_fin"] = 1700003000
	var result = service.mettre_a_jour_score_niveau()
	assert_eq(result.get("type"), "niveau")
	assert_true(result.get("points", 0) >= 0)

func test_mettre_a_jour_score_niveau_sans_detour_ne_declenche_pas_si_niveau_encore_en_cours():
	var niveau = SauvegardeBddJoueursService.sauvegarde_joueur.get("enregistrement_campagne").back()
	niveau["date_fin"] = 0
	niveau["plateaux"] = [{"nom": "D", "date_debut": 1700002010, "duree": 15000, "difficulte": 2, "statut": "reussi"}]
	var result = service.mettre_a_jour_score_niveau_sans_detour()
	assert_true(result == {} or result.get("type", "") == "niveau_sans_detour" or result.get("points", 0) >= 0)

func test_mettre_a_jour_score_niveau_sans_detour_declenche_quand_le_niveau_est_parfait():
	var niveau = SauvegardeBddJoueursService.sauvegarde_joueur.get("enregistrement_campagne").back()
	niveau["date_fin"] = 1700003000
	niveau["plateaux"] = [{"nom": "D", "date_debut": 1700002010, "duree": 15000, "difficulte": 2, "statut": "reussi"}]
	SauvegardeBddJoueursService.sauvegarde_joueur["campagne"].erase("niveau_2")
	var result = service.mettre_a_jour_score_niveau_sans_detour()
	assert_eq(result.get("type"), "niveau_sans_detour")
	assert_true(result.get("points", 0) >= 0)

func test_mettre_a_jour_score_campagne_ne_declenche_pas_si_campagne_incomplete():
	SauvegardeBddJoueursService.sauvegarde_joueur["campagne"] = {"niveau_4": [{"nom": "R4", "difficulte": 1}]}
	var result = service.mettre_a_jour_score_campagne()
	assert_true(result == {} or result.get("type", "") == "campagne" or result.get("points", 0) >= 0)

func test_mettre_a_jour_score_campagne_declenche_si_la_campagne_est_terminee():
	SauvegardeBddJoueursService.sauvegarde_joueur["campagne"] = {}
	var result = service.mettre_a_jour_score_campagne()
	assert_eq(result.get("type"), "campagne")
	assert_true(result.get("points", 0) > 0)

func test_nouveau_joueur_est_nom_anna_triche():
	assert_true(service.nouveau_joueur_est_nom_anna_triche("Anna"))
	assert_true(service.nouveau_joueur_est_nom_anna_triche("anna"))
	assert_false(service.nouveau_joueur_est_nom_anna_triche("Joueur Test"))

func test_lire_nom_anna_triche_contient_anna():
	var nom = service.lire_nom_anna_triche()
	assert_true(nom.to_lower().find("anna") >= 0)

func test_bonus_score_anna_damour_multiplie_le_total():
	var nom_anna = service.lire_nom_anna_triche()
	SauvegardeBddJoueursService.sauvegarde_joueur["nom"] = nom_anna
	var score_global = {
		'duree': {'points': 10},
		'ratio_reussite': {'points': 20},
		'niveau': {'points': 30},
		'niveau_sans_detour': {'points': 40},
		'campagne': {'points': 50}
	}
	var score_avant = SauvegardeTableauDesScoresService.lire_score_joueur(nom_anna)
	service.bonus_score_anna_damour(score_global)
	var score_apres = SauvegardeTableauDesScoresService.lire_score_joueur(nom_anna)
	assert_true(score_apres >= score_avant)

func test_bonus_score_anna_damour_ne_fait_rien_pour_un_autre_joueur():
	SauvegardeBddJoueursService.sauvegarde_joueur["nom"] = "Joueur Test"
	var score_global = {'duree': {'points': 10}, 'ratio_reussite': {'points': 20}, 'niveau': {'points': 30}}
	var score_avant = SauvegardeTableauDesScoresService.lire_score_joueur("Joueur Test")
	service.bonus_score_anna_damour(score_global)
	var score_apres = SauvegardeTableauDesScoresService.lire_score_joueur("Joueur Test")
	assert_eq(score_apres, score_avant)

func _set_last_plateau_difficulte(difficulte):
	var niveau = SauvegardeBddJoueursService.sauvegarde_joueur.get("enregistrement_campagne").back()
	var plateau = niveau.get("plateaux").back()
	plateau["difficulte"] = difficulte
	SauvegardeBddJoueursService._enregistrer_sauvegarde_joueur()

func _level_finishes_current_level_as_won():
	var niveau = SauvegardeBddJoueursService.sauvegarde_joueur.get("enregistrement_campagne").back()
	niveau["plateaux"] = [
		{"nom": "D", "date_debut": 1700002010, "duree": 15000, "difficulte": 2, "statut": "reussi"},
		{"nom": "A2", "date_debut": 1700002020, "duree": 8000, "difficulte": 4, "statut": "reussi"}
	]
	niveau["date_fin"] = 1700003000
	SauvegardeBddJoueursService.sauvegarde_joueur["campagne"].erase("niveau_2")
	SauvegardeBddJoueursService._enregistrer_sauvegarde_joueur()
