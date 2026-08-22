extends RefCounted

signal animation_terminee

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

var composants_animes: Array[Control] = []
var positions_finales: Array[Vector2] = []
var z_index_finaux: Array[int] = []

func capturer_transfert(pile_depart: Pile, pile_arrivee: Pile) -> Dictionary:
	var nombre_jetons := pile_depart.combien_de_jetons_identiques_au_sommet()
	var cases_vides_depart := pile_depart.combien_de_cases_vides_au_sommet()
	var premier_indice_depart := (
			pile_depart.liste_jetons.size() - cases_vides_depart - nombre_jetons)
	var cases_vides_arrivee := pile_arrivee.combien_de_cases_vides_au_sommet()
	var premier_indice_arrivee := (
			pile_arrivee.liste_jetons.size() - cases_vides_arrivee)
	return {
		"nombre_jetons": nombre_jetons,
		"premier_indice_depart": premier_indice_depart,
		"premier_indice_arrivee": premier_indice_arrivee,
		"position_bloc_source": pile_depart.liste_jetons[premier_indice_depart].position(),
	}

func jetons_arrives(pile_arrivee: Pile, capture: Dictionary) -> Array:
	var jetons: Array = []
	for indice in range(capture.nombre_jetons):
		jetons.append(pile_arrivee.liste_jetons[
				capture.premier_indice_arrivee + indice])
	return jetons

func animer(proprietaire: Node, pile_arrivee: Pile, capture: Dictionary) -> Tween:
	var jetons := jetons_arrives(pile_arrivee, capture)
	if jetons.is_empty():
		return null
	var position_bloc_finale: Vector2 = jetons[0].position()
	var offset_initial: Vector2 = capture.position_bloc_source - position_bloc_finale
	_preparer_composants(jetons, offset_initial)

	var appliquer_offset := func(offset: Vector2) -> void:
		for indice in range(composants_animes.size()):
			if is_instance_valid(composants_animes[indice]):
				composants_animes[indice].position = positions_finales[indice] + offset

	var offset_haut := offset_initial + Vector2(0, -HAUTEUR_MONTEE)
	var offset_destination_haut := Vector2(0, -HAUTEUR_MONTEE)
	var tween := proprietaire.create_tween()
	tween.tween_method(appliquer_offset, offset_initial, offset_haut, DUREE_MONTEE) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_method(appliquer_offset, offset_haut, offset_destination_haut,
			DUREE_TRANSLATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(appliquer_offset, offset_destination_haut, Vector2.ZERO,
			DUREE_DESCENTE).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.finished.connect(_terminer_animation, CONNECT_ONE_SHOT)
	return tween

func positions_finales_sont_exactes() -> bool:
	for indice in range(composants_animes.size()):
		if is_instance_valid(composants_animes[indice]) \
				and composants_animes[indice].position != positions_finales[indice]:
			return false
	return true

func _preparer_composants(jetons: Array, offset_initial: Vector2) -> void:
	composants_animes.clear()
	positions_finales.clear()
	z_index_finaux.clear()
	for jeton in jetons:
		for chemin_composant in COMPOSANTS_JETON:
			var composant: Control = jeton.get_node(chemin_composant)
			composants_animes.append(composant)
			positions_finales.append(composant.position)
			z_index_finaux.append(composant.z_index)
			composant.z_index = 10
			composant.position += offset_initial

func _restaurer_positions_finales() -> void:
	for indice in range(composants_animes.size()):
		if is_instance_valid(composants_animes[indice]):
			composants_animes[indice].position = positions_finales[indice]
			composants_animes[indice].z_index = z_index_finaux[indice]

func _terminer_animation() -> void:
	_restaurer_positions_finales()
	animation_terminee.emit()
