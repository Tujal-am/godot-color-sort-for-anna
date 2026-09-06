extends GutTest

var service
var sauvegarde_joueur_initiale
var fichier_sauvegarde_initial
var configuration_initiale
const RACINE_TEST = "tests/test_audio_service"

func _nettoyer_fichiers_utilisateur():
	FichiersJsonService.effacer_racine_utilisateur()

func _activer_joueur_test(reussis: int, restants: int) -> void:
	var plateaux_reussis = []
	for index in range(reussis):
		plateaux_reussis.append({
			"nom": "Plateau reussi %d" % index,
			"date_debut": 1700000010 + index,
			"duree": 1000,
			"difficulte": 1,
			"statut": "reussi"
		})

	var plateaux_restants = []
	for index in range(restants):
		plateaux_restants.append({
			"nom": "Plateau restant %d" % index,
			"difficulte": 1,
			"gameplay": "CLASSIQUE"
		})

	SauvegardeBddJoueursService.sauvegarde_joueur = {
		"nom": "Joueur Audio",
		"campagne": {
			"niveau_1": plateaux_restants
		},
		"enregistrement_campagne": [
			{
				"niveau": "niveau_1",
				"date_debut": 1700000000,
				"date_fin": 0,
				"plateaux": plateaux_reussis
			}
		],
		"plateaux_libres": {},
		"nombre_de_parties": {}
	}
	FichiersJsonService.write_json_file("test_audio_service.json", SauvegardeBddJoueursService.sauvegarde_joueur)
	assert_true(SauvegardeBddJoueursService.choisir_le_joueur("Joueur Audio", "test_audio_service.json"))

func before_each():
	FichiersJsonService.definir_racine_utilisateur(RACINE_TEST)
	_nettoyer_fichiers_utilisateur()
	sauvegarde_joueur_initiale = SauvegardeBddJoueursService.sauvegarde_joueur.duplicate(true)
	fichier_sauvegarde_initial = SauvegardeBddJoueursService.fichier_sauvegarde
	configuration_initiale = SauvegardeConfigurationService.configuration_du_jeu.duplicate(true)

	SauvegardeConfigurationService.configuration_du_jeu["date_debut_campagne"] = "2020-01-01 00:00:00"
	SauvegardeConfigurationService.configuration_du_jeu["musiques"] = true
	SauvegardeConfigurationService.configuration_du_jeu["effets sonores"] = true
	_activer_joueur_test(1, 5)

	service = add_child_autofree(load("res://Singletons/audio_service.gd").new())

func after_each():
	SauvegardeBddJoueursService.sauvegarde_joueur = sauvegarde_joueur_initiale
	SauvegardeBddJoueursService.fichier_sauvegarde = fichier_sauvegarde_initial
	SauvegardeConfigurationService.configuration_du_jeu = configuration_initiale
	_nettoyer_fichiers_utilisateur()
	FichiersJsonService.reinitialiser_racine_utilisateur()

func test_ready_initialise_les_players_audio():
	assert_true(service.musique != null)
	assert_true(service.effet_sonore != null)
	assert_eq(service.get_child_count(), 2)

func test_jouer_la_musique_ne_joue_rien_si_les_musiques_sont_desactivees():
	SauvegardeConfigurationService.configuration_du_jeu["musiques"] = false
	service.musique.stream = null
	service.jouer_la_musique()
	assert_eq(service.musique.stream, null)

func test_jouer_la_musique_choisit_la_bonne_piste_selon_la_progression_du_niveau():
	var cas = [
		{"reussis": 0, "restants": 6, "musique": service.MUSIQUE_DREAMING},
		{"reussis": 1, "restants": 5, "musique": service.MUSIQUE_DREAMING},
		{"reussis": 2, "restants": 4, "musique": service.MUSIQUE_SU_TURNO},
		{"reussis": 3, "restants": 3, "musique": service.MUSIQUE_THE_THREE_PRINCESSES_OF_LILAC_MEADOW},
		{"reussis": 4, "restants": 2, "musique": service.MUSIQUE_SOLVE_THE_PUZZLE},
		{"reussis": 5, "restants": 1, "musique": service.MUSIQUE_HUMBLE_MATCH},
		{"reussis": 6, "restants": 0, "musique": service.MUSIQUE_GREAT_LITTLE_CHALLENGE}
	]

	for cas_de_test in cas:
		_activer_joueur_test(cas_de_test.get("reussis"), cas_de_test.get("restants"))
		service.jouer_la_musique()
		assert_eq(service.musique.stream, cas_de_test.get("musique"))

func test_arreter_la_musique_stoppe_la_lecture_si_les_musiques_sont_actives():
	SauvegardeConfigurationService.configuration_du_jeu["musiques"] = true
	service._musique_play(service.MUSIQUE_DREAMING)
	assert_true(service.musique.playing)
	service.arreter_la_musique()
	assert_false(service.musique.playing)

func test_arreter_la_musique_ne_crashe_pas_si_les_musiques_sont_desactivees():
	SauvegardeConfigurationService.configuration_du_jeu["musiques"] = false
	service.musique.stream = null
	service.arreter_la_musique()
	assert_eq(service.musique.stream, null)
	assert_false(service.musique.playing)

func test_effets_sonores_jouent_le_bon_son_quand_ils_sont_actifs():
	var cas = [
		{"methode": "son_menu_click", "son": service.SON_MENU_CLICK},
		{"methode": "son_commencer_un_plateau", "son": service.SON_PARTIE_COMMENCER},
		{"methode": "son_abandonner_un_plateau", "son": service.SON_PARTIE_ECHEC},
		{"methode": "son_gagner_un_plateau", "son": service.SON_PARTIE_VICTOIRE},
		{"methode": "son_jeton_deplacer_debut", "son": service.SON_JETON_DEPLACER_DEBUT_SUCCES},
		{"methode": "son_jeton_deplacer_echec", "son": service.SON_JETON_DEPLACER_ECHEC},
		{"methode": "son_jeton_deplacer_succes", "son": service.SON_JETON_DEPLACER_DEBUT_SUCCES},
		{"methode": "son_jeton_deplacer_pile_pleine", "son": service.SON_JETON_DEPLACER_PLEINE}
	]

	SauvegardeConfigurationService.configuration_du_jeu["effets sonores"] = true
	for cas_de_test in cas:
		service.effet_sonore.stream = null
		service.call(cas_de_test.get("methode"))
		assert_eq(service.effet_sonore.stream, cas_de_test.get("son"))

func test_effets_sonores_ne_jouent_rien_quand_ils_sont_desactives():
	var methodes = [
		"son_menu_click",
		"son_commencer_un_plateau",
		"son_abandonner_un_plateau",
		"son_gagner_un_plateau",
		"son_jeton_deplacer_debut",
		"son_jeton_deplacer_echec",
		"son_jeton_deplacer_succes",
		"son_jeton_deplacer_pile_pleine"
	]

	SauvegardeConfigurationService.configuration_du_jeu["effets sonores"] = false
	for methode in methodes:
		service.effet_sonore.stream = null
		service.call(methode)
		assert_eq(service.effet_sonore.stream, null)
