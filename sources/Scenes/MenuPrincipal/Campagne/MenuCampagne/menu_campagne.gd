extends CanvasLayer

class_name MenuCampagne

var _classique_background: TextureRect
var _classique_hud: Control
var _qpg_before: Control
var _classique_heritage_detache: Array[Dictionary] = []

signal score_continuer

var formatter := FormatterMenuCampagne.new()
var beta_test: bool = true

# Notifie la scene `Plateau` que le bouton est pressé
signal commencer_plateau

enum ActionApresPartage { AUCUNE, NIVEAU_SUIVANT, STATISTIQUES }

var _action_apres_partage: ActionApresPartage = ActionApresPartage.AUCUNE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connecter les signaux attendus
	var pcs = get_node("/root/ProgressionCampagneService")
	pcs.detail_score_plateau.connect(_on_progression_campagne_service_detail_score_plateau)
	pcs.fin_campagne.connect(_on_progression_campagne_service_fin_campagne)
	_initialiser_presentation_classique()

func _initialiser_presentation_classique() -> void:
	_classique_background = $ClassiqueBackground
	_classique_hud = $ClassiqueHud
	_qpg_before = $QpgBefore
	_classique_hud.action_requested.connect(_on_classique_hud_action)
	_qpg_before.action_requested.connect(_on_qpg_hud_action)
	_classique_background.hide()
	_classique_hud.hide()
	_qpg_before.hide()

func detacher_heritage_classique() -> void:
	if not _classique_heritage_detache.is_empty():
		return
	for node_name in ["BoutonMenuPrincipal", "BoutonStatistiques", "InfosDuJoueur", "BoutonCommencer"]:
		var node := get_node_or_null(node_name) as CanvasItem
		if node:
			_classique_heritage_detache.append({"node": node, "index": node.get_index()})
	for entry in _classique_heritage_detache:
		var node: Node = entry["node"]
		remove_child(node)

func _reattacher_heritage_classique() -> void:
	_classique_heritage_detache.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["index"]) < int(b["index"]))
	for entry in _classique_heritage_detache:
		var node: Node = entry["node"]
		if is_instance_valid(node) and node.get_parent() == null:
			add_child(node)
			move_child(node, mini(int(entry["index"]), get_child_count() - 1))
	_classique_heritage_detache.clear()

func _mettre_a_jour_hud_classique() -> void:
	var niveau := SauvegardeBddJoueursService.enregistrement_lire_valeur_niveau_joueur()
	if not SauvegardeBddJoueursService.enregistrement_niveau_en_cours():
		niveau = SauvegardeBddJoueursService.lire_prochain_niveau_de_campagne()
	var rang := SauvegardeTableauDesScoresService.lire_rang_joueur(SauvegardeBddJoueursService.lire_nom_joueur())
	var medaille: String = {1: "or", 2: "argent", 3: "bronze"}.get(rang, "bronze")
	var progression := float(SauvegardeBddJoueursService.lire_pourcentage_niveau_realise()) / 100.0
	_classique_hud.set_profile(SauvegardeBddJoueursService.lire_nom_joueur(), niveau, progression, medaille)

func _mode_qpg() -> bool:
	return SauvegardeBddJoueursService.enregistrement_lire_gameplay_plateau() == "QUI_PERD_GAGNE"

func _mettre_a_jour_hud_qpg() -> void:
	var niveau := SauvegardeBddJoueursService.enregistrement_lire_valeur_niveau_joueur()
	if not SauvegardeBddJoueursService.enregistrement_niveau_en_cours():
		niveau = SauvegardeBddJoueursService.lire_prochain_niveau_de_campagne()
	var rang := SauvegardeTableauDesScoresService.lire_rang_joueur(SauvegardeBddJoueursService.lire_nom_joueur())
	var medaille: String = {1:"or", 2:"argent", 3:"bronze"}.get(rang, "bronze")
	var progression := float(SauvegardeBddJoueursService.lire_pourcentage_niveau_realise()) / 100.0
	_qpg_before.set_profile(SauvegardeBddJoueursService.lire_nom_joueur(), niveau, progression, medaille)

func _on_qpg_hud_action(action: String) -> void:
	match action:
		"home": _on_bouton_menu_principal_pressed()
		"stats": _on_bouton_statistiques_pressed()
		"play": _on_bouton_commencer_pressed()

func _activer_presentation_classique(activer: bool, restaurer_anciens_controles := true) -> void:
	if activer:
		detacher_heritage_classique()
		_classique_background.show()
		_classique_hud.show()
		_classique_hud.set_active(false)
		_mettre_a_jour_hud_classique()
	else:
		_classique_background.hide()
		_classique_hud.hide()
		if restaurer_anciens_controles:
			_reattacher_heritage_classique()

func _on_classique_hud_action(action: String) -> void:
	match action:
		"home":
			_on_bouton_menu_principal_pressed()
		"stats":
			_on_bouton_statistiques_pressed()
		"play":
			_on_bouton_commencer_pressed()

# ###### SIGNAUX##########
func _on_progression_campagne_service_detail_score_plateau(detail_score: Dictionary):
	afficher_detail_score(detail_score)

func _on_progression_campagne_service_fin_campagne() -> void:
	_on_bouton_statistiques_pressed()

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
	_reattacher_heritage_classique()
	$Centrer.hide()
	$Centrer/PanneauDefaite.hide()
	$BoutonCommencer.show()
	score_continuer.emit() #Redonner la main à "campagne" pour la suite

func _on_panneau_victoire_plateau_continuer() -> void:
	_reattacher_heritage_classique()
	$Centrer.hide()
	$Centrer/PanneauVictoirePlateau.hide()
	$BoutonCommencer.show()
	score_continuer.emit() #Redonner la main à "campagne" pour la suite

func _on_panneau_victoire_niveau_continuer() -> void:
	_action_apres_partage = ActionApresPartage.NIVEAU_SUIVANT
	_afficher_partage_dernier_niveau()

func _on_panneau_victoire_campagne_continuer() -> void:
	_action_apres_partage = ActionApresPartage.STATISTIQUES
	_afficher_partage_dernier_niveau()

func _on_panneau_partage_performances_fermer() -> void:
	$Centrer/PanneauPartagePerformances.hide()
	$Centrer.hide()

	var action := _action_apres_partage
	_action_apres_partage = ActionApresPartage.AUCUNE
	match action:
		ActionApresPartage.NIVEAU_SUIVANT:
			_reattacher_heritage_classique()
			$BoutonCommencer.show()
			score_continuer.emit()
		ActionApresPartage.STATISTIQUES:
			_on_bouton_statistiques_pressed()
			score_continuer.emit()

func _afficher_partage_dernier_niveau() -> void:
	$Centrer.hide()
	$Centrer/PanneauVictoireNiveau.hide()
	$Centrer/PanneauVictoireCampagne.hide()
	var bouton_commencer := get_node_or_null("BoutonCommencer") as CanvasItem
	if bouton_commencer:
		bouton_commencer.hide()
	if beta_test:
		var bouton_fermer := $Centrer/PanneauPartagePerformances.get_node_or_null("BoutonFermer") as Button
		if bouton_fermer:
			bouton_fermer.text = "Niveau suivant" if _action_apres_partage == ActionApresPartage.NIVEAU_SUIVANT else "Voir les statistiques"
		$Centrer/PanneauPartagePerformances.afficher_dernier_niveau()
		$Centrer.show()
	else:
		_on_panneau_partage_performances_fermer()

## Affiche le panneau de partage à partir des enregistrements du dernier niveau terminé.
func afficher_partage_performances(enregistrements: Dictionary) -> void:
	$Centrer/PanneauDefaite.hide()
	$Centrer/PanneauVictoirePlateau.hide()
	$Centrer/PanneauVictoireNiveau.hide()
	$Centrer/PanneauVictoireCampagne.hide()
	$Centrer/PanneauPartagePerformances.afficher(enregistrements)
	$Centrer.show()



func mettre_a_jour_infos_joueur() -> void:
	_reattacher_heritage_classique()
	$InfosDuJoueur/TexteInfosDuJoueur.bbcode_text = formatter.formater_infos_joueur()

func afficher_plateau_suivant():
	if _mode_qpg():
		detacher_heritage_classique()
		_classique_background.hide()
		_classique_hud.hide()
		_qpg_before.show()
		_qpg_before.set_state_active(true)
		_mettre_a_jour_hud_qpg()
		return
	_qpg_before.hide()
	_reattacher_heritage_classique()
	$BoutonMenuPrincipal.show()
	$BoutonStatistiques.show()
	mettre_a_jour_infos_joueur()
	$InfosDuJoueur.show()
	$BoutonCommencer.show()
	_activer_presentation_classique(true)

func cacher_accueil():
	_qpg_before.hide()
	_activer_presentation_classique(false, false)
	# Legacy controls are detached while the replacement gameplay UI is active.
	for node_name in ["BoutonMenuPrincipal", "BoutonStatistiques", "InfosDuJoueur", "BoutonCommencer"]:
		var node := get_node_or_null(node_name) as CanvasItem
		if node:
			node.hide()



func afficher_plateau_invalide():
	# Pas de plateau invalide en campagne
	pass

func afficher_abandonner_un_plateau():
	if not _classique_heritage_detache.is_empty() and SauvegardeBddJoueursService.enregistrement_lire_gameplay_plateau() == "CLASSIQUE":
		# Garder l’habillage Classique derrière le panneau, sans réafficher son ancien bandeau.
		_classique_background.show()
		_classique_hud.show()
		_classique_hud.set_active(false)
		_mettre_a_jour_hud_classique()
	else:
		_activer_presentation_classique(false, false)
		mettre_a_jour_infos_joueur()
		$BoutonMenuPrincipal.show()
		$BoutonStatistiques.show()
		$InfosDuJoueur.show()
	
	$Centrer.show()
	$Centrer/PanneauDefaite.show()

func afficher_passer_un_plateau():
	if _mode_qpg():
		detacher_heritage_classique()
		_classique_background.hide()
		_classique_hud.hide()
		_qpg_before.show()
		_qpg_before.set_state_active(true)
		_mettre_a_jour_hud_qpg()
		return
	_qpg_before.hide()
	mettre_a_jour_infos_joueur()
	$BoutonMenuPrincipal.show()
	$BoutonStatistiques.show()
	$InfosDuJoueur.show()

	# TODO : Panneau pour le plateau passé
	$BoutonCommencer.show()
	# $Centrer.show()
	# $Centrer/PanneauPasse.show()
	_activer_presentation_classique(true)

func afficher_gagner_un_plateau() -> void:
	_activer_presentation_classique(false, false)
	# TODO : Insérer ici un message positif pour le joueur apres le score
	pass

func afficher_fin_niveau():
	_activer_presentation_classique(false, false)
	# TODO : Insérer ici un message positif pour le joueur apres le score
	pass

func afficher_fin_campagne():
	_activer_presentation_classique(false, false)
	# TODO : Insérer ici un message positif pour le joueur apres le score
	var bouton_commencer := get_node_or_null("BoutonCommencer") as CanvasItem
	if bouton_commencer:
		bouton_commencer.hide()



# ##########################
# Panneau de détail du score
func afficher_detail_score(detail_score : Dictionary) -> void:
	_activer_presentation_classique(false, false)
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
