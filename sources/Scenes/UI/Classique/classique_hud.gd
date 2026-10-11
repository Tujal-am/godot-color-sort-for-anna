extends Control

signal action_requested(action: String)
const FONT = preload("res://Art/UI/ClassiqueV18/font/DejaVuSans-Bold.ttf")
var active := false
var locked := false
var reduced_motion := false
@onready var before: Control = $Before
@onready var during: Control = $During
@onready var player_name: Label = $Before/PlayerName
@onready var level: Label = $Before/Level
@onready var percent: Label = $Before/Percent
@onready var medal: TextureRect = $Before/Medal
@onready var elapsed: Label = $During/Elapsed
@onready var active_legend: Label = $During/ActiveLegend
@onready var progress_fill: ColorRect = $Before/ProgressFill
@onready var buttons := {"home": $Before/Home, "stats": $Before/Stats, "play": $Before/Play, "restart": $During/Restart, "pass": $During/Pass}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	for key in buttons:
		var button: Button = buttons[key]
		button.tooltip_text = {"home":"Accueil", "stats":"Statistiques", "play":"Jouer", "restart":"Recommencer", "pass":"Passer au plateau suivant"}[key]
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		for state in ["normal", "hover", "pressed", "disabled"]:
			button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
		var focus := StyleBoxFlat.new()
		focus.bg_color = Color.TRANSPARENT
		focus.border_color = Color("063f78")
		focus.set_border_width_all(3)
		focus.set_corner_radius_all(29)
		button.add_theme_stylebox_override("focus", focus)
		button.pressed.connect(_request.bind(key))
		button.button_down.connect(_press_art.bind(button))
		button.button_up.connect(_release_art.bind(button))
	get_viewport().size_changed.connect(_resize)
	_resize()
	set_active(false)

func _press_art(button: Button) -> void:
	if not reduced_motion:
		button.get_node("Image").position.y += 1024.0 / 480.0

func _release_art(button: Button) -> void:
	var image: TextureRect = button.get_node("Image")
	var origin := Vector2(-2, -2)
	if reduced_motion:
		image.position = origin
	else:
		create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT).tween_property(image, "position", origin, 0.1)

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
	var safe := DisplayServer.get_display_safe_area() if OS.has_feature("mobile") else Rect2i()
	if OS.has_feature("mobile"):
		var screen := DisplayServer.screen_get_size()
		position.y = safe.position.y * viewport_size.y / maxf(screen.y, 1.0)
	var window_width := float(get_window().size.x)
	for key in buttons:
		var button: Button = buttons[key]
		var face := button.size
		var minimum := 44.0 * 1024.0 / maxf(window_width, 1.0)
		var hit_size := face.max(Vector2.ONE * minimum)
		var center := button.position + face * 0.5
		button.position = center - hit_size * 0.5
		button.size = hit_size
	if window_width <= 375.0:
		active_legend.add_theme_font_size_override("font_size", 36)
	elif window_width <= 410.0:
		active_legend.add_theme_font_size_override("font_size", 34)

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
		var is_active_action: bool = key in ["restart", "pass"]
		var enabled: bool = is_visible_in_tree() and not locked and active == is_active_action
		button.disabled = not enabled
		button.mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE
		button.focus_mode = Control.FOCUS_ALL if enabled else Control.FOCUS_NONE
		button.modulate.a = 0.5 if locked else 1.0

func set_actions_visible(value: bool) -> void:
	buttons["restart"].visible = value
	buttons["pass"].visible = value
	_sync_inputs()

func set_profile(nom: String, niveau: int, ratio: float, medal_key: String) -> void:
	player_name.text = nom
	player_name.tooltip_text = nom
	level.text = str(niveau).pad_zeros(2)
	level.add_theme_font_size_override("font_size", 36 if level.text.length() <= 2 else 28)
	if level.text.length() > 3:
		level.text = level.text.insert(level.text.length() - 2, "\n")
		level.add_theme_font_size_override("font_size", 22)
		level.add_theme_constant_override("line_spacing", -5)
	var normalized := clampf(ratio, 0.0, 1.0) if is_finite(ratio) else 0.0
	percent.text = "%d%%" % roundi(normalized * 100.0)
	progress_fill.material.set_shader_parameter("ratio", normalized)
	var effective_medal := medal_key if medal_key in ["bronze", "argent", "or", "diamant"] else "bronze"
	medal.texture = load("res://Art/UI/ClassiqueV18/medailles/MEDAILLE_" + effective_medal.to_upper() + "_MASTER_1024.png")
	medal.visible = true

static func format_elapsed(elapsed_ms: int) -> String:
	var seconds := maxi(elapsed_ms, 0) / 1000
	if seconds >= 3600:
		return "%02d:%02d:%02d" % [seconds / 3600, (seconds / 60) % 60, seconds % 60]
	return "%02d:%02d.%02d" % [seconds / 60, seconds % 60, (maxi(elapsed_ms, 0) / 10) % 100]

func set_elapsed(elapsed_ms: int) -> void:
	elapsed.text = format_elapsed(elapsed_ms)
	elapsed.add_theme_font_size_override("font_size", 38 if elapsed.text.length() <= 8 else 30)
