extends Node

class_name MenuPlateau

signal abandon
signal deselection_pile

const ASSET_ROOT := "res://Art/UI/IntegrationV4/Gameplay/"
const QPG_BACKGROUND_TEXTURE := ASSET_ROOT + "qui_perd_gagne/qpg_background_clean_v2_480x720.png"
const QPG_ACTIVE_BANNER := ASSET_ROOT + "qui_perd_gagne/qpg_actif_statique_v2_480x96.png"
const QPG_RESTART_BUTTON := ASSET_ROOT + "qui_perd_gagne/qpg_recommencer_v2_244x60.png"
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
	_maj_chrono()
	_maj_coups()

# #############
# API Gameplay
func enregistrer_gameplay(gameplay : String):
	if has_node("Top/Gameplay"):
		$Top/Gameplay.text = gameplay.to_upper()

func enregistrer_chrono(minutes: String, secondes: String = "", decisecondes: String = ""):
	if has_node("Top/ChronoLabel"):
		var chrono := minutes
		if not secondes.is_empty():
			chrono = minutes + ":" + secondes + "." + decisecondes
		$Top/ChronoLabel.text = chrono

func enregistrer_coups(coups : String):
	if has_node("Top/CoupsLabel"):
		$Top/CoupsLabel.text = coups

func show():
	_build_presentation()
	$Fond.show()
	$Top.show()
	if _is_qpg():
		$BoutonRetour.hide()
		$BoutonStatistiques.hide()
	else:
		$BoutonRetour.hide()
		$BoutonStatistiques.hide()
	$Top/BoutonRecommencer.show()
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
	$Top/BoutonRecommencer.hide()

func cacher_accueil():
	hide()

func _maj_chrono() -> void:
	var temps_ecoule_en_s: float = SauvegardeBddJoueursService.enregistrement_lire_duree_plateau()
	var minutes := floori(temps_ecoule_en_s / 60.0)
	var secondes := floori(temps_ecoule_en_s - 60 * minutes)
	var decisecondes := roundi((temps_ecoule_en_s - 60 * minutes - secondes) * 10.0)
	if decisecondes == 10:
		decisecondes = 0
		secondes += 1
	if secondes == 60:
		secondes = 0
		minutes += 1
	enregistrer_chrono(str(minutes).pad_zeros(2), str(secondes).pad_zeros(2), str(decisecondes))

func _maj_coups() -> void:
	enregistrer_coups(str(SauvegardeBddJoueursService.lire_nombre_coups()))

# ########
# Usine >>
func _on_bouton_recommencer_pressed() -> void:
	$Top/BoutonRecommencer.hide()
	abandon.emit()

func _on_fond_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# LogService.log_debug("Clique souris sur le fond du plateau")
			# Parcourir les piles et déselectionner la pile (comme "timeout" sur la selection)
			deselection_pile.emit()

func _build_presentation() -> void:
	# The shared UI derives the mode from the gameplay scene.  It must never
	# choose or reset the gameplay itself; the exported value is only a
	# compatibility hint for older scenes.
	var qpg := get_parent().name == "QuiPerdGagne"
	$Fond.texture = load(QPG_BACKGROUND_TEXTURE if qpg else ASSET_ROOT + "classique/production_final/BACKGROUND_CLASSIQUE_HEADER_SAFE_480x720.png")
	$Fond.position = Vector2.ZERO
	$Fond.size = Vector2(480, 720)
	$BoutonRetour.texture_normal = load(ASSET_ROOT + ("qui_perd_gagne/REF_back_button_crop.png" if qpg else "classique/production_final/03_BACK_CLASSIQUE_48x56.png"))
	$BoutonRetour.position = Vector2(8,44) if qpg else Vector2(4,137)
	$Top.position = Vector2(70,38) if qpg else Vector2(51,135)
	$Top/TopPanel.texture = load(ASSET_ROOT + ("qui_perd_gagne/production_clean/top_panel_qpg_clean.png" if qpg else "classique/production_final/01_HEADER_CLASSIQUE_STATIC_365x58.png"))
	$BoutonStatistiques.texture_normal = load(ASSET_ROOT + "qui_perd_gagne/production_clean/statistics_button_qpg_clean.png") if qpg else null
	$BoutonStatistiques.position = Vector2(408,38) if qpg else Vector2(415,135)
	$BoutonStatistiques.size = Vector2(60,66) if qpg else Vector2(60,58)
	$BoutonStatistiques/StatistiquesLabel.add_theme_color_override("font_color", Color.WHITE if qpg else Color("0a3765"))
	$Top/BoutonRecommencer.modulate = Color.WHITE
	$Top/BoutonRecommencer.self_modulate = Color.WHITE
	$Top/BoutonRecommencer.texture_normal = load(ASSET_ROOT + ("qui_perd_gagne/production_clean/restart_button_qpg_clean.png" if qpg else "classique/production_final/05_RECOMMENCER_CLASSIQUE_244x60.png"))
	$Top/BoutonRecommencer.position = Vector2(38,502) if qpg else Vector2(110,92)
	$Top/BoutonRecommencer.size = Vector2(264,58) if qpg else Vector2(244,60)
	$Top/BoutonRecommencer/RestartLabel.position.x = 100 if qpg else 82
	$Top/BoutonRecommencer/RestartLabel.size.x = 126 if qpg else 142
	# Classique utilise un libellé rasterisé dans le pack validé ; le label historique reste actif pour QPG.
	$Top/BoutonRecommencer/RestartLabel.visible = qpg
	if qpg:
		$Top.position = Vector2.ZERO
		$Top.size = Vector2(480, 96)
		$Top.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
		$Top/BannerBackground.hide()
		$Top/TopPanel.texture = load(QPG_ACTIVE_BANNER)
		$Top/TopPanel.position = Vector2.ZERO
		$Top/TopPanel.size = Vector2(480, 96)
		$Top/TopPanel.show()
		$BoutonRetour.texture_normal = null
		$BoutonStatistiques.texture_normal = null
		$Top/BoutonRecommencer.position = Vector2(118, 101)
		$Top/BoutonRecommencer.size = Vector2(244, 60)
		$Top/BoutonRecommencer.texture_normal = load(QPG_RESTART_BUTTON)
		$Top/BoutonRecommencer/RestartLabel.hide()
		for state in ["normal", "hover", "pressed", "focus", "disabled"]:
			$Top/BoutonRecommencer.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	_build_top_contents(qpg)

func _is_qpg() -> bool:
	return get_parent().name == "QuiPerdGagne"

func _build_top_contents(qpg: bool) -> void:
	if qpg:
		_build_qpg_active_contents()
		return
	_build_classique_contents()

func _build_classique_contents() -> void:
	var level := SauvegardeBddJoueursService.enregistrement_lire_valeur_niveau_joueur()
	var percent := clampi(SauvegardeBddJoueursService.lire_pourcentage_niveau_realise(),0,100)
	$Top/ModeIcon.texture = null
	$Top/ModeIcon.position = Vector2(8,17)
	$Top/ModeIcon.size = Vector2(48,30)
	$Top/Check.visible = true
	$Top/Gameplay.text = "CLASSIQUE"
	$Top/Gameplay.add_theme_font_size_override("font_size", 15)
	$Top/Gameplay.add_theme_color_override("font_color", Color("063b75"))
	$Top/Gameplay.position = Vector2(92,8)
	$Top/Gameplay.size = Vector2(94,20)
	$Top/Subtitle.text = "Empile les couleurs"
	$Top/Subtitle.add_theme_color_override("font_color", Color("079ab2"))
	$Top/Subtitle.position = Vector2(92,29)
	$Top/Subtitle.size = Vector2(94,18)
	$Top/Progression.text = "Niveau %s : %s %%" % [level,percent]
	$Top/Progression.add_theme_color_override("font_color", Color("063b75"))
	$Top/Progression.position = Vector2(190,10)
	$Top/Progression.size = Vector2(70,18)
	$Top/ProgressBarBackground.color = Color("f3d8bf")
	$Top/ProgressBarBackground.position.x = 190
	$Top/ProgressBar.color = Color("f04d3c")
	$Top/ProgressBar.position.x = 190
	$Top/ProgressBar.size.x = 62.0 * percent / 100.0
	var player_name := SauvegardeBddJoueursService.lire_nom_joueur()
	var avatar_path := _avatar_path(player_name)
	$Top/Avatar.position = Vector2(243,16)
	$Top/Avatar.size = Vector2(34,34)
	$Top/Avatar.texture = load(avatar_path) if not avatar_path.is_empty() else null
	$Top/Avatar.visible = not avatar_path.is_empty()
	$Top/NomJoueur.text = player_name
	$Top/NomJoueur.add_theme_color_override("font_color", Color("063b75"))
	$Top/NomJoueur.position = Vector2(277,13)
	$Top/NomJoueur.size = Vector2(38,38)
	$Top/Heart.visible = true
	$Top/ChronoLabel.visible = true
	$Top/CoupsLabel.visible = true
	$Top/ProgressPercent.visible = true
	$Top/CoupsTitle.visible = false
	$Top/ChronoIcon.visible = false
	$PlayerCard.visible = true
	$Top/ModeIcon.visible = false
	$Top/Check.visible = true
	$Top/Gameplay.visible = true
	$Top/Subtitle.visible = true
	$Top/GameplayDivider.visible = true
	$Top/PlayerDivider.visible = true
	$Top/ProgressionDivider.visible = false
	$BoutonStatistiques/StatistiquesLabel.visible = false
	_build_classique_banner()

func _build_qpg_active_contents() -> void:
	var player_name := SauvegardeBddJoueursService.lire_nom_joueur()
	var avatar_path := _avatar_path(player_name)
	for node_name in ["ModeIcon", "ModeIcon2", "ModeIcon3", "Check", "Gameplay", "Subtitle", "GameplayDivider", "ProgressionDivider", "PlayerDivider", "HeaderRule", "Progression", "ProgressPercent", "ProgressionTrack", "ProgressBarBackground", "ProgressBar", "Heart", "CoupsTitle", "ChronoIcon"]:
		$Top.get_node(node_name).hide()
	$PlayerCard.hide()
	$Top/Avatar.position = Vector2(27, 29)
	$Top/Avatar.size = Vector2(33, 37)
	$Top/Avatar.texture = load(avatar_path) if not avatar_path.is_empty() else null
	$Top/Avatar.show()
	$Top/NomJoueur.position = Vector2(68, 19)
	$Top/NomJoueur.size = Vector2(60, 18)
	_configurer_nom_qpg(player_name)
	$Top/GradeName.position = Vector2(68, 49)
	$Top/GradeName.size = Vector2(60, 16)
	$Top/GradeName.text = GradePresentationScript.for_player(player_name).get("name", "Bronze")
	$Top/GradeName.add_theme_font_size_override("font_size", 11)
	$Top/GradeName.add_theme_color_override("font_color", Color("#E8FFFF"))
	$Top/GradeName.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	$Top/GradeName.show()
	$Top/ChronoLabel.position = Vector2(335, 47)
	$Top/ChronoLabel.size = Vector2(61, 18)
	$Top/ChronoLabel.add_theme_font_size_override("font_size", 13)
	$Top/ChronoLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$Top/ChronoLabel.add_theme_color_override("font_color", Color("#E8FFFF"))
	$Top/ChronoLabel.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	$Top/ChronoLabel.show()
	$Top/CoupsLabel.position = Vector2(430, 47)
	$Top/CoupsLabel.size = Vector2(38, 18)
	$Top/CoupsLabel.add_theme_font_size_override("font_size", 13)
	$Top/CoupsLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$Top/CoupsLabel.add_theme_color_override("font_color", Color("#E8FFFF"))
	$Top/CoupsLabel.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	$Top/CoupsLabel.show()

func _configurer_nom_qpg(player_name: String) -> void:
	var label := $Top/NomJoueur
	label.text = player_name
	label.clip_text = true
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.pivot_offset = Vector2.ZERO
	label.scale = Vector2.ONE
	var font_size := 11
	while font_size > 8 and player_name.length() * font_size * 0.58 > label.size.x:
		font_size -= 1
	label.add_theme_font_size_override("font_size", font_size)
	var measured_width: float = label.get_theme_font("font").get_string_size(player_name, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	if measured_width > label.size.x and player_name.contains(" "):
		var words := player_name.split(" ", false)
		var midpoint := maxi(1, words.size() / 2)
		var first_line := " ".join(words.slice(0, midpoint))
		var second_line := " ".join(words.slice(midpoint, words.size()))
		label.text = first_line + "\n" + second_line
		label.add_theme_font_size_override("font_size", 8)
		var first_width: float = label.get_theme_font("font").get_string_size(first_line, HORIZONTAL_ALIGNMENT_LEFT, -1, 8).x
		var second_width: float = label.get_theme_font("font").get_string_size(second_line, HORIZONTAL_ALIGNMENT_LEFT, -1, 8).x
		label.scale = Vector2(minf(1.0, label.size.x / maxf(maxf(first_width, second_width), 1.0)), 1.0)
	else:
		label.scale = Vector2(minf(1.0, label.size.x / maxf(measured_width, 1.0)), 1.0)
	label.add_theme_color_override("font_color", Color("#E8FFFF"))
	label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.show()

func _avatar_path(player_name: String) -> String:
	# Gameplay identity uses the active player's grade medal; no portrait fallback.
	return GradePresentationScript.texture_path_for_stats_player(player_name)

func _build_classique_banner() -> void:
	"""Compose le bandeau Classique dans une enveloppe unique, sans toucher au gameplay."""
	$Fond.texture = load(ASSET_ROOT + "classique/MASTER_backgroundgameplay_classique_480x720.png")
	$Top.position = Vector2(8, 8)
	$Top.size = Vector2(464, 72)
	$Top/BannerBackground.show()
	$Top/TopPanel.hide()
	# Colonnes identité / mode / temps / coups : 114 / 204 / 68 / 78 px.
	$Top/PlayerDivider.position = Vector2(114, 20)
	$Top/PlayerDivider.size = Vector2(1, 32)
	$Top/GameplayDivider.position = Vector2(318, 20)
	$Top/GameplayDivider.size = Vector2(1, 32)
	$Top/ProgressionDivider.position = Vector2(386, 20)
	$Top/ProgressionDivider.size = Vector2(1, 32)
	$Top/PlayerDivider.show()
	$Top/GameplayDivider.show()
	$Top/ProgressionDivider.show()
	$Top/ModeIcon.texture = load("res://assets/stats/normalized/cube_campagne_34x34_normalized.png")
	$Top/ModeIcon2.texture = load("res://assets/stats/normalized/cube_niveau_34x34_normalized.png")
	$Top/ModeIcon3.texture = load("res://assets/stats/normalized/cube_plateau_34x34_normalized.png")
	$Top/ModeIcon2.show()
	$Top/ModeIcon3.show()
	$Top/ModeIcon.position = Vector2(126, 22)
	$Top/ModeIcon.size = Vector2(36, 28)
	$Top/ModeIcon.show()
	$Top/Check.position = Vector2(168, 24)
	$Top/Check.size = Vector2(20, 24)
	$Top/Check.show()
	$Top/Gameplay.position = Vector2(192, 14)
	$Top/Gameplay.size = Vector2(116, 20)
	$Top/Gameplay.text = "CLASSIQUE"
	$Top/Gameplay.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$Top/Gameplay.show()
	$Top/Subtitle.position = Vector2(184, 36)
	$Top/Subtitle.size = Vector2(126, 18)
	$Top/Subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$Top/Subtitle.show()
	$Top/ChronoIcon.position = Vector2(326, 16)
	$Top/ChronoIcon.size = Vector2(18, 20)
	$Top/ChronoIcon.show()
	$Top/ChronoLabel.position = Vector2(344, 24)
	$Top/ChronoLabel.size = Vector2(66, 24)
	$Top/ChronoLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$Top/ChronoLabel.show()
	$Top/CoupsTitle.position = Vector2(394, 14)
	$Top/CoupsTitle.size = Vector2(64, 20)
	$Top/CoupsTitle.text = "Coups"
	$Top/CoupsTitle.hide()
	$Top/CoupsLabel.position = Vector2(394, 36)
	$Top/CoupsLabel.size = Vector2(64, 24)
	$Top/CoupsLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$Top/CoupsLabel.show()
	# Identité dynamique : médaille, grade, puis pseudo, sans portrait.
	var player_name := SauvegardeBddJoueursService.lire_nom_joueur()
	$Top/Avatar.position = Vector2(12, 12)
	$Top/Avatar.size = Vector2(40, 40)
	$Top/Avatar.texture = load(_avatar_path(player_name))
	$Top/Avatar.show()
	$Top/NomJoueur.position = Vector2(56, 10)
	$Top/NomJoueur.size = Vector2(54, 25)
	$Top/NomJoueur.text = player_name
	$Top/NomJoueur.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	$Top/NomJoueur.clip_text = true
	$Top/NomJoueur.show()
	$Top/GradeName.text = GradePresentationScript.for_player(player_name).get("name", "Bronze")
	$Top/GradeName.position = Vector2(56, 38)
	$Top/GradeName.size = Vector2(54, 20)
	$Top/GradeName.show()
	$Top/Heart.hide()
	$Top/Progression.hide()
	$Top/ProgressPercent.hide()
	$Top/ProgressionTrack.hide()
	$Top/ProgressBarBackground.hide()
	$Top/ProgressBar.hide()
	$Top/HeaderRule.hide()
	$PlayerCard.hide()
	# Le bouton garde son callback historique, mais reste une cible séparée du bandeau.
	$BoutonStatistiques.position = Vector2(408, 88)
	$BoutonStatistiques.size = Vector2(60, 58)
	$BoutonStatistiques/StatistiquesLabel.hide()

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
