extends Control

signal continuer
var _create_time_ms : int = 0
const SEUIL_CLICK_BOUTON_EN_MS : int = 500

func _on_draw() -> void:
	_create_time_ms = Time.get_ticks_msec()

func _on_bouton_pressed() -> void:
	var delta_ms = Time.get_ticks_msec() - _create_time_ms
	if delta_ms < SEUIL_CLICK_BOUTON_EN_MS:
		return
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
	$Temps.item4(points + " points")

func ratio(ratio : String,
			points : String) -> void:
	$Ratio.item1("Réalisé : " + ratio + "%")
	$Ratio.item2(points + " points")

func niveau(longueur : String,
			points : String) -> void:
	$Niveau.item1("Longueur: " + longueur)
	$Niveau.item2(points + " points")

func niveau_parfait(bonus : String,
			points : String) -> void:
	$NiveauParfait.item1("Bonus:  " + bonus)
	$NiveauParfait.item2(points + " points")
