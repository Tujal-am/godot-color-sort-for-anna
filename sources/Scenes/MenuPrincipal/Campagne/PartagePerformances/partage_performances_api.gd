extends Node

class_name PartagePerformancesAPI

signal partage_qr_code(donnees_json: Dictionary)
signal erreur_decodage_qr(message: String)

const LOGIQUE := preload("res://Scenes/MenuPrincipal/Campagne/PartagePerformances/partage_performances_logic.gd")
const QR_SCRIPT_PATH := "res://addons/QRPlugin/QR.gd"
var _logique: PartagePerformancesLogic = LOGIQUE.new()
var _qr_scanner: Node

## Retourne le nom du joueur et les enregistrements de son dernier niveau.
func lire_donnees_dernier_niveau() -> Dictionary:
	return {
		"nom": SauvegardeBddJoueursService.lire_nom_joueur(),
		"niveau": SauvegardeBddJoueursService.enregistrement_lire_dernier_niveau()
	}

## Prépare les données JSON du niveau, leur signature HMAC et le contenu du QR.
func preparer_partage(enregistrements: Dictionary) -> Dictionary:
	var cle_hmac: String = ProjectSettings.get_setting("partage_performances/cle_hmac", "")
	return _logique.preparer_enveloppe(enregistrements, cle_hmac)

## Génère l'image du QR avec le plugin natif sur Android ou iOS.
func generer_image_qr(contenu: String) -> Dictionary:
	return _logique.generer_image_qr(contenu, self)

## Reçoit une image QR et lance son décodage asynchrone avec le plugin.
func recevoir_image_qr(image: Image) -> bool:
	if image == null or image.is_empty():
		erreur_decodage_qr.emit("L'image QR est vide ou invalide.")
		return false
	if not Engine.has_singleton("QRPlugin"):
		erreur_decodage_qr.emit("Le décodage QR n'est pas disponible sur cette plateforme.")
		return false
	if is_instance_valid(_qr_scanner):
		erreur_decodage_qr.emit("Un décodage QR est déjà en cours.")
		return false

	var qr_script := load(QR_SCRIPT_PATH) as Script
	if qr_script == null:
		erreur_decodage_qr.emit("Le script du plugin QR est introuvable.")
		return false

	_qr_scanner = qr_script.new() as Node
	if _qr_scanner == null:
		erreur_decodage_qr.emit("Impossible d'initialiser le décodeur QR.")
		return false
	if not _qr_scanner.has_signal("qr_detected") or not _qr_scanner.has_signal("qr_scan_failed"):
		_qr_scanner.free()
		_qr_scanner = null
		erreur_decodage_qr.emit("Le plugin QR n'expose pas les signaux de décodage attendus.")
		return false

	_qr_scanner.connect("qr_detected", _on_qr_detected)
	_qr_scanner.connect("qr_scan_failed", _on_qr_scan_failed)
	add_child(_qr_scanner)
	_qr_scanner.call("scan_qr_image", image)
	return true

## Retourne l'adresse courriel à afficher ou à copier.
func lire_adresse_courriel() -> String:
	return _logique.DESTINATAIRE_COURRIEL

## Partage l'image du QR avec le dialogue natif Android.
func partager_qr_android(share: Node, texture_qr: Texture2D) -> bool:
	if not OS.has_feature("android"):
		return false
	if not Engine.has_singleton("SharePlugin"):
		return false
	if texture_qr == null:
		return false

	var qr_data = lire_donnees_dernier_niveau()
	var nom_joueur = qr_data.get("nom", "")
	var nom_niveau = qr_data.get("niveau", "").get("niveau", "").replace("_", " ")
	share.call(
		"share_texture",
		texture_qr,
		nom_joueur + " partage ses performances", # titre
		"Performances du " + nom_niveau,          # sujet
		nom_joueur + " partage ses performances sur le " + nom_niveau + "." # texte du partage
	)
	return true

func _on_qr_detected(contenu_qr: String) -> void:
	_liberer_qr_scanner()
	var cle_hmac: String = ProjectSettings.get_setting("partage_performances/cle_hmac", "")
	var resultat: Dictionary = _logique.decoder_et_verifier_qr(contenu_qr, cle_hmac)
	if not resultat.get("succes", false):
		erreur_decodage_qr.emit(resultat.get("erreur", "Le QR ne peut pas être validé."))
		return
	partage_qr_code.emit(resultat.get("donnees"))

func _on_qr_scan_failed(erreur: Object) -> void:
	_liberer_qr_scanner()
	var description := "Le plugin QR n'a pas pu décoder l'image."
	if erreur.has_method("get_description"):
		description = erreur.call("get_description")
	erreur_decodage_qr.emit(description)

func _liberer_qr_scanner() -> void:
	if is_instance_valid(_qr_scanner):
		_qr_scanner.queue_free()
	_qr_scanner = null
