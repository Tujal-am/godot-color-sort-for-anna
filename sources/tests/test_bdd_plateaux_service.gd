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
