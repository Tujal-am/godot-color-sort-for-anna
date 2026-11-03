extends GutTest

const LOGIQUE_PARTAGE = preload("res://Scenes/MenuPrincipal/Campagne/PartagePerformances/partage_performances_logic.gd")
const API_PARTAGE = preload("res://Scenes/MenuPrincipal/Campagne/PartagePerformances/partage_performances_api.gd")
const SCENE_PARTAGE = preload("res://Scenes/MenuPrincipal/Campagne/PartagePerformances/partage_performances_ui.tscn")
const SCENE_MESSAGES_CAMPAGNE = preload("res://Scenes/MenuPrincipal/Campagne/MessagesCampagne/messages_campagne.tscn")

var logique: PartagePerformancesLogic

func before_each() -> void:
	logique = LOGIQUE_PARTAGE.new()

func test_qr_code_00_reel_depuis_appli() -> void:
	var qr_code = {"algorithme":"HMAC-SHA256","donnees_json":"{\"niveau\":{\"date_debut\":1790715101.25958,\"date_fin\":1790715118.80644,\"niveau\":\"niveau_3\",\"plateaux\":[{\"coups joués\":[{\"arrivee\":2,\"depart\":3},{\"arrivee\":3,\"depart\":4},{\"arrivee\":2,\"depart\":1},{\"arrivee\":1,\"depart\":0},{\"arrivee\":2,\"depart\":0},{\"arrivee\":0,\"depart\":1},{\"arrivee\":4,\"depart\":1}],\"date_debut\":1790715101.2635,\"date_fin\":1790715110.20952,\"difficulte\":10,\"duree\":8.94602203369141,\"gameplay\":\"CLASSIQUE\",\"nom\":\"DBD.CDB.   .AAB.CCA\",\"score\":{\"duree\":1341,\"ratio_reussite\":1500},\"statut\":\"reussi\"},{\"coups joués\":[{\"arrivee\":0,\"depart\":4}],\"date_debut\":1790715112.16423,\"date_fin\":1790715118.80384,\"difficulte\":11,\"duree\":6.63960909843445,\"gameplay\":\"QUI_PERD_GAGNE\",\"nom\":\"AB .AA .DCC.BDC.DB \",\"score\":{\"duree\":2319,\"ratio_reussite\":1500},\"statut\":\"reussi\"}],\"score\":{\"niveau\":1000,\"niveau_parfait\":1000}},\"nom\":\"Alain Konu\"}","signature":"9e515a6810a3799ca689d2e8b1bba4a84a77fc49bff65dd76d95820d3f804187","version":1}
	var donnees : String = qr_code.get("donnees_json", "")
	var signature : String = qr_code.get("signature", "")
	var cle_hmac : String = ProjectSettings.get_setting("partage_performances/cle_hmac", "")
	var msg_authentique : bool = logique.verifier_hmac(donnees, signature, cle_hmac)
	assert_true(msg_authentique)

func test_qr_code_01_reel_depuis_appli() -> void:
	var qr_code = {"algorithme":"HMAC-SHA256","donnees_json":"{\"niveau\":{\"date_debut\":1790717811.96122,\"date_fin\":1790717822.41267,\"niveau\":\"niveau_1\",\"plateaux\":[{\"coups joués\":[{\"arrivee\":3,\"depart\":2},{\"arrivee\":3,\"depart\":1},{\"arrivee\":1,\"depart\":4},{\"arrivee\":3,\"depart\":4},{\"arrivee\":2,\"depart\":0},{\"arrivee\":0,\"depart\":4}],\"date_debut\":1790717811.96308,\"date_fin\":1790717817.71838,\"difficulte\":10,\"duree\":5.75530004501343,\"gameplay\":\"CLASSIQUE\",\"nom\":\"DDA.CCB.AAB.   .DBC\",\"score\":{\"duree\":2085,\"ratio_reussite\":500},\"statut\":\"reussi\"},{\"coups joués\":[{\"arrivee\":6,\"depart\":4}],\"date_debut\":1790717820.8535,\"date_fin\":1790717822.41083,\"difficulte\":11,\"duree\":1.55732798576355,\"gameplay\":\"QUI_PERD_GAGNE\",\"nom\":\"AC.BD.CD.EA.FB.FE.  \",\"score\":{\"duree\":9889,\"ratio_reussite\":500},\"statut\":\"reussi\"}],\"score\":{\"niveau\":1000,\"niveau_parfait\":1000}},\"nom\":\"GuiGuiX\"}","signature":"b18a7d4ac8c530d5ef0671e22b1b1a200af2ee3746505635cbaafd738a9f974f","version":1}
	var donnees : String = qr_code.get("donnees_json", "")
	var signature : String = qr_code.get("signature", "")
	var cle_hmac : String = ProjectSettings.get_setting("partage_performances/cle_hmac", "")
	var msg_authentique : bool = logique.verifier_hmac(donnees, signature, cle_hmac)
	assert_true(msg_authentique)

func test_qr_code_02_reel_depuis_appli() -> void:
	var qr_code = {"algorithme":"HMAC-SHA256","donnees_json":"{\"niveau\":{\"date_debut\":1790718189.50043,\"date_fin\":1790718207.53138,\"niveau\":\"niveau_2\",\"plateaux\":[{\"coups joués\":[{\"arrivee\":3,\"depart\":1},{\"arrivee\":3,\"depart\":0},{\"arrivee\":0,\"depart\":4},{\"arrivee\":4,\"depart\":2},{\"arrivee\":2,\"depart\":1},{\"arrivee\":1,\"depart\":4},{\"arrivee\":0,\"depart\":4}],\"date_debut\":1790718189.50149,\"date_fin\":1790718202.79959,\"difficulte\":10,\"duree\":13.2980999946594,\"gameplay\":\"CLASSIQUE\",\"nom\":\"DC .ABC.BBA.C  .DAD\",\"score\":{\"duree\":902,\"ratio_reussite\":1000},\"statut\":\"reussi\"},{\"coups joués\":[{\"arrivee\":1,\"depart\":2}],\"date_debut\":1790718205.11719,\"date_fin\":1790718207.52914,\"difficulte\":11,\"duree\":2.4119508266449,\"gameplay\":\"QUI_PERD_GAGNE\",\"nom\":\"AAC.CB .DB .DDC.BA \",\"score\":{\"duree\":6385,\"ratio_reussite\":1000},\"statut\":\"reussi\"}],\"score\":{\"niveau\":1000,\"niveau_parfait\":1000}},\"nom\":\"GuiGuiX\"}","signature":"2c84f8cf8779b68ba7d7392991d9cc0c37fc051c89bb48b63c933d98d4e39929","version":1}
	var donnees : String = qr_code.get("donnees_json", "")
	var signature : String = qr_code.get("signature", "")
	var cle_hmac : String = ProjectSettings.get_setting("partage_performances/cle_hmac", "")
	var msg_authentique : bool = logique.verifier_hmac(donnees, signature, cle_hmac)
	assert_true(msg_authentique)

func test_calculer_hmac_projet() -> void:
	var donnees : String = "The quick brown fox jumps over the lazy dog"
	var cle_hmac : String = ProjectSettings.get_setting("partage_performances/cle_hmac", "")
	var signature : String = logique.calculer_hmac(donnees, cle_hmac)
	var msg_authentique : bool = logique.verifier_hmac(donnees, signature, cle_hmac)
	assert_true(msg_authentique)

func test_calculer_hmac_correspond_au_vecteur_sha256_connu() -> void:
	var signature := logique.calculer_hmac(
		"The quick brown fox jumps over the lazy dog",
		"key"
	)

	assert_eq(signature, "f7bc83f430538424b13298e6aa6fb143ef4d59a14946175997479dbc2d1a3cd8")

func test_preparer_enveloppe_emballe_les_donnees_et_leur_signature() -> void:
	var enregistrements := {"niveau": 3, "plateaux": [{"duree": 18.5, "coups": 24}]}
	var resultat: Dictionary = logique.preparer_enveloppe(enregistrements, "cle-de-test")
	var enveloppe: Dictionary = JSON.parse_string(resultat.get("contenu_qr", ""))

	assert_true(resultat.get("succes", false))
	assert_eq(enveloppe.get("version"), 1.0)
	assert_eq(enveloppe.get("algorithme"), "HMAC-SHA256")
	var donnees_decodees: Dictionary = JSON.parse_string(enveloppe.get("donnees_json", ""))
	var premier_plateau: Dictionary = donnees_decodees.get("plateaux", [])[0]
	assert_eq(donnees_decodees.get("niveau"), 3.0)
	assert_eq(premier_plateau.get("duree"), 18.5)
	assert_eq(premier_plateau.get("coups"), 24.0)
	assert_true(logique.verifier_hmac(
		enveloppe.get("donnees_json", ""),
		enveloppe.get("signature", ""),
		"cle-de-test"
	))

func test_preparer_enveloppe_refuse_les_donnees_vides_et_une_cle_absente() -> void:
	var resultat_sans_donnees: Dictionary = logique.preparer_enveloppe({}, "cle")
	var resultat_sans_cle: Dictionary = logique.preparer_enveloppe({"niveau": 1}, "")

	assert_false(resultat_sans_donnees.get("succes", true))
	assert_false(resultat_sans_cle.get("succes", true))

func test_ajouter_sous_titre_qr_preserve_le_qr_et_inclut_le_texte_dans_image() -> void:
	var api: PartagePerformancesAPI = add_child_autofree(API_PARTAGE.new())
	var sauvegarde_initiale: Dictionary = SauvegardeBddJoueursService._sauvegarde_joueur.duplicate(true)
	var fichier_initial: String = SauvegardeBddJoueursService.fichier_sauvegarde
	SauvegardeBddJoueursService._sauvegarde_joueur = {
		"nom": "Joueuse",
		"enregistrement_campagne": [{
			"campagne": "campagne_2",
			"niveaux": [{"niveau": "niveau_2"}]
		}]
	}
	SauvegardeBddJoueursService.fichier_sauvegarde = "test"
	assert_eq(api.lire_sous_titre_qr(), "Joueuse - Campagne 2 - Niveau 2")
	if DisplayServer.get_name() == "headless":
		SauvegardeBddJoueursService._sauvegarde_joueur = sauvegarde_initiale
		SauvegardeBddJoueursService.fichier_sauvegarde = fichier_initial
		return

	var image_qr := Image.create(128, 128, false, Image.FORMAT_RGBA8)
	image_qr.fill(Color.BLACK)
	var resultat: Dictionary = await api.ajouter_sous_titre_qr(image_qr)
	SauvegardeBddJoueursService._sauvegarde_joueur = sauvegarde_initiale
	SauvegardeBddJoueursService.fichier_sauvegarde = fichier_initial
	var image_finale: Image = resultat.get("image")

	assert_true(resultat.get("succes", false))
	assert_eq(image_finale.get_width(), 128)
	assert_eq(image_finale.get_height(), 206)
	assert_eq(image_finale.get_pixel(20, 20), Color.BLACK)

	var texte_dessine := false
	for y in range(150, image_finale.get_height()):
		for x in range(image_finale.get_width()):
			if image_finale.get_pixel(x, y) != Color.WHITE:
				texte_dessine = true
				break
		if texte_dessine:
			break
	assert_true(texte_dessine)

func test_verifier_hmac_refuse_une_signature_modifiee_ou_mal_formee() -> void:
	var signature := logique.calculer_hmac("donnees", "cle")

	assert_false(logique.verifier_hmac("donnees modifiees", signature, "cle"))
	assert_false(logique.verifier_hmac("donnees", "abc", "cle"))
	assert_false(logique.verifier_hmac("donnees", signature, ""))

func test_decoder_qr_retourne_les_donnees_apres_verification_hmac() -> void:
	var donnees := {
		"joueur": "Joueuse",
		"campagne": {
			"campagne": "campagne_2",
			"date_debut": 100.25,
			"date_fin": 200.5,
			"score": {"fin_campagne": 500.0}
		},
		"niveau": {"niveau": "niveau_2", "plateaux": []}
	}
	var enveloppe: Dictionary = logique.preparer_enveloppe(donnees, "cle-test")
	var resultat: Dictionary = logique.decoder_et_verifier_qr(enveloppe.get("contenu_qr", ""), "cle-test")

	assert_true(resultat.get("succes", false))
	assert_eq(resultat.get("donnees"), donnees)

func test_decoder_qr_refuse_un_hmac_invalide() -> void:
	var enveloppe: Dictionary = logique.preparer_enveloppe({"nom": "Joueuse"}, "cle-test")
	var qr: Dictionary = JSON.parse_string(enveloppe.get("contenu_qr", ""))
	qr["donnees_json"] = "{\"nom\":\"Autre joueuse\"}"
	var resultat: Dictionary = logique.decoder_et_verifier_qr(JSON.stringify(qr), "cle-test")

	assert_false(resultat.get("succes", true))
	assert_true(resultat.get("erreur", "").contains("signature HMAC"))

func test_decoder_qr_refuse_les_enveloppes_mal_formees_ou_incompatibles() -> void:
	var resultat_json_invalide: Dictionary = logique.decoder_et_verifier_qr("{invalide", "cle")
	var resultat_version_inconnue: Dictionary = logique.decoder_et_verifier_qr(
		JSON.stringify({"version": 2, "algorithme": "HMAC-SHA256"}),
		"cle"
	)
	var resultat_donnees_non_objet: Dictionary = logique.decoder_et_verifier_qr(
		JSON.stringify({
			"version": 1,
			"algorithme": "HMAC-SHA256",
			"donnees_json": "[]",
			"signature": logique.calculer_hmac("[]", "cle")
		}),
		"cle"
	)

	assert_false(resultat_json_invalide.get("succes", true))
	assert_false(resultat_version_inconnue.get("succes", true))
	assert_false(resultat_donnees_non_objet.get("succes", true))

func test_api_utilise_la_cle_configuree_dans_le_projet() -> void:
	var api: PartagePerformancesAPI = add_child_autofree(API_PARTAGE.new())
	var resultat: Dictionary = api.preparer_partage({"niveau": 4})

	assert_true(resultat.get("succes", false))
	assert_true(logique.verifier_hmac(
		resultat.get("donnees_json", ""),
		resultat.get("signature", ""),
		ProjectSettings.get_setting("partage_performances/cle_hmac", "")
	))

func test_api_expose_ladresse_courriel_a_copier() -> void:
	var api: PartagePerformancesAPI = add_child_autofree(API_PARTAGE.new())

	assert_eq(api.lire_adresse_courriel(), "rangelescouleurspouranna@gmail.com")

func test_panneau_affiche_et_permet_de_copier_ladresse_courriel_sans_bouton_mail() -> void:
	var panneau: PartagePerformancesUI = add_child_autofree(SCENE_PARTAGE.instantiate())

	assert_eq(panneau.get_node("AdresseCourriel").text, "rangelescouleurspouranna@gmail.com")
	assert_not_null(panneau.get_node_or_null("BoutonCopierCourriel"))
	assert_null(panneau.get_node_or_null("BoutonCourriel"))

func test_api_refuse_le_partage_natif_hors_android() -> void:
	if OS.has_feature("android"):
		return

	var api: PartagePerformancesAPI = add_child_autofree(API_PARTAGE.new())
	var share_node: Node = add_child_autofree(Node.new())
	var texture := ImageTexture.create_from_image(Image.create(1, 1, false, Image.FORMAT_RGBA8))

	assert_false(api.partager_qr_android(share_node, texture))

func test_sous_titre_sadapte_a_limage_qr_haute_resolution() -> void:
	if DisplayServer.get_name() == "headless":
		assert_eq(API_PARTAGE.TAILLE_QR_PARTAGE, 1024)
		return

	var api: PartagePerformancesAPI = add_child_autofree(API_PARTAGE.new())
	var sauvegarde_initiale: Dictionary = SauvegardeBddJoueursService._sauvegarde_joueur.duplicate(true)
	var fichier_initial: String = SauvegardeBddJoueursService.fichier_sauvegarde
	SauvegardeBddJoueursService._sauvegarde_joueur = {
		"nom": "A",
		"enregistrement_campagne": [{
			"campagne": "b",
			"niveaux": [{"niveau": "c"}]
		}]
	}
	SauvegardeBddJoueursService.fichier_sauvegarde = "test"
	var image_qr := Image.create(512, 512, false, Image.FORMAT_RGBA8)
	image_qr.fill(Color.WHITE)

	var resultat: Dictionary = await api.ajouter_sous_titre_qr(image_qr, 2.0)
	SauvegardeBddJoueursService._sauvegarde_joueur = sauvegarde_initiale
	SauvegardeBddJoueursService.fichier_sauvegarde = fichier_initial

	assert_true(resultat.get("succes", false))
	if not resultat.get("succes", false):
		return
	var image_partage: Image = resultat.get("image")
	assert_eq(image_partage.get_width(), 512)
	assert_eq(image_partage.get_height(), 668)

# Import QR volontairement interdit dans cette version : un QR valide est refusé.
func test_api_refuse_l_import_d_un_qr_valide_dans_cette_version() -> void:
	var api: PartagePerformancesAPI = add_child_autofree(API_PARTAGE.new())
	var donnees_attendues := {
		"joueur": "Joueuse",
		"campagne": {
			"campagne": "campagne_2",
			"date_debut": 100.25,
			"date_fin": 200.5,
			"score": {"fin_campagne": 500.0}
		},
		"niveau": {"niveau": "niveau_2", "plateaux": []}
	}
	var cle_hmac: String = ProjectSettings.get_setting("partage_performances/cle_hmac", "")
	var enveloppe: Dictionary = logique.preparer_enveloppe(donnees_attendues, cle_hmac)
	var qr_valide: Array[Dictionary] = []
	var erreurs: Array[String] = []
	api.partage_qr_code.connect(func(donnees: Dictionary) -> void: qr_valide.append(donnees))
	api.erreur_decodage_qr.connect(func(message: String) -> void: erreurs.append(message))

	api._on_qr_detected(enveloppe.get("contenu_qr", ""))

	assert_eq(qr_valide.size(), 0)
	assert_eq(erreurs.size(), 1)
	assert_true(erreurs[0].contains("plus compatible"))

func test_api_signale_quand_le_decodage_nest_pas_disponible() -> void:
	if Engine.has_singleton("QRPlugin"):
		return

	var api: PartagePerformancesAPI = add_child_autofree(API_PARTAGE.new())
	var erreurs: Array[String] = []
	api.erreur_decodage_qr.connect(func(message: String) -> void: erreurs.append(message))
	var image := Image.create(2, 2, false, Image.FORMAT_RGBA8)

	assert_false(api.recevoir_image_qr(image))
	assert_eq(erreurs.size(), 1)
	assert_true(erreurs[0].contains("plateforme"))

func test_scene_n_emet_pas_partage_qr_code_pour_un_qr_valide_dans_cette_version() -> void:
	var panneau: PartagePerformancesUI = add_child_autofree(SCENE_PARTAGE.instantiate())
	var api: PartagePerformancesAPI = panneau.get_node("PartagePerformancesAPI")
	var donnees_attendues := {
		"joueur": "Joueuse",
		"campagne": {
			"campagne": "campagne_2",
			"date_debut": 100.25,
			"date_fin": 200.5,
			"score": {"fin_campagne": 500.0}
		},
		"niveau": {"niveau": "niveau_2", "plateaux": []}
	}
	var cle_hmac: String = ProjectSettings.get_setting("partage_performances/cle_hmac", "")
	var enveloppe: Dictionary = logique.preparer_enveloppe(donnees_attendues, cle_hmac)
	var qr_valide: Array[Dictionary] = []
	panneau.partage_qr_code.connect(func(donnees: Dictionary) -> void: qr_valide.append(donnees))

	api._on_qr_detected(enveloppe.get("contenu_qr", ""))

	assert_true(panneau.has_method("recevoir_image_qr"))
	assert_eq(qr_valide.size(), 0)

func test_api_lit_le_nom_du_joueur_et_le_dernier_niveau() -> void:
	var api: PartagePerformancesAPI = add_child_autofree(API_PARTAGE.new())
	var donnees: Dictionary = api.lire_donnees_dernier_niveau()

	assert_eq(donnees.size(), 5)
	assert_eq(donnees.get("joueur"), SauvegardeBddJoueursService.lire_nom_joueur())
	assert_eq(donnees.get("campagne"), SauvegardeBddJoueursService.enregistrement_campagne_lire_nom_derniere_campagne())
	assert_eq(donnees.get("niveau"), SauvegardeBddJoueursService.enregistrement_campagne_lire_nom_dernier_niveau())
	assert_eq(donnees.get("Status"), "Ne pas importer")
	var plateaux = donnees.get("plateaux")
	assert_true(plateaux is Array)
	for plateau in plateaux:
		for cle in ["coups joués", "date_debut", "date_fin", "score"]:
			assert_false(plateau.has(cle), "champ allege attendu absent : " + cle)

func test_panneau_explique_lindisponibilite_du_qr_sur_une_plateforme_non_supportee() -> void:
	if Engine.has_singleton("QRPlugin"):
		return

	var panneau: PartagePerformancesUI = add_child_autofree(SCENE_PARTAGE.instantiate())
	var partage_reussi: bool = await panneau.afficher({"niveau": 4})
	var message: Label = panneau.get_node("Message")

	assert_false(partage_reussi)
	assert_true(message.visible)
	assert_true(message.text.contains("Android"))
	assert_eq(panneau.get_node("AdresseCourriel").text, "rangelescouleurspouranna@gmail.com")
	assert_false(panneau.get_node("BoutonPartagerQR").visible)

func test_messages_campagne_affiche_le_panneau_avec_les_enregistrements_fournis() -> void:
	var menu: MessagesCampagne = add_child_autofree(SCENE_MESSAGES_CAMPAGNE.instantiate())

	await menu.afficher_partage_performances({"niveau": 4})

	assert_true(menu.get_node("Centrer").visible)
	assert_true(menu.get_node("Centrer/PanneauPartagePerformances").visible)

func test_fin_de_niveau_affiche_le_partage_apres_le_panneau_de_score() -> void:
	var menu: MessagesCampagne = add_child_autofree(SCENE_MESSAGES_CAMPAGNE.instantiate())
	var panneau_partage: Control = menu.get_node("Centrer/PanneauPartagePerformances")
	var panneau_niveau: Control = menu.get_node("Centrer/PanneauVictoireNiveau")
	var continuations: Array[bool] = []
	menu.score_continuer.connect(func() -> void: continuations.append(true))

	panneau_niveau.show()
	await menu._on_panneau_victoire_niveau_continuer()

	assert_false(panneau_niveau.visible)
	assert_true(panneau_partage.visible)
	assert_eq(continuations, [])

	menu._on_panneau_partage_performances_fermer()

	assert_false(panneau_partage.visible)
	assert_eq(continuations, [true])

func test_fin_de_campagne_affiche_le_partage_avant_les_statistiques() -> void:
	var menu: MessagesCampagne = add_child_autofree(SCENE_MESSAGES_CAMPAGNE.instantiate())
	var panneau_partage: Control = menu.get_node("Centrer/PanneauPartagePerformances")
	var panneau_campagne: Control = menu.get_node("Centrer/PanneauVictoireCampagne")

	panneau_campagne.show()
	await menu._on_panneau_victoire_campagne_continuer()

	assert_false(panneau_campagne.visible)
	assert_true(panneau_partage.visible)
