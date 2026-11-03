extends GutTest

const SCENE_PARTAGE = preload("res://Scenes/MenuPrincipal/Campagne/PartagePerformances/partage_performances_ui.tscn")
const API_PARTAGE = preload("res://Scenes/MenuPrincipal/Campagne/PartagePerformances/partage_performances_api.gd")
const RACINE_TEST := "tests/test_partage_performances_ui"
const ADRESSE := "rangelescouleurspouranna@gmail.com"

class FausseErreurQR extends RefCounted:
	func get_description() -> String:
		return "Image illisible"

var sauvegarde_joueur_initiale: Dictionary
var fichier_sauvegarde_initial: String

func _donnees_joueur() -> Dictionary:
	return {
		"nom": "Joueuse test",
		"campagne": {},
		"nombre_de_parties": {},
		"enregistrement_campagne": [{
			"campagne": "campagne_test",
			"date_debut": 1700000000,
			"date_fin": 0,
			"score": {},
			"niveaux": [
				{"niveau": "niveau_1", "date_debut": 1700000000, "date_fin": 1700000500, "plateaux": []},
				{
					"niveau": "niveau_2",
					"date_debut": 1700001000,
					"date_fin": 1700002000,
					"plateaux": [{
						"nom": "AB.BA",
						"gameplay": "CLASSIQUE",
						"difficulte": 3,
						"duree": 12.5,
						"statut": "reussi",
						"date_debut": 1700001010,
						"date_fin": 1700001022,
						"coups joués": [{"depart": 0, "arrivee": 1}],
						"score": {"duree": 20, "ratio_reussite": 80}
					}]
				}
			]
		}],
		"plateaux_libres": {}
	}

func before_each() -> void:
	FichiersJsonService.definir_racine_utilisateur(RACINE_TEST)
	FichiersJsonService.effacer_racine_utilisateur()
	sauvegarde_joueur_initiale = SauvegardeBddJoueursService._sauvegarde_joueur.duplicate(true)
	fichier_sauvegarde_initial = SauvegardeBddJoueursService.fichier_sauvegarde
	SauvegardeBddJoueursService._sauvegarde_joueur = _donnees_joueur()
	SauvegardeBddJoueursService.fichier_sauvegarde = "joueuse_test.json"

func after_each() -> void:
	SauvegardeBddJoueursService._sauvegarde_joueur = sauvegarde_joueur_initiale
	SauvegardeBddJoueursService.fichier_sauvegarde = fichier_sauvegarde_initial
	FichiersJsonService.effacer_racine_utilisateur()
	FichiersJsonService.reinitialiser_racine_utilisateur()

func _panneau() -> PartagePerformancesUI:
	return add_child_autofree(SCENE_PARTAGE.instantiate())

func _api() -> PartagePerformancesAPI:
	return add_child_autofree(API_PARTAGE.new())

# ------------------------------------------------------------------
# Interface

func test_le_panneau_affiche_son_titre_et_ses_boutons() -> void:
	var panneau := _panneau()

	assert_eq(panneau.get_node("Titre").text, "Partage tes performances")
	assert_eq(panneau.get_node("BoutonCopierCourriel").text, "Copier l'adresse courriel")
	assert_eq(panneau.get_node("BoutonPartagerQR").text, "Partager le QR code")
	assert_eq(panneau.get_node("BoutonFermer").text, "Retour au score")
	assert_eq(panneau.get_node("AdresseCourriel").text, ADRESSE)

func test_le_bouton_de_partage_natif_n_est_visible_que_sur_android() -> void:
	var panneau := _panneau()

	assert_eq(panneau.get_node("BoutonPartagerQR").visible, OS.has_feature("android"))

func test_le_bouton_fermer_emet_le_signal_fermer() -> void:
	var panneau := _panneau()
	var fermetures := [0]
	panneau.fermer.connect(func() -> void: fermetures[0] += 1)

	panneau.get_node("BoutonFermer").emit_signal("pressed")

	assert_eq(fermetures[0], 1)

func test_copier_l_adresse_courriel_confirme_a_l_utilisateur() -> void:
	var panneau := _panneau()
	var presse_papiers := ""
	var presse_papiers_disponible := DisplayServer.has_feature(DisplayServer.FEATURE_CLIPBOARD)
	if presse_papiers_disponible:
		presse_papiers = DisplayServer.clipboard_get()
	panneau.get_node("Message").visible = false

	panneau.get_node("BoutonCopierCourriel").emit_signal("pressed")

	assert_true(panneau.get_node("Message").visible)
	assert_eq(panneau.get_node("Message").text, "Adresse courriel copiée.")
	if presse_papiers_disponible:
		assert_eq(DisplayServer.clipboard_get(), ADRESSE)
		DisplayServer.clipboard_set(presse_papiers)

func test_le_partage_natif_est_refuse_quand_il_n_est_pas_disponible() -> void:
	if ShareService.is_available():
		return
	var panneau := _panneau()
	panneau.get_node("Message").visible = false

	await panneau._on_bouton_partager_qr_pressed()

	assert_true(panneau.get_node("Message").visible)
	assert_eq(panneau.get_node("Message").text, "Le partage natif Android n'est pas disponible.")

func test_un_echec_du_partage_natif_est_affiche_avec_son_motif() -> void:
	var panneau := _panneau()

	panneau._on_partage_qr_echoue("annulé")

	assert_true(panneau.get_node("Message").visible)
	assert_eq(panneau.get_node("Message").text, "Le partage du QR a échoué : annulé")

# ------------------------------------------------------------------
# Affichage du QR

func test_afficher_montre_le_panneau_et_signale_un_enregistrement_vide() -> void:
	var panneau := _panneau()
	panneau.hide()

	var partage_reussi: bool = await panneau.afficher({})

	assert_false(partage_reussi)
	assert_true(panneau.visible)
	assert_true(panneau.get_node("Message").visible)
	assert_eq(panneau.get_node("Message").text, "Aucun enregistrement de niveau à partager.")
	assert_null(panneau.get_node("ImageQR").texture)
	assert_true(panneau.get_node("BoutonPartagerQR").disabled)

func test_afficher_reinitialise_l_image_et_le_message_avant_chaque_preparation() -> void:
	var panneau := _panneau()
	panneau.get_node("ImageQR").texture = ImageTexture.create_from_image(Image.create(2, 2, false, Image.FORMAT_RGBA8))
	panneau.get_node("Message").visible = false

	await panneau.afficher({})

	assert_null(panneau.get_node("ImageQR").texture)
	assert_true(panneau.get_node("Message").visible)

func test_afficher_dernier_niveau_prepare_le_partage_depuis_la_sauvegarde() -> void:
	if Engine.has_singleton("QRPlugin"):
		return
	var panneau := _panneau()

	var partage_reussi: bool = await panneau.afficher_dernier_niveau()

	assert_false(partage_reussi)
	assert_true(panneau.visible)
	assert_true(panneau.get_node("Message").text.contains("Android"))
	assert_true(panneau._contenu_qr_partage.contains("Joueuse test"))

func test_recevoir_une_image_vide_affiche_l_erreur() -> void:
	var panneau := _panneau()
	panneau.get_node("Message").visible = false

	assert_false(panneau.recevoir_image_qr(null))
	assert_true(panneau.get_node("Message").visible)
	assert_eq(panneau.get_node("Message").text, "L'image QR est vide ou invalide.")

func test_les_erreurs_de_decodage_de_l_api_sont_affichees() -> void:
	var panneau := _panneau()

	panneau.get_node("PartagePerformancesAPI").erreur_decodage_qr.emit("QR illisible")

	assert_true(panneau.get_node("Message").visible)
	assert_eq(panneau.get_node("Message").text, "QR illisible")

func test_un_qr_decode_par_l_api_est_relaye_par_le_panneau() -> void:
	var panneau := _panneau()
	var recus: Array[Dictionary] = []
	panneau.partage_qr_code.connect(func(donnees: Dictionary) -> void: recus.append(donnees))

	panneau.get_node("PartagePerformancesAPI").partage_qr_code.emit({"joueur": "Joueuse test"})

	assert_eq(recus, [{"joueur": "Joueuse test"}])

# ------------------------------------------------------------------
# API

func test_api_lit_les_donnees_allegees_du_dernier_niveau() -> void:
	var api := _api()

	var donnees: Dictionary = api.lire_donnees_dernier_niveau()

	assert_eq(donnees.get("joueur"), "Joueuse test")
	assert_eq(donnees.get("campagne"), "campagne_test")
	assert_eq(donnees.get("niveau"), "niveau_2")
	assert_eq(donnees.get("Status"), "Ne pas importer")
	assert_eq(donnees.get("plateaux"), [{
		"nom": "AB.BA",
		"gameplay": "CLASSIQUE",
		"difficulte": 3,
		"duree": 12.5,
		"statut": "reussi"
	}])

func test_api_n_altere_pas_la_sauvegarde_en_allegeant_les_donnees() -> void:
	var api := _api()

	api.lire_donnees_dernier_niveau()

	var plateau: Dictionary = SauvegardeBddJoueursService.enregistrement_campagne_lire_dernier_plateau()
	assert_true(plateau.has("coups joués"))
	assert_true(plateau.has("score"))
	assert_true(plateau.has("date_debut"))
	assert_true(plateau.has("date_fin"))

func test_api_compose_le_sous_titre_du_qr_avec_joueur_campagne_et_niveau() -> void:
	var api := _api()

	assert_eq(api.lire_sous_titre_qr(), "Joueuse test - Campagne Test - Niveau 2")

func test_api_refuse_un_sous_titre_sans_nom_de_joueur() -> void:
	var api := _api()
	SauvegardeBddJoueursService._sauvegarde_joueur["nom"] = ""

	assert_eq(api.lire_sous_titre_qr(), "")

func test_ajouter_sous_titre_refuse_une_image_absente_ou_vide() -> void:
	var api := _api()

	var resultat_null: Dictionary = await api.ajouter_sous_titre_qr(null)
	var resultat_vide: Dictionary = await api.ajouter_sous_titre_qr(Image.new())

	assert_false(resultat_null.get("succes", true))
	assert_eq(resultat_null.get("erreur"), "L'image du QR est vide.")
	assert_false(resultat_vide.get("succes", true))
	assert_eq(resultat_vide.get("erreur"), "L'image du QR est vide.")

func test_ajouter_sous_titre_refuse_une_echelle_invalide() -> void:
	var api := _api()
	var image := Image.create(64, 64, false, Image.FORMAT_RGBA8)

	var resultat_nul: Dictionary = await api.ajouter_sous_titre_qr(image, 0.0)
	var resultat_negatif: Dictionary = await api.ajouter_sous_titre_qr(image, -1.0)

	assert_false(resultat_nul.get("succes", true))
	assert_eq(resultat_nul.get("erreur"), "L'échelle du sous-titre QR est invalide.")
	assert_false(resultat_negatif.get("succes", true))

func test_ajouter_sous_titre_refuse_un_sous_titre_indisponible() -> void:
	var api := _api()
	SauvegardeBddJoueursService._sauvegarde_joueur["nom"] = ""
	var image := Image.create(64, 64, false, Image.FORMAT_RGBA8)

	var resultat: Dictionary = await api.ajouter_sous_titre_qr(image)

	assert_false(resultat.get("succes", true))
	assert_true(resultat.get("erreur", "").contains("indisponible"))

func test_generer_image_qr_est_indisponible_hors_plugin() -> void:
	if Engine.has_singleton("QRPlugin"):
		return
	var api := _api()

	var resultat: Dictionary = api.generer_image_qr("contenu")
	var resultat_partage: Dictionary = await api.generer_image_qr_pour_partage("contenu")

	assert_false(resultat.get("succes", true))
	assert_true(resultat.get("erreur", "").contains("Android"))
	assert_false(resultat_partage.get("succes", true))
	assert_eq(resultat_partage.get("erreur"), resultat.get("erreur"))

func test_api_signale_une_image_qr_vide() -> void:
	var api := _api()
	var erreurs: Array[String] = []
	api.erreur_decodage_qr.connect(func(message: String) -> void: erreurs.append(message))

	assert_false(api.recevoir_image_qr(null))
	assert_false(api.recevoir_image_qr(Image.new()))

	assert_eq(erreurs, ["L'image QR est vide ou invalide.", "L'image QR est vide ou invalide."])

func test_qr_detecte_signale_que_l_import_n_est_plus_compatible() -> void:
	var api := _api()
	var erreurs: Array[String] = []
	var importes: Array[Dictionary] = []
	api.erreur_decodage_qr.connect(func(message: String) -> void: erreurs.append(message))
	api.partage_qr_code.connect(func(donnees: Dictionary) -> void: importes.append(donnees))
	var cle_hmac: String = ProjectSettings.get_setting("partage_performances/cle_hmac", "")
	var enveloppe: Dictionary = API_PARTAGE.LOGIQUE.new().preparer_enveloppe({"joueur": "Joueuse test"}, cle_hmac)

	api._on_qr_detected(enveloppe.get("contenu_qr", ""))

	assert_eq(erreurs, ["Dans cette version, l'import de QR n'est plus compatible."])
	assert_eq(importes, [])

func test_echec_de_scan_utilise_la_description_du_plugin() -> void:
	var api := _api()
	var erreurs: Array[String] = []
	api.erreur_decodage_qr.connect(func(message: String) -> void: erreurs.append(message))

	api._on_qr_scan_failed(FausseErreurQR.new())

	assert_eq(erreurs, ["Image illisible"])

func test_echec_de_scan_sans_description_utilise_le_message_par_defaut() -> void:
	var api := _api()
	var erreurs: Array[String] = []
	api.erreur_decodage_qr.connect(func(message: String) -> void: erreurs.append(message))
	var erreur_anonyme := RefCounted.new()

	api._on_qr_scan_failed(erreur_anonyme)

	assert_eq(erreurs, ["Le plugin QR n'a pas pu décoder l'image."])

func test_echec_de_scan_libere_le_scanner_en_cours() -> void:
	var api := _api()
	var scanner := Node.new()
	api.add_child(scanner)
	api._qr_scanner = scanner

	api._on_qr_scan_failed(FausseErreurQR.new())

	assert_null(api._qr_scanner)
	assert_true(scanner.is_queued_for_deletion())
