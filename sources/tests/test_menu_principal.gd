extends GutTest

const SCENE_MENU = preload("res://Scenes/MenuPrincipal/menu_principal.tscn")
const RACINE_TEST := "tests/test_menu_principal"
const LIGNES := "LowerFlow/CenterConfiguration/Configuration/Lignes/"
const ZONE_JOUEURS := "LowerFlow/PlayerSection/PlayerScroll/PlayersCenter/PlayerArea"
const AJOUT := "LowerFlow/PlayerSection/PlayerRow/Add"

var sauvegarde_joueur_initiale: Dictionary
var fichier_sauvegarde_initial: String
var configuration_initiale: Dictionary
var liste_des_scores_initiale: Array
var liste_des_joueurs_initiale: Array

func _donnees_joueur(nom: String, campagne_terminee: bool) -> Dictionary:
	return {
		"nom": nom,
		"nom_campagne": "campagne_test",
		"campagne": {} if campagne_terminee else {"niveau_1": [{"nom": "R1", "difficulte": 1}]},
		"enregistrement_campagne": [],
		"plateaux_libres": {}
	}

func _declarer_joueur(nom: String, indice: int, campagne_terminee: bool) -> void:
	var fichier := "joueur_test_%d.json" % indice
	FichiersJsonService.write_json_file(fichier, _donnees_joueur(nom, campagne_terminee))
	SauvegardeListeJoueursService.liste_des_joueurs.append({"indice": indice, "nom": nom, "fichier_sauvegarde": fichier})

func before_each() -> void:
	FichiersJsonService.definir_racine_utilisateur(RACINE_TEST)
	FichiersJsonService.effacer_racine_utilisateur()
	sauvegarde_joueur_initiale = SauvegardeBddJoueursService._sauvegarde_joueur.duplicate(true)
	fichier_sauvegarde_initial = SauvegardeBddJoueursService.fichier_sauvegarde
	configuration_initiale = SauvegardeConfigurationService.configuration_du_jeu.duplicate(true)
	liste_des_scores_initiale = SauvegardeTableauDesScoresService.liste_des_scores.duplicate(true)
	liste_des_joueurs_initiale = SauvegardeListeJoueursService.liste_des_joueurs.duplicate(true)
	SauvegardeListeJoueursService.liste_des_joueurs = []
	SauvegardeTableauDesScoresService.liste_des_scores = []

func after_each() -> void:
	var scene_courante := get_tree().current_scene
	if scene_courante != null:
		scene_courante.queue_free()
	SauvegardeBddJoueursService._sauvegarde_joueur = sauvegarde_joueur_initiale
	SauvegardeBddJoueursService.fichier_sauvegarde = fichier_sauvegarde_initial
	SauvegardeConfigurationService.configuration_du_jeu = configuration_initiale
	SauvegardeTableauDesScoresService.liste_des_scores = liste_des_scores_initiale
	SauvegardeListeJoueursService.liste_des_joueurs = liste_des_joueurs_initiale
	FichiersJsonService.effacer_racine_utilisateur()
	FichiersJsonService.reinitialiser_racine_utilisateur()

func _menu() -> Control:
	var menu: Control = add_child_autofree(SCENE_MENU.instantiate())
	menu.delay_ms = 0
	return menu

func _bouton_joueur(menu: Node, nom: String) -> Button:
	return menu.player_buttons[nom]

func _noms_affiches(menu: Node) -> Array:
	var noms := []
	for bouton in menu.get_node(ZONE_JOUEURS).get_children():
		if not bouton.is_queued_for_deletion():
			noms.append(bouton.text.strip_edges())
	return noms

func _scene_apres_changement() -> String:
	await wait_process_frames(3)
	return get_tree().current_scene.scene_file_path

# ------------------------------------------------------------------
# Construction

func test_textes_du_menu() -> void:
	var menu := _menu()

	assert_eq(menu.get_node("LowerFlow/PlayerSection/PlayerHeading/PlayerTitle").text, "JOUEURS")
	assert_eq(menu.get_node("LowerFlow/Scores/Text").text, "Scores")
	assert_eq(menu.get_node("LowerFlow/Apropos/Text").text, "À propos")
	assert_eq(menu.get_node(LIGNES + "Musique/Text").text, "Musique")
	assert_eq(menu.get_node(LIGNES + "EffetsSonores/Text").text, "Effets sonores")
	assert_eq(menu.get_node(LIGNES + "Vibration/Text").text, "Vibration")

func test_la_version_affichee_est_celle_de_la_configuration() -> void:
	var menu := _menu()

	assert_eq(menu.get_node(LIGNES + "Version").text, SauvegardeConfigurationService.lire_la_version())

func test_au_demarrage_les_joueurs_sont_replies_et_la_configuration_visible() -> void:
	var menu := _menu()

	assert_false(menu.expanded)
	assert_false(menu.get_node("PlayersOutline").visible)
	assert_false(menu.get_node("LowerFlow/PlayerSection").visible)
	assert_false(menu.get_node("LowerFlow/BottomSpace").visible)
	assert_true(menu.get_node("LowerFlow/CenterConfiguration").visible)

func test_la_vibration_est_visible_hors_web() -> void:
	if OS.has_feature("web"):
		pending("Spécifique au web")
		return
	var menu := _menu()

	assert_true(menu.get_node(LIGNES + "Vibration").visible)
	assert_true(menu.get_node(LIGNES + "Vibration/Button").visible)

func test_l_icone_effets_sonores_recoit_un_materiau_colorise() -> void:
	var menu := _menu()

	assert_is(menu.get_node(LIGNES + "EffetsSonores/Icon").material, ShaderMaterial)
	assert_null(menu.get_node(LIGNES + "Musique/Icon").material)

func test_les_interrupteurs_refletent_la_configuration_initiale() -> void:
	SauvegardeConfigurationService.configuration_du_jeu["musiques"] = true
	SauvegardeConfigurationService.configuration_du_jeu["effets sonores"] = false
	var menu := _menu()

	assert_eq(menu.get_node(LIGNES + "Musique/Dot").position.x, 222.0)
	assert_eq(menu.get_node(LIGNES + "EffetsSonores/Dot").position.x, 203.0)

# ------------------------------------------------------------------
# Interrupteurs

func test_bouton_musique_desactive_puis_active_la_musique() -> void:
	SauvegardeConfigurationService.activer_musiques()
	var menu := _menu()
	var bouton: Button = menu.get_node(LIGNES + "Musique/Button")

	bouton.button_pressed = true
	assert_false(SauvegardeConfigurationService.musiques_sont_actives() and not bouton.button_pressed)
	bouton.button_pressed = false
	assert_false(SauvegardeConfigurationService.musiques_sont_actives())
	bouton.button_pressed = true
	assert_true(SauvegardeConfigurationService.musiques_sont_actives())

func test_bouton_effets_sonores_modifie_la_configuration() -> void:
	SauvegardeConfigurationService.activer_effets_sonores()
	var menu := _menu()
	var bouton: Button = menu.get_node(LIGNES + "EffetsSonores/Button")

	bouton.button_pressed = false
	assert_false(SauvegardeConfigurationService.effets_sonores_sont_actifs())
	bouton.button_pressed = true
	assert_true(SauvegardeConfigurationService.effets_sonores_sont_actifs())

func test_bouton_vibration_modifie_la_configuration() -> void:
	SauvegardeConfigurationService.activer_vibrations()
	var menu := _menu()
	var bouton: Button = menu.get_node(LIGNES + "Vibration/Button")

	bouton.button_pressed = false
	assert_false(SauvegardeConfigurationService.vibrations_sont_actives())
	bouton.button_pressed = true
	assert_true(SauvegardeConfigurationService.vibrations_sont_actives())

func test_le_pastille_suit_l_etat_de_l_interrupteur() -> void:
	var menu := _menu()
	var bouton: Button = menu.get_node(LIGNES + "Musique/Button")
	var pastille: Panel = menu.get_node(LIGNES + "Musique/Dot")

	bouton.button_pressed = true
	assert_eq(pastille.position.x, 222.0)
	bouton.button_pressed = false
	assert_eq(pastille.position.x, 203.0)

func test_le_fond_du_curseur_change_de_couleur_selon_l_etat() -> void:
	var menu := _menu()
	var bouton: Button = menu.get_node(LIGNES + "Musique/Button")
	var pilule: Panel = menu.get_node(LIGNES + "Musique/Pill")

	bouton.button_pressed = true
	assert_eq(pilule.get_theme_stylebox("panel").bg_color, UIV3.CORAL)
	bouton.button_pressed = false
	assert_eq(pilule.get_theme_stylebox("panel").bg_color, Color("566878"))

func test_filtrer_click_absorbe_les_clics_rapproches() -> void:
	var menu := _menu()
	menu.delay_ms = 100000
	menu.last_click_time = -100000

	assert_false(menu.filtrer_click())
	assert_true(menu.filtrer_click())
	assert_true(menu.filtrer_click())

func test_filtrer_click_laisse_passer_apres_le_delai() -> void:
	var menu := _menu()
	menu.delay_ms = 0

	assert_false(menu.filtrer_click())
	assert_false(menu.filtrer_click())

func test_un_clic_filtre_n_est_pas_applique_et_retablit_l_etat_reel() -> void:
	SauvegardeConfigurationService.activer_musiques()
	var menu := _menu()
	var bouton: Button = menu.get_node(LIGNES + "Musique/Button")
	menu.delay_ms = 100000
	menu.last_click_time = Time.get_ticks_msec()

	bouton.button_pressed = true
	bouton.button_pressed = false

	assert_true(SauvegardeConfigurationService.musiques_sont_actives())
	assert_true(bouton.button_pressed)

func test_un_clic_filtre_sur_effets_sonores_retablit_l_etat_reel() -> void:
	SauvegardeConfigurationService.desactiver_effets_sonores()
	var menu := _menu()
	var bouton: Button = menu.get_node(LIGNES + "EffetsSonores/Button")
	menu.delay_ms = 100000
	menu.last_click_time = Time.get_ticks_msec()

	bouton.button_pressed = true

	assert_false(bouton.button_pressed)

func test_un_clic_filtre_sur_vibration_retablit_l_etat_reel() -> void:
	SauvegardeConfigurationService.activer_vibrations()
	var menu := _menu()
	var bouton: Button = menu.get_node(LIGNES + "Vibration/Button")
	menu.delay_ms = 100000
	menu.last_click_time = Time.get_ticks_msec()

	bouton.button_pressed = true
	bouton.button_pressed = false

	assert_true(SauvegardeConfigurationService.vibrations_sont_actives())
	assert_true(bouton.button_pressed)

# ------------------------------------------------------------------
# Liste des joueurs

func test_bouton_campagne_deplie_puis_replie_la_liste() -> void:
	var menu := _menu()

	menu.get_node("CampaignButton").emit_signal("pressed")
	assert_true(menu.expanded)
	assert_true(menu.get_node("PlayersOutline").visible)
	assert_true(menu.get_node("LowerFlow/PlayerSection").visible)
	assert_true(menu.get_node("LowerFlow/BottomSpace").visible)
	assert_false(menu.get_node("LowerFlow/CenterConfiguration").visible)

	menu.get_node("CampaignButton").emit_signal("pressed")
	assert_false(menu.expanded)
	assert_false(menu.get_node("PlayersOutline").visible)
	assert_true(menu.get_node("LowerFlow/CenterConfiguration").visible)

func test_le_depliage_decale_le_bouton_et_la_zone_basse() -> void:
	var menu := _menu()

	menu.get_node("CampaignButton").emit_signal("pressed")
	assert_eq(menu.get_node("CampaignButton").position.y, 198.0)
	assert_eq(menu.get_node("LowerFlow").position.y, 282.0)
	assert_eq(menu.get_node("LowerFlow").size.y, 403.0)

	menu.get_node("CampaignButton").emit_signal("pressed")
	assert_eq(menu.get_node("CampaignButton").position.y, 203.0)
	assert_eq(menu.get_node("LowerFlow").position.y, 305.0)
	assert_eq(menu.get_node("LowerFlow").size.y, 233.0)

func test_un_bouton_par_joueur_dans_l_ordre_de_la_liste() -> void:
	_declarer_joueur("Alice", 0, false)
	_declarer_joueur("Bob", 1, false)
	var menu := _menu()

	menu.get_node("CampaignButton").emit_signal("pressed")

	assert_eq(_noms_affiches(menu), ["Alice", "Bob"])
	assert_eq(menu.player_buttons.keys(), ["Alice", "Bob"])

func test_liste_vide_aucun_bouton() -> void:
	var menu := _menu()

	menu.get_node("CampaignButton").emit_signal("pressed")

	assert_eq(menu.player_buttons.size(), 0)
	assert_eq(menu.get_node(ZONE_JOUEURS).get_child_count(), 0)

func test_recharger_les_joueurs_ne_duplique_pas_les_boutons() -> void:
	_declarer_joueur("Alice", 0, false)
	var menu := _menu()
	menu._show_campaign_players(true)
	await wait_process_frames(2)

	menu._reload_players()
	await wait_process_frames(2)

	assert_eq(_noms_affiches(menu), ["Alice"])
	assert_eq(menu.player_buttons.size(), 1)

func test_la_hauteur_de_la_liste_est_bornee() -> void:
	for i in range(8):
		_declarer_joueur("J%d" % i, i, false)
	var menu := _menu()
	menu._show_campaign_players(true)

	assert_eq(menu.get_node("LowerFlow/PlayerSection/PlayerScroll").custom_minimum_size.y, 152.0)

func test_la_hauteur_de_la_liste_a_un_minimum() -> void:
	var menu := _menu()
	menu._show_campaign_players(true)

	assert_eq(menu.get_node("LowerFlow/PlayerSection/PlayerScroll").custom_minimum_size.y, 37.0)

func test_la_hauteur_de_la_liste_suit_le_nombre_de_joueurs() -> void:
	_declarer_joueur("A", 0, false)
	_declarer_joueur("B", 1, false)
	var menu := _menu()
	menu._show_campaign_players(true)

	assert_eq(menu.get_node("LowerFlow/PlayerSection/PlayerScroll").custom_minimum_size.y, 78.0)

func test_le_joueur_anna_recoit_un_avatar() -> void:
	_declarer_joueur(ScoreService.lire_nom_anna_triche(), 0, false)
	_declarer_joueur("Bob", 1, false)
	var menu := _menu()
	menu._show_campaign_players(true)

	assert_eq(_bouton_joueur(menu, ScoreService.lire_nom_anna_triche()).get_child_count(), 1)
	assert_is(_bouton_joueur(menu, ScoreService.lire_nom_anna_triche()).get_child(0), TextureRect)
	assert_eq(_bouton_joueur(menu, "Bob").get_child_count(), 0)

# ------------------------------------------------------------------
# Nouveau joueur

func test_un_nouveau_joueur_est_ajoute_et_affiche() -> void:
	var menu := _menu()
	menu._show_campaign_players(true)

	menu.get_node(AJOUT).emit_signal("text_submitted", "Camille")

	assert_true(SauvegardeListeJoueursService.le_joueur_existe("Camille"))
	assert_true(menu.player_buttons.has("Camille"))
	assert_true(SauvegardeTableauDesScoresService.le_joueur_existe("Camille"))

func test_le_champ_de_saisie_est_vide_apres_validation() -> void:
	var menu := _menu()
	menu._show_campaign_players(true)
	menu.get_node(AJOUT).text = "Camille"

	menu.get_node(AJOUT).emit_signal("text_submitted", "Camille")

	assert_eq(menu.get_node(AJOUT).text, "")

func test_un_nom_vide_est_refuse() -> void:
	var menu := _menu()
	menu._show_campaign_players(true)
	menu.get_node(AJOUT).text = "   "

	menu.get_node(AJOUT).emit_signal("text_submitted", "   ")

	assert_eq(SauvegardeListeJoueursService.retourner_la_liste_des_joueurs(), [])
	assert_eq(menu.player_buttons.size(), 0)
	assert_eq(menu.get_node(AJOUT).text, "")

func test_un_nom_existant_est_refuse_sans_doublon() -> void:
	_declarer_joueur("Alice", 0, false)
	var menu := _menu()
	menu._show_campaign_players(true)

	menu.get_node(AJOUT).emit_signal("text_submitted", "alice")

	assert_eq(SauvegardeListeJoueursService.retourner_la_liste_des_joueurs(), ["Alice"])

func test_le_nom_anna_est_remplace_par_le_nom_special() -> void:
	var menu := _menu()
	menu._show_campaign_players(true)

	menu.get_node(AJOUT).emit_signal("text_submitted", "anna")

	assert_true(menu.player_buttons.has(ScoreService.lire_nom_anna_triche()))
	assert_false(SauvegardeListeJoueursService.le_joueur_existe("anna"))

# ------------------------------------------------------------------
# Navigation

func test_bouton_scores_charge_l_ecran_des_scores() -> void:
	var menu := _menu()

	menu.get_node("LowerFlow/Scores/ScoresButton").emit_signal("pressed")

	assert_eq(await _scene_apres_changement(), "res://Scenes/MenuPrincipal/Scores/scores.tscn")

func test_bouton_a_propos_charge_l_ecran_a_propos() -> void:
	var menu := _menu()

	menu.get_node("LowerFlow/Apropos/AProposButton").emit_signal("pressed")

	assert_eq(await _scene_apres_changement(), "res://Scenes/MenuPrincipal/APropos/a_propos.tscn")

func test_joueur_avec_campagne_en_cours_ouvre_la_campagne() -> void:
	_declarer_joueur("Alice", 0, false)
	var menu := _menu()
	menu._show_campaign_players(true)

	_bouton_joueur(menu, "Alice").emit_signal("pressed")

	assert_eq(await _scene_apres_changement(), "res://Scenes/MenuPrincipal/Campagne/campagne.tscn")

func test_joueur_avec_campagne_terminee_ouvre_les_statistiques() -> void:
	_declarer_joueur("Alice", 0, true)
	var menu := _menu()
	menu._show_campaign_players(true)

	_bouton_joueur(menu, "Alice").emit_signal("pressed")

	assert_eq(await _scene_apres_changement(), "res://Scenes/MenuPrincipal/Campagne/Statistiques/statistiques.tscn")

func test_joueur_inconnu_ne_change_pas_de_scene() -> void:
	var menu := _menu()
	var scene_avant := get_tree().current_scene

	menu._on_joueurs_campagne_pressed("Fantome")
	await wait_process_frames(3)

	assert_same(get_tree().current_scene, scene_avant)

func test_joueur_dont_la_sauvegarde_est_illisible_est_retire_de_la_liste() -> void:
	SauvegardeListeJoueursService.liste_des_joueurs.append({"indice": 0, "nom": "Orphelin", "fichier_sauvegarde": "inexistant.json"})
	var menu := _menu()
	var scene_avant := get_tree().current_scene

	menu._on_joueurs_campagne_pressed("Orphelin")
	await wait_process_frames(3)

	assert_same(get_tree().current_scene, scene_avant)
	assert_false(SauvegardeListeJoueursService.le_joueur_existe("Orphelin"))

# ------------------------------------------------------------------
# Import de fichier JSON

func _donnees_import() -> Dictionary:
	return {
		"joueur": "Alice",
		"campagne": {
			"campagne": "campagne_test",
			"niveaux": [{"niveau": "niveau_03", "plateaux": []}]
		}
	}

func test_le_panneau_d_import_fichier_est_cache_au_demarrage() -> void:
	var menu := _menu()

	assert_false(menu.get_node("PanneauImportFichier").visible)

func test_afficher_import_fichier_renseigne_et_montre_le_panneau() -> void:
	var menu := _menu()

	menu.afficher_import_fichier(_donnees_import())

	var contenu := "PanneauImportFichier/Fond/Panel/Contenu/"
	assert_true(menu.get_node("PanneauImportFichier").visible)
	assert_eq(menu.get_node(contenu + "NomJoueur").text, "Joueur : Alice")
	assert_eq(menu.get_node(contenu + "NomCampagne").text, "Campagne : Campagne Test")
	assert_eq(menu.get_node(contenu + "NomNiveau").text, "Niveau : Niveau 03")

func test_afficher_import_fichier_gere_des_donnees_incompletes() -> void:
	var menu := _menu()

	menu.afficher_import_fichier({})

	var contenu := "PanneauImportFichier/Fond/Panel/Contenu/"
	assert_true(menu.get_node("PanneauImportFichier").visible)
	assert_eq(menu.get_node(contenu + "NomJoueur").text, "Joueur : inconnue")
	assert_eq(menu.get_node(contenu + "NomCampagne").text, "Campagne : ")
	assert_eq(menu.get_node(contenu + "NomNiveau").text, "Niveau : Inconnu")

func test_fermer_import_fichier_cache_le_panneau() -> void:
	var menu := _menu()
	menu.afficher_import_fichier(_donnees_import())

	menu.fermer_import_fichier()

	assert_false(menu.get_node("PanneauImportFichier").visible)

func test_refuser_l_import_ferme_le_panneau() -> void:
	var menu := _menu()
	menu.afficher_import_fichier(_donnees_import())

	menu.get_node("PanneauImportFichier/Fond/Panel/Contenu/Boutons/BoutonRefuser").emit_signal("pressed")

	assert_false(menu.get_node("PanneauImportFichier").visible)

func test_accepter_sans_import_en_attente_ne_change_rien() -> void:
	var menu := _menu()
	menu.afficher_import_fichier(_donnees_import())
	var scene_avant := get_tree().current_scene

	menu.get_node("PanneauImportFichier/Fond/Panel/Contenu/Boutons/BoutonAccepter").emit_signal("pressed")
	await wait_process_frames(3)

	assert_same(get_tree().current_scene, scene_avant)
	assert_eq(SauvegardeListeJoueursService.retourner_la_liste_des_joueurs(), [])
