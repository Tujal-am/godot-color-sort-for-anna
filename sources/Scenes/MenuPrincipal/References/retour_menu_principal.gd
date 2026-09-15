extends Control

const ASSET_DIR := "res://Art/UI/IntegrationV3/a_propos/"
const NAVY := Color("0a274d")
const CORAL := Color("f04d3c")
const PANEL_COLOR := Color("fff8e8")
const CARD_COLOR := Color("fff8eb")
const BORDER_COLOR := Color("ead0ae")
const FONT_REGULAR: FontFile = preload("res://Art/UI/Fonts/TeXGyreAdventor/texgyreadventor-regular.otf")
const FONT_BOLD: FontFile = preload("res://Art/UI/Fonts/TeXGyreAdventor/texgyreadventor-bold.otf")

const GODOT_URL := "https://godotengine.org"
const MUSIC_URL := "https://patrickdearteaga.com"
const SOUND_URL := "https://pixabay.com"
const TUTORIAL_URL := "https://www.youtube.com/@BabaDesBois"

func _ready() -> void:
	_build_workshop_underlay()
	_build_content_panel()
	_build_back_hitbox()

func _build_workshop_underlay() -> void:
	var underlay := TextureRect.new()
	underlay.name = "DecorAtelierVerrouille"
	underlay.texture = load(ASSET_DIR + "a_propos_underlay_edge_fixed_480x720.png")
	underlay.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	underlay.stretch_mode = TextureRect.STRETCH_KEEP
	underlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	underlay.position = Vector2.ZERO
	underlay.size = Vector2(480, 720)
	add_child(underlay)

func _build_content_panel() -> void:
	var panel := Panel.new()
	panel.name = "PanneauCredits"
	panel.position = Vector2(62, 75)
	panel.size = Vector2(356, 625)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", _style(PANEL_COLOR, 23, BORDER_COLOR, 1))
	add_child(panel)

	_add_label(panel, Rect2(45, 8, 266, 55), "À propos", 41, NAVY, HORIZONTAL_ALIGNMENT_CENTER, true, 1.006)
	_add_header_ornament(panel)
	_add_label(panel, Rect2(74, 84, 236, 28), "Crédits et ressources", 18, CORAL, HORIZONTAL_ALIGNMENT_CENTER, false, 1.012)

	_add_card(panel, Rect2(23, 118, 310, 85), "Moteur", ASSET_DIR + "godot_icon_official.png", Vector2(16, 11), Vector2(64, 63),
		"Godot Engine", GODOT_URL, "godotengine.org", 13)
	_add_card(panel, Rect2(23, 213, 310, 150), "Musiques", ASSET_DIR + "icon_music.png", Vector2(20, 54), Vector2(48, 42),
		"• Dreaming – Su Turno\n• The Three Princesses of\n   Lilac Meadow\n• Solve The Puzzle\n• Humble Match\n• Great Little Challenge", MUSIC_URL, "patrickdearteaga.com", 13)
	_add_card(panel, Rect2(23, 373, 310, 150), "Effets sonores", ASSET_DIR + "icon_sound_about_validated.png", Vector2(12, 50), Vector2(62, 48),
		"• freesound.community\n• floraphonic\n• virtual_vibes\n• SoundReality\n• Dragon-Studio", SOUND_URL, "pixabay.com", 13)
	_add_card(panel, Rect2(23, 533, 310, 77), "Didacticiel", ASSET_DIR + "icon_youtube.png", Vector2(18, 18), Vector2(52, 40),
		"Baba Des Bois – @BabaDesBois", TUTORIAL_URL, "youtube.com", 13)

func _add_header_ornament(parent: Control) -> void:
	for x in [123.0, 198.0]:
		var line := ColorRect.new()
		line.position = Vector2(x, 77)
		line.size = Vector2(36, 2)
		line.color = CORAL
		line.mouse_filter = Control.MOUSE_FILTER_IGNORE
		parent.add_child(line)
	var diamond := Polygon2D.new()
	diamond.position = Vector2(178, 78)
	diamond.polygon = PackedVector2Array([Vector2(0,-8),Vector2(7,-4),Vector2(7,4),Vector2(0,8),Vector2(-7,4),Vector2(-7,-4)])
	diamond.color = CORAL
	parent.add_child(diamond)

func _add_card(parent: Control, rect: Rect2, title: String, icon_path: String, icon_position: Vector2, icon_size: Vector2, body: String, url: String, url_label: String, body_font_size: int) -> void:
	var card := Panel.new()
	card.name = title.replace(" ", "")
	card.position = rect.position
	card.size = rect.size
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_theme_stylebox_override("panel", _style(CARD_COLOR, 14, BORDER_COLOR, 1))
	parent.add_child(card)

	var icon := TextureRect.new()
	icon.name = "Pictogramme"
	icon.position = icon_position
	icon.size = icon_size
	icon.texture = load(icon_path)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(icon)

	var text_x := 90.0
	var title_x := text_x
	var title_y := 10.0 if title in ["Musiques", "Effets sonores"] else 9.0
	if title == "Didacticiel": title_y = 8.0
	_add_label(card, Rect2(title_x, title_y, 204, 25), title, 19, NAVY, HORIZONTAL_ALIGNMENT_LEFT, true)

	var body_top := 34.0
	if title == "Musiques": body_top = 33.0
	elif title == "Effets sonores": body_top = 35.0
	elif title == "Didacticiel": body_top = 32.0
	var body_x := text_x + 1.0 if title in ["Musiques", "Effets sonores"] else text_x
	var link_height := 19.0
	var link_top := rect.size.y - link_height - 8.0
	if title == "Moteur": link_top -= 4.0
	elif title == "Didacticiel": link_top += 1.0
	else: link_top += 4.0
	var body_label := _add_label(card, Rect2(body_x, body_top, 205, maxf(18, link_top - body_top)), body, body_font_size, NAVY, HORIZONTAL_ALIGNMENT_LEFT)
	body_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.add_theme_constant_override("line_spacing", 1)

	var link := RichTextLabel.new()
	link.name = "Lien"
	link.position = Vector2(text_x + 1.0 if title == "Didacticiel" else text_x, link_top)
	link.size = Vector2(205, link_height)
	link.bbcode_enabled = true
	link.fit_content = false
	link.scroll_active = false
	link.meta_underlined = false
	link.mouse_filter = Control.MOUSE_FILTER_STOP
	link.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	link.add_theme_color_override("default_color", CORAL)
	link.add_theme_color_override("font_color", CORAL)
	link.add_theme_font_override("normal_font", FONT_REGULAR)
	link.add_theme_font_size_override("normal_font_size", 13)
	link.text = "[url=%s][color=#f04d3c]%s[/color][/url]" % [url, url_label]
	link.meta_clicked.connect(_on_link_clicked)
	card.add_child(link)

func _add_label(parent: Control, rect: Rect2, text: String, font_size: int, color: Color, alignment: HorizontalAlignment, bold: bool = false, width_scale: float = 1.0) -> Label:
	var label := Label.new()
	label.position = rect.position
	label.size = rect.size
	label.text = text
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_font_override("font", _font_variant(FONT_BOLD if bold else FONT_REGULAR, width_scale))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func _font_variant(base_font: Font, width_scale: float) -> FontVariation:
	var variation := FontVariation.new()
	variation.base_font = base_font
	variation.variation_transform = Transform2D(Vector2(width_scale, 0), Vector2(0, 1), Vector2.ZERO)
	return variation

func _build_back_hitbox() -> void:
	var back := Button.new()
	back.name = "Retour"
	back.position = Vector2(18, 12)
	back.size = Vector2(72, 64)
	back.flat = true
	back.focus_mode = Control.FOCUS_NONE
	back.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var empty_style := StyleBoxEmpty.new()
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		back.add_theme_stylebox_override(state, empty_style)
	back.pressed.connect(_return_to_home)
	add_child(back)

func _on_link_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))

func _return_to_home() -> void:
	AudioService.son_menu_click()
	get_tree().change_scene_to_file("res://Scenes/MenuPrincipal/menu_principal.tscn")

func _style(color: Color, radius: int, border: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	return style
