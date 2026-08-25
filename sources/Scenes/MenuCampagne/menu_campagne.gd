extends CanvasLayer

class_name MenuCampagne

var formatter := FormatterMenuCampagne.new()

# Notifie la scene `Plateau` que le bouton est pressé
signal commencer_plateau
signal fin_lecture_score

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connecter les signaux attendus
	var pcs = get_node("/root/ProgressionCampagneService")
	pcs.detail_score_plateau.connect(_on_progression_campagne_service_detail_score_plateau)

	mettre_a_jour_infos_joueur()

func enregistrer_infos_joueur(	_nom : String = "",
								_trophee : String = "",
								_pourcentage_ascension_realise : int = 0,
								_pourcentage_campagne_realise : int = 0,
								_score_texte : String = "0") -> void:
	formatter.enregistrer_infos_joueur(_nom, _trophee, _pourcentage_ascension_realise, _pourcentage_campagne_realise, _score_texte)

func mettre_a_jour_infos_joueur() -> void:
	$InfosDuJoueur/TexteInfosDuJoueur.bbcode_text = formatter.formater_infos_joueur()

func afficher_detail_score(detail_score : Dictionary) -> void:
	var score_bbcode: Dictionary = formatter.formater_detail_score(detail_score)
	$MessageRiche.text = score_bbcode['bbcode']
	$MessageRiche.size.y = score_bbcode['size_y']

# Méthodes d'ajustement de la scene
func modifier_message_vertical_align(alignement : VerticalAlignment) -> void:
	$Message.vertical_alignment = alignement


func cacher_accueil():
	# Dans l'habillage Originel par défaut, Menu et Scores restent disponibles
	# pendant le plateau via leurs hitboxes natives transparentes.
	$BoutonMenuPrincipal.show()
	$BoutonStatistiques.show()
	$InfosDuJoueur.hide()
	$Message.hide()
	$BoutonCommencer.hide()
	$LongueurAscension.hide()
	$MessageRiche.hide()

func afficher_accueil_nouvelle_ascension():
	$BoutonMenuPrincipal.show()
	$BoutonStatistiques.show()
	# Reset le max de la jauge de plateaux
	reset_jauge_LongueurAscension()
	$LongueurAscension.show()
	
	_afficher_message("")
	$BoutonCommencer.show()

func afficher_accueil_ascension_en_cours():
	$BoutonMenuPrincipal.show()
	$BoutonStatistiques.show()
	mettre_a_jour_infos_joueur()
	$InfosDuJoueur.show()
	
	_afficher_message("Poursuivre l'ascension!")
	# Attendre l'affichage du texte
	await get_tree().create_timer(0.5).timeout
	$BoutonCommencer.show()

func _afficher_message(texte : String, tempo : float = 1.0):
	$Message.hide()
	$Message.text = texte
	$Message.show()
	await get_tree().create_timer(tempo).timeout
	$Message.hide()

func _afficher_des_messages(les_message : Array[String], tempo : float = 1.0):
	for message in les_message:
		# pas d'appel à '_afficher_message'
		# pour que 'await' soit bloquant entre les messages
		$Message.hide()
		$Message.text = message
		$Message.show()
		await get_tree().create_timer(tempo).timeout
		$Message.hide()

func _on_bouton_commencer_pressed() -> void:
	AudioService.son_menu_click()
	commencer_plateau.emit()

func _on_bouton_menu_principal_pressed() -> void:
	AudioService.son_menu_click()
	get_tree().change_scene_to_file("res://Scenes/MenuPrincipal/menu_principal.tscn")

func _on_bouton_statistiques_pressed() -> void:
	AudioService.son_menu_click()
	get_tree().change_scene_to_file("res://Scenes/Statistiques/statistiques.tscn")



func afficher_plateau_suivant(texte : String):
	_afficher_message(texte)
	mettre_a_jour_infos_joueur()
	$BoutonMenuPrincipal.show()
	$BoutonStatistiques.show()
	$InfosDuJoueur.show()
	# Attendre l'affichage du texte
	await get_tree().create_timer(0.5).timeout
	$BoutonCommencer.show()

func afficher_plateau_invalide():
	# Pas de plateau invalide en campagne
	pass

func afficher_abandonner_un_plateau():
	_afficher_des_messages(["Perdu!",
							"Fin de Partie",
							"Plateau suivant!"])
	$BoutonMenuPrincipal.show()
	$BoutonStatistiques.show()
	mettre_a_jour_infos_joueur()
	$InfosDuJoueur.show()
	
	# Attendre l'affichage du texte
	await get_tree().create_timer(3.0).timeout
	$BoutonCommencer.show()

func afficher_gagner_un_plateau(duree : int) -> void:
	_afficher_message("Bravo!", 0.5)
	# Attendre l'affichage du texte
	await get_tree().create_timer(0.5).timeout
	$MessageRiche.show()
	# Affichage minimum de 1s
	await get_tree().create_timer(1.0).timeout
	await fin_lecture_score
	$MessageRiche.hide()
	afficher_plateau_suivant("Plateau suivant!")

func afficher_fin_ascension():
	$MessageRiche.show()
	# Affichage minimum de 1s
	await get_tree().create_timer(1.0).timeout
	await fin_lecture_score
	$MessageRiche.hide()
	_afficher_des_messages(["Bravo!",
							"C'était le dernier plateau!",
							"Vous êtes au sommet...",
							"...de l'Everest!"], 3.0)
	# Attendre l'affichage du texte
	await get_tree().create_timer(4*3.0).timeout
	afficher_plateau_suivant("Ascension suivante!")
	afficher_accueil_nouvelle_ascension()

func afficher_fin_campagne():
	$MessageRiche.show()
	# Affichage minimum de 1s
	await get_tree().create_timer(1.0).timeout
	await fin_lecture_score
	$MessageRiche.hide()
	_afficher_des_messages(["Félicitation!",
							"C'était le dernier plateau...",
							"...de la dernière ascension.",
							"Vous êtes au sommet...",
							"Savourez l'instant."], 5.0)
	# Attendre l'affichage du texte
	await get_tree().create_timer(5*5.0).timeout
	$BoutonMenuPrincipal.show()
	$BoutonStatistiques.show()
	mettre_a_jour_infos_joueur()
	$InfosDuJoueur.show()


# LongueurAscension
###################

var longueur_max_ascension : int = 0

func enregistrer_longueur_max_ascension(max : int) -> void:
	longueur_max_ascension = max

func reset_jauge_LongueurAscension():
	var pourcentage_min = 100. / longueur_max_ascension
	# Incrément par plateau
	$LongueurAscension/VBox/Curseur.step = pourcentage_min
	# 1 plateau minimum
	$LongueurAscension/VBox/Curseur.min_value = pourcentage_min
	
	# Initialisé à 100% par défaut
	$LongueurAscension/VBox/Curseur.value = 100
	$LongueurAscension/VBox/Pourcentage.value = 100
	_on_h_slider_value_changed(100.)

func _on_h_slider_value_changed(value: float) -> void:
	# Repercuter sur la valeur
	$LongueurAscension/VBox/Pourcentage.value = value
	# Repercuter sur le nombre de plateaux
	var nb_plateaux = roundi(value / 100. * longueur_max_ascension)
	if nb_plateaux > 1:
		$LongueurAscension/VBox/NombreDePlateaux.text = str(nb_plateaux) +" plateaux"
	else:
		$LongueurAscension/VBox/NombreDePlateaux.text = str(nb_plateaux) +" plateau"

func _on_progression_campagne_service_detail_score_plateau(detail_score: Dictionary):
	afficher_detail_score(detail_score)

func _on_message_riche_gui_input(event: InputEvent) -> void:
	print('click score !!!')
	fin_lecture_score.emit()
