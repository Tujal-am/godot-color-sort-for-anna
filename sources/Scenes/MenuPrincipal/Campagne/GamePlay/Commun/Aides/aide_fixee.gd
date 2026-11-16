extends CanvasLayer

signal fermee

@onready var _surface: Control = $Surface
@onready var _zone: Control = $Surface/Zone
@onready var _compris: Button = $Surface/Zone/Compris
@onready var _taille_reference: Vector2 = _zone.size


func _ready() -> void:
	_ajuster_zone()


func ouvrir() -> void:
	show()
	_compris.grab_focus()


func _ajuster_zone() -> void:
	if not is_node_ready():
		return
	var espace := _surface.size
	var ratio := minf(espace.x / _taille_reference.x, espace.y / _taille_reference.y)
	_zone.scale = Vector2.ONE * ratio
	_zone.position = (espace - _taille_reference * ratio) / 2.0


func _on_compris_pressed() -> void:
	fermee.emit()
