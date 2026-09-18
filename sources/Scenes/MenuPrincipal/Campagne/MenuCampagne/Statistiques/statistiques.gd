extends Control

func _ready():
	score()
	campagne()
	niveaux()
	difficultes()
	plateaux()
	classique()
	qui_perd_gagne()

func _on_retour_pressed() -> void:
	AudioService.son_menu_click()
	VibrationService.vibration_click()
	if ProgressionCampagneService.la_campagne_est_terminee():
		# Retour au menu principal
		get_tree().change_scene_to_file("res://Scenes/MenuPrincipal/menu_principal.tscn")
	else:
		# Retour au menu de campagne
		get_tree().change_scene_to_file("res://Scenes/MenuPrincipal/Campagne/campagne.tscn")


func score():
	# Identifier le joueur
	# Consulter la BDD pour obtenir les indicateurs à afficher
	var valeur
	# TODO : score : diagrammes et courbes

	var ui_score = $Scroll/Content/Score

	# TODO : Gerer dans un service le type de medaille.
	ui_score.nom_grade('bronze')
	ui_score.nom_joueur(StatsService.campagne_nom_joueur())
	ui_score.score(StatsService.score().replace('.', ' '))

	valeur = StatsService.score_pourcentage_rapidite()
	valeur = str_arrondir_pourcentage(valeur)
	ui_score.rapidite(valeur)

	valeur = StatsService.score_pourcentage_reussite()
	valeur = str_arrondir_pourcentage(valeur)
	ui_score.reussite(valeur)

	valeur = StatsService.score_pourcentage_niveau()
	valeur = str_arrondir_pourcentage(valeur)
	ui_score.niveau(valeur)

	valeur = StatsService.score_pourcentage_niveau_parfait()
	valeur = str_arrondir_pourcentage(valeur)
	ui_score.parfait(valeur)

	valeur = StatsService.score_pourcentage_fin_campagne()
	valeur = str_arrondir_pourcentage(valeur)
	ui_score.campagne(valeur)

func campagne():
	# Identifier le joueur
	# Consulter la BDD pour obtenir les indicateurs à afficher
	var valeur
	# TODO : campagne : diagrammes et courbes
	
	var ui_campagne = $Scroll/Content/Campagne

	valeur = StatsService.campagne_taux_completion()
	valeur = str_arrondir_pourcentage(valeur)
	ui_campagne.completion(valeur)

	valeur = StatsService.campagne_temps_total_en_s()
	valeur = str_arrondir_temps_en_s(valeur)
	ui_campagne.temps(valeur)

	valeur = StatsService.campagne_taux_reussite()
	valeur = str_arrondir_pourcentage(valeur)
	ui_campagne.reussite(valeur)

	valeur = str(StatsService.campagne_serie_max_reussite())
	ui_campagne.serie_max(valeur)

func niveaux():
	# Identifier le joueur
	# Consulter la BDD pour obtenir les indicateurs à afficher
	var valeur
	# TODO : niveaux : diagrammes et courbes

	var ui_niveau = $Scroll/Content/Niveau
	
	ui_niveau.en_cours(str(SauvegardeBddJoueursService.enregistrement_lire_valeur_niveau_joueur()))

	valeur = StatsService.niveau_taux_completion()
	valeur = str_arrondir_pourcentage(valeur)
	ui_niveau.completion(valeur)

	# TODO : Changer les min_lg/maax_lg en niveau.
	var taux_reussite = StatsService.niveau_taux_reussite_infos()
	valeur = str_arrondir_pourcentage(taux_reussite.get('taux_min'))
	ui_niveau.taux_reussite_minimum(valeur)
	valeur = str_arrondir_pourcentage(taux_reussite.get('taux_min_lg'))
	ui_niveau.difficulte_reussite_minimum(valeur)

	valeur = str_arrondir_pourcentage(taux_reussite.get('taux_max'))
	ui_niveau.taux_reussite_maximum(valeur)
	valeur = str_arrondir_pourcentage(taux_reussite.get('taux_max_lg'))
	ui_niveau.difficulte_reussite_maximum(valeur)

func difficultes():
	# Identifier le joueur
	# Consulter la BDD pour obtenir les indicateurs à afficher
	# TODO : difficultés : diagrammes et courbes

	# KPI
	# TODO : difficultés : KPI
	pass

func plateaux():
	# Identifier le joueur
	# Consulter la BDD pour obtenir les indicateurs à afficher
	var valeur
	# TODO : plateaux : diagrammes et courbes

	var ui_plateau = $Scroll/Content/Plateau

	valeur = str(StatsService.plateau_nombre_de_plateaux_joues())
	ui_plateau.nb_plateaux(valeur)

	var temps_moyen = StatsService.plateau_temps_moyen_en_s()
	valeur = str_arrondir_temps_en_s(temps_moyen)
	ui_plateau.temps_moyen(valeur)

	valeur = StatsService.plateau_taux_de_reussite()
	valeur = str_arrondir_pourcentage(valeur)
	ui_plateau.taux_reussite(valeur)

	var plus_rapide = StatsService.plateau_plus_rapide_infos()
	valeur = str_arrondir_temps_en_s(plus_rapide.get('temps_en_s'))
	ui_plateau.plus_rapide_temps(valeur)
	valeur = str(plus_rapide.get('difficulte'))
	ui_plateau.plus_rapide_difficulte(valeur)

	var plus_lent = StatsService.plateau_plus_lent_infos()
	valeur = str_arrondir_temps_en_s(plus_lent.get('temps_en_s'))
	ui_plateau.plus_lent_temps(valeur)
	valeur = str(plus_lent.get('difficulte'))
	ui_plateau.plus_lent_difficulte(valeur)

	var plus_galere = StatsService.plateau_plus_galere_infos()
	valeur = str(plus_galere.get('essais'))
	ui_plateau.plus_galere_essais(valeur)
	valeur = str(plus_galere.get('difficulte'))
	ui_plateau.plus_galere_difficulte(valeur)

func classique():
	# Identifier le joueur
	# Consulter la BDD pour obtenir les indicateurs à afficher
	var valeur
	# TODO : plateaux : diagrammes et courbes

	var ui_classique = $Scroll/Content/Classique

	valeur = str(StatsService.classique_nombre_de_plateaux_joues())
	ui_classique.nb_plateaux(valeur)

	valeur = StatsService.classique_temps_moyen_en_s()
	valeur = str_arrondir_temps_en_s(valeur)
	ui_classique.temps_moyen(valeur)

	valeur = StatsService.classique_taux_de_reussite()
	valeur = str_arrondir_pourcentage(valeur)
	ui_classique.taux_reussite(valeur)

	var plus_rapide = StatsService.classique_plus_rapide_infos()
	valeur = str_arrondir_temps_en_s(plus_rapide.get('temps_en_s'))
	ui_classique.plus_rapide_temps(valeur)
	valeur = str(plus_rapide.get('difficulte'))
	ui_classique.plus_rapide_difficulte(valeur)

	var plus_lent = StatsService.classique_plus_lent_infos()
	valeur = str_arrondir_temps_en_s(plus_lent.get('temps_en_s'))
	ui_classique.plus_lent_temps(valeur)
	valeur = str(plus_lent.get('difficulte'))
	ui_classique.plus_lent_difficulte(valeur)

	var plus_galere = StatsService.classique_plus_galere_infos()
	valeur = str(plus_galere.get('essais'))
	ui_classique.plus_galere_essais(valeur)
	valeur = str(plus_galere.get('difficulte'))
	ui_classique.plus_galere_difficulte(valeur)
	# TODO : representer le plateau en miniature

func qui_perd_gagne():
	# Identifier le joueur
	# Consulter la BDD pour obtenir les indicateurs à afficher
	var valeur
	# TODO : plateaux : diagrammes et courbes

	var ui_qui_perd_gagne = $Scroll/Content/QuiPerdGagne
	

	valeur = str(StatsService.qui_perd_gagne_nombre_de_plateaux_joues())
	ui_qui_perd_gagne.nb_plateaux(valeur)

	valeur = StatsService.qui_perd_gagne_temps_moyen_en_s()
	valeur = str_arrondir_temps_en_s(valeur)
	ui_qui_perd_gagne.temps_moyen(valeur)

	valeur = StatsService.qui_perd_gagne_taux_de_reussite()
	valeur = str_arrondir_pourcentage(valeur)
	ui_qui_perd_gagne.taux_reussite(valeur)

	var plus_rapide = StatsService.qui_perd_gagne_plus_rapide_infos()
	valeur = str_arrondir_temps_en_s(plus_rapide.get('temps_en_s'))
	ui_qui_perd_gagne.plus_rapide_temps(valeur)
	valeur = str(plus_rapide.get('difficulte'))
	ui_qui_perd_gagne.plus_rapide_difficulte(valeur)

	var plus_lent = StatsService.qui_perd_gagne_plus_lent_infos()
	valeur = str_arrondir_temps_en_s(plus_lent.get('temps_en_s'))
	ui_qui_perd_gagne.plus_lent_temps(valeur)
	valeur = str(plus_lent.get('difficulte'))
	ui_qui_perd_gagne.plus_lent_difficulte(valeur)

	var plus_galere = StatsService.qui_perd_gagne_plus_galere_infos()
	valeur = str(plus_galere.get('essais'))
	ui_qui_perd_gagne.plus_galere_essais(valeur)
	valeur = str(plus_galere.get('difficulte'))
	ui_qui_perd_gagne.plus_galere_difficulte(valeur)
	# TODO : representer le plateau en miniature

func str_arrondir_pourcentage(pourcentage: float) -> String:
	# Passage en pourcentage * 100
	pourcentage = 100. * pourcentage
	# Précision du pourcentage selon le taux.
	if pourcentage < 10.0:
		# 1 decimale
		return str(round(pourcentage * 10) / 10.0) + '%'
	else:
		# 0 decimale
		return str(roundi(pourcentage)) + '%'

func str_arrondir_temps_en_s(temps: float) -> String:
	# Passage en pourcentage * 100
	# Précision du pourcentage selon le taux.
	if temps < 1.:
		# En millissecondes (arrondi)
		return str(roundi(temps * 1000)) + 'ms'
	elif temps < 10.:
		# En secondes avec 1 decimale (arrondi)
		return str(roundi(temps * 10) / 10.) + 's'
	elif temps < 60.: # < 1 min
		# En secondes sans decimale (arrondi)
		return str(roundi(temps)) + 's'
	elif temps < (60. * 60.): # < 1 h
		# En minutes + secondes (arrondi)
		var mins = floori(temps/60.)
		var sec = roundi(fmod(temps, 60.))
		return str(mins) + 'min ' + str(sec) + 's'
	else:
		# En heure + minutes + secondes (arrondi)
		var heure = floori(temps/3600.)
		var mins = floori((temps - heure * 3600.) / 60.)
		return str(heure) + 'h ' + str(mins) + 'min'
