extends RefCounted
class_name CatalogueVisuelJetons

# Catalogue de textures versionné. Il restera vide tant qu'aucun asset n'aura
# été validé graphiquement.
const TEXTURES: Dictionary = {
	Jeton.THEME_ORIGINEL_ROND_V1: {},
}

static func est_theme_pret(theme: StringName, couleurs_utilisees: Array[int]) -> bool:
	var catalogue_theme: Dictionary = TEXTURES.get(theme, {})
	for indice_couleur in couleurs_utilisees:
		var variantes: Dictionary = catalogue_theme.get(indice_couleur, {})
		if variantes.is_empty():
			return false
		for texture in variantes.values():
			if not texture is Texture2D:
				return false
	return not couleurs_utilisees.is_empty()

static func obtenir_texture(theme: StringName,
								indice_couleur: int,
								id_variante: StringName) -> Texture2D:
	return TEXTURES.get(theme, {}).get(indice_couleur, {}).get(id_variante)
