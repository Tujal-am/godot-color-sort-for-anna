extends BaseGameplay
class_name Classique

signal recommencer
const Hud = preload("res://Scenes/UI/Classique/classique_hud.gd")
const BACKGROUND := "res://Art/UI/IntegrationV4/Gameplay/classique/MASTER_backgroundgameplay_classique_480x720.png"
var hud: Control
var background: TextureRect
var _active := false
var _action_after := 0

func _ready() -> void:
	$Plateau.enregistrer_callback_est_termine(Callable(self, "est_termine"))
	background = TextureRect.new()
	background.texture = load(BACKGROUND)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	move_child(background, 0)
	hud = Hud.new()
	add_child(hud)
	hud.action_requested.connect(_on_action)
	get_viewport().size_changed.connect(_resize_background)
	_resize_background()
	hide()

func _resize_background() -> void:
	background.size = get_viewport().get_visible_rect().size

func _process(_delta: float) -> void:
	if _active:
		hud.set_elapsed(SauvegardeBddJoueursService.lire_duree_classique_ms())

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

func commencer_un_nouveau_plateau(plateau_texte: String) -> void:
	if not est_valide(plateau_texte):
		plateau_invalide.emit()
		return
	$Plateau.enregistrer_bouton_recommencer_size_y(160.0 * get_viewport().get_visible_rect().size.x / 1024.0)
	$Plateau/SelectionPile.stop()
	$Plateau.sauvegarde_indice_pile_depart = -1
	$Plateau.commencer_un_nouveau_plateau(plateau_texte)
	if $Plateau.liste_piles.is_empty():
		return
	for pile in $Plateau.liste_piles:
		pile.get_node("Fond").color = Color.TRANSPARENT
	SauvegardeBddJoueursService.activer_horloge_classique()
	_active = true
	_action_after = Time.get_ticks_msec() + 300
	show()

func show() -> void:
	background.show()
	hud.show()
	hud.set_active(true)
	hud.set_elapsed(SauvegardeBddJoueursService.lire_duree_classique_ms())

func hide() -> void:
	_active = false
	if is_instance_valid(hud):
		hud.hide()
		background.hide()
	$Plateau.hide()

func cacher_accueil() -> void:
	hide()

func _on_action(action: String) -> void:
	if not _active or Time.get_ticks_msec() < _action_after:
		hud.set_locked(false)
		return
	_active = false
	if action == "restart":
		recommencer.emit()
	elif action == "pass":
		passe.emit()

func est_termine(liste_piles) -> bool:
	if not _active:
		return false
	for pile in liste_piles:
		if not pile.est_vide() and not pile.est_termine():
			return false
	_active = false
	hud.set_locked(true)
	victoire.emit()
	hud.set_elapsed(SauvegardeBddJoueursService.lire_duree_classique_ms())
	return true
