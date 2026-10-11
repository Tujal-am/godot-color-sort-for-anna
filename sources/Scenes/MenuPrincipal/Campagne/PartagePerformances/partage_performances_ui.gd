extends Control

class_name PartagePerformancesUI

signal partage_qr_code(donnees_json: Dictionary)
signal fermer

func _ready() -> void:
	$PartagePerformancesAPI.partage_qr_code.connect(_on_api_partage_qr_code)
	$PartagePerformancesAPI.erreur_decodage_qr.connect(_on_api_erreur_decodage_qr)
	$AdresseCourriel.text = $PartagePerformancesAPI.lire_adresse_courriel()
	$BoutonPartagerQR.visible = OS.has_feature("android")

	if OS.has_feature("android"):
		$BoutonPartagerQR.disabled = not ShareService.is_available()
		if not ShareService.share_failed.is_connected(_on_partage_qr_echoue):
			ShareService.share_failed.connect(_on_partage_qr_echoue)
		if $BoutonPartagerQR.disabled:
			_afficher_erreur("Le partage natif Android n'est pas disponible.")

## Reçoit une image de QR et demande son décodage et sa vérification.
func recevoir_image_qr(image: Image) -> bool:
	return $PartagePerformancesAPI.recevoir_image_qr(image)

## Lit les enregistrements du dernier niveau via l'API et affiche leur QR.
func afficher_dernier_niveau() -> bool:
	var enregistrements: Dictionary = $PartagePerformancesAPI.lire_donnees_dernier_niveau()
	return afficher(enregistrements)

## Affiche le panneau et prépare le QR à partir des enregistrements du niveau.
func afficher(enregistrements: Dictionary) -> bool:
	show()
	$ImageQR.texture = null
	$Message.visible = true
	$Message.text = "Préparation des performances..."
	$BoutonPartagerQR.disabled = true

	var resultat_partage: Dictionary = $PartagePerformancesAPI.preparer_partage(enregistrements)
	if not resultat_partage.get("succes", false):
		_afficher_erreur(resultat_partage.get("erreur", "Impossible de préparer le partage."))
		return false

	var resultat_qr: Dictionary = $PartagePerformancesAPI.generer_image_qr(resultat_partage.get("contenu_qr", ""))
	if not resultat_qr.get("succes", false):
		_afficher_erreur(resultat_qr.get("erreur", "Impossible de générer le QR."))
		return false

	$ImageQR.texture = ImageTexture.create_from_image(resultat_qr.get("image"))
	$Message.visible = false
	$BoutonPartagerQR.disabled = not OS.has_feature("android")
	return true

func _on_bouton_copier_courriel_pressed() -> void:
	DisplayServer.clipboard_set($PartagePerformancesAPI.lire_adresse_courriel())
	$Message.text = "Adresse courriel copiée."
	$Message.visible = true

func _on_bouton_partager_qr_pressed() -> void:
	if not ShareService.is_available():
		_afficher_erreur("Le partage natif Android n'est pas disponible.")
		return

	var texture_qr: Texture2D = $ImageQR.texture
	if not $PartagePerformancesAPI.partager_qr_android(ShareService, texture_qr):
		_afficher_erreur("Impossible de partager le QR code sur cet appareil.")

func _on_partage_qr_echoue(message: String) -> void:
	_afficher_erreur("Le partage du QR a échoué : %s" % message)

func _on_api_partage_qr_code(donnees_json: Dictionary) -> void:
	partage_qr_code.emit(donnees_json)

func _on_api_erreur_decodage_qr(message: String) -> void:
	_afficher_erreur(message)

func _on_bouton_fermer_pressed() -> void:
	fermer.emit()

func _afficher_erreur(message: String) -> void:
	$Message.text = message
	$Message.visible = true
