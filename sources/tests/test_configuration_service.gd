extends GutTest

var service
const RACINE_TEST = "tests/test_configuration_service"

var configuration_initiale
var liste_joueurs_initiale
var tableau_scores_initial
var sauvegarde_joueur_initiale
var fichier_sauvegarde_initial

func _nettoyer_fichiers_utilisateur() -> void:
	FichiersJsonService.effacer_racine_utilisateur()

func _lire_configuration_fichier():
	return FichiersJsonService.read_json_file("configuration_du_jeu.json")

func _configuration_par_defaut() -> Dictionary:
	return {
		"version": "V1.0.0-rc1",
		"date_debut_campagne": "2026-10-01 00:00:00",
		"musiques": true,
		"effets sonores": true,
		"vibrations": true
	}

func _creer_service(configuration = null):
	_nettoyer_fichiers_utilisateur()
	if configuration != null:
		FichiersJsonService.write_json_file("configuration_du_jeu.json", configuration)
	service = add_child_autofree(load("res://Singletons/Sauvegarde/configuration_service.gd").new())
	return service

func before_each():
	FichiersJsonService.definir_racine_utilisateur(RACINE_TEST)
	configuration_initiale = SauvegardeConfigurationService.configuration_du_jeu.duplicate(true)
	liste_joueurs_initiale = SauvegardeListeJoueursService.liste_des_joueurs.duplicate(true)
	tableau_scores_initial = SauvegardeTableauDesScoresService.liste_des_scores.duplicate(true)
	sauvegarde_joueur_initiale = SauvegardeBddJoueursService.sauvegarde_joueur.duplicate(true)
	fichier_sauvegarde_initial = SauvegardeBddJoueursService.fichier_sauvegarde
	_nettoyer_fichiers_utilisateur()

func after_each():
	SauvegardeConfigurationService.configuration_du_jeu = configuration_initiale.duplicate(true)
	SauvegardeListeJoueursService.liste_des_joueurs = liste_joueurs_initiale.duplicate(true)
	SauvegardeTableauDesScoresService.liste_des_scores = tableau_scores_initial.duplicate(true)
	SauvegardeBddJoueursService.sauvegarde_joueur = sauvegarde_joueur_initiale.duplicate(true)
	SauvegardeBddJoueursService.fichier_sauvegarde = fichier_sauvegarde_initial
	_nettoyer_fichiers_utilisateur()
	FichiersJsonService.reinitialiser_racine_utilisateur()

func test_ready_cree_le_fichier_initial_et_supprime_la_sauvegarde_obsolete():
	FichiersJsonService.write_json_file("sauvegarde.json", {"obsolete": true})

	_creer_service()

	assert_true(FichiersJsonService.json_file_exists("configuration_du_jeu.json"))
	assert_false(FichiersJsonService.json_file_exists("sauvegarde.json"))
	assert_eq(service.configuration_du_jeu, _configuration_par_defaut())
	assert_eq(_lire_configuration_fichier(), _configuration_par_defaut())

func test_ready_charge_les_preferences_utilisateur_mais_garde_les_parametres_usine():
	var configuration = {
		"version": "V0.1.0",
		"date_debut_campagne": "2020-01-01 00:00:00",
		"musiques": false,
		"effets sonores": true,
		"vibrations": false
	}

	_creer_service(configuration)

	assert_eq(service.lire_la_version(), _configuration_par_defaut().get("version"))
	assert_false(service.musiques_sont_actives())
	assert_true(service.effets_sonores_sont_actifs())
	assert_false(service.vibrations_sont_actives())
	assert_eq(service.lire_la_date_debut_campagne_timestamp(), int(Time.get_unix_time_from_datetime_string(_configuration_par_defaut().get("date_debut_campagne"))))

func test_ready_convertit_une_ancienne_version_et_reinitialise_campagne_et_scores():
	SauvegardeListeJoueursService.liste_des_joueurs = [
		{"indice": 0, "nom": "Alice", "fichier_sauvegarde": "test_configuration_joueur_00.json"}
	]
	SauvegardeTableauDesScoresService.liste_des_scores = [
		{"nom": "Alice", "rang": 1, "score": 999, "score_txt": "999"}
	]
	FichiersJsonService.write_json_file("test_configuration_joueur_00.json", {
		"nom": "Alice",
		"campagne": {"niveau_99": [{"nom": "Ancien", "difficulte": 9, "gameplay": "CLASSIQUE"}]},
		"enregistrement_campagne": [],
		"plateaux_libres": {},
		"nombre_de_parties": {}
	})
	var ancienne_configuration = {
		"version": "V0.4.0.beta7",
		"date_debut_campagne": "2020-01-01 00:00:00",
		"musiques": false,
		"effets sonores": false,
		"vibrations": false
	}
	FichiersJsonService.write_json_file("configuration_du_jeu.json", ancienne_configuration)
	service = add_child_autofree(load("res://Singletons/Sauvegarde/configuration_service.gd").new())

	assert_eq(service.lire_la_version(), "V1.0.0-rc1")
	assert_false(service.musiques_sont_actives())
	assert_false(service.effets_sonores_sont_actifs())
	assert_false(service.vibrations_sont_actives())

	assert_true(SauvegardeBddJoueursService._lire_sauvegarde_joueur("test_configuration_joueur_00.json"))
	assert_true(SauvegardeBddJoueursService.sauvegarde_joueur.get("campagne") != {"niveau_99": [{"nom": "Ancien", "difficulte": 9, "gameplay": "CLASSIQUE"}]})
	assert_eq(int(SauvegardeTableauDesScoresService.lire_score_joueur("Alice")), 0)
	assert_eq(SauvegardeTableauDesScoresService.lire_score_txt_joueur("Alice"), "0")

func test_lecteurs_retournent_les_defauts_quand_les_cles_sont_absentes():
	_creer_service()
	service.configuration_du_jeu = {"date_debut_campagne": "2020-01-01 00:00:00"}

	assert_true(service.musiques_sont_actives())
	assert_true(service.effets_sonores_sont_actifs())
	assert_true(service.vibrations_sont_actives())
	assert_eq(service.lire_la_version(), "?")
	assert_eq(service.lire_la_date_debut_campagne_timestamp(), int(Time.get_unix_time_from_datetime_string("2020-01-01 00:00:00")))

func _verifier_bascule(option: String, activer_methode: String, desactiver_methode: String, getter_methode: String) -> void:
	service.configuration_du_jeu = _configuration_par_defaut()
	service.configuration_du_jeu[option] = false
	service.call(activer_methode)
	assert_true(service.call(getter_methode))
	assert_true(_lire_configuration_fichier().get(option))
	service.call(activer_methode)
	assert_true(service.call(getter_methode))
	assert_true(_lire_configuration_fichier().get(option))

	service.configuration_du_jeu[option] = true
	service.call(desactiver_methode)
	assert_false(service.call(getter_methode))
	assert_false(_lire_configuration_fichier().get(option))
	service.call(desactiver_methode)
	assert_false(service.call(getter_methode))
	assert_false(_lire_configuration_fichier().get(option))

func test_bascule_des_musiques_couvre_activation_et_desactivation():
	_creer_service()
	_verifier_bascule("musiques", "activer_musiques", "desactiver_musiques", "musiques_sont_actives")

func test_bascule_des_effets_sonores_couvre_activation_et_desactivation():
	_creer_service()
	_verifier_bascule("effets sonores", "activer_effets_sonores", "desactiver_effets_sonores", "effets_sonores_sont_actifs")

func test_bascule_des_vibrations_couvre_activation_et_desactivation():
	_creer_service()
	_verifier_bascule("vibrations", "activer_vibrations", "desactiver_vibrations", "vibrations_sont_actives")
