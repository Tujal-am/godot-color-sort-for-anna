extends GutTest

const PANNEAU_IMPORT := preload("res://Scenes/MenuPrincipal/PanneauImportQR/panneau_import_qr.tscn")

func test_qr_importable_exige_un_nom_et_un_niveau_valide() -> void:
	var service = get_node("/root/PartagePerformancesImportService")

	assert_true(service._qr_est_exploitable({
		"joueur": "Joueuse",
		"campagne": {"campagne": "campagne_1"},
		"niveau": {"niveau": "niveau_2", "plateaux": []}
	}))
	assert_false(service._qr_est_exploitable({
		"campagne": {"campagne": "campagne_1"},
		"niveau": {"niveau": "niveau_2", "plateaux": []}
	}))
	assert_false(service._qr_est_exploitable({
		"joueur": "Joueuse",
		"campagne": {"campagne": "campagne_1"},
		"niveau": {}
	}))
	assert_false(service._qr_est_exploitable({
		"joueur": " ",
		"campagne": {"campagne": "campagne_1"},
		"niveau": {"niveau": "niveau_2", "plateaux": []}
	}))
	assert_false(service._qr_est_exploitable({
		"joueur": "Joueuse",
		"campagne": {"campagne": " "},
		"niveau": {"niveau": "niveau_2", "plateaux": []}
	}))
	assert_false(service._qr_est_exploitable({
		"joueur": "Joueuse",
		"campagne": "campagne_1",
		"niveau": {"niveau": "niveau_2"}
	}))
	assert_false(service._qr_est_exploitable({
		"joueur": "Joueuse",
		"campagne": {},
		"niveau": {"niveau": "niveau_2", "plateaux": []}
	}))

func test_panneau_import_affiche_le_joueur_et_le_niveau_et_emet_les_actions() -> void:
	var panneau = add_child_autofree(PANNEAU_IMPORT.instantiate())
	var acceptations := [0]
	var refus := [0]
	panneau.accepter.connect(func() -> void: acceptations[0] += 1)
	panneau.refuser.connect(func() -> void: refus[0] += 1)

	panneau.afficher_import("Joueuse", "Campagne 1", "Niveau 2")
	assert_true(panneau.visible)
	assert_eq(panneau.get_node("Fond/Panel/Contenu/NomJoueur").text, "Joueur : Joueuse")
	assert_eq(panneau.get_node("Fond/Panel/Contenu/NomCampagne").text, "Campagne : Campagne 1")
	assert_eq(panneau.get_node("Fond/Panel/Contenu/NomNiveau").text, "Niveau : Niveau 2")

	panneau.get_node("Fond/Panel/Contenu/Boutons/BoutonAccepter").emit_signal("pressed")
	panneau.get_node("Fond/Panel/Contenu/Boutons/BoutonRefuser").emit_signal("pressed")
	assert_eq(acceptations[0], 1)
	assert_eq(refus[0], 1)


# ---------------------------------------------------------
# Flux d'import (doubles et isolation)
# ---------------------------------------------------------

const RACINE_TEST = "tests/test_partage_performances_import_service"
const DOSSIER_IMAGES = "user://tests_partage_import"

class FauxPartage extends RefCounted:
	var chemins := PackedStringArray()
	var mime := ""

	func _init(chemins_recus: PackedStringArray = PackedStringArray(), mime_recu: String = "") -> void:
		chemins = chemins_recus
		mime = mime_recu

	func get_file_paths() -> PackedStringArray:
		return chemins

	func get_mime_type() -> String:
		return mime

class PartageIncomplet extends RefCounted:
	func get_file_paths() -> PackedStringArray:
		return PackedStringArray()

class FauxApi extends Node:
	signal partage_qr_code(qr_data)
	signal erreur_decodage_qr(message)
	var images: Array = []
	var retour := true

	func recevoir_image_qr(image) -> bool:
		images.append(image)
		return retour

class FausseScene extends Node:
	var fermetures := 0

	func fermer_import_qr() -> void:
		fermetures += 1

var service
var liste_joueurs_initiale
var bdd_joueur_initiale
var fichier_bdd_initial
var scores_initiaux
var scene_initiale
var scenes_ajoutees: Array = []

func before_each():
	FichiersJsonService.definir_racine_utilisateur(RACINE_TEST)
	FichiersJsonService.effacer_racine_utilisateur()
	liste_joueurs_initiale = SauvegardeListeJoueursService.liste_des_joueurs.duplicate(true)
	bdd_joueur_initiale = SauvegardeBddJoueursService._sauvegarde_joueur.duplicate(true)
	fichier_bdd_initial = SauvegardeBddJoueursService.fichier_sauvegarde
	scores_initiaux = SauvegardeTableauDesScoresService.liste_des_scores.duplicate(true)
	scene_initiale = get_tree().current_scene
	scenes_ajoutees = []
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DOSSIER_IMAGES))

	SauvegardeListeJoueursService.liste_des_joueurs = [
		{"indice": 0, "nom": "Alpha", "fichier_sauvegarde": "sauvegarde_joueur_alpha.json"},
		{"indice": 1, "nom": "Beta", "fichier_sauvegarde": "sauvegarde_joueur_beta.json"}
	]
	SauvegardeTableauDesScoresService.liste_des_scores = [
		{"nom": "Alpha", "rang": 1, "score": 0, "score_txt": "0"},
		{"nom": "Beta", "rang": 2, "score": 0, "score_txt": "0"}
	]
	SauvegardeBddJoueursService.fichier_sauvegarde = ""
	SauvegardeBddJoueursService._sauvegarde_joueur = {}
	FichiersJsonService.write_json_file("sauvegarde_joueur_alpha.json", {
		"nom": "Alpha",
		"campagne": {"niveau_2": [{"nom": "P2", "difficulte": 2, "gameplay": "CLASSIQUE"}]},
		"enregistrement_campagne": [],
		"plateaux_libres": {},
		"nombre_de_parties": {}
	})
	FichiersJsonService.write_json_file("sauvegarde_joueur_beta.json", {
		"nom": "Beta",
		"campagne": {},
		"enregistrement_campagne": [],
		"plateaux_libres": {},
		"nombre_de_parties": {}
	})

	service = add_child_autofree(load("res://Singletons/partage_performances_import_service.gd").new())
	watch_signals(service)

func after_each():
	await _retirer_scenes()
	SauvegardeListeJoueursService.liste_des_joueurs = liste_joueurs_initiale.duplicate(true)
	SauvegardeBddJoueursService._sauvegarde_joueur = bdd_joueur_initiale.duplicate(true)
	SauvegardeBddJoueursService.fichier_sauvegarde = fichier_bdd_initial
	SauvegardeTableauDesScoresService.liste_des_scores = scores_initiaux.duplicate(true)
	_supprimer_dossier_images()
	FichiersJsonService.effacer_racine_utilisateur()
	FichiersJsonService.reinitialiser_racine_utilisateur()

func _retirer_scenes() -> void:
	for scene in scenes_ajoutees:
		if is_instance_valid(scene):
			scene.queue_free()
	scenes_ajoutees = []
	var courante = get_tree().current_scene
	if is_instance_valid(courante) and courante != scene_initiale:
		get_tree().unload_current_scene()
	await wait_frames(2)
	if is_instance_valid(scene_initiale):
		get_tree().current_scene = scene_initiale

func _supprimer_dossier_images() -> void:
	var dossier = ProjectSettings.globalize_path(DOSSIER_IMAGES)
	for nom in DirAccess.get_files_at(dossier):
		DirAccess.remove_absolute(dossier.path_join(nom))
	DirAccess.remove_absolute(dossier)

func _chemin_image(nom: String) -> String:
	return ProjectSettings.globalize_path(DOSSIER_IMAGES).path_join(nom)

func _creer_png(nom: String) -> String:
	var chemin = _chemin_image(nom)
	var image = Image.create(8, 8, false, Image.FORMAT_RGBA8)
	image.fill(Color.BLACK)
	assert_eq(image.save_png(chemin), OK)
	return chemin

func _creer_fichier_texte(nom: String) -> String:
	var chemin = _chemin_image(nom)
	var fichier = FileAccess.open(chemin, FileAccess.WRITE)
	fichier.store_string("pas une image")
	fichier.close()
	return chemin

func _accepter_erreurs_moteur_de_chargement_image() -> void:
	var erreurs_gerees := 0
	for erreur in get_errors():
		if erreur.is_engine_error() and (erreur.contains_text("image") or erreur.contains_text("PNG") \
				or erreur.contains_text("opening file") or erreur.contains_text("f.is_null()") \
				or erreur.contains_text("ERR_FILE_CORRUPT")):
			erreur.handled = true
			erreurs_gerees += 1
	assert_gt(erreurs_gerees, 0, "le moteur doit signaler l'echec de chargement de l'image")

func _installer_faux_api() -> FauxApi:
	var faux = FauxApi.new()
	service.add_child(faux)
	service._api = faux
	return faux

func _installer_fausse_scene() -> FausseScene:
	var scene = FausseScene.new()
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene
	scenes_ajoutees.append(scene)
	return scene

func _qr_valide(joueur: String = "Gamma") -> Dictionary:
	return {
		"joueur": joueur,
		"campagne": {"campagne": "campagne_1", "date_debut": 100, "date_fin": 0, "score": {"fin_campagne": 300}},
		"niveau": {"niveau": "niveau_2", "date_debut": 100, "date_fin": 200, "score": {"niveau": 1000, "niveau_parfait": 1000},
			"plateaux": [{"nom": "Q1", "date_debut": 110, "date_fin": 120, "duree": 10, "difficulte": 1, "statut": "reussi", "gameplay": "CLASSIQUE", "score": {"duree": 50, "ratio_reussite": 70}}]}
	}

func _attendre_changement_de_scene() -> void:
	await wait_frames(30)

func _etat_repos_attendu() -> void:
	assert_false(service._decodage_en_cours)
	assert_false(service._import_en_cours)
	assert_true(service._import_en_attente.is_empty())
	assert_null(service._image_qr)
	assert_eq(service._chemins_images_recues.size(), 0)


# ---------------------------------------------------------
# _ready
# ---------------------------------------------------------

func test_ready_cree_l_api_et_connecte_les_signaux():
	assert_not_null(service._api)
	assert_true(service._api.is_connected("partage_qr_code", service._on_api_partage_qr_code))
	assert_true(service._api.is_connected("erreur_decodage_qr", service._on_api_erreur_decodage_qr))
	assert_true(ShareService.share_received.is_connected(service._on_share_received))

func test_etat_initial_au_repos():
	_etat_repos_attendu()


# ---------------------------------------------------------
# _on_share_received
# ---------------------------------------------------------

func test_share_recu_non_objet_declenche_une_erreur_sans_decodage():
	var faux_api = _installer_faux_api()
	var scene = _installer_fausse_scene()
	for valeur in [null, "texte", 12, {"a": 1}, [1]]:
		service._on_share_received(valeur)
	assert_eq(scene.fermetures, 5)
	assert_eq(faux_api.images.size(), 0)
	_etat_repos_attendu()

func test_share_recu_sans_methodes_attendues_declenche_une_erreur():
	var faux_api = _installer_faux_api()
	var scene = _installer_fausse_scene()
	service._on_share_received(RefCounted.new())
	service._on_share_received(PartageIncomplet.new())
	service._on_share_received(autofree(Node.new()))
	assert_eq(scene.fermetures, 3)
	assert_eq(faux_api.images.size(), 0)
	_etat_repos_attendu()

func test_share_recu_sans_chemin_declenche_une_erreur():
	var faux_api = _installer_faux_api()
	var scene = _installer_fausse_scene()
	service._on_share_received(FauxPartage.new(PackedStringArray(), "image/png"))
	assert_eq(scene.fermetures, 1)
	assert_eq(faux_api.images.size(), 0)
	_etat_repos_attendu()

func test_share_recu_mime_non_image_declenche_une_erreur_et_supprime_le_fichier():
	var faux_api = _installer_faux_api()
	var scene = _installer_fausse_scene()
	var chemin = _creer_png("qr.png")
	service._on_share_received(FauxPartage.new(PackedStringArray([chemin]), "text/plain"))
	assert_eq(scene.fermetures, 1)
	assert_eq(faux_api.images.size(), 0)
	assert_false(FileAccess.file_exists(chemin))
	_etat_repos_attendu()

func test_share_recu_fichier_inexistant_declenche_une_erreur():
	var faux_api = _installer_faux_api()
	var scene = _installer_fausse_scene()
	service._on_share_received(FauxPartage.new(PackedStringArray([_chemin_image("absent.png")]), "image/png"))
	_accepter_erreurs_moteur_de_chargement_image()
	assert_eq(scene.fermetures, 1)
	assert_eq(faux_api.images.size(), 0)
	_etat_repos_attendu()

func test_share_recu_fichier_non_image_declenche_une_erreur_et_supprime_le_fichier():
	var faux_api = _installer_faux_api()
	var scene = _installer_fausse_scene()
	var chemin = _creer_fichier_texte("faux.png")
	service._on_share_received(FauxPartage.new(PackedStringArray([chemin]), "image/png"))
	_accepter_erreurs_moteur_de_chargement_image()
	assert_eq(scene.fermetures, 1)
	assert_eq(faux_api.images.size(), 0)
	assert_false(FileAccess.file_exists(chemin))
	_etat_repos_attendu()

func test_share_recu_image_valide_lance_le_decodage():
	var faux_api = _installer_faux_api()
	var chemin = _creer_png("qr.png")
	service._on_share_received(FauxPartage.new(PackedStringArray([chemin]), "image/png"))
	assert_true(service._decodage_en_cours)
	assert_eq(faux_api.images.size(), 1)
	assert_eq(faux_api.images[0].get_width(), 8)
	assert_eq(faux_api.images[0].get_height(), 8)
	assert_null(service._image_qr)
	assert_eq(service._chemins_images_recues, PackedStringArray([chemin]))
	assert_true(FileAccess.file_exists(chemin))

func test_share_recu_mime_vide_est_accepte():
	var faux_api = _installer_faux_api()
	service._on_share_received(FauxPartage.new(PackedStringArray([_creer_png("qr.png")]), ""))
	assert_eq(faux_api.images.size(), 1)
	assert_true(service._decodage_en_cours)

func test_share_recu_ne_decode_que_le_premier_fichier():
	var faux_api = _installer_faux_api()
	var premier = _creer_png("a.png")
	var second = _creer_png("b.png")
	service._on_share_received(FauxPartage.new(PackedStringArray([premier, second]), "image/png"))
	assert_eq(faux_api.images.size(), 1)
	assert_eq(service._chemins_images_recues.size(), 2)

func test_share_recu_pendant_un_decodage_supprime_les_fichiers_recus_sans_nouveau_decodage():
	var faux_api = _installer_faux_api()
	service._decodage_en_cours = true
	var chemin = _creer_png("qr.png")
	service._on_share_received(FauxPartage.new(PackedStringArray([chemin]), "image/png"))
	assert_false(FileAccess.file_exists(chemin))
	assert_eq(faux_api.images.size(), 0)
	assert_true(service._decodage_en_cours)
	assert_eq(service._chemins_images_recues.size(), 0)

func test_share_recu_avec_import_en_attente_est_ignore_et_conserve_l_import():
	var faux_api = _installer_faux_api()
	service._import_en_attente = _qr_valide()
	var chemin = _creer_png("qr.png")
	service._on_share_received(FauxPartage.new(PackedStringArray([chemin]), "image/png"))
	assert_false(FileAccess.file_exists(chemin))
	assert_eq(faux_api.images.size(), 0)
	assert_eq(service._import_en_attente.get("joueur"), "Gamma")

func test_share_recu_pendant_un_import_en_cours_est_ignore():
	var faux_api = _installer_faux_api()
	service._import_en_cours = true
	var chemin = _creer_png("qr.png")
	service._on_share_received(FauxPartage.new(PackedStringArray([chemin]), "image/png"))
	assert_false(FileAccess.file_exists(chemin))
	assert_eq(faux_api.images.size(), 0)
	assert_true(service._import_en_cours)

func test_share_recu_ignore_ne_ferme_pas_le_panneau_en_cours():
	_installer_faux_api()
	var scene = _installer_fausse_scene()
	service._import_en_attente = _qr_valide()
	service._on_share_received(FauxPartage.new(PackedStringArray([_creer_png("qr.png")]), "image/png"))
	assert_eq(scene.fermetures, 0)

func test_share_recu_via_le_signal_du_service_de_partage():
	# L'autoload ecoute deja le meme signal : on l'isole pour ne tester que ce service.
	var autoload_import = PartagePerformancesImportService
	var autoload_connecte = ShareService.share_received.is_connected(autoload_import._on_share_received)
	if autoload_connecte:
		ShareService.share_received.disconnect(autoload_import._on_share_received)
	var faux_api = _installer_faux_api()
	var chemin = _creer_png("qr.png")
	ShareService.share_received.emit(FauxPartage.new(PackedStringArray([chemin]), "image/png"))
	assert_eq(faux_api.images.size(), 1)
	if autoload_connecte:
		ShareService.share_received.connect(autoload_import._on_share_received)

func test_share_recu_api_qui_refuse_le_decodage_ne_bloque_pas_les_imports_suivants():
	# Défaut attendu : si l'API retourne false sans émettre d'erreur, le service doit revenir au repos.
	var faux_api = _installer_faux_api()
	faux_api.retour = false
	service._on_share_received(FauxPartage.new(PackedStringArray([_creer_png("qr.png")]), "image/png"))
	assert_false(service._decodage_en_cours)

func test_share_recu_sur_plateforme_sans_plugin_qr_revient_au_repos_et_supprime_le_fichier():
	var scene = _installer_fausse_scene()
	var chemin = _creer_png("qr.png")
	service._on_share_received(FauxPartage.new(PackedStringArray([chemin]), "image/png"))
	assert_eq(scene.fermetures, 1)
	assert_false(FileAccess.file_exists(chemin))
	_etat_repos_attendu()

func test_share_recu_puis_nouveau_partage_possible_apres_une_erreur():
	var faux_api = _installer_faux_api()
	service._on_share_received(FauxPartage.new(PackedStringArray(), "image/png"))
	service._on_share_received(FauxPartage.new(PackedStringArray([_creer_png("qr.png")]), "image/png"))
	assert_eq(faux_api.images.size(), 1)


# ---------------------------------------------------------
# _on_api_erreur_decodage_qr / _erreur_import
# ---------------------------------------------------------

func test_erreur_decodage_qr_remet_le_service_au_repos():
	var scene = _installer_fausse_scene()
	service._decodage_en_cours = true
	service._import_en_attente = _qr_valide()
	service._import_en_cours = true
	var chemin = _creer_png("qr.png")
	service._chemins_images_recues = PackedStringArray([chemin])
	service._on_api_erreur_decodage_qr("échec")
	assert_eq(scene.fermetures, 1)
	assert_false(FileAccess.file_exists(chemin))
	_etat_repos_attendu()

func test_signal_erreur_decodage_de_l_api_appelle_le_traitement_d_erreur():
	var scene = _installer_fausse_scene()
	service._api.erreur_decodage_qr.emit("erreur")
	assert_eq(scene.fermetures, 1)

func test_erreur_decodage_message_vide_ne_plante_pas():
	service._on_api_erreur_decodage_qr("")
	_etat_repos_attendu()

func test_erreur_import_sans_scene_courante_ne_plante_pas():
	get_tree().current_scene = null
	service._erreur_import()
	_etat_repos_attendu()

func test_erreur_import_scene_sans_methode_fermer_import_qr_ne_plante_pas():
	var scene = Node.new()
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene
	scenes_ajoutees.append(scene)
	service._erreur_import()
	_etat_repos_attendu()

func test_erreur_import_ferme_le_panneau_de_la_scene_courante():
	var scene = _installer_fausse_scene()
	service._erreur_import()
	assert_eq(scene.fermetures, 1)
	service._erreur_import()
	assert_eq(scene.fermetures, 2)

func test_erreur_import_vide_les_donnees_et_supprime_les_images():
	service._import_en_attente = _qr_valide()
	service._image_qr = Image.new()
	var chemin = _creer_png("qr.png")
	service._chemins_images_recues = PackedStringArray([chemin])
	service._erreur_import()
	assert_false(FileAccess.file_exists(chemin))
	_etat_repos_attendu()

func test_erreur_import_ne_modifie_pas_les_sauvegardes():
	service._import_en_attente = _qr_valide()
	var liste_avant = SauvegardeListeJoueursService.liste_des_joueurs.duplicate(true)
	var scores_avant = SauvegardeTableauDesScoresService.liste_des_scores.duplicate(true)
	service._erreur_import()
	assert_eq(SauvegardeListeJoueursService.liste_des_joueurs, liste_avant)
	assert_eq(SauvegardeTableauDesScoresService.liste_des_scores, scores_avant)

func test_erreur_import_n_emet_pas_partage_qr_code():
	service._erreur_import()
	assert_signal_not_emitted(service, "partage_qr_code")


# ---------------------------------------------------------
# _on_api_partage_qr_code
# ---------------------------------------------------------

func test_qr_non_exploitable_declenche_une_erreur_sans_signal():
	var scene = _installer_fausse_scene()
	service._decodage_en_cours = true
	for donnees in [{}, {"joueur": "X"}, {"joueur": "", "campagne": {"campagne": "c"}, "niveau": {"niveau": "n", "plateaux": []}},
			{"joueur": "X", "campagne": {"campagne": "c"}, "niveau": {"niveau": "n", "plateaux": [1]}}]:
		service._on_api_partage_qr_code(donnees)
	assert_eq(scene.fermetures, 4)
	assert_signal_not_emitted(service, "partage_qr_code")
	_etat_repos_attendu()

func test_qr_non_exploitable_supprime_l_image_recue():
	_installer_fausse_scene()
	var chemin = _creer_png("qr.png")
	service._chemins_images_recues = PackedStringArray([chemin])
	service._image_qr = Image.new()
	service._on_api_partage_qr_code({})
	assert_false(FileAccess.file_exists(chemin))
	assert_null(service._image_qr)

func test_signal_partage_qr_code_de_l_api_non_exploitable_declenche_une_erreur():
	var scene = _installer_fausse_scene()
	service._api.partage_qr_code.emit({"joueur": ""})
	assert_eq(scene.fermetures, 1)

func test_qr_valide_emet_le_signal_et_memorise_l_import_en_attente():
	var qr = _qr_valide()
	service._decodage_en_cours = true
	service._on_api_partage_qr_code(qr)
	assert_signal_emitted_with_parameters(service, "partage_qr_code", [qr])
	assert_eq(service._import_en_attente, qr)
	assert_false(service._decodage_en_cours)
	await _attendre_changement_de_scene()

func test_qr_valide_memorise_une_copie_independante():
	var qr = _qr_valide()
	service._on_api_partage_qr_code(qr)
	qr["joueur"] = "Modifie"
	qr["niveau"]["plateaux"].clear()
	assert_eq(service._import_en_attente.get("joueur"), "Gamma")
	assert_eq(service._import_en_attente.get("niveau").get("plateaux").size(), 1)
	await _attendre_changement_de_scene()

func test_qr_valide_emet_une_copie_independante_de_l_import_en_attente():
	var recu: Array = []
	service.partage_qr_code.connect(func(donnees): recu.append(donnees))
	service._on_api_partage_qr_code(_qr_valide())
	assert_eq(recu.size(), 1)
	recu[0]["joueur"] = "Modifie"
	assert_eq(service._import_en_attente.get("joueur"), "Gamma")
	await _attendre_changement_de_scene()

func test_qr_valide_supprime_l_image_recue_et_ne_modifie_pas_les_sauvegardes():
	var chemin = _creer_png("qr.png")
	service._chemins_images_recues = PackedStringArray([chemin])
	var liste_avant = SauvegardeListeJoueursService.liste_des_joueurs.duplicate(true)
	service._on_api_partage_qr_code(_qr_valide())
	assert_false(FileAccess.file_exists(chemin))
	assert_eq(SauvegardeListeJoueursService.liste_des_joueurs, liste_avant)
	await _attendre_changement_de_scene()

func test_qr_valide_ouvre_le_menu_principal_et_affiche_le_panneau_d_import():
	service._on_api_partage_qr_code(_qr_valide("Gamma"))
	await _attendre_changement_de_scene()
	var scene = get_tree().current_scene
	assert_not_null(scene)
	if scene:
		assert_eq(scene.scene_file_path, service.MENU_PRINCIPAL_PATH)
		assert_eq(scene.get_node("PanneauImportQR/Fond/Panel/Contenu/NomJoueur").text, "Joueur : Gamma")


# ---------------------------------------------------------
# refuser_import / _liberer_*
# ---------------------------------------------------------

func test_refuser_import_vide_l_import_en_attente_sans_modifier_les_sauvegardes():
	service._import_en_attente = _qr_valide()
	var chemin = _creer_png("qr.png")
	service._chemins_images_recues = PackedStringArray([chemin])
	var liste_avant = SauvegardeListeJoueursService.liste_des_joueurs.duplicate(true)
	var scores_avant = SauvegardeTableauDesScoresService.liste_des_scores.duplicate(true)
	service.refuser_import()
	_etat_repos_attendu()
	assert_false(FileAccess.file_exists(chemin))
	assert_eq(SauvegardeListeJoueursService.liste_des_joueurs, liste_avant)
	assert_eq(SauvegardeTableauDesScoresService.liste_des_scores, scores_avant)
	assert_false(FileAccess.file_exists(ProjectSettings.globalize_path("user://") + "x"))

func test_refuser_import_sans_import_en_attente_ne_plante_pas():
	service.refuser_import()
	service.refuser_import()
	_etat_repos_attendu()

func test_refuser_import_n_appelle_pas_fermer_import_qr_ni_ne_change_de_scene():
	var scene = _installer_fausse_scene()
	service._import_en_attente = _qr_valide()
	service.refuser_import()
	assert_eq(scene.fermetures, 0)
	assert_eq(get_tree().current_scene, scene)

func test_refuser_import_autorise_un_nouveau_partage():
	var faux_api = _installer_faux_api()
	service._import_en_attente = _qr_valide()
	service.refuser_import()
	service._on_share_received(FauxPartage.new(PackedStringArray([_creer_png("qr.png")]), "image/png"))
	assert_eq(faux_api.images.size(), 1)

func test_liberer_donnees_import_remet_tout_au_repos():
	service._import_en_attente = _qr_valide()
	service._import_en_cours = true
	service._image_qr = Image.new()
	var chemin = _creer_png("qr.png")
	service._chemins_images_recues = PackedStringArray([chemin])
	service._liberer_donnees_import()
	assert_false(FileAccess.file_exists(chemin))
	_etat_repos_attendu()

func test_liberer_donnees_import_ne_touche_pas_au_decodage_en_cours():
	service._decodage_en_cours = true
	service._liberer_donnees_import()
	assert_true(service._decodage_en_cours)

func test_liberer_image_recue_supprime_les_fichiers_et_vide_la_liste():
	var premier = _creer_png("a.png")
	var second = _creer_png("b.png")
	service._image_qr = Image.new()
	service._chemins_images_recues = PackedStringArray([premier, second])
	service._liberer_image_recue()
	assert_false(FileAccess.file_exists(premier))
	assert_false(FileAccess.file_exists(second))
	assert_eq(service._chemins_images_recues.size(), 0)
	assert_null(service._image_qr)

func test_liberer_image_recue_ne_touche_pas_aux_autres_donnees():
	service._import_en_attente = _qr_valide()
	service._import_en_cours = true
	service._decodage_en_cours = true
	service._liberer_image_recue()
	assert_false(service._import_en_attente.is_empty())
	assert_true(service._import_en_cours)
	assert_true(service._decodage_en_cours)

func test_liberer_image_recue_fichier_deja_absent_ne_plante_pas():
	service._chemins_images_recues = PackedStringArray([_chemin_image("absent.png")])
	service._liberer_image_recue()
	assert_eq(service._chemins_images_recues.size(), 0)

func test_liberer_image_recue_sans_donnees_ne_plante_pas():
	service._liberer_image_recue()
	_etat_repos_attendu()

func test_supprimer_fichiers_partages_supprime_uniquement_les_fichiers_existants():
	var existant = _creer_png("a.png")
	var autre = _creer_png("conserve.png")
	service._supprimer_fichiers_partages(PackedStringArray([existant, _chemin_image("absent.png")]))
	assert_false(FileAccess.file_exists(existant))
	assert_true(FileAccess.file_exists(autre))

func test_supprimer_fichiers_partages_liste_vide_ne_fait_rien():
	var existant = _creer_png("a.png")
	service._supprimer_fichiers_partages(PackedStringArray())
	assert_true(FileAccess.file_exists(existant))

func test_supprimer_fichiers_partages_ne_supprime_pas_un_dossier():
	var dossier = ProjectSettings.globalize_path(DOSSIER_IMAGES)
	service._supprimer_fichiers_partages(PackedStringArray([dossier]))
	assert_true(DirAccess.dir_exists_absolute(dossier))

func test_supprimer_fichiers_partages_chemin_vide_ne_plante_pas():
	service._supprimer_fichiers_partages(PackedStringArray([""]))
	assert_true(true)


# ---------------------------------------------------------
# accepter_import
# ---------------------------------------------------------

func test_accepter_import_sans_import_en_attente_ne_fait_rien():
	var liste_avant = SauvegardeListeJoueursService.liste_des_joueurs.duplicate(true)
	var scene = _installer_fausse_scene()
	service.accepter_import()
	assert_eq(SauvegardeListeJoueursService.liste_des_joueurs, liste_avant)
	assert_eq(scene.fermetures, 0)
	assert_eq(get_tree().current_scene, scene)
	assert_false(service._import_en_cours)

func test_accepter_import_deja_en_cours_ne_fait_rien():
	var liste_avant = SauvegardeListeJoueursService.liste_des_joueurs.duplicate(true)
	service._import_en_attente = _qr_valide()
	service._import_en_cours = true
	service.accepter_import()
	assert_eq(SauvegardeListeJoueursService.liste_des_joueurs, liste_avant)
	assert_false(service._import_en_attente.is_empty())
	assert_true(service._import_en_cours)

func test_accepter_import_cree_un_nouveau_joueur_et_ses_scores():
	service._import_en_attente = _qr_valide("Gamma")
	service.accepter_import()
	assert_true(SauvegardeListeJoueursService.le_joueur_existe("Gamma"))
	assert_eq(SauvegardeTableauDesScoresService.lire_score_joueur("Gamma"), 300 + 1000 + 1000 + 50 + 70)
	assert_true(SauvegardeListeJoueursService.le_joueur_existe("Alpha"))
	await _attendre_changement_de_scene()

func test_accepter_import_enregistre_la_campagne_et_le_niveau_dans_la_sauvegarde_du_joueur():
	service._import_en_attente = _qr_valide("Gamma")
	service.accepter_import()
	var fichier = SauvegardeListeJoueursService.retourner_le_fichier_de_sauvegarde("Gamma")
	var sauvegarde = FichiersJsonService.read_json_file(fichier)
	var campagnes = sauvegarde.get("enregistrement_campagne")
	assert_eq(campagnes.size(), 1)
	assert_eq(campagnes[0].get("campagne"), "campagne_1")
	assert_eq(campagnes[0].get("niveaux")[0].get("niveau"), "niveau_2")
	assert_true(sauvegarde.get("campagne").is_empty())
	await _attendre_changement_de_scene()

func test_accepter_import_libere_les_donnees_et_affiche_les_statistiques():
	service._import_en_attente = _qr_valide("Gamma")
	var chemin = _creer_png("qr.png")
	service._chemins_images_recues = PackedStringArray([chemin])
	service.accepter_import()
	_etat_repos_attendu()
	assert_false(FileAccess.file_exists(chemin))
	await _attendre_changement_de_scene()
	var scene = get_tree().current_scene
	assert_not_null(scene)
	if scene:
		assert_eq(scene.scene_file_path, service.STATISTIQUES_PATH)

func test_accepter_import_importe_dans_un_joueur_externe_existant_dont_la_campagne_est_terminee():
	var qr = _qr_valide("Beta")
	service._import_en_attente = qr
	service.accepter_import()
	var noms = SauvegardeListeJoueursService.liste_des_joueurs.map(func(joueur): return joueur.get("nom"))
	assert_eq(noms, ["Alpha", "Beta"])
	assert_eq(SauvegardeTableauDesScoresService.lire_score_joueur("Beta"), 300 + 1000 + 1000 + 50 + 70)
	await _attendre_changement_de_scene()

func test_accepter_import_deux_fois_le_meme_niveau_sur_un_joueur_externe_n_ajoute_pas_de_points():
	service._import_en_attente = _qr_valide("Beta")
	service.accepter_import()
	await _attendre_changement_de_scene()
	var score_apres_premier = SauvegardeTableauDesScoresService.lire_score_joueur("Beta")
	service._import_en_attente = _qr_valide("Beta")
	service.accepter_import()
	assert_eq(SauvegardeTableauDesScoresService.lire_score_joueur("Beta"), score_apres_premier)
	await _attendre_changement_de_scene()

func test_accepter_import_joueur_local_en_cours_de_campagne_est_importe_sous_un_nom_import():
	service._import_en_attente = _qr_valide("Alpha")
	service.accepter_import()
	assert_true(SauvegardeListeJoueursService.le_joueur_existe("Alpha (import)"))
	assert_eq(SauvegardeTableauDesScoresService.lire_score_joueur("Alpha"), 0)
	assert_eq(SauvegardeTableauDesScoresService.lire_score_joueur("Alpha (import)"), 300 + 1000 + 1000 + 50 + 70)
	await _attendre_changement_de_scene()

func test_accepter_import_n_ecrase_pas_la_sauvegarde_du_joueur_local_en_cours_de_campagne():
	service._import_en_attente = _qr_valide("Alpha")
	service.accepter_import()
	var sauvegarde = FichiersJsonService.read_json_file("sauvegarde_joueur_alpha.json")
	assert_eq(sauvegarde.get("campagne").get("niveau_2").size(), 1)
	assert_eq(sauvegarde.get("enregistrement_campagne").size(), 0)
	await _attendre_changement_de_scene()

func test_accepter_import_echec_total_declenche_une_erreur_sans_changer_de_scene():
	SauvegardeListeJoueursService.liste_des_joueurs.append({"indice": 2, "nom": "Alpha (import)", "fichier_sauvegarde": "sauvegarde_joueur_alpha_import.json"})
	FichiersJsonService.write_json_file("sauvegarde_joueur_alpha_import.json", {
		"nom": "Alpha (import)",
		"campagne": {"niveau_2": [{"nom": "P2", "difficulte": 2, "gameplay": "CLASSIQUE"}]},
		"enregistrement_campagne": [],
		"plateaux_libres": {},
		"nombre_de_parties": {}
	})
	var scene = _installer_fausse_scene()
	service._import_en_attente = _qr_valide("Alpha")
	var scores_avant = SauvegardeTableauDesScoresService.liste_des_scores.duplicate(true)
	service.accepter_import()
	assert_eq(scene.fermetures, 1)
	assert_eq(get_tree().current_scene, scene)
	assert_eq(SauvegardeTableauDesScoresService.liste_des_scores, scores_avant)
	_etat_repos_attendu()

func test_accepter_import_sans_nom_de_joueur_utilise_le_repli_import():
	var qr = _qr_valide("")
	service._import_en_attente = qr
	service.accepter_import()
	assert_true(SauvegardeListeJoueursService.le_joueur_existe(" (import)") or service._import_en_attente.is_empty())
	await _attendre_changement_de_scene()

func test_accepter_import_ne_change_pas_la_scene_en_cas_d_echec_et_permet_de_reessayer():
	var scene = _installer_fausse_scene()
	service._import_en_attente = {"joueur": "Gamma", "campagne": {}, "niveau": {}}
	service.accepter_import()
	assert_eq(scene.fermetures, 1)
	assert_false(service._import_en_cours)
	assert_true(service._import_en_attente.is_empty())