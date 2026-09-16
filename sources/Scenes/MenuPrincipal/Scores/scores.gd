extends Control

const TOP_N := 5
const ASSET_DIR := "res://Art/UI/scores/"
const NAVY := Color("0a274d")
const CORAL := Color("f04d3c")
const PANEL := Color("fbefe0")
const CARD := Color("f8eadb")
const FIRST_CARD := Color("fdecd3")
const BORDER := Color("e8c9a8")
const SEPARATOR := Color("d9cec3")

func _ready() -> void:
	_build_ranking(SauvegardeTableauDesScoresService.retourner_classement())

func _build_ranking(classement: Array) -> void:
	var panel := Panel.new()
	panel.name = "ClassementDynamique"
	panel.position = Vector2(28, 323)
	panel.size = Vector2(424, 376)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", _style(PANEL, 22, BORDER, 1))
	add_child(panel)

	var first_card := Panel.new()
	first_card.position = Vector2(14, 14)
	first_card.size = Vector2(397, 86)
	first_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var first_style := _style(FIRST_CARD, 17, BORDER, 1)
	first_style.shadow_color = Color(0.45, 0.28, 0.12, 0.14)
	first_style.shadow_size = 5
	first_style.shadow_offset = Vector2(0, 3)
	first_card.add_theme_stylebox_override("panel", first_style)
	panel.add_child(first_card)

	var lower_card := Panel.new()
	lower_card.position = Vector2(14, 111)
	lower_card.size = Vector2(397, 252)
	lower_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lower_card.add_theme_stylebox_override("panel", _style(CARD, 17, BORDER, 1))
	panel.add_child(lower_card)

	for index in range(TOP_N):
		var item: Dictionary = classement[index] if index < classement.size() else {}
		var returned_rank := int(item.get("rang", index + 1))
		var visual_rank := clampi(returned_rank, 1, TOP_N)
		var row_parent: Control = first_card if index == 0 else lower_card
		var row_y := 0.0 if index == 0 else float((index - 1) * 63)
		_build_row(row_parent, index, row_y, visual_rank, item)

func _build_row(parent: Control, index: int, row_y: float, rank: int, item: Dictionary) -> void:
	var row := Control.new()
	row.name = "Rang%d" % (index + 1)
	row.position = Vector2(0, row_y)
	row.size = Vector2(397, 86 if index == 0 else 63)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(row)

	if index > 1:
		var separator := ColorRect.new()
		separator.position = Vector2(13, 0)
		separator.size = Vector2(371, 1)
		separator.color = SEPARATOR
		separator.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(separator)

	var medal := TextureRect.new()
	medal.name = "Medaille"
	var medal_filename := "medaille_rang_1_72x88_transparente.png" if rank == 1 else "medaille_rang_%d_58x58.png" % rank
	medal.texture = load(ASSET_DIR + medal_filename)
	medal.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	medal.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	medal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if index == 0:
		medal.position = Vector2(10, 0)
		medal.size = Vector2(72, 88)
	else:
		medal.position = Vector2(19, 2)
		medal.size = Vector2(58, 58)
	row.add_child(medal)

	var player_name := Label.new()
	player_name.name = "Nom"
	player_name.text = str(item.get("nom", "-"))
	player_name.position = Vector2(106, 0)
	player_name.size = Vector2(90 if index == 0 else 122, row.size.y)
	player_name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	player_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	player_name.add_theme_color_override("font_color", NAVY)
	player_name.add_theme_font_size_override("font_size", 24 if index == 0 else 22)
	row.add_child(player_name)

	var score := Label.new()
	score.name = "Score"
	score.text = "-" if item.is_empty() else _format_score_fr(int(item.get("score", 0)))
	score.position = Vector2(200 if index == 0 else 232, 0)
	score.size = Vector2(160 if index == 0 else 128, row.size.y)
	score.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	score.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	score.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	score.add_theme_color_override("font_color", CORAL if index == 0 else NAVY)
	score.add_theme_font_size_override("font_size", 27 if index == 0 else 22)
	row.add_child(score)

func _format_score_fr(value: int) -> String:
	var digits := str(value)
	var groups: Array[String] = []
	while digits.length() > 3:
		groups.push_front(digits.right(3))
		digits = digits.left(digits.length() - 3)
	groups.push_front(digits)
	return String.chr(0x00A0).join(groups)

func _style(color: Color, radius: int, border: Color, width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.border_color = border
	style.border_width_left = width
	style.border_width_top = width
	style.border_width_right = width
	style.border_width_bottom = width
	return style

func _return_to_home() -> void:
	AudioService.son_menu_click()
	VibrationService.vibration_click()
	get_tree().change_scene_to_file("res://Scenes/MenuPrincipal/menu_principal.tscn")

func _on_retour_pressed() -> void:
	_return_to_home()
