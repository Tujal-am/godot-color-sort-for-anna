extends Control

## Plateau miniature purement illustratif (aucune interaction avec les règles).
## Les 15 cellules et leurs sous-noeuds sont définis dans mini_plateau_classique.tscn.

const COULEURS := {
	"A": "RED",
	"B": "BLUE_VIOLET",
	"C": "FOREST_GREEN",
	"D": "AQUA"
}

func configurer(valeurs: Array) -> void:
	assert(valeurs.size() == 15)
	for index in range(15):
		var cellule: Control = get_node("Cell%d" % index)
		var carre: ColorRect = cellule.get_node("Couleur")
		var lettre: Label = cellule.get_node("Lettre")
		var nom := str(valeurs[index]) if valeurs[index] != null else ""
		carre.visible = nom != ""
		lettre.text = nom
		lettre.visible = nom != ""
		if nom != "":
			carre.color = Color(COULEURS.get(nom, "BLUE_VIOLET"))
