extends BaseGameplay

class_name Classique

func _ready() -> void:
	super._ready()

	# Initialiser le menu
	$MenuPlateau.enregistrer_gameplay("Classique")
	$MenuPlateau.retirer_interface_heritage()

# Callback pour "Plateau"
func est_termine(liste_piles) -> bool:
	# Vérifier si la partie est achevée
	var termine = true
	for pile in liste_piles:
		# Vérifier que les piles qui ne sont pas vides sont terminées.
		if not pile.est_vide() and not pile.est_termine():
			termine = false
			break
	if termine:
		LogService.log_debug("Classique : victoire.emit()")
		victoire.emit()
	return termine
