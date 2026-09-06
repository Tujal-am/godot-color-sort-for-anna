extends Control

func _ready():
	set_process_input(true) # Pour retourner dans le menu de campagne.
	var nom_joueur = $Marge/HBoxContainer/VBoxContainer/Nom_Joueur
	nom_joueur.text = StatsService.campagne_nom_joueur()
	campagne()
	niveaux()
	difficultes()
	plateaux()

	# TODO : Poursuivre les statistiques
	## Graphiques
	#var WinLossBarChart = $Marge/HBoxContainer/VBoxContainer/Charts/WinLossBarChart
	#WinLossBarChart.wins = 15
	#WinLossBarChart.losses = 7
	#WinLossBarChart.queue_redraw()
#
	#var PlaytimeLineChart = $Marge/HBoxContainer/VBoxContainer/Charts/PlaytimeLineChart
	#PlaytimeLineChart.monthly_minutes = [120, 90, 150, 200, 180, 220]
	#PlaytimeLineChart.queue_redraw()
#
	## Jauge
	#$Marge/HBoxContainer/VBoxContainer/MonthlyPlaytimeGauge.set_progress(120, 300)


func _input(event):
	if event is InputEventMouseButton and event.pressed:
		AudioService.son_menu_click()
		if SauvegardeBddJoueursService.campagne_la_campagne_est_terminee():
			# Retour au menu principal
			get_tree().change_scene_to_file("res://Scenes/MenuPrincipal/menu_principal.tscn")
		else:
			# Retour au menu de campagne
			get_tree().change_scene_to_file("res://Scenes/MenuPrincipal/Campagne/campagne.tscn")


func campagne():
	# Identifier le joueur
	# Consulter la BDD pour obtenir les indicateurs à afficher
	var valeur
	# TODO : campagne : diagrammes et courbes
	
	# Largeur du titre 'Campagne'
	$"Marge/HBoxContainer/VBoxContainer/Titre Campagne".set_minimum_size(Vector2(430,25))

	# KPI
	var KPI_Completion = $Marge/HBoxContainer/VBoxContainer/KPI_Campagne/KPI_Completion
	KPI_Completion.set_title("Complétion")
	valeur = StatsService.campagne_taux_completion()
	valeur = str_arrondir_pourcentage(valeur)
	KPI_Completion.set_value(valeur)
	KPI_Completion.set_color(Color("ffe6f3ff"), Color('DEEP_PINK'))
	KPI_Completion.set_minimum_size(Vector2(105,50))

	var KPI_Temps = $Marge/HBoxContainer/VBoxContainer/KPI_Campagne/KPI_Temps
	KPI_Temps.set_title("Temps")
	valeur = StatsService.campagne_temps_total_en_s()
	valeur = str_arrondir_temps_en_s(valeur)
	KPI_Temps.set_value(valeur)
	KPI_Temps.set_color(Color("ffe6f3ff"), Color('DEEP_PINK'))
	KPI_Temps.set_minimum_size(Vector2(105,50))

	var KPI_TauxReussite = $Marge/HBoxContainer/VBoxContainer/KPI_Campagne/KPI_TauxReussite
	KPI_TauxReussite.set_title("Réussite")
	valeur = StatsService.campagne_taux_reussite()
	valeur = str_arrondir_pourcentage(valeur)
	KPI_TauxReussite.set_value(valeur)
	KPI_TauxReussite.set_color(Color("ffe6f3ff"), Color('DEEP_PINK'))
	KPI_TauxReussite.set_minimum_size(Vector2(105,50))

	var KPI_SerieMaximumSucces = $Marge/HBoxContainer/VBoxContainer/KPI_Campagne/KPI_SerieMaximumSucces
	KPI_SerieMaximumSucces.set_title("Série Max.")
	valeur = StatsService.campagne_serie_max_reussite()
	KPI_SerieMaximumSucces.set_value(valeur)
	KPI_SerieMaximumSucces.set_color(Color("ffe6f3ff"), Color('DEEP_PINK'))
	KPI_SerieMaximumSucces.set_minimum_size(Vector2(105,50))

func niveaux():
	# Identifier le joueur
	# Consulter la BDD pour obtenir les indicateurs à afficher
	var valeur
	# TODO : niveaux : diagrammes et courbes

	# Largeur du titre 'Niveau'
	$"Marge/HBoxContainer/VBoxContainer/Titre Niveau".set_minimum_size(Vector2(365,25))

	# KPI
	# Ligne 1
	var KPI_Completion = $Marge/HBoxContainer/VBoxContainer/KPI_Niveau/KPI_Completion
	KPI_Completion.set_title("Complétion")
	valeur = StatsService.niveau_taux_completion()
	valeur = str_arrondir_pourcentage(valeur)
	KPI_Completion.set_value(valeur)
	KPI_Completion.set_color(Color("WHITE"), Color('00a7f9'))
	KPI_Completion.set_minimum_size(Vector2(120,50))

	var KPI_Terminees = $Marge/HBoxContainer/VBoxContainer/KPI_Niveau/KPI_Terminees
	KPI_Terminees.set_title("Terminées")
	valeur = StatsService.niveau_terminees()
	KPI_Terminees.set_value(valeur)
	KPI_Terminees.set_color(Color("WHITE"), Color('00a7f9'))
	KPI_Terminees.set_minimum_size(Vector2(120,50))

	var KPI_Longueur = $Marge/HBoxContainer/VBoxContainer/KPI_Niveau/KPI_Longueur
	KPI_Longueur.set_title("Longueur Max.")
	valeur = StatsService.niveau_longueur_max()
	KPI_Longueur.set_value(valeur)
	KPI_Longueur.set_color(Color("WHITE"), Color('00a7f9'))
	KPI_Longueur.set_minimum_size(Vector2(120,50))

	# Ligne 2
	var KPI_MinMax_Titre = $Marge/HBoxContainer/VBoxContainer/KPI_Niveau2/KPI_MinMax_Titre
	KPI_MinMax_Titre.set_title("Réussite Min/Max")
	KPI_MinMax_Titre.set_value("Longueur")
	KPI_MinMax_Titre.set_color(Color("WHITE"), Color('00a7f9'))
	KPI_MinMax_Titre.set_minimum_size(Vector2(160,50))

	var KPI_Taux_Min = $Marge/HBoxContainer/VBoxContainer/KPI_Niveau2/KPI_Taux_Min
	var taux_reussite = StatsService.niveau_taux_reussite_infos()
	valeur = str_arrondir_pourcentage(taux_reussite.get('taux_min'))
	KPI_Taux_Min.set_title(valeur)
	KPI_Taux_Min.set_value(taux_reussite.get('taux_min_lg'))
	KPI_Taux_Min.set_color(Color("WHITE"), Color('00a7f9'))
	KPI_Taux_Min.set_minimum_size(Vector2(100,50))

	var KPI_Taux_Max = $Marge/HBoxContainer/VBoxContainer/KPI_Niveau2/KPI_Taux_Max
	valeur = str_arrondir_pourcentage(taux_reussite.get('taux_max'))
	KPI_Taux_Max.set_title(valeur)
	KPI_Taux_Max.set_value(taux_reussite.get('taux_max_lg'))
	KPI_Taux_Max.set_color(Color("WHITE"), Color('00a7f9'))
	KPI_Taux_Max.set_minimum_size(Vector2(100,50))

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

	# Largeur du titre 'Plateau'
	$"Marge/HBoxContainer/VBoxContainer/Titre Plateau".set_minimum_size(Vector2(245,25))

	# KPI
	# Ligne 1
	var KPI_MoyenTitre = $Marge/HBoxContainer/VBoxContainer/KPI_Plateau3/KPI_MoyenTitre
	KPI_MoyenTitre.set_title("Temps")
	KPI_MoyenTitre.set_value("Moyen")
	KPI_MoyenTitre.set_color(Color("WHITE"), Color('b067ef'))
	KPI_MoyenTitre.set_minimum_size(Vector2(120,50))

	var KPI_MoyenTemps = $Marge/HBoxContainer/VBoxContainer/KPI_Plateau3/KPI_MoyenTemps
	KPI_MoyenTemps.set_title("Temps")
	var temps_moyen = StatsService.plateau_temps_moyen_en_s()
	valeur = str_arrondir_temps_en_s(temps_moyen)
	KPI_MoyenTemps.set_value(valeur)
	KPI_MoyenTemps.set_color(Color("WHITE"), Color('b067ef'))
	KPI_MoyenTemps.set_minimum_size(Vector2(120,50))
	
	# Ligne 2
	var KPI_RapideTitre = $Marge/HBoxContainer/VBoxContainer/KPI_Plateau/KPI_RapideTitre
	KPI_RapideTitre.set_title("Le Plus")
	KPI_RapideTitre.set_value("Rapide")
	KPI_RapideTitre.set_color(Color("WHITE"), Color('b067ef'))
	KPI_RapideTitre.set_minimum_size(Vector2(120,50))

	var KPI_RapideTemps = $Marge/HBoxContainer/VBoxContainer/KPI_Plateau/KPI_RapideTemps
	KPI_RapideTemps.set_title("Temps")
	var plus_rapide = StatsService.plateau_plus_rapide_infos()
	valeur = str_arrondir_temps_en_s(plus_rapide.get('temps_en_s'))
	KPI_RapideTemps.set_value(valeur)
	KPI_RapideTemps.set_color(Color("WHITE"), Color('b067ef'))
	KPI_RapideTemps.set_minimum_size(Vector2(120,50))

	var KPI_RapideDifficulte = $Marge/HBoxContainer/VBoxContainer/KPI_Plateau/KPI_RapideDifficulte
	KPI_RapideDifficulte.set_title("Difficulté")
	valeur = plus_rapide.get('difficulte')
	KPI_RapideDifficulte.set_value(valeur)
	KPI_RapideDifficulte.set_color(Color("WHITE"), Color('b067ef'))
	KPI_RapideDifficulte.set_minimum_size(Vector2(120,50))
	
	# Ligne 3
	var KPI_LentTitre = $Marge/HBoxContainer/VBoxContainer/KPI_Plateau2/KPI_LentTitre
	KPI_LentTitre.set_title("Le Plus")
	KPI_LentTitre.set_value("Lent")
	KPI_LentTitre.set_color(Color("WHITE"), Color('b067ef'))
	KPI_LentTitre.set_minimum_size(Vector2(120,50))

	var KPI_LentTemps = $Marge/HBoxContainer/VBoxContainer/KPI_Plateau2/KPI_LentTemps
	KPI_LentTemps.set_title("Temps")
	var plus_lent = StatsService.plateau_plus_lent_infos()
	valeur = str_arrondir_temps_en_s(plus_lent.get('temps_en_s'))
	KPI_LentTemps.set_value(valeur)
	KPI_LentTemps.set_color(Color("WHITE"), Color('b067ef'))
	KPI_LentTemps.set_minimum_size(Vector2(120,50))

	var KPI_LentDifficulte = $Marge/HBoxContainer/VBoxContainer/KPI_Plateau2/KPI_LentDifficulte
	KPI_LentDifficulte.set_title("Difficulté")
	valeur = plus_lent.get('difficulte')
	KPI_LentDifficulte.set_value(valeur)
	KPI_LentDifficulte.set_color(Color("WHITE"), Color('b067ef'))
	KPI_LentDifficulte.set_minimum_size(Vector2(120,50))
	
	# Ligne 4
	var KPI_GalereTitre = $Marge/HBoxContainer/VBoxContainer/KPI_Plateau4/KPI_GalereTitre
	KPI_GalereTitre.set_title("Le Plus")
	KPI_GalereTitre.set_value("Galère")
	KPI_GalereTitre.set_color(Color("WHITE"), Color('b067ef'))
	KPI_GalereTitre.set_minimum_size(Vector2(120,50))

	var KPI_GalereEssais = $Marge/HBoxContainer/VBoxContainer/KPI_Plateau4/KPI_GalereEssais
	KPI_GalereEssais.set_title("Essais")
	var plus_galere = StatsService.plateau_plus_galere_infos()
	valeur = plus_galere.get('essais')
	KPI_GalereEssais.set_value(valeur)
	KPI_GalereEssais.set_color(Color("WHITE"), Color('b067ef'))
	KPI_GalereEssais.set_minimum_size(Vector2(120,50))

	var KPI_GalereDifficulte = $Marge/HBoxContainer/VBoxContainer/KPI_Plateau4/KPI_GalereDifficulte
	KPI_GalereDifficulte.set_title("Difficulté")
	valeur = plus_galere.get('difficulte')
	KPI_GalereDifficulte.set_value(valeur)
	KPI_GalereDifficulte.set_color(Color("WHITE"), Color('b067ef'))
	KPI_GalereDifficulte.set_minimum_size(Vector2(120,50))
	
	# TODO : representer le plateau en miniature

func str_arrondir_pourcentage(pourcentage: float) -> String:
	# Passage en pourcentage * 100
	pourcentage = 100. * pourcentage
	# Précision du pourcentage selon le taux.
	if pourcentage < 1.0:
		# 2 decimales
		return str(round(pourcentage * 100) / 100.0) + '%'
	elif pourcentage < 10.0:
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
		var min = floori(temps/60.)
		var sec = roundi(fmod(temps, 60.))
		return str(min) + 'min ' + str(sec) + 's'
	else:
		# En heure + minutes + secondes (arrondi)
		var heure = floori(temps/3600.)
		var min = floori((temps - heure * 3600.) / 60.)
		var sec = roundi(fmod(temps, 60.))
		return str(heure) + 'h ' + str(min) + 'min' + str(sec) + 's'
