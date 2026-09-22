extends GutTest

var singleton
const RACINE_TEST = "tests/test_bdd_plateaux_service"

func _nettoyer_fichiers_utilisateur():
	FichiersJsonService.effacer_racine_utilisateur()

func _ecrire_campagne_test(fichier: String, campagne: Dictionary) -> void:
	FichiersJsonService.write_json_file(fichier, campagne)

func before_all():
	FichiersJsonService.definir_racine_utilisateur(RACINE_TEST)
	_nettoyer_fichiers_utilisateur()

func before_each():
	_nettoyer_fichiers_utilisateur()
	singleton = add_child_autofree(load("res://Singletons/Sauvegarde/bdd_plateaux_service.gd").new())
	singleton.plateau_campagne.clear()

func after_each():
	_nettoyer_fichiers_utilisateur()

func after_all():
	_nettoyer_fichiers_utilisateur()
	FichiersJsonService.reinitialiser_racine_utilisateur()

func test_initialiser_les_plateaux_charge_une_campagne_valide():
	_ecrire_campagne_test("campagne.json", {
		"campagne": {
			"niveau_1": [
				{"nom": "AAA.BBB.CCC", "difficulte": 1},
				{"nom": "DDD.EEE.FFF", "difficulte": 1}
			],
			"niveau_2": [
				{"nom": "GGG.HHH.III", "difficulte": 2}
			]
		}
	})
	singleton.chemin_campagne = "campagne.json"
	singleton._initialiser_les_plateaux()

	assert_eq(singleton.nom_niveau(1), "niveau_1")
	assert_eq(singleton.nom_niveau(0), "")
	assert_eq(singleton.plateau_campagne.get("niveau_1").size(), 2)
	assert_eq(singleton.plateau_campagne.get("niveau_2").size(), 1)

func test_initialiser_les_plateaux_ignore_un_fichier_absent():
	singleton.chemin_campagne = "campagne_inexistante.json"
	singleton._initialiser_les_plateaux()
	assert_true(singleton.plateau_campagne.is_empty())

func test_initialiser_les_plateaux_acepte_l_ancienne_cle_sans_casser_le_chargement():
	_ecrire_campagne_test("campagne_obsolete.json", {
		"liste difficulte des plateaux": true,
		"campagne": {
			"niveau_1": [
				{"nom": "AAA.BBB.CCC", "difficulte": 1}
			]
		}
	})
	singleton.chemin_campagne = "campagne_obsolete.json"
	singleton._initialiser_les_plateaux()

	assert_true(singleton.plateau_campagne.has("niveau_1"))
	assert_eq(singleton.plateau_campagne.get("niveau_1").size(), 1)

func test_nom_niveau_et_duplicate_reste_une_copie_independante():
	_ecrire_campagne_test("campagne.json", {
		"campagne": {
			"niveau_1": [
				{"nom": "AAA.BBB.CCC", "difficulte": 1},
				{"nom": "DDD.EEE.FFF", "difficulte": 1}
			]
		}
	})
	singleton.chemin_campagne = "campagne.json"
	singleton._initialiser_les_plateaux()

	var copie = singleton.plateau_liste_niveaux_duplicate()
	assert_eq(copie, singleton.plateau_campagne)

	copie[singleton.nom_niveau(1)][0]["difficulte"] += 1
	assert_ne(copie, singleton.plateau_campagne)
	assert_eq(int(singleton.plateau_campagne.get("niveau_1")[0].get("difficulte")), 1)

func test_initialiser_les_plateaux_ignore_un_fichier_sans_cle_campagne():
	_ecrire_campagne_test("campagne_sans_cle.json", {
		"autre_cle": "valeur"
	})
	singleton.chemin_campagne = "campagne_sans_cle.json"
	singleton._initialiser_les_plateaux()

	assert_true(singleton.plateau_campagne.is_empty())

func test_initialiser_les_plateaux_une_nouvelle_campagne_efface_les_niveaux_inacheves():
	# Charger une première campagne avec un niveau "niveau_1" inachevé
	_ecrire_campagne_test("campagne_a.json", {
		"campagne": {
			"niveau_1": [{"nom": "AAA.BBB.CCC", "difficulte": 1}]
		}
	})
	singleton.chemin_campagne = "campagne_a.json"
	singleton._initialiser_les_plateaux()
	assert_true(singleton.plateau_campagne.has("niveau_1"))

	# Charger une nouvelle campagne ne définissant que "niveau_2" : les
	# niveaux résiduels de l'ancienne campagne ("niveau_1") sont effacés.
	_ecrire_campagne_test("campagne_b.json", {
		"campagne": {
			"niveau_2": [{"nom": "GGG.HHH.III", "difficulte": 2}]
		}
	})
	singleton.chemin_campagne = "campagne_b.json"
	singleton._initialiser_les_plateaux()

	assert_false(singleton.plateau_campagne.has("niveau_1"))
	assert_true(singleton.plateau_campagne.has("niveau_2"))

func test_initialiser_les_plateaux_avec_une_cle_campagne_vide_ne_reinitialise_pas():
	_ecrire_campagne_test("campagne_a.json", {
		"campagne": {
			"niveau_1": [{"nom": "AAA.BBB.CCC", "difficulte": 1}]
		}
	})
	singleton.chemin_campagne = "campagne_a.json"
	singleton._initialiser_les_plateaux()
	assert_true(singleton.plateau_campagne.has("niveau_1"))

	# Une campagne vide ("campagne": {}) est considérée comme absente de
	# contenu : "niveau_1" n'est pas effacé.
	_ecrire_campagne_test("campagne_vide.json", {
		"campagne": {}
	})
	singleton.chemin_campagne = "campagne_vide.json"
	singleton._initialiser_les_plateaux()

	assert_true(singleton.plateau_campagne.has("niveau_1"))

func test_nom_niveau_avec_une_valeur_negative_ou_nulle_retourne_une_chaine_vide():
	# "niveau_0" ne correspond à aucun niveau réel : 0 et les négatifs sont
	# ignorés au même titre.
	assert_eq(singleton.nom_niveau(0), "")
	assert_eq(singleton.nom_niveau(-1), "")

func test_ready_charge_la_campagne_reelle_du_jeu_sans_erreur():
	# Smoke test : reconstruire un service "frais" avec le chemin par défaut
	# ("res://campagne.json", le vrai fichier du jeu) pour vérifier qu'il n'y
	# a pas de régression de chargement au démarrage réel.
	var service_reel = add_child_autofree(load("res://Singletons/Sauvegarde/bdd_plateaux_service.gd").new())
	await get_tree().process_frame

	assert_eq(service_reel.chemin_campagne, "res://campagne.json")
	assert_true(service_reel.plateau_campagne.has("niveau_1"))
	assert_false(service_reel.plateau_campagne.get("niveau_1").is_empty())
