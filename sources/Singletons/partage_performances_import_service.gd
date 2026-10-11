extends Node

signal partage_qr_code(qr_data: Dictionary)

const API_SCRIPT := preload("res://Scenes/MenuPrincipal/Campagne/PartagePerformances/partage_performances_api.gd")
const MENU_PRINCIPAL_PATH := "res://Scenes/MenuPrincipal/menu_principal.tscn"
const STATISTIQUES_PATH := "res://Scenes/MenuPrincipal/Campagne/MenuCampagne/Statistiques/statistiques.tscn"
const MESSAGE_ERREUR_IMPORT := "Erreur sur import QR, aucune action."

var _api: Node
var _image_qr: Image
var _chemins_images_recues := PackedStringArray()
var _decodage_en_cours := false
var _import_en_attente: Dictionary = {}
var _import_en_cours := false

func _ready() -> void:
	_api = API_SCRIPT.new()
	add_child(_api)
	_api.connect("partage_qr_code", _on_api_partage_qr_code)
	_api.connect("erreur_decodage_qr", _on_api_erreur_decodage_qr)

	if not ShareService.share_received.is_connected(_on_share_received):
		ShareService.share_received.connect(_on_share_received)

## Traite une image reçue par le share target Android.
func _on_share_received(received_data: Variant) -> void:
	if not received_data is Object or not received_data.has_method("get_file_paths"):
		_erreur_import()
		return

	var mime_type := str(received_data.call("get_mime_type"))
	var chemins: PackedStringArray = received_data.call("get_file_paths")
	if _decodage_en_cours or not _import_en_attente.is_empty() or _import_en_cours:
		_supprimer_fichiers_partages(chemins)
		LogService.log_erreur(MESSAGE_ERREUR_IMPORT)
		return
	_chemins_images_recues = chemins
	if chemins.is_empty() or (not mime_type.is_empty() and not mime_type.begins_with("image/")):
		_erreur_import()
		return

	_image_qr = Image.new()
	if _image_qr.load(chemins[0]) != OK or _image_qr.is_empty():
		_erreur_import()
		return

	_decodage_en_cours = true
	if not _api.call("recevoir_image_qr", _image_qr):
		return
	_image_qr = null

## Valide la demande affichée dans le menu et importe les statistiques.
func accepter_import() -> void:
	if _import_en_attente.is_empty() or _import_en_cours:
		return
	_import_en_cours = true

	var nom_joueur := str(_import_en_attente.get("nom", ""))
	var niveau: Dictionary = _import_en_attente.get("niveau", {})
	var nom_joueur_import := nom_joueur
	var import_reussi := false

	if not ProgressionCampagneService.importer_statistiques_nouveau_joueur_externe(nom_joueur_import, niveau) \
		and not ProgressionCampagneService.importer_statistiques_joueur_externe(nom_joueur_import, niveau):
		nom_joueur_import = nom_joueur + " (import)"
		if not ProgressionCampagneService.importer_statistiques_nouveau_joueur_externe(nom_joueur_import, niveau) \
			and not ProgressionCampagneService.importer_statistiques_joueur_externe(nom_joueur_import, niveau):
			_erreur_import()
			return

	_liberer_donnees_import()
	var erreur_changement := get_tree().change_scene_to_file(STATISTIQUES_PATH)
	if erreur_changement != OK:
		LogService.log_erreur("Erreur sur import QR, impossible d'afficher les statistiques.")

## Annule la demande sans modifier les sauvegardes.
func refuser_import() -> void:
	_liberer_donnees_import()

func _on_api_partage_qr_code(qr_data: Dictionary) -> void:
	_decodage_en_cours = false
	_liberer_image_recue()
	if not _qr_est_exploitable(qr_data):
		_erreur_import()
		return

	_import_en_attente = qr_data.duplicate(true)
	partage_qr_code.emit(_import_en_attente.duplicate(true))
	var erreur_changement := get_tree().change_scene_to_file(MENU_PRINCIPAL_PATH)
	if erreur_changement != OK:
		_erreur_import()
		return

	await get_tree().scene_changed
	var menu_principal := get_tree().current_scene
	if not is_instance_valid(menu_principal) or not menu_principal.has_method("afficher_import_qr"):
		_erreur_import()
		return
	menu_principal.call("afficher_import_qr", _import_en_attente.duplicate(true))

func _on_api_erreur_decodage_qr(_message: String) -> void:
	_erreur_import()

func _qr_est_exploitable(qr_data: Dictionary) -> bool:
	var nom: Variant = qr_data.get("nom", "")
	var niveau: Variant = qr_data.get("niveau", "")
	if not nom is String or nom.strip_edges().is_empty() or not niveau is Dictionary:
		return false
	var nom_niveau: Variant = niveau.get("niveau", "")
	var plateaux: Variant = niveau.get("plateaux", null)
	if not nom_niveau is String or nom_niveau.is_empty() or not plateaux is Array:
		return false
	for plateau in plateaux:
		if not plateau is Dictionary:
			return false
	return true

func _erreur_import() -> void:
	_decodage_en_cours = false
	_liberer_donnees_import()
	LogService.log_erreur(MESSAGE_ERREUR_IMPORT)
	var scene_courante := get_tree().current_scene
	if is_instance_valid(scene_courante) and scene_courante.has_method("fermer_import_qr"):
		scene_courante.call("fermer_import_qr")

func _liberer_donnees_import() -> void:
	_import_en_attente.clear()
	_import_en_cours = false
	_liberer_image_recue()

func _liberer_image_recue() -> void:
	_image_qr = null
	_supprimer_fichiers_partages(_chemins_images_recues)
	_chemins_images_recues = PackedStringArray()

func _supprimer_fichiers_partages(chemins: PackedStringArray) -> void:
	for chemin in chemins:
		if FileAccess.file_exists(chemin):
			var erreur_suppression := DirAccess.remove_absolute(chemin)
			if erreur_suppression != OK:
				LogService.log_erreur("Impossible de supprimer une image QR importée.")
