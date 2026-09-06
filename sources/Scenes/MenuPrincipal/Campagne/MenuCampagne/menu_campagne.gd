extends CanvasLayer

class_name MenuCampagne

var formatter := FormatterMenuCampagne.new()
var _message_riche_verrouille := false # Semaphore sur l'affichage de message riche
var _on_message_riche_gui_input_verouille := false

# Notifie la scene `Plateau` que le bouton est pressé
signal commencer_plateau
signal fin_message_riche

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connecter les signaux attendus
	var pcs = get_node("/root/ProgressionCampagneService")
	pcs.detail_score_plateau.connect(_on_progression_campagne_service_detail_score_plateau)

func mettre_a_jour_infos_joueur() -> void:
	$InfosDuJoueur/TexteInfosDuJoueur.bbcode_text = formatter.formater_infos_joueur()

func modifier_message_riche(message_bbcode: Dictionary) -> void:
	$MessageRiche.hide()
	$MessageRiche.text = message_bbcode['bbcode']
	$MessageRiche.position.y = message_bbcode['position_y']
	$MessageRiche.size.y = message_bbcode['size_y']
	$MessageRiche.show()

func afficher_detail_score(detail_score : Dictionary) -> void:
	var score_bbcode: Dictionary = formatter.formater_detail_score(detail_score)
	while _message_riche_verrouille:
		await fin_message_riche # Attendre que le message riche soit libéré
	_message_riche_verrouille = true # Reservation du message riche
	modifier_message_riche(score_bbcode)
	# _message_riche_verrouille = false # Géré avec le signal 'fin_message_riche'

func afficher_message_simple(message : String, tempo : float = 1.0) -> void:
	if message != "":
		var message_bbcode: Dictionary = formatter.formater_message_simple(message)
		while _message_riche_verrouille:
			await fin_message_riche # Attendre que le message riche soit libéré
		_message_riche_verrouille = true # Reservation du message riche
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

func afficher_plateau_suivant(texte : String = ""):
	$BoutonMenuPrincipal.show()
	$BoutonStatistiques.show()
	mettre_a_jour_infos_joueur()
	$InfosDuJoueur.show()

	if texte != "":
		afficher_message_simple(texte, 0.5)
		# Attendre l'affichage du texte
		await fin_message_riche
	$BoutonCommencer.show()
	if texte != "":
		afficher_message_simple(texte, 0.5)
		# Attendre l'affichage du texte à 50%
		await fin_message_riche


func cacher_accueil():
	$BoutonMenuPrincipal.hide()
	$BoutonStatistiques.hide()
	$InfosDuJoueur.hide()
	$Message.hide()
	$BoutonCommencer.hide()
	$MessageRiche.hide()

func afficher_accueil_nouveau_niveau():
	afficher_plateau_suivant("Nouveau Niveau !")

func afficher_accueil_niveau_en_cours():
	afficher_plateau_suivant("Poursuivre Le Niveau !")

func _on_bouton_commencer_pressed() -> void:
	AudioService.son_menu_click()
	var date_debut_campagne = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	if Time.get_unix_time_from_system() < date_debut_campagne:
		var datetime_debut_campagne = Time.get_datetime_dict_from_unix_time( date_debut_campagne )
		var annee = datetime_debut_campagne.get('year')
		var mois = datetime_debut_campagne.get('month')
		var jour = datetime_debut_campagne.get('day')
		# var heure = datetime_debut_campagne.get('hour')
		# var minute = datetime_debut_campagne.get('minute')
		var message = "Soyez patient, la campagne commence le " \
			+ str(jour).pad_zeros(2) +"/"+str(mois).pad_zeros(2)+"/"+str(annee)+"."
		afficher_message_simple(message, 5.)
	else:
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
	$BoutonMenuPrincipal.show()
	$BoutonStatistiques.show()
	mettre_a_jour_infos_joueur()
	$InfosDuJoueur.show()
	
	var message : Array[String] = [ "Perdu !",
					"Fin De Partie",
					"Plateau Suivant !"]
	afficher_des_messages_simples(message)
	# Attendre l'affichage des messages
	for attente in message.size():
		await fin_message_riche

	$BoutonCommencer.show()

func afficher_gagner_un_plateau() -> void:
	# TODO : Voir si l'affiche doit toujours être lancé d'ailleurs
	# Affichage minimum de 1s pour le detail du score
	await get_tree().create_timer(1.0).timeout
	await fin_message_riche
	_message_riche_verrouille = false # Libération du message riche
	$MessageRiche.hide()

	afficher_plateau_suivant("Plateau Suivant !")

func afficher_fin_niveau():
	# TODO : Voir si l'affiche doit toujours être lancé d'ailleurs
	# Affichage minimum de 1s pour le detail du score
	await get_tree().create_timer(1.0).timeout
	await fin_message_riche
	_message_riche_verrouille = false # Libération du message riche
	$MessageRiche.hide()

	var message : Array[String] = [ "Bravo !",
					"C'était Le Dernier Plateau.",
					"Vous êtes au TOP !"]
	afficher_des_messages_simples(message, 3.0)
	# Attendre l'affichage des messages
	for attente in message.size():
		await fin_message_riche

	afficher_plateau_suivant("Découvrez Le Niveau Suivant !")

func afficher_fin_campagne():
	# TODO : Voir si l'affiche doit toujours être lancé d'ailleurs
	# Affichage minimum de 1s pour le detail du score
	await get_tree().create_timer(1.0).timeout
	await fin_message_riche
	_message_riche_verrouille = false # Libération du message riche
	await get_tree().process_frame
	$MessageRiche.hide()


	var message : Array[String] = [ "Félicitation !",
					"C'était le dernier plateau...",
					"...du dernier niveau.",
					"Vous êtes incroyable !",
					"Rien ne vous arrête."]
	afficher_des_messages_simples(message, 5.0)
	# Attendre l'affichage des messages
	for attente in message.size():
		await fin_message_riche

	afficher_plateau_suivant()
	$BoutonCommencer.hide()

func _on_progression_campagne_service_detail_score_plateau(detail_score: Dictionary):
	afficher_detail_score(detail_score)

func _on_message_riche_gui_input(_event: InputEvent) -> void:
	if 	_on_message_riche_gui_input_verouille:
		return
	_on_message_riche_gui_input_verouille = true

	print('click score !!!')
	fin_message_riche.emit()

	# Limiter l'occurence de l'evenement avant la disparition
	await get_tree().create_timer(1.0).timeout
	_on_message_riche_gui_input_verouille = false
