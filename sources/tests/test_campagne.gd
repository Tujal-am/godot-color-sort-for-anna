extends GutTest

const SCENE_CAMPAGNE = preload("res://Scenes/MenuPrincipal/Campagne/campagne.tscn")
const RACINE_TEST := "tests/test_campagne"
const PLATEAU_CLASSIQUE := "DDA.CCB.AAB.   .DBC"
const PLATEAU_QUI_PERD_GAGNE := "AC.BD.CD.EA.FB.FE.  "

var sauvegarde_joueur_initiale: Dictionary
var fichier_sauvegarde_initial: String
var configuration_initiale: Dictionary
var liste_des_scores_initiale: Array

func _plateaux_classique_puis_qpg() -> Array:
	return [
		{"nom": PLATEAU_CLASSIQUE, "gameplay": "CLASSIQUE", "difficulte": 1},
		{"nom": PLATEAU_QUI_PERD_GAGNE, "gameplay": "QUI_PERD_GAGNE", "difficulte": 2}
	]

func _definir_campagne(plateaux: Array) -> void:
	SauvegardeBddJoueursService._sauvegarde_joueur = {
		"nom": "Joueuse test",
		"campagne": {"niveau_1": plateaux},
		"nombre_de_parties": {},
		"enregistrement_campagne": [],
		"plateaux_libres": {}
	}

func before_each() -> void:
	FichiersJsonService.definir_racine_utilisateur(RACINE_TEST)
	FichiersJsonService.effacer_racine_utilisateur()
	sauvegarde_joueur_initiale = SauvegardeBddJoueursService._sauvegarde_joueur.duplicate(true)
	fichier_sauvegarde_initial = SauvegardeBddJoueursService.fichier_sauvegarde
	configuration_initiale = SauvegardeConfigurationService.configuration_du_jeu.duplicate(true)
	liste_des_scores_initiale = SauvegardeTableauDesScoresService.liste_des_scores.duplicate(true)
	SauvegardeBddJoueursService.fichier_sauvegarde = "joueuse_test.json"
	SauvegardeConfigurationService.configuration_du_jeu["date_debut_campagne"] = "2020-01-01 00:00:00"
	SauvegardeTableauDesScoresService.liste_des_scores = [{"nom": "Joueuse test", "rang": 1, "score": 0, "score_txt": "0"}]
	_definir_campagne(_plateaux_classique_puis_qpg())

func after_each() -> void:
	SauvegardeBddJoueursService._sauvegarde_joueur = sauvegarde_joueur_initiale
	SauvegardeBddJoueursService.fichier_sauvegarde = fichier_sauvegarde_initial
	SauvegardeConfigurationService.configuration_du_jeu = configuration_initiale
	SauvegardeTableauDesScoresService.liste_des_scores = liste_des_scores_initiale
	FichiersJsonService.effacer_racine_utilisateur()
	FichiersJsonService.reinitialiser_racine_utilisateur()

func _campagne() -> Campagne:
	return add_child_autofree(SCENE_CAMPAGNE.instantiate())

func _commencer_le_plateau(campagne: Campagne) -> void:
	campagne.gameplay_courant.get_node("MenuPlateau/BandeauMenu/BoutonCommencer").emit_signal("pressed")

func test_gameplay_to_ui_associe_chaque_gameplay_a_son_noeud() -> void:
	var campagne := _campagne()
	var attendus := {
		GameplayTypes.Gameplay.CLASSIQUE: "Classique",
		GameplayTypes.Gameplay.AU_PLUS_PRES: "AuPlusPres",
		GameplayTypes.Gameplay.PILE_POIL: "PilePoil",
		GameplayTypes.Gameplay.TOUT_EN_TETE: "ToutEnTete",
		GameplayTypes.Gameplay.PROGRAMMATION: "Programmation",
		GameplayTypes.Gameplay.PROGRAMMATION_GENIUS: "ProgrammationGenius",
		GameplayTypes.Gameplay.QUI_PERD_GAGNE: "QuiPerdGagne",
		GameplayTypes.Gameplay.POIDS_PLUME: "PoidsPlume",
		GameplayTypes.Gameplay.PILE_OU_FACE: "PileOuFace",
		GameplayTypes.Gameplay.MOT_CACHE: "MotCache"
	}

	for gameplay in attendus:
		assert_eq(campagne.gameplay_to_ui(gameplay), campagne.get_node(attendus[gameplay]), attendus[gameplay])

func test_instance_gameplay_ne_connait_que_classique_et_qui_perd_gagne() -> void:
	var campagne := _campagne()

	assert_eq(campagne.instance_gameplay(GameplayTypes.Gameplay.CLASSIQUE), campagne.get_node("Classique"))
	assert_eq(campagne.instance_gameplay(GameplayTypes.Gameplay.QUI_PERD_GAGNE), campagne.get_node("QuiPerdGagne"))
	assert_null(campagne.instance_gameplay(GameplayTypes.Gameplay.PILE_POIL))

func test_au_demarrage_le_premier_gameplay_est_classique_avec_son_menu() -> void:
	var campagne := _campagne()

	assert_eq(campagne.gameplay_courant, campagne.get_node("Classique"))
	assert_true(campagne.get_node("Classique/MenuPlateau/BandeauMenu").visible)
	assert_false(campagne.get_node("Classique/MenuPlateau/BandeauEnJeu").visible)
	assert_false(campagne.get_node("QuiPerdGagne/MenuPlateau/Fond").visible)
	assert_false(campagne.get_node("QuiPerdGagne/MenuPlateau/BandeauMenu").visible)
	assert_false(campagne.get_node("MessagesCampagne").visible)

func test_au_demarrage_un_premier_plateau_qui_perd_gagne_masque_classique() -> void:
	_definir_campagne([_plateaux_classique_puis_qpg()[1]])

	var campagne := _campagne()

	assert_eq(campagne.gameplay_courant, campagne.get_node("QuiPerdGagne"))
	assert_true(campagne.get_node("QuiPerdGagne/MenuPlateau/BandeauMenu").visible)
	assert_false(campagne.get_node("Classique/MenuPlateau/Fond").visible)
	assert_false(campagne.get_node("Classique/MenuPlateau/BandeauMenu").visible)
	assert_false(campagne.get_node("MessagesCampagne").visible)

func test_cacher_les_gameplays_masque_classique_et_qui_perd_gagne() -> void:
	var campagne := _campagne()
	campagne.get_node("QuiPerdGagne/MenuPlateau").show_menu()

	campagne.cacher_les_gameplays()

	for gameplay in ["Classique", "QuiPerdGagne"]:
		assert_false(campagne.get_node(gameplay + "/MenuPlateau/Fond").visible, gameplay)
		assert_false(campagne.get_node(gameplay + "/MenuPlateau/BandeauMenu").visible, gameplay)

func test_commencer_un_plateau_initialise_l_enregistrement_et_lance_le_jeu() -> void:
	var campagne := _campagne()

	_commencer_le_plateau(campagne)

	assert_true(SauvegardeBddJoueursService.enregistrement_campagne_plateau_en_cours())
	assert_eq(SauvegardeBddJoueursService.enregistrement_campagne_lire_nom_plateau(), PLATEAU_CLASSIQUE)
	assert_eq(SauvegardeBddJoueursService.enregistrement_campagne_lire_gameplay_plateau(), "CLASSIQUE")
	assert_true(campagne.get_node("Classique/MenuPlateau/BandeauEnJeu").visible)
	assert_false(campagne.get_node("Classique/MenuPlateau/BandeauMenu").visible)
	assert_false(campagne.get_node("MessagesCampagne").visible)

func test_abandon_affiche_le_panneau_de_defaite_et_conserve_le_plateau() -> void:
	var campagne := _campagne()
	_commencer_le_plateau(campagne)

	campagne.get_node("Classique").abandon.emit()

	var messages: MessagesCampagne = campagne.get_node("MessagesCampagne")
	assert_true(messages.visible)
	assert_true(messages.get_node("Centrer").visible)
	assert_true(messages.get_node("Centrer/PanneauDefaite").visible)
	assert_true(campagne.get_node("Classique/MenuPlateau/Fond").visible)
	assert_false(campagne.get_node("Classique/MenuPlateau/BandeauEnJeu").visible)
	assert_eq(SauvegardeBddJoueursService.campagne_lire_prochain_gameplay(), "CLASSIQUE")

func test_passe_affiche_le_fond_sans_panneau_et_enchaine_le_plateau_suivant() -> void:
	var campagne := _campagne()
	_commencer_le_plateau(campagne)

	campagne.get_node("Classique").passe.emit()

	var messages: MessagesCampagne = campagne.get_node("MessagesCampagne")
	assert_true(messages.visible)
	assert_false(messages.get_node("Centrer/PanneauDefaite").visible)
	assert_true(campagne.get_node("Classique/MenuPlateau/Fond").visible)
	assert_eq(SauvegardeBddJoueursService.campagne_lire_prochain_gameplay(), "QUI_PERD_GAGNE")

func test_victoire_affiche_le_detail_du_score_du_plateau() -> void:
	var campagne := _campagne()
	_commencer_le_plateau(campagne)

	campagne.get_node("Classique").victoire.emit()

	var messages: MessagesCampagne = campagne.get_node("MessagesCampagne")
	assert_true(messages.visible)
	assert_true(messages.get_node("Centrer").visible)
	assert_true(messages.get_node("Centrer/PanneauVictoirePlateau").visible)
	assert_false(messages.get_node("Centrer/PanneauVictoireNiveau").visible)
	assert_eq(SauvegardeBddJoueursService.campagne_lire_prochain_gameplay(), "QUI_PERD_GAGNE")

func test_victoire_du_dernier_plateau_affiche_le_score_de_fin_de_campagne() -> void:
	_definir_campagne([_plateaux_classique_puis_qpg()[0]])
	var campagne := _campagne()
	_commencer_le_plateau(campagne)

	campagne.get_node("Classique").victoire.emit()

	var messages: MessagesCampagne = campagne.get_node("MessagesCampagne")
	assert_true(ProgressionCampagneService.la_campagne_est_terminee())
	assert_true(messages.get_node("Centrer").visible)
	assert_true(messages.get_node("Centrer/PanneauVictoireCampagne").visible)

func test_victoire_qui_perd_gagne_suit_le_meme_parcours_que_classique() -> void:
	_definir_campagne([_plateaux_classique_puis_qpg()[1], _plateaux_classique_puis_qpg()[0]])
	var campagne := _campagne()
	_commencer_le_plateau(campagne)
	assert_eq(SauvegardeBddJoueursService.enregistrement_campagne_lire_gameplay_plateau(), "QUI_PERD_GAGNE")

	campagne.get_node("QuiPerdGagne").victoire.emit()

	assert_true(campagne.get_node("MessagesCampagne/Centrer/PanneauVictoirePlateau").visible)
	assert_eq(SauvegardeBddJoueursService.campagne_lire_prochain_gameplay(), "CLASSIQUE")

func test_abandon_qui_perd_gagne_suit_le_meme_parcours_que_classique() -> void:
	_definir_campagne([_plateaux_classique_puis_qpg()[1], _plateaux_classique_puis_qpg()[0]])
	var campagne := _campagne()
	_commencer_le_plateau(campagne)

	campagne.get_node("QuiPerdGagne").abandon.emit()

	assert_true(campagne.get_node("MessagesCampagne/Centrer/PanneauDefaite").visible)
	assert_true(campagne.get_node("QuiPerdGagne/MenuPlateau/Fond").visible)
	assert_false(campagne.get_node("QuiPerdGagne/MenuPlateau/BandeauEnJeu").visible)
	assert_eq(SauvegardeBddJoueursService.campagne_lire_prochain_gameplay(), "QUI_PERD_GAGNE")

func test_passe_qui_perd_gagne_suit_le_meme_parcours_que_classique() -> void:
	_definir_campagne([_plateaux_classique_puis_qpg()[1], _plateaux_classique_puis_qpg()[0]])
	var campagne := _campagne()
	_commencer_le_plateau(campagne)

	campagne.get_node("QuiPerdGagne").passe.emit()

	assert_true(campagne.get_node("MessagesCampagne").visible)
	assert_false(campagne.get_node("MessagesCampagne/Centrer/PanneauDefaite").visible)
	assert_true(campagne.get_node("QuiPerdGagne/MenuPlateau/Fond").visible)
	assert_eq(SauvegardeBddJoueursService.campagne_lire_prochain_gameplay(), "CLASSIQUE")

func test_continuer_apres_le_score_affiche_le_gameplay_suivant() -> void:
	var campagne := _campagne()
	_commencer_le_plateau(campagne)
	campagne.get_node("Classique").victoire.emit()

	campagne.get_node("MessagesCampagne").score_continuer.emit()

	assert_false(campagne.get_node("MessagesCampagne").visible)
	assert_eq(campagne.gameplay_courant, campagne.get_node("QuiPerdGagne"))
	assert_false(campagne.get_node("Classique/MenuPlateau/Fond").visible)
	assert_true(campagne.get_node("QuiPerdGagne/MenuPlateau/BandeauMenu").visible)

func test_continuer_une_fois_la_campagne_terminee_ne_change_pas_de_gameplay() -> void:
	_definir_campagne([_plateaux_classique_puis_qpg()[0]])
	var campagne := _campagne()
	_commencer_le_plateau(campagne)
	campagne.get_node("Classique").victoire.emit()

	campagne.get_node("MessagesCampagne").score_continuer.emit()

	assert_true(campagne.get_node("MessagesCampagne").visible)
	assert_eq(campagne.gameplay_courant, campagne.get_node("Classique"))

func test_les_plateaux_invalides_ne_modifient_pas_l_etat_de_la_campagne() -> void:
	var campagne := _campagne()

	campagne.get_node("Classique").plateau_invalide.emit()
	campagne.get_node("QuiPerdGagne").plateau_invalide.emit()

	assert_false(campagne.get_node("MessagesCampagne").visible)
	assert_eq(campagne.gameplay_courant, campagne.get_node("Classique"))
	assert_false(SauvegardeBddJoueursService.enregistrement_campagne_plateau_en_cours())
