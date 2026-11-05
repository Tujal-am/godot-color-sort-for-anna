extends GutTest

const PANNEAU_IMPORT := preload("res://Scenes/MenuPrincipal/PanneauImportFichier/panneau_import_fichier.tscn")

func test_importable_exige_un_joueur_et_une_campagne_complete() -> void:
	var service = get_node("/root/PartagePerformancesImportService")
	var donnees := {
		"joueur": "Joueuse",
		"campagne": {
			"campagne": "campagne_1",
			"niveaux": [{"niveau": "niveau_2", "plateaux": [{"nom": "P1"}]}]
		}
	}

	assert_true(service._fichier_est_exploitable(donnees))
	assert_false(service._fichier_est_exploitable({"joueur": " ", "campagne": donnees["campagne"]}))
	assert_false(service._fichier_est_exploitable({"joueur": "Joueuse", "campagne": {"campagne": "campagne_1"}}))
	assert_false(service._fichier_est_exploitable({
		"joueur": "Joueuse",
		"campagne": {"campagne": "campagne_1", "niveaux": [{"niveau": "niveau_1", "plateaux": [1]}]}
	}))

func test_panneau_import_affiche_les_noms_et_emet_les_actions() -> void:
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
