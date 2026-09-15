extends Control

const GradePresentationScript = preload("res://Scenes/MenuPrincipal/Grades/grade_presentation.gd")
const A := "res://Art/UI/IntegrationV3/"

static func avatar_path_for_player(player_name: String) -> String:
	if player_name == "Alain Konu": return A + "accueil/avatar_alain_32x32.png"
	if player_name == "Anna": return A + "accueil/avatar_anna_32x32.png"
	return ""
var expanded := false
var underlay: TextureRect
var player_area: VBoxContainer
var player_section: VBoxContainer
var player_scroll: ScrollContainer
var add_player_field: LineEdit
var add_player_row: Control
var players_bottom_space: Control
var lower_scroll: ScrollContainer
var lower_flow: VBoxContainer
var settings: PanelContainer
var campaign_button: TextureButton
var players_outline: Panel
var player_buttons: Dictionary = {}

func _ready() -> void:
	_build_ui()

func _build_ui() -> void:
	underlay = TextureRect.new()
	underlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	underlay.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	underlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(underlay)
	_add_texture(A + "accueil/logo_accueil_locked_325x145.png", Rect2(78,44,325,145))
	players_outline = Panel.new()
	players_outline.mouse_filter = Control.MOUSE_FILTER_IGNORE
	players_outline.add_theme_stylebox_override("panel", UIV3.box(Color.TRANSPARENT, 18, UIV3.CORAL, 2))
	UIV3.place(players_outline, Rect2(79,192,322,249))
	add_child(players_outline)
	campaign_button = _texture_button(A + "accueil/bouton_campagne_locked_305x85.png", Rect2(88,203,305,85))
	campaign_button.pressed.connect(_toggle_players)
	lower_scroll = ScrollContainer.new()
	lower_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	lower_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	UIV3.place(lower_scroll, Rect2(88,305,305,233))
	add_child(lower_scroll)
	lower_flow = VBoxContainer.new()
	lower_flow.custom_minimum_size.x = 305
	lower_flow.add_theme_constant_override("separation", 6)
	lower_scroll.add_child(lower_flow)
	player_section = VBoxContainer.new()
	player_section.custom_minimum_size.x = 305
	player_section.add_theme_constant_override("separation", 4)
	lower_flow.add_child(player_section)
	var player_heading := HBoxContainer.new()
	player_heading.custom_minimum_size = Vector2(305,21)
	player_heading.add_theme_constant_override("separation", 5)
	player_section.add_child(player_heading)
	player_heading.add_child(_create_players_icon())
	var player_title := Label.new()
	player_title.text = "JOUEURS"
	player_title.custom_minimum_size = Vector2(270,21)
	player_title.add_theme_color_override("font_color", UIV3.CREAM)
	player_title.add_theme_font_size_override("font_size", 15)
	player_heading.add_child(player_title)
	player_scroll = ScrollContainer.new()
	player_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	player_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	player_section.add_child(player_scroll)
	player_area = VBoxContainer.new()
	player_area.custom_minimum_size.x = 260
	player_area.add_theme_constant_override("separation", 4)
	var players_center := CenterContainer.new()
	players_center.custom_minimum_size.x = 305
	players_center.add_child(player_area)
	player_scroll.add_child(players_center)
	add_player_row = _create_add_player_row()
	player_section.add_child(add_player_row)
	players_bottom_space = Control.new()
	players_bottom_space.custom_minimum_size.y = 10
	lower_flow.add_child(players_bottom_space)
	var scores := _action_button("Scores", A + "accueil/picto_scores_36x36.png")
	scores.pressed.connect(_on_bouton_scores_pressed)
	var about := _action_button("À propos", A + "icons/icon_info.png")
	about.pressed.connect(_on_bouton_references_pressed)
	settings = PanelContainer.new()
	settings.custom_minimum_size = Vector2(260,123)
	settings.add_theme_stylebox_override("panel", UIV3.box(Color("061d31e6"), 10, Color("18384f"), 1))
	var settings_center := CenterContainer.new()
	settings_center.custom_minimum_size = Vector2(305,123)
	settings_center.add_child(settings)
	lower_flow.add_child(settings_center)
	var setting_rows := VBoxContainer.new()
	setting_rows.add_theme_constant_override("separation", 0)
	settings.add_child(setting_rows)
	var music := _add_setting(setting_rows, "Musique", A + "icons/icon_music.png", SauvegardeConfigurationService.musiques_sont_actives(), _on_bouton_musiques_toggled)
	var sound := _add_setting(setting_rows, "Effets sonores", A + "icons/icon_sound.png", SauvegardeConfigurationService.effets_sonores_sont_actifs(), _on_bouton_effets_sonores_toggled)
	var vibration := _add_setting(setting_rows, "Vibration", A + "icons/icon_vibration.png", SauvegardeConfigurationService.vibrations_sont_actives(), _on_bouton_vibrations_toggled)
	if OS.has_feature("web"): vibration.hide()
	_apply_state(false)

func _toggle_players() -> void:
	_apply_state(not expanded)
	AudioService.son_menu_click()

func _apply_state(value: bool) -> void:
	expanded = value
	underlay.texture = load(A + ("accueil/accueil_joueurs_underlay_sans_texte_480x720.png" if expanded else "accueil/accueil_simple_underlay_sans_texte_480x720.png"))
	player_section.visible = expanded
	players_bottom_space.visible = expanded
	players_outline.visible = expanded
	if expanded: _reload_players()
	campaign_button.position.y = 198 if expanded else 203
	lower_scroll.position.y = 282 if expanded else 305
	lower_scroll.size.y = 403 if expanded else 233
	lower_scroll.scroll_vertical = 0

func _reload_players() -> void:
	for child in player_area.get_children(): child.queue_free()
	player_buttons.clear()
	var names: Array = SauvegardeListeJoueursService.retourner_la_liste_des_joueurs()
	for nom in names:
		var button := Button.new()
		button.text = "           " + str(nom)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.custom_minimum_size = Vector2(260,37)
		button.add_theme_font_size_override("font_size", 17)
		button.pressed.connect(_on_joueurs_campagne_pressed.bind(str(nom)))
		player_area.add_child(button)
		_add_player_avatar(button, str(nom))
		player_buttons[str(nom)] = button
	_refresh_player_selection()
	player_scroll.custom_minimum_size.y = minf(maxf(names.size() * 41.0 - 4.0, 37.0), 152.0)

func _create_add_player_row() -> Control:
	var row := Control.new()
	row.custom_minimum_size = Vector2(260,37)
	row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var add := LineEdit.new()
	add.name = "nouveau_joueur"
	add.placeholder_text = "Ajouter"
	add.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add.add_theme_color_override("font_color", UIV3.NAVY)
	add.add_theme_color_override("font_placeholder_color", UIV3.NAVY)
	var normal := UIV3.box(UIV3.CREAM,12,UIV3.CREAM_BORDER,1)
	normal.content_margin_left = 44
	var focus := UIV3.box(Color.WHITE,12,UIV3.CORAL,2)
	focus.content_margin_left = 44
	add.add_theme_stylebox_override("normal", normal)
	add.add_theme_stylebox_override("focus", focus)
	add.text_submitted.connect(_on_nouveau_joueur_text_submitted)
	if OS.has_feature("web") and _is_ios(): add.focus_entered.connect(_nouveau_joueur_on_focus_entered)
	row.add_child(add)
	var plus := TextureRect.new()
	plus.texture = load(A + "accueil/avatar_add_32x32.png")
	plus.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	plus.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	plus.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UIV3.place(plus, Rect2(5,3,32,32))
	row.add_child(plus)
	add_player_field = add
	return row

func _create_players_icon() -> Control:
	var icon := Control.new()
	icon.custom_minimum_size = Vector2(24,21)
	for data in [Rect2(2,3,6,6), Rect2(12,3,6,6), Rect2(0,10,10,8), Rect2(10,10,10,8)]:
		var shape := Panel.new()
		shape.mouse_filter = Control.MOUSE_FILTER_IGNORE
		shape.add_theme_stylebox_override("panel", UIV3.box(Color("f9dfae"), int(data.size.y / 2.0)))
		UIV3.place(shape, data)
		icon.add_child(shape)
	return icon

func _add_player_avatar(button: Button, player_name: String) -> void:
	var avatar_path := GradePresentationScript.texture_path_for_player(player_name)
	if avatar_path.is_empty():
		var neutral := Panel.new()
		neutral.mouse_filter = Control.MOUSE_FILTER_IGNORE
		neutral.add_theme_stylebox_override("panel", UIV3.box(Color("e8d7bf"), 15, UIV3.CREAM_BORDER, 1))
		UIV3.place(neutral, Rect2(6,4,31,31))
		button.add_child(neutral)
		return
	var avatar := TextureRect.new()
	avatar.texture = load(avatar_path)
	avatar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	avatar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	avatar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UIV3.place(avatar, Rect2(5,3,32,32))
	button.add_child(avatar)

func _active_player_name() -> String:
	if SauvegardeBddJoueursService.le_joueur_existe():
		return SauvegardeBddJoueursService.lire_nom_joueur()
	return ""

func _refresh_player_selection() -> void:
	var active_name := _active_player_name()
	for player_name in player_buttons:
		var button: Button = player_buttons[player_name]
		var selected: bool = str(player_name) == active_name
		var background := UIV3.CORAL if selected else UIV3.CREAM
		var foreground := UIV3.CREAM if selected else UIV3.NAVY
		button.add_theme_color_override("font_color", foreground)
		button.add_theme_color_override("font_hover_color", foreground)
		button.add_theme_color_override("font_focus_color", foreground)
		button.add_theme_color_override("font_pressed_color", foreground)
		button.add_theme_stylebox_override("normal", UIV3.box(background, 12))
		button.add_theme_stylebox_override("hover", UIV3.box(background, 12))
		button.add_theme_stylebox_override("focus", UIV3.box(background, 12))
		button.add_theme_stylebox_override("pressed", UIV3.box(background, 12))

func _texture_button(path: String, rect: Rect2) -> TextureButton:
	var button := TextureButton.new()
	button.texture_normal = load(path)
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_SCALE
	UIV3.place(button, rect)
	add_child(button)
	return button

func _add_texture(path: String, rect: Rect2) -> void:
	var texture := TextureRect.new()
	texture.texture = load(path); texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE; texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UIV3.place(texture, rect); add_child(texture)

func _action_button(label: String, icon_path: String) -> Button:
	var wrapper := Control.new()
	wrapper.custom_minimum_size = Vector2(305,48)
	lower_flow.add_child(wrapper)
	var rect := Rect2(0,0,305,48)
	var surface := TextureRect.new()
	surface.texture = load(A + "accueil/bouton_action_vide_305x48.png")
	surface.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	surface.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UIV3.place(surface, rect); wrapper.add_child(surface)
	var icon := TextureRect.new(); icon.texture = load(icon_path); icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE; icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED; icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UIV3.place(icon, Rect2(Vector2(13,8), Vector2(32,32))); wrapper.add_child(icon)
	var text := Label.new(); text.text = label; text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER; text.add_theme_color_override("font_color", UIV3.NAVY); text.add_theme_font_size_override("font_size", 19); text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UIV3.place(text, Rect2(Vector2(63,0), Vector2(185,48))); wrapper.add_child(text)
	var chevron := TextureRect.new(); chevron.texture = load(A + "icons/icon_chevron.png"); chevron.expand_mode = TextureRect.EXPAND_IGNORE_SIZE; chevron.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED; chevron.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UIV3.place(chevron, Rect2(Vector2(268,13), Vector2(22,22))); wrapper.add_child(chevron)
	var button := Button.new(); button.name = "Scores" if label == "Scores" else "About"; button.flat = true
	button.add_theme_stylebox_override("normal", StyleBoxEmpty.new()); button.add_theme_stylebox_override("hover", StyleBoxEmpty.new()); button.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	button.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); wrapper.add_child(button); return button

func _add_setting(parent: VBoxContainer, label: String, icon_path: String, state: bool, callback: Callable) -> Button:
	var row := Control.new(); row.custom_minimum_size = Vector2(260,40); parent.add_child(row)
	var icon := TextureRect.new(); icon.texture=load(icon_path); icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE; icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED; icon.mouse_filter=Control.MOUSE_FILTER_IGNORE; UIV3.place(icon,Rect2(12,6,28,28)); row.add_child(icon)
	if label == "Effets sonores": icon.material = _sound_icon_material()
	var text := Label.new(); text.text=label; text.vertical_alignment=VERTICAL_ALIGNMENT_CENTER; text.add_theme_color_override("font_color",UIV3.CREAM); text.add_theme_font_size_override("font_size",15); text.mouse_filter=Control.MOUSE_FILTER_IGNORE; UIV3.place(text,Rect2(58,0,140,40)); row.add_child(text)
	var pill := Panel.new(); pill.name="Pill"; pill.mouse_filter=Control.MOUSE_FILTER_IGNORE; UIV3.place(pill,Rect2(201,9,44,22)); row.add_child(pill)
	var dot := Panel.new(); dot.name="Dot"; dot.mouse_filter=Control.MOUSE_FILTER_IGNORE; UIV3.place(dot,Rect2(222 if state else 203,11,18,18)); dot.add_theme_stylebox_override("panel",UIV3.box(UIV3.CREAM,9)); row.add_child(dot)
	var button := Button.new(); button.toggle_mode=true; button.button_pressed=state; button.flat=true; button.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); row.add_child(button)
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

func _on_bouton_references_pressed(): get_tree().change_scene_to_file("res://Scenes/MenuPrincipal/References/references.tscn"); AudioService.son_menu_click()
func _on_bouton_scores_pressed(): get_tree().change_scene_to_file("res://Scenes/MenuPrincipal/Scores/scores.tscn"); AudioService.son_menu_click()
func _on_joueurs_campagne_pressed(nom: String):
	if not SauvegardeListeJoueursService.le_joueur_existe(nom): return
	if ProgressionCampagneService.la_campagne_est_terminee_pour_joueur(nom):
		AudioService.son_menu_click()
		get_tree().change_scene_to_file("res://Scenes/MenuPrincipal/Campagne/MenuCampagne/Statistiques/statistiques.tscn")
	elif ProgressionCampagneService.choisir_le_joueur_pour_la_campagne(nom):
		_refresh_player_selection()
		AudioService.son_menu_click()
		get_tree().change_scene_to_file("res://Scenes/MenuPrincipal/Campagne/campagne.tscn")
func _on_nouveau_joueur_text_submitted(nom: String):
	_on_clavier_pseudo_annule()
	if ScoreService.nouveau_joueur_est_nom_anna_triche(nom): nom = ScoreService.lire_nom_anna_triche()
	if ProgressionCampagneService.initialiser_le_nouveau_joueur_pour_la_campagne(nom):
		_reload_players()
		_on_joueurs_campagne_pressed(nom)
func _on_bouton_musiques_toggled(on: bool):
	if on: SauvegardeConfigurationService.activer_musiques()
	else: SauvegardeConfigurationService.desactiver_musiques()
	AudioService.son_menu_click()
func _on_bouton_effets_sonores_toggled(on: bool):
	if on: SauvegardeConfigurationService.activer_effets_sonores()
	else: SauvegardeConfigurationService.desactiver_effets_sonores()
	AudioService.son_menu_click()
func _on_bouton_vibrations_toggled(on: bool):
	if on: SauvegardeConfigurationService.activer_vibrations()
	else: SauvegardeConfigurationService.desactiver_vibrations()
	AudioService.son_menu_click()
func _nouveau_joueur_on_focus_entered(): $Clavier.ouvrir()
func _is_ios():
	var ua = JavaScriptBridge.eval("navigator.userAgent"); return ua.find("iPhone") != -1 or ua.find("iPad") != -1 or ua.find("iPod") != -1
func _on_clavier_pseudo_valide(pseudo: String): $Clavier.fermer(); _on_nouveau_joueur_text_submitted(pseudo)
func _on_clavier_pseudo_annule(): $Clavier.fermer()
