extends GutTest

var service
var sauvegarde_joueur_initiale
var fichier_sauvegarde_initial
var configuration_initiale
const RACINE_TEST = "tests/test_stats_service"

func _nettoyer_fichiers_utilisateur():
	FichiersJsonService.effacer_racine_utilisateur()

func _activer_joueur_test():
	FichiersJsonService.write_json_file("test_stats_service.json", SauvegardeBddJoueursService.sauvegarde_joueur)
	assert_true(SauvegardeBddJoueursService.choisir_le_joueur("Joueur Test", "test_stats_service.json"))


func before_each():
	FichiersJsonService.definir_racine_utilisateur(RACINE_TEST)
	_nettoyer_fichiers_utilisateur()
	service = load("res://Singletons/stats_service.gd").new()
	sauvegarde_joueur_initiale = SauvegardeBddJoueursService.sauvegarde_joueur.duplicate(true)
	fichier_sauvegarde_initial = SauvegardeBddJoueursService.fichier_sauvegarde
	configuration_initiale = SauvegardeConfigurationService.configuration_du_jeu.duplicate(true)

	SauvegardeConfigurationService.configuration_du_jeu["date_debut_campagne"] = "2020-01-01 00:00:00"
	SauvegardeBddJoueursService.sauvegarde_joueur = {
		"nom": "Joueur Test",
		# Nouvelle convention : 'campagne' ne contient que les niveaux actifs.
		# Les niveaux terminés sont archivés dans 'enregistrement_campagne' et sortis de la campagne active.
		# En jeu libre, les plateaux sortis sont indexés par leur difficulté dans 'plateaux_libres'.
		"campagne": {
			"niveau_2": [
				{"nom": "R3", "difficulte": 2}
			],
			"niveau_3": [
				{"nom": "R1", "difficulte": 1},
				{"nom": "R2", "difficulte": 2}
			]
		},
		"enregistrement_campagne": [
			{
				"niveau": "niveau_1",
				"date_debut": 1700000000,
				"date_fin": 1700001000,
				"plateaux": [
					{"nom": "A1", "date_debut": 1700000010, "duree": 10, "difficulte": 1, "statut": "reussi"},
					{"nom": "B", "date_debut": 1700000020, "duree": 11, "difficulte": 2, "statut": "abandonné"},
					{"nom": "B", "date_debut": 1700000030, "duree": 15, "difficulte": 2, "statut": "reussi"},
					{"nom": "C", "date_debut": 1700000040, "duree": 9, "difficulte": 3, "statut": "reussi"}
				]
			},
			{
				"niveau": "niveau_2",
				"date_debut": 1700002000,
				"date_fin": 0,
				"plateaux": [
					{"nom": "D", "date_debut": 1700002010, "duree": 15, "difficulte": 2, "statut": "reussi"},
					{"nom": "A2", "date_debut": 1700002020, "duree": 8, "difficulte": 4, "statut": "reussi"}
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
	_nettoyer_fichiers_utilisateur()
	FichiersJsonService.reinitialiser_racine_utilisateur()


func test_campagne_et_niveau_statistiques():
	var campagne = SauvegardeBddJoueursService.sauvegarde_joueur.get("campagne", {})
	var historique = SauvegardeBddJoueursService.sauvegarde_joueur.get("enregistrement_campagne", [])

	assert_false("niveau_1" in campagne)
	assert_true("niveau_2" in campagne)
	assert_true("niveau_3" in campagne)
	assert_true(historique.size() >= 1)
	assert_eq(historique[0].get("niveau"), "niveau_1")
	assert_true("1" in SauvegardeBddJoueursService.sauvegarde_joueur.get("plateaux_libres", {}))
	assert_true("2" in SauvegardeBddJoueursService.sauvegarde_joueur.get("plateaux_libres", {}))
	assert_true("3" in SauvegardeBddJoueursService.sauvegarde_joueur.get("plateaux_libres", {}))
	assert_true("4" in SauvegardeBddJoueursService.sauvegarde_joueur.get("plateaux_libres", {}))

	assert_eq(service.campagne_nom_joueur(), "Joueur Test")
	assert_eq(service.nombre_de_plateau_inacheves(), 3)
	assert_eq(service.nombre_de_plateau_acheves(), 5)
	assert_true(abs(service.campagne_taux_completion() - (5.0 / 8.0)) < 0.0001)
	assert_true(abs(service.campagne_taux_reussite() - (5.0 / 6.0)) < 0.0001)
	assert_eq(service.campagne_serie_max_reussite(), 4)

	assert_true(abs(service.niveau_taux_completion() - (2.0 / 3.0)) < 0.0001)
	assert_eq(service.niveau_terminees(), 1)
	assert_eq(service.niveau_longueur_max(), 3)

	var infos_taux = service.niveau_taux_reussite_infos()
	assert_true(abs(infos_taux.get("taux_min") - 0.75) < 0.0001)
	assert_eq(infos_taux.get("taux_min_lg"), 3)
	assert_true(abs(infos_taux.get("taux_max") - 1.0) < 0.0001)
	assert_eq(infos_taux.get("taux_max_lg"), 2)


func test_plateau_statistiques():
	assert_true(abs(service.campagne_temps_total_en_s() - 68.0) < 0.0001)
	assert_true(abs(service.plateau_temps_moyen_en_s() - (68.0 / 6.0)) < 0.0001)

	var plus_rapide = service.plateau_plus_rapide_infos()
	assert_true(abs(plus_rapide.get("temps_en_s") - 8.0) < 0.0001)
	assert_eq(plus_rapide.get("difficulte"), 4)

	var plus_lent = service.plateau_plus_lent_infos()
	assert_true(abs(plus_lent.get("temps_en_s") - 15.0) < 0.0001)
	assert_eq(plus_lent.get("difficulte"), 2)

	var plus_galere = service.plateau_plus_galere_infos()
	assert_eq(plus_galere.get("nom"), "B")
	assert_eq(plus_galere.get("essais"), 2)
	assert_eq(plus_galere.get("difficulte"), 2)

func test_statistiques_couvrent_les_branches_sans_plateaux_et_egalites():
	# Cas sans enregistrement de niveau : zéro/ratio limite
	SauvegardeBddJoueursService.sauvegarde_joueur["enregistrement_campagne"] = []
	assert_eq(service.nombre_niveaux_termines(), 0)
	assert_eq(service.duree_moyenne_niveaux_terminees_en_s(), 0.0)
	assert_eq(service.taux_de_reussite_des_plateaux(), 0.0)
	assert_eq(service.taux_completion_niveau(), 0.0)
	assert_eq(service.plateau_le_plus_rapide_les_infos().get("temps_en_s"), 0.0)
	assert_eq(service.plateau_le_plus_lent_les_infos().get("temps_en_s"), 0.0)

	# Cas avec valeurs identiques : la difficulté la plus élevée doit être retenue
	SauvegardeBddJoueursService.sauvegarde_joueur["enregistrement_campagne"] = [
		{
			"niveau": "niveau_1",
			"date_debut": 1700000000,
			"date_fin": 1700001000,
			"plateaux": [
				{"nom": "A", "date_debut": 1700000010, "duree": 10, "difficulte": 2, "statut": "reussi"},
				{"nom": "B", "date_debut": 1700000020, "duree": 10, "difficulte": 5, "statut": "reussi"}
			]
		}
	]
	var rapid = service.plateau_le_plus_rapide_les_infos()
	assert_true(abs(rapid.get("temps_en_s") - 10.0) < 0.0001)
	assert_eq(rapid.get("difficulte"), 5)

	var lent = service.plateau_le_plus_lent_les_infos()
	assert_true(abs(lent.get("temps_en_s") - 10.0) < 0.0001)
	assert_eq(lent.get("difficulte"), 5)

	# Cas avec mêmes noms de plateau pour déclencher le chemin de doublon dans l'indexation
	SauvegardeBddJoueursService.sauvegarde_joueur["enregistrement_campagne"] = [
		{
			"niveau": "niveau_1",
			"date_debut": 1700000000,
			"date_fin": 1700001000,
			"plateaux": [
				{"nom": "B", "date_debut": 1700000010, "duree": 5, "difficulte": 2, "statut": "reussi"},
				{"nom": "B", "date_debut": 1700000020, "duree": 7, "difficulte": 3, "statut": "abandonné"},
				{"nom": "B", "date_debut": 1700000030, "duree": 11, "difficulte": 5, "statut": "reussi"}
			]
		}
	]
	var galere = service.plateau_le_plus_galere_les_infos()
	assert_eq(galere.get("nom"), "B")
	assert_eq(galere.get("essais"), 3)
	assert_eq(galere.get("difficulte"), 2)

	# Cas de reset de série et de max atteint : abandon = coupure de série
	SauvegardeBddJoueursService.sauvegarde_joueur["enregistrement_campagne"] = [
		{"niveau": "niveau_1", "date_debut": 1700000000, "date_fin": 1700001000, "plateaux": [
			{"nom": "A", "statut": "reussi"},
			{"nom": "B", "statut": "reussi"},
			{"nom": "C", "statut": "abandonné"},
			{"nom": "D", "statut": "reussi"},
			{"nom": "E", "statut": "reussi"}
		]},
		{"niveau": "niveau_2", "date_debut": 1700002000, "date_fin": 1700003000, "plateaux": [
			{"nom": "F", "statut": "reussi"}
		]}
	]
	assert_eq(service.serie_de_victoire_maximum(), 3)

func test_niveau_taux_reussite_les_infos_traite_les_branchs_fallbacks():
	var infos = service.niveau_taux_reussite_les_infos()
	assert_true(infos.get("taux_min") >= 0.0)
	assert_true(infos.get("taux_max") <= 1.0)
	assert_true(infos.get("taux_min_lg") >= 0)
	assert_true(infos.get("taux_max_lg") >= 0)

	SauvegardeBddJoueursService.sauvegarde_joueur["enregistrement_campagne"] = [
		{"niveau": "niveau_1", "date_debut": 1700000000, "date_fin": 1700001000, "plateaux": [
			{"nom": "A", "date_debut": 1700000010, "duree": 10, "difficulte": 2, "statut": "reussi"},
			{"nom": "B", "date_debut": 1700000020, "duree": 20, "difficulte": 5, "statut": "abandonné"}]
		},
		{"niveau": "niveau_2", "date_debut": 1700002000, "date_fin": 1700003000, "plateaux": []}
	]
	var infos_2 = service.niveau_taux_reussite_les_infos()
	assert_true(abs(infos_2.get("taux_min") - 0.5) < 0.0001)
	assert_eq(infos_2.get("taux_min_lg"), 1)
	assert_true(abs(infos_2.get("taux_max") - 0.5) < 0.0001)
	assert_eq(infos_2.get("taux_max_lg"), 1)

func test_reussis_abandonnes_par_niveau_et_completion_niveau_couvrent_les_zeros():
	var par_niveau = service.nombre_de_plateau_reussis_abandonnes_pour_niveau("niveau_2")
	assert_eq(par_niveau.get("reussis"), 2)
	assert_eq(par_niveau.get("abandonnes"), 0)
	assert_true(abs(service.taux_completion_niveau() - (2.0 / 3.0)) < 0.0001)

	SauvegardeBddJoueursService.sauvegarde_joueur["campagne"] = {"niveau_99": []}
	SauvegardeBddJoueursService.sauvegarde_joueur["enregistrement_campagne"] = [
		{"niveau": "niveau_99", "date_debut": 1700000000, "date_fin": 1700001000, "plateaux": []}
	]
	assert_eq(service.nombre_de_plateau_reussis_abandonnes_pour_niveau("niveau_99").get("reussis"), 0)
	assert_true(abs(service.taux_completion_niveau()) < 0.0001)
