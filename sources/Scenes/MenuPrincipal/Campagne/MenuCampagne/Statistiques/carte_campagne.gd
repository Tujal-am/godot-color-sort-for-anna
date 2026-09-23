extends Control

func completion(nom : String) -> void:
	$Completion/Valeur.text = nom

func temps(nom : String) -> void:
	$Temps/Valeur.text = nom

func serie_max(nom : String) -> void:
	$SerieMax/Valeur.text = nom

func reussite(nom : String) -> void:
	$Reussite/Valeur.text = nom
