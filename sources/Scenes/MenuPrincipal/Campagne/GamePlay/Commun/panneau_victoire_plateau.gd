extends Control

signal continuer

func _on_bouton_pressed() -> void:
	continuer.emit()

func score_points(texte : String) -> void:
	$ScorePoints.points(texte)

func temps(reference : String,
			recommence : String,
			realise : String,
			points : String) -> void:
	$Temps.item1("Référence : " + reference + "s")
	$Temps.item2("Recommencé : " + recommence + "s")
	$Temps.item3("Réalisé : " + realise + "s")
	# TODO : CREER la carte avec 4 items !
	# $Temps.item4(points + " points")

func ratio(ratio : String,
			points : String) -> void:
	$Ratio.item1("Réalisé : " + ratio + "s")
	$Temps.item2(points + " points")
