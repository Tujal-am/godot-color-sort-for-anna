extends GutTest

const LOGIQUE_PARTAGE = preload("res://Scenes/MenuPrincipal/Campagne/PartagePerformances/partage_performances_logic.gd")
const API_PARTAGE = preload("res://Scenes/MenuPrincipal/Campagne/PartagePerformances/partage_performances_api.gd")

var logique: PartagePerformancesLogic

func before_each() -> void:
	logique = LOGIQUE_PARTAGE.new()

func test_calculer_hmac_correspond_au_vecteur_sha256_connu() -> void:
	assert_eq(
		logique.calculer_hmac("The quick brown fox jumps over the lazy dog", "key"),
		"f7bc83f430538424b13298e6aa6fb143ef4d59a14946175997479dbc2d1a3cd8"
	)

func test_preparer_et_decoder_une_enveloppe_json_signee() -> void:
	var donnees := {
		"joueur": "Joueuse",
		"campagne": {
			"campagne": "campagne_2",
			"niveaux": [{"niveau": "niveau_1", "plateaux": [{"nom": "A1", "duree": 12.5}]}]
		}
	}
	var resultat: Dictionary = logique.preparer_enveloppe(donnees, "cle-de-test")
	var decode: Dictionary = logique.decoder_fichier_signe(resultat.get("contenu_fichier", ""), "cle-de-test")

	assert_true(resultat.get("succes", false))
	assert_true(decode.get("succes", false))
	assert_eq(decode.get("donnees"), donnees)

func test_decoder_refuse_une_signature_alteree() -> void:
	var resultat: Dictionary = logique.preparer_enveloppe({"joueur": "Joueuse"}, "cle-de-test")
	var enveloppe: Dictionary = JSON.parse_string(resultat.get("contenu_fichier", ""))
	enveloppe["signature"] = "0".repeat(64)

	var decode: Dictionary = logique.decoder_fichier_signe(JSON.stringify(enveloppe), "cle-de-test")

	assert_false(decode.get("succes", true))

func test_decoder_refuse_un_format_invalide_ou_une_cle_absente() -> void:
	assert_false(logique.decoder_fichier_signe("invalide", "cle").get("succes", true))
	assert_false(logique.preparer_enveloppe({"joueur": "Joueuse"}, "").get("succes", true))

func test_api_lit_l_integralite_de_la_derniere_campagne() -> void:
	var sauvegarde_initiale: Dictionary = SauvegardeBddJoueursService._sauvegarde_joueur.duplicate(true)
	var fichier_initial: String = SauvegardeBddJoueursService.fichier_sauvegarde
	SauvegardeBddJoueursService._sauvegarde_joueur = {
		"nom": "Joueuse",
		"enregistrement_campagne": [
			{"campagne": "ancienne", "niveaux": [{"niveau": "niveau_1"}]},
			{
				"campagne": "derniere",
				"date_fin": 200,
				"niveaux": [{"niveau": "niveau_2", "plateaux": [{"nom": "A1", "duree": 12.5}]}]
			}
		]
	}
	SauvegardeBddJoueursService.fichier_sauvegarde = "test"
	var api: PartagePerformancesAPI = add_child_autofree(API_PARTAGE.new())

	var donnees: Dictionary = api.lire_donnees_derniere_campagne()

	assert_eq(donnees.get("joueur"), "Joueuse")
	assert_eq(donnees.get("campagne"), SauvegardeBddJoueursService.enregistrement_campagne_lire_derniere_campagne())
	assert_eq(donnees.get("campagne", {}).get("niveaux", [])[0].get("plateaux", [])[0].get("duree"), 12.5)
	SauvegardeBddJoueursService._sauvegarde_joueur = sauvegarde_initiale
	SauvegardeBddJoueursService.fichier_sauvegarde = fichier_initial
