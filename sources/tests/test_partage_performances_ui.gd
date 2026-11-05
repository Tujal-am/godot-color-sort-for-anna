extends GutTest

const SCENE_PARTAGE = preload("res://Scenes/MenuPrincipal/Campagne/PartagePerformances/partage_performances_ui.tscn")

func test_afficher_export_presente_le_joueur_la_campagne_et_le_dernier_niveau() -> void:
	var panneau: PartagePerformancesUI = add_child_autofree(SCENE_PARTAGE.instantiate())
	var sauvegarde_initiale: Dictionary = SauvegardeBddJoueursService._sauvegarde_joueur.duplicate(true)
	var fichier_initial: String = SauvegardeBddJoueursService.fichier_sauvegarde
	SauvegardeBddJoueursService._sauvegarde_joueur = {
		"nom": "Joueuse",
		"enregistrement_campagne": [{
			"campagne": "campagne_test",
			"niveaux": [{"niveau": "niveau_3", "plateaux": []}]
		}]
	}
	SauvegardeBddJoueursService.fichier_sauvegarde = "test"
	var donnees := {
		"joueur": "Joueuse",
		"campagne": {"campagne": "campagne_test", "niveaux": [{"niveau": "niveau_3"}]}
	}
	panneau.afficher_export(donnees)

	assert_true(panneau.visible)
	assert_eq(panneau.get_node("Panneau/Contenu/NomJoueur").text, "Joueur : Joueuse")
	assert_eq(panneau.get_node("Panneau/Contenu/NomCampagne").text, "Campagne : Campagne Test")
	assert_eq(panneau.get_node("Panneau/Contenu/NomNiveau").text, "Dernier niveau : Niveau 3")
	assert_eq(panneau.get_node("Panneau/Contenu/AdresseCourriel").text, "rangelescouleurspouranna@gmail.com")
	assert_false(panneau.get_node("Panneau/Contenu/Message").visible)
	SauvegardeBddJoueursService._sauvegarde_joueur = sauvegarde_initiale
	SauvegardeBddJoueursService.fichier_sauvegarde = fichier_initial

func test_bouton_copier_courriel_copie_l_adresse_et_confirme() -> void:
	var panneau: PartagePerformancesUI = add_child_autofree(SCENE_PARTAGE.instantiate())

	panneau._on_bouton_copier_courriel_pressed()

	assert_true(panneau.get_node("Panneau/Contenu/Message").visible)
	if DisplayServer.has_feature(DisplayServer.FEATURE_CLIPBOARD):
		assert_eq(DisplayServer.clipboard_get(), "rangelescouleurspouranna@gmail.com")
		assert_eq(
			panneau.get_node("Panneau/Contenu/Message").text,
			"Adresse courriel copiée dans le presse-papiers."
		)
	else:
		assert_eq(
			panneau.get_node("Panneau/Contenu/Message").text,
			"La copie dans le presse-papiers n'est pas disponible."
		)

func test_bouton_retour_masque_le_panneau_et_emet_fermer() -> void:
	var panneau: PartagePerformancesUI = add_child_autofree(SCENE_PARTAGE.instantiate())
	var fermetures := [0]
	panneau.fermer.connect(func() -> void: fermetures[0] += 1)
	panneau.show()

	panneau._on_bouton_retour_statistiques_pressed()

	assert_false(panneau.visible)
	assert_eq(fermetures[0], 1)
