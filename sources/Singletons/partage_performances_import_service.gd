extends Node

signal partage_fichier_valide(donnees: Dictionary)

const API_SCRIPT := preload("res://Scenes/MenuPrincipal/Campagne/PartagePerformances/partage_performances_api.gd")
const MENU_PRINCIPAL_PATH := "res://Scenes/MenuPrincipal/menu_principal.tscn"
const STATISTIQUES_PATH := "res://Scenes/MenuPrincipal/Campagne/Statistiques/statistiques.tscn"
const MESSAGE_ERREUR_IMPORT := "Erreur sur import de fichier JSON, aucune action."
const TYPES_MIME_AUTORISES := ["application/json", "text/json", "text/plain", "application/octet-stream"]

var _api: Node
var _chemins_fichiers_recus := PackedStringArray()
var _import_en_attente: Dictionary = {}
var _import_en_cours := false

func _ready() -> void:
	_api = API_SCRIPT.new()
	add_child(_api)
	if not ShareService.share_received.is_connected(_on_share_received):
		ShareService.share_received.connect(_on_share_received)
	LogService.log_debug("Import JSON : écoute du signal SHARE activée.")

## Lit et valide un fichier de campagne reçu via SHARE.
func _on_share_received(received_data: Variant) -> void:
	LogService.log_debug("Import JSON : événement SHARE reçu.")
	if not received_data is Object or not received_data.has_method("get_file_paths") \
		or not received_data.has_method("get_mime_type"):
		LogService.log_debug("Import JSON : données SHARE absentes ou de type inattendu.")
		_erreur_import()
		return

	var mime_type := str(received_data.call("get_mime_type")).to_lower()
	var chemins: PackedStringArray = received_data.call("get_file_paths")
	LogService.log_debug("Import JSON : MIME reçu = ", mime_type, " ; nombre de fichiers = ", chemins.size(), ".")
	if not _import_en_attente.is_empty() or _import_en_cours:
		LogService.log_debug("Import JSON : réception ignorée, un import est déjà actif.")
		_supprimer_fichiers_recus(chemins)
		LogService.log_erreur(MESSAGE_ERREUR_IMPORT)
		return
	if chemins.is_empty():
		LogService.log_debug("Import JSON : aucun chemin de fichier transmis.")
		_erreur_import()
		return
	if not mime_type.is_empty() and not TYPES_MIME_AUTORISES.has(mime_type):
		LogService.log_debug("Import JSON : type MIME non pris en charge.")
		_chemins_fichiers_recus = chemins
		_erreur_import()
		return

	_chemins_fichiers_recus = chemins
	var chemin_fichier := chemins[0]
	if chemin_fichier.get_extension().to_lower() != "json":
		LogService.log_debug("Import JSON : le fichier reçu n'a pas l'extension .json.")
		_erreur_import()
		return
	var fichier := FileAccess.open(chemin_fichier, FileAccess.READ)
	if fichier == null:
		LogService.log_debug("Import JSON : ouverture impossible (", error_string(FileAccess.get_open_error()), ").")
		_erreur_import()
		return
	var contenu := fichier.get_as_text()
	fichier.close()
	if contenu.is_empty():
		LogService.log_debug("Import JSON : le fichier reçu est vide.")
		_erreur_import()
		return

	var resultat: Dictionary = _api.decoder_fichier_signe(contenu)
	if not resultat.get("succes", false):
		LogService.log_debug("Import JSON : fichier ou signature invalide : ", resultat.get("erreur", "erreur inconnue"))
		_erreur_import()
		return
	var donnees: Dictionary = resultat.get("donnees", {})
	if not _fichier_est_exploitable(donnees):
		_erreur_import()
		return

	LogService.log_debug("Import JSON : signature et structure valides. Ouverture de la confirmation.")
	_import_en_attente = donnees.duplicate(true)
	_liberer_fichiers_recus()
	partage_fichier_valide.emit(_import_en_attente.duplicate(true))
	var erreur_changement := get_tree().change_scene_to_file(MENU_PRINCIPAL_PATH)
	if erreur_changement != OK:
		LogService.log_debug("Import JSON : changement vers le menu impossible (", error_string(erreur_changement), ").")
		_erreur_import()
		return

	await get_tree().scene_changed
	var menu_principal := get_tree().current_scene
	if not is_instance_valid(menu_principal) or not menu_principal.has_method("afficher_import_fichier"):
		LogService.log_debug("Import JSON : le menu principal ne peut pas afficher le panneau de confirmation.")
		_erreur_import()
		return
	menu_principal.call("afficher_import_fichier", _import_en_attente.duplicate(true))

## Importe la campagne après confirmation et évite les collisions de noms.
func accepter_import() -> void:
	if _import_en_attente.is_empty() or _import_en_cours:
		return
	_import_en_cours = true

	var nom_joueur := str(_import_en_attente.get("joueur", ""))
	var campagne: Dictionary = _import_en_attente.get("campagne", {})
	var nom_joueur_import := nom_joueur
	if not ProgressionCampagneService.importer_campagne_nouveau_joueur_externe(nom_joueur_import, campagne) \
		and not ProgressionCampagneService.importer_campagne_joueur_externe(nom_joueur_import, campagne):
		nom_joueur_import = nom_joueur + " (import)"
		if not ProgressionCampagneService.importer_campagne_nouveau_joueur_externe(nom_joueur_import, campagne) \
			and not ProgressionCampagneService.importer_campagne_joueur_externe(nom_joueur_import, campagne):
			_erreur_import()
			return

	_liberer_import()
	var erreur_changement := get_tree().change_scene_to_file(STATISTIQUES_PATH)
	if erreur_changement != OK:
		LogService.log_erreur("Erreur sur import de fichier JSON, impossible d'afficher les statistiques.")

## Annule l'import sans modifier les sauvegardes.
func refuser_import() -> void:
	_liberer_import()

func _fichier_est_exploitable(donnees: Dictionary) -> bool:
	var joueur: Variant = donnees.get("joueur", "")
	if not joueur is String or joueur.strip_edges().is_empty():
		LogService.log_debug("Import JSON : champ joueur absent, vide ou de type incorrect.")
		return false

	var campagne: Variant = donnees.get("campagne", null)
	if not campagne is Dictionary:
		LogService.log_debug("Import JSON : campagne absente ou de type incorrect.")
		return false
	var nom_campagne: Variant = campagne.get("campagne", "")
	var niveaux: Variant = campagne.get("niveaux", null)
	if not nom_campagne is String or nom_campagne.strip_edges().is_empty() \
		or not niveaux is Array or niveaux.is_empty():
		LogService.log_debug("Import JSON : nom de campagne ou liste de niveaux invalide.")
		return false
	for index in range(niveaux.size()):
		var niveau: Variant = niveaux[index]
		if not niveau is Dictionary:
			LogService.log_debug("Import JSON : niveau ", index, " de type incorrect.")
			return false
		var nom_niveau: Variant = niveau.get("niveau", "")
		if not nom_niveau is String or nom_niveau.strip_edges().is_empty():
			LogService.log_debug("Import JSON : le niveau ", index, " n'a pas de nom valide.")
			return false
		var plateaux: Variant = niveau.get("plateaux", null)
		if not plateaux is Array:
			LogService.log_debug("Import JSON : liste de plateaux absente ou invalide au niveau ", index, ".")
			return false
		for plateau in plateaux:
			if not plateau is Dictionary:
				LogService.log_debug("Import JSON : plateau de type incorrect au niveau ", index, ".")
				return false
	return true

func _erreur_import() -> void:
	_liberer_import()
	LogService.log_erreur(MESSAGE_ERREUR_IMPORT)
	var scene_courante := get_tree().current_scene
	if is_instance_valid(scene_courante) and scene_courante.has_method("fermer_import_fichier"):
		scene_courante.call("fermer_import_fichier")

func _liberer_import() -> void:
	_import_en_attente.clear()
	_import_en_cours = false
	_liberer_fichiers_recus()

func _liberer_fichiers_recus() -> void:
	_supprimer_fichiers_recus(_chemins_fichiers_recus)
	_chemins_fichiers_recus = PackedStringArray()

func _supprimer_fichiers_recus(chemins: PackedStringArray) -> void:
	for chemin in chemins:
		if FileAccess.file_exists(chemin):
			var erreur_suppression := DirAccess.remove_absolute(chemin)
			if erreur_suppression != OK:
				LogService.log_erreur("Impossible de supprimer un fichier de campagne reçu.")
