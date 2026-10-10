extends BaseGameplay

class_name QuiPerdGagne

var _active := false

func commencer_un_nouveau_plateau(plateau_texte: String) -> void:
	if not est_valide(plateau_texte):
		plateau_invalide.emit()
		return
	$Plateau.commencer_un_nouveau_plateau(plateau_texte)
	if $Plateau.liste_piles.is_empty():
		return
	# Le même chronomètre monotone est consommé par le HUD et par la sauvegarde du résultat.
	SauvegardeBddJoueursService.activer_horloge_classique()
	_active = true
	show()

func hide() -> void:
	_active = false
	super.hide()

func _notification(what: int) -> void:
	if not _active:
		return
	match what:
		NOTIFICATION_PAUSED:
			SauvegardeBddJoueursService.horloge_classique.pause("tree", true)
		NOTIFICATION_UNPAUSED:
			SauvegardeBddJoueursService.horloge_classique.pause("tree", false)
		NOTIFICATION_APPLICATION_PAUSED:
			SauvegardeBddJoueursService.horloge_classique.pause("application", true)
		NOTIFICATION_APPLICATION_RESUMED:
			SauvegardeBddJoueursService.horloge_classique.pause("application", false)

func _ready() -> void:
	super._ready()
	$MenuPlateau.passe.connect(_on_menu_plateau_passe)

	# Initialiser le menu
	$MenuPlateau.enregistrer_gameplay("Qui perd gagne")

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
		_active = false
		if $MenuPlateau.qpg_hud:
			$MenuPlateau.qpg_hud.set_locked(true)
		$MenuPlateau/Top/BoutonRecommencer.hide()
		victoire.emit()
	return termine
