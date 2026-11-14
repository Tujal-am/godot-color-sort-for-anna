extends Control

## Instances des graphismes RC20, sans logique de plateau ni entrée utilisateur.
func configurer(valeurs: Array) -> void:
	assert(valeurs.size() == 15)
	for index in range(15):
		var jeton: Control = get_node("Cell%d/Jeton" % index)
		jeton.visible = valeurs[index] != null
		get_node("Cell%d" % index).self_modulate.a = 0.0 if jeton.visible else 1.0
		if jeton.visible:
			jeton.choisir_jeton("ABCD".find(str(valeurs[index])))

func presenter_grand_plateau(grand: bool) -> void:
	var colonnes := [0, 87, 169, 252, 339] if grand else [0, 39, 76, 116, 154]
	var lignes := [0, 60, 120] if grand else [0, 42, 82]
	var dimensions := Vector2(61, 57) if grand else Vector2(28, 28)
	for index in range(15):
		var cellule: Control = get_node("Cell%d" % index)
		cellule.position = Vector2(colonnes[index % 5], lignes[floori(index / 5.0)])
		cellule.size = dimensions
		cellule.material.set_shader_parameter("haut",Vector4(215.0/255.0,173.0/255.0,143.0/255.0,0.85))
		cellule.material.set_shader_parameter("bas",Vector4(215.0/255.0,173.0/255.0,143.0/255.0,0.85))
		cellule.material.set_shader_parameter("dimensions",dimensions)
		cellule.material.set_shader_parameter("rayon",6.0 if grand else 4.0)
		cellule.material.set_shader_parameter("pointilles",grand)
		cellule.scale = Vector2.ONE
		var jeton: Control = cellule.get_node("Jeton")
		jeton.position = Vector2.ZERO
		jeton.scale = Vector2.ONE
		jeton.configurer_dimensions(dimensions, 32 if grand else 16)
