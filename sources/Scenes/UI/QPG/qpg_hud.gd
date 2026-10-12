extends Control

signal action_requested(action: String)

const FONT = preload("res://Art/UI/ClassiqueV18/font/DejaVuSans-Bold.ttf")
@export_enum("before", "active") var state := "before"
@onready var player_name: Label = $Hud/Before/PlayerName if state == "before" else null
@onready var level: Label = $Hud/Before/Level if state == "before" else null
@onready var percent: Label = $Hud/Before/Percent if state == "before" else null
@onready var medal: TextureRect = $Hud/Before/Medal if state == "before" else null
@onready var progress_fill: ColorRect = $Hud/Before/ProgressFill if state == "before" else null
@onready var elapsed: Label = $Hud/During/Elapsed if state == "active" else null
@onready var actions: Control = $Hud/During/Actions if state == "active" else null
@onready var buttons: Dictionary = _get_buttons()
var locked := false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	get_viewport().size_changed.connect(_resize)
	for key in buttons:
		var button: Button = buttons[key]
		button.tooltip_text = {"home":"Accueil", "stats":"Statistiques", "play":"Jouer", "restart":"Recommencer", "pass":"Passer au plateau suivant"}[key]
	_resize()
	set_state_active(state == "active")
	if state == "active":
		set_actions_visible(true)

func _get_buttons() -> Dictionary:
	if state == "before":
		return {"home":$Hud/Before/Home, "stats":$Hud/Before/Stats, "play":$Hud/Before/Play}
	return {"restart":$Hud/During/Actions/Restart, "pass":$Hud/During/Actions/Pass}

func _resize() -> void:
	var factor := get_viewport_rect().size.x / 1024.0
	scale = Vector2.ONE * factor
	position = Vector2.ZERO
	if OS.has_feature("mobile"):
		var safe := DisplayServer.get_display_safe_area()
		var screen := DisplayServer.screen_get_size()
		position.y = safe.position.y * get_viewport_rect().size.y / maxf(screen.y, 1.0)

func set_state_active(value: bool) -> void:
	if state == "before":
		$Hud/Before.visible = value
	else:
		$Hud/During.visible = value

func set_profile(nom: String, niveau: int, ratio: float, medal_key: String) -> void:
	if state != "before": return
	player_name.text = nom
	player_name.tooltip_text = nom
	level.text = str(niveau).pad_zeros(2)
	var normalized := clampf(ratio, 0.0, 1.0) if is_finite(ratio) else 0.0
	percent.text = "%d%%" % roundi(normalized * 100.0)
	progress_fill.material.set_shader_parameter("ratio", normalized)
	var trophy := medal_key.to_upper() if medal_key in ["bronze", "argent", "or", "diamant"] else "BRONZE"
	medal.texture = load("res://Art/UI/ClassiqueV18/medailles/MEDAILLE_%s_MASTER_1024.png" % trophy)

func set_elapsed(ms: int) -> void:
	if state != "active": return
	var seconds := maxi(ms, 0) / 1000
	if seconds >= 3600:
		elapsed.text = "%02d:%02d:%02d" % [seconds / 3600, (seconds / 60) % 60, seconds % 60]
	else:
		elapsed.text = "%02d:%02d.%02d" % [seconds / 60, seconds % 60, (maxi(ms, 0) / 10) % 100]

func set_actions_visible(value: bool) -> void:
	if state != "active": return
	actions.visible = value
	_sync_buttons()

func _request(key: String) -> void:
	if locked or not is_visible_in_tree(): return
	locked = true
	_sync_buttons()
	action_requested.emit(key)

func unlock_actions() -> void:
	locked = false
	_sync_buttons()

func _sync_buttons() -> void:
	for key in buttons:
		var button: Button = buttons[key]
		button.disabled = locked
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE if locked else Control.MOUSE_FILTER_STOP
