extends Control

signal continuer

func _on_bouton_pressed() -> void:
	continuer.emit()
