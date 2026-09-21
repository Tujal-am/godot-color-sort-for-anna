@tool
extends Node2D

# Paramètres modifiables depuis l'inspecteur
@export_range(0.0, 100.0) var percentage: float = 35.0:
	set(value):
		percentage = clamp(value, 0.0, 100.0)
		_update_display()

@onready var progress_arc: TextureRect = $ProgressArc
@onready var percent_text: Label = $PercentText

func _ready() -> void:
	_update_display()

func _update_display() -> void:
	if not is_node_ready():
		await ready

	# Mettre à jour le paramètre "progress" du Shader (valeur entre 0.0 et 1.0)
	if progress_arc.material is ShaderMaterial:
		progress_arc.material.set_shader_parameter("progress", percentage / 100.0)
	
	# Mettre à jour le texte central
	percent_text.text = str(roundi(percentage)) + "%"
