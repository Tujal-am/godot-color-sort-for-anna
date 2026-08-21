extends Node

const THEME_DEMONSTRATION: StringName = Jeton.THEME_ORIGINEL_CUBE_V1
const PILE_SCENE: PackedScene = preload("res://Scenes/Pile/pile.tscn")
const CATALOGUE_VISUEL = preload("res://Scenes/Jeton/catalogue_visuel_jetons.gd")
const COULEURS_DEMONSTRATION: Array[int] = [0, 1, 2, 3]
const COULEUR_FOND_PILE_DEMONSTRATION := Color(0.78, 0.74, 0.66, 1)
const CATALOGUE_VARIANTES_DEMONSTRATION: Dictionary = {
	THEME_DEMONSTRATION: {
		0: [&"cible", &"etoile", &"points"],
		1: [&"cible", &"coeur", &"etincelle"],
		2: [&"cible", &"points", &"rayons"],
		3: [&"points", &"spirale", &"vagues"],
	},
}

var piles_de_demonstration: Array[Pile] = []
var succes := true
var theme_effectif_demonstration: StringName = Jeton.THEME_CLASSIQUE

func _ready() -> void:
	theme_effectif_demonstration = _determiner_theme_effectif_demonstration()
	$EtatCatalogue.text = "CATALOGUE VISUEL : " + (
			"PRÊT" if theme_effectif_demonstration == THEME_DEMONSTRATION \
			else "NON PRÊT — fallback global classique")

	# Quatre couleurs, trois variantes par couleur, soudures et sélection visibles.
	var pile_selectionnee := _creer_pile(
			[0, 0, 0, Plateau.ESPACE],
			[&"cible", &"etoile", &"points", &""],
			Vector2(25, 270))
	_creer_pile(
			[1, 1, 2, Plateau.ESPACE],
			[&"cible", &"coeur", &"cible", &""],
			Vector2(80, 270))
	_creer_pile(
			[2, 2, 2, Plateau.ESPACE],
			[&"cible", &"points", &"rayons", &""],
			Vector2(135, 270))
	_creer_pile(
			[3, 3, 3, Plateau.ESPACE],
			[&"points", &"spirale", &"vagues", &""],
			Vector2(190, 270))
	pile_selectionnee.selectionner()

	# États visuels avant/après d'un déplacement simple, sans sauvegarde.
	_creer_pile(
			[1, 0, Plateau.ESPACE],
			[&"cible", &"cible", &""],
			Vector2(285, 270))
	_creer_pile(
			[1, 0, 0],
			[&"cible", &"etoile", &"cible"],
			Vector2(390, 270))

	# États visuels avant/après d'un bloc ; l'ordre relatif est conservé.
	_creer_pile(
			[2, 0, 0, Plateau.ESPACE],
			[&"rayons", &"etoile", &"cible", &""],
			Vector2(118, 565))
	_creer_pile(
			[2, 0, 0],
			[&"rayons", &"etoile", &"cible"],
			Vector2(328, 565))

	_verifier_scene_isolee()
	if DisplayServer.get_name() == "headless":
		print("VALIDATION_VISUELLE_JETONS: ", "PASS" if succes else "FAIL")
		get_tree().quit(0 if succes else 1)

func _determiner_theme_effectif_demonstration() -> StringName:
	var piles_couleurs := [COULEURS_DEMONSTRATION]
	var theme_effectif := Plateau.determiner_theme_visuel_effectif(
			THEME_DEMONSTRATION,
			piles_couleurs,
			CATALOGUE_VARIANTES_DEMONSTRATION)
	if theme_effectif != Jeton.THEME_CLASSIQUE \
			and not CATALOGUE_VISUEL.est_theme_pret(
					theme_effectif,
					COULEURS_DEMONSTRATION,
					CATALOGUE_VARIANTES_DEMONSTRATION):
		push_warning("Textures cube incomplètes : la démonstration entière reste classique.")
		return Jeton.THEME_CLASSIQUE
	return theme_effectif

func _creer_pile(couleurs: Array,
					variantes: Array[StringName],
					position_pile: Vector2) -> Pile:
	var pile: Pile = PILE_SCENE.instantiate()
	add_child(pile)
	pile.get_node("Fond").color = COULEUR_FOND_PILE_DEMONSTRATION
	pile.ajouter_les_jetons(couleurs)
	pile.choisir_position(position_pile)
	for indice in range(pile.liste_jetons.size()):
		var jeton = pile.liste_jetons[indice]
		jeton.choisir_theme_visuel_effectif(theme_effectif_demonstration)
		jeton.choisir_id_variante_visuelle(variantes[indice])
	piles_de_demonstration.append(pile)
	return pile

func _verifier_scene_isolee() -> void:
	_verifier(THEME_DEMONSTRATION == Jeton.THEME_ORIGINEL_CUBE_V1,
			"La démonstration doit demander explicitement originel_cube_v1.")
	_verifier(theme_effectif_demonstration == THEME_DEMONSTRATION,
			"Le thème cube doit être choisi globalement pour toute la démonstration.")
	_verifier(CATALOGUE_VISUEL.est_theme_pret(
			THEME_DEMONSTRATION,
			COULEURS_DEMONSTRATION,
			CATALOGUE_VARIANTES_DEMONSTRATION),
			"Le catalogue cube doit couvrir toutes les couleurs de démonstration.")
	_verifier(Plateau.determiner_theme_visuel_effectif(
			THEME_DEMONSTRATION,
			[COULEURS_DEMONSTRATION],
			{THEME_DEMONSTRATION: {0: [&"cible"]}}) == Jeton.THEME_CLASSIQUE,
			"Un catalogue incomplet doit conserver le fallback global classique.")
	var variante_deterministe_a := Plateau.determiner_id_variante_visuelle(
			THEME_DEMONSTRATION,
			"AAA.BBB.CCC.DDD",
			0, 0, 0,
			CATALOGUE_VARIANTES_DEMONSTRATION)
	var variante_deterministe_b := Plateau.determiner_id_variante_visuelle(
			THEME_DEMONSTRATION,
			"AAA.BBB.CCC.DDD",
			0, 0, 0,
			CATALOGUE_VARIANTES_DEMONSTRATION)
	_verifier(variante_deterministe_a == variante_deterministe_b,
			"Un même plateau cube doit produire les mêmes variantes.")
	_verifier(piles_de_demonstration.size() == 8,
			"Tous les cas de démonstration doivent être présents.")
	_verifier(piles_de_demonstration[0].liste_jetons[0].largeur() == 32 \
			and piles_de_demonstration[0].liste_jetons[0].hauteur() == 32,
			"Les jetons de démonstration doivent rester en 32 × 32.")
	_verifier(absf(piles_de_demonstration[0].liste_jetons[0].position().y \
			- piles_de_demonstration[0].liste_jetons[1].position().y) == 34,
			"Le pas vertical doit rester de 34 pixels.")
	_verifier(piles_de_demonstration[0].liste_jetons[0].id_variante_visuelle \
			!= piles_de_demonstration[0].liste_jetons[1].id_variante_visuelle,
			"Une même couleur doit présenter plusieurs variantes.")
	for pile in piles_de_demonstration:
		for jeton in pile.liste_jetons:
			if not jeton.est_vide():
				_verifier(jeton.theme_visuel == THEME_DEMONSTRATION \
						and jeton.get_node("Carre/Visuel").visible \
						and jeton.get_node("Carre/Visuel").texture \
								== CATALOGUE_VISUEL.obtenir_texture(
										THEME_DEMONSTRATION,
										jeton.indice_jeton,
										jeton.id_variante_visuelle) \
						and not jeton.get_node("Nom").visible,
						"Aucun jeton non vide ne doit rester en rendu classique.")
	_verifier([
		piles_de_demonstration[7].liste_jetons[1].id_variante_visuelle,
		piles_de_demonstration[7].liste_jetons[2].id_variante_visuelle,
	] == [&"etoile", &"cible"],
			"L'état après transfert groupé doit conserver l'ordre du bloc.")
	_verifier(piles_de_demonstration[0].liste_jetons[2].get_node("Selection").visible,
			"La sélection du bloc supérieur doit être visible.")
	_verifier(piles_de_demonstration[0].liste_jetons[1].get_node("SoudureHaute").visible,
			"Les soudures entre jetons identiques doivent être visibles.")

func _verifier(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		succes = false
