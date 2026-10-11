extends Control

func _on_retour_pressed() -> void:
	AudioService.son_menu_click()
	VibrationService.vibration_click()
	get_tree().change_scene_to_file("res://Scenes/MenuPrincipal/menu_principal.tscn")
