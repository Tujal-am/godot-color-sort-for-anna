extends CanvasLayer

class_name MenuCampagne

var formatter := FormatterMenuCampagne.new()
var _message_riche_verrouille := false # Semaphore sur l'affichage de message riche
var _on_message_riche_gui_input_verouille := false
var _resultat_terminal := false
var _fin_campagne_en_attente := false

# Notifie la scene `Plateau` que le bouton est pressé
signal commencer_plateau
signal fin_message_riche

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connecter les signaux attendus
	var pcs = get_node("/root/ProgressionCampagneService")
	pcs.detail_score_plateau.connect(_on_progression_campagne_service_detail_score_plateau)
	# L’écran d’accueil ne doit jamais exposer le gabarit de message/résultat.
	$ResultsPanel.hide()
	$MessageRiche.hide()

func afficher_background() -> void:
	$Background.show()

func mettre_a_jour_infos_joueur() -> void:
	$InfosDuJoueur/TexteInfosDuJoueur.bbcode_text = formatter.formater_infos_joueur()

func modifier_message_riche(message_bbcode: Dictionary) -> void:
	$MessageRiche.hide()
	$MessageRiche.text = message_bbcode['bbcode']
	$MessageRiche.position.y = message_bbcode['position_y']
	$MessageRiche.size.y = message_bbcode['size_y']
	$MessageRiche.show()

func afficher_detail_score(detail_score : Dictionary) -> void:
	while _message_riche_verrouille:
		await fin_message_riche
	_message_riche_verrouille = true
	$MessageRiche.hide()
	$ResultsVisualLayer.capture_backdrop()
	_mettre_a_jour_cartes_resultat(detail_score)
	$ResultsPanel.show()

func _nombre(value) -> String:
	return SauvegardeTableauDesScoresService.nombre_avec_separateur_de_milliers(value, '.')

func _mettre_a_jour_cartes_resultat(detail_score: Dictionary) -> void:
	var duree: Dictionary = detail_score.get('duree', {})
	var ratio: Dictionary = detail_score.get('ratio_reussite', {})
	var niveau: Dictionary = detail_score.get('niveau', {})
	var detour: Dictionary = detail_score.get('niveau_sans_detour', {})
	var campagne: Dictionary = detail_score.get('campagne', {})
	var score_total = duree.get('points', 0) + ratio.get('points', 0)
	score_total += niveau.get('points', 0) + detour.get('points', 0) + campagne.get('points', 0)
	$ResultsPanel/ResultsContent/ScoreCard/ScoreLabel.text = _nombre(score_total) + " points"
	$ResultsPanel/ResultsContent/TempsCard/TempsLabel.text = "• Référence : " + str(duree.get('reference', 0)) + "s\n• Réalisé : " + str(snapped(duree.get('realise', 0), 0.1)) + "s\n• " + _nombre(duree.get('points', 0)) + " points"
	$ResultsPanel/ResultsContent/RatioCard/RatioLabel.text = "• Réalisé : " + str(ratio.get('ratio', 0)) + "%\n• " + _nombre(ratio.get('points', 0)) + " points"
	$ResultsPanel/ResultsContent/RatioCard/RatioPercent.text = str(ratio.get('ratio', 0)) + "%"
	$ResultsPanel/ResultsContent/NiveauCard.visible = not niveau.is_empty()
	$ResultsPanel/ResultsContent/NiveauCard/NiveauLabel.text = "• Niveau " + str(niveau.get('longueur', 0)) + "\n• " + _nombre(niveau.get('points', 0)) + " points"
	$ResultsPanel/ResultsContent/DetourCard.visible = not detour.is_empty()
	$ResultsPanel/ResultsContent/DetourCard/DetourLabel.text = "• Réalisé : " + ("Oui" if detour.get('bonus', 0) else "Non") + "\n• " + _nombre(detour.get('points', 0)) + " points"
	$ResultsPanel/ResultsContent/BonusCard.visible = not campagne.is_empty()
	$ResultsPanel/ResultsContent/BonusCard/BonusLabel.text = "• " + _nombre(campagne.get('points', 0)) + " points"
	_ajuster_results_layout()

func _ajuster_results_layout() -> void:
	var content = $ResultsPanel/ResultsContent
	var visible_cards := 0
	for child in content.get_children():
		if child.visible:
			visible_cards += 1
	var content_height := 0.0
	for child in content.get_children():
		if child.visible:
			content_height += child.custom_minimum_size.y
	if visible_cards > 1:
		content_height += float(visible_cards - 1) * content.get_theme_constant("separation")
	var panel_height: float = content_height * content.scale.y + 24.0
	$ResultsPanel.size.y = panel_height
	$ResultsPanel/ResultsContent.position.y = 12.0
	$BoutonCommencer.position.y = $ResultsPanel.position.y + panel_height + 8.0

func afficher_message_simple(message : String, tempo : float = 1.0) -> void:
	if message != "":
		var message_bbcode: Dictionary = formatter.formater_message_simple(message)
		while _message_riche_verrouille:
			await fin_message_riche # Attendre que le message riche soit libéré
		_message_riche_verrouille = true # Reservation du message riche
		$ResultsPanel.hide()
		modifier_message_riche(message_bbcode)
		await get_tree().create_timer(tempo).timeout # Persistence message
		$MessageRiche.hide()
		_message_riche_verrouille = false # Libération du message riche
		fin_message_riche.emit()

func afficher_des_messages_simples(les_message : Array[String], tempo : float = 1.0):
	for message in les_message:
		if message != "":
			afficher_message_simple(message, tempo)
			# Se synchroniser avec 'afficher_message_simple'
			while _message_riche_verrouille:
				await fin_message_riche

func _afficher_resultat_et_continuer() -> void:
	_resultat_terminal = false
	_fin_campagne_en_attente = false
	$BoutonMenuPrincipal.hide()
	$BoutonStatistiques.hide()
	$InfosDuJoueur.hide()
	$Message.hide()
	$MessageRiche.hide()
	$ResultsPanel.show()
	$ResultsPanel.mouse_filter = Control.MOUSE_FILTER_STOP
	$BoutonCommencer.show()
	$ResultsVisualLayer.show_intermediate()

func afficher_plateau_suivant(_texte: String = ""):
	# Le panneau de résultats reste l'écran de transition unique.
	_afficher_resultat_et_continuer()

func cacher_accueil():
	_resultat_terminal = false
	_fin_campagne_en_attente = false
	$Background.hide()
	$BoutonMenuPrincipal.hide()
	$BoutonStatistiques.hide()
	$InfosDuJoueur.hide()
	$Message.hide()
	$BoutonCommencer.hide()
	$BoutonRetourFinCampagne.hide()
	$MessageRiche.hide()
	$ResultsPanel.hide()
	$ResultsVisualLayer.hide_all()

func afficher_accueil_nouveau_niveau():
	afficher_plateau_suivant("Nouveau Niveau !")

func afficher_accueil_niveau_en_cours():
	afficher_plateau_suivant("Poursuivre Le Niveau !")

func _on_resultats_continue_requested() -> void:
	if _resultat_terminal:
		return
	AudioService.son_menu_click()
	if _fin_campagne_en_attente:
		_fin_campagne_en_attente = false
		fin_message_riche.emit()
		$ResultsPanel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		$MessageRiche.hide()
		$BoutonCommencer.hide()
		$BoutonRetourFinCampagne.show()
		$ResultsVisualLayer.show_final()
		_resultat_terminal = true
		return
	# Libère le verrou de l'ancien écran de score avant de relancer le plateau.
	fin_message_riche.emit()
	$ResultsPanel.hide()
	$BoutonCommencer.hide()
	$ResultsVisualLayer.hide_all()
	commencer_plateau.emit()

func _on_bouton_menu_principal_pressed() -> void:
	AudioService.son_menu_click()
	get_tree().change_scene_to_file("res://Scenes/MenuPrincipal/menu_principal.tscn")

func _on_bouton_statistiques_pressed() -> void:
	AudioService.son_menu_click()
	get_tree().change_scene_to_file("res://Scenes/MenuPrincipal/Campagne/MenuCampagne/Statistiques/statistiques.tscn")



func afficher_plateau_invalide():
	# Pas de plateau invalide en campagne
	pass

func afficher_abandonner_un_plateau():
	$ResultsVisualLayer.capture_backdrop()
	$ResultsVisualLayer.show_lost()
	$BoutonMenuPrincipal.hide()
	$BoutonStatistiques.hide()
	$InfosDuJoueur.hide()
	$MessageRiche.hide()
	$BoutonCommencer.hide()

func afficher_gagner_un_plateau() -> void:
	_message_riche_verrouille = false # Libération du message riche
	$MessageRiche.hide()
	_afficher_resultat_et_continuer()

func afficher_fin_niveau():
	# TODO : Voir si l'affiche doit toujours être lancé d'ailleurs
	# Affichage minimum de 1s pour le detail du score
	await get_tree().create_timer(1.0).timeout
	_message_riche_verrouille = false # Libération du message riche
	$MessageRiche.hide()
	_afficher_resultat_et_continuer()

func afficher_fin_campagne():
	_afficher_resultat_et_continuer()
	_fin_campagne_en_attente = true

func _on_bouton_retour_fin_campagne_pressed() -> void:
	AudioService.son_menu_click()
	$ResultsVisualLayer.hide_all()
	get_tree().change_scene_to_file("res://Scenes/MenuPrincipal/menu_principal.tscn")

func _on_progression_campagne_service_detail_score_plateau(detail_score: Dictionary):
	afficher_detail_score(detail_score)

func _on_message_riche_gui_input(_event: InputEvent) -> void:
	if 	_on_message_riche_gui_input_verouille:
		return
	_on_message_riche_gui_input_verouille = true

	fin_message_riche.emit()

	# Limiter l'occurence de l'evenement avant la disparition
	await get_tree().create_timer(1.0).timeout
	_on_message_riche_gui_input_verouille = false

func _on_results_panel_gui_input(event: InputEvent) -> void:
	if _resultat_terminal:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_on_resultats_continue_requested()
