extends SceneTree

## Vérification d'intégration exécutée dans Godot (pas un test unitaire d'UI).
## Utiliser exclusivement un XDG_DATA_HOME temporaire : ce parcours crée des joueurs.
## RTC_CAPTURE_DIR facultatif : captures du viewport rendu, sans recomposition.
var INTRO: Script
var CLASSIQUE: PackedScene
var erreurs: int = 0
var controles: int = 0
var jeu: Node
var intro: CanvasLayer
var bdd: Node
var captures := OS.get_environment("RTC_CAPTURE_DIR")

func _initialize() -> void:
	call_deferred("executer")

func verifier(condition: bool, message: String) -> void:
	controles += 1
	if not condition:
		erreurs += 1
		push_error("ECHEC : " + message)
	else:
		print("OK : ", message)

func attendre(secondes: float = 0.08) -> void:
	await create_timer(secondes).timeout

func cliquer(position: Vector2) -> void:
	for presse in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.position = position
		event.global_position = position
		event.pressed = presse
		root.push_input(event, true)
		await process_frame
	await attendre()

func bouton(chemin: String) -> void:
	var control: Control = intro.get_node("Surface/Cartouche/" + chemin)
	await cliquer(control.get_global_rect().get_center())

func capturer(nom: String) -> void:
	if captures.is_empty() or DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	verifier(root.get_texture().get_image().save_png(captures.path_join(nom + ".png")) == OK, "capture " + nom)

func verifier_encart() -> void:
	verifier(intro.description.get_rect().end.y <= intro.cartouche.size.y + 0.1, "texte contenu dans le panneau phase %d" % intro._phase_actuelle)

func creer_jeu() -> void:
	jeu = CLASSIQUE.instantiate()
	root.add_child(jeu)
	intro = jeu.get_node("TutorielClassique")

func executer() -> void:
	INTRO = load("res://Scenes/MenuPrincipal/Campagne/GamePlay/Classique/Tutoriel/tutoriel_classique.gd")
	CLASSIQUE = load("res://Scenes/MenuPrincipal/Campagne/GamePlay/Classique/classique.tscn")
	bdd = root.get_node("SauvegardeBddJoueursService")
	INTRO._joueurs_vus.clear()
	# Comptes de test créés dans la sauvegarde temporaire uniquement.
	bdd.ajouter_un_nouveau_joueur("Anna (test)", "verification_a.json")
	creer_jeu()
	jeu.commencer_un_nouveau_gameplay()
	await attendre()
	verifier(intro.visible, "première visite : ouverture automatique")
	verifier(not intro.has_node("Surface/Cartouche/Actions"), "aucun des deux gros boutons rejetés dans la scène")
	verifier(intro.get_node("Surface").size == Vector2(480, 720), "surface 480×720")
	verifier(jeu.get_node("MenuPlateau").process_mode == Node.PROCESS_MODE_DISABLED, "menu derrière l'aide désactivé")
	var carre: Control = intro.get_node("Surface/Cartouche/Demo/B1/Jeton/Carre")
	verifier(carre.get_global_rect().position.is_equal_approx(Vector2(158, 334)), "jeton natif ancré dans la colonne")
	verifier(carre.get_global_rect().size.is_equal_approx(Vector2(62, 62)), "échelle du jeton natif transmise")
	await capturer("01_depart")
	# Vrai clic sur JOUER, hors panneau : ne doit pas traverser la surface modale.
	var lancements: Array = []
	jeu.commencer_plateau.connect(func(): lancements.append(true))
	await cliquer(Vector2(341, 50))
	verifier(lancements.is_empty(), "clic derrière le panneau sans lancement du plateau")
	await attendre(3.6)
	verifier(intro.jeton_b_1.position.is_equal_approx(INTRO.ARRIVEE_B1), "B1 transféré")
	verifier(intro.jeton_b_2.position.is_equal_approx(INTRO.ARRIVEE_B2), "B2 transféré avec B1")
	verifier(intro.demo.get_node("C").position == Vector2(126, 290), "C reste immobile")
	verifier(intro.demo.get_node("B2/Jeton/SoudureBasse").visible, "liaison native des trois B après transfert")
	await capturer("02_transfert")
	await attendre(2.7)
	verifier(intro._phase_actuelle == 3, "animation aboutit à JOUER")
	verifier_encart()
	await capturer("03_jouer")
	intro._avancer()
	await attendre()
	verifier(intro._phase_actuelle == 4, "avancement interne vers RECOMMENCER")
	verifier_encart()
	await capturer("04_recommencer")
	intro._avancer()
	await attendre()
	verifier(intro._phase_actuelle == 5, "avancement interne vers PASSER")
	verifier_encart()
	await capturer("05_passer")
	intro._avancer()
	await attendre()
	verifier(intro._phase_actuelle == 6, "avancement interne vers conclusion")
	verifier(not intro.case_ne_plus_afficher.button_pressed, "case finale décochée")
	await capturer("06_final")
	await bouton("Final/Compris")
	verifier(not intro.visible, "Compris ferme le CanvasLayer")
	verifier(jeu.get_node("MenuPlateau").process_mode == Node.PROCESS_MODE_INHERIT, "menu restauré")
	jeu.commencer_un_nouveau_gameplay()
	verifier(not intro.visible, "pas de répétition automatique dans la session")
	await cliquer(Vector2(442, 666))
	verifier(intro.visible and intro._phase_actuelle == 0, "bouton ? rouvre le début")
	verifier(intro.jeton_b_1.position == INTRO.DEPART_B1, "B1 réinitialisé à la réouverture")
	await attendre(2.4)
	intro.masquer()
	verifier(not intro.visible, "fermeture en plein transfert")
	intro.afficher_manuellement()
	verifier(intro.jeton_b_2.position == INTRO.DEPART_B2, "B2 réinitialisé après interruption")
	intro._ignorer_demonstration()
	await attendre()
	verifier(intro._phase_actuelle == 6, "annulation de la démonstration via API interne")
	await cliquer(intro.case_ne_plus_afficher.get_global_rect().get_center())
	verifier(intro.case_ne_plus_afficher.button_pressed, "case Ne plus afficher cliquable")
	await bouton("Final/Compris")
	verifier(intro._pref_masquee(), "préférence enregistrée pour A")
	# Nouvelle session simulée, nouvelle instance de CanvasLayer.
	INTRO._joueurs_vus.clear()
	jeu.queue_free()
	await attendre()
	creer_jeu()
	jeu.commencer_un_nouveau_gameplay()
	verifier(not intro.visible, "préférence A relue par une nouvelle instance")
	bdd.ajouter_un_nouveau_joueur("Joueur B (test)", "verification_b.json")
	jeu.commencer_un_nouveau_gameplay()
	verifier(intro.visible, "première visite du joueur B indépendante")
	verifier(not intro.case_ne_plus_afficher.button_pressed, "case de B décochée")
	intro.masquer()
	bdd.choisir_le_joueur("Anna (test)", "verification_a.json")
	intro.afficher_manuellement()
	verifier(intro.visible, "aide manuelle disponible même si masquée automatiquement")
	verifier(not intro.case_ne_plus_afficher.button_pressed, "case décochée à chaque conclusion")
	intro._ignorer_demonstration()
	await bouton("Final/Compris")
	verifier(not intro._pref_masquee(), "décocher réactive les prochaines sessions")
	# Partie réelle : vérifier l'isolation pendant l'animation.
	root.get_node("ProgressionCampagneService").commencer_un_plateau()
	var nom: String = bdd.enregistrement_campagne_lire_nom_plateau()
	jeu.commencer_un_nouveau_plateau(nom)
	await attendre()
	var plateau: Node = jeu.get_node("Plateau")
	var references: Array = plateau.liste_piles.duplicate()
	var coups: int = bdd.enregistrement_campagne_lire_nombre_coups()
	await cliquer(Vector2(442, 666))
	verifier(intro.visible, "? fonctionne pendant une vraie partie")
	var sauvegarde: Dictionary = bdd._sauvegarde_joueur.duplicate(true)
	var temps: float = bdd.enregistrement_campagne_lire_duree_plateau()
	await attendre(3.8)
	verifier(is_equal_approx(bdd.enregistrement_campagne_lire_duree_plateau(), temps), "chrono gelé pendant l'aide")
	verifier(bdd._sauvegarde_joueur == sauvegarde, "sauvegarde et progression inchangées pendant le transfert")
	verifier(plateau.liste_piles == references, "mêmes piles réelles après transfert démonstratif")
	verifier(bdd.enregistrement_campagne_lire_nombre_coups() == coups, "aucun coup réel ajouté")
	intro._ignorer_demonstration()
	await bouton("Final/Compris")
	await attendre(0.2)
	var reprise: float = bdd.enregistrement_campagne_lire_duree_plateau()
	verifier(reprise > temps and reprise - temps < 1, "chrono reprend sans compter la lecture de l'aide")
	await capturer("07_plateau_repris")
	intro.afficher_manuellement()
	jeu.hide()
	verifier(not intro.visible and bdd._plateau_en_aide.is_empty(), "hide du gameplay ferme aussi le CanvasLayer et la pause")
	jeu.queue_free()
	await attendre()
	creer_jeu()
	jeu.commencer_un_nouveau_gameplay()
	verifier(not intro.visible, "visite mémorisée après recréation de la scène")
	intro.afficher_manuellement()
	jeu.queue_free()
	await attendre()
	verifier(bdd._plateau_en_aide.is_empty(), "destruction libère la pause")
	print("RESULTAT : %d contrôles, %d échecs" % [controles, erreurs])
	quit(0 if erreurs == 0 else 1)
