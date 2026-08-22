extends Node

const THEME_DEMONSTRATION: StringName = Jeton.THEME_ORIGINEL_CUBE_V1
const PILE_SCENE: PackedScene = preload("res://Scenes/Pile/pile.tscn")
const CATALOGUE_VISUEL = preload("res://Scenes/Jeton/catalogue_visuel_jetons.gd")
const COULEURS_DEMONSTRATION: Array[int] = [0, 1, 2, 3, 4, 5]
const COULEUR_FOND_PILE_DEMONSTRATION := Color(0.78, 0.74, 0.66, 1)
const HAUTEUR_MONTEE := 12.0
const DUREE_MONTEE := 0.12
const DUREE_TRANSLATION := 0.20
const DUREE_DESCENTE := 0.12
const COMPOSANTS_JETON := [
	"Selection",
	"SoudureHaute",
	"Carre",
	"SoudureBasse",
	"Nom",
]
const CATALOGUE_VARIANTES_DEMONSTRATION: Dictionary = Jeton.CATALOGUE_VARIANTES

var piles_de_demonstration: Array[Pile] = []
var succes := true
var theme_effectif_demonstration: StringName = Jeton.THEME_CLASSIQUE
var animation_transfert_en_cours := false
var pile_animation_depart: Pile
var pile_animation_arrivee: Pile
var tween_animation: Tween
var composants_animes: Array[Control] = []
var positions_finales_composants: Array[Vector2] = []
var z_index_finaux: Array[int] = []
var variantes_attendues_sommet_vers_bas: Array[StringName] = []
var resultats_animation := {}
var nombre_transferts_metier := 0

func _ready() -> void:
	theme_effectif_demonstration = _determiner_theme_effectif_demonstration()
	$EtatCatalogue.text = "CATALOGUE VISUEL : " + (
			"PRÊT" if theme_effectif_demonstration == THEME_DEMONSTRATION \
			else "NON PRÊT — fallback global classique")

	# Six couleurs, trois variantes par couleur, soudures et sélection visibles.
	var pile_selectionnee := _creer_pile(
			[0, 0, 0, Plateau.ESPACE],
			[&"cible", &"etoile", &"points", &""],
			Vector2(25, 270))
	_creer_pile(
			[1, 1, 1, Plateau.ESPACE],
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
	_creer_pile(
			[4, 4, 4, Plateau.ESPACE],
			[&"coeur", &"cible", &"points", &""],
			Vector2(245, 270))
	_creer_pile(
			[5, 5, 5, Plateau.ESPACE],
			[&"vagues", &"spirale", &"etincelle", &""],
			Vector2(300, 270))
	pile_selectionnee.selectionner()

	_preparer_cas_animation(1)

	_verifier_scene_isolee()
	if DisplayServer.get_name() == "headless":
		await _tester_animations_headless()
		print("VALIDATION_VISUELLE_JETONS: ", "PASS" if succes else "FAIL")
		get_tree().quit(0 if succes else 1)

func _on_animer_un_jeton_pressed() -> void:
	_lancer_cas_animation(1)

func _on_animer_deux_jetons_pressed() -> void:
	_lancer_cas_animation(2)

func _on_animer_trois_jetons_pressed() -> void:
	_lancer_cas_animation(3)

func _lancer_cas_animation(nombre_jetons: int) -> bool:
	if animation_transfert_en_cours:
		return false
	_preparer_cas_animation(nombre_jetons)
	return _animer_transfert_demo()

func _preparer_cas_animation(nombre_jetons: int) -> void:
	if pile_animation_depart != null:
		piles_de_demonstration.erase(pile_animation_depart)
		pile_animation_depart.free()
	if pile_animation_arrivee != null:
		piles_de_demonstration.erase(pile_animation_arrivee)
		pile_animation_arrivee.free()

	var couleurs_depart := [Plateau.ESPACE, Plateau.ESPACE, Plateau.ESPACE, Plateau.ESPACE]
	var variantes_depart: Array[StringName] = [&"", &"", &"", &""]
	var variantes_bloc: Array[StringName] = [&"cible", &"etoile", &"points"]
	for indice in range(nombre_jetons):
		couleurs_depart[indice] = 0
		variantes_depart[indice] = variantes_bloc[indice]

	pile_animation_depart = _creer_pile(
			couleurs_depart, variantes_depart, Vector2(118, 600))
	pile_animation_arrivee = _creer_pile(
			[0, Plateau.ESPACE, Plateau.ESPACE, Plateau.ESPACE],
			[&"points", &"", &"", &""],
			Vector2(328, 600))
	pile_animation_depart.selectionner()

func _animer_transfert_demo() -> bool:
	if animation_transfert_en_cours:
		return false
	var regles := PlateauReglesDuJeuService.new()
	var piles := [pile_animation_depart, pile_animation_arrivee]
	if not regles.est_valide_le_tansfert_de_pile(piles, 0, 1):
		return false

	animation_transfert_en_cours = true
	_definir_controles_animation_desactives(true)
	var nombre_jetons := pile_animation_depart.combien_de_jetons_identiques_au_sommet()
	var cases_vides_depart := pile_animation_depart.combien_de_cases_vides_au_sommet()
	var premier_indice_bloc_depart := (
			pile_animation_depart.liste_jetons.size()
			- cases_vides_depart
			- nombre_jetons)
	var cases_vides_arrivee := pile_animation_arrivee.combien_de_cases_vides_au_sommet()
	var premier_indice_bloc_arrivee := (
			pile_animation_arrivee.liste_jetons.size() - cases_vides_arrivee)
	var position_bloc_source: Vector2 = pile_animation_depart.liste_jetons[
			premier_indice_bloc_depart].position()
	variantes_attendues_sommet_vers_bas.clear()
	for indice in range(nombre_jetons - 1, -1, -1):
		variantes_attendues_sommet_vers_bas.append(
				pile_animation_depart.liste_jetons[
						premier_indice_bloc_depart + indice].id_variante_visuelle)

	for jeton in pile_animation_depart.liste_jetons:
		jeton.deselectionner()
	pile_animation_depart.get_node("Fond").color = COULEUR_FOND_PILE_DEMONSTRATION

	if not regles.realiser_le_tansfert_de_pile(piles, 0, 1, false):
		_finaliser_animation(false, nombre_jetons)
		return false
	nombre_transferts_metier += 1

	var jetons_animes: Array = []
	for indice in range(nombre_jetons):
		jetons_animes.append(pile_animation_arrivee.liste_jetons[
				premier_indice_bloc_arrivee + indice])
	var position_bloc_finale: Vector2 = jetons_animes[0].position()
	var offset_initial := position_bloc_source - position_bloc_finale
	_preparer_composants_animes(jetons_animes, offset_initial)

	var appliquer_offset := func(offset: Vector2) -> void:
		for indice in range(composants_animes.size()):
			composants_animes[indice].position = positions_finales_composants[indice] + offset

	var offset_haut := offset_initial + Vector2(0, -HAUTEUR_MONTEE)
	var offset_destination_haut := Vector2(0, -HAUTEUR_MONTEE)
	tween_animation = create_tween()
	tween_animation.tween_method(
			appliquer_offset, offset_initial, offset_haut, DUREE_MONTEE) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween_animation.tween_method(
			appliquer_offset, offset_haut, offset_destination_haut, DUREE_TRANSLATION) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween_animation.tween_method(
			appliquer_offset, offset_destination_haut, Vector2.ZERO, DUREE_DESCENTE) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween_animation.finished.connect(
			func() -> void: _finaliser_animation(true, nombre_jetons),
			CONNECT_ONE_SHOT)
	return true

func _preparer_composants_animes(jetons_animes: Array,
								offset_initial: Vector2) -> void:
	composants_animes.clear()
	positions_finales_composants.clear()
	z_index_finaux.clear()
	for jeton in jetons_animes:
		jeton.selectionner()
		for chemin_composant in COMPOSANTS_JETON:
			var composant: Control = jeton.get_node(chemin_composant)
			composants_animes.append(composant)
			positions_finales_composants.append(composant.position)
			z_index_finaux.append(composant.z_index)
			composant.z_index = 10
			composant.position += offset_initial

func _finaliser_animation(transfert_reussi: bool, nombre_jetons: int) -> void:
	for indice in range(composants_animes.size()):
		composants_animes[indice].position = positions_finales_composants[indice]
		composants_animes[indice].z_index = z_index_finaux[indice]
	for jeton in pile_animation_arrivee.liste_jetons:
		jeton.deselectionner()
	pile_animation_arrivee.get_node("Fond").color = COULEUR_FOND_PILE_DEMONSTRATION
	resultats_animation[nombre_jetons] = transfert_reussi \
			and _ordre_animation_est_conserve(nombre_jetons) \
			and _positions_finales_sont_exactes() \
			and _pile_est_monochrome(pile_animation_depart) \
			and _pile_est_monochrome(pile_animation_arrivee)
	animation_transfert_en_cours = false
	_definir_controles_animation_desactives(false)

func _ordre_animation_est_conserve(nombre_jetons: int) -> bool:
	var variantes_finales_sommet_vers_bas: Array[StringName] = []
	var nombre_cases_occupees := (
			pile_animation_arrivee.liste_jetons.size()
			- pile_animation_arrivee.combien_de_cases_vides_au_sommet())
	for indice in range(
			nombre_cases_occupees - 1,
			nombre_cases_occupees - nombre_jetons - 1,
			-1):
		variantes_finales_sommet_vers_bas.append(
				pile_animation_arrivee.liste_jetons[indice].id_variante_visuelle)
	return variantes_finales_sommet_vers_bas == variantes_attendues_sommet_vers_bas

func _positions_finales_sont_exactes() -> bool:
	for indice in range(composants_animes.size()):
		if composants_animes[indice].position != positions_finales_composants[indice]:
			return false
	return true

func _pile_est_monochrome(pile: Pile) -> bool:
	var couleur: int = Plateau.ESPACE
	for jeton in pile.liste_jetons:
		if jeton.est_vide():
			continue
		if couleur == Plateau.ESPACE:
			couleur = jeton.indice_jeton
		elif jeton.indice_jeton != couleur:
			return false
	return true

func _definir_controles_animation_desactives(desactives: bool) -> void:
	$AnimerUnJeton.disabled = desactives
	$AnimerDeuxJetons.disabled = desactives
	$AnimerTroisJetons.disabled = desactives

func _tester_animations_headless() -> void:
	var transferts_avant := nombre_transferts_metier
	for nombre_jetons in [1, 2, 3]:
		var lancement_reussi := _lancer_cas_animation(nombre_jetons)
		var double_demande_bloquee := not _lancer_cas_animation(nombre_jetons)
		_verifier(lancement_reussi,
				"Le transfert de %d jeton(s) doit démarrer." % nombre_jetons)
		_verifier(double_demande_bloquee,
				"Une seconde demande doit être bloquée pendant l'animation.")
		if tween_animation != null and tween_animation.is_running():
			await tween_animation.finished
		_verifier(resultats_animation.get(nombre_jetons, false),
				"Le transfert animé de %d jeton(s) doit finir exactement." % nombre_jetons)
	_verifier(nombre_transferts_metier == transferts_avant + 3,
			"Chaque animation doit appliquer exactement un transfert métier.")

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
		_verifier(_pile_est_monochrome(pile),
				"Chaque pile de démonstration doit rester monochrome.")
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
	_verifier(piles_de_demonstration[0].liste_jetons[2].get_node("Selection").visible,
			"La sélection du bloc supérieur doit être visible.")
	_verifier(piles_de_demonstration[0].liste_jetons[1].get_node("SoudureHaute").visible,
			"Les soudures entre jetons identiques doivent être visibles.")

func _verifier(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		succes = false
