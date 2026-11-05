extends RefCounted

class_name PartagePerformancesLogic

## Sérialise et signe les données de campagne pour leur partage en fichier JSON.
func preparer_enveloppe(donnees: Dictionary, cle_hmac: String) -> Dictionary:
	if donnees.is_empty():
		return _erreur("Aucune donnée de campagne à partager.")
	if cle_hmac.is_empty():
		return _erreur("La clé HMAC n'est pas configurée.")

	var donnees_json := JSON.stringify(donnees)
	if donnees_json.is_empty():
		return _erreur("Les données ne peuvent pas être sérialisées en JSON.")

	var signature := calculer_hmac(donnees_json, cle_hmac)
	if signature.is_empty():
		return _erreur("Le calcul de la signature HMAC a échoué.")

	var contenu_fichier := JSON.stringify({
		"version": 1,
		"algorithme": "HMAC-SHA256",
		"donnees_json": donnees_json,
		"signature": signature
	})
	return {
		"succes": true,
		"donnees_json": donnees_json,
		"signature": signature,
		"contenu_fichier": contenu_fichier
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

## Lit une enveloppe JSON et retourne les données uniquement si le HMAC est valide.
func decoder_fichier_signe(contenu_fichier: String, cle_hmac: String) -> Dictionary:
	var parseur_enveloppe := JSON.new()
	if parseur_enveloppe.parse(contenu_fichier) != OK:
		return _erreur("Le fichier partagé n'est pas un objet JSON valide.")
	var enveloppe: Variant = parseur_enveloppe.data
	if not enveloppe is Dictionary:
		return _erreur("Le fichier partagé n'est pas un objet JSON valide.")
	if enveloppe.get("version") != 1:
		return _erreur("La version du fichier partagé n'est pas prise en charge.")
	if enveloppe.get("algorithme") != "HMAC-SHA256":
		return _erreur("L'algorithme de signature du fichier n'est pas pris en charge.")

	var donnees_json: Variant = enveloppe.get("donnees_json")
	var signature: Variant = enveloppe.get("signature")
	if not donnees_json is String or not signature is String:
		return _erreur("Le fichier ne contient pas de données ou de signature valides.")
	if not verifier_hmac(donnees_json, signature, cle_hmac):
		return _erreur("La signature HMAC du fichier est invalide.")

	var parseur_donnees := JSON.new()
	if parseur_donnees.parse(donnees_json) != OK:
		return _erreur("Les données signées ne sont pas un objet JSON valide.")
	var donnees: Variant = parseur_donnees.data
	if not donnees is Dictionary:
		return _erreur("Les données signées ne sont pas un objet JSON valide.")

	return {"succes": true, "donnees": donnees}

func _erreur(message: String) -> Dictionary:
	return {"succes": false, "erreur": message}
