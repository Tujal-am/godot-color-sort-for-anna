extends GutTest

var service
var sauvegarde_joueur_initiale
var fichier_sauvegarde_initial
var configuration_initiale
var liste_des_scores_initiale
const RACINE_TEST = "tests/test_stats_service"
const SCORE_JOUEUR_TEST = 1000

func _nettoyer_fichiers_utilisateur():
	FichiersJsonService.effacer_racine_utilisateur()

func _activer_joueur_test():
	FichiersJsonService.write_json_file("test_stats_service.json", SauvegardeBddJoueursService._sauvegarde_joueur)
	assert_true(SauvegardeBddJoueursService.choisir_le_joueur("Joueur Test", "test_stats_service.json"))


func before_each():
	FichiersJsonService.definir_racine_utilisateur(RACINE_TEST)
	_nettoyer_fichiers_utilisateur()
	service = add_child_autofree(load("res://Singletons/stats_service.gd").new())
	sauvegarde_joueur_initiale = SauvegardeBddJoueursService._sauvegarde_joueur.duplicate(true)
	fichier_sauvegarde_initial = SauvegardeBddJoueursService.fichier_sauvegarde
	configuration_initiale = SauvegardeConfigurationService.configuration_du_jeu.duplicate(true)
	liste_des_scores_initiale = SauvegardeTableauDesScoresService.liste_des_scores.duplicate(true)

	SauvegardeConfigurationService.configuration_du_jeu["date_debut_campagne"] = "2020-01-01 00:00:00"
	SauvegardeTableauDesScoresService.liste_des_scores = [
		{"nom": "Joueur Test", "rang": 1, "score": SCORE_JOUEUR_TEST, "score_txt": "1.000"}
	]
	SauvegardeBddJoueursService._sauvegarde_joueur = {
		"nom": "Joueur Test",
		"nom_campagne": "campagne_test",
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
				"campagne": "campagne_test",
				"date_debut": 1700000000,
				"date_fin": 0,
				"score": {"niveau": 20, "niveau_parfait": 0},
				"niveaux": [
					{
						"niveau": "niveau_1",
						"date_debut": 1700000000,
						"date_fin": 1700001000,
						"score": {"niveau": 100, "niveau_parfait": 50},
						"plateaux": [
							{"nom": "A1", "date_debut": 1700000010, "date_fin": 1700000020, "duree": 10, "difficulte": 1, "statut": "reussi", "gameplay": "CLASSIQUE", "score": {"duree": 20, "ratio_reussite": 80}},
							{"nom": "B", "date_debut": 1700000020, "date_fin": 1700000031, "duree": 11, "difficulte": 2, "statut": "abandonné", "gameplay": "QUI_PERD_GAGNE", "score": {"duree": 5, "ratio_reussite": 10}},
							{"nom": "B", "date_debut": 1700000030, "date_fin": 1700000045, "duree": 15, "difficulte": 2, "statut": "reussi", "gameplay": "QUI_PERD_GAGNE", "score": {"duree": 30, "ratio_reussite": 90}},
							{"nom": "C", "date_debut": 1700000040, "date_fin": 1700000049, "duree": 9, "difficulte": 3, "statut": "reussi", "gameplay": "CLASSIQUE", "score": {"duree": 15, "ratio_reussite": 70}}
						]
					},
					{
						"niveau": "niveau_2",
						"date_debut": 1700002000,
						"date_fin": 0,
						"score": {"niveau": 20, "niveau_parfait": 0},
						"plateaux": [
							{"nom": "D", "date_debut": 1700002010, "date_fin": 1700002025, "duree": 15, "difficulte": 2, "statut": "reussi", "gameplay": "CLASSIQUE", "score": {"duree": 25, "ratio_reussite": 85}},
							{"nom": "A2", "date_debut": 1700002020, "date_fin": 1700002028, "duree": 8, "difficulte": 4, "statut": "reussi", "gameplay": "QUI_PERD_GAGNE", "score": {"duree": 40, "ratio_reussite": 95}}
						]
					}
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
	SauvegardeBddJoueursService._sauvegarde_joueur = sauvegarde_joueur_initiale
	SauvegardeBddJoueursService.fichier_sauvegarde = fichier_sauvegarde_initial
	SauvegardeConfigurationService.configuration_du_jeu = configuration_initiale
	SauvegardeTableauDesScoresService.liste_des_scores = liste_des_scores_initiale
	_nettoyer_fichiers_utilisateur()
	FichiersJsonService.reinitialiser_racine_utilisateur()


func test_campagne_et_niveau_statistiques():
	var campagne = SauvegardeBddJoueursService._sauvegarde_joueur.get("campagne", {})
	var historique = SauvegardeBddJoueursService._sauvegarde_joueur.get("enregistrement_campagne", [])

	assert_false("niveau_1" in campagne)
	assert_true("niveau_2" in campagne)
	assert_true("niveau_3" in campagne)
	assert_true(historique.size() >= 1)
	assert_eq(historique[0].get("niveaux")[0].get("niveau"), "niveau_1")
	assert_true("1" in SauvegardeBddJoueursService._sauvegarde_joueur.get("plateaux_libres", {}))
	assert_true("2" in SauvegardeBddJoueursService._sauvegarde_joueur.get("plateaux_libres", {}))
	assert_true("3" in SauvegardeBddJoueursService._sauvegarde_joueur.get("plateaux_libres", {}))
	assert_true("4" in SauvegardeBddJoueursService._sauvegarde_joueur.get("plateaux_libres", {}))

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
	# 5 plateaux réussis, 1 essai abandonné : 5 plateaux joués pour 6 essais
	assert_eq(service.plateau_nombre_de_plateaux_joues(), 5)
	assert_eq(service.plateau_nombre_essais_de_plateaux(), 6)
	assert_true(abs(service.plateau_taux_de_reussite() - (5.0 / 6.0)) < 0.0001)
	assert_true(abs(service.plateau_taux_de_realisation() - 1.0) < 0.0001)
	assert_true(abs(service.campagne_temps_total_en_s() - 68.0) < 0.0001)
	# Temps de tous les essais / nombre de plateaux réussis
	assert_true(abs(service.plateau_temps_moyen_en_s() - (68.0 / 5.0)) < 0.0001)

	var plus_rapide = service.plateau_plus_rapide_infos()
	assert_true(abs(plus_rapide.get("temps_en_s") - 8.0) < 0.0001)
	assert_eq(plus_rapide.get("difficulte"), 4)

	# B : essai abandonné (11 s) + essai réussi (15 s) cumulés
	var plus_lent = service.plateau_plus_lent_infos()
	assert_true(abs(plus_lent.get("temps_en_s") - 26.0) < 0.0001)
	assert_eq(plus_lent.get("difficulte"), 2)

	var plus_galere = service.plateau_plus_galere_infos()
	assert_eq(plus_galere.get("nom"), "B")
	assert_eq(plus_galere.get("essais"), 2)
	assert_eq(plus_galere.get("difficulte"), 2)

func test_statistiques_couvrent_les_branches_sans_plateaux_et_egalites():
	# Cas sans enregistrement de niveau : zéro/ratio limite
	SauvegardeBddJoueursService._sauvegarde_joueur["enregistrement_campagne"][0]["niveaux"] = []
	assert_eq(service.nombre_niveaux_termines(), 0)
	assert_eq(service.duree_moyenne_niveaux_terminees_en_s(), 0.0)
	assert_eq(service.taux_de_reussite_des_plateaux(), 0.0)
	assert_eq(service.taux_completion_niveau(), 0.0)
	assert_eq(service.plateau_le_plus_rapide_les_infos().get("temps_en_s"), 0.0)
	assert_eq(service.plateau_le_plus_lent_les_infos().get("temps_en_s"), 0.0)

	# Cas avec valeurs identiques : la difficulté la plus élevée doit être retenue
	SauvegardeBddJoueursService._sauvegarde_joueur["enregistrement_campagne"][0]["niveaux"] = [
		{
			"niveau": "niveau_1",
			"date_debut": 1700000000,
			"date_fin": 1700001000,
			"plateaux": [
				{"nom": "A", "date_debut": 1700000010, "date_fin": 1700000020, "duree": 10, "difficulte": 2, "statut": "reussi"},
				{"nom": "B", "date_debut": 1700000020, "date_fin": 1700000030, "duree": 10, "difficulte": 5, "statut": "reussi"}
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
	SauvegardeBddJoueursService._sauvegarde_joueur["enregistrement_campagne"][0]["niveaux"] = [
		{
			"niveau": "niveau_1",
			"date_debut": 1700000000,
			"date_fin": 1700001000,
			"plateaux": [
				{"nom": "B", "date_debut": 1700000010, "date_fin": 1700000015, "duree": 5, "difficulte": 2, "statut": "reussi"},
				{"nom": "B", "date_debut": 1700000020, "date_fin": 1700000027, "duree": 7, "difficulte": 3, "statut": "abandonné"},
				{"nom": "B", "date_debut": 1700000030, "date_fin": 1700000041, "duree": 11, "difficulte": 5, "statut": "reussi"}
			]
		}
	]
	var galere = service.plateau_le_plus_galere_les_infos()
	assert_eq(galere.get("nom"), "B")
	assert_eq(galere.get("essais"), 3)
	assert_eq(galere.get("difficulte"), 2)

	# Cas de reset de série et de max atteint : abandon = coupure de série
	SauvegardeBddJoueursService._sauvegarde_joueur["enregistrement_campagne"][0]["niveaux"] = [
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

	SauvegardeBddJoueursService._sauvegarde_joueur["enregistrement_campagne"][0]["niveaux"] = [
		{"niveau": "niveau_1", "date_debut": 1700000000, "date_fin": 1700001000, "plateaux": [
			{"nom": "A", "date_debut": 1700000010, "date_fin": 1700000020, "duree": 10, "difficulte": 2, "statut": "reussi"},
			{"nom": "B", "date_debut": 1700000020, "date_fin": 1700000040, "duree": 20, "difficulte": 5, "statut": "abandonné"}]
		},
		{"niveau": "niveau_2", "date_debut": 1700002000, "date_fin": 1700003000, "plateaux": []}
	]
	var infos_2 = service.niveau_taux_reussite_les_infos()
	assert_true(abs(infos_2.get("taux_min") - 0.5) < 0.0001)
	assert_eq(infos_2.get("taux_min_lg"), 1)
	assert_true(abs(infos_2.get("taux_max") - 0.5) < 0.0001)
	assert_eq(infos_2.get("taux_max_lg"), 1)

func test_reussis_abandonnes_par_niveau_et_completion_niveau_couvrent_les_zeros():
	var par_niveau = service.nombre_de_plateau_reussis_abandonnes_passes_pour_niveau("niveau_2")
	assert_eq(par_niveau.get("reussis"), 2)
	assert_eq(par_niveau.get("abandonnes"), 0)
	assert_true(abs(service.taux_completion_niveau() - (2.0 / 3.0)) < 0.0001)

	SauvegardeBddJoueursService._sauvegarde_joueur["campagne"] = {"niveau_99": []}
	SauvegardeBddJoueursService._sauvegarde_joueur["enregistrement_campagne"][0]["niveaux"] = [
		{"niveau": "niveau_99", "date_debut": 1700000000, "date_fin": 1700001000, "plateaux": []}
	]
	assert_eq(service.nombre_de_plateau_reussis_abandonnes_passes_pour_niveau("niveau_99").get("reussis"), 0)
	assert_true(abs(service.taux_completion_niveau()) < 0.0001)

func test_plateaux_passes_sont_comptes_et_interrompent_les_series_de_victoires():
	SauvegardeBddJoueursService._sauvegarde_joueur["enregistrement_campagne"][0]["niveaux"] = [
		{
			"niveau": "niveau_2",
			"date_debut": 1700002000,
			"date_fin": 1700003000,
			"plateaux": [
				{"nom": "C", "date_debut": 1700002010, "duree": 10, "difficulte": 1, "statut": "reussi", "gameplay": "CLASSIQUE"},
				{"nom": "D", "date_debut": 1700002020, "duree": 10, "difficulte": 1, "statut": "abandonné", "gameplay": "CLASSIQUE"},
				{"nom": "E", "date_debut": 1700002030, "duree": 10, "difficulte": 1, "statut": "reussi", "gameplay": "CLASSIQUE"},
				{"nom": "F", "date_debut": 1700002040, "duree": 10, "difficulte": 1, "statut": "reussi", "gameplay": "CLASSIQUE"}
			]
		},
		{
			"niveau": "niveau_1",
			"date_debut": 1700000000,
			"date_fin": 1700001000,
			"plateaux": [
				{"nom": "A", "date_debut": 1700000010, "duree": 10, "difficulte": 1, "statut": "reussi", "gameplay": "CLASSIQUE"},
				{"nom": "B", "date_debut": 1700000020, "duree": 10, "difficulte": 1, "statut": "reussi", "gameplay": "CLASSIQUE"},
				{"nom": "G", "date_debut": 1700000030, "duree": 10, "difficulte": 1, "statut": "passé", "gameplay": "CLASSIQUE"}
			]
		}
	]

	assert_eq(service.nombre_de_plateau_reussis_abandonnes_passes(), {
		"reussis": 5,
		"abandonnes": 1,
		"passes": 1
	})
	# Plateaux joués = réussis + passés ; essais = joués + abandonnés
	assert_eq(service.nombre_de_plateaux_joues(), 6)
	assert_eq(service.nombre_essais_de_plateaux(), 7)
	assert_true(abs(service.taux_de_realisation_des_plateaux() - (5.0 / 6.0)) < 0.0001)
	assert_true(abs(service.taux_de_reussite_des_plateaux() - (5.0 / 7.0)) < 0.0001)
	assert_eq(service.serie_de_victoire_maximum(), 2)

func test_statistiques_excluent_les_donnees_a_la_date_de_debut_de_campagne():
	var date_debut_campagne = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	SauvegardeBddJoueursService._sauvegarde_joueur["enregistrement_campagne"][0]["niveaux"].append({
		"niveau": "niveau_0",
		"date_debut": date_debut_campagne - 1,
		"date_fin": date_debut_campagne + 100,
		"plateaux": [
			{
				"nom": "Ancien",
				"date_debut": date_debut_campagne - 1,
				"date_fin": date_debut_campagne + 10,
				"duree": 999,
				"difficulte": 99,
				"statut": "reussi",
				"gameplay": "CLASSIQUE",
				"score": {"duree": 999, "ratio_reussite": 999}
			}
		]
	})

	assert_eq(service.nombre_de_plateaux_totaux(), 8)
	assert_true(abs(service.taux_completion_campagne() - (5.0 / 8.0)) < 0.0001)
	assert_eq(service.plateau_nombre_de_plateaux_joues(), 5)
	assert_eq(service.plateau_nombre_essais_de_plateaux(), 6)
	assert_true(abs(service.campagne_temps_total_en_s() - 68.0) < 0.0001)
	assert_eq(service.campagne_serie_max_reussite(), 4)
	assert_eq(service.detail_score_cumule().get("rapidite"), 135)
	assert_eq(service.detail_score_cumule().get("reussite"), 430)

func test_duree_moyenne_des_niveaux_termines_ne_compte_que_leurs_plateaux():
	var durees = service.duree_totale_plateaux_tous_les_niveaux_en_s()
	assert_eq(durees.get("toutes"), 68.0)
	assert_eq(durees.get("terminees"), 45.0)
	assert_eq(service.duree_moyenne_niveaux_terminees_en_s(), 45.0)

	SauvegardeBddJoueursService._sauvegarde_joueur["enregistrement_campagne"][0]["niveaux"][0]["plateaux"] = []
	assert_eq(service.nombre_niveaux_termines(), 1)
	assert_eq(service.duree_moyenne_niveaux_terminees_en_s(), 0.0)

func test_gameplay_statistiques_classique():
	assert_eq(service.classique_nombre_de_plateaux_joues(), 3)
	assert_true(abs(service.classique_taux_de_reussite() - 1.0) < 0.0001)
	assert_true(abs(service.classique_temps_moyen_en_s() - (34.0 / 3.0)) < 0.0001)

	var plus_rapide = service.classique_plus_rapide_infos()
	assert_true(abs(plus_rapide.get("temps_en_s") - 9.0) < 0.0001)
	assert_eq(plus_rapide.get("difficulte"), 3)

	var plus_lent = service.classique_plus_lent_infos()
	assert_true(abs(plus_lent.get("temps_en_s") - 15.0) < 0.0001)
	assert_eq(plus_lent.get("difficulte"), 2)

	var plus_galere = service.classique_plus_galere_infos()
	assert_eq(plus_galere.get("nom"), "A1")
	assert_eq(plus_galere.get("essais"), 1)
	assert_eq(plus_galere.get("difficulte"), 1)

func test_gameplay_statistiques_qui_perd_gagne():
	assert_eq(service.qui_perd_gagne_nombre_de_plateaux_joues(), 2)
	assert_eq(service.qui_perd_gagne_nombre_essais_de_plateaux(), 3)
	assert_true(abs(service.qui_perd_gagne_taux_de_reussite() - (2.0 / 3.0)) < 0.0001)
	assert_true(abs(service.qui_perd_gagne_temps_moyen_en_s() - (34.0 / 2.0)) < 0.0001)

	var plus_rapide = service.qui_perd_gagne_plus_rapide_infos()
	assert_true(abs(plus_rapide.get("temps_en_s") - 8.0) < 0.0001)
	assert_eq(plus_rapide.get("difficulte"), 4)

	var plus_lent = service.qui_perd_gagne_plus_lent_infos()
	assert_true(abs(plus_lent.get("temps_en_s") - 26.0) < 0.0001)
	assert_eq(plus_lent.get("difficulte"), 2)

	var plus_galere = service.qui_perd_gagne_plus_galere_infos()
	assert_eq(plus_galere.get("nom"), "B")
	assert_eq(plus_galere.get("essais"), 2)
	assert_eq(plus_galere.get("difficulte"), 2)

func test_gameplay_statistiques_sans_plateaux_retourne_zero():
	SauvegardeBddJoueursService._sauvegarde_joueur["enregistrement_campagne"][0]["niveaux"] = []
	assert_eq(service.classique_nombre_de_plateaux_joues(), 0)
	assert_eq(service.classique_taux_de_reussite(), 0.0)
	assert_eq(service.classique_temps_moyen_en_s(), 0.0)
	assert_eq(service.classique_plus_rapide_infos().get("temps_en_s"), 0.0)
	assert_eq(service.classique_plus_lent_infos().get("temps_en_s"), 0.0)
	assert_eq(service.classique_plus_galere_infos().get("nom"), "")

func test_score_detail_cumule_et_pourcentages():
	var detail = service.detail_score_cumule()
	assert_eq(detail.get("joueur"), "Joueur Test")
	assert_eq(detail.get("rapidite"), 135)
	assert_eq(detail.get("reussite"), 430)
	assert_eq(detail.get("niveau"), 120)
	assert_eq(detail.get("niveau_parfait"), 50)
	assert_eq(detail.get("fin_campagne"), 0)

	# Le total est la somme des détails (ici 735), et les parts sont calculées dessus
	var total = detail.get("rapidite") + detail.get("reussite") + detail.get("niveau") \
		+ detail.get("niveau_parfait") + detail.get("fin_campagne")
	assert_eq(total, 735)
	assert_eq(service.score_total(), total)
	assert_eq(service.score(), "735")
	assert_true(abs(service.score_pourcentage_rapidite() - (135.0 / total)) < 0.0001)
	assert_true(abs(service.score_pourcentage_reussite() - (430.0 / total)) < 0.0001)
	assert_true(abs(service.score_pourcentage_niveau() - (120.0 / total)) < 0.0001)
	assert_true(abs(service.score_pourcentage_niveau_parfait() - (50.0 / total)) < 0.0001)
	var somme = service.score_pourcentage_rapidite() + service.score_pourcentage_reussite() \
		+ service.score_pourcentage_niveau() + service.score_pourcentage_niveau_parfait() \
		+ service.score_pourcentage_fin_campagne()
	assert_true(abs(somme - 1.0) < 0.0001)
	assert_true(abs(service.score_pourcentage_fin_campagne()) < 0.0001)

func test_score_pourcentage_fin_campagne_quand_la_campagne_est_terminee():
	# Campagne terminée <=> plus aucun niveau actif dans 'campagne'.
	SauvegardeBddJoueursService._sauvegarde_joueur["campagne"] = {}
	var score_fin_campagne = roundi(ScoreService.FIN_CAMPAGNE * service.campagne_taux_reussite())
	SauvegardeBddJoueursService._sauvegarde_joueur["enregistrement_campagne"][0]["score"]["fin_campagne"] = score_fin_campagne
	assert_true(ProgressionCampagneService.la_campagne_est_terminee())
	assert_true(abs(service.score_pourcentage_fin_campagne() - (float(score_fin_campagne) / service.score_total())) < 0.0001)

func test_score_pourcentages_couvrent_le_cas_score_total_nul():
	SauvegardeBddJoueursService._sauvegarde_joueur["enregistrement_campagne"] = []
	assert_eq(service.score_total(), 0)
	assert_eq(service.score_pourcentage_rapidite(), 0.0)
	assert_eq(service.score_pourcentage_reussite(), 0.0)
	assert_eq(service.score_pourcentage_niveau(), 0.0)
	assert_eq(service.score_pourcentage_niveau_parfait(), 0.0)
	assert_eq(service.score_pourcentage_fin_campagne(), 0.0)


# ---------------------------------------------------------
# Aides
# ---------------------------------------------------------

const DATE_VALIDE = 1700000000

func _niveaux() -> Array:
	return SauvegardeBddJoueursService._sauvegarde_joueur["enregistrement_campagne"][0]["niveaux"]

func _definir_niveaux(niveaux: Array) -> void:
	SauvegardeBddJoueursService._sauvegarde_joueur["enregistrement_campagne"][0]["niveaux"] = niveaux

func _niveau(nom: String, plateaux: Array, termine: bool = true, debut: int = DATE_VALIDE) -> Dictionary:
	return {"niveau": nom, "date_debut": debut, "date_fin": debut + 1000 if termine else 0, "score": {}, "plateaux": plateaux}

func _plateau(nom: String, statut: String, duree: float, difficulte: int, gameplay: String = "CLASSIQUE", debut: int = DATE_VALIDE + 10) -> Dictionary:
	return {"nom": nom, "date_debut": debut, "duree": duree, "difficulte": difficulte, "statut": statut, "gameplay": gameplay, "score": {}}

func _campagne_suivante() -> Dictionary:
	return {
		"campagne": "campagne_suivante",
		"date_debut": DATE_VALIDE + 100000,
		"date_fin": 0,
		"score": {"fin_campagne": 900},
		"niveaux": [{
			"niveau": "niveau_1",
			"date_debut": DATE_VALIDE + 100000,
			"date_fin": DATE_VALIDE + 101000,
			"score": {"niveau": 40, "niveau_parfait": 0},
			"plateaux": [
				{"nom": "N1", "date_debut": DATE_VALIDE + 100010, "duree": 4, "difficulte": 3, "statut": "reussi", "gameplay": "CLASSIQUE", "score": {"duree": 7, "ratio_reussite": 8}},
				{"nom": "N2", "date_debut": DATE_VALIDE + 100020, "duree": 6, "difficulte": 5, "statut": "abandonné", "gameplay": "QUI_PERD_GAGNE", "score": {"duree": 1, "ratio_reussite": 2}}
			]
		}]
	}


# ---------------------------------------------------------
# Score : pourcentages
# ---------------------------------------------------------

func test_score_total_pourcentages_appel_direct_egal_aux_alias():
	assert_eq(service.score_total_pourcentage_rapidite(), service.score_pourcentage_rapidite())
	assert_eq(service.score_total_pourcentage_reussite(), service.score_pourcentage_reussite())
	assert_eq(service.score_total_pourcentage_niveau(), service.score_pourcentage_niveau())
	assert_eq(service.score_total_pourcentage_niveau_parfait(), service.score_pourcentage_niveau_parfait())
	assert_eq(service.score_total_pourcentage_fin_campagne(), service.score_pourcentage_fin_campagne())
	assert_almost_eq(service.score_total_pourcentage_rapidite(), 135.0 / 735.0, 0.0001)
	assert_almost_eq(service.score_total_pourcentage_reussite(), 430.0 / 735.0, 0.0001)
	assert_almost_eq(service.score_total_pourcentage_niveau(), 120.0 / 735.0, 0.0001)
	assert_almost_eq(service.score_total_pourcentage_niveau_parfait(), 50.0 / 735.0, 0.0001)

func test_score_total_pourcentage_une_seule_composante_vaut_un():
	SauvegardeBddJoueursService._sauvegarde_joueur["enregistrement_campagne"][0]["score"] = {"fin_campagne": 500}
	_definir_niveaux([])
	assert_eq(service.score_total(), 500)
	assert_eq(service.score_total_pourcentage_fin_campagne(), 1.0)
	assert_eq(service.score_total_pourcentage_rapidite(), 0.0)
	assert_eq(service.score_total_pourcentage_reussite(), 0.0)
	assert_eq(service.score_total_pourcentage_niveau(), 0.0)
	assert_eq(service.score_total_pourcentage_niveau_parfait(), 0.0)

func test_score_formate_avec_separateur_de_milliers():
	SauvegardeBddJoueursService._sauvegarde_joueur["enregistrement_campagne"][0]["score"] = {"fin_campagne": 1234567}
	_definir_niveaux([])
	assert_eq(service.score_total(), 1234567)
	assert_eq(service.score(), "1.234.567")

func test_score_zero_sans_donnees():
	_definir_niveaux([])
	assert_eq(service.score(), "0")

func test_detail_score_fin_campagne_ignore_si_campagne_commencee_avant_la_date_de_debut():
	var campagne = SauvegardeBddJoueursService._sauvegarde_joueur["enregistrement_campagne"][0]
	campagne["date_debut"] = 1000
	campagne["score"]["fin_campagne"] = 500
	var detail = service.detail_score_cumule()
	assert_eq(detail.get("fin_campagne"), 0)
	assert_eq(detail.get("niveau"), 120)

func test_detail_score_fin_campagne_pris_en_compte_a_la_date_exacte_de_debut():
	var campagne = SauvegardeBddJoueursService._sauvegarde_joueur["enregistrement_campagne"][0]
	campagne["date_debut"] = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	campagne["score"]["fin_campagne"] = 500
	assert_eq(service.detail_score_cumule().get("fin_campagne"), 500)

func test_detail_score_cumule_ignore_les_niveaux_et_plateaux_anterieurs_a_la_date_de_debut():
	var date_debut = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	var ancien_niveau = _niveau("niveau_0", [_plateau("Ancien", "reussi", 5, 1, "CLASSIQUE", date_debut - 5)], true, date_debut - 10)
	ancien_niveau["score"] = {"niveau": 1000, "niveau_parfait": 1000}
	ancien_niveau["plateaux"][0]["score"] = {"duree": 1000, "ratio_reussite": 1000}
	_niveaux().append(ancien_niveau)
	var niveau_recent = _niveau("niveau_9", [_plateau("Ancien2", "reussi", 5, 1, "CLASSIQUE", date_debut - 5)], true, DATE_VALIDE)
	niveau_recent["plateaux"][0]["score"] = {"duree": 1000, "ratio_reussite": 1000}
	_niveaux().append(niveau_recent)
	var detail = service.detail_score_cumule()
	assert_eq(detail.get("rapidite"), 135)
	assert_eq(detail.get("reussite"), 430)
	assert_eq(detail.get("niveau"), 120)
	assert_eq(detail.get("niveau_parfait"), 50)

func test_detail_score_cumule_sans_joueur_ni_donnees():
	SauvegardeBddJoueursService.liberer_le_joueur()
	var detail = service.detail_score_cumule()
	assert_eq(detail.get("joueur"), "")
	assert_eq(detail.get("rapidite"), 0)
	assert_eq(detail.get("reussite"), 0)
	assert_eq(detail.get("niveau"), 0)
	assert_eq(detail.get("niveau_parfait"), 0)
	assert_eq(detail.get("fin_campagne"), 0)
	assert_eq(service.score_total(), 0)

func test_detail_score_cumule_a_la_date_exacte_de_debut_incoherent_avec_les_autres_statistiques():
	# Les scores retiennent date_debut == date de début de campagne ('<' -> continue),
	# alors que les autres statistiques l'excluent ('>' strict).
	var date_debut = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	var niveau = _niveau("niveau_9", [_plateau("Pile", "reussi", 5, 1, "CLASSIQUE", date_debut)], true, date_debut)
	niveau["score"] = {"niveau": 7, "niveau_parfait": 0}
	_definir_niveaux([niveau])
	assert_eq(service.detail_score_cumule().get("niveau"), 7)
	assert_eq(service.nombre_niveaux_termines(), 0)
	assert_eq(service.nombre_de_plateaux_joues(), 0)
	assert_eq(service.nombre_essais_de_plateaux(), 0)


# ---------------------------------------------------------
# Aucune donnée / division par zéro
# ---------------------------------------------------------

func test_statistiques_sans_enregistrement_de_campagne():
	SauvegardeBddJoueursService._sauvegarde_joueur["enregistrement_campagne"] = []
	SauvegardeBddJoueursService._sauvegarde_joueur["campagne"] = {}
	assert_eq(service.nombre_de_plateau_inacheves(), 0)
	assert_eq(service.nombre_de_plateau_acheves(), 0)
	assert_eq(service.nombre_de_plateaux_totaux(), 0)
	assert_eq(service.taux_completion_campagne(), 0.0)
	assert_eq(service.campagne_taux_completion(), 0.0)
	assert_eq(service.taux_completion_niveau(), 0.0)
	assert_eq(service.niveau_taux_completion(), 0.0)
	assert_eq(service.duree_totale_plateaux_tous_les_niveaux_en_s(), {"toutes": 0.0, "terminees": 0.0})
	assert_eq(service.campagne_temps_total_en_s(), 0.0)
	assert_eq(service.nombre_niveaux_termines(), 0)
	assert_eq(service.niveau_terminees(), 0)
	assert_eq(service.duree_moyenne_niveaux_terminees_en_s(), 0.0)
	assert_eq(service.nombre_de_plateau_reussis_abandonnes_passes(), {"reussis": 0, "abandonnes": 0, "passes": 0})
	assert_eq(service.nombre_de_plateaux_joues(), 0)
	assert_eq(service.nombre_essais_de_plateaux(), 0)
	assert_eq(service.taux_de_reussite_des_plateaux(), 0.0)
	assert_eq(service.taux_de_realisation_des_plateaux(), 0.0)
	assert_eq(service.campagne_taux_reussite(), 0.0)
	assert_eq(service.longueur_max_niveau_termine(), 0)
	assert_eq(service.niveau_longueur_max(), 0)
	assert_eq(service.serie_de_victoire_maximum(), 0)
	assert_eq(service.campagne_serie_max_reussite(), 0)
	assert_eq(service.plateau_le_temps_moyen_en_s(), 0.0)
	assert_eq(service.plateau_temps_moyen_en_s(), 0.0)
	assert_eq(service.plateau_le_plus_rapide_les_infos(), {"temps_en_s": 0.0, "difficulte": 0})
	assert_eq(service.plateau_le_plus_lent_les_infos(), {"temps_en_s": 0.0, "difficulte": 0})
	assert_eq(service.plateau_le_plus_galere_les_infos(), {"nom": "", "essais": 0, "difficulte": 0})
	assert_eq(service.niveau_taux_reussite_les_infos(), {
		"taux_min": 0.0, "taux_min_lg": 0, "taux_min_niveau": 0,
		"taux_max": 0.0, "taux_max_lg": 0, "taux_max_niveau": 0
	})
	assert_eq(service.score_total(), 0)

func test_statistiques_sans_joueur_selectionne():
	SauvegardeBddJoueursService.liberer_le_joueur()
	assert_eq(service.campagne_nom_joueur(), "")
	assert_eq(service.nombre_de_plateaux_totaux(), 0)
	assert_eq(service.taux_completion_campagne(), 0.0)
	assert_eq(service.taux_completion_niveau(), 0.0)
	assert_eq(service.nombre_niveaux_termines(), 0)
	assert_eq(service.taux_de_reussite_des_plateaux(), 0.0)
	assert_eq(service.longueur_max_niveau_termine(), 0)
	assert_eq(service.serie_de_victoire_maximum(), 0)
	assert_eq(service.plateau_le_plus_galere_les_infos().get("essais"), 0)
	assert_eq(service.classique_nombre_de_plateaux_joues(), 0)
	assert_eq(service.qui_perd_gagne_taux_de_reussite(), 0.0)

func test_taux_completion_campagne_vaut_un_quand_il_ne_reste_aucun_plateau():
	SauvegardeBddJoueursService._sauvegarde_joueur["campagne"] = {}
	assert_eq(service.nombre_de_plateau_inacheves(), 0)
	assert_eq(service.nombre_de_plateaux_totaux(), 5)
	assert_eq(service.taux_completion_campagne(), 1.0)

func test_taux_completion_campagne_sans_cle_campagne_ne_divise_pas_par_zero():
	SauvegardeBddJoueursService._sauvegarde_joueur.erase("campagne")
	SauvegardeBddJoueursService._sauvegarde_joueur["enregistrement_campagne"] = []
	assert_eq(service.nombre_de_plateau_inacheves(), 0)
	assert_eq(service.taux_completion_campagne(), 0.0)

func test_nombre_de_plateau_inacheves_compte_tous_les_niveaux_actifs():
	SauvegardeBddJoueursService._sauvegarde_joueur["campagne"]["niveau_4"] = [{"nom": "X"}, {"nom": "Y"}, {"nom": "Z"}]
	assert_eq(service.nombre_de_plateau_inacheves(), 6)
	SauvegardeBddJoueursService._sauvegarde_joueur["campagne"]["niveau_5"] = []
	assert_eq(service.nombre_de_plateau_inacheves(), 6)

func test_taux_completion_campagne_compte_les_plateaux_passes_comme_acheves():
	_definir_niveaux([_niveau("niveau_1", [
		_plateau("A", "reussi", 5, 1),
		_plateau("B", "passé", 0, 1),
		_plateau("C", "abandonné", 4, 1)
	])])
	# Un plateau passé n'est plus à jouer mais n'est pas réussi : il n'est pas compté comme achevé
	assert_eq(service.nombre_de_plateau_acheves(), 1)
	assert_eq(service.nombre_de_plateaux_totaux(), 4)
	assert_almost_eq(service.taux_completion_campagne(), 1.0 / 4.0, 0.0001)

func test_plateaux_en_cours_ne_sont_ni_acheves_ni_comptes_dans_le_taux_de_reussite():
	_definir_niveaux([_niveau("niveau_1", [
		_plateau("A", "reussi", 5, 1),
		_plateau("B", "en cours", 0, 1)
	], false)])
	assert_eq(service.nombre_de_plateau_reussis_abandonnes_passes(), {"reussis": 1, "abandonnes": 0, "passes": 0})
	assert_eq(service.nombre_de_plateaux_joues(), 1)
	assert_eq(service.nombre_essais_de_plateaux(), 1)
	assert_eq(service.taux_de_reussite_des_plateaux(), 1.0)

func test_taux_de_reussite_nul_quand_aucun_plateau_reussi():
	_definir_niveaux([_niveau("niveau_1", [
		_plateau("A", "abandonné", 5, 1),
		_plateau("B", "passé", 0, 1)
	])])
	assert_eq(service.nombre_de_plateaux_joues(), 1)
	assert_eq(service.nombre_essais_de_plateaux(), 2)
	assert_eq(service.taux_de_reussite_des_plateaux(), 0.0)
	assert_eq(service.taux_de_realisation_des_plateaux(), 0.0)


# ---------------------------------------------------------
# Plusieurs campagnes : seule la dernière compte
# ---------------------------------------------------------

func test_statistiques_ignorent_les_campagnes_precedentes():
	var ancienne = _campagne_suivante()
	ancienne["campagne"] = "campagne_ancienne"
	ancienne["date_debut"] = DATE_VALIDE - 5000
	ancienne["score"] = {"fin_campagne": 777777}
	SauvegardeBddJoueursService._sauvegarde_joueur["enregistrement_campagne"].push_front(ancienne)
	assert_eq(service.nombre_de_plateau_acheves(), 5)
	assert_eq(service.nombre_de_plateau_reussis_abandonnes_passes(), {"reussis": 5, "abandonnes": 1, "passes": 0})
	assert_eq(service.nombre_niveaux_termines(), 1)
	assert_eq(service.campagne_temps_total_en_s(), 68.0)
	assert_eq(service.campagne_serie_max_reussite(), 4)
	var detail = service.detail_score_cumule()
	assert_eq(detail.get("fin_campagne"), 0)
	assert_eq(service.score_total(), 735)

func test_statistiques_ne_lisent_que_la_derniere_campagne():
	SauvegardeBddJoueursService._sauvegarde_joueur["enregistrement_campagne"].append(_campagne_suivante())
	assert_eq(service.nombre_de_plateau_reussis_abandonnes_passes(), {"reussis": 1, "abandonnes": 1, "passes": 0})
	assert_eq(service.nombre_de_plateaux_joues(), 1)
	assert_eq(service.nombre_essais_de_plateaux(), 2)
	assert_eq(service.nombre_de_plateau_acheves(), 1)
	assert_eq(service.nombre_de_plateau_inacheves(), 3)
	assert_eq(service.nombre_de_plateaux_totaux(), 4)
	assert_almost_eq(service.taux_completion_campagne(), 0.25, 0.0001)
	assert_almost_eq(service.campagne_taux_reussite(), 0.5, 0.0001)
	assert_eq(service.campagne_serie_max_reussite(), 1)
	assert_eq(service.nombre_niveaux_termines(), 1)
	assert_eq(service.niveau_longueur_max(), 1)
	assert_eq(service.duree_totale_plateaux_tous_les_niveaux_en_s(), {"toutes": 10.0, "terminees": 10.0})
	assert_eq(service.duree_moyenne_niveaux_terminees_en_s(), 10.0)
	assert_eq(service.plateau_le_temps_moyen_en_s(), 10.0)
	assert_eq(service.plateau_le_plus_rapide_les_infos(), {"temps_en_s": 4.0, "difficulte": 3})
	assert_eq(service.plateau_le_plus_lent_les_infos(), {"temps_en_s": 4.0, "difficulte": 3})
	assert_eq(service.plateau_le_plus_galere_les_infos(), {"nom": "N1", "essais": 1, "difficulte": 3})
	assert_almost_eq(service.taux_completion_niveau(), 1.0, 0.0001)

func test_detail_score_et_gameplay_de_la_derniere_campagne():
	SauvegardeBddJoueursService._sauvegarde_joueur["enregistrement_campagne"].append(_campagne_suivante())
	var detail = service.detail_score_cumule()
	assert_eq(detail.get("rapidite"), 8)
	assert_eq(detail.get("reussite"), 10)
	assert_eq(detail.get("niveau"), 40)
	assert_eq(detail.get("niveau_parfait"), 0)
	assert_eq(detail.get("fin_campagne"), 900)
	assert_eq(service.score_total(), 958)
	assert_eq(service.classique_nombre_de_plateaux_joues(), 1)
	assert_eq(service.classique_taux_de_reussite(), 1.0)
	assert_eq(service.qui_perd_gagne_nombre_de_plateaux_joues(), 0)
	assert_eq(service.qui_perd_gagne_nombre_essais_de_plateaux(), 1)


# ---------------------------------------------------------
# Niveaux terminés
# ---------------------------------------------------------

func test_niveau_terminees_ignore_les_niveaux_en_cours_et_anterieurs():
	var date_debut = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	_definir_niveaux([
		_niveau("niveau_1", [_plateau("A", "reussi", 5, 1)], true),
		_niveau("niveau_2", [_plateau("B", "reussi", 5, 1)], true),
		_niveau("niveau_3", [_plateau("C", "reussi", 5, 1)], false),
		_niveau("niveau_0", [_plateau("D", "reussi", 5, 1)], true, date_debut - 10)
	])
	assert_eq(service.nombre_niveaux_termines(), 2)
	assert_eq(service.niveau_terminees(), 2)

func test_duree_moyenne_niveaux_terminees_divise_par_le_nombre_de_niveaux_termines():
	_definir_niveaux([
		_niveau("niveau_1", [_plateau("A", "reussi", 10, 1), _plateau("B", "abandonné", 6, 1)], true),
		_niveau("niveau_2", [_plateau("C", "reussi", 20, 1)], true),
		_niveau("niveau_3", [_plateau("D", "reussi", 100, 1)], false)
	])
	assert_eq(service.duree_totale_plateaux_tous_les_niveaux_en_s(), {"toutes": 136.0, "terminees": 36.0})
	assert_eq(service.duree_moyenne_niveaux_terminees_en_s(), 18.0)

func test_duree_totale_ignore_les_plateaux_sans_duree_et_les_plateaux_anterieurs():
	var date_debut = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	_definir_niveaux([_niveau("niveau_1", [
		_plateau("A", "reussi", 0, 1),
		_plateau("B", "reussi", 12.5, 1),
		_plateau("C", "reussi", 99, 1, "CLASSIQUE", date_debut - 1),
		{"nom": "D", "date_debut": DATE_VALIDE + 30, "statut": "reussi", "gameplay": "CLASSIQUE"}
	])])
	assert_eq(service.duree_totale_plateaux_tous_les_niveaux_en_s(), {"toutes": 12.5, "terminees": 12.5})

func test_niveau_longueur_max_retient_le_plus_long_niveau_termine():
	_definir_niveaux([
		_niveau("niveau_1", [_plateau("A", "reussi", 1, 1), _plateau("B", "reussi", 1, 1)], true),
		_niveau("niveau_2", [
			_plateau("C", "reussi", 1, 1), _plateau("D", "reussi", 1, 1),
			_plateau("E", "reussi", 1, 1), _plateau("F", "reussi", 1, 1),
			_plateau("G", "abandonné", 1, 1), _plateau("H", "abandonné", 1, 1)
		], true),
		_niveau("niveau_3", [_plateau("I", "reussi", 1, 1), _plateau("J", "reussi", 1, 1), _plateau("K", "reussi", 1, 1), _plateau("L", "reussi", 1, 1), _plateau("M", "reussi", 1, 1)], false)
	])
	assert_eq(service.longueur_max_niveau_termine(), 4)
	assert_eq(service.niveau_longueur_max(), 4)

func test_longueur_max_ignore_niveau_termine_sans_plateaux_et_niveau_anterieur():
	var date_debut = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	_definir_niveaux([
		_niveau("niveau_1", [], true),
		_niveau("niveau_0", [_plateau("A", "reussi", 1, 1), _plateau("B", "reussi", 1, 1)], true, date_debut - 10)
	])
	assert_eq(service.longueur_max_niveau_termine(), 0)

func test_longueur_max_niveau_termine_ne_compte_pas_les_plateaux_passes():
	# Comportement actuel (discutable) : seuls les plateaux 'reussi' comptent dans la longueur.
	_definir_niveaux([_niveau("niveau_1", [
		_plateau("A", "reussi", 1, 1), _plateau("B", "reussi", 1, 1),
		_plateau("C", "passé", 0, 1), _plateau("D", "passé", 0, 1)
	], true)])
	assert_eq(service.longueur_max_niveau_termine(), 2)

func test_longueur_max_niveau_termine_ex_aequo_garde_le_premier():
	_definir_niveaux([
		_niveau("niveau_1", [_plateau("A", "reussi", 1, 1), _plateau("B", "reussi", 1, 1)], true),
		_niveau("niveau_2", [_plateau("C", "reussi", 1, 1), _plateau("D", "reussi", 1, 1)], true)
	])
	assert_eq(service.longueur_max_niveau_termine(), 2)

func test_niveau_taux_reussite_infos_retourne_les_niveaux_min_et_max():
	_definir_niveaux([
		_niveau("niveau_1", [_plateau("A", "reussi", 1, 1), _plateau("B", "abandonné", 1, 1)], true),
		_niveau("niveau_2", [_plateau("C", "reussi", 1, 1), _plateau("D", "reussi", 1, 1), _plateau("E", "reussi", 1, 1)], true),
		_niveau("niveau_3", [_plateau("F", "passé", 0, 1)], true)
	])
	var infos = service.niveau_taux_reussite_les_infos()
	assert_eq(infos.get("taux_min"), 0.0)
	assert_eq(infos.get("taux_min_lg"), 0)
	assert_eq(infos.get("taux_min_niveau"), 3)
	assert_eq(infos.get("taux_max"), 1.0)
	assert_eq(infos.get("taux_max_lg"), 3)
	assert_eq(infos.get("taux_max_niveau"), 2)
	assert_eq(service.niveau_taux_reussite_infos(), infos)

func test_niveau_taux_reussite_infos_ex_aequo_cherche_le_niveau_min_et_le_niveau_max():
	_definir_niveaux([
		_niveau("niveau_4", [_plateau("A", "reussi", 1, 1), _plateau("B", "abandonné", 1, 1)], true),
		_niveau("niveau_5", [_plateau("C", "reussi", 1, 1), _plateau("D", "abandonné", 1, 1)], true)
	])
	var infos = service.niveau_taux_reussite_les_infos()
	assert_eq(infos.get("taux_min"), 0.5)
	assert_eq(infos.get("taux_max"), 0.5)
	assert_eq(infos.get("taux_min_niveau"), 4)
	assert_eq(infos.get("taux_max_niveau"), 5)

func test_niveau_taux_reussite_infos_niveau_sans_nom():
	_definir_niveaux([{"date_debut": DATE_VALIDE, "date_fin": DATE_VALIDE + 1, "plateaux": [_plateau("A", "reussi", 1, 1)]}])
	var infos = service.niveau_taux_reussite_les_infos()
	assert_eq(infos.get("taux_max_niveau"), 0)

func test_reussis_abandonnes_passes_pour_niveau():
	_definir_niveaux([
		_niveau("niveau_1", [_plateau("A", "reussi", 1, 1), _plateau("B", "passé", 0, 1)], true),
		_niveau("niveau_2", [_plateau("C", "abandonné", 1, 1), _plateau("D", "abandonné", 1, 1), _plateau("E", "reussi", 1, 1)], true)
	])
	assert_eq(service.nombre_de_plateau_reussis_abandonnes_passes_pour_niveau("niveau_1"),
		{"niveau": "niveau_1", "reussis": 1, "abandonnes": 0, "passes": 1})
	assert_eq(service.nombre_de_plateau_reussis_abandonnes_passes_pour_niveau("niveau_2"),
		{"niveau": "niveau_2", "reussis": 1, "abandonnes": 2, "passes": 0})
	assert_eq(service.nombre_de_plateau_reussis_abandonnes_passes_pour_niveau("niveau_inconnu"),
		{"niveau": "niveau_inconnu", "reussis": 0, "abandonnes": 0, "passes": 0})

func test_taux_completion_niveau_compte_les_plateaux_passes_et_restants():
	SauvegardeBddJoueursService._sauvegarde_joueur["campagne"] = {"niveau_2": [{"nom": "R", "difficulte": 2}, {"nom": "S", "difficulte": 2}]}
	_definir_niveaux([_niveau("niveau_2", [
		_plateau("A", "reussi", 1, 2),
		_plateau("B", "passé", 0, 2),
		_plateau("C", "abandonné", 1, 2)
	], false)])
	assert_almost_eq(service.taux_completion_niveau(), 2.0 / 4.0, 0.0001)

func test_taux_completion_niveau_vaut_un_sans_plateau_restant():
	SauvegardeBddJoueursService._sauvegarde_joueur["campagne"] = {}
	_definir_niveaux([_niveau("niveau_2", [_plateau("A", "reussi", 1, 2), _plateau("B", "reussi", 1, 2)], true)])
	assert_eq(service.taux_completion_niveau(), 1.0)

func test_taux_completion_niveau_vaut_zero_sans_plateau_realise():
	_definir_niveaux([_niveau("niveau_2", [], false)])
	assert_eq(service.taux_completion_niveau(), 1.0 * 0 / 1)


# ---------------------------------------------------------
# Plateaux : temps moyen, plus rapide, plus lent, plus galère
# ---------------------------------------------------------

func test_plateau_temps_moyen_cumule_tous_les_essais_et_divise_par_les_plateaux_reussis():
	_definir_niveaux([_niveau("niveau_1", [
		_plateau("A", "reussi", 10, 1),
		_plateau("B", "reussi", 20, 1),
		_plateau("C", "abandonné", 100, 1),
		_plateau("D", "passé", 50, 1),
		_plateau("E", "reussi", 0, 1)
	])])
	# (10 + 20 + 100 + 50 + 0) s cumulés sur 3 plateaux réussis
	assert_eq(service.plateau_le_temps_moyen_en_s(), 60.0)
	assert_eq(service.plateau_temps_moyen_en_s(), 60.0)

func test_plateau_temps_moyen_ignore_les_niveaux_anterieurs_a_la_date_de_debut():
	var date_debut = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	_definir_niveaux([
		_niveau("niveau_0", [_plateau("A", "reussi", 1000, 1)], true, date_debut - 10),
		_niveau("niveau_1", [_plateau("B", "reussi", 8, 1)], true)
	])
	assert_eq(service.plateau_le_temps_moyen_en_s(), 8.0)

func test_plateau_plus_rapide_et_plus_lent_cumulent_les_essais_jusquau_plateau_reussi():
	_definir_niveaux([_niveau("niveau_1", [
		_plateau("A", "abandonné", 1, 9),
		_plateau("B", "passé", 2, 9),
		_plateau("C", "reussi", 30, 3),
		_plateau("D", "abandonné", 5, 4),
		_plateau("E", "reussi", 7, 4),
		_plateau("F", "reussi", 50, 6)
	])])
	# Le plateau passé remet le cumul à zéro ; E cumule l'essai abandonné D : 12 s
	assert_eq(service.plateau_plus_rapide_infos(), {"temps_en_s": 12.0, "difficulte": 4})
	assert_eq(service.plateau_plus_lent_infos(), {"temps_en_s": 50.0, "difficulte": 6})

func test_plateau_plus_rapide_ex_aequo_retient_la_difficulte_la_plus_elevee_quelque_soit_lordre():
	_definir_niveaux([_niveau("niveau_1", [
		_plateau("A", "reussi", 10, 5),
		_plateau("B", "reussi", 10, 2)
	])])
	assert_eq(service.plateau_le_plus_rapide_les_infos().get("temps_en_s"), 10.0)
	assert_eq(service.plateau_le_plus_rapide_les_infos().get("difficulte"), 5)

func test_plateau_plus_lent_ex_aequo_retient_la_difficulte_la_plus_elevee_quelque_soit_lordre():
	_definir_niveaux([_niveau("niveau_1", [
		_plateau("A", "reussi", 10, 5),
		_plateau("B", "reussi", 10, 2)
	])])
	assert_eq(service.plateau_le_plus_lent_les_infos().get("temps_en_s"), 10.0)
	assert_eq(service.plateau_le_plus_lent_les_infos().get("difficulte"), 5)

func test_plateau_plus_galere_premier_ex_aequo_conserve():
	_definir_niveaux([_niveau("niveau_1", [
		_plateau("A", "abandonné", 1, 2),
		_plateau("A", "reussi", 1, 2),
		_plateau("B", "abandonné", 1, 7),
		_plateau("B", "reussi", 1, 7)
	])])
	assert_eq(service.plateau_le_plus_galere_les_infos(), {"nom": "A", "essais": 2, "difficulte": 2})
	assert_eq(service.plateau_plus_galere_infos(), {"nom": "A", "essais": 2, "difficulte": 2})

func test_plateau_plus_galere_cumule_les_essais_a_travers_les_niveaux_et_les_statuts():
	_definir_niveaux([
		_niveau("niveau_1", [_plateau("A", "abandonné", 1, 4), _plateau("B", "reussi", 1, 1)], true),
		_niveau("niveau_2", [_plateau("A", "passé", 0, 4), _plateau("A", "reussi", 1, 4)], true)
	])
	assert_eq(service.plateau_le_plus_galere_les_infos(), {"nom": "A", "essais": 3, "difficulte": 4})

func test_plateau_plus_galere_regroupe_les_plateaux_sans_nom():
	_definir_niveaux([_niveau("niveau_1", [
		{"date_debut": DATE_VALIDE + 10, "difficulte": 3, "statut": "reussi", "gameplay": "CLASSIQUE"},
		{"date_debut": DATE_VALIDE + 20, "difficulte": 3, "statut": "reussi", "gameplay": "CLASSIQUE"},
		_plateau("B", "reussi", 1, 1)
	])])
	assert_eq(service.plateau_le_plus_galere_les_infos(), {"nom": "inconnu", "essais": 2, "difficulte": 3})

func test_plateau_plus_galere_ignore_les_niveaux_anterieurs():
	var date_debut = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	_definir_niveaux([
		_niveau("niveau_0", [_plateau("Z", "abandonné", 1, 9), _plateau("Z", "abandonné", 1, 9)], true, date_debut - 10),
		_niveau("niveau_1", [_plateau("A", "reussi", 1, 1)], true)
	])
	assert_eq(service.plateau_le_plus_galere_les_infos(), {"nom": "A", "essais": 1, "difficulte": 1})

func test_plateau_difficulte_flottante_est_arrondie():
	_definir_niveaux([_niveau("niveau_1", [_plateau("A", "reussi", 10, 1)])])
	_niveaux()[0]["plateaux"][0]["difficulte"] = 10.6
	assert_eq(service.plateau_le_plus_rapide_les_infos().get("difficulte"), 11)
	assert_eq(service.plateau_le_plus_lent_les_infos().get("difficulte"), 11)
	assert_eq(service.plateau_le_plus_galere_les_infos().get("difficulte"), 11)


# ---------------------------------------------------------
# Série de victoires
# ---------------------------------------------------------

func test_serie_de_victoire_classe_les_niveaux_par_ordre_chronologique():
	_definir_niveaux([
		_niveau("niveau_2", [
			_plateau("C", "reussi", 1, 1), _plateau("D", "reussi", 1, 1),
			_plateau("E", "abandonné", 1, 1), _plateau("F", "reussi", 1, 1)
		], true, DATE_VALIDE + 2000),
		_niveau("niveau_1", [_plateau("A", "reussi", 1, 1), _plateau("B", "reussi", 1, 1)], true, DATE_VALIDE)
	])
	assert_eq(service.serie_de_victoire_maximum(), 4)

func test_serie_de_victoire_ne_modifie_pas_lordre_des_niveaux_enregistres():
	_definir_niveaux([
		_niveau("niveau_2", [_plateau("C", "reussi", 1, 1)], true, DATE_VALIDE + 2000),
		_niveau("niveau_1", [_plateau("A", "reussi", 1, 1)], true, DATE_VALIDE)
	])
	service.serie_de_victoire_maximum()
	assert_eq(_niveaux()[0].get("niveau"), "niveau_2")
	assert_eq(_niveaux()[1].get("niveau"), "niveau_1")

func test_serie_de_victoire_coupee_par_abandon_et_passage_pas_par_en_cours():
	_definir_niveaux([_niveau("niveau_1", [
		_plateau("A", "reussi", 1, 1),
		_plateau("B", "en cours", 0, 1),
		_plateau("C", "reussi", 1, 1),
		_plateau("D", "passé", 0, 1),
		_plateau("E", "reussi", 1, 1),
		_plateau("F", "abandonné", 1, 1)
	])])
	assert_eq(service.serie_de_victoire_maximum(), 2)

func test_serie_de_victoire_derniere_serie_et_sans_defaite():
	_definir_niveaux([_niveau("niveau_1", [
		_plateau("A", "reussi", 1, 1), _plateau("B", "reussi", 1, 1), _plateau("C", "reussi", 1, 1)
	])])
	assert_eq(service.serie_de_victoire_maximum(), 3)

func test_serie_de_victoire_nulle_si_que_des_defaites():
	_definir_niveaux([_niveau("niveau_1", [_plateau("A", "abandonné", 1, 1), _plateau("B", "passé", 0, 1)])])
	assert_eq(service.serie_de_victoire_maximum(), 0)

func test_serie_de_victoire_ignore_les_niveaux_anterieurs_a_la_date_de_debut():
	var date_debut = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	_definir_niveaux([
		_niveau("niveau_0", [_plateau("A", "reussi", 1, 1), _plateau("B", "reussi", 1, 1), _plateau("C", "reussi", 1, 1)], true, date_debut - 10),
		_niveau("niveau_1", [_plateau("D", "reussi", 1, 1)], true)
	])
	assert_eq(service.serie_de_victoire_maximum(), 1)


# ---------------------------------------------------------
# Gameplay
# ---------------------------------------------------------

func _definir_niveau_gameplays() -> void:
	_definir_niveaux([_niveau("niveau_1", [
		_plateau("a", "reussi", 10, 2, "CLASSIQUE"),
		_plateau("b", "passé", 0, 2, "CLASSIQUE"),
		_plateau("c", "abandonné", 7, 3, "CLASSIQUE"),
		_plateau("d", "reussi", 0, 1, "CLASSIQUE"),
		_plateau("e", "reussi", 20, 4, "QUI_PERD_GAGNE")
	])])

func test_gameplay_appels_directs_sur_la_campagne_de_reference():
	assert_eq(service.gameplay_nombre_de_plateau_reussis_abandonnes_passes("CLASSIQUE"), {"reussis": 3, "abandonnes": 0, "passes": 0})
	assert_eq(service.gameplay_nombre_de_plateau_reussis_abandonnes_passes("QUI_PERD_GAGNE"), {"reussis": 2, "abandonnes": 1, "passes": 0})
	assert_eq(service.gameplay_nombre_de_plateaux_joues("CLASSIQUE"), 3)
	assert_eq(service.gameplay_nombre_essais_de_plateaux("CLASSIQUE"), 3)
	assert_eq(service.gameplay_nombre_de_plateaux_joues("QUI_PERD_GAGNE"), 2)
	assert_eq(service.gameplay_nombre_essais_de_plateaux("QUI_PERD_GAGNE"), 3)
	assert_almost_eq(service.gameplay_taux_de_reussite_des_plateaux("QUI_PERD_GAGNE"), 2.0 / 3.0, 0.0001)
	assert_almost_eq(service.gameplay_le_temps_moyen_en_s("CLASSIQUE"), 34.0 / 3.0, 0.0001)
	assert_eq(service.gameplay_le_plus_rapide_les_infos("CLASSIQUE"), {"temps_en_s": 9.0, "difficulte": 3})
	assert_eq(service.gameplay_le_plus_lent_les_infos("CLASSIQUE"), {"temps_en_s": 15.0, "difficulte": 2})
	assert_eq(service.gameplay_le_plus_galere_les_infos("QUI_PERD_GAGNE"), {"nom": "B", "essais": 2, "difficulte": 2})

func test_gameplay_est_insensible_a_la_casse():
	assert_eq(service.gameplay_nombre_de_plateaux_joues("classique"), 3)
	assert_eq(service.gameplay_nombre_de_plateaux_joues("Classique"), 3)
	assert_eq(service.gameplay_nombre_de_plateaux_joues("qui_perd_gagne"), 2)
	assert_eq(service.gameplay_le_plus_rapide_les_infos("classique"), service.gameplay_le_plus_rapide_les_infos("CLASSIQUE"))
	assert_eq(service.gameplay_le_plus_galere_les_infos("qui_perd_gagne"), service.gameplay_le_plus_galere_les_infos("QUI_PERD_GAGNE"))

func test_gameplay_inconnu_ou_vide_retourne_zero():
	for gameplay in ["INCONNU", ""]:
		assert_eq(service.gameplay_nombre_de_plateau_reussis_abandonnes_passes(gameplay), {"reussis": 0, "abandonnes": 0, "passes": 0})
		assert_eq(service.gameplay_nombre_de_plateaux_joues(gameplay), 0)
		assert_eq(service.gameplay_nombre_essais_de_plateaux(gameplay), 0)
		assert_eq(service.gameplay_taux_de_reussite_des_plateaux(gameplay), 0.0)
		assert_eq(service.gameplay_le_temps_moyen_en_s(gameplay), 0.0)
		assert_eq(service.gameplay_le_plus_rapide_les_infos(gameplay), {"temps_en_s": 0.0, "difficulte": 0})
		assert_eq(service.gameplay_le_plus_lent_les_infos(gameplay), {"temps_en_s": 0.0, "difficulte": 0})
		assert_eq(service.gameplay_le_plus_galere_les_infos(gameplay), {"nom": "", "essais": 0, "difficulte": 0})

func test_gameplay_statuts_mixtes_comptes_et_taux():
	_definir_niveau_gameplays()
	assert_eq(service.gameplay_nombre_de_plateau_reussis_abandonnes_passes("CLASSIQUE"), {"reussis": 2, "abandonnes": 1, "passes": 1})
	assert_eq(service.classique_nombre_de_plateaux_joues(), 3)
	assert_eq(service.classique_nombre_essais_de_plateaux(), 4)
	assert_eq(service.classique_taux_de_reussite(), 0.5)
	assert_eq(service.qui_perd_gagne_nombre_de_plateaux_joues(), 1)
	assert_eq(service.qui_perd_gagne_nombre_essais_de_plateaux(), 1)
	assert_eq(service.qui_perd_gagne_taux_de_reussite(), 1.0)

func test_gameplay_temps_moyen_cumule_tous_les_essais_sur_les_plateaux_reussis():
	_definir_niveau_gameplays()
	# CLASSIQUE : (10 + 0 + 7 + 0) s sur 2 plateaux réussis
	assert_eq(service.classique_temps_moyen_en_s(), 8.5)
	assert_eq(service.qui_perd_gagne_temps_moyen_en_s(), 20.0)

func test_gameplay_plus_rapide_plus_lent_cumulent_les_essais_abandonnes():
	_definir_niveau_gameplays()
	# d (réussi) cumule l'essai abandonné c : 7 s, le passé b remet le cumul à zéro
	assert_eq(service.classique_plus_rapide_infos(), {"temps_en_s": 7.0, "difficulte": 1})
	assert_eq(service.classique_plus_lent_infos(), {"temps_en_s": 10.0, "difficulte": 2})
	assert_eq(service.qui_perd_gagne_plus_rapide_infos(), {"temps_en_s": 20.0, "difficulte": 4})
	assert_eq(service.qui_perd_gagne_plus_lent_infos(), {"temps_en_s": 20.0, "difficulte": 4})

func test_gameplay_plus_galere_compte_tous_les_statuts_du_gameplay():
	_definir_niveau_gameplays()
	assert_eq(service.classique_plus_galere_infos(), {"nom": "a", "essais": 1, "difficulte": 2})
	assert_eq(service.qui_perd_gagne_plus_galere_infos(), {"nom": "e", "essais": 1, "difficulte": 4})

func test_gameplay_plus_rapide_et_plus_lent_ex_aequo_retiennent_la_difficulte_la_plus_elevee_quelque_soit_lordre():
	_definir_niveaux([_niveau("niveau_1", [
		_plateau("A", "reussi", 10, 5, "CLASSIQUE"),
		_plateau("B", "reussi", 10, 2, "CLASSIQUE")
	])])
	assert_eq(service.gameplay_le_plus_rapide_les_infos("CLASSIQUE").get("difficulte"), 5)
	assert_eq(service.gameplay_le_plus_lent_les_infos("CLASSIQUE").get("difficulte"), 5)

func test_gameplay_temps_moyen_ne_filtre_pas_les_plateaux_par_date_contrairement_aux_comptes():
	var date_debut = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	_definir_niveaux([
		_niveau("niveau_0", [_plateau("Z", "reussi", 1, 9, "CLASSIQUE", date_debut - 5)], true, date_debut - 10),
		_niveau("niveau_1", [
			_plateau("Y", "reussi", 1, 9, "CLASSIQUE", date_debut - 5),
			_plateau("A", "reussi", 6, 2, "CLASSIQUE")
		], true)
	])
	assert_eq(service.classique_nombre_de_plateaux_joues(), 1)
	assert_eq(service.classique_temps_moyen_en_s(), 3.5)

func test_gameplay_ignore_les_plateaux_sans_gameplay():
	# Un plateau importé (QR) sans clé 'gameplay' ne doit pas faire planter les statistiques.
	_definir_niveaux([_niveau("niveau_1", [
		_plateau("A", "reussi", 5, 1, "CLASSIQUE"),
		{"nom": "B", "date_debut": DATE_VALIDE + 20, "duree": 7, "difficulte": 2, "statut": "reussi"}
	])])
	assert_eq(service.classique_nombre_de_plateaux_joues(), 1)
	assert_eq(service.classique_taux_de_reussite(), 1.0)
	assert_eq(service.classique_temps_moyen_en_s(), 5.0)
	assert_eq(service.classique_plus_rapide_infos().get("temps_en_s"), 5.0)
	assert_eq(service.classique_plus_lent_infos().get("temps_en_s"), 5.0)
	assert_eq(service.classique_plus_galere_infos().get("nom"), "A")


# ---------------------------------------------------------
# Plateaux joués / essais de plateaux
# ---------------------------------------------------------

func test_plateaux_joues_et_essais_sont_distincts():
	_definir_niveaux([_niveau("niveau_1", [
		_plateau("A", "abandonné", 4, 1),
		_plateau("A", "abandonné", 3, 1),
		_plateau("A", "reussi", 5, 1),
		_plateau("B", "passé", 0, 1),
		_plateau("C", "reussi", 6, 1),
		_plateau("D", "en cours", 0, 1)
	])])
	assert_eq(service.nombre_de_plateau_reussis_abandonnes_passes(), {"reussis": 2, "abandonnes": 2, "passes": 1})
	assert_eq(service.nombre_de_plateaux_joues(), 3)
	assert_eq(service.plateau_nombre_de_plateaux_joues(), 3)
	assert_eq(service.nombre_essais_de_plateaux(), 5)
	assert_eq(service.plateau_nombre_essais_de_plateaux(), 5)
	assert_eq(service.classique_nombre_de_plateaux_joues(), 3)
	assert_eq(service.classique_nombre_essais_de_plateaux(), 5)
	assert_eq(service.qui_perd_gagne_nombre_de_plateaux_joues(), 0)
	assert_eq(service.qui_perd_gagne_nombre_essais_de_plateaux(), 0)

func test_taux_de_reussite_porte_sur_les_essais_et_taux_de_realisation_sur_les_plateaux_joues():
	_definir_niveaux([_niveau("niveau_1", [
		_plateau("A", "abandonné", 4, 1),
		_plateau("A", "reussi", 5, 1),
		_plateau("B", "passé", 0, 1),
		_plateau("C", "reussi", 6, 1)
	])])
	# 2 réussis sur 4 essais ; 2 réussis sur 3 plateaux joués (réussis + passés)
	assert_almost_eq(service.taux_de_reussite_des_plateaux(), 2.0 / 4.0, 0.0001)
	assert_almost_eq(service.plateau_taux_de_reussite(), 2.0 / 4.0, 0.0001)
	assert_almost_eq(service.taux_de_realisation_des_plateaux(), 2.0 / 3.0, 0.0001)
	assert_almost_eq(service.plateau_taux_de_realisation(), 2.0 / 3.0, 0.0001)

func test_taux_de_realisation_sans_reussi_ni_passe_vaut_zero():
	_definir_niveaux([_niveau("niveau_1", [_plateau("A", "abandonné", 4, 1)])])
	assert_eq(service.taux_de_realisation_des_plateaux(), 0.0)
	_definir_niveaux([])
	assert_eq(service.taux_de_realisation_des_plateaux(), 0.0)

func test_taux_de_realisation_vaut_zero_sans_reussi_avec_passe():
	_definir_niveaux([_niveau("niveau_1", [_plateau("A", "passé", 0, 1)])])
	assert_eq(service.taux_de_realisation_des_plateaux(), 0.0)
	assert_eq(service.nombre_de_plateaux_joues(), 1)

func test_gameplay_essais_et_plateaux_joues_distincts():
	_definir_niveaux([_niveau("niveau_1", [
		_plateau("A", "abandonné", 4, 1, "QUI_PERD_GAGNE"),
		_plateau("A", "reussi", 5, 1, "QUI_PERD_GAGNE"),
		_plateau("B", "passé", 0, 1, "QUI_PERD_GAGNE"),
		_plateau("C", "abandonné", 6, 1, "CLASSIQUE")
	])])
	assert_eq(service.qui_perd_gagne_nombre_de_plateaux_joues(), 2)
	assert_eq(service.qui_perd_gagne_nombre_essais_de_plateaux(), 3)
	assert_eq(service.classique_nombre_de_plateaux_joues(), 0)
	assert_eq(service.classique_nombre_essais_de_plateaux(), 1)
	assert_almost_eq(service.qui_perd_gagne_taux_de_reussite(), 1.0 / 3.0, 0.0001)


# ---------------------------------------------------------
# Temps cumulé sur tous les essais
# ---------------------------------------------------------

func test_temps_moyen_cumule_les_essais_abandonnes_et_passes():
	_definir_niveaux([_niveau("niveau_1", [
		_plateau("A", "abandonné", 10, 1),
		_plateau("A", "reussi", 20, 1),
		_plateau("B", "passé", 6, 1),
		_plateau("C", "reussi", 4, 1)
	])])
	# (10 + 20 + 6 + 4) s sur 2 plateaux réussis
	assert_eq(service.plateau_le_temps_moyen_en_s(), 20.0)

func test_temps_moyen_sans_plateau_reussi_vaut_zero():
	_definir_niveaux([_niveau("niveau_1", [_plateau("A", "abandonné", 10, 1), _plateau("B", "passé", 3, 1)])])
	assert_eq(service.plateau_le_temps_moyen_en_s(), 0.0)
	assert_eq(service.classique_temps_moyen_en_s(), 0.0)

func test_plus_rapide_et_plus_lent_le_passe_remet_le_cumul_a_zero():
	_definir_niveaux([_niveau("niveau_1", [
		_plateau("A", "abandonné", 100, 1),
		_plateau("B", "passé", 100, 1),
		_plateau("C", "reussi", 9, 2)
	])])
	assert_eq(service.plateau_le_plus_rapide_les_infos(), {"temps_en_s": 9.0, "difficulte": 2})
	assert_eq(service.plateau_le_plus_lent_les_infos(), {"temps_en_s": 9.0, "difficulte": 2})

func test_plus_rapide_et_plus_lent_le_cumul_traverse_les_niveaux():
	_definir_niveaux([
		_niveau("niveau_1", [_plateau("A", "abandonné", 10, 3)], false),
		_niveau("niveau_2", [_plateau("A", "reussi", 5, 3)], true, DATE_VALIDE + 2000)
	])
	assert_eq(service.plateau_le_plus_rapide_les_infos(), {"temps_en_s": 15.0, "difficulte": 3})
	assert_eq(service.plateau_le_plus_lent_les_infos(), {"temps_en_s": 15.0, "difficulte": 3})

func test_gameplay_cumul_ignore_les_plateaux_des_autres_gameplays():
	_definir_niveaux([_niveau("niveau_1", [
		_plateau("A", "abandonné", 10, 1, "QUI_PERD_GAGNE"),
		_plateau("B", "reussi", 3, 1, "CLASSIQUE"),
		_plateau("A", "reussi", 5, 1, "QUI_PERD_GAGNE")
	])])
	assert_eq(service.qui_perd_gagne_plus_lent_infos(), {"temps_en_s": 15.0, "difficulte": 1})
	assert_eq(service.classique_plus_lent_infos(), {"temps_en_s": 3.0, "difficulte": 1})
	assert_eq(service.qui_perd_gagne_temps_moyen_en_s(), 15.0)


# ---------------------------------------------------------
# Ratio min/max par niveau
# ---------------------------------------------------------

func test_niveau_taux_reussite_ratio_min_ex_aequo_retient_le_plus_bas_niveau_et_max_le_plus_haut():
	_definir_niveaux([
		_niveau("niveau_7", [_plateau("A", "reussi", 1, 1), _plateau("B", "abandonné", 1, 1)], true),
		_niveau("niveau_3", [_plateau("C", "reussi", 1, 1), _plateau("D", "abandonné", 1, 1)], true),
		_niveau("niveau_5", [_plateau("E", "reussi", 1, 1), _plateau("F", "abandonné", 1, 1)], true)
	])
	var infos = service.niveau_taux_reussite_les_infos()
	assert_eq(infos.get("taux_min"), 0.5)
	assert_eq(infos.get("taux_min_niveau"), 3)
	assert_eq(infos.get("taux_max"), 0.5)
	assert_eq(infos.get("taux_max_niveau"), 7)

func test_niveau_taux_reussite_ratio_compte_les_essais_abandonnes_et_passes():
	_definir_niveaux([
		_niveau("niveau_1", [_plateau("A", "abandonné", 1, 1), _plateau("A", "reussi", 1, 1), _plateau("B", "reussi", 1, 1)], true),
		_niveau("niveau_2", [_plateau("C", "reussi", 1, 1), _plateau("D", "passé", 0, 1)], true)
	])
	var infos = service.niveau_taux_reussite_les_infos()
	assert_almost_eq(infos.get("taux_min"), 0.5, 0.0001)
	assert_eq(infos.get("taux_min_lg"), 1)
	assert_eq(infos.get("taux_min_niveau"), 2)
	assert_almost_eq(infos.get("taux_max"), 2.0 / 3.0, 0.0001)
	assert_eq(infos.get("taux_max_lg"), 2)
	assert_eq(infos.get("taux_max_niveau"), 1)

func test_niveau_taux_reussite_un_seul_niveau_est_min_et_max():
	_definir_niveaux([_niveau("niveau_4", [_plateau("A", "reussi", 1, 1), _plateau("B", "abandonné", 1, 1)], true)])
	var infos = service.niveau_taux_reussite_les_infos()
	assert_eq(infos.get("taux_min_niveau"), 4)
	assert_eq(infos.get("taux_max_niveau"), 4)
	assert_eq(infos.get("taux_min_lg"), 1)
	assert_eq(infos.get("taux_max_lg"), 1)


# ---------------------------------------------------------
# Bonus de campagne : ratio de réussite x ratio de plateaux réalisés
# ---------------------------------------------------------

func _terminer_la_campagne_avec(plateaux: Array) -> void:
	SauvegardeBddJoueursService._sauvegarde_joueur["campagne"] = {}
	_definir_niveaux([_niveau("niveau_1", plateaux, true)])
	assert_true(ProgressionCampagneService.la_campagne_est_terminee())

func test_bonus_campagne_depend_du_ratio_de_reussite_et_des_plateaux_passes():
	_terminer_la_campagne_avec([
		_plateau("A", "reussi", 1, 1),
		_plateau("B", "reussi", 1, 1),
		_plateau("C", "reussi", 1, 1),
		_plateau("D", "abandonné", 1, 1),
		_plateau("E", "passé", 0, 1)
	])
	# réussite 3/5, réalisation 3/4
	assert_almost_eq(service.campagne_taux_reussite(), 3.0 / 5.0, 0.0001)
	assert_almost_eq(service.plateau_taux_de_realisation(), 3.0 / 4.0, 0.0001)
	var attendu = roundi(ScoreService.FIN_CAMPAGNE * (3.0 / 5.0) * (3.0 / 4.0))
	var resultat = ScoreService.mettre_a_jour_score_campagne()
	assert_eq(resultat.get("type"), "campagne")
	assert_eq(resultat.get("points"), attendu)
	assert_eq(service.detail_score_cumule().get("fin_campagne"), attendu)

func test_bonus_campagne_complet_sans_plateau_passe_ne_depend_que_de_la_reussite():
	_terminer_la_campagne_avec([
		_plateau("A", "abandonné", 1, 1),
		_plateau("A", "reussi", 1, 1),
		_plateau("B", "reussi", 1, 1)
	])
	var attendu = roundi(ScoreService.FIN_CAMPAGNE * (2.0 / 3.0))
	assert_eq(ScoreService.mettre_a_jour_score_campagne().get("points"), attendu)

func test_bonus_campagne_nul_si_tous_les_plateaux_sont_passes():
	_terminer_la_campagne_avec([_plateau("A", "passé", 0, 1), _plateau("B", "passé", 0, 1)])
	assert_eq(ScoreService.mettre_a_jour_score_campagne().get("points"), 0)

func test_bonus_campagne_non_attribue_tant_que_la_campagne_nest_pas_terminee():
	assert_false(ProgressionCampagneService.la_campagne_est_terminee())
	assert_eq(ScoreService.mettre_a_jour_score_campagne(), {})