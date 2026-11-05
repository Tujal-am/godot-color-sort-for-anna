extends GutTest

var service
var initial_liste_joueurs
var initial_bdd_joueur
var initial_bdd_fichier
var initial_tableau_scores
const RACINE_TEST = "tests/test_progression_campagne_service"

var detail_score_received = null
var fin_niveau_recu = false

func _nettoyer_fichiers_utilisateur():
	FichiersJsonService.effacer_racine_utilisateur()

func before_each():
	FichiersJsonService.definir_racine_utilisateur(RACINE_TEST)
	_nettoyer_fichiers_utilisateur()
	initial_liste_joueurs = SauvegardeListeJoueursService.liste_des_joueurs.duplicate(true)
	initial_bdd_joueur = SauvegardeBddJoueursService._sauvegarde_joueur.duplicate(true)
	initial_bdd_fichier = SauvegardeBddJoueursService.fichier_sauvegarde
	initial_tableau_scores = SauvegardeTableauDesScoresService.liste_des_scores.duplicate(true)
	service = add_child_autofree(load("res://Singletons/progression_campagne_service.gd").new())

	detail_score_received = null
	fin_niveau_recu = false

	SauvegardeListeJoueursService.liste_des_joueurs = [
		{"indice": 0, "nom": "Alpha", "fichier_sauvegarde": "sauvegarde_joueur_alpha.json"},
		{"indice": 1, "nom": "Beta", "fichier_sauvegarde": "sauvegarde_joueur_beta.json"}
	]
	SauvegardeTableauDesScoresService.liste_des_scores = [
		{"nom": "Alpha", "rang": 1, "score": 0, "score_txt": "0"},
		{"nom": "Beta", "rang": 2, "score": 0, "score_txt": "0"}
	]
	SauvegardeBddJoueursService.fichier_sauvegarde = ""
	SauvegardeBddJoueursService._sauvegarde_joueur = {}

	var plateaux_niveau_1 = [
		{"nom": "Q1", "date_debut": 110, "duree": 1000, "difficulte": 1, "statut": "reussi"}
	]
	var plateaux_niveau_2 = [
		{"nom": "Q2", "date_debut": 510, "duree": 1500, "difficulte": 2, "statut": "en_cours"}
	]
	FichiersJsonService.write_json_file("sauvegarde_joueur_alpha.json", {
		"nom": "Alpha",
		"campagne": {
			"niveau_2": [{"nom": "P2", "difficulte": 2, "gameplay": "CLASSIQUE"}],
			"niveau_3": [{"nom": "P3", "difficulte": 3, "gameplay": "DEFI_DU_GOSSE"}]
		},
		"enregistrement_campagne": [
			{
				"campagne": "campagne_test",
				"date_debut": 100,
				"date_fin": 0,
				"score": {},
				"niveaux": [
					{
						"niveau": "niveau_1",
						"date_debut": 100,
						"date_fin": 200,
						"plateaux": plateaux_niveau_1
					},
					{
						"niveau": "niveau_2",
						"date_debut": 500,
						"date_fin": 0,
						"plateaux": plateaux_niveau_2
					}
				]
			}
		],
		"plateaux_libres": {"1": [{"nom": "Externe"}]},
		"nombre_de_parties": {"2": 1}
	})
	FichiersJsonService.write_json_file("sauvegarde_joueur_beta.json", {
		"nom": "Beta",
		"campagne": {},
		"enregistrement_campagne": [],
		"plateaux_libres": {},
		"nombre_de_parties": {}
	})

	service.detail_score_plateau.connect(_on_detail_score_plateau)
	service.fin_niveau.connect(_on_fin_niveau)

func after_each():
	SauvegardeListeJoueursService.liste_des_joueurs = initial_liste_joueurs.duplicate(true)
	SauvegardeBddJoueursService._sauvegarde_joueur = initial_bdd_joueur.duplicate(true)
	SauvegardeBddJoueursService.fichier_sauvegarde = initial_bdd_fichier
	SauvegardeTableauDesScoresService.liste_des_scores = initial_tableau_scores.duplicate(true)
	_nettoyer_fichiers_utilisateur()
	FichiersJsonService.reinitialiser_racine_utilisateur()

func _on_detail_score_plateau(detail_score : Dictionary):
	detail_score_received = detail_score

func _on_fin_niveau():
	fin_niveau_recu = true

func test_la_campagne_est_terminee_pour_joueur_renvoie_oui_si_vide():
	assert_true(service.la_campagne_est_terminee_pour_joueur("Beta"))
	assert_false(service.la_campagne_est_terminee_pour_joueur("Inconnu"))

func test_choisir_le_joueur_pour_la_campagne_charge_un_joueur_existant():
	assert_true(service.choisir_le_joueur_pour_la_campagne("Alpha"))
	assert_eq(SauvegardeBddJoueursService.lire_nom_joueur(), "Alpha")
	assert_eq(SauvegardeBddJoueursService.fichier_sauvegarde, "sauvegarde_joueur_alpha.json")

func test_choisir_et_corriger_le_joueur_supprime_un_joueur_orphelin():
	FichiersJsonService.write_json_file("sauvegarde_joueur_alpha.json", {"nom": "Autre", "campagne": {}, "enregistrement_campagne": [], "plateaux_libres": {}, "nombre_de_parties": {}})
	assert_false(service._choisir_et_corriger_le_joueur("Alpha"))
	assert_false(SauvegardeListeJoueursService.le_joueur_existe("Alpha"))

func test_liberer_le_joueur_pour_la_campagne_vides_la_sauvegarde_active():
	service.choisir_le_joueur_pour_la_campagne("Alpha")
	service.liberer_le_joueur_pour_la_campagne()
	assert_eq(SauvegardeBddJoueursService.fichier_sauvegarde, "")

func test_autoriser_le_nouveau_joueur_pour_la_campagne():
	assert_true(service.autoriser_le_nouveau_joueur_pour_la_campagne("Gamma"))
	assert_false(service.autoriser_le_nouveau_joueur_pour_la_campagne("Alpha"))
	assert_false(service.autoriser_le_nouveau_joueur_pour_la_campagne("alpha"))
	assert_false(service.autoriser_le_nouveau_joueur_pour_la_campagne("   "))

func test_importer_campagne_complete_cree_un_joueur_sans_plateaux_a_jouer():
	var campagne := {
		"campagne": "campagne_test",
		"date_debut": 100.0,
		"date_fin": 200.0,
		"score": {"fin_campagne": 500},
		"niveaux": [{"niveau": "niveau_1", "score": {"niveau": 10}, "plateaux": []}]
	}

	assert_true(service.importer_campagne_nouveau_joueur_externe("Gamma", campagne))
	assert_true(SauvegardeListeJoueursService.le_joueur_existe("Gamma"))
	assert_true(SauvegardeBddJoueursService.campagne_la_campagne_est_terminee())
	var campagne_importee: Dictionary = SauvegardeBddJoueursService.enregistrement_campagne_lire_derniere_campagne()
	assert_eq(campagne_importee, campagne)
	assert_eq(SauvegardeTableauDesScoresService.lire_score_joueur("Gamma"), 510)

func test_initialiser_le_nouveau_joueur_pour_la_campagne_cree_le_compte():
	assert_true(service.initialiser_le_nouveau_joueur_pour_la_campagne("Gamma"))
	assert_true(SauvegardeListeJoueursService.le_joueur_existe("Gamma"))
	assert_true(SauvegardeTableauDesScoresService.le_joueur_existe("Gamma"))
	assert_eq(SauvegardeBddJoueursService.lire_nom_joueur(), "Gamma")

func test_niveau_en_cours_et_la_campagne_est_terminee_sont_coherents():
	service.choisir_le_joueur_pour_la_campagne("Alpha")
	assert_true(SauvegardeBddJoueursService.enregistrement_campagne_niveau_en_cours())
	assert_true(service.niveau_en_cours())
	assert_false(service.la_campagne_est_terminee())

	SauvegardeBddJoueursService._sauvegarde_joueur["campagne"] = {}
	assert_true(service.la_campagne_est_terminee())

func test_gagner_un_plateau_emet_les_signaux_et_maj_score():
	service.choisir_le_joueur_pour_la_campagne("Alpha")
	var score_before = SauvegardeTableauDesScoresService.lire_score_joueur("Alpha")
	service.gagner_un_plateau()
	assert_true(detail_score_received != null)
	assert_true(detail_score_received.has("duree"))
	assert_true(SauvegardeTableauDesScoresService.lire_score_joueur("Alpha") >= score_before)

func test_abandonner_un_plateau_ne_detruit_pas_la_campaign():
	service.choisir_le_joueur_pour_la_campagne("Alpha")
	var campagne_avant = SauvegardeBddJoueursService._sauvegarde_joueur.get("campagne").duplicate(true)
	service.abandonner_un_plateau()
	assert_eq(SauvegardeBddJoueursService._sauvegarde_joueur.get("campagne").keys().size(), campagne_avant.keys().size())

func test_afficher_niveau_plateau_parties_ne_crashe_pas():
	service.choisir_le_joueur_pour_la_campagne("Alpha")
	service.afficher_niveau_plateau_parties()
	assert_true(true)

func test_retourner_le_niveau_le_plus_bas_trouve_le_plus_bas_non_termine():
	FichiersJsonService.write_json_file("sauvegarde_joueur_alpha.json", {
		"nom": "Alpha",
		"campagne": {"niveau_2": [{"nom": "P2", "difficulte": 2, "gameplay": "CLASSIQUE"}]},
		"enregistrement_campagne": [],
		"plateaux_libres": {},
		"nombre_de_parties": {}
	})
	assert_true(service.choisir_le_joueur_pour_la_campagne("Alpha"))
	assert_eq(service.retourner_le_niveau_le_plus_bas(), 2)

func test_commencer_un_plateau_initialise_le_premier_niveau_et_incremente_les_parties():
	FichiersJsonService.write_json_file("sauvegarde_joueur_alpha.json", {
		"nom": "Alpha",
		"campagne": {"niveau_1": [{"nom": "P1", "gameplay": "CLASSIQUE", "difficulte": 1}]},
		"enregistrement_campagne": [],
		"plateaux_libres": {},
		"nombre_de_parties": {}
	})
	service.choisir_le_joueur_pour_la_campagne("Alpha")

	service.commencer_un_plateau()

	assert_true(SauvegardeBddJoueursService.enregistrement_campagne_niveau_existe())
	assert_true(SauvegardeBddJoueursService.enregistrement_campagne_plateau_en_cours())
	assert_eq(SauvegardeBddJoueursService.enregistrement_campagne_lire_nom_plateau(), "P1")
	assert_eq(SauvegardeBddJoueursService.lire_nombre_de_parties_difficulte(1), 1)

func test_commencer_un_plateau_abandonne_le_plateau_precedent_avant_den_demarrer_un_nouveau():
	FichiersJsonService.write_json_file("sauvegarde_joueur_alpha.json", {
		"nom": "Alpha",
		"campagne": {"niveau_1": [{"nom": "P2", "gameplay": "CLASSIQUE", "difficulte": 1}]},
		"enregistrement_campagne": [
			{
				"campagne": "campagne_test",
				"date_debut": 100,
				"date_fin": 0,
				"score": {},
				"niveaux": [{
					"niveau": "niveau_1",
					"date_debut": 100,
					"date_fin": 0,
					"score": {},
					"plateaux": [
						{"nom": "P1", "date_debut": 90, "date_fin": 0, "duree": 0, "gameplay": "CLASSIQUE", "difficulte": 1, "statut": "en cours", "score": {}, "coups joués": []}
					]
				}]
			}
		],
		"plateaux_libres": {},
		"nombre_de_parties": {}
	})
	service.choisir_le_joueur_pour_la_campagne("Alpha")

	service.commencer_un_plateau()

	var plateaux = SauvegardeBddJoueursService.enregistrement_campagne_lire_dernier_niveau().get("plateaux")
	assert_eq(plateaux.size(), 2)
	assert_eq(plateaux[0].get("statut"), "abandonné")
	assert_true(plateaux[0].get("date_fin") > 0)
	assert_eq(plateaux[1].get("nom"), "P2")
	assert_eq(plateaux[1].get("statut"), "en cours")

func test_gagner_un_plateau_emet_fin_niveau_quand_cetait_le_dernier_plateau_du_niveau():
	FichiersJsonService.write_json_file("sauvegarde_joueur_alpha.json", {
		"nom": "Alpha",
		"campagne": {"niveau_1": [{"nom": "P1", "gameplay": "CLASSIQUE", "difficulte": 1}]},
		"enregistrement_campagne": [
			{
				"campagne": "campagne_test",
				"date_debut": 100,
				"date_fin": 0,
				"score": {},
				"niveaux": [{
					"niveau": "niveau_1",
					"date_debut": 100,
					"date_fin": 0,
					"score": {},
					"plateaux": [
						{"nom": "P1", "date_debut": 90, "date_fin": 0, "duree": 0, "gameplay": "CLASSIQUE", "difficulte": 1, "statut": "en cours", "score": {}, "coups joués": []}
					]
				}]
			}
		],
		"plateaux_libres": {},
		"nombre_de_parties": {}
	})
	service.choisir_le_joueur_pour_la_campagne("Alpha")

	service.gagner_un_plateau()

	assert_true(fin_niveau_recu)
	assert_false(SauvegardeBddJoueursService.campagne_niveau_existe(1))

func test_gagner_un_plateau_nemet_pas_fin_niveau_sil_reste_des_plateaux_dans_le_niveau():
	FichiersJsonService.write_json_file("sauvegarde_joueur_alpha.json", {
		"nom": "Alpha",
		"campagne": {
			"niveau_1": [
				{"nom": "P1", "gameplay": "CLASSIQUE", "difficulte": 1},
				{"nom": "P2", "gameplay": "CLASSIQUE", "difficulte": 1}
			]
		},
		"enregistrement_campagne": [
			{
				"campagne": "campagne_test",
				"date_debut": 100,
				"date_fin": 0,
				"score": {},
				"niveaux": [{
					"niveau": "niveau_1",
					"date_debut": 100,
					"date_fin": 0,
					"score": {},
					"plateaux": [
						{"nom": "P1", "date_debut": 90, "date_fin": 0, "duree": 0, "gameplay": "CLASSIQUE", "difficulte": 1, "statut": "en cours", "score": {}, "coups joués": []}
					]
				}]
			}
		],
		"plateaux_libres": {},
		"nombre_de_parties": {}
	})
	service.choisir_le_joueur_pour_la_campagne("Alpha")

	service.gagner_un_plateau()

	assert_false(fin_niveau_recu)
	assert_true(SauvegardeBddJoueursService.campagne_niveau_existe(1))


# ---------------------------------------------------------
# passer_un_plateau
# ---------------------------------------------------------

var fin_campagne_recue = false

func _on_fin_campagne():
	fin_campagne_recue = true

func _plateau_en_cours(nom: String, difficulte: int = 1) -> Dictionary:
	return {"nom": nom, "date_debut": Time.get_unix_time_from_system() - 30., "date_fin": 0, "duree": 0, "gameplay": "CLASSIQUE", "difficulte": difficulte, "statut": "en cours", "score": {}, "coups joués": []}

func _ecrire_alpha(campagne: Dictionary, plateaux: Array, plateaux_libres: Dictionary = {}) -> void:
	FichiersJsonService.write_json_file("sauvegarde_joueur_alpha.json", {
		"nom": "Alpha",
		"campagne": campagne,
		"enregistrement_campagne": [{
			"campagne": "campagne_test",
			"date_debut": 100,
			"date_fin": 0,
			"score": {},
			"niveaux": [{
				"niveau": "niveau_1",
				"date_debut": 100,
				"date_fin": 0,
				"score": {},
				"plateaux": plateaux
			}]
		}],
		"plateaux_libres": plateaux_libres,
		"nombre_de_parties": {}
	})
	service.fin_campagne.connect(_on_fin_campagne)
	fin_campagne_recue = false
	assert_true(service.choisir_le_joueur_pour_la_campagne("Alpha"))

func _plateau_p1(plateaux_restants: int = 2) -> Dictionary:
	var liste = []
	for index in range(plateaux_restants):
		liste.append({"nom": "P%d" % (index + 1), "gameplay": "CLASSIQUE", "difficulte": 1})
	return {"niveau_1": liste}

func _dernier_plateau_enregistre() -> Dictionary:
	return SauvegardeBddJoueursService.enregistrement_campagne_lire_dernier_plateau()

func test_passer_un_plateau_retire_le_plateau_courant_de_la_campagne():
	_ecrire_alpha(_plateau_p1(2), [_plateau_en_cours("P1")])
	service.passer_un_plateau()
	var restants = SauvegardeBddJoueursService._sauvegarde_joueur.get("campagne").get("niveau_1")
	assert_eq(restants.size(), 1)
	assert_eq(restants[0].get("nom"), "P2")

func test_passer_un_plateau_enregistre_le_statut_passe_et_termine_le_plateau():
	_ecrire_alpha(_plateau_p1(2), [_plateau_en_cours("P1")])
	service.passer_un_plateau()
	var plateau = _dernier_plateau_enregistre()
	assert_eq(plateau.get("statut"), "passé")
	assert_gt(plateau.get("date_fin"), 0)
	assert_false(SauvegardeBddJoueursService.enregistrement_campagne_plateau_en_cours())

func test_passer_un_plateau_n_enregistre_pas_de_temps_de_jeu_pour_un_plateau_passe():
	_ecrire_alpha(_plateau_p1(2), [_plateau_en_cours("P1")])
	service.passer_un_plateau()
	assert_eq(_dernier_plateau_enregistre().get("duree"), 0.0)

func test_passer_un_plateau_ne_memorise_pas_le_plateau_dans_les_plateaux_libres():
	_ecrire_alpha(_plateau_p1(2), [_plateau_en_cours("P1")], {"1": [{"nom": "Externe"}]})
	service.passer_un_plateau()
	assert_eq(SauvegardeBddJoueursService._sauvegarde_joueur.get("plateaux_libres"), {"1": [{"nom": "Externe"}]})

func test_gagner_un_plateau_memorise_le_plateau_contrairement_a_passer():
	_ecrire_alpha(_plateau_p1(2), [_plateau_en_cours("P1")])
	service.gagner_un_plateau()
	assert_eq(SauvegardeBddJoueursService._sauvegarde_joueur.get("plateaux_libres").get("1").size(), 1)

func test_passer_un_plateau_emet_detail_score_sans_points_de_duree_ni_de_ratio():
	_ecrire_alpha(_plateau_p1(2), [_plateau_en_cours("P1")])
	service.passer_un_plateau()
	assert_not_null(detail_score_received)
	assert_eq(detail_score_received.get("duree").get("points"), 0)
	assert_eq(detail_score_received.get("duree").get("realise"), 0)
	assert_eq(detail_score_received.get("duree").get("recommence"), 0)
	assert_eq(detail_score_received.get("ratio_reussite").get("points"), 0)
	assert_eq(detail_score_received.get("ratio_reussite").get("ratio"), 0)

func test_passer_un_plateau_remet_a_zero_les_scores_du_plateau_en_base():
	_ecrire_alpha(_plateau_p1(2), [_plateau_en_cours("P1")])
	service.passer_un_plateau()
	var score = _dernier_plateau_enregistre().get("score")
	assert_eq(score.get("duree"), 0)
	assert_eq(score.get("ratio_reussite"), 0)

func test_passer_un_plateau_ne_modifie_pas_le_score_hors_niveau_et_campagne():
	_ecrire_alpha(_plateau_p1(2), [_plateau_en_cours("P1")])
	var avant = SauvegardeTableauDesScoresService.lire_score_joueur("Alpha")
	service.passer_un_plateau()
	assert_eq(SauvegardeTableauDesScoresService.lire_score_joueur("Alpha"), avant)

func test_passer_un_plateau_n_emet_pas_fin_niveau_ni_fin_campagne_s_il_reste_des_plateaux():
	_ecrire_alpha(_plateau_p1(2), [_plateau_en_cours("P1")])
	service.passer_un_plateau()
	assert_false(fin_niveau_recu)
	assert_false(fin_campagne_recue)

func test_passer_le_dernier_plateau_du_niveau_emet_fin_niveau_et_fin_campagne():
	_ecrire_alpha(_plateau_p1(1), [_plateau_en_cours("P1")])
	service.passer_un_plateau()
	assert_true(fin_niveau_recu)
	assert_true(fin_campagne_recue)
	assert_false(SauvegardeBddJoueursService.campagne_niveau_existe(1))
	assert_true(service.la_campagne_est_terminee())

func test_passer_le_dernier_plateau_du_niveau_sans_fin_de_campagne():
	var campagne = _plateau_p1(1)
	campagne["niveau_2"] = [{"nom": "Q1", "gameplay": "CLASSIQUE", "difficulte": 2}]
	_ecrire_alpha(campagne, [_plateau_en_cours("P1")])
	service.passer_un_plateau()
	assert_true(fin_niveau_recu)
	assert_false(fin_campagne_recue)
	assert_false(service.la_campagne_est_terminee())

func test_passer_le_dernier_plateau_attribue_les_points_de_niveau_et_de_campagne_sans_duree_ni_ratio():
	_ecrire_alpha(_plateau_p1(1), [_plateau_en_cours("P1")])
	var avant = SauvegardeTableauDesScoresService.lire_score_joueur("Alpha")
	service.passer_un_plateau()
	var attendu = 0
	for cle in ["niveau", "niveau_parfait", "campagne"]:
		attendu += detail_score_received.get(cle, {}).get("points", 0)
	assert_eq(SauvegardeTableauDesScoresService.lire_score_joueur("Alpha"), avant + attendu)

func test_passer_deux_plateaux_de_suite_les_marque_tous_les_deux_passes():
	_ecrire_alpha(_plateau_p1(3), [_plateau_en_cours("P1")])
	service.passer_un_plateau()
	service.commencer_un_plateau()
	service.passer_un_plateau()
	var plateaux = SauvegardeBddJoueursService.enregistrement_campagne_lire_dernier_niveau().get("plateaux")
	assert_eq(plateaux.size(), 2)
	assert_eq(plateaux[0].get("statut"), "passé")
	assert_eq(plateaux[1].get("statut"), "passé")
	assert_eq(plateaux[1].get("nom"), "P2")
	assert_eq(SauvegardeBddJoueursService._sauvegarde_joueur.get("campagne").get("niveau_1").size(), 1)

func test_passer_un_plateau_apres_commencer_un_plateau():
	_ecrire_alpha(_plateau_p1(2), [])
	service.commencer_un_plateau()
	assert_true(SauvegardeBddJoueursService.enregistrement_campagne_plateau_en_cours())
	service.passer_un_plateau()
	assert_eq(_dernier_plateau_enregistre().get("statut"), "passé")
	assert_eq(_dernier_plateau_enregistre().get("nom"), "P1")
	assert_eq(SauvegardeBddJoueursService.lire_nombre_de_parties_difficulte(1), 1)

func test_passer_un_plateau_est_enregistre_dans_la_sauvegarde_du_joueur():
	_ecrire_alpha(_plateau_p1(2), [_plateau_en_cours("P1")])
	service.passer_un_plateau()
	var sauvegarde = FichiersJsonService.read_json_file("sauvegarde_joueur_alpha.json")
	var plateaux = sauvegarde.get("enregistrement_campagne")[0].get("niveaux")[0].get("plateaux")
	assert_eq(plateaux[0].get("statut"), "passé")
	assert_eq(sauvegarde.get("campagne").get("niveau_1").size(), 1)

func test_passer_un_plateau_deja_termine_ne_modifie_pas_son_statut():
	# Défaut attendu : sans plateau en cours, l'appel ne doit rien modifier (le plateau réussi devient 'passé').
	var plateau_reussi = _plateau_en_cours("P0")
	plateau_reussi["statut"] = "reussi"
	plateau_reussi["date_fin"] = 150
	plateau_reussi["duree"] = 12
	_ecrire_alpha(_plateau_p1(2), [plateau_reussi])
	service.passer_un_plateau()
	assert_eq(_dernier_plateau_enregistre().get("statut"), "reussi")
	assert_eq(SauvegardeBddJoueursService._sauvegarde_joueur.get("campagne").get("niveau_1").size(), 2)

func test_passer_un_plateau_sans_plateau_en_cours_ne_retire_rien_de_la_campagne():
	var plateau_reussi = _plateau_en_cours("P0")
	plateau_reussi["statut"] = "reussi"
	plateau_reussi["date_fin"] = 150
	_ecrire_alpha(_plateau_p1(2), [plateau_reussi])
	service.passer_un_plateau()
	assert_eq(SauvegardeBddJoueursService._sauvegarde_joueur.get("campagne").get("niveau_1").size(), 2)

func test_passer_un_plateau_dont_le_statut_n_est_pas_en_cours_ne_retire_rien():
	_ecrire_alpha(_plateau_p1(2), [{"nom": "P1", "date_debut": 90, "date_fin": 0, "duree": 0, "gameplay": "CLASSIQUE", "difficulte": 1, "statut": "en_cours", "score": {}}])
	service.passer_un_plateau()
	assert_eq(SauvegardeBddJoueursService._sauvegarde_joueur.get("campagne").get("niveau_1").size(), 2)

func test_passer_un_plateau_sans_joueur_ne_plante_pas():
	# Comportement actuel (discutable) : sans joueur, fin_niveau et fin_campagne sont tout de même émis.
	SauvegardeBddJoueursService.liberer_le_joueur()
	var scores_avant = SauvegardeTableauDesScoresService.liste_des_scores.duplicate(true)
	service.passer_un_plateau()
	assert_eq(SauvegardeTableauDesScoresService.liste_des_scores, scores_avant)
	assert_not_null(detail_score_received)