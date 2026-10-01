extends Control
## Présentation commune AVANT/ACTIF. Aucune écriture dans le modèle de jeu.

signal action_requested(action: String)

const ASSETS := "res://Art/UI/ClassiqueV18/"
const FONT = preload("res://Art/UI/ClassiqueV18/font/DejaVuSans-Bold.ttf")
const PROGRESS_SHADER = preload("res://Scenes/UI/Classique/progression.gdshader")
var layout: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(ASSETS + "layout.json"))
var active := false
var locked := false
var reduced_motion := false
var before := Control.new()
var during := Control.new()
var buttons: Dictionary = {}
var player_name: Label
var level: Label
var percent: Label
var elapsed: Label
var medal: TextureRect
var progress_material := ShaderMaterial.new()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	size = Vector2(1024, 280)
	for group in [before, during]:
		group.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(group)
	_texture(before, ASSETS + "svg/base_before.svg", Rect2(0, 0, 1024, 280))
	_texture(during, ASSETS + "svg/base_active.svg", Rect2(0, 0, 1024, 280))
	medal = _texture(before, "", _rect(layout.dynamic.medal.rect))
	player_name = _label(before, _rect(layout.dynamic.player_name.rect), 28)
	player_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	player_name.max_lines_visible = 2
	player_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	player_name.add_theme_constant_override("line_spacing", -9)
	level = _label(before, Rect2(354, 180, 56, 48), 36)
	percent = _label(before, Rect2(548, 180, 82, 48), 34)
	percent.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	elapsed = _label(during, _rect(layout.dynamic.elapsed.rect), 38)
	elapsed.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var fill := ColorRect.new()
	fill.position = _rect(layout.dynamic.progress.rect).position
	fill.size = _rect(layout.dynamic.progress.rect).size
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	progress_material.shader = PROGRESS_SHADER
	fill.material = progress_material
	before.add_child(fill)
	for key in layout.asset_placements:
		_build_button(key)
	visibility_changed.connect(_sync_inputs)
	get_viewport().size_changed.connect(_resize)
	_resize()
	set_active(false)

func _rect(values: Array) -> Rect2:
	return Rect2(values[0], values[1], values[2], values[3])

func _texture(parent: Control, path: String, rect: Rect2) -> TextureRect:
	var texture := TextureRect.new()
	texture.position = rect.position
	texture.size = rect.size
	texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not path.is_empty():
		texture.texture = load(path)
	parent.add_child(texture)
	return texture

func _label(parent: Control, rect: Rect2, font_size: int) -> Label:
	var label := Label.new()
	label.position = rect.position
	label.size = rect.size
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", FONT)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color("063f78"))
	parent.add_child(label)
	return label

func _build_button(key: String) -> void:
	var data: Dictionary = layout.asset_placements[key]
	var button := Button.new()
	button.name = key
	button.tooltip_text = {"home": "Accueil", "stats": "Statistiques", "play": "Jouer", "restart": "Recommencer", "pass": "Passer (échec)"}[key]
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	for state in ["normal", "hover", "pressed", "disabled"]:
		button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	var focus := StyleBoxFlat.new()
	focus.bg_color = Color.TRANSPARENT
	focus.border_color = Color("063f78")
	focus.set_border_width_all(3)
	focus.set_corner_radius_all(29)
	focus.set_expand_margin_all(5)
	button.add_theme_stylebox_override("focus", focus)
	var group: Control = during if key in ["restart", "pass"] else before
	group.add_child(button)
	var picture := _texture(button, ASSETS + "svg/" + data.file + ".svg", _rect(data.texture_rect))
	buttons[key] = button
	button.button_down.connect(func():
		if not reduced_motion:
			picture.position.y += 1024.0 / 480.0)
	button.button_up.connect(func():
		var origin := _rect(data.texture_rect).position - button.position
		if reduced_motion:
			picture.position = origin
		else:
			create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT).tween_property(picture, "position", origin, 0.1))
	button.pressed.connect(_request.bind(key))

func _request(key: String) -> void:
	if locked or not is_visible_in_tree() or buttons[key].disabled:
		return
	set_locked(true)
	action_requested.emit(key)

func _resize() -> void:
	var viewport_size := get_viewport_rect().size
	var factor := viewport_size.x / 1024.0
	scale = Vector2.ONE * factor
	position = Vector2.ZERO
	var physical_width := float(get_window().size.x)
	if OS.has_feature("mobile"):
		var safe := DisplayServer.get_display_safe_area()
		var screen := DisplayServer.screen_get_size()
		position.y = safe.position.y * viewport_size.y / maxf(screen.y, 1.0)
		physical_width = screen.x
	for key in buttons:
		var button: Button = buttons[key]
		var data: Dictionary = layout.asset_placements[key]
		var face := _rect(data.face_rect)
		var minimum := 44.0 * 1024.0 / maxf(physical_width, 1.0)
		var hit_size := face.size.max(Vector2.ONE * minimum)
		button.position = face.get_center() - hit_size * 0.5
		button.size = hit_size
		button.get_child(0).position = _rect(data.texture_rect).position - button.position

## Les contrôles invisibles ne participent ni au focus ni aux transactions.
func set_active(value: bool) -> void:
	active = value
	before.visible = not active
	during.visible = active
	set_locked(false)

func set_locked(value: bool) -> void:
	locked = value
	_sync_inputs()

func _sync_inputs() -> void:
	for key in buttons:
		var button: Button = buttons[key]
		var is_active_action: bool = key == "restart" or key == "pass"
		var enabled: bool = is_visible_in_tree() and not locked and (active == is_active_action)
		button.disabled = not enabled
		button.mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE
		button.focus_mode = Control.FOCUS_ALL if enabled else Control.FOCUS_NONE
		button.modulate.a = 0.5 if locked else 1.0

## Le contrôleur fournit les valeurs réelles ; aucune identité de démonstration.
func set_profile(nom: String, niveau: int, ratio: float, medal_key: String) -> void:
	player_name.text = nom
	player_name.tooltip_text = nom
	level.text = str(niveau).pad_zeros(2)
	level.add_theme_font_size_override("font_size", 36 if level.text.length() <= 2 else 28)
	# La campagne actuelle reste sous 1000 ; quatre chiffres restent lisibles sur deux lignes.
	if level.text.length() > 3:
		level.text = level.text.insert(level.text.length() - 2, "\n")
		level.add_theme_font_size_override("font_size", 22)
		level.add_theme_constant_override("line_spacing", -5)
	var normalized := clampf(ratio, 0.0, 1.0) if is_finite(ratio) else 0.0
	percent.text = "%d%%" % roundi(normalized * 100.0)
	progress_material.set_shader_parameter("ratio", normalized)
	medal.texture = load(ASSETS + "medailles/MEDAILLE_" + medal_key.to_upper() + "_MASTER_1024.png") if medal_key in ["bronze", "argent", "or", "diamant"] else null
	medal.visible = medal.texture != null

static func format_elapsed(elapsed_ms: int) -> String:
	var seconds := maxi(elapsed_ms, 0) / 1000
	if seconds >= 3600:
		return "%02d:%02d:%02d" % [seconds / 3600, (seconds / 60) % 60, seconds % 60]
	return "%02d:%02d.%02d" % [seconds / 60, seconds % 60, (maxi(elapsed_ms, 0) / 10) % 100]

func set_elapsed(elapsed_ms: int) -> void:
	elapsed.text = format_elapsed(elapsed_ms)
	elapsed.add_theme_font_size_override("font_size", 38 if elapsed.text.length() <= 8 else 30)
