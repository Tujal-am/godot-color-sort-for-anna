extends SceneTree

## Parcours filmable depuis l'accueil réel, sur sauvegarde temporaire uniquement.
## Godot --path sources --script res://tests/presentation_classique.gd --write-movie /tmp/classique.avi
func _initialize() -> void:
	call_deferred("filmer")

func attendre(secondes: float) -> void:
	await create_timer(secondes).timeout

func cliquer(control: Control) -> void:
	for presse in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.position = control.get_global_rect().get_center()
		event.global_position = event.position
		event.pressed = presse
		root.push_input(event, true)
		await process_frame

func filmer() -> void:
	change_scene_to_file("res://Scenes/MenuPrincipal/menu_principal.tscn")
	await attendre(1.0)
	var accueil := current_scene
	accueil._on_nouveau_joueur_text_submitted("Anna (démo)")
	accueil._on_joueurs_campagne_pressed("Anna (démo)")
	await attendre(0.2)
	var campagne := current_scene
	var intro: CanvasLayer = campagne.get_node("Classique/TutorielClassique")
	if not intro.visible:
		push_error("La première visite Classique n'a pas ouvert l'introduction.")
		quit(1)
		return
	print("PARCOURS : accueil → joueur → campagne → introduction Classique")
	# 6,1 s démonstration puis pages automatiques 4 + 4 + 6 s.
	await attendre(23.0)
	await cliquer(intro.get_node("Surface/Cartouche/Final/Compris"))
	await attendre(1.0)
	if intro.visible or not campagne.get_node("Classique/MenuPlateau/BandeauMenu").visible:
		push_error("Compris n'a pas ramené au menu avant plateau.")
		quit(1)
		return
	print("PARCOURS OK : Compris → menu avant plateau, sans lancer le chrono")
	quit()
