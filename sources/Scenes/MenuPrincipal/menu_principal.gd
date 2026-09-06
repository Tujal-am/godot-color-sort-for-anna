extends Control

var delay_ms: int = 200
var last_click_time: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ProgressionCampagneService.liberer_le_joueur_pour_la_campagne()
	_creer_tuiles_joueurs_campagne()
	_mettre_a_jour_configuration()
	if OS.has_feature("web"):
		# [WEB] masquer le bouton de vibration
		$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/VBoxContainer/BoutonVibrations.hide()

func _on_bouton_références_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MenuPrincipal/References/references.tscn")
	AudioService.son_menu_click()

func _on_bouton_scores_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MenuPrincipal/Scores/scores.tscn")
	AudioService.son_menu_click()

func _on_nouveau_joueur_text_submitted(nom_nouveau_joueur: String) -> void:
	_on_clavier_pseudo_annule() # Par precaution
	LogService.log_debug("Nouveau joueur : ", nom_nouveau_joueur)
	if ScoreService.nouveau_joueur_est_nom_anna_triche(nom_nouveau_joueur):
		nom_nouveau_joueur = ScoreService.lire_nom_anna_triche()
		LogService.log_debug("Anna la tricheuse s'inscrit !")
	$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/JoueursCampagne.get_node("nouveau_joueur").clear()
	if not ProgressionCampagneService.ajouter_un_nouveau_joueur_pour_la_campagne(nom_nouveau_joueur):
		LogService.log_erreur("Erreur : Le nom *" + nom_nouveau_joueur + "* n'est pas libre")
		$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/JoueursCampagne.get_node("nouveau_joueur").placeholder_text = 'Erreur !'
	else:
		ProgressionCampagneService.initialiser_le_nouveau_joueur_pour_la_campagne(nom_nouveau_joueur)
		$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/JoueursCampagne.get_node("nouveau_joueur").placeholder_text = 'Ok !'
		_ajouter_une_tuile_pour_nouveau_joueur_campagne(nom_nouveau_joueur)
		$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/JoueursCampagne.get_node("nouveau_joueur").placeholder_text = " Ajouter "

func _on_bouton_campagne_pressed() -> void:
	if $Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/JoueursCampagne.is_visible_in_tree():
		$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/JoueursCampagne.hide()
	else:
		$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/JoueursCampagne.show()
	AudioService.son_menu_click()

func _on_joueurs_campagne_pressed(nom_joueur: String) -> void:
	LogService.log_debug("Campagne avec le joueur : ", nom_joueur)
	if not SauvegardeListeJoueursService.le_joueur_existe(nom_joueur):
		LogService.log_erreur("Erreur : Le nom *" + nom_joueur + "* n'existe pas")
	elif not ProgressionCampagneService.la_campagne_est_terminee_pour_joueur(nom_joueur):
		# Choisir le joueur pour la campagne
		var succes: bool = ProgressionCampagneService.choisir_le_joueur_pour_la_campagne(nom_joueur)
		if succes:
			AudioService.son_menu_click()
			get_tree().change_scene_to_file("res://Scenes/Campagne/campagne.tscn")
		else:
			LogService.log_erreur("Erreur : Impossible de choisir le joueur *" + nom_joueur + "*.")
	else:
		AudioService.son_menu_click()
		get_tree().change_scene_to_file("res://Scenes/Statistiques/statistiques.tscn")

func _mettre_a_jour_configuration():
	$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/VBoxContainer/BoutonMusiques.button_pressed = SauvegardeConfigurationService.musiques_sont_actives()
	$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/VBoxContainer/BoutonEffetsSonores.button_pressed = SauvegardeConfigurationService.effets_sonores_sont_actifs()
	$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/VBoxContainer/BoutonVibrations.button_pressed = SauvegardeConfigurationService.vibrations_sont_actives()
	$Version.text = SauvegardeConfigurationService.lire_la_version()

func filtrer_click() -> bool:
	var current_time = Time.get_ticks_msec()
	if current_time - last_click_time < delay_ms:
		print("filtrer_click() filtré ", current_time,"ms")
		return true # Absorbe l'evenement qui ne sera pas trasnmis
	else:
		print("filtrer_click() accepté ", current_time,"ms")
		last_click_time = current_time
		return false

func _on_bouton_musiques_toggled(toggled_on: bool) -> void:
	if filtrer_click():
		_mettre_a_jour_configuration() # Corriger le changement parasite
		return
	if toggled_on:
		SauvegardeConfigurationService.activer_musiques()
	else:
		SauvegardeConfigurationService.desactiver_musiques()
	AudioService.son_menu_click()

func _on_bouton_effets_sonores_toggled(toggled_on: bool) -> void:
	if filtrer_click():
		_mettre_a_jour_configuration() # Corriger le changement parasite
		return
	if toggled_on:
		SauvegardeConfigurationService.activer_effets_sonores()
	else:
		SauvegardeConfigurationService.desactiver_effets_sonores()
	AudioService.son_menu_click()

func _on_bouton_vibrations_toggled(toggled_on: bool) -> void:
	if filtrer_click():
		_mettre_a_jour_configuration() # Corriger le changement parasite
		return
	if toggled_on:
		SauvegardeConfigurationService.activer_vibrations()
	else:
		SauvegardeConfigurationService.desactiver_vibrations()
	AudioService.son_menu_click()


func _creer_tuiles_joueurs_campagne():
	$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/JoueursCampagne.columns = 2
	for nom_joueur in SauvegardeListeJoueursService.retourner_la_liste_des_joueurs():
		# Ajouter des boutons ou des tuiles de sélection de profil
		var button = Button.new()
		_creer_style_tuile_joueur_campagne(button, nom_joueur, ProgressionCampagneService.la_campagne_est_terminee_pour_joueur(nom_joueur))
		button.text = nom_joueur
		button.connect("pressed", _on_joueurs_campagne_pressed.bind(nom_joueur))
		$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/JoueursCampagne.add_child(button)

	# Ajouter la tuile pour ajouter un nouveau joueur
	var nouveau_joueur = LineEdit.new()
	if OS.has_feature("web") and _is_ios():
		nouveau_joueur.focus_entered.connect(_nouveau_joueur_on_focus_entered)
	_creer_style_tuile_joueur_campagne(nouveau_joueur, "nouveau_joueur", false)
	nouveau_joueur.placeholder_text = " Ajouter "
	if OS.has_feature("web"):
		# [WEB] Faire apparaitre un clavier virtuel pour créer les joueurs.
		nouveau_joueur.set_virtual_keyboard_enabled(true)
		nouveau_joueur.set_virtual_keyboard_show_on_focus(true)

	nouveau_joueur.text_submitted.connect(_on_nouveau_joueur_text_submitted)
	$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/JoueursCampagne.add_child(nouveau_joueur)

func _nouveau_joueur_on_focus_entered():
	if OS.has_feature("web") and _is_ios():
		# Ouvrir le clavier intégré au jeu pour iOS sur le web.
		$Clavier.ouvrir()

func _is_ios() -> bool:
	var ua = JavaScriptBridge.eval("navigator.userAgent")
	return ua.find("iPhone") != -1 or ua.find("iPad") != -1 or ua.find("iPod") != -1

func _on_clavier_pseudo_valide(pseudo: String):
	$Clavier.fermer()
	_on_nouveau_joueur_text_submitted(pseudo)

func _on_clavier_pseudo_annule():
	$Clavier.fermer()

func _ajouter_une_tuile_pour_nouveau_joueur_campagne(nom_joueur : String):
	# Ajouter la tuile de sélection du nouveau profil
	var button = Button.new()
	_creer_style_tuile_joueur_campagne(button, nom_joueur, ProgressionCampagneService.la_campagne_est_terminee_pour_joueur(nom_joueur))
	button.text = nom_joueur
	button.connect("pressed", _on_joueurs_campagne_pressed.bind(nom_joueur))
	$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/JoueursCampagne.add_child(button)
	# Mettre en avant derniere position la tuile pour que l'ajout de nouveau joueur soit toujours dernier
	$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/JoueursCampagne.move_child(button, -2)


# "Control" = parent de "Button" et "LineEdit"
func _creer_style_tuile_joueur_campagne(tuile : Control, nom : String, campagne_terminee : bool):
	tuile.name = nom
	tuile.add_theme_font_size_override("font_size", 21)
	
	# Code conditionnel
	if tuile is Button:
		pass
	if tuile is LineEdit:
		pass
	
	# Créer un StyleBoxFlat pour le hover et normal.
	# On conserve la logique existante, seule la présentation est alignée sur le nouveau menu.
	var normal_style = StyleBoxFlat.new()
	if campagne_terminee:
		normal_style.bg_color = Color.html("404040")
	else:
		normal_style.bg_color = Color.html("f86950")
	normal_style.content_margin_left = 10
	normal_style.content_margin_right = 10
	normal_style.content_margin_top = 6
	normal_style.content_margin_bottom = 6
	normal_style.corner_radius_top_left = 10
	normal_style.corner_radius_top_right = 10
	normal_style.corner_radius_bottom_right = 10
	normal_style.corner_radius_bottom_left = 10
	tuile.add_theme_stylebox_override("normal", normal_style)

	var hover_style = StyleBoxFlat.new()
	if campagne_terminee:
		hover_style.bg_color = Color.html("202020")
	else:
		hover_style.bg_color = Color.html("ff7e66")
	hover_style.content_margin_left = 10
	hover_style.content_margin_right = 10
	hover_style.content_margin_top = 6
	hover_style.content_margin_bottom = 6
	hover_style.corner_radius_top_left = 10
	hover_style.corner_radius_top_right = 10
	hover_style.corner_radius_bottom_right = 10
	hover_style.corner_radius_bottom_left = 10
	tuile.add_theme_stylebox_override("hover", hover_style)
