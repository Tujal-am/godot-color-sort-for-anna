extends GutTest

const API_SCRIPT := preload("res://Scenes/MenuPrincipal/Campagne/PartagePerformances/partage_performances_api.gd")
const RACINE_TEST := "tests/test_partage_performances_import_service"
const DOSSIER_FICHIERS := "user://tests_partage_import"

var service: Node
var liste_joueurs_initiale: Array
var bdd_joueur_initiale: Dictionary
var fichier_bdd_initial: String
var scores_initiaux: Array

func before_each() -> void:
	FichiersJsonService.definir_racine_utilisateur(RACINE_TEST)
	FichiersJsonService.effacer_racine_utilisateur()
	liste_joueurs_initiale = SauvegardeListeJoueursService.liste_des_joueurs.duplicate(true)
	bdd_joueur_initiale = SauvegardeBddJoueursService._sauvegarde_joueur.duplicate(true)
	fichier_bdd_initial = SauvegardeBddJoueursService.fichier_sauvegarde
	scores_initiaux = SauvegardeTableauDesScoresService.liste_des_scores.duplicate(true)
	service = add_child_autofree(load("res://Singletons/partage_performances_import_service.gd").new())

func after_each() -> void:
	SauvegardeListeJoueursService.liste_des_joueurs = liste_joueurs_initiale.duplicate(true)
	SauvegardeBddJoueursService._sauvegarde_joueur = bdd_joueur_initiale.duplicate(true)
	SauvegardeBddJoueursService.fichier_sauvegarde = fichier_bdd_initial
	SauvegardeTableauDesScoresService.liste_des_scores = scores_initiaux.duplicate(true)
	FichiersJsonService.effacer_racine_utilisateur()
	FichiersJsonService.reinitialiser_racine_utilisateur()

func _campagne() -> Dictionary:
	return {
		"campagne": "campagne_partagee",
		"date_debut": 100.0,
		"date_fin": 200.0,
		"score": {"fin_campagne": 500},
		"niveaux": [
			{"niveau": "niveau_1", "score": {"niveau": 10}, "plateaux": [{"nom": "P1", "score": {"duree": 2}}]},
			{"niveau": "niveau_2", "score": {"niveau": 20}, "plateaux": [{"nom": "P2", "score": {"ratio_reussite": 3}}]}
		]
	}

func test_fichier_est_exploitable_exige_une_campagne_complete() -> void:
	var donnees := {"joueur": "Joueuse", "campagne": _campagne()}

	assert_true(service._fichier_est_exploitable(donnees))
	assert_false(service._fichier_est_exploitable({"joueur": " ", "campagne": _campagne()}))
	assert_false(service._fichier_est_exploitable({"joueur": "Joueuse", "campagne": {}}))
	assert_false(service._fichier_est_exploitable({
		"joueur": "Joueuse",
		"campagne": {"campagne": "nom", "niveaux": [{"niveau": "niveau_1", "plateaux": [1]}]}
	}))

func test_extension_vide_ou_json_est_acceptee() -> void:
	assert_true(service._extension_fichier_est_acceptee("user://toto."))
	assert_true(service._extension_fichier_est_acceptee("user://campagne.JSON"))
	assert_false(service._extension_fichier_est_acceptee("user://campagne.png"))

func test_import_refuse_efface_les_donnees_en_attente() -> void:
	service._import_en_attente = {"joueur": "Joueuse", "campagne": _campagne()}

	service.refuser_import()

	assert_true(service._import_en_attente.is_empty())
	assert_false(service._import_en_cours)

func test_accepter_import_cree_un_joueur_avec_toute_la_campagne() -> void:
	var nom_joueur := "Joueuse importee"
	var campagne := _campagne()
	service._import_en_attente = {"joueur": nom_joueur, "campagne": campagne}
	SauvegardeListeJoueursService.liste_des_joueurs = []
	SauvegardeTableauDesScoresService.liste_des_scores = []

	service.accepter_import()

	assert_true(SauvegardeListeJoueursService.le_joueur_existe(nom_joueur))
	var chemin: String = SauvegardeListeJoueursService.retourner_le_fichier_de_sauvegarde(nom_joueur)
	var sauvegarde: Dictionary = FichiersJsonService.read_json_file(chemin)
	var campagnes: Array = sauvegarde.get("enregistrement_campagne", [])
	assert_eq(campagnes.size(), 1)
	assert_eq(campagnes[0].get("campagne"), campagne.get("campagne"))
	assert_eq(campagnes[0].get("date_debut"), campagne.get("date_debut"))
	assert_eq(campagnes[0].get("date_fin"), campagne.get("date_fin"))
	assert_eq(campagnes[0].get("niveaux").size(), 2)
	assert_eq(campagnes[0].get("niveaux")[1].get("niveau"), "niveau_2")
	assert_eq(campagnes[0].get("niveaux")[1].get("plateaux")[0].get("nom"), "P2")
	var empreintes_partagees: Array = sauvegarde.get("campagnes_partagees_fichiers", [])
	var api: Node = service.get("_api")
	var empreinte_campagne: String = api.call("_calculer_empreinte_campagne", campagnes[0])
	assert_true(empreintes_partagees.has(empreinte_campagne))
	assert_true(sauvegarde.get("campagne", {}).is_empty())
	assert_true(service._import_en_attente.is_empty())
	assert_false(service._import_en_cours)

func test_import_signe_enveloppe_verifie_la_signature_avant_validation() -> void:
	var api: Node = API_SCRIPT.new()
	add_child_autofree(api)
	var donnees := {"joueur": "Joueuse", "campagne": _campagne()}
	var enveloppe: Dictionary = api.preparer_partage(donnees)
	var contenu := str(enveloppe.get("contenu_fichier", ""))
	var decode: Dictionary = api.decoder_fichier_signe(contenu)

	assert_true(enveloppe.get("succes", false))
	assert_true(decode.get("succes", false))
	assert_eq(decode.get("donnees").get("joueur"), "Joueuse")
	assert_eq(decode.get("donnees").get("campagne").get("campagne"), "campagne_partagee")
	assert_eq(decode.get("donnees").get("campagne").get("niveaux").size(), 2)
	assert_false(api.decoder_fichier_signe(contenu.replace("Joueuse", "Pirate")).get("succes", true))
