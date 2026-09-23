extends Control

const ASSET_DIR := "res://Art/UI/"

const DARK_BLUE := Color("081b2d")
const CORAL := Color("f04d3c")
const NAVY := Color("0a274d")
const CREAM := Color("fff8ed")
const CREAM_BORDER := Color("edc9a5")

var expanded := false
var player_buttons: Dictionary = {}

var delay_ms: int = 100
var last_click_time: int = 0

func _ready() -> void:
	_build_ui()

func _build_ui() -> void:
	var configuration = $LowerFlow/CenterConfiguration/Configuration/Lignes
	var music := _add_setting(configuration.get_node("Musique"),
					 SauvegardeConfigurationService.musiques_sont_actives(),
					 _on_bouton_musiques_toggled)
	var sound := _add_setting(configuration.get_node("EffetsSonores"),
					 SauvegardeConfigurationService.effets_sonores_sont_actifs(),
					 _on_bouton_effets_sonores_toggled)
	var vibration := _add_setting(configuration.get_node("Vibration"),
				 SauvegardeConfigurationService.vibrations_sont_actives(),
				 _on_bouton_vibrations_toggled)
	if OS.has_feature("web"):
		vibration.hide()
	configuration.get_node("Version").text = SauvegardeConfigurationService.lire_la_version()
	_show_campaign_players(false)

func _on_campaign_button_pressed() -> void:
	_show_campaign_players(not expanded)
	AudioService.son_menu_click()
	VibrationService.vibration_click()

func _show_campaign_players(value: bool) -> void:
	"Affiche les joueurs"
	expanded = value
	if not expanded:
		var size = Vector2(425-55, 720-72-110+18)
		$Panneau.set_size(size)
		# Expand est géré dans '_reload_players()'

	$PlayersOutline.visible = expanded
	$CampaignButton.position.y = 198 if expanded else 203
	$LowerFlow.position.y = 282 if expanded else 305
	$LowerFlow.size.y = 403 if expanded else 233
	$LowerFlow/PlayerSection.visible = expanded
	$LowerFlow/BottomSpace.visible = expanded
	$LowerFlow/CenterConfiguration.visible = not expanded
	if expanded: _reload_players()

func _reload_players() -> void:
	for child in $LowerFlow/PlayerSection/PlayerScroll/PlayersCenter/PlayerArea.get_children(): child.queue_free()
	player_buttons.clear()
	var names: Array = SauvegardeListeJoueursService.retourner_la_liste_des_joueurs()
	for nom in names:
		var button := Button.new()
		button.text = "           " + str(nom)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.custom_minimum_size = Vector2(260,37)
		button.add_theme_font_size_override("font_size", 17)
		button.pressed.connect(_on_joueurs_campagne_pressed.bind(str(nom)))
		$LowerFlow/PlayerSection/PlayerScroll/PlayersCenter/PlayerArea.add_child(button)

		_add_player_avatar(button, str(nom))
		_add_player_theme(button)
		player_buttons[str(nom)] = button
	# Ajuster la hauteur des elements graphiques
	var min_size_y = minf(maxf(names.size() * 41.0 - 4.0, 37.0), 152.0)
	$LowerFlow/PlayerSection/PlayerScroll.custom_minimum_size.y = min_size_y
	$Panneau.set_size(Vector2(425-55, 470 + min_size_y))
	$PlayersOutline.set_size(Vector2(322, 167 + min_size_y))

func _add_player_avatar(button: Button, player_name: String) -> void:
	var avatar_path := ""
	if player_name == ScoreService.lire_nom_anna_triche(): avatar_path = ASSET_DIR + "MenuPrincipal/avatar_anna_32x32.png"
	if avatar_path.is_empty():
		return
	var avatar := TextureRect.new()
	avatar.texture = load(avatar_path)
	avatar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	avatar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	avatar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UIV3.place(avatar, Rect2(5,3,32,32))
	button.add_child(avatar)

func _add_player_theme(button: Button) -> void:
	var background := UIV3.CREAM
	var foreground := UIV3.NAVY
	button.add_theme_color_override("font_color", foreground)
	button.add_theme_color_override("font_hover_color", foreground)
	button.add_theme_color_override("font_focus_color", foreground)
	button.add_theme_color_override("font_pressed_color", foreground)
	button.add_theme_stylebox_override("normal", UIV3.box(background, 12))
	button.add_theme_stylebox_override("hover", UIV3.box(background, 12))
	button.add_theme_stylebox_override("focus", UIV3.box(background, 12))
	button.add_theme_stylebox_override("pressed", UIV3.box(background, 12))

func _add_setting(parent: Control, state: bool, callback: Callable) -> Button:
	var label = parent.get_node("Text").text
	if label == "Effets sonores":
		# Colorie l'icone en rouge ! Waouh !
		parent.get_node("Icon").material = _sound_icon_material()

	var pill = parent.get_node("Pill")
	var dot = parent.get_node("Dot")
	var button = parent.get_node("Button")
	_set_toggle_visual(pill,dot,state)
	button.toggled.connect(func(on:bool): _set_toggle_visual(pill,dot,on); callback.call(on))
	return button

func _sound_icon_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;
void fragment() {
	vec4 source = texture(TEXTURE, UV);
	float tone = max(source.r, max(source.g, source.b));
	vec3 dark_color = vec3(0.7764706, 0.2196078, 0.1764706);
	vec3 main_color = vec3(0.9411765, 0.3019608, 0.2352941);
	vec3 light_color = vec3(1.0, 0.6980392, 0.6588235);
	vec3 coral = mix(dark_color, main_color, smoothstep(0.18, 0.62, tone));
	coral = mix(coral, light_color, smoothstep(0.78, 1.0, tone));
	COLOR = vec4(coral, source.a);
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	return material

func _set_toggle_visual(pill: Panel, dot: Panel, on: bool) -> void:
	pill.add_theme_stylebox_override("panel", UIV3.box(UIV3.CORAL if on else Color("566878"), 11))
	dot.position.x = 222 if on else 203

func _on_bouton_a_propos_pressed():
	get_tree().change_scene_to_file("res://Scenes/MenuPrincipal/APropos/a_propos.tscn")
	AudioService.son_menu_click()
	VibrationService.vibration_click()

func _on_bouton_scores_pressed():
	get_tree().change_scene_to_file("res://Scenes/MenuPrincipal/Scores/scores.tscn")
	AudioService.son_menu_click()
	VibrationService.vibration_click()

func _on_joueurs_campagne_pressed(nom_joueur: String) -> void:
	LogService.log_debug("Campagne avec le joueur : ", nom_joueur)
	if not SauvegardeListeJoueursService.le_joueur_existe(nom_joueur):
		LogService.log_erreur("Erreur : Le nom *" + nom_joueur + "* n'existe pas")
		return
	if not ProgressionCampagneService.la_campagne_est_terminee_pour_joueur(nom_joueur):
		# Choisir le joueur pour la campagne
		var succes: bool = ProgressionCampagneService.choisir_le_joueur_pour_la_campagne(nom_joueur)
		if succes:
			AudioService.son_menu_click()
			VibrationService.vibration_click()
			get_tree().change_scene_to_file("res://Scenes/MenuPrincipal/Campagne/campagne.tscn")
		else:
			LogService.log_erreur("Erreur : Impossible de choisir le joueur *" + nom_joueur + "*.")
	else:
		AudioService.son_menu_click()
		VibrationService.vibration_click()
		get_tree().change_scene_to_file("res://Scenes/MenuPrincipal/Campagne/MenuCampagne/Statistiques/statistiques.tscn")

func _on_nouveau_joueur_text_submitted(nom_nouveau_joueur: String):
	if ScoreService.nouveau_joueur_est_nom_anna_triche(nom_nouveau_joueur):
		nom_nouveau_joueur = ScoreService.lire_nom_anna_triche()
	if ProgressionCampagneService.autoriser_le_nouveau_joueur_pour_la_campagne(nom_nouveau_joueur):
		ProgressionCampagneService.initialiser_le_nouveau_joueur_pour_la_campagne(nom_nouveau_joueur)
		_reload_players()
	$LowerFlow/PlayerSection/PlayerRow/Add.text = ''

func _mettre_a_jour_configuration(conf_node_name : String):
	var state_buttons : Dictionary= {
		"Musique": SauvegardeConfigurationService.musiques_sont_actives(),
		"EffetsSonores": SauvegardeConfigurationService.effets_sonores_sont_actifs(),
		"Vibration": SauvegardeConfigurationService.vibrations_sont_actives()
		}

	var configuration = $LowerFlow/CenterConfiguration/Configuration/Lignes
	var status = state_buttons.get(conf_node_name, true)
	var button = configuration.get_node(conf_node_name).get_node("Button")
	button.button_pressed = status

func filtrer_click() -> bool:
	var current_time = Time.get_ticks_msec()
	if current_time - last_click_time < delay_ms:
		print("filtrer_click() filtré ", current_time,"ms")
		return true # Absorbe l'evenement qui ne sera pas trasnmis
	else:
		print("filtrer_click() accepté ", current_time,"ms")
		last_click_time = current_time
		return false

func _on_bouton_musiques_toggled(on: bool):
	if filtrer_click():
		 # Corriger le changement parasite
		_mettre_a_jour_configuration("Musique")
		return
	if on: SauvegardeConfigurationService.activer_musiques()
	else: SauvegardeConfigurationService.desactiver_musiques()
	AudioService.son_menu_click()
	VibrationService.vibration_click()

func _on_bouton_effets_sonores_toggled(on: bool):
	if filtrer_click():
		 # Corriger le changement parasite
		_mettre_a_jour_configuration("EffetsSonores")
		return
	if on: SauvegardeConfigurationService.activer_effets_sonores()
	else: SauvegardeConfigurationService.desactiver_effets_sonores()
	AudioService.son_menu_click()
	VibrationService.vibration_click()

func _on_bouton_vibrations_toggled(on: bool):
	if filtrer_click():
		 # Corriger le changement parasite
		_mettre_a_jour_configuration("Vibration")
		return
	if on: SauvegardeConfigurationService.activer_vibrations()
	else: SauvegardeConfigurationService.desactiver_vibrations()
	AudioService.son_menu_click()
	VibrationService.vibration_click()
