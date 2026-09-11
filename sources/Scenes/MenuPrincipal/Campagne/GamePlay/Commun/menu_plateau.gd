extends Node

class_name MenuPlateau

signal abandon
signal deselection_pile

var chronometre : int = 0
const ASSET_ROOT := "res://Art/UI/IntegrationV4/Gameplay/"
const FONT_REGULAR := preload("res://Art/UI/Fonts/TeXGyreAdventor/texgyreadventor-regular.otf")
const FONT_BOLD := preload("res://Art/UI/Fonts/TeXGyreAdventor/texgyreadventor-bold.otf")
const MENU_PRINCIPAL_SCRIPT := preload("res://Scenes/MenuPrincipal/menu_principal.gd")
const GradePresentationScript = preload("res://Scenes/MenuPrincipal/Grades/grade_presentation.gd")
const AVATAR_FALLBACK := preload("res://Art/UI/IntegrationV4/Gameplay/classique/production_final/AVATAR_FALLBACK_TEST_64x64.png")
@export var presentation_mode := ""
func _ready() -> void:
	_build_presentation()

func configurer_presentation(mode: String) -> void:
	presentation_mode = mode
	_build_presentation()

func _process(_delta: float) -> void:
	var pluriel = "s"
	var nb_coups = SauvegardeBddJoueursService.lire_nombre_coups()
	if nb_coups < 2:
		pluriel = ""
	enregistrer_coups(str(nb_coups))

# #############
# API Gameplay
func enregistrer_gameplay(gameplay : String):
	if has_node("Top/Gameplay"):
		$Top/Gameplay.text = gameplay.to_upper()

func enregistrer_chrono(chrono : String):
	if has_node("Top/ChronoLabel"):
		$Top/ChronoLabel.text = chrono

func enregistrer_coups(coups : String):
	if has_node("Top/CoupsLabel"):
		$Top/CoupsLabel.text = coups

func show():
	_build_presentation()
	$Fond.show()
	$BoutonRetour.show()
	$Top.show()
	$BoutonStatistiques.show()
	$Top/BoutonAbandonner.show()
	if not _is_qpg():
		var plateau := get_parent().get_node_or_null("Plateau")
		if plateau:
			for pile in plateau.liste_piles:
				pile.get_node("Fond").color = Color.TRANSPARENT

func hide():
	$Fond.hide()
	$BoutonRetour.hide()
	$Top.hide()
	$BoutonStatistiques.hide()
	$Top/BoutonAbandonner.hide()

func cacher_accueil():
	hide()

func demarrer_chronometre():
	chronometre = -1
	_on_chronometre_timeout()

func arreter_chronometre():
	$Chronometre.stop()

# ########
# Usine >>
func _on_bouton_abandonner_pressed() -> void:
	$Top/BoutonAbandonner.hide()
	abandon.emit()

func _on_fond_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# LogService.log_debug("Clique souris sur le fond du plateau")
			# Parcourir les piles et déselectionner la pile (comme "timeout" sur la selection)
			deselection_pile.emit()

func _on_chronometre_timeout() -> void:
	# Relance le chronometre
	$Chronometre.start()
	# Incrémente le compteur
	chronometre += 1
	# MàJ affichage
	enregistrer_chrono(str(floori(chronometre/60.)).pad_zeros(2)+':'+str(chronometre%60).pad_zeros(2))

func _build_presentation() -> void:
	# The shared UI derives the mode from the gameplay scene.  It must never
	# choose or reset the gameplay itself; the exported value is only a
	# compatibility hint for older scenes.
	var qpg := get_parent().name == "QuiPerdGagne"
	$Fond.texture = load(ASSET_ROOT + ("qui_perd_gagne/bg_gameplay_qui_perd_gagne_480x720.png" if qpg else "classique/production_final/BACKGROUND_CLASSIQUE_HEADER_SAFE_480x720.png"))
	$BoutonRetour.texture_normal = load(ASSET_ROOT + ("qui_perd_gagne/REF_back_button_crop.png" if qpg else "classique/production_final/03_BACK_CLASSIQUE_48x56.png"))
	$BoutonRetour.position = Vector2(8,44) if qpg else Vector2(4,137)
	$Top.position = Vector2(70,38) if qpg else Vector2(51,135)
	$Top/TopPanel.texture = load(ASSET_ROOT + ("qui_perd_gagne/production_clean/top_panel_qpg_clean.png" if qpg else "classique/production_final/01_HEADER_CLASSIQUE_STATIC_365x58.png"))
	$BoutonStatistiques.texture_normal = load(ASSET_ROOT + ("qui_perd_gagne/production_clean/statistics_button_qpg_clean.png" if qpg else "classique/production_final/04_STATISTIQUES_CLASSIQUE_60x58.png"))
	$BoutonStatistiques.position = Vector2(408,38) if qpg else Vector2(415,135)
	$BoutonStatistiques.size = Vector2(60,66) if qpg else Vector2(60,58)
	$BoutonStatistiques/StatistiquesLabel.add_theme_color_override("font_color", Color.WHITE if qpg else Color("0a3765"))
	$Top/BoutonAbandonner.modulate = Color.WHITE
	$Top/BoutonAbandonner.self_modulate = Color.WHITE
	$Top/BoutonAbandonner.texture_normal = load(ASSET_ROOT + ("qui_perd_gagne/production_clean/restart_button_qpg_clean.png" if qpg else "classique/production_final/05_RECOMMENCER_CLASSIQUE_244x60.png"))
	$Top/BoutonAbandonner.position = Vector2(38,502) if qpg else Vector2(61,456)
	$Top/BoutonAbandonner.size = Vector2(264,58) if qpg else Vector2(236,60)
	$Top/BoutonAbandonner/RestartLabel.position.x = 100 if qpg else 82
	$Top/BoutonAbandonner/RestartLabel.size.x = 126 if qpg else 142
	# Classique utilise un libellé rasterisé dans le pack validé ; le label historique reste actif pour QPG.
	$Top/BoutonAbandonner/RestartLabel.visible = qpg
	_build_top_contents(qpg)

func _is_qpg() -> bool:
	return get_parent().name == "QuiPerdGagne"

func _build_top_contents(qpg: bool) -> void:
	$Top/ModeIcon.texture = load(ASSET_ROOT + ("qui_perd_gagne/icon_diablotin_neon.png" if qpg else "classique/icon_stacked_cubes.png"))
	$Top/ModeIcon.position = Vector2(8,9) if qpg else Vector2(8,17)
	$Top/ModeIcon.size = Vector2(43,48) if qpg else Vector2(48,30)
	$Top/Check.visible = not qpg
	$Top/Gameplay.text = "QUI PERD GAGNE" if qpg else "CLASSIQUE"
	$Top/Gameplay.add_theme_font_size_override("font_size", 11 if qpg else 15)
	$Top/Gameplay.add_theme_color_override("font_color", Color("ff1597") if qpg else Color("063b75"))
	$Top/Gameplay.position = Vector2(76 if qpg else 92,8)
	$Top/Gameplay.size = Vector2(121 if qpg else 94,20)
	$Top/Subtitle.text = "Bloque le jeu pour gagner." if qpg else "Empile les couleurs"
	$Top/Subtitle.add_theme_color_override("font_color", Color.WHITE if qpg else Color("079ab2"))
	$Top/Subtitle.position = Vector2(76 if qpg else 92,29)
	$Top/Subtitle.size = Vector2(121 if qpg else 94,18)
	var level := SauvegardeBddJoueursService.enregistrement_lire_valeur_niveau_joueur()
	var percent := clampi(SauvegardeBddJoueursService.lire_pourcentage_niveau_realise(),0,100)
	$Top/Progression.text = "Niveau %s : %s %%" % [level,percent]
	$Top/Progression.add_theme_color_override("font_color", Color.WHITE if qpg else Color("063b75"))
	$Top/Progression.position = Vector2(199 if qpg else 190,10)
	$Top/Progression.size = Vector2(64 if qpg else 70,18)
	$Top/ProgressBarBackground.color = Color("44266e") if qpg else Color("f3d8bf")
	$Top/ProgressBarBackground.position.x = 200 if qpg else 190
	$Top/ProgressBar.color = Color("fd198e") if qpg else Color("f04d3c")
	$Top/ProgressBar.position.x = 200 if qpg else 190
	$Top/ProgressBar.size.x = 62.0 * percent / 100.0
	var player_name := SauvegardeBddJoueursService.lire_nom_joueur()
	var avatar_path := _avatar_path(player_name)
	$Top/Avatar.position = Vector2(253 if qpg else 243,16)
	$Top/Avatar.size = Vector2(30,30) if qpg else Vector2(34,34)
	$Top/Avatar.texture = load(avatar_path) if not avatar_path.is_empty() else null
	$Top/Avatar.visible = not avatar_path.is_empty()
	$Top/NomJoueur.text = player_name
	$Top/NomJoueur.add_theme_color_override("font_color", Color.WHITE if qpg else Color("063b75"))
	$Top/NomJoueur.position = Vector2(283 if qpg else 277,13)
	$Top/NomJoueur.size = Vector2(46 if qpg else 38,38)
	$Top/Heart.visible = not qpg
	$Top/ChronoLabel.visible = not qpg
	$Top/CoupsLabel.visible = not qpg
	$Top/ProgressPercent.visible = not qpg
	$Top/CoupsTitle.visible = qpg
	$Top/ChronoIcon.visible = qpg
	$PlayerCard.visible = not qpg
	$Top/ModeIcon.visible = qpg
	$Top/Check.visible = qpg
	$Top/Gameplay.visible = qpg
	$Top/Subtitle.visible = qpg
	$Top/GameplayDivider.visible = qpg
	$Top/PlayerDivider.visible = qpg
	$Top/ProgressionDivider.visible = false
	$BoutonStatistiques/StatistiquesLabel.visible = qpg
	if not qpg:
		# Le header de production contient déjà les éléments statiques ; masquer les doublons.
		for duplicate in ["ModeIcon", "Check", "Gameplay", "Subtitle", "ChronoIcon", "CoupsTitle", "ProgressionTrack", "ProgressBarBackground", "HeaderRule", "GameplayDivider", "PlayerDivider", "ProgressionDivider"]:
			$Top.get_node(duplicate).hide()
		$BoutonStatistiques/StatistiquesLabel.hide()
		$Top/BoutonAbandonner/RestartLabel.hide()
		$PlayerCard/CardAvatar.position = Vector2(10,7)
		$PlayerCard/CardAvatar.size = Vector2(39,42)
		$PlayerCard/CardAvatar.texture = $Top/Avatar.texture if $Top/Avatar.visible else AVATAR_FALLBACK
		$PlayerCard/CardAvatar.visible = true
		$PlayerCard/CardName.position = Vector2(51,14)
		$PlayerCard/CardName.size = Vector2(77,27)
		$PlayerCard/CardName.text = player_name
		$PlayerCard/CardHeart.position = Vector2(133,14)
		$PlayerCard/CardHeart.size = Vector2(23,27)
		$PlayerCard/CardHeart.visible = $Top/Heart.visible
		$Top/Avatar.hide()
		$Top/NomJoueur.hide()
		$Top/Heart.hide()
		$Top/ChronoLabel.position = Vector2(309,7)
		$Top/ChronoLabel.size = Vector2(43,23)
		$Top/ChronoLabel.add_theme_font_size_override("font_size", 14)
		$Top/ChronoLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		$Top/CoupsLabel.position = Vector2(334,32)
		$Top/CoupsLabel.size = Vector2(25,24)
		$Top/CoupsLabel.add_theme_font_size_override("font_size", 13)
		$Top/CoupsLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		$Top/CoupsLabel.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
		$Top/CoupsLabel.add_theme_constant_override("shadow_offset_x", 0)
		$Top/CoupsLabel.add_theme_constant_override("shadow_offset_y", 0)
		$Top/Progression.position = Vector2(170,7)
		$Top/Progression.size = Vector2(62,22)
		$Top/Progression.add_theme_font_size_override("font_size", 14)
		$Top/Progression.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		$Top/Progression.text = "Niveau %s" % level
		$Top/ProgressPercent.position = Vector2(240,32)
		$Top/ProgressPercent.size = Vector2(35,24)
		$Top/ProgressPercent.add_theme_font_size_override("font_size", 13)
		$Top/ProgressPercent.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		$Top/ProgressPercent.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
		$Top/ProgressPercent.add_theme_constant_override("shadow_offset_x", 0)
		$Top/ProgressPercent.add_theme_constant_override("shadow_offset_y", 0)
		$Top/ProgressPercent.text = "%s %%" % percent
		$Top/ProgressionTrack.position = Vector2(171,38)
		$Top/ProgressionTrack.size = Vector2(64,9)
		$Top/ProgressBarBackground.position = Vector2(171,38)
		$Top/ProgressBarBackground.size = Vector2(64,9)
		$Top/ProgressBar.position = Vector2(171,38)
		$Top/ProgressBar.size.x = 64.0 * percent / 100.0
	else:
		# Restore the legacy QPG controls when a shared instance is reused.
		$PlayerCard.hide()
		$Top/Avatar.visible = not avatar_path.is_empty()
		$Top/NomJoueur.show()
		$Top/Heart.hide()
		$Top/ChronoLabel.hide()
		$Top/CoupsLabel.hide()

func _avatar_path(player_name: String) -> String:
	# Gameplay identity uses the active player's grade medal; no portrait fallback.
	return GradePresentationScript.texture_path_for_stats_player(player_name)

func _on_bouton_retour_pressed() -> void:
	AudioService.son_menu_click()
	AudioService.arreter_la_musique()
	var gameplay := get_parent()
	if gameplay and gameplay.has_method("hide"):
		gameplay.hide()
	get_tree().change_scene_to_file("res://Scenes/MenuPrincipal/menu_principal.tscn")

func _on_bouton_statistiques_pressed() -> void:
	AudioService.son_menu_click()
	get_tree().change_scene_to_file("res://Scenes/MenuPrincipal/Campagne/MenuCampagne/Statistiques/statistiques.tscn")
