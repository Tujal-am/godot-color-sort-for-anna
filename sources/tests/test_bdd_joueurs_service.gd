extends GutTest

var singleton
const RACINE_TEST = "tests/test_bdd_joueurs_service"

func _nettoyer_fichiers_utilisateur():
	FichiersJsonService.effacer_racine_utilisateur()

func _sauvegarde_joueur_de_test() -> Dictionary:
	var plateaux_niveau_1 = [
		{
			"nom": "A1",
			"date_debut": 110,
			"date_fin": 0,
			"duree": 0,
			"gameplay": "CLASSIQUE",
			"difficulte": 1,
			"statut": "en cours",
			"score": {},
			"coups joués": []
		}
	]
	var plateaux_niveau_2 = [
		{
			"nom": "B1",
			"date_debut": 210,
			"date_fin": 220,
			"duree": 10,
			"gameplay": "CLASSIQUE",
			"difficulte": 2,
			"statut": "reussi",
			"score": {},
			"coups joués": []
		},
		{
			"nom": "B2",
			"date_debut": 230,
			"date_fin": 0,
			"duree": 0,
			"gameplay": "DEFI_DU_GOSSE",
			"difficulte": 2,
			"statut": "en cours",
			"score": {},
			"coups joués": []
		}
	]
	return {
		"nom": "Joueur Test",
		"campagne": {
			"niveau_1": [
				{"nom": "A1", "difficulte": 1, "gameplay": "CLASSIQUE"}
			],
			"niveau_2": [
				{"nom": "B1", "difficulte": 2, "gameplay": "CLASSIQUE"},
				{"nom": "B2", "difficulte": 2, "gameplay": "DEFI_DU_GOSSE"}
			]
		},
		"enregistrement_campagne": [
			{
				"niveau": "niveau_1",
				"date_debut": 100,
				"date_fin": 0,
				"score": {},
				"plateaux": plateaux_niveau_1,
			}
		],
		"plateaux_libres": {
			"1": [{"nom": "libre1", "gameplay": "QUI_PERD_GAGNE", "difficulte": 1}]
		},
		"nombre_de_parties": {
			"1": 2
		}
	}

func _sauvegarde_joueur_sans_joueur_en_cours() -> Dictionary:
	var sauvegarde = _sauvegarde_joueur_de_test().duplicate(true)
	sauvegarde["enregistrement_campagne"][1]["date_fin"] = 10
	return sauvegarde

func _charger_joueur_test(fichier: String, sauvegarde: Dictionary) -> void:
	FichiersJsonService.write_json_file(fichier, sauvegarde)
	assert_true(singleton.choisir_le_joueur(sauvegarde.get("nom", ""), fichier))

func before_all():
	FichiersJsonService.definir_racine_utilisateur(RACINE_TEST)
	_nettoyer_fichiers_utilisateur()

func before_each():
	_nettoyer_fichiers_utilisateur()
	singleton = add_child_autofree(load("res://Singletons/Sauvegarde/bdd_joueurs_service.gd").new())
	# "_ready()" est appelé en différé par Godot (frame suivante) : on attend
	# qu'il se termine avant de lancer les assertions, sinon le fichier
	# "sauvegarde_joueur_00.json" créé par "_ready()" n'existe pas encore.
	await get_tree().process_frame

func after_each():
	_nettoyer_fichiers_utilisateur()

func after_all():
	_nettoyer_fichiers_utilisateur()
	FichiersJsonService.reinitialiser_racine_utilisateur()

func test_ready_cree_le_joueur_initial_si_absent():
	assert_true(FichiersJsonService.json_file_exists("sauvegarde_joueur_00.json"))
	assert_true(singleton.le_joueur_existe())
	assert_eq(singleton.lire_nom_joueur(), "Alain Konu")

func test_lire_sauvegarde_joueur_absente_retourne_false():
	assert_false(singleton._lire_sauvegarde_joueur("joueur_inexistant.json"))
	assert_eq(singleton.fichier_sauvegarde, "")

func test_choisir_le_joueur_charge_un_fichier_existant():
	var sauvegarde = _sauvegarde_joueur_de_test()
	_charger_joueur_test("joueur_test.json", sauvegarde)

	assert_eq(singleton.lire_nom_joueur(), "Joueur Test")
	assert_eq(singleton.fichier_sauvegarde, "joueur_test.json")
	assert_true(singleton.le_joueur_existe())

func test_ajouter_un_nouveau_joueur_gere_les_refus_et_la_creation():
	FichiersJsonService.write_json_file("joueur_test.json", _sauvegarde_joueur_de_test())

	assert_false(singleton.ajouter_un_nouveau_joueur("", "joueur_vide.json"))
	assert_false(singleton.ajouter_un_nouveau_joueur("Joueur Test", "joueur_test.json"))
	assert_true(singleton.ajouter_un_nouveau_joueur("Nouveau Joueur", "joueur_nouveau.json"))
	assert_true(FichiersJsonService.json_file_exists("joueur_nouveau.json"))

func test_nom_niveau_et_valeur_niveau_sont_bijectifs():
	assert_eq(singleton.nom_niveau(0), "")
	assert_eq(singleton.nom_niveau(3), "niveau_3")
	assert_eq(singleton.valeur_niveau("niveau_3"), 3)
	assert_eq(singleton.valeur_niveau(""), 0)

func test_campagne_niveaux_et_prochain_niveau_couvrent_les_branches():
	_charger_joueur_test("joueur_test.json", _sauvegarde_joueur_de_test())

	assert_eq(singleton.campagne_nombre_niveaux(), 2)
	assert_true(singleton.campagne_niveau_existe(1))
	assert_true(singleton.campagne_niveau_existe(2))
	assert_false(singleton.campagne_niveau_existe(99))
	assert_eq(singleton.lire_campagne_liste_niveaux().size(), 2)
	assert_eq(singleton.lire_prochain_niveau_de_campagne(), 0)

	var niveau_courant = singleton.enregistrement_lire_dernier_niveau()
	niveau_courant["date_fin"] = 12
	assert_eq(singleton.lire_prochain_niveau_de_campagne(), 1)

	singleton.sauvegarde_joueur["campagne"].erase("niveau_1")
	singleton.sauvegarde_joueur["campagne"].erase("niveau_2")
	assert_true(singleton.campagne_la_campagne_est_terminee())
	assert_true(singleton.campagne_le_niveau_est_termine(1))

func test_campagne_plateau_courant_et_suppression_couvrent_les_branches():
	_charger_joueur_test("joueur_test.json", _sauvegarde_joueur_de_test())

	assert_eq(singleton.campagne_lire_prochain_plateau_pour_niveau_courant().get("nom"), "A1")
	assert_true(singleton.campagne_supprimer_plateau_courant())
	assert_true(singleton.campagne_le_niveau_est_termine(1))
	assert_eq(singleton.plateaux_libres_lire_liste_plateaux_de_difficulte(1).size(), 2)

	singleton.sauvegarde_joueur["campagne"] = {
		"niveau_1": [
			{"nom": "A1", "difficulte": 1, "gameplay": "CLASSIQUE"}
		]
	}
	singleton.sauvegarde_joueur["enregistrement_campagne"] = [
		{
			"niveau": "niveau_1",
			"date_debut": 100,
			"date_fin": 0,
			"score": {},
			"plateaux": [
				{"nom": "A1", "date_debut": 110, "date_fin": 0, "duree": 0, "difficulte": 1, "statut": "reussi", "score": {}, "coups joués": []}
			]
		}
	]
	assert_false(singleton.campagne_supprimer_plateau_courant())

func test_nombre_de_parties_de_la_difficulte_courante_est_majoree():
	_charger_joueur_test("joueur_test.json", _sauvegarde_joueur_de_test())

	assert_true(singleton.nombre_de_parties_difficulte_existe(1))
	assert_false(singleton.nombre_de_parties_difficulte_existe(2))
	assert_eq(singleton.lire_nombre_de_parties_difficulte(1), 2)
	assert_eq(singleton.lire_nombre_de_parties_difficulte(2), 0)

	singleton.nombre_de_parties_incrementer_pour_difficulte_courante()
	assert_eq(singleton.lire_nombre_de_parties_difficulte(1), 3)

	singleton.sauvegarde_joueur["nombre_de_parties"] = {}
	singleton.sauvegarde_joueur["campagne"]["niveau_1"][0]["difficulte"] = 2
	singleton.nombre_de_parties_incrementer_pour_difficulte_courante()
	assert_eq(singleton.lire_nombre_de_parties_difficulte(2), 1)

func test_enregistrement_niveau_et_scores_couvrent_les_branches():
	var sauvegarde = {
		"nom": "Joueur Test",
		"campagne": {
			"niveau_1": [
				{"nom": "A1", "difficulte": 1, "gameplay": "CLASSIQUE"}
			],
			"niveau_2": [
				{"nom": "B1", "difficulte": 2, "gameplay": "CLASSIQUE"},
				{"nom": "B2", "difficulte": 2, "gameplay": "DEFI_DU_GOSSE"}
			]
		},
		"enregistrement_campagne": [
			{
				"niveau": "niveau_1",
				"date_debut": 100,
				"date_fin": 10,
				"score": {},
				"plateaux": [
					{"nom": "A1", "date_debut": 110, "date_fin": 120, "duree": 10, "difficulte": 1, "statut": "reussi", "score": {}, "coups joués": []}
				]
			},
			{
				"niveau": "niveau_2",
				"date_debut": 500,
				"date_fin": 0,
				"score": {},
				"plateaux": [
					{"nom": "B1", "date_debut": 210, "date_fin": 220, "duree": 10, "difficulte": 2, "statut": "reussi", "score": {}, "coups joués": []},
					{"nom": "B2", "date_debut": 230, "date_fin": 0, "duree": 0, "difficulte": 2, "statut": "en cours", "score": {}, "coups joués": []}
				]
			}
		],
		"plateaux_libres": {
			"1": [{"nom": "libre1", "gameplay": "QUI_PERD_GAGNE", "difficulte": 1}]
		},
		"nombre_de_parties": {
			"1": 2
		}
	}
	_charger_joueur_test("joueur_test.json", sauvegarde)

	assert_true(singleton.enregistrement_niveau_existe())
	assert_eq(singleton.enregistrement_lire_dernier_niveau().get("niveau"), "niveau_2")
	assert_true(singleton.enregistrement_niveau_en_cours())
	assert_eq(singleton.enregistrement_lire_valeur_niveau_joueur(), 2)
	assert_eq(singleton.enregistrement_lire_score_niveau(), 0)

	singleton.enregistrement_modifier_score_niveau(123)
	singleton.enregistrement_modifier_score_niveau_sans_detour(456)
	assert_eq(singleton.enregistrement_lire_score_niveau(), 123)

	var niveau_courant = singleton.enregistrement_lire_dernier_niveau()
	niveau_courant["date_fin"] = 12
	assert_false(singleton.enregistrement_niveau_en_cours())
	assert_true(singleton.enregistrement_initialiser_un_nouveau_niveau())
	assert_eq(singleton.enregistrement_lire_dernier_niveau().get("niveau"), "niveau_1")

	singleton.enregistrement_terminer_niveau()
	assert_true(singleton.enregistrement_lire_dernier_niveau().get("date_fin", 0) > 0)

func test_longueur_et_pourcentage_du_niveau_courant_sont_calcules():
	var sauvegarde = {
		"nom": "Joueur Test",
		"campagne": {
			"niveau_1": [
				{"nom": "A1", "difficulte": 1, "gameplay": "CLASSIQUE"}
			],
			"niveau_2": [
				{"nom": "B1", "difficulte": 2, "gameplay": "CLASSIQUE"},
				{"nom": "B2", "difficulte": 2, "gameplay": "DEFI_DU_GOSSE"}
			]
		},
		"enregistrement_campagne": [
			{
				"niveau": "niveau_1",
				"date_debut": 100,
				"date_fin": 10,
				"score": {},
				"plateaux": [
					{"nom": "A1", "date_debut": 110, "date_fin": 120, "duree": 10, "difficulte": 1, "statut": "reussi", "score": {}, "coups joués": []}
				]
			},
			{
				"niveau": "niveau_2",
				"date_debut": 500,
				"date_fin": 0,
				"score": {},
				"plateaux": [
					{"nom": "B1", "date_debut": 210, "date_fin": 220, "duree": 10, "difficulte": 2, "statut": "reussi", "score": {}, "coups joués": []},
					{"nom": "B2", "date_debut": 230, "date_fin": 0, "duree": 0, "difficulte": 2, "statut": "en cours", "score": {}, "coups joués": []}
				]
			}
		],
		"plateaux_libres": {
			"1": [{"nom": "libre1", "gameplay": "QUI_PERD_GAGNE", "difficulte": 1}]
		},
		"nombre_de_parties": {
			"1": 2
		}
	}
	_charger_joueur_test("joueur_test.json", sauvegarde)

	assert_eq(singleton.enregistrement_lire_niveau_longueur_realisee(), 1)
	assert_eq(singleton.lire_longueur_niveau_courant(), 3)
	assert_eq(singleton.lire_pourcentage_niveau_realise(), 33)

func test_coups_joues_et_plateau_courant_couvrent_les_branches():
	var sauvegarde = _sauvegarde_joueur_de_test()
	sauvegarde["enregistrement_campagne"][0]["plateaux"][0]["coups joués"] = [
		{"depart": 0, "arrivee": 1}
	]
	_charger_joueur_test("joueur_test.json", sauvegarde)

	assert_true(singleton.coups_joues_existe())
	assert_eq(singleton.lire_nombre_coups(), 1)
	assert_true(singleton.coups_joues_ajouter_un_nouveau_coup(1, 2))
	assert_true(singleton.coups_joues_existe())
	assert_eq(singleton.lire_nombre_coups(), 2)

	var niveau_courant = singleton.enregistrement_lire_dernier_niveau()
	niveau_courant["plateaux"].back()["date_fin"] = 10
	assert_false(singleton.coups_joues_ajouter_un_nouveau_coup(3, 4))
