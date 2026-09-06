extends BaseGameplay

class_name QuiPerdGagne

func _ready() -> void:
	super._ready()

	# Initialiser le menu
	$MenuPlateau.enregistrer_gameplay("Qui Perd\nGagne")

# Callback pour "Plateau"
func est_termine(liste_piles) -> bool:
	# Condition de victoire : plateau bloqué + 1 pile non terminée
	# Vérifier si la partie est achevée

	# Impossible de joueur
	var plateau_bloque = false
	plateau_bloque = $Plateau.est_bloque()
	
	# Une pile non terminée
	var une_pile_en_desordre = false
	for pile in liste_piles:
		# Vérifier qu'une piles qui n'est pas vides n'est pas terminée.
		if not pile.est_vide() and not pile.est_termine():
			une_pile_en_desordre = true
			break

	var termine = plateau_bloque and une_pile_en_desordre
	if termine:
		LogService.log_debug("QuiPerdGagne : victoire.emit()")
		$MenuPlateau/Top/BoutonAbandonner.hide()
		$MenuPlateau.arreter_chronometre()
		victoire.emit()
	return termine
