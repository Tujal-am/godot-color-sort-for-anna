extends RefCounted
class_name CatalogueVisuelJetons

const THEME_ORIGINEL_ROND_V1: StringName = &"originel_rond_v1"
const THEME_ORIGINEL_CUBE_V1: StringName = &"originel_cube_v1"

# Catalogue de textures versionné. Il restera vide tant qu'aucun asset n'aura
# été validé graphiquement.
const TEXTURES: Dictionary = {
	THEME_ORIGINEL_ROND_V1: {},
	THEME_ORIGINEL_CUBE_V1: {
		0: {
			&"cible": preload("res://Art/Images/Jetons/Originel/Cube/v1/cube_pop_cible_32.png"),
			&"etoile": preload("res://Art/Images/Jetons/Originel/Cube/v1/cube_pop_etoile_32.png"),
			&"points": preload("res://Art/Images/Jetons/Originel/Cube/v1/cube_pop_points_32.png"),
		},
		1: {
			&"cible": preload("res://Art/Images/Jetons/Originel/Cube/v1/cube_signature_cible_32.png"),
			&"coeur": preload("res://Art/Images/Jetons/Originel/Cube/v1/cube_signature_coeur_32.png"),
			&"etincelle": preload("res://Art/Images/Jetons/Originel/Cube/v1/cube_signature_etincelle_32.png"),
		},
		2: {
			&"cible": preload("res://Art/Images/Jetons/Originel/Cube/v1/cube_doux_cible_32.png"),
			&"points": preload("res://Art/Images/Jetons/Originel/Cube/v1/cube_doux_points_32.png"),
			&"rayons": preload("res://Art/Images/Jetons/Originel/Cube/v1/cube_doux_rayons_32.png"),
		},
		3: {
			&"points": preload("res://Art/Images/Jetons/Originel/Cube/v1/cube_matiere_points_32.png"),
			&"spirale": preload("res://Art/Images/Jetons/Originel/Cube/v1/cube_matiere_spirale_32.png"),
			&"vagues": preload("res://Art/Images/Jetons/Originel/Cube/v1/cube_matiere_vagues_32.png"),
		},
		4: {
			&"coeur": preload("res://Art/Images/Jetons/Originel/Cube/v1/cube_framboise_coeur_32.png"),
			&"cible": preload("res://Art/Images/Jetons/Originel/Cube/v1/cube_framboise_cible_32.png"),
			&"points": preload("res://Art/Images/Jetons/Originel/Cube/v1/cube_framboise_points_32.png"),
		},
		5: {
			&"vagues": preload("res://Art/Images/Jetons/Originel/Cube/v1/cube_lagon_vagues_32.png"),
			&"spirale": preload("res://Art/Images/Jetons/Originel/Cube/v1/cube_lagon_spirale_32.png"),
			&"etincelle": preload("res://Art/Images/Jetons/Originel/Cube/v1/cube_lagon_etincelle_32.png"),
		},
	},
}

static func est_theme_pret(theme: StringName,
							couleurs_utilisees: Array[int],
							catalogue_variantes: Dictionary = {}) -> bool:
	var catalogue_theme: Dictionary = TEXTURES.get(theme, {})
	for indice_couleur in couleurs_utilisees:
		var variantes: Dictionary = catalogue_theme.get(indice_couleur, {})
		if variantes.is_empty():
			return false
		var ids_attendus: Array = catalogue_variantes.get(theme, {}).get(
				indice_couleur, variantes.keys())
		if ids_attendus.is_empty():
			return false
		for id_variante in ids_attendus:
			if not variantes.get(id_variante) is Texture2D:
				return false
	return not couleurs_utilisees.is_empty()

static func obtenir_texture(theme: StringName,
								indice_couleur: int,
								id_variante: StringName) -> Texture2D:
	return TEXTURES.get(theme, {}).get(indice_couleur, {}).get(id_variante)
