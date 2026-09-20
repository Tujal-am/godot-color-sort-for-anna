extends CanvasLayer

class_name MenuCampagne

signal score_continuer

var formatter := FormatterMenuCampagne.new()

# Notifie la scene `Plateau` que le bouton est pressé
signal commencer_plateau


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connecter les signaux attendus
	var pcs = get_node("/root/ProgressionCampagneService")
	pcs.detail_score_plateau.connect(_on_progression_campagne_service_detail_score_plateau)

# ###### SIGNAUX##########
func _on_progression_campagne_service_detail_score_plateau(detail_score: Dictionary):
	afficher_detail_score(detail_score)

func _on_bouton_menu_principal_pressed() -> void:
	AudioService.son_menu_click()
	VibrationService.vibration_click()
	get_tree().change_scene_to_file("res://Scenes/MenuPrincipal/menu_principal.tscn")

func _on_bouton_statistiques_pressed() -> void:
	AudioService.son_menu_click()
	VibrationService.vibration_click()
	get_tree().change_scene_to_file("res://Scenes/MenuPrincipal/Campagne/MenuCampagne/Statistiques/statistiques.tscn")

func _on_bouton_commencer_pressed() -> void:
	AudioService.son_menu_click()
	VibrationService.vibration_click()
	var date_debut_campagne = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	if Time.get_unix_time_from_system() < date_debut_campagne:
		var datetime_debut_campagne = Time.get_datetime_dict_from_unix_time( date_debut_campagne )
		var annee = datetime_debut_campagne.get('year')
		var mois = datetime_debut_campagne.get('month')
		var jour = datetime_debut_campagne.get('day')
		# var heure = datetime_debut_campagne.get('hour')
		# var minute = datetime_debut_campagne.get('minute')

		# TODO : Faire un message pour l'usager.
		# var message = "Soyez patient, la campagne commence le " \
		# 	+ str(jour).pad_zeros(2) +"/"+str(mois).pad_zeros(2)+"/"+str(annee)+"."
		# afficher_message_simple(message, 5.)
	else:
		commencer_plateau.emit()

# ###### SIGNAUX##########
# Panneau de détail du score
func _on_panneau_defaite_continuer() -> void:
	$Centrer.hide()
	$Centrer/PanneauDefaite.hide()
	$BoutonCommencer.show()
	score_continuer.emit() #Redonner la main à "campagne" pour la suite

func _on_panneau_victoire_plateau_continuer() -> void:
	$Centrer.hide()
	$Centrer/PanneauVictoirePlateau.hide()
	$BoutonCommencer.show()
	score_continuer.emit() #Redonner la main à "campagne" pour la suite

func _on_panneau_victoire_niveau_continuer() -> void:
	$Centrer.hide()
	$Centrer/PanneauVictoireNiveau.hide()
	$BoutonCommencer.show()
	score_continuer.emit() #Redonner la main à "campagne" pour la suite

func _on_panneau_victoire_campagne_continuer() -> void:
	$Centrer.hide()
	$Centrer/PanneauVictoireCampagne.hide()
	_on_bouton_statistiques_pressed()
	score_continuer.emit() #Redonner la main à "campagne" pour la suite



func mettre_a_jour_infos_joueur() -> void:
	$InfosDuJoueur/TexteInfosDuJoueur.bbcode_text = formatter.formater_infos_joueur()

func afficher_plateau_suivant():
	$BoutonMenuPrincipal.show()
	$BoutonStatistiques.show()
	mettre_a_jour_infos_joueur()
	$InfosDuJoueur.show()
	$BoutonCommencer.show()

func cacher_accueil():
	$BoutonMenuPrincipal.hide()
	$BoutonStatistiques.hide()
	$InfosDuJoueur.hide()
	$BoutonCommencer.hide()



func afficher_plateau_invalide():
	# Pas de plateau invalide en campagne
	pass

func afficher_abandonner_un_plateau():
	$BoutonMenuPrincipal.show()
	$BoutonStatistiques.show()
	mettre_a_jour_infos_joueur()
	$InfosDuJoueur.show()
	
	$Centrer.show()
	$Centrer/PanneauDefaite.show()

func afficher_gagner_un_plateau() -> void:
	# TODO : Insérer ici un message positif pour le joueur apres le score
	pass

func afficher_fin_niveau():
	# TODO : Insérer ici un message positif pour le joueur apres le score
	pass

func afficher_fin_campagne():
	# TODO : Insérer ici un message positif pour le joueur apres le score
	$BoutonCommencer.hide()



# ##########################
# Panneau de détail du score
func afficher_detail_score(detail_score : Dictionary) -> void:
	if detail_score.get('campagne'):
		afficher_detail_score_campagne(detail_score)
	elif detail_score.get('niveau'):
		afficher_detail_score_niveau(detail_score)
	else:
		afficher_detail_score_plateau(detail_score)

func lire_score_plateau_score(detail_score : Dictionary) -> String:
	if not detail_score:
		return '0'
	var score_total = 0
	score_total += detail_score.get('duree').get('points')
	score_total += detail_score.get('ratio_reussite').get('points')
	score_total += detail_score.get('niveau', {}).get('points', 0)
	score_total += detail_score.get('niveau_parfait', {}).get('points', 0)
	score_total += detail_score.get('campagne', {}).get('points', 0)
	return SauvegardeTableauDesScoresService.nombre_avec_separateur_de_milliers(score_total, '.')

func lire_score_plateau_temps(detail_score_duree : Dictionary) -> Dictionary:
	if not detail_score_duree:
		return {'reference': '-', 'recommence': '-', 'realise': '-', 'points': '0'}
	return {
		'reference': str(detail_score_duree.get('reference')),
		'recommence': str( snapped(detail_score_duree.get('recommence'), 0.1) ),
		'realise': str( snapped(detail_score_duree.get('realise'), 0.1) ),
		'points': SauvegardeTableauDesScoresService.nombre_avec_separateur_de_milliers(detail_score_duree.get('points'), '.')
	}

func lire_score_plateau_ratio_reussite(detail_score_ratio : Dictionary) -> Dictionary:
	if not detail_score_ratio:
		return {'ratio': '-', 'points': '0'}
	return {
		'ratio': str(detail_score_ratio.get('ratio')),
		'points': SauvegardeTableauDesScoresService.nombre_avec_separateur_de_milliers(detail_score_ratio.get('points'), '.')
	}

func lire_score_niveau(detail_score_niveau : Dictionary) -> Dictionary:
	if not detail_score_niveau:
		return {'longueur': '-', 'points': '0'}
	return {
		'longueur': str(detail_score_niveau.get('longueur')),
		'points': SauvegardeTableauDesScoresService.nombre_avec_separateur_de_milliers(detail_score_niveau.get('points'), '.')
	}

func lire_score_niveau_parfait(detail_score_niveau_parfait : Dictionary) -> Dictionary:
	if not detail_score_niveau_parfait:
		return {'bonus': '-', 'points': '0'}
	return {
		'bonus': str(detail_score_niveau_parfait.get('bonus')),
		'points': SauvegardeTableauDesScoresService.nombre_avec_separateur_de_milliers(detail_score_niveau_parfait.get('points'), '.')
	}

func lire_score_campagne(detail_score_campagne : Dictionary) -> String:
	if not detail_score_campagne:
		return '0'
	return SauvegardeTableauDesScoresService.nombre_avec_separateur_de_milliers(detail_score_campagne.get('points'), '.')

func afficher_detail_score_plateau(detail_score : Dictionary) -> void:
	$Centrer/PanneauVictoirePlateau.score_points(lire_score_plateau_score(detail_score))

	var detail_score_duree = lire_score_plateau_temps(detail_score.get('duree'))
	$Centrer/PanneauVictoirePlateau.temps(	detail_score_duree.get('reference'),
											detail_score_duree.get('recommence'),
											detail_score_duree.get('realise'),
											detail_score_duree.get('points'))

	var detail_score_ratio_reussite = lire_score_plateau_ratio_reussite(detail_score.get('ratio_reussite'))
	$Centrer/PanneauVictoirePlateau.ratio(	detail_score_ratio_reussite.get('ratio'),
											detail_score_ratio_reussite.get('points'))

	$Centrer.show()
	$Centrer/PanneauVictoirePlateau.show()

func afficher_detail_score_niveau(detail_score : Dictionary) -> void:
	$Centrer/PanneauVictoireNiveau.score_points(lire_score_plateau_score(detail_score))

	var detail_score_duree = lire_score_plateau_temps(detail_score.get('duree'))
	$Centrer/PanneauVictoireNiveau.temps(	detail_score_duree.get('reference'),
											detail_score_duree.get('recommence'),
											detail_score_duree.get('realise'),
											detail_score_duree.get('points'))

	var detail_score_ratio_reussite = lire_score_plateau_ratio_reussite(detail_score.get('ratio_reussite'))
	$Centrer/PanneauVictoireNiveau.ratio(	detail_score_ratio_reussite.get('ratio'),
											detail_score_ratio_reussite.get('points'))

	var detail_score_niveau = lire_score_niveau(detail_score.get('niveau'))
	$Centrer/PanneauVictoireNiveau.niveau(	detail_score_niveau.get('longueur'),
											detail_score_niveau.get('points'))

	var detail_score_niveau_parfait = lire_score_niveau_parfait(detail_score.get('niveau_parfait'))
	$Centrer/PanneauVictoireNiveau.niveau_parfait(	detail_score_niveau_parfait.get('bonus'),
													detail_score_niveau_parfait.get('points'))

	$Centrer.show()
	$Centrer/PanneauVictoireNiveau.show()

func afficher_detail_score_campagne(detail_score : Dictionary) -> void:
	$Centrer/PanneauVictoireCampagne.score_points(lire_score_plateau_score(detail_score))

	var detail_score_duree = lire_score_plateau_temps(detail_score.get('duree'))
	$Centrer/PanneauVictoireCampagne.temps(	detail_score_duree.get('reference'),
											detail_score_duree.get('recommence'),
											detail_score_duree.get('realise'),
											detail_score_duree.get('points'))

	var detail_score_ratio_reussite = lire_score_plateau_ratio_reussite(detail_score.get('ratio_reussite'))
	$Centrer/PanneauVictoireCampagne.ratio(	detail_score_ratio_reussite.get('ratio'),
											detail_score_ratio_reussite.get('points'))

	var detail_score_niveau = lire_score_niveau(detail_score.get('niveau'))
	$Centrer/PanneauVictoireCampagne.niveau(	detail_score_niveau.get('longueur'),
												detail_score_niveau.get('points'))

	var detail_score_niveau_parfait = lire_score_niveau_parfait(detail_score.get('niveau_parfait'))
	$Centrer/PanneauVictoireCampagne.niveau_parfait(	detail_score_niveau_parfait.get('bonus'),
														detail_score_niveau_parfait.get('points'))

	$Centrer/PanneauVictoireCampagne.campagne(lire_score_campagne(detail_score.get('campagne')))

	$Centrer.show()
	$Centrer/PanneauVictoireCampagne.show()
