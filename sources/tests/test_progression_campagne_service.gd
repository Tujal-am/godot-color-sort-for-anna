extends GutTest

var service
var initial_liste_joueurs
var initial_bdd_joueur
var initial_bdd_fichier
var initial_tableau_scores
const RACINE_TEST = "tests/test_progression_campagne_service"

var progression_emitted = false
var detail_score_received = null

func _nettoyer_fichiers_utilisateur():
	FichiersJsonService.effacer_racine_utilisateur()

func before_each():
	FichiersJsonService.definir_racine_utilisateur(RACINE_TEST)
	_nettoyer_fichiers_utilisateur()
	initial_liste_joueurs = SauvegardeListeJoueursService.liste_des_joueurs.duplicate(true)
	initial_bdd_joueur = SauvegardeBddJoueursService.sauvegarde_joueur.duplicate(true)
	initial_bdd_fichier = SauvegardeBddJoueursService.fichier_sauvegarde
	initial_tableau_scores = SauvegardeTableauDesScoresService.liste_des_scores.duplicate(true)
	service = add_child_autofree(load("res://Singletons/progression_campagne_service.gd").new())

	progression_emitted = false
	detail_score_received = null

	SauvegardeListeJoueursService.liste_des_joueurs = [
		{"indice": 0, "nom": "Alpha", "fichier_sauvegarde": "sauvegarde_joueur_alpha.json"},
		{"indice": 1, "nom": "Beta", "fichier_sauvegarde": "sauvegarde_joueur_beta.json"}
	]
	SauvegardeTableauDesScoresService.liste_des_scores = [
		{"nom": "Alpha", "rang": 1, "score": 0, "score_txt": "0"},
		{"nom": "Beta", "rang": 2, "score": 0, "score_txt": "0"}
	]
	SauvegardeBddJoueursService.fichier_sauvegarde = ""
	SauvegardeBddJoueursService.sauvegarde_joueur = {}

	var plateaux_niveau_1 = [
		{"nom": "Q1", "date_debut": 110, "duree": 1000, "difficulte": 1, "statut": "reussi"}
	]
	var plateaux_niveau_2 = [
		{"nom": "Q2", "date_debut": 510, "duree": 1500, "difficulte": 2, "statut": "en_cours"}
	]
	FichiersJsonService.write_json_file("sauvegarde_joueur_alpha.json", {
		"nom": "Alpha",
		"campagne": {
			"niveau_2": [{"nom": "P2", "difficulte": 2, "gameplay": "CLASSIQUE"}],
			"niveau_3": [{"nom": "P3", "difficulte": 3, "gameplay": "DEFI_DU_GOSSE"}]
		},
		"enregistrement_campagne": [
			{
				"niveau": "niveau_1",
				"date_debut": 100,
				"date_fin": 200,
				"plateaux": plateaux_niveau_1,
				"liste_plateaux": plateaux_niveau_1
			},
			{
				"niveau": "niveau_2",
				"date_debut": 500,
				"date_fin": 0,
				"plateaux": plateaux_niveau_2,
				"liste_plateaux": plateaux_niveau_2
			}
		],
		"plateaux_libres": {"1": [{"nom": "Externe"}]},
		"nombre_de_parties": {"2": 1}
	})
	FichiersJsonService.write_json_file("sauvegarde_joueur_beta.json", {
		"nom": "Beta",
		"campagne": {},
		"enregistrement_campagne": [],
		"plateaux_libres": {},
		"nombre_de_parties": {}
	})

	service.progression_niveau.connect(_on_progression_niveau)
	service.detail_score_plateau.connect(_on_detail_score_plateau)

func after_each():
	SauvegardeListeJoueursService.liste_des_joueurs = initial_liste_joueurs.duplicate(true)
	SauvegardeBddJoueursService.sauvegarde_joueur = initial_bdd_joueur.duplicate(true)
	SauvegardeBddJoueursService.fichier_sauvegarde = initial_bdd_fichier
	SauvegardeTableauDesScoresService.liste_des_scores = initial_tableau_scores.duplicate(true)
	_nettoyer_fichiers_utilisateur()
	FichiersJsonService.reinitialiser_racine_utilisateur()

func _on_progression_niveau():
	progression_emitted = true

func _on_detail_score_plateau(detail_score : Dictionary):
	detail_score_received = detail_score

func test_la_campagne_est_terminee_pour_joueur_renvoie_oui_si_vide():
	assert_true(service.la_campagne_est_terminee_pour_joueur("Beta"))
	assert_false(service.la_campagne_est_terminee_pour_joueur("Inconnu"))

func test_choisir_le_joueur_pour_la_campagne_charge_un_joueur_existant():
	assert_true(service.choisir_le_joueur_pour_la_campagne("Alpha"))
	assert_eq(SauvegardeBddJoueursService.lire_nom_joueur(), "Alpha")
	assert_eq(SauvegardeBddJoueursService.fichier_sauvegarde, "sauvegarde_joueur_alpha.json")

func test_choisir_et_corriger_le_joueur_supprime_un_joueur_orphelin():
	FichiersJsonService.write_json_file("sauvegarde_joueur_alpha.json", {"nom": "Autre", "campagne": {}, "enregistrement_campagne": [], "plateaux_libres": {}, "nombre_de_parties": {}})
	assert_false(service._choisir_et_corriger_le_joueur("Alpha"))
	assert_false(SauvegardeListeJoueursService.le_joueur_existe("Alpha"))

func test_liberer_le_joueur_pour_la_campagne_vides_la_sauvegarde_active():
	service.choisir_le_joueur_pour_la_campagne("Alpha")
	service.liberer_le_joueur_pour_la_campagne()
	assert_eq(SauvegardeBddJoueursService.fichier_sauvegarde, "")

func test_autoriser_le_nouveau_joueur_pour_la_campagne():
	assert_true(service.autoriser_le_nouveau_joueur_pour_la_campagne("Gamma"))
	assert_false(service.autoriser_le_nouveau_joueur_pour_la_campagne("Alpha"))

func test_initialiser_le_nouveau_joueur_pour_la_campagne_cree_le_compte():
	assert_true(service.initialiser_le_nouveau_joueur_pour_la_campagne("Gamma"))
	assert_true(SauvegardeListeJoueursService.le_joueur_existe("Gamma"))
	assert_true(SauvegardeTableauDesScoresService.le_joueur_existe("Gamma"))
	assert_eq(SauvegardeBddJoueursService.lire_nom_joueur(), "Gamma")

func test_niveau_en_cours_et_la_campagne_est_terminee_sont_coherents():
	service.choisir_le_joueur_pour_la_campagne("Alpha")
	assert_true(SauvegardeBddJoueursService.enregistrement_niveau_en_cours())
	assert_true(service.niveau_en_cours())
	assert_false(service.la_campagne_est_terminee())

	SauvegardeBddJoueursService.sauvegarde_joueur["campagne"] = {}
	assert_true(service.la_campagne_est_terminee())

func test_gagner_un_plateau_emet_les_signaux_et_maj_score():
	service.choisir_le_joueur_pour_la_campagne("Alpha")
	var score_before = SauvegardeTableauDesScoresService.lire_score_joueur("Alpha")
	service.gagner_un_plateau()
	assert_true(progression_emitted)
	assert_true(detail_score_received != null)
	assert_true(detail_score_received.has("duree"))
	assert_true(SauvegardeTableauDesScoresService.lire_score_joueur("Alpha") >= score_before)

func test_abandonner_un_plateau_ne_detruit_pas_la_campaign():
	service.choisir_le_joueur_pour_la_campagne("Alpha")
	var campagne_avant = SauvegardeBddJoueursService.sauvegarde_joueur.get("campagne").duplicate(true)
	service.abandonner_un_plateau()
	assert_eq(SauvegardeBddJoueursService.sauvegarde_joueur.get("campagne").keys().size(), campagne_avant.keys().size())

func test_afficher_niveau_plateau_parties_ne_crashe_pas():
	service.choisir_le_joueur_pour_la_campagne("Alpha")
	service.afficher_niveau_plateau_parties()
	assert_true(true)

func test_retourner_le_niveau_le_plus_bas_trouve_le_plus_bas_non_termine():
	FichiersJsonService.write_json_file("sauvegarde_joueur_alpha.json", {
		"nom": "Alpha",
		"campagne": {"niveau_2": [{"nom": "P2", "difficulte": 2, "gameplay": "CLASSIQUE"}]},
		"enregistrement_campagne": [],
		"plateaux_libres": {},
		"nombre_de_parties": {}
	})
	assert_true(service.choisir_le_joueur_pour_la_campagne("Alpha"))
	assert_eq(service.retourner_le_niveau_le_plus_bas(), 2)
