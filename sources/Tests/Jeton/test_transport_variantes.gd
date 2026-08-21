extends Node

const FICHIER_JOUEUR_TEST := "test_transport_variantes_joueur.json"

var succes := true

func _ready() -> void:
	var sauvegarde_initialisee := _initialiser_sauvegarde_test()
	_verifier(sauvegarde_initialisee, "La sauvegarde de test doit être initialisée.")
	await _tester_transfert_simple()
	await _tester_transfert_groupe()
	await _tester_regles_et_compatibilite()
	var compteur_final := SauvegardeBddJoueursService.lire_nombre_coups()
	_verifier(compteur_final == 2,
			"Deux transferts, dont un groupé, doivent compter exactement deux coups.")
	SauvegardeBddJoueursService.annuler_creation_joueur(FICHIER_JOUEUR_TEST)
	print("TEST_TRANSPORT_VARIANTES: ", "PASS" if succes else "FAIL")
	get_tree().quit(0 if succes else 1)

func _tester_transfert_simple() -> void:
	var plateau = _creer_plateau("A  .   ")
	var pile_depart: Pile = plateau.liste_piles[0]
	var pile_arrivee: Pile = plateau.liste_piles[1]
	pile_depart.liste_jetons[0].choisir_id_variante_visuelle(&"coeur")
	var coups_avant := SauvegardeBddJoueursService.lire_nombre_coups()
	var transfert: bool = plateau.regles.realiser_le_tansfert_de_pile(
			plateau.liste_piles, 0, 1)
	var coups_apres := SauvegardeBddJoueursService.lire_nombre_coups()
	_verifier(transfert, "Le transfert simple doit réussir.")
	_verifier(pile_arrivee.liste_jetons[0].indice_jeton == 0 \
			and pile_arrivee.liste_jetons[0].id_variante_visuelle == &"coeur",
			"Le transfert simple doit conserver couleur et variante.")
	_verifier(pile_depart.liste_jetons[0].indice_jeton == Plateau.ESPACE \
			and pile_depart.liste_jetons[0].id_variante_visuelle == &"",
			"La case source vidée doit perdre sa variante.")
	_verifier(coups_apres == coups_avant + 1,
			"Un transfert simple doit compter un seul coup.")
	plateau.free()

func _tester_transfert_groupe() -> void:
	var plateau = _creer_plateau("BAA.   ")
	var pile_depart: Pile = plateau.liste_piles[0]
	var pile_arrivee: Pile = plateau.liste_piles[1]
	pile_depart.liste_jetons[0].choisir_id_variante_visuelle(&"base")
	pile_depart.liste_jetons[1].choisir_id_variante_visuelle(&"points")
	pile_depart.liste_jetons[2].choisir_id_variante_visuelle(&"coeur")
	var validite_avant: bool = plateau.regles.est_valide_le_tansfert_de_pile(
			plateau.liste_piles, 0, 1)
	pile_depart.liste_jetons[1].choisir_id_variante_visuelle(&"vagues")
	var validite_apres: bool = plateau.regles.est_valide_le_tansfert_de_pile(
			plateau.liste_piles, 0, 1)
	# Restaurer la variante attendue avant de réaliser le transfert réel.
	pile_depart.liste_jetons[1].choisir_id_variante_visuelle(&"points")
	var coups_avant := SauvegardeBddJoueursService.lire_nombre_coups()
	var transfert: bool = plateau.regles.realiser_le_tansfert_de_pile(
			plateau.liste_piles, 0, 1)
	var coups_apres := SauvegardeBddJoueursService.lire_nombre_coups()
	var ordre_destination := [
		pile_arrivee.liste_jetons[0].id_variante_visuelle,
		pile_arrivee.liste_jetons[1].id_variante_visuelle,
	]
	_verifier(validite_avant and validite_apres,
			"La validité du transfert doit être indépendante des variantes.")
	_verifier(transfert, "Le transfert groupé doit réussir.")
	_verifier(ordre_destination == [&"coeur", &"points"],
			"Chaque couleur doit rester appariée à sa variante dans l'ordre historique.")
	_verifier(pile_arrivee.liste_jetons[0].indice_jeton == 0 \
			and pile_arrivee.liste_jetons[1].indice_jeton == 0,
			"Les couleurs du groupe doivent être conservées.")
	_verifier(pile_depart.liste_jetons[1].id_variante_visuelle == &"" \
			and pile_depart.liste_jetons[2].id_variante_visuelle == &"",
			"Toutes les cases sources vidées doivent perdre leur variante.")
	_verifier(coups_apres == coups_avant + 1,
			"Un transfert groupé doit compter un seul coup.")
	plateau.free()

func _tester_regles_et_compatibilite() -> void:
	var plateau_termine = _creer_plateau("AAA.BBB")
	var variantes := [&"coeur", &"points", &"vagues"]
	for pile in plateau_termine.liste_piles:
		for indice in range(pile.liste_jetons.size()):
			pile.liste_jetons[indice].choisir_id_variante_visuelle(variantes[indice])
	_verifier(plateau_termine.regles.est_termine(plateau_termine.liste_piles),
			"La victoire doit rester indépendante des variantes.")
	plateau_termine.free()

	var plateau_historique = _creer_plateau("A .  ")
	var pile_arrivee: Pile = plateau_historique.liste_piles[1]
	_verifier(pile_arrivee.ajouter_le_jeton_dans_le_vide(0),
			"L'appel historique sans variante doit continuer à fonctionner.")
	_verifier(pile_arrivee.liste_jetons[0].id_variante_visuelle == &"",
			"L'appel historique doit conserver une variante neutre.")
	plateau_historique.free()

func _creer_plateau(texte: String):
	var scene: PackedScene = load("res://Scenes/Plateau/plateau.tscn")
	var plateau = scene.instantiate()
	add_child(plateau)
	plateau.commencer_un_nouveau_plateau(texte)
	return plateau

func _initialiser_sauvegarde_test() -> bool:
	if not SauvegardeBddJoueursService.ajouter_un_nouveau_joueur(
			"Test Transport Variantes", FICHIER_JOUEUR_TEST):
		return false
	if not SauvegardeBddJoueursService.choisir_le_joueur(
			"Test Transport Variantes", FICHIER_JOUEUR_TEST):
		return false
	if not SauvegardeBddJoueursService.initialiser_une_nouvelle_ascension(1, 10, 10):
		return false
	return SauvegardeBddJoueursService.initialiser_un_nouveau_plateau("BAA.   ", 10)

func _verifier(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		succes = false
