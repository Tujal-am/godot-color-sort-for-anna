# Types et conversions partagés liés au gameplay de la campagne.
class_name GameplayTypes

enum Gameplay {
	CLASSIQUE,
	AU_PLUS_PRES,
	PILE_POIL,
	TOUT_EN_TETE,
	PROGRAMMATION,
	PROGRAMMATION_GENIUS,
	QUI_PERD_GAGNE,
	POIDS_PLUME,
	PILE_OU_FACE,
	MOT_CACHE
}

static func gameplay_to_enum(gameplay : String) -> Gameplay:
	match gameplay:
		"CLASSIQUE":
			return Gameplay.CLASSIQUE
		"AU_PLUS_PRES":
			return Gameplay.AU_PLUS_PRES
		"PILE_POIL":
			return Gameplay.PILE_POIL
		"TOUT_EN_TETE":
			return Gameplay.TOUT_EN_TETE
		"PROGRAMMATION":
			return Gameplay.PROGRAMMATION
		"PROGRAMMATION_GENIUS":
			return Gameplay.PROGRAMMATION_GENIUS
		"QUI_PERD_GAGNE":
			return Gameplay.QUI_PERD_GAGNE
		"POIDS_PLUME":
			return Gameplay.POIDS_PLUME
		"PILE_OU_FACE":
			return Gameplay.PILE_OU_FACE
		"MOT_CACHE":
			return Gameplay.MOT_CACHE
		_:
			LogService.log_erreur("Gameplay inconnu : ", gameplay)
			return Gameplay.CLASSIQUE
