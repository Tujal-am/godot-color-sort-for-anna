extends BaseGameplay

class_name QuiPerdGagne

@onready var qpg_hud: Control = $QpgHudLayer/QpgHud
var qpg_locked := false

func _ready() -> void:
	super._ready()
	# Le MenuPlateau et ses signaux LEGUIMS restent en place; seul leur ancien affichage est retiré.
	$MenuPlateau/Fond.color = Color(0, 0, 0, 0)
	$MenuPlateau/FondEntete.hide()
	$MenuPlateau/Top.hide()
	qpg_hud.action_requested.connect(_on_qpg_action)
	$MenuPlateau.passe.connect(func(): qpg_hud.set_actions_visible(false))
	$MenuPlateau.abandon.connect(func(): qpg_hud.set_actions_visible(false))
	qpg_hud.hide()
	$MenuPlateau.enregistrer_gameplay("Qui Perd Gagne", 22)

func show() -> void:
	super.show()
	$MenuPlateau/Fond.color = Color(0, 0, 0, 0)
	$MenuPlateau/FondEntete.hide()
	$MenuPlateau/Top.hide()
	qpg_hud.show()
	qpg_hud.set_actions_visible(SauvegardeBddJoueursService.enregistrement_plateau_en_cours())
	qpg_hud.unlock_actions()

func hide() -> void:
	qpg_hud.hide()
	super.hide()

func cacher_accueil() -> void:
	hide()

func _process(_delta: float) -> void:
	if qpg_hud.visible:
		qpg_hud.set_elapsed(roundi(SauvegardeBddJoueursService.enregistrement_lire_duree_plateau() * 1000.0))

func _on_qpg_action(action: String) -> void:
	if action == "restart":
		$MenuPlateau._on_bouton_recommencer_pressed()
	elif action == "pass":
		$MenuPlateau._on_bouton_passer_pressed()

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
		$MenuPlateau/Top/BoutonRecommencer.hide()
		$MenuPlateau/Top/BoutonPasser.hide()
		qpg_hud.set_actions_visible(false)
		victoire.emit()
	return termine
