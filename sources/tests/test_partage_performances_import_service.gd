extends GutTest

const PANNEAU_IMPORT := preload("res://Scenes/MenuPrincipal/PanneauImportQR/panneau_import_qr.tscn")

func test_qr_importable_exige_un_nom_et_un_niveau_valide() -> void:
	var service = get_node("/root/PartagePerformancesImportService")

	assert_true(service._qr_est_exploitable({
		"nom": "Joueuse",
		"niveau": {"niveau": "niveau_2", "plateaux": []}
	}))
	assert_false(service._qr_est_exploitable({
		"niveau": {"niveau": "niveau_2", "plateaux": []}
	}))
	assert_false(service._qr_est_exploitable({
		"nom": "Joueuse",
		"niveau": {}
	}))
	assert_false(service._qr_est_exploitable({
		"nom": " ",
		"niveau": {"niveau": "niveau_2", "plateaux": []}
	}))
	assert_false(service._qr_est_exploitable({
		"nom": "Joueuse",
		"niveau": {"niveau": "niveau_2"}
	}))

func test_panneau_import_affiche_le_joueur_et_le_niveau_et_emet_les_actions() -> void:
	var panneau = add_child_autofree(PANNEAU_IMPORT.instantiate())
	var acceptations := [0]
	var refus := [0]
	panneau.accepter.connect(func() -> void: acceptations[0] += 1)
	panneau.refuser.connect(func() -> void: refus[0] += 1)

	panneau.afficher_import("Joueuse", "niveau 2")
	assert_true(panneau.visible)
	assert_eq(panneau.get_node("Fond/Panel/Contenu/NomJoueur").text, "Joueur : Joueuse")
	assert_eq(panneau.get_node("Fond/Panel/Contenu/NomNiveau").text, "Niveau : niveau 2")

	panneau.get_node("Fond/Panel/Contenu/Boutons/BoutonAccepter").emit_signal("pressed")
	panneau.get_node("Fond/Panel/Contenu/Boutons/BoutonRefuser").emit_signal("pressed")
	assert_eq(acceptations[0], 1)
	assert_eq(refus[0], 1)
