extends Node

## Adaptateur de présentation uniquement : aucune progression, signal métier ou scène.
var _menu: CanvasLayer
var _backdrop: TextureRect

func _ready() -> void:
	_menu = get_parent() as CanvasLayer
	_backdrop = $GameplayBackdropSnapshot
	hide_all()

func capture_backdrop() -> void:
	var image: Image = get_viewport().get_texture().get_image()
	if image.is_empty():
		return
	_backdrop.texture = ImageTexture.create_from_image(image)
	_backdrop.show()

func show_intermediate() -> void:
	_hide_overlays()
	_sync_values()
	_menu.get_node("OverlayIntermediate").show()
	_menu.get_node("OverlayIntermediate/OverlayIntermediateContinueHitbox").show()

func show_final() -> void:
	_hide_overlays()
	_sync_values()
	_menu.get_node("OverlayFinal").show()
	_menu.get_node("OverlayFinal/OverlayFinalReturnHitbox").show()

func show_lost() -> void:
	_hide_overlays()
	_menu.get_node("OverlayLost").show()
	_menu.get_node("OverlayLost/OverlayLostContinueHitbox").show()

func hide_all() -> void:
	_hide_overlays()
	_backdrop.hide()

func _hide_overlays() -> void:
	_menu.get_node("OverlayIntermediate").hide()
	_menu.get_node("OverlayFinal").hide()
	_menu.get_node("OverlayLost").hide()

func _sync_values() -> void:
	var score: String = _menu.get_node("ResultsPanel/ResultsContent/ScoreCard/ScoreLabel").text
	var temps: PackedStringArray = _menu.get_node("ResultsPanel/ResultsContent/TempsCard/TempsLabel").text.split("\n")
	var ratio: PackedStringArray = _menu.get_node("ResultsPanel/ResultsContent/RatioCard/RatioLabel").text.split("\n")
	var niveau: PackedStringArray = _menu.get_node("ResultsPanel/ResultsContent/NiveauCard/NiveauLabel").text.split("\n")
	var detour: PackedStringArray = _menu.get_node("ResultsPanel/ResultsContent/DetourCard/DetourLabel").text.split("\n")
	var bonus: String = _menu.get_node("ResultsPanel/ResultsContent/BonusCard/BonusLabel").text
	var ratio_percent: String = _menu.get_node("ResultsPanel/ResultsContent/RatioCard/RatioPercent").text
	_set_text("OverlayIntermediate/OverlayIntermediateScore", score)
	_set_text("OverlayIntermediate/OverlayIntermediateTimeReference", _line_value(temps, 0))
	_set_text("OverlayIntermediate/OverlayIntermediateTimeRealized", _line_value(temps, 1))
	_set_text("OverlayIntermediate/OverlayIntermediateRatioPercent", ratio_percent)
	_set_text("OverlayIntermediate/OverlayIntermediateRatioRealized", _line_value(ratio, 0))
	_set_text("OverlayIntermediate/OverlayIntermediateRatioPoints", _line_value(ratio, 1))
	_set_text("OverlayFinal/OverlayFinalScore", score)
	_set_text("OverlayFinal/OverlayFinalTimeReference", _line_value(temps, 0))
	_set_text("OverlayFinal/OverlayFinalTimeRealized", _line_value(temps, 1))
	_set_text("OverlayFinal/OverlayFinalRatioPercent", ratio_percent)
	_set_text("OverlayFinal/OverlayFinalRatioRealized", _line_value(ratio, 0))
	_set_text("OverlayFinal/OverlayFinalRatioPoints", _line_value(ratio, 1))
	_set_text("OverlayFinal/OverlayFinalNiveauValue", _line_value(niveau, 0))
	_set_text("OverlayFinal/OverlayFinalNiveauPoints", _line_value(niveau, 1))
	_set_text("OverlayFinal/OverlayFinalDetourValue", _line_value(detour, 0))
	_set_text("OverlayFinal/OverlayFinalDetourPoints", _line_value(detour, 1))
	_set_text("OverlayFinal/OverlayFinalBonusValue", "")
	_set_text("OverlayFinal/OverlayFinalBonusPoints", bonus.replace("• ", "").trim_suffix(" points"))

func _line_value(lines: PackedStringArray, index: int) -> String:
	if index >= lines.size():
		return ""
	var value: String = lines[index].strip_edges()
	var separator := value.find(":")
	if separator >= 0:
		value = value.substr(separator + 1).strip_edges()
	return value.trim_prefix("• ").strip_edges()

func _set_text(path: String, value: String) -> void:
	var label := _menu.get_node(path) as Label
	label.text = value
	_fit_label_font(label)

func _fit_label_font(label: Label) -> void:
	if not label.has_meta("results_nominal_font_size"):
		label.set_meta("results_nominal_font_size", label.get_theme_font_size("font_size"))
	var nominal: int = label.get_meta("results_nominal_font_size")
	var minimum := 18 if label.name == "OverlayFinalScore" else 12
	var available := label.size.x - 8.0
	if available <= 0.0 or value_is_empty(label.text):
		return
	var font := label.get_theme_font("font")
	var size := nominal
	while size > minimum and font.get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x > available:
		size -= 1
	label.add_theme_font_size_override("font_size", size)

func value_is_empty(value: String) -> bool:
	return value.strip_edges().is_empty()
