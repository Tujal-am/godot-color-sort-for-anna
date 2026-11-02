extends Control

func nb_plateaux(valeur : String) -> void:
	$Nombre/Valeur.text = valeur

func nb_essais(valeur : String) -> void:
	$Essais/Valeur.text = valeur

func temps_moyen(valeur : String) -> void:
	$TempsMoyen/Valeur.text = valeur

func taux_reussite(valeur : String) -> void:
	$Reussite/Valeur.text = valeur

func plus_rapide_temps(valeur : String) -> void:
	$Tableau/PlusRapide/Temps.text = valeur

func plus_rapide_niveau(valeur : String) -> void:
	$Tableau/PlusRapide/Niveau.text = valeur

func plus_lent_temps(valeur : String) -> void:
	$Tableau/PlusLent/Temps.text = valeur

func plus_lent_niveau(valeur : String) -> void:
	$Tableau/PlusLent/Niveau.text = valeur

func plus_galere_essais(valeur : String) -> void:
	$Tableau/PlusGalere/Essais.text = valeur

func plus_galere_niveau(valeur : String) -> void:
	$Tableau/PlusGalere/Niveau.text = valeur
