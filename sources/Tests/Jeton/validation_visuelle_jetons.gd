extends Node

const THEME_DEMONSTRATION: StringName = Jeton.THEME_ORIGINEL_ROND_V1
const PILE_SCENE: PackedScene = preload("res://Scenes/Pile/pile.tscn")
const CATALOGUE_VISUEL = preload("res://Scenes/Jeton/catalogue_visuel_jetons.gd")
const COULEURS_DEMONSTRATION: Array[int] = [0, 1, 2]

var piles_de_demonstration: Array[Pile] = []
var succes := true

func _ready() -> void:
	$EtatCatalogue.text = "CATALOGUE VISUEL : " + (
			"PRÊT" if CATALOGUE_VISUEL.est_theme_pret(
					THEME_DEMONSTRATION, COULEURS_DEMONSTRATION)
			else "NON PRÊT — aucune texture validée")

	# Trois couleurs, trois variantes de rouge, soudures et sélection visibles.
	var pile_selectionnee := _creer_pile(
			[0, 0, 0, Plateau.ESPACE],
			[&"coeur", &"points", &"vagues", &""],
			Vector2(38, 270))
	_creer_pile(
			[1, 1, 2, Plateau.ESPACE],
			[&"cible", &"etoile", &"fleur", &""],
			Vector2(108, 270))
	_creer_pile(
			[2, 2, 2, Plateau.ESPACE],
			[&"rayons", &"spirale", &"etincelle", &""],
			Vector2(178, 270))
	pile_selectionnee.selectionner()

	# États visuels avant/après d'un déplacement simple, sans sauvegarde.
	_creer_pile(
			[1, 0, Plateau.ESPACE],
			[&"cible", &"coeur", &""],
			Vector2(285, 270))
	_creer_pile(
			[1, 0, 0],
			[&"cible", &"points", &"coeur"],
			Vector2(390, 270))

	# États visuels avant/après d'un bloc ; l'ordre relatif est conservé.
	_creer_pile(
			[2, 0, 0, Plateau.ESPACE],
			[&"rayons", &"points", &"coeur", &""],
			Vector2(118, 565))
	_creer_pile(
			[2, 0, 0],
			[&"rayons", &"points", &"coeur"],
			Vector2(328, 565))

	_verifier_scene_isolee()
	if DisplayServer.get_name() == "headless":
		print("VALIDATION_VISUELLE_JETONS: ", "PASS" if succes else "FAIL")
		get_tree().quit(0 if succes else 1)

func _creer_pile(couleurs: Array,
					variantes: Array[StringName],
					position_pile: Vector2) -> Pile:
	var pile: Pile = PILE_SCENE.instantiate()
	add_child(pile)
	pile.ajouter_les_jetons(couleurs)
	pile.choisir_position(position_pile)
	for indice in range(pile.liste_jetons.size()):
		var jeton = pile.liste_jetons[indice]
		jeton.choisir_theme_visuel_effectif(THEME_DEMONSTRATION)
		jeton.choisir_id_variante_visuelle(variantes[indice])
	piles_de_demonstration.append(pile)
	return pile

func _verifier_scene_isolee() -> void:
	_verifier(THEME_DEMONSTRATION == Jeton.THEME_ORIGINEL_ROND_V1,
			"La démonstration doit demander explicitement originel_rond_v1.")
	_verifier(not CATALOGUE_VISUEL.est_theme_pret(
			THEME_DEMONSTRATION, COULEURS_DEMONSTRATION),
			"Le catalogue sans texture doit être signalé comme non prêt.")
	_verifier(piles_de_demonstration.size() == 7,
			"Tous les cas de démonstration doivent être présents.")
	_verifier(piles_de_demonstration[0].liste_jetons[0].largeur() == 32 \
			and piles_de_demonstration[0].liste_jetons[0].hauteur() == 32,
			"Les jetons de démonstration doivent rester en 32 × 32.")
	_verifier(piles_de_demonstration[0].liste_jetons[0].id_variante_visuelle \
			!= piles_de_demonstration[0].liste_jetons[1].id_variante_visuelle,
			"Une même couleur doit présenter plusieurs variantes.")
	_verifier(piles_de_demonstration[0].liste_jetons[2].get_node("Selection").visible,
			"La sélection du bloc supérieur doit être visible.")
	_verifier(piles_de_demonstration[0].liste_jetons[1].get_node("SoudureHaute").visible,
			"Les soudures entre jetons identiques doivent être visibles.")

func _verifier(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		succes = false
