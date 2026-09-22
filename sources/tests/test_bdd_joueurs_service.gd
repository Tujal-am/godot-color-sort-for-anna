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
	singleton.enregistrement_modifier_score_niveau_parfait(456)
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

func test_sauvegarde_vierge_retourne_la_structure_par_defaut():
	var vierge = singleton.sauvegarde_vierge("Nouveau Joueur")
	assert_eq(vierge.get("nom"), "Nouveau Joueur")
	assert_eq(vierge.get("campagne"), {})
	assert_eq(vierge.get("nombre_de_parties"), {})
	assert_eq(vierge.get("enregistrement_campagne"), [])
	assert_eq(vierge.get("plateaux_libres"), {})

func test_lire_infos_du_plateau_courant_gameplay_difficulte_et_statut():
	_charger_joueur_test("joueur_test.json", _sauvegarde_joueur_de_test())

	assert_eq(singleton.enregistrement_lire_gameplay_plateau(), "CLASSIQUE")
	assert_eq(singleton.enregistrement_lire_difficulte_plateau(), 1)
	assert_eq(singleton.enregistrement_lire_statut_plateau(), "en cours")

	singleton.enregistrement_modifier_statut_plateau("reussi")
	assert_eq(singleton.enregistrement_lire_statut_plateau(), "reussi")

func test_duree_du_plateau_est_calculee_en_direct_ou_lue_si_termine():
	var sauvegarde = _sauvegarde_joueur_de_test()
	_charger_joueur_test("joueur_test.json", sauvegarde)

	# Plateau "en cours" ("date_fin" == 0) : la durée est calculée en direct.
	assert_true(singleton.enregistrement_lire_duree_plateau() >= 0.0)

	var plateau_courant = singleton.enregistrement_lire_dernier_plateau()
	plateau_courant["date_fin"] = plateau_courant.get("date_debut") + 42
	plateau_courant["duree"] = 42.0
	# Plateau terminé : la durée enregistrée est retournée telle quelle.
	assert_eq(singleton.enregistrement_lire_duree_plateau(), 42.0)

func test_duree_plateau_recommence_cumule_les_tentatives_abandonnees():
	var sauvegarde = _sauvegarde_joueur_de_test()
	sauvegarde["enregistrement_campagne"][0]["plateaux"] = [
		{"nom": "A1", "date_debut": 100, "date_fin": 105, "duree": 5, "gameplay": "CLASSIQUE", "difficulte": 1, "statut": "abandonné", "score": {}, "coups joués": []},
		{"nom": "A1", "date_debut": 110, "date_fin": 118, "duree": 8, "gameplay": "CLASSIQUE", "difficulte": 1, "statut": "abandonné", "score": {}, "coups joués": []},
		{"nom": "A1", "date_debut": 120, "date_fin": 0, "duree": 0, "gameplay": "CLASSIQUE", "difficulte": 1, "statut": "en cours", "score": {}, "coups joués": []}
	]
	_charger_joueur_test("joueur_test.json", sauvegarde)

	assert_true(abs(singleton.enregistrement_lire_duree_plateau_recommence() - 13.0) < 0.0001)

func test_modifier_le_score_duree_et_ratio_reussite_du_plateau_courant():
	_charger_joueur_test("joueur_test.json", _sauvegarde_joueur_de_test())

	singleton.enregistrement_modifier_score_duree_plateau(250)
	singleton.enregistrement_modifier_score_ratio_reussite_plateau(80)

	var plateau_courant = singleton.enregistrement_lire_dernier_plateau()
	assert_eq(plateau_courant.get("score").get("duree"), 250)
	assert_eq(plateau_courant.get("score").get("ratio_reussite"), 80)

func test_lire_le_temps_du_joueur_formate_les_durees():
	var sauvegarde = _sauvegarde_joueur_de_test()
	sauvegarde["enregistrement_campagne"][0]["plateaux"][0]["date_fin"] = 999
	sauvegarde["enregistrement_campagne"][0]["plateaux"][0]["duree"] = 45.0
	_charger_joueur_test("joueur_test.json", sauvegarde)

	assert_eq(singleton.enregistrement_lire_le_temps_du_joueur(), "45 secondes")

	var plateau_courant = singleton.enregistrement_lire_dernier_plateau()
	plateau_courant["duree"] = 3725.0 # 1h 2min 5s
	assert_eq(singleton.enregistrement_lire_le_temps_du_joueur(), "1 heures 2 minutes")

	plateau_courant["duree"] = 90000.0 # 1j 1h
	assert_eq(singleton.enregistrement_lire_le_temps_du_joueur(), "1 jours 1 heures")

	plateau_courant["duree"] = 0.5
	assert_eq(singleton.enregistrement_lire_le_temps_du_joueur(), "500 millisecondes")

	plateau_courant["duree"] = 0.0
	assert_eq(singleton.enregistrement_lire_le_temps_du_joueur(), "")

func test_plateaux_libres_et_existence_par_difficulte():
	_charger_joueur_test("joueur_test.json", _sauvegarde_joueur_de_test())

	assert_true(singleton.plateaux_libres_difficulte_existe(1))
	assert_false(singleton.plateaux_libres_difficulte_existe(99))
	assert_eq(singleton.plateaux_libres().get("1").size(), 1)
	assert_eq(singleton.plateaux_libres_lire_liste_plateaux_de_difficulte(99).size(), 0)

func test_commencer_et_gagner_un_plateau_orchestrent_lenregistrement():
	var sauvegarde = {
		"nom": "Joueur Test",
		"campagne": {
			"niveau_1": [
				{"nom": "P1", "gameplay": "CLASSIQUE", "difficulte": 1}
			]
		},
		"enregistrement_campagne": [
			{"niveau": "niveau_1", "date_debut": 100, "date_fin": 0, "score": {}, "plateaux": []}
		],
		"plateaux_libres": {},
		"nombre_de_parties": {}
	}
	_charger_joueur_test("joueur_test.json", sauvegarde)

	singleton.commencer_un_plateau()
	assert_true(singleton.enregistrement_plateau_en_cours())
	assert_eq(singleton.enregistrement_lire_nom_plateau(), "P1")
	assert_eq(singleton.lire_nombre_de_parties_difficulte(1), 1)

	singleton.gagner_un_plateau()
	assert_false(singleton.enregistrement_plateau_en_cours())
	assert_eq(singleton.enregistrement_lire_statut_plateau(), "reussi")
	# Le plateau gagné a été retiré de la campagne (niveau vidé) et déplacé
	# dans les plateaux libres.
	assert_false(singleton.campagne_niveau_existe(1))
	assert_true(singleton.plateaux_libres_difficulte_existe(1))

func test_abandonner_un_plateau_conserve_le_plateau_dans_la_campagne():
	var sauvegarde = {
		"nom": "Joueur Test",
		"campagne": {
			"niveau_1": [
				{"nom": "P1", "gameplay": "CLASSIQUE", "difficulte": 1}
			]
		},
		"enregistrement_campagne": [
			{"niveau": "niveau_1", "date_debut": 100, "date_fin": 0, "score": {}, "plateaux": []}
		],
		"plateaux_libres": {},
		"nombre_de_parties": {}
	}
	_charger_joueur_test("joueur_test.json", sauvegarde)

	singleton.commencer_un_plateau()
	singleton.abandonner_un_plateau()

	assert_false(singleton.enregistrement_plateau_en_cours())
	assert_eq(singleton.enregistrement_lire_statut_plateau(), "abandonné")
	# Contrairement à "gagner_un_plateau", le plateau n'est pas retiré de
	# la campagne : il pourra être rejoué.
	assert_true(singleton.campagne_niveau_existe(1))

func test_reset_sauvegarde_des_joueurs_vide_la_progression_de_chaque_joueur():
	var initial_liste_joueurs = SauvegardeListeJoueursService.liste_des_joueurs.duplicate(true)
	SauvegardeListeJoueursService.liste_des_joueurs = [
		{"indice": 0, "nom": "Joueur A", "fichier_sauvegarde": "joueur_a.json"},
		{"indice": 1, "nom": "Joueur B", "fichier_sauvegarde": "joueur_b.json"}
	]
	FichiersJsonService.write_json_file("joueur_a.json", _sauvegarde_joueur_de_test())
	FichiersJsonService.write_json_file("joueur_b.json", _sauvegarde_joueur_de_test())

	singleton.reset_sauvegarde_des_joueurs()

	var sauvegarde_a = FichiersJsonService.read_json_file("joueur_a.json")
	assert_eq(sauvegarde_a.get("nom"), "Joueur A")
	assert_eq(sauvegarde_a.get("enregistrement_campagne"), [])
	assert_eq(sauvegarde_a.get("nombre_de_parties"), {})
	assert_eq(sauvegarde_a.get("campagne"), SauvegardeBddPlateauxService.plateau_liste_niveaux_duplicate())
	# Chaque joueur est libéré une fois traité.
	assert_false(singleton.le_joueur_existe())

	SauvegardeListeJoueursService.liste_des_joueurs = initial_liste_joueurs

func test_remplacer_campagne_des_joueurs_cloture_et_renouvelle_la_campagne():
	var initial_liste_joueurs = SauvegardeListeJoueursService.liste_des_joueurs.duplicate(true)
	SauvegardeListeJoueursService.liste_des_joueurs = [
		{"indice": 0, "nom": "Joueur C", "fichier_sauvegarde": "joueur_c.json"}
	]
	FichiersJsonService.write_json_file("joueur_c.json", _sauvegarde_joueur_de_test())

	singleton.remplacer_campagne_des_joueurs()

	var sauvegarde_c = FichiersJsonService.read_json_file("joueur_c.json")
	assert_eq(sauvegarde_c.get("campagne"), SauvegardeBddPlateauxService.plateau_liste_niveaux_duplicate())
	# Le niveau et le plateau en cours ont été clos avant le remplacement.
	assert_true(sauvegarde_c.get("enregistrement_campagne")[0].get("date_fin") > 0)
	assert_true(sauvegarde_c.get("enregistrement_campagne")[0].get("plateaux")[0].get("date_fin") > 0)
	assert_false(singleton.le_joueur_existe())

	SauvegardeListeJoueursService.liste_des_joueurs = initial_liste_joueurs
