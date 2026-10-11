extends Control

func _on_lien_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))
