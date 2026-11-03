extends GutTest

const SCENE_A_PROPOS = preload("res://Scenes/MenuPrincipal/APropos/a_propos.tscn")
const DOSSIER := "res://Scenes/MenuPrincipal/APropos/"
const SCENE_MENU_PRINCIPAL := "res://Scenes/MenuPrincipal/menu_principal.tscn"
const RACINE_TEST := "tests/test_a_propos"
const CARTES := "PanneauCredits/HBoxContainer/VBox/VBoxCorps/"

var sauvegarde_joueur_initiale: Dictionary
var fichier_sauvegarde_initial: String
var configuration_initiale: Dictionary
var liste_des_scores_initiale: Array
var liste_des_joueurs_initiale: Array

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

func _ecran() -> Control:
	return add_child_autofree(SCENE_A_PROPOS.instantiate())

func _carte(ecran: Node, nom: String) -> Control:
	return ecran.get_node(CARTES + nom)

func _url_du_lien(lien: RichTextLabel) -> String:
	var debut := lien.text.find("url=\"") + 5
	return lien.text.substr(debut, lien.text.find("\"", debut) - debut)

func _scene_apres_changement() -> String:
	await wait_process_frames(3)
	return get_tree().current_scene.scene_file_path

func test_l_ecran_affiche_son_titre_et_son_sous_titre() -> void:
	var ecran := _ecran()

	assert_eq(ecran.get_node("PanneauCredits/HBoxContainer/VBox/VBoxEntete/Titre").text, "À propos")
	assert_eq(ecran.get_node("PanneauCredits/HBoxContainer/VBox/VBoxEntete/SousTitre").text, "Crédits et ressources")

func test_l_ecran_liste_les_cinq_cartes_dans_l_ordre() -> void:
	var ecran := _ecran()

	var noms: Array[String] = []
	for carte in ecran.get_node(CARTES).get_children():
		noms.append(carte.name)
	assert_eq(noms, ["CarteMoteur", "CarteIA", "CarteMusique", "CarteEffetsSonores", "CarteDidacticiel"])

func test_chaque_carte_porte_son_titre() -> void:
	var ecran := _ecran()

	assert_eq(_carte(ecran, "CarteMoteur").get_node("Colonne2/Titre").text, "Moteur")
	assert_eq(_carte(ecran, "CarteIA").get_node("Fond/Colonne2/Titre").text, "IA")
	assert_eq(_carte(ecran, "CarteMusique").get_node("Fond/Colonne2/Titre").text, "Musiques")
	assert_eq(_carte(ecran, "CarteEffetsSonores").get_node("Fond/Colonne2/Titre").text, "Effets sonores")
	assert_eq(_carte(ecran, "CarteDidacticiel").get_node("Fond/Colonne2/Titre").text, "Didacticiel")

func test_les_cartes_citent_leurs_ressources() -> void:
	var ecran := _ecran()

	assert_eq(_carte(ecran, "CarteMoteur").get_node("Colonne2/Item1").text, "Godot Engine")
	assert_true(_carte(ecran, "CarteMoteur").get_node("Colonne2/Item2").text.contains("GUT"))
	assert_true(_carte(ecran, "CarteIA").get_node("Fond/Colonne2/Items").text.contains("ChatGPT"))
	assert_true(_carte(ecran, "CarteMusique").get_node("Fond/Colonne2/Items").text.contains("Su Turno"))
	assert_true(_carte(ecran, "CarteEffetsSonores").get_node("Fond/Colonne2/Items").text.contains("freesound.community"))
	assert_true(_carte(ecran, "CarteDidacticiel").get_node("Fond/Colonne2/Items").text.contains("Baba Des Bois"))

func test_les_liens_des_cartes_pointent_vers_les_sites_cites() -> void:
	var ecran := _ecran()
	var attendus := {
		"CarteMoteur": ["Colonne2/Lien", "https://godotengine.org", "godotengine.org"],
		"CarteMusique": ["Fond/Colonne2/Lien", "https://patrickdearteaga.com", "patrickdearteaga.com"],
		"CarteEffetsSonores": ["Fond/Colonne2/Lien", "https://pixabay.com", "pixabay.com"],
		"CarteDidacticiel": ["Fond/Colonne2/Lien", "https://www.youtube.com/@BabaDesBois", "youtube.com"]
	}

	for nom in attendus:
		var lien: RichTextLabel = _carte(ecran, nom).get_node(attendus[nom][0])
		assert_eq(_url_du_lien(lien), attendus[nom][1], nom)
		assert_eq(lien.get_parsed_text(), attendus[nom][2], nom)

func test_les_liens_cliquables_sont_relies_au_gestionnaire_de_la_carte() -> void:
	var ecran := _ecran()

	for nom in ["CarteMoteur", "CarteMusique", "CarteEffetsSonores", "CarteDidacticiel"]:
		var carte := _carte(ecran, nom)
		var lien: RichTextLabel = carte.get_node("Colonne2/Lien") if nom == "CarteMoteur" else carte.get_node("Fond/Colonne2/Lien")
		assert_true(lien.bbcode_enabled, nom)
		assert_true(lien.meta_clicked.is_connected(carte._on_lien_meta_clicked), nom)

func test_la_carte_ia_n_a_pas_de_lien() -> void:
	var ecran := _ecran()

	assert_null(_carte(ecran, "CarteIA").get_node_or_null("Fond/Colonne2/Lien"))

func test_les_cartes_ne_bloquent_pas_les_clics_sur_leur_contenu() -> void:
	var ecran := _ecran()

	assert_eq(_carte(ecran, "CarteIA").mouse_filter, Control.MOUSE_FILTER_IGNORE)

func test_le_bouton_retour_ramene_au_menu_principal() -> void:
	var ecran := _ecran()

	ecran.get_node("Retour").emit_signal("pressed")

	assert_eq(await _scene_apres_changement(), SCENE_MENU_PRINCIPAL)

func test_le_bouton_retour_est_relie_au_gestionnaire_de_l_ecran() -> void:
	var ecran := _ecran()

	assert_true(ecran.get_node("Retour").pressed.is_connected(ecran._on_retour_pressed))
