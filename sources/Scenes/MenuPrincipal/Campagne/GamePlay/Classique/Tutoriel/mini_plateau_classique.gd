extends Control

## Instances des graphismes RC20, sans logique de plateau ni entrée utilisateur.
func configurer(valeurs: Array) -> void:
	assert(valeurs.size() == 15)
	for index in range(15):
		var jeton: Control = get_node("Cell%d/Jeton" % index)
		jeton.visible = valeurs[index] != null
		if jeton.visible:
			jeton.choisir_jeton("ABCD".find(str(valeurs[index])))

func presenter_grand_plateau(grand: bool) -> void:
	# Espacement des colonnes indépendant de l'échelle : les jetons restent carrés.
	for index in range(15):
		var cellule: Control = get_node("Cell%d" % index)
		cellule.position = Vector2(6 + (index % 5) * (87 if grand else 37), 8 + floori(index / 5.0) * (60 if grand else 37))
		cellule.scale = Vector2.ONE * (1.7 if grand else 1.0)
