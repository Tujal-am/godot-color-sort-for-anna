extends Control

func en_cours(valeur : String) -> void:
	$EnCours/Valeur.text = valeur

func completion(valeur : String) -> void:
	$Completion/Valeur.text = valeur

func taux_reussite_minimum(valeur : String) -> void:
	$Tableau/ReussiteMinimum/Pourcent.text = valeur

func difficulte_reussite_minimum(valeur : String) -> void:
	$Tableau/ReussiteMinimum/Difficulte.text = valeur

func taux_reussite_maximum(valeur : String) -> void:
	$Tableau/ReussiteMaximum/Pourcent.text = valeur

func difficulte_reussite_maximum(valeur : String) -> void:
	$Tableau/ReussiteMaximum/Difficulte.text = valeur
