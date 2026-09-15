class_name GradePresentation
extends RefCounted

# Official campaign-completion thresholds, centralized for every presentation surface.
const CONFIG := {
	"bronze": {"name": "Bronze", "threshold": 0, "texture": "res://Art/UI/IntegrationV3/grades/medaille_bronze_32.png", "texture_stats": "res://Art/UI/IntegrationV3/grades/medaille_bronze_48.png", "color": "#A65A2E"},
	"argent": {"name": "Argent", "threshold": 6, "texture": "res://Art/UI/IntegrationV3/grades/medaille_argent_32.png", "texture_stats": "res://Art/UI/IntegrationV3/grades/medaille_argent_48.png", "color": "#6F7782"},
	"or": {"name": "Or", "threshold": 11, "texture": "res://Art/UI/IntegrationV3/grades/medaille_or_32.png", "texture_stats": "res://Art/UI/IntegrationV3/grades/medaille_or_48.png", "color": "#B77B00"},
	"diamant": {"name": "Diamant", "threshold": 17, "texture": "res://Art/UI/IntegrationV3/grades/medaille_diamant_32.png", "texture_stats": "res://Art/UI/IntegrationV3/grades/medaille_diamant_48.png", "color": "#2A8792"}
}

static func for_save(save: Dictionary) -> Dictionary:
	var count := 0
	var registry = save.get("campagnes_terminees", [])
	if registry is Array:
		count = registry.size()
	return for_count(count)

static func for_count(count: int) -> Dictionary:
	var selected: Dictionary = CONFIG["bronze"]
	for key in ["argent", "or", "diamant"]:
		var threshold = CONFIG[key].get("threshold")
		if threshold != null and count >= int(threshold):
			selected = CONFIG[key]
	return selected

static func for_player(player_name: String) -> Dictionary:
	if player_name.is_empty() or not SauvegardeListeJoueursService.le_joueur_existe(player_name):
		return CONFIG["bronze"]
	var file_name := SauvegardeListeJoueursService.retourner_le_fichier_de_sauvegarde(player_name)
	var save = FichiersJsonService.read_json_file(file_name)
	return for_save(save if save is Dictionary else {})

static func texture_path_for_player(player_name: String) -> String:
	return str(for_player(player_name).get("texture", CONFIG["bronze"]["texture"]))

static func texture_path_for_stats_player(player_name: String) -> String:
	return str(for_player(player_name).get("texture_stats", for_player(player_name).get("texture", CONFIG["bronze"]["texture"])))

static func color_for_player(player_name: String) -> Color:
	return Color(str(for_player(player_name).get("color", "#A65A2E")))

static func name_for_player(player_name: String) -> String:
	return str(for_player(player_name).get("name", "Bronze"))
