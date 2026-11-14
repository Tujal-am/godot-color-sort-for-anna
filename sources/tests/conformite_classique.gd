extends SceneTree

## QA interne uniquement. Les PNG ne sont pas des propositions à publier avant matrice OK.
var sortie := OS.get_environment("RTC_CONFORMITE_DIR")
var donnees: Dictionary = {}

func _initialize() -> void:
	call_deferred("executer")

func dump(noeud: Node, resultat: Dictionary) -> void:
	if noeud is Control and noeud.is_visible_in_tree():
		var rect: Rect2 = noeud.get_global_rect()
		var entree := {"rect": [rect.position.x,rect.position.y,rect.end.x,rect.end.y]}
		if noeud is Label:
			entree["texte"] = noeud.text
			entree["corps"] = noeud.get_theme_font_size("font_size")
		resultat[str(noeud.get_path())] = entree
	for enfant in noeud.get_children():
		dump(enfant,resultat)

func executer() -> void:
	if sortie.is_empty():
		push_error("RTC_CONFORMITE_DIR doit désigner un dossier de QA interne.")
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute(sortie)
	var bdd: Node = root.get_node("SauvegardeBddJoueursService")
	bdd.choisir_le_joueur("Alain Konu","sauvegarde_joueur_00.json")
	var jeu = load("res://Scenes/MenuPrincipal/Campagne/GamePlay/Classique/classique.tscn").instantiate()
	root.add_child(jeu)
	jeu.commencer_un_nouveau_gameplay()
	await create_timer(0.35).timeout
	var intro: CanvasLayer = jeu.get_node("TutorielClassique")
	var phases := [3,4,5,6] if OS.get_environment("RTC_FINAL_SEUL").is_empty() else [6]
	for phase in phases:
		intro._stop_animation()
		intro._afficher_phase(phase)
		intro._stop_animation()
		await create_timer(0.15).timeout
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		var nom: String = {3:"JOUER",4:"RECOMMENCER",5:"PASSER",6:"FINAL"}[phase]
		var resultat: Dictionary = {}
		dump(intro,resultat)
		var verre: StyleBoxFlat = intro.cartouche.get_theme_stylebox("panel")
		resultat["style_panneau"] = {"rgba": [verre.bg_color.r,verre.bg_color.g,verre.bg_color.b,verre.bg_color.a],"border":verre.border_width_left}
		donnees[nom] = resultat
		var erreur := root.get_texture().get_image().save_png(sortie.path_join(nom+".png"))
		if erreur != OK:
			push_error("Capture impossible : "+nom)
			quit(1)
			return
		print("QA interne capturée : ",nom)
	var fichier := FileAccess.open(sortie.path_join("noeuds.json"),FileAccess.WRITE)
	fichier.store_string(JSON.stringify(donnees,"  "))
	jeu.queue_free()
	await process_frame
	quit()
