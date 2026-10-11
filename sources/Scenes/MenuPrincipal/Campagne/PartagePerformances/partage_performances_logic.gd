extends RefCounted

class_name PartagePerformancesLogic

const DESTINATAIRE_COURRIEL := "rangelescouleurspouranna@gmail.com"

## Sérialise et signe les enregistrements, puis prépare l'enveloppe à encoder.
func preparer_enveloppe(enregistrements: Dictionary, cle_hmac: String) -> Dictionary:
	if enregistrements.is_empty():
		return _erreur("Aucun enregistrement de niveau à partager.")
	if cle_hmac.is_empty():
		return _erreur("La clé HMAC n'est pas configurée.")

	var donnees_json := JSON.stringify(enregistrements)
	if donnees_json.is_empty():
		return _erreur("Les enregistrements ne peuvent pas être sérialisés en JSON.")

	var signature := calculer_hmac(donnees_json, cle_hmac)
	if signature.is_empty():
		return _erreur("Le calcul de la signature HMAC a échoué.")

	var contenu_qr := JSON.stringify({
		"version": 1,
		"algorithme": "HMAC-SHA256",
		"donnees_json": donnees_json,
		"signature": signature
	})
	return {
		"succes": true,
		"donnees_json": donnees_json,
		"signature": signature,
		"contenu_qr": contenu_qr
	}

## Calcule une empreinte HMAC-SHA256 hexadécimale des données UTF-8.
func calculer_hmac(donnees: String, cle_hmac: String) -> String:
	if cle_hmac.is_empty():
		return ""

	var crypto := Crypto.new()
	var empreinte := crypto.hmac_digest(
		HashingContext.HASH_SHA256,
		cle_hmac.to_utf8_buffer(),
		donnees.to_utf8_buffer()
	)
	if empreinte.is_empty():
		return ""
	return empreinte.hex_encode()

## Vérifie la signature HMAC-SHA256 des données fournies.
func verifier_hmac(donnees: String, signature: String, cle_hmac: String) -> bool:
	if signature.length() != 64 or cle_hmac.is_empty():
		return false
	return calculer_hmac(donnees, cle_hmac) == signature.to_lower()

## Décode une enveloppe QR et retourne les données uniquement si le HMAC est valide.
func decoder_et_verifier_qr(contenu_qr: String, cle_hmac: String) -> Dictionary:
	var parseur_enveloppe := JSON.new()
	if parseur_enveloppe.parse(contenu_qr) != OK:
		return _erreur("Le contenu du QR n'est pas une enveloppe JSON valide.")
	var enveloppe: Variant = parseur_enveloppe.data
	if not enveloppe is Dictionary:
		return _erreur("Le contenu du QR n'est pas une enveloppe JSON valide.")
	if enveloppe.get("version") != 1:
		return _erreur("La version du QR n'est pas prise en charge.")
	if enveloppe.get("algorithme") != "HMAC-SHA256":
		return _erreur("L'algorithme de signature du QR n'est pas pris en charge.")

	var donnees_json: Variant = enveloppe.get("donnees_json")
	var signature: Variant = enveloppe.get("signature")
	if not donnees_json is String or not signature is String:
		return _erreur("L'enveloppe QR ne contient pas de données ou de signature valides.")
	if not verifier_hmac(donnees_json, signature, cle_hmac):
		return _erreur("La signature HMAC du QR est invalide.")

	var parseur_donnees := JSON.new()
	if parseur_donnees.parse(donnees_json) != OK:
		return _erreur("Les données signées du QR ne sont pas un objet JSON valide.")
	var donnees: Variant = parseur_donnees.data
	if not donnees is Dictionary:
		return _erreur("Les données signées du QR ne sont pas un objet JSON valide.")

	return {"succes": true, "donnees": donnees}

## Génère une image QR avec l'extension native chargée dans le projet.
func generer_image_qr(contenu: String, parent: Node) -> Dictionary:
	if not Engine.has_singleton("QRPlugin"):
		return _erreur("La génération de QR n'est disponible que dans les exports Android.")

	var qr_script := load("res://addons/QRPlugin/QR.gd") as Script
	if qr_script == null:
		return _erreur("Le script du plugin QR est introuvable.")

	var qr_node := qr_script.new() as Node
	if qr_node == null:
		return _erreur("Impossible d'initialiser le plugin QR.")

	parent.add_child(qr_node)
	var image: Variant = qr_node.call("generate_qr_image", contenu, 512, Color.BLACK, Color.WHITE)
	qr_node.queue_free()
	if not image is Image or image.is_empty():
		return _erreur("Le plugin QR n'a pas pu générer l'image.")

	return {"succes": true, "image": image}

func _erreur(message: String) -> Dictionary:
	return {"succes": false, "erreur": message}
