extends MenuPlateau

var classique_background_layer: CanvasLayer
var classique_hud_layer: CanvasLayer
var classique_hud: Control
var classique_input_capture: ColorRect

func _ready() -> void:
	classique_background_layer = $ClassiqueBackgroundLayer
	classique_hud_layer = $ClassiqueHudLayer
	classique_hud = $ClassiqueHudLayer/ClassiqueHud
	classique_input_capture = $ClassiqueInputCapture
	classique_hud.action_requested.connect(_on_classique_hud_action)
	classique_input_capture.gui_input.connect(_on_fond_gui_input)
	get_parent().victoire.connect(_on_classique_victoire)
	classique_background_layer.hide()
	classique_hud_layer.hide()
	classique_input_capture.hide()

## Appelé après l'initialisation LEGUIMS, une fois les données de Top lues.
## Cette suppression ne touche que l'instance d'affichage du gameplay Classique.
func retirer_interface_heritage() -> void:
	for node_name in ["Fond", "FondEntete", "Top"]:
		var node := get_node_or_null(node_name)
		if node:
			remove_child(node)

func _process(_delta: float) -> void:
	if classique_hud_layer.visible:
		classique_hud.set_elapsed(roundi(SauvegardeBddJoueursService.enregistrement_lire_duree_plateau() * 1000.0))

func show() -> void:
	var menu_campagne := get_parent().get_parent().get_node_or_null("MenuCampagne")
	if menu_campagne and menu_campagne.has_method("detacher_heritage_classique"):
		menu_campagne.detacher_heritage_classique()
	classique_input_capture.show()
	classique_background_layer.show()
	classique_hud_layer.show()
	classique_hud.set_active(true)
	classique_hud.set_actions_visible(SauvegardeBddJoueursService.enregistrement_plateau_en_cours())

func hide() -> void:
	classique_input_capture.hide()
	classique_background_layer.hide()
	classique_hud_layer.hide()
	classique_hud.set_active(false)

func cacher_accueil() -> void:
	hide()

func _on_classique_hud_action(action: String) -> void:
	match action:
		"restart":
			if SauvegardeBddJoueursService.enregistrement_plateau_en_cours():
				_on_bouton_recommencer_pressed()
		"pass":
			if SauvegardeBddJoueursService.enregistrement_plateau_en_cours():
				_on_bouton_passer_pressed()

func _on_classique_victoire() -> void:
	classique_input_capture.hide()
	classique_hud_layer.hide()
