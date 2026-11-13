extends Control

## Plateau miniature purement illustratif (aucune interaction avec les règles).
## Les 15 cellules et leurs sous-noeuds sont définis dans mini_plateau_classique.tscn.

const COULEURS := {
	"A": Color("#df4c40"),
	"B": Color("#7433cb"),
	"C": Color("#36a947"),
	"D": Color("#36a9d2")
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
			carre.color = COULEURS.get(nom, Color("#7854b5"))
