extends Control

signal continuer
var _create_time_ms : int = 0
const SEUIL_CLICK_BOUTON_EN_MS : int = 500

func _on_draw() -> void:
	_create_time_ms = Time.get_ticks_msec()

func _on_bouton_pressed() -> void:
	var delta_ms = Time.get_ticks_msec() - _create_time_ms
	if delta_ms < SEUIL_CLICK_BOUTON_EN_MS:
		return
	continuer.emit()
