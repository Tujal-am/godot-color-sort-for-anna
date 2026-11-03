extends GutTest

const RACINE_TEST = "tests/test_configuration_service"
const SCRIPT_SERVICE = "res://Singletons/Sauvegarde/configuration_service.gd"
const FICHIER_CONFIGURATION = "configuration_du_jeu.json"

var service
var configuration_initiale
var liste_joueurs_initiale
var tableau_scores_initial
var sauvegarde_joueur_initiale
var fichier_sauvegarde_initial

###############################################
# Outils
###############################################

func _nettoyer_fichiers_utilisateur() -> void:
	FichiersJsonService.effacer_racine_utilisateur()

func _lire_configuration_fichier():
	return FichiersJsonService.read_json_file(FICHIER_CONFIGURATION)

func _configuration_par_defaut() -> Dictionary:
	# Valeurs d'usine du script, lues sur une instance non ajoutée à l'arbre.
	var instance = load(SCRIPT_SERVICE).new()
	var configuration: Dictionary = instance.configuration_du_jeu.duplicate(true)
	instance.free()
	return configuration

func _version_courante() -> String:
	return _configuration_par_defaut().get("version")

func _version_meme_mineure() -> String:
	# Même 'majeure.mineure' que la version courante, 'build' différent.
	var morceaux = _version_courante().split(".")
	return morceaux[0] + "." + morceaux[1] + ".0-ancien_build"

func _configuration_disque(version: String, musiques := true, effets := true, vibrations := true) -> Dictionary:
	return {
		"version": version,
		"date_debut_campagne": "2020-01-01 00:00:00",
		"musiques": musiques,
		"effets sonores": effets,
		"vibrations": vibrations
	}

func _creer_service(configuration = null):
	_nettoyer_fichiers_utilisateur()
	if configuration != null:
		FichiersJsonService.write_json_file(FICHIER_CONFIGURATION, configuration)
	return _lancer_service()

func _lancer_service():
	# Le '_ready()' du service est exécuté ici (initialisation + migrations).
	service = add_child_autofree(load(SCRIPT_SERVICE).new())
	return service

func _declarer_joueurs(joueurs: Array) -> void:
	# joueurs : [{"nom": ..., "fichier": ..., "contenu": {...}, "score": ...}]
	var liste = []
	var scores = []
	var indice = 0
	for joueur in joueurs:
		liste.append({"indice": indice, "nom": joueur.get("nom"), "fichier_sauvegarde": joueur.get("fichier")})
		scores.append({"nom": joueur.get("nom"), "rang": indice + 1, "score": joueur.get("score", 0), "score_txt": str(joueur.get("score", 0))})
		FichiersJsonService.write_json_file(joueur.get("fichier"), joueur.get("contenu"))
		indice += 1
	SauvegardeListeJoueursService.liste_des_joueurs = liste
	SauvegardeTableauDesScoresService.liste_des_scores = scores

func _relire_joueur(fichier: String) -> Dictionary:
	# Relecture depuis le disque : vérifie ce qui est réellement persisté.
	var contenu = FichiersJsonService.read_json_file(fichier)
	assert_true(contenu is Dictionary, "sauvegarde illisible : " + fichier)
	return contenu if contenu is Dictionary else {}

###############################################
# Fixtures : sauvegardes joueur d'anciennes versions (clé 'ascensions')
###############################################

func _plateau_ancien(nom: String, difficulte: int, debut: float, fin: float, statut := "reussi") -> Dictionary:
	return {
		"nom": nom,
		"niveau": difficulte,
		"date_debut": debut,
		"date_fin": fin,
		"duree": fin - debut,
		"statut": statut,
		"score": {"duree": 40, "ratio_reussite": 20},
		"coups joués": [{"depart": 2, "arrivee": 1}, {"depart": 0, "arrivee": 2}]
	}

func _joueur_ancien(nom: String, campagne_terminee := false) -> Dictionary:
	return {
		"nom": nom,
		"nombre_de_parties": {"18": 2, "20": 1},
		# Plateaux restant à jouer : vide <=> la campagne 1 est terminée.
		"plateaux": {} if campagne_terminee else {"20": [{"nom": "Reste", "difficulte": 20, "gameplay": "CLASSIQUE"}]},
		"ascensions": [
			{
				"date_debut": 1700000000.0,
				"date_fin": 1700000500.0,
				"score": {"ascension": 100, "ascension_sans_detour": 50},
				"plateaux": [
					_plateau_ancien("A.A.A", 18, 1700000000.0, 1700000100.0),
					_plateau_ancien("B.B.B", 20, 1700000200.0, 1700000300.0)
				]
			},
			{
				"date_debut": 1700001000.0,
				"date_fin": 1700001500.0,
				"score": {"ascension": 200},
				"plateaux": [
					_plateau_ancien("C.C.C", 22, 1700001000.0, 1700001100.0, "passé")
				]
			}
		]
	}

func _migrer_un_joueur(version_disque: String, contenu_joueur: Dictionary, score := 999) -> Dictionary:
	_declarer_joueurs([{"nom": "Alice", "fichier": "joueur_alice.json", "contenu": contenu_joueur, "score": score}])
	_creer_service_sans_nettoyage(_configuration_disque(version_disque))
	return _relire_joueur("joueur_alice.json")

func _creer_service_sans_nettoyage(configuration: Dictionary):
	FichiersJsonService.write_json_file(FICHIER_CONFIGURATION, configuration)
	return _lancer_service()

###############################################
# Cycle de vie
###############################################

func before_each():
	FichiersJsonService.definir_racine_utilisateur(RACINE_TEST)
	configuration_initiale = SauvegardeConfigurationService.configuration_du_jeu.duplicate(true)
	liste_joueurs_initiale = SauvegardeListeJoueursService.liste_des_joueurs.duplicate(true)
	tableau_scores_initial = SauvegardeTableauDesScoresService.liste_des_scores.duplicate(true)
	sauvegarde_joueur_initiale = SauvegardeBddJoueursService._sauvegarde_joueur.duplicate(true)
	fichier_sauvegarde_initial = SauvegardeBddJoueursService.fichier_sauvegarde
	_nettoyer_fichiers_utilisateur()
	# Aucun joueur par défaut : le fichier du joueur d'usine n'existe pas dans ce répertoire de test.
	SauvegardeListeJoueursService.liste_des_joueurs = []
	SauvegardeTableauDesScoresService.liste_des_scores = []
	SauvegardeBddJoueursService._sauvegarde_joueur = {}
	SauvegardeBddJoueursService.fichier_sauvegarde = ""

func after_each():
	SauvegardeConfigurationService.configuration_du_jeu = configuration_initiale.duplicate(true)
	SauvegardeListeJoueursService.liste_des_joueurs = liste_joueurs_initiale.duplicate(true)
	SauvegardeTableauDesScoresService.liste_des_scores = tableau_scores_initial.duplicate(true)
	SauvegardeBddJoueursService._sauvegarde_joueur = sauvegarde_joueur_initiale.duplicate(true)
	SauvegardeBddJoueursService.fichier_sauvegarde = fichier_sauvegarde_initial
	_nettoyer_fichiers_utilisateur()
	FichiersJsonService.reinitialiser_racine_utilisateur()

###############################################
# Valeurs d'usine et première installation
###############################################

func test_les_valeurs_d_usine_sont_coherentes():
	var configuration = _configuration_par_defaut()
	assert_true(str(configuration.get("version")).begins_with("V"))
	assert_eq(str(configuration.get("version")).split(".").size() >= 3, true)
	assert_true(configuration.get("musiques"))
	assert_true(configuration.get("effets sonores"))
	assert_true(configuration.get("vibrations"))
	assert_true(Time.get_unix_time_from_datetime_string(configuration.get("date_debut_campagne")) > 0)

func test_premiere_installation_cree_le_fichier_initial_et_supprime_la_sauvegarde_obsolete():
	FichiersJsonService.write_json_file("sauvegarde.json", {"obsolete": true})

	_creer_service()

	assert_true(FichiersJsonService.json_file_exists(FICHIER_CONFIGURATION))
	assert_false(FichiersJsonService.json_file_exists("sauvegarde.json"))
	assert_eq(service.configuration_du_jeu, _configuration_par_defaut())
	assert_eq(_lire_configuration_fichier(), _configuration_par_defaut())

func test_premiere_installation_sans_joueur_ni_fichier_ne_cree_rien_d_autre():
	_creer_service()

	assert_true(FichiersJsonService.json_file_exists(FICHIER_CONFIGURATION))
	assert_false(FichiersJsonService.json_file_exists("scores.json") and SauvegardeTableauDesScoresService.liste_des_scores.size() > 0)
	assert_false(SauvegardeBddJoueursService.le_joueur_existe())

func test_premiere_installation_remet_les_scores_a_zero_et_cree_la_campagne_du_joueur():
	_declarer_joueurs([{
		"nom": "Alice", "fichier": "joueur_alice.json", "score": 999,
		"contenu": SauvegardeBddJoueursService.sauvegarde_vierge("Alice")
	}])

	_lancer_service()

	assert_eq(int(SauvegardeTableauDesScoresService.lire_score_joueur("Alice")), 0)
	var sauvegarde = _relire_joueur("joueur_alice.json")
	assert_eq(sauvegarde.get("enregistrement_campagne").size(), 1)
	assert_eq(float(sauvegarde.get("enregistrement_campagne")[0].get("date_fin")), 0.0)

###############################################
# Démarrage avec une configuration à la version courante
###############################################

func test_meme_version_ne_migre_pas_et_conserve_la_campagne_et_les_scores():
	_declarer_joueurs([{
		"nom": "Alice", "fichier": "joueur_alice.json", "score": 999,
		"contenu": SauvegardeBddJoueursService.sauvegarde_vierge("Alice")
	}])

	_creer_service_sans_nettoyage(_configuration_disque(_version_courante()))

	assert_eq(int(SauvegardeTableauDesScoresService.lire_score_joueur("Alice")), 999)
	assert_eq(_relire_joueur("joueur_alice.json").get("enregistrement_campagne"), [])

func test_meme_version_conserve_les_preferences_utilisateur():
	_creer_service(_configuration_disque(_version_courante(), false, false, false))

	assert_false(service.musiques_sont_actives())
	assert_false(service.effets_sonores_sont_actifs())
	assert_false(service.vibrations_sont_actives())

func test_meme_mineure_build_different_ne_reinitialise_ni_campagne_ni_scores():
	var contenu = SauvegardeBddJoueursService.sauvegarde_vierge("Alice")
	contenu["campagne"] = {"niveau_99": [{"nom": "Ancien", "difficulte": 9, "gameplay": "CLASSIQUE"}]}
	_declarer_joueurs([{"nom": "Alice", "fichier": "joueur_alice.json", "score": 999, "contenu": contenu}])

	_creer_service_sans_nettoyage(_configuration_disque(_version_meme_mineure()))

	assert_eq(service.lire_la_version(), _version_courante())
	var sauvegarde = _relire_joueur("joueur_alice.json")
	var niveau_99 = sauvegarde.get("campagne").get("niveau_99")
	assert_eq(niveau_99.size(), 1)
	assert_eq(niveau_99[0].get("nom"), "Ancien")
	assert_eq(int(niveau_99[0].get("difficulte")), 9)
	assert_eq(sauvegarde.get("enregistrement_campagne"), [])
	assert_eq(int(SauvegardeTableauDesScoresService.lire_score_joueur("Alice")), 999)

func test_meme_mineure_conserve_les_preferences_utilisateur():
	_creer_service(_configuration_disque(_version_meme_mineure(), true, false, false))

	assert_true(service.musiques_sont_actives())
	assert_false(service.effets_sonores_sont_actifs())
	assert_false(service.vibrations_sont_actives())

func test_relancer_apres_migration_ne_migre_plus():
	_migrer_un_joueur("V0.4.0.beta7", _joueur_ancien("Alice"))
	var apres_premiere_migration = _relire_joueur("joueur_alice.json")
	assert_eq(apres_premiere_migration.get("enregistrement_campagne").size(), 2)

	# Deuxième démarrage : la configuration sur disque est à jour.
	SauvegardeTableauDesScoresService.liste_des_scores[0]["score"] = 321
	_lancer_service()

	assert_eq(_lire_configuration_fichier().get("version"), _version_courante())
	assert_eq(_relire_joueur("joueur_alice.json"), apres_premiere_migration)
	assert_eq(int(SauvegardeTableauDesScoresService.lire_score_joueur("Alice")), 321)

###############################################
# Migration V0.2.X -> V0.3.X
###############################################

func test_migration_v0_2_supprime_l_ancienne_sauvegarde_unique():
	FichiersJsonService.write_json_file("sauvegarde.json", {"ancienne": "structure"})
	_declarer_joueurs([])

	_lancer_service()

	assert_false(FichiersJsonService.json_file_exists("sauvegarde.json"))
	assert_eq(_lire_configuration_fichier().get("version"), _version_courante())

###############################################
# Migration V0.3.X -> V0.4.X -> V1.0.X
###############################################

func test_migration_v0_3_met_a_jour_la_version_sur_le_disque():
	_declarer_joueurs([])

	_creer_service_sans_nettoyage(_configuration_disque("V0.3.2"))

	assert_eq(service.lire_la_version(), _version_courante())
	assert_eq(_lire_configuration_fichier().get("version"), _version_courante())

func test_migration_v0_3_conserve_les_preferences_utilisateur():
	_declarer_joueurs([])

	_creer_service_sans_nettoyage(_configuration_disque("V0.3.2", false, false, false))

	assert_false(service.musiques_sont_actives())
	assert_false(service.effets_sonores_sont_actifs())
	assert_false(service.vibrations_sont_actives())

func test_migration_v0_3_convertit_les_joueurs_comme_une_v0_4():
	var sauvegarde = _migrer_un_joueur("V0.3.2", _joueur_ancien("Alice"))

	assert_false(sauvegarde.has("ascensions"))
	assert_false(sauvegarde.has("plateaux"))
	assert_eq(sauvegarde.get("enregistrement_campagne").size(), 2)
	assert_eq(sauvegarde.get("enregistrement_campagne")[0].get("campagne"), "campagne_1")

###############################################
# Migration V0.4.X -> V1.0.X
###############################################

func test_migration_v0_4_conserve_les_preferences_utilisateur():
	_declarer_joueurs([])

	_creer_service_sans_nettoyage(_configuration_disque("V0.4.0.beta7", false, true, false))

	assert_eq(service.lire_la_version(), _version_courante())
	assert_false(service.musiques_sont_actives())
	assert_true(service.effets_sonores_sont_actifs())
	assert_false(service.vibrations_sont_actives())
	var configuration_disque = _lire_configuration_fichier()
	assert_eq(configuration_disque.get("version"), _version_courante())
	assert_false(configuration_disque.get("musiques"))
	assert_true(configuration_disque.get("effets sonores"))
	assert_false(configuration_disque.get("vibrations"))

func test_migration_v0_4_reprend_les_parametres_usine_pour_date_de_campagne_et_version():
	_declarer_joueurs([])

	_creer_service_sans_nettoyage(_configuration_disque("V0.4.0.beta7"))

	assert_eq(service.configuration_du_jeu.get("date_debut_campagne"), _configuration_par_defaut().get("date_debut_campagne"))
	assert_eq(service.lire_la_version(), _version_courante())

func test_migration_v0_4_remet_les_scores_a_zero():
	_migrer_un_joueur("V0.4.0.beta7", _joueur_ancien("Alice"), 999)

	assert_eq(int(SauvegardeTableauDesScoresService.lire_score_joueur("Alice")), 0)
	assert_eq(SauvegardeTableauDesScoresService.lire_score_txt_joueur("Alice"), "0")

func test_migration_v0_4_transcrit_les_ascensions_en_niveaux_de_la_campagne_1():
	var sauvegarde = _migrer_un_joueur("V0.4.0.beta7", _joueur_ancien("Alice"))

	var campagne_1 = sauvegarde.get("enregistrement_campagne")[0]
	assert_eq(campagne_1.get("campagne"), "campagne_1")
	assert_eq(float(campagne_1.get("date_debut")), 1700000000.0)
	var niveaux = campagne_1.get("niveaux")
	assert_eq(niveaux.size(), 2)

	assert_eq(niveaux[0].get("niveau"), "niveau_1")
	assert_eq(float(niveaux[0].get("date_debut")), 1700000000.0)
	assert_eq(float(niveaux[0].get("date_fin")), 1700000500.0)
	assert_eq(int(niveaux[0].get("score").get("niveau")), 100)
	assert_eq(int(niveaux[0].get("score").get("niveau_parfait")), 50)
	assert_eq(niveaux[0].get("plateaux").size(), 2)

	assert_eq(niveaux[1].get("niveau"), "niveau_2")
	assert_eq(float(niveaux[1].get("date_debut")), 1700001000.0)
	assert_eq(int(niveaux[1].get("score").get("niveau")), 200)
	assert_false(niveaux[1].get("score").has("niveau_parfait"))
	assert_eq(niveaux[1].get("plateaux").size(), 1)

func test_migration_v0_4_transcrit_les_plateaux_avec_leurs_statistiques():
	var sauvegarde = _migrer_un_joueur("V0.4.0.beta7", _joueur_ancien("Alice"))

	var niveaux = sauvegarde.get("enregistrement_campagne")[0].get("niveaux")
	var premier = niveaux[0].get("plateaux")[0]
	assert_eq(premier.get("nom"), "A.A.A")
	assert_eq(premier.get("gameplay"), "CLASSIQUE")
	assert_eq(int(premier.get("difficulte")), 18)
	assert_eq(float(premier.get("date_debut")), 1700000000.0)
	assert_eq(float(premier.get("date_fin")), 1700000100.0)
	assert_eq(float(premier.get("duree")), 100.0)
	assert_eq(premier.get("statut"), "reussi")
	assert_eq(int(premier.get("score").get("duree")), 40)
	assert_eq(int(premier.get("score").get("ratio_reussite")), 20)
	assert_eq(premier.get("coups joués").size(), 2)
	assert_eq(int(premier.get("coups joués")[0].get("depart")), 2)
	assert_eq(int(premier.get("coups joués")[0].get("arrivee")), 1)

	var passe = niveaux[1].get("plateaux")[0]
	assert_eq(passe.get("nom"), "C.C.C")
	assert_eq(passe.get("statut"), "passé")
	assert_eq(int(passe.get("difficulte")), 22)

func test_migration_v0_4_cree_les_plateaux_libres_par_difficulte():
	var sauvegarde = _migrer_un_joueur("V0.4.0.beta7", _joueur_ancien("Alice"))

	var plateaux_libres = sauvegarde.get("plateaux_libres")
	assert_eq(plateaux_libres.keys().size(), 3)
	for difficulte in ["18", "20", "22"]:
		assert_true(plateaux_libres.has(difficulte), "difficulté " + difficulte)
		assert_eq(plateaux_libres[difficulte].size(), 1)
		assert_eq(plateaux_libres[difficulte][0].get("gameplay"), "CLASSIQUE")
		assert_eq(int(plateaux_libres[difficulte][0].get("difficulte")), int(difficulte))
	assert_eq(plateaux_libres["18"][0].get("nom"), "A.A.A")
	assert_eq(plateaux_libres["20"][0].get("nom"), "B.B.B")
	assert_eq(plateaux_libres["22"][0].get("nom"), "C.C.C")

func test_migration_v0_4_regroupe_les_plateaux_libres_de_meme_difficulte():
	var joueur = _joueur_ancien("Alice")
	joueur["ascensions"][1]["plateaux"].append(_plateau_ancien("D.D.D", 18, 1700001200.0, 1700001300.0))

	var sauvegarde = _migrer_un_joueur("V0.4.0.beta7", joueur)

	var libres_18 = sauvegarde.get("plateaux_libres")["18"]
	assert_eq(libres_18.size(), 2)
	assert_eq(libres_18[0].get("nom"), "A.A.A")
	assert_eq(libres_18[1].get("nom"), "D.D.D")

func test_migration_v0_4_supprime_les_anciennes_cles_et_conserve_le_nombre_de_parties():
	var sauvegarde = _migrer_un_joueur("V0.4.0.beta7", _joueur_ancien("Alice"))

	assert_false(sauvegarde.has("ascensions"))
	assert_false(sauvegarde.has("plateaux"))
	assert_eq(sauvegarde.get("nom"), "Alice")
	assert_eq(int(sauvegarde.get("nombre_de_parties").get("18")), 2)
	assert_eq(int(sauvegarde.get("nombre_de_parties").get("20")), 1)

func test_migration_v0_4_campagne_non_terminee_n_ajoute_pas_de_score_de_fin():
	var sauvegarde = _migrer_un_joueur("V0.4.0.beta7", _joueur_ancien("Alice", false))

	var campagne_1 = sauvegarde.get("enregistrement_campagne")[0]
	assert_false(campagne_1.get("score").has("fin_campagne"))

func test_migration_v0_4_campagne_terminee_ajoute_le_score_de_fin_de_campagne():
	var sauvegarde = _migrer_un_joueur("V0.4.0.beta7", _joueur_ancien("Alice", true))

	var campagne_1 = sauvegarde.get("enregistrement_campagne")[0]
	assert_eq(int(campagne_1.get("score").get("fin_campagne")), 500000)

func test_migration_v0_4_ouvre_une_nouvelle_campagne_apres_la_campagne_1():
	var sauvegarde = _migrer_un_joueur("V0.4.0.beta7", _joueur_ancien("Alice"))

	var enregistrements = sauvegarde.get("enregistrement_campagne")
	assert_eq(enregistrements.size(), 2)
	var nouvelle_campagne = enregistrements[1]
	assert_ne(nouvelle_campagne.get("campagne"), "campagne_1")
	assert_eq(float(nouvelle_campagne.get("date_fin")), 0.0)
	assert_eq(nouvelle_campagne.get("niveaux"), [])
	assert_eq(sauvegarde.get("nom_campagne"), nouvelle_campagne.get("campagne"))
	assert_false(sauvegarde.get("campagne").is_empty())

func test_migration_v0_4_conserve_les_dates_historiques_de_la_campagne_1():
	var sauvegarde = _migrer_un_joueur("V0.4.0.beta7", _joueur_ancien("Alice"))

	var campagne_1 = sauvegarde.get("enregistrement_campagne")[0]
	var dernier_niveau = campagne_1.get("niveaux")[-1]
	var dernier_plateau = dernier_niveau.get("plateaux")[-1]
	assert_eq(float(dernier_plateau.get("date_fin")), 1700001100.0, "date de fin du dernier plateau")
	assert_eq(float(dernier_niveau.get("date_fin")), 1700001500.0, "date de fin du dernier niveau")

func test_migration_v0_4_libere_le_joueur_courant():
	_migrer_un_joueur("V0.4.0.beta7", _joueur_ancien("Alice"))

	assert_false(SauvegardeBddJoueursService.le_joueur_existe())

func test_migration_v0_4_joueur_sans_ascension_n_a_que_la_nouvelle_campagne():
	var sauvegarde = _migrer_un_joueur("V0.4.0.beta7", {
		"nom": "Alice",
		"nombre_de_parties": {},
		"plateaux": {"1": [{"nom": "Reste", "difficulte": 1, "gameplay": "CLASSIQUE"}]}
	})

	assert_eq(sauvegarde.get("enregistrement_campagne").size(), 1)
	assert_ne(sauvegarde.get("enregistrement_campagne")[0].get("campagne"), "campagne_1")
	assert_eq(sauvegarde.get("plateaux_libres"), {})
	assert_false(sauvegarde.has("plateaux"))

func test_migration_v0_4_ascension_sans_score_ni_plateaux():
	var sauvegarde = _migrer_un_joueur("V0.4.0.beta7", {
		"nom": "Alice",
		"plateaux": {"1": []},
		"ascensions": [{"date_debut": 1700000000.0, "date_fin": 1700000500.0}]
	})

	var niveaux = sauvegarde.get("enregistrement_campagne")[0].get("niveaux")
	assert_eq(niveaux.size(), 1)
	assert_eq(niveaux[0].get("niveau"), "niveau_1")
	assert_eq(niveaux[0].get("score"), {})
	assert_eq(niveaux[0].get("plateaux"), [])
	assert_eq(sauvegarde.get("plateaux_libres"), {})

func test_migration_v0_4_plateau_incomplet_utilise_les_valeurs_par_defaut():
	var sauvegarde = _migrer_un_joueur("V0.4.0.beta7", {
		"nom": "Alice",
		"plateaux": {"1": []},
		"ascensions": [{
			"date_debut": 1700000000.0,
			"date_fin": 1700000500.0,
			"plateaux": [{}]
		}]
	})

	var plateau = sauvegarde.get("enregistrement_campagne")[0].get("niveaux")[0].get("plateaux")[0]
	assert_eq(plateau.get("nom"), "Plateau_inconnu")
	assert_eq(plateau.get("gameplay"), "CLASSIQUE")
	assert_eq(int(plateau.get("difficulte")), 0)
	assert_eq(plateau.get("statut"), "reussi")
	assert_eq(plateau.get("coups joués"), [])

func test_migration_v0_4_convertit_plusieurs_joueurs_independamment():
	_declarer_joueurs([
		{"nom": "Alice", "fichier": "joueur_alice.json", "score": 10, "contenu": _joueur_ancien("Alice", true)},
		{"nom": "Bob", "fichier": "joueur_bob.json", "score": 20, "contenu": {"nom": "Bob", "plateaux": {"1": []}}}
	])

	_creer_service_sans_nettoyage(_configuration_disque("V0.4.0.beta7"))

	var alice = _relire_joueur("joueur_alice.json")
	var bob = _relire_joueur("joueur_bob.json")
	assert_eq(alice.get("enregistrement_campagne").size(), 2)
	assert_eq(alice.get("enregistrement_campagne")[0].get("campagne"), "campagne_1")
	assert_eq(bob.get("enregistrement_campagne").size(), 1)
	assert_eq(int(SauvegardeTableauDesScoresService.lire_score_joueur("Alice")), 0)
	assert_eq(int(SauvegardeTableauDesScoresService.lire_score_joueur("Bob")), 0)

###############################################
# Lecteurs
###############################################

func test_lecteurs_retournent_les_defauts_quand_les_cles_sont_absentes():
	_creer_service()
	service.configuration_du_jeu = {"date_debut_campagne": "2020-01-01 00:00:00"}

	assert_true(service.musiques_sont_actives())
	assert_true(service.effets_sonores_sont_actifs())
	assert_true(service.vibrations_sont_actives())
	assert_eq(service.lire_la_version(), "?")
	assert_eq(service.lire_la_date_debut_campagne_timestamp(), int(Time.get_unix_time_from_datetime_string("2020-01-01 00:00:00")))

func test_lire_la_date_debut_campagne_timestamp_avec_cle_absente_retourne_la_valeur_invalide():
	_creer_service()
	service.configuration_du_jeu = {"version": "V1.0.0-rc17"}

	assert_eq(service.lire_la_date_debut_campagne_timestamp(), int(Time.get_unix_time_from_datetime_string("?")))

func test_lire_la_date_debut_campagne_timestamp_convertit_la_date_en_secondes():
	_creer_service()
	service.configuration_du_jeu["date_debut_campagne"] = "1970-01-02 00:00:00"

	assert_eq(service.lire_la_date_debut_campagne_timestamp(), 86400)

###############################################
# Réglages : bascules
###############################################

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

func test_une_bascule_ne_modifie_pas_les_autres_reglages():
	_creer_service()

	service.desactiver_musiques()

	assert_false(service.musiques_sont_actives())
	assert_true(service.effets_sonores_sont_actifs())
	assert_true(service.vibrations_sont_actives())
	assert_eq(_lire_configuration_fichier().get("version"), _version_courante())

func test_une_bascule_sans_changement_n_ecrit_pas_le_fichier():
	_creer_service()
	FichiersJsonService.remove_json_file(FICHIER_CONFIGURATION)

	service.activer_musiques()
	service.activer_effets_sonores()
	service.activer_vibrations()

	assert_false(FichiersJsonService.json_file_exists(FICHIER_CONFIGURATION))

func test_une_bascule_est_conservee_au_redemarrage():
	_creer_service()
	service.desactiver_vibrations()

	_lancer_service()

	assert_false(service.vibrations_sont_actives())

###############################################
# Vrais fichiers de sauvegarde (tests/fixtures/configuration)
###############################################

const DOSSIER_FIXTURES = "res://tests/fixtures/configuration/"

func _lire_fixture(dossier: String, fichier: String) -> Variant:
	var chemin = DOSSIER_FIXTURES + dossier + "/" + fichier
	if not FileAccess.file_exists(chemin):
		return null
	return JSON.parse_string(FileAccess.get_file_as_string(chemin))

func _installer_fixture(dossier: String) -> void:
	"Copie les fichiers réels dans le répertoire utilisateur de test et charge les listes comme au démarrage du jeu."
	var repertoire = DirAccess.open(DOSSIER_FIXTURES + dossier)
	for fichier in repertoire.get_files():
		if fichier.ends_with(".json"):
			FichiersJsonService.write_json_file(fichier, _lire_fixture(dossier, fichier))
	var liste = _lire_fixture(dossier, "liste_des_joueurs.json")
	if liste == null:
		# Aucune liste avant la V0.4 : un seul joueur historique.
		liste = [{"indice": 0, "nom": "Alain Konu", "fichier_sauvegarde": "sauvegarde_joueur_00.json"}]
	SauvegardeListeJoueursService.liste_des_joueurs = liste
	var scores = _lire_fixture(dossier, "scores.json")
	SauvegardeTableauDesScoresService.liste_des_scores = scores if scores != null else []

func _demarrer_avec_fixture(dossier: String) -> void:
	_installer_fixture(dossier)
	_lancer_service()

func _fichier_joueur(indice: int) -> String:
	return "sauvegarde_joueur_%02d.json" % indice

func _verifier_campagne_1_migree(ancien: Dictionary, migre: Dictionary) -> void:
	var nom = ancien.get("nom")
	var ascensions: Array = ancien.get("ascensions")
	var campagne_1: Dictionary = migre.get("enregistrement_campagne")[0]
	assert_eq(campagne_1.get("campagne"), "campagne_1", nom)
	assert_eq(float(campagne_1.get("date_debut")), float(ascensions[0].get("date_debut")), nom + " : date de début")
	assert_eq(campagne_1.get("niveaux").size(), ascensions.size(), nom + " : nombre de niveaux")
	# Une campagne sans plateau restant à jouer est terminée.
	if ancien.get("plateaux").is_empty():
		assert_eq(int(campagne_1.get("score").get("fin_campagne")), 500000, nom + " : fin de campagne")
	else:
		assert_false(campagne_1.get("score").has("fin_campagne"), nom + " : campagne non terminée")

	for i in range(ascensions.size()):
		var ascension: Dictionary = ascensions[i]
		var niveau: Dictionary = campagne_1.get("niveaux")[i]
		var contexte = nom + " / niveau " + str(i + 1)
		assert_eq(niveau.get("niveau"), "niveau_" + str(i + 1), contexte)
		assert_eq(float(niveau.get("date_debut")), float(ascension.get("date_debut")), contexte + " : date de début")
		if float(ascension.get("date_fin", 0.0)) > 0.0:
			assert_eq(float(niveau.get("date_fin")), float(ascension.get("date_fin")), contexte + " : date de fin")
		var score_ancien: Dictionary = ascension.get("score", {})
		assert_eq(niveau.get("score").get("niveau"), score_ancien.get("ascension"), contexte + " : score niveau")
		assert_eq(niveau.get("score").get("niveau_parfait"), score_ancien.get("ascension_sans_detour"), contexte + " : score niveau parfait")
		assert_eq(niveau.get("plateaux").size(), ascension.get("plateaux", []).size(), contexte + " : nombre de plateaux")
		for j in range(ascension.get("plateaux", []).size()):
			var ancien_plateau: Dictionary = ascension.get("plateaux")[j]
			var plateau: Dictionary = niveau.get("plateaux")[j]
			var contexte_plateau = contexte + " / plateau " + str(j + 1)
			assert_eq(plateau.get("nom"), ancien_plateau.get("nom"), contexte_plateau)
			assert_eq(int(plateau.get("difficulte")), int(ancien_plateau.get("niveau")), contexte_plateau + " : difficulté")
			assert_eq(plateau.get("statut"), ancien_plateau.get("statut"), contexte_plateau + " : statut")
			assert_eq(float(plateau.get("date_debut")), float(ancien_plateau.get("date_debut")), contexte_plateau + " : date de début")
			assert_eq(plateau.get("score"), ancien_plateau.get("score"), contexte_plateau + " : score")
			assert_eq(plateau.get("coups joués").size(), ancien_plateau.get("coups joués", []).size(), contexte_plateau + " : coups")
			if ancien_plateau.get("statut") != "en cours":
				assert_eq(float(plateau.get("date_fin")), float(ancien_plateau.get("date_fin")), contexte_plateau + " : date de fin")
				assert_eq(float(plateau.get("duree")), float(ancien_plateau.get("duree")), contexte_plateau + " : durée")

func _verifier_plateaux_libres_migres(ancien: Dictionary, migre: Dictionary) -> void:
	var attendus = {}
	for ascension in ancien.get("ascensions"):
		for plateau in ascension.get("plateaux", []):
			var difficulte = str(int(plateau.get("niveau")))
			attendus[difficulte] = attendus.get(difficulte, 0) + 1
	var plateaux_libres: Dictionary = migre.get("plateaux_libres")
	assert_eq(plateaux_libres.keys().size(), attendus.keys().size(), ancien.get("nom") + " : difficultés")
	for difficulte in attendus:
		assert_eq(plateaux_libres.get(difficulte, []).size(), attendus[difficulte], ancien.get("nom") + " : difficulté " + difficulte)

func test_reel_v0_2_la_sauvegarde_unique_est_supprimee():
	_installer_fixture("v0_2")
	assert_true(FichiersJsonService.json_file_exists("sauvegarde.json"))
	SauvegardeListeJoueursService.liste_des_joueurs = []

	_lancer_service()

	assert_false(FichiersJsonService.json_file_exists("sauvegarde.json"))
	assert_eq(_lire_configuration_fichier().get("version"), _version_courante())

func test_reel_v0_3_met_a_jour_la_configuration_et_conserve_les_preferences():
	_demarrer_avec_fixture("v0_3")

	var disque = _lire_configuration_fichier()
	assert_eq(disque.get("version"), _version_courante())
	assert_eq(service.musiques_sont_actives(), _lire_fixture("v0_3", "configuration_du_jeu.json").get("musiques"))
	assert_eq(service.effets_sonores_sont_actifs(), _lire_fixture("v0_3", "configuration_du_jeu.json").get("effets sonores"))
	assert_eq(service.vibrations_sont_actives(), _lire_fixture("v0_3", "configuration_du_jeu.json").get("vibrations"))

func test_reel_v0_3_sauvegarde_du_joueur_est_convertie_sans_ascension():
	var ancien = _lire_fixture("v0_3", _fichier_joueur(0))
	assert_true(ancien.get("plateaux").size() > 0)

	_demarrer_avec_fixture("v0_3")

	var sauvegarde = _relire_joueur(_fichier_joueur(0))
	assert_eq(sauvegarde.get("nom"), "Alain Konu")
	assert_false(sauvegarde.has("plateaux"))
	assert_false(sauvegarde.has("ascensions"))
	assert_eq(sauvegarde.get("plateaux_libres"), {})
	# Aucune ascension dans la V0.3 : seule la nouvelle campagne existe.
	assert_eq(sauvegarde.get("enregistrement_campagne").size(), 1)
	assert_ne(sauvegarde.get("enregistrement_campagne")[0].get("campagne"), "campagne_1")
	assert_false(sauvegarde.get("campagne").is_empty())

func test_reel_v0_3_remet_les_scores_a_zero():
	_demarrer_avec_fixture("v0_3")

	for joueur in SauvegardeTableauDesScoresService.liste_des_scores:
		assert_eq(int(joueur.get("score")), 0)
		assert_eq(joueur.get("score_txt"), "0")

func test_reel_v0_4_met_a_jour_la_configuration_et_conserve_les_preferences():
	var ancienne = _lire_fixture("v0_4", "configuration_du_jeu.json")
	assert_false(ancienne.get("musiques"), "la fixture doit avoir la musique coupée")

	_demarrer_avec_fixture("v0_4")

	assert_eq(service.lire_la_version(), _version_courante())
	assert_false(service.musiques_sont_actives())
	assert_eq(service.effets_sonores_sont_actifs(), ancienne.get("effets sonores"))
	assert_eq(service.vibrations_sont_actives(), ancienne.get("vibrations"))
	var disque = _lire_configuration_fichier()
	assert_eq(disque.get("version"), _version_courante())
	assert_false(disque.get("musiques"))
	assert_eq(disque.get("date_debut_campagne"), _configuration_par_defaut().get("date_debut_campagne"))

func test_reel_v0_4_remet_tous_les_scores_a_zero():
	_demarrer_avec_fixture("v0_4")

	assert_eq(SauvegardeTableauDesScoresService.liste_des_scores.size(), 5)
	for joueur in SauvegardeTableauDesScoresService.liste_des_scores:
		assert_eq(int(joueur.get("score")), 0, joueur.get("nom"))
		assert_eq(joueur.get("score_txt"), "0", joueur.get("nom"))
	assert_eq(_lire_fixture("v0_4", "scores.json")[0].get("score"), 2159546.0, "la fixture contient bien des scores à effacer")

func test_reel_v0_4_convertit_la_campagne_1_de_chaque_joueur():
	var anciens = []
	for indice in range(3):
		anciens.append(_lire_fixture("v0_4", _fichier_joueur(indice)))

	_demarrer_avec_fixture("v0_4")

	for indice in range(3):
		var migre = _relire_joueur(_fichier_joueur(indice))
		_verifier_campagne_1_migree(anciens[indice], migre)

func test_reel_v0_4_conserve_les_donnees_du_joueur():
	var anciens = []
	for indice in range(3):
		anciens.append(_lire_fixture("v0_4", _fichier_joueur(indice)))

	_demarrer_avec_fixture("v0_4")

	for indice in range(3):
		var migre = _relire_joueur(_fichier_joueur(indice))
		assert_eq(migre.get("nom"), anciens[indice].get("nom"))
		assert_eq(migre.get("nombre_de_parties"), anciens[indice].get("nombre_de_parties"), anciens[indice].get("nom") + " : nombre de parties")
		assert_false(migre.has("ascensions"))
		assert_false(migre.has("plateaux"))

func test_reel_v0_4_transcrit_les_plateaux_libres():
	var anciens = []
	for indice in range(3):
		anciens.append(_lire_fixture("v0_4", _fichier_joueur(indice)))

	_demarrer_avec_fixture("v0_4")

	for indice in range(3):
		_verifier_plateaux_libres_migres(anciens[indice], _relire_joueur(_fichier_joueur(indice)))

func test_reel_v0_4_ouvre_une_nouvelle_campagne_par_joueur():
	_demarrer_avec_fixture("v0_4")

	for indice in range(3):
		var migre = _relire_joueur(_fichier_joueur(indice))
		var enregistrements = migre.get("enregistrement_campagne")
		assert_eq(enregistrements.size(), 2)
		assert_eq(float(enregistrements[1].get("date_fin")), 0.0)
		assert_eq(enregistrements[1].get("niveaux"), [])
		assert_eq(enregistrements[1].get("campagne"), migre.get("nom_campagne"))
		assert_ne(enregistrements[1].get("campagne"), "campagne_1")
		assert_false(migre.get("campagne").is_empty())

func test_reel_v0_4_la_campagne_terminee_est_distinguee_de_la_campagne_en_cours():
	_demarrer_avec_fixture("v0_4")

	var terminee = _relire_joueur(_fichier_joueur(0))
	var en_cours = _relire_joueur(_fichier_joueur(1))
	assert_eq(int(terminee.get("enregistrement_campagne")[0].get("score").get("fin_campagne")), 500000)
	assert_false(en_cours.get("enregistrement_campagne")[0].get("score").has("fin_campagne"))

func test_reel_v0_4_le_resultat_a_la_meme_forme_que_la_v1_0_de_reference():
	_demarrer_avec_fixture("v0_4")

	for indice in range(3):
		var migre = _relire_joueur(_fichier_joueur(indice))
		var reference = _lire_fixture("v1_0_0", _fichier_joueur(indice))
		assert_eq(migre.keys().size(), reference.keys().size(), "clés de la sauvegarde " + str(indice))
		for cle in reference.keys():
			assert_true(migre.has(cle), "clé manquante : " + cle)
		var campagne_migree = migre.get("enregistrement_campagne")[0]
		var campagne_reference = reference.get("enregistrement_campagne")[0]
		for cle in campagne_reference.keys():
			assert_true(campagne_migree.has(cle), "clé de campagne manquante : " + cle)
		assert_eq(campagne_migree.get("niveaux").size(), campagne_reference.get("niveaux").size())
		assert_eq(campagne_migree.get("score"), campagne_reference.get("score"))
		assert_eq(migre.get("plateaux_libres").keys().size(), reference.get("plateaux_libres").keys().size())

func test_reel_v0_4_un_deuxieme_demarrage_ne_modifie_rien():
	_demarrer_avec_fixture("v0_4")
	var premiere = []
	for indice in range(3):
		premiere.append(_relire_joueur(_fichier_joueur(indice)))
	var configuration = _lire_configuration_fichier()

	_lancer_service()

	for indice in range(3):
		assert_eq(_relire_joueur(_fichier_joueur(indice)), premiere[indice])
	assert_eq(_lire_configuration_fichier(), configuration)

func test_reel_v1_0_redemarrage_sans_changement_de_version_conserve_tout():
	var configuration_reference = _lire_fixture("v1_0_0", "configuration_du_jeu.json")
	assert_eq(str(configuration_reference.get("version")).split(".").slice(0, 2), _version_courante().split(".").slice(0, 2), "la fixture doit avoir la même majeure.mineure que la version courante")
	var anciens = []
	for indice in range(3):
		anciens.append(_lire_fixture("v1_0_0", _fichier_joueur(indice)))

	_demarrer_avec_fixture("v1_0_0")

	for indice in range(3):
		assert_eq(_relire_joueur(_fichier_joueur(indice)), anciens[indice], "joueur " + str(indice))
	assert_eq(SauvegardeTableauDesScoresService.liste_des_scores, _lire_fixture("v1_0_0", "scores.json"))

func test_reel_v1_0_redemarrage_conserve_les_preferences_utilisateur():
	var configuration_reference = _lire_fixture("v1_0_0", "configuration_du_jeu.json")
	assert_false(configuration_reference.get("musiques"), "la fixture doit avoir la musique coupée")

	_demarrer_avec_fixture("v1_0_0")

	assert_false(service.musiques_sont_actives())
	assert_eq(service.effets_sonores_sont_actifs(), configuration_reference.get("effets sonores"))
	assert_eq(service.vibrations_sont_actives(), configuration_reference.get("vibrations"))
