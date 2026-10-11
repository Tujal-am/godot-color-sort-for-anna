extends Node

signal share_received(received_data: Variant)
signal share_failed(message: String)

const SHARE_SCRIPT_PATH := "res://addons/SharePlugin/Share.gd"

var _share_node: Node

func _ready() -> void:
	if not OS.has_feature("android"):
		return
	if not Engine.has_singleton("SharePlugin"):
		LogService.log_erreur("Le plugin SHARE Android n'est pas disponible.")
		return

	var share_script := load(SHARE_SCRIPT_PATH) as Script
	if share_script == null:
		LogService.log_erreur("Le script du plugin SHARE est introuvable.")
		return

	_share_node = share_script.new() as Node
	if _share_node == null:
		LogService.log_erreur("Impossible d'initialiser le plugin SHARE.")
		return
	if not _share_node.has_signal("share_received") or not _share_node.has_signal("share_failed"):
		LogService.log_erreur("Le plugin SHARE n'expose pas les signaux attendus.")
		_share_node.free()
		_share_node = null
		return

	_share_node.connect("share_received", _on_share_received)
	_share_node.connect("share_failed", _on_share_failed)
	add_child(_share_node)
	_share_node.call("set_share_target", true)

func is_available() -> bool:
	return is_instance_valid(_share_node)

func share_texture(texture: Texture2D, title: String, subject: String, content: String) -> bool:
	if not is_available():
		return false
	_share_node.call("share_texture", texture, title, subject, content)
	return true

func _on_share_received(received_data: Variant) -> void:
	share_received.emit(received_data)

func _on_share_failed(message: String) -> void:
	share_failed.emit(message)
