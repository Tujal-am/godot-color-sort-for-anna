extends Node

#func _ready() -> void:
	## TODO : Utile pour les tests de la page.
	##ProgressionCampagneService.choisir_le_joueur_pour_la_campagne("Alain Konu")
	#ProgressionCampagneService.choisir_le_joueur_pour_la_campagne("toto")
	##ProgressionCampagneService.choisir_le_joueur_pour_la_campagne("Anna")

# ########
# Score
func score() -> String:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	return SauvegardeTableauDesScoresService.lire_score_txt_joueur(joueur)

func score_pourcentage_rapidite() -> float:
	return score_total_pourcentage_rapidite()

func score_pourcentage_reussite() -> float:
	return score_total_pourcentage_reussite()

func score_pourcentage_niveau() -> float:
	return score_total_pourcentage_niveau()

func score_pourcentage_niveau_parfait() -> float:
	return score_total_pourcentage_niveau_parfait()

func score_pourcentage_fin_campagne() -> float:
	return score_total_pourcentage_fin_campagne()

# ########
# Campagne
func campagne_nom_joueur() -> String:
	return SauvegardeBddJoueursService.lire_nom_joueur()

func campagne_taux_completion() -> float:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	LogService.log_debug("joueur:",joueur, ' campagne_taux_completion=', taux_completion_campagne())
	return taux_completion_campagne()

func campagne_temps_total_en_s() -> float:
	return duree_totale_plateaux_toutes_les_ascensions_en_s().get('toutes')

func campagne_taux_reussite() -> float:
	return taux_de_reussite_des_plateaux()

func campagne_serie_max_reussite() -> int:
	return serie_de_victoire_maximum()

# #########
# Ascension
func ascension_taux_completion() -> float:
	return taux_completion_ascension()

func ascension_terminees() -> int:
	return nombre_ascensions_terminees()

func ascension_longueur_max() -> int:
	return longueur_max_ascension_terminee()

func ascension_taux_reussite_infos() -> Dictionary:
	"Ascensions taux de réussite : min, max et longueur"
	return ascension_taux_reussite_les_infos()

# #######
# Plateau
func plateau_temps_moyen_en_s() -> float:
	return plateau_le_temps_moyen_en_s()

func plateau_plus_rapide_infos() -> Dictionary:
	return plateau_le_plus_rapide_les_infos()

func plateau_plus_lent_infos() -> Dictionary:
	return plateau_le_plus_lent_les_infos()

func plateau_plus_galere_infos() -> Dictionary:
	return plateau_le_plus_galere_les_infos()

# ####################
# Calculs Statistiques
func detail_score_cumule() -> Dictionary:
	"Taux de complétion de l'ascension en cours"
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var date_debut_campagne = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	# Scores cumulés
	var score_rapidite: int = 0
	var score_reussite: int = 0
	var score_niveau: int = 0
	var score_niveau_parfait: int = 0
	var score_fin_campagne: int = 0

	if SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions", null):
		for ascension in SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions"):
			if "score" in ascension:
				score_niveau += ascension.get("score").get('ascension', 0)
				score_niveau_parfait += ascension.get("score").get('ascension_sans_detour', 0)
			# Comptabiliser les plateaux reussis
			if "plateaux" in ascension:
				for plateau_joue in ascension.get("plateaux"):
					if plateau_joue.get("date_debut") > date_debut_campagne \
						and 'score' in plateau_joue:
						score_rapidite += plateau_joue.get("score").get('duree', 0)
						score_reussite += plateau_joue.get("score").get('ratio_reussite', 0)

	if SauvegardeBddJoueursService.la_campagne_est_terminee():
		score_fin_campagne = 2_000_000

	return {
		'joueur': joueur,
		'rapidite': score_rapidite,
		'reussite': score_reussite,
		'niveau': score_niveau,
		'niveau_parfait': score_niveau_parfait,
		'fin_campagne': score_fin_campagne,
	}

func score_total_pourcentage_rapidite() -> float:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var score_total :int = SauvegardeTableauDesScoresService.lire_score_joueur(joueur)
	var score_rapidite :int = detail_score_cumule().get('rapidite', 0)
	return 1. * score_rapidite / score_total

func score_total_pourcentage_reussite() -> float:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var score_total :int = SauvegardeTableauDesScoresService.lire_score_joueur(joueur)
	var score_reussite :int = detail_score_cumule().get('reussite', 0)
	return 1. * score_reussite / score_total

func score_total_pourcentage_niveau() -> float:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var score_total :int = SauvegardeTableauDesScoresService.lire_score_joueur(joueur)
	var score_niveau :int = detail_score_cumule().get('niveau', 0)
	return 1. * score_niveau / score_total

func score_total_pourcentage_niveau_parfait() -> float:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var score_total :int = SauvegardeTableauDesScoresService.lire_score_joueur(joueur)
	var score_niveau_parfait :int = detail_score_cumule().get('niveau_parfait', 0)
	return 1. * score_niveau_parfait / score_total

func score_total_pourcentage_fin_campagne() -> float:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var score_total :int = SauvegardeTableauDesScoresService.lire_score_joueur(joueur)
	var score_fin_campagne :int = detail_score_cumule().get('fin_campagne', 0)
	return 1. * score_fin_campagne / score_total

func nombre_de_plateau_inacheves() -> int:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	# Nombre de plateau inachevés
	var nb_plateaux_inacheves: int = 0
	# Parcourir la liste des plateaux de chaque niveaux
	if SauvegardeBddJoueursService.sauvegarde_joueur.get("plateaux", null):
		for liste_plateaux in SauvegardeBddJoueursService.sauvegarde_joueur.get("plateaux").values():
			nb_plateaux_inacheves += liste_plateaux.size()
	LogService.log_debug("joueur:",joueur, ' nb_plateaux_inacheves=', nb_plateaux_inacheves)
	return nb_plateaux_inacheves

func nombre_de_plateau_acheves() -> int:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var date_debut_campagne = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	# Nombre de plateau achevés
	var nb_plateaux_acheves: int = 0
	# Parcourir la liste des ascensions
	if SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions", null):
		for ascension in SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions"):
			# Comptabiliser les plateaux reussis
			if ascension.get("plateaux", null):
				for plateau_joue in ascension.get("plateaux"):
					if plateau_joue.get("date_debut") > date_debut_campagne \
						and plateau_joue.get("statut") == "reussi":
						nb_plateaux_acheves += 1
	LogService.log_debug("joueur:",joueur, ' nb_plateaux_acheves=', nb_plateaux_acheves)
	return nb_plateaux_acheves

func nombre_de_plateaux_totaux() -> int:
	return nombre_de_plateau_inacheves() + nombre_de_plateau_acheves()

func taux_completion_campagne() -> float:
	return 1. * nombre_de_plateau_acheves() / nombre_de_plateaux_totaux()

func taux_completion_ascension() -> float:
	"Taux de complétion de l'ascension en cours"
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var date_debut_campagne = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	# Consulter la derniere ascension
	if SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions", null):
		var ascension = SauvegardeBddJoueursService.sauvegarde_joueur.get('ascensions').back()
		if "longueur_initiale" in ascension \
			and not ascension.get('date_fin', null) \
			and ascension.get("date_debut") > date_debut_campagne:
			var lg_initiale: int = ascension.get("longueur_initiale", 0)
			var lg_realisee: int = ascension.get("plateaux", 0).size()
			var lg_detour: int = ascension.get("longueur_detour", 0)
			if (2 * lg_detour) < lg_realisee:
				# Un plateau perdu entraine 2 plateaux supplémentaires.
				var completion: float = 1. * (lg_realisee - 2 * lg_detour) / lg_initiale
				LogService.log_debug("joueur:",joueur,
									' lg_initiale=', lg_initiale,
									' lg_realisee=', lg_realisee,
									' lg_detour=', lg_detour,
									' completion=', completion)
				return completion
	return 0.

func duree_totale_plateaux_toutes_les_ascensions_en_s() -> Dictionary:
	"Durée totale de jeu effectif de plateaux dans les ascensions"
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var date_debut_campagne = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	# Nombre de plateau achevés
	var duree_totale_plateaux_toutes_les_ascensions: float = 0.
	var duree_totale_plateaux_toutes_les_ascensions_terminees: float = 0.
	# Parcourir la liste des ascensions
	if SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions", null):
		for ascension in SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions"):
			# Comptabiliser les plateaux reussis
			if ascension.get("plateaux", null):
				for plateau_joue in ascension.get("plateaux"):
					if plateau_joue.get("date_debut") > date_debut_campagne:
						var duree_en_ms = plateau_joue.get("duree")
						if duree_en_ms:
							# Comptabiliser TOUTES les ascensions
							duree_totale_plateaux_toutes_les_ascensions += duree_en_ms / 1000.
							if ascension.get("date_fin"):
								# Comptabiliser les ascensions TERMINEES
								duree_totale_plateaux_toutes_les_ascensions_terminees += duree_en_ms / 1000.
	LogService.log_debug("joueur:",joueur,
						' duree_totale_plateaux_toutes_les_ascensions=', duree_totale_plateaux_toutes_les_ascensions,
						' duree_totale_plateaux_toutes_les_ascensions_terminees=', duree_totale_plateaux_toutes_les_ascensions_terminees)
	return {
		'toutes': duree_totale_plateaux_toutes_les_ascensions,
		'terminees': duree_totale_plateaux_toutes_les_ascensions_terminees
	}

func nombre_ascensions_terminees() -> int:
	var date_debut_campagne = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	var nb_ascensions: int = 0
	for ascension in SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions"):
		if ascension.get("date_debut") > date_debut_campagne \
			and ascension.get("date_fin"):
			nb_ascensions += 1
	return nb_ascensions

func duree_moyenne_ascensions_terminees_en_s() -> float:
	var nat = nombre_ascensions_terminees()
	if nat == 0:
		return 0.
	var duree_ascensions = duree_totale_plateaux_toutes_les_ascensions_en_s()
	return duree_ascensions.get('terminees') / nombre_ascensions_terminees()

func nombre_de_plateau_reussis_abandonnes() -> Dictionary:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var date_debut_campagne = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	# Nombre de plateau reussis
	var nb_plateaux_reussis: int = 0
	# Nombre de plateau reussis
	var nb_plateaux_abandonnes: int = 0
	# Parcourir la liste des ascensions
	if SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions", null):
		for ascension in SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions"):
			# Comptabiliser les plateaux reussis
			if ascension.get("plateaux", null):
				for plateau_joue in ascension.get("plateaux"):
					if plateau_joue.get("date_debut") > date_debut_campagne:
						if plateau_joue.get("statut") == "reussi":
							nb_plateaux_reussis += 1
						if plateau_joue.get("statut") == "abandonné":
							nb_plateaux_abandonnes += 1
	LogService.log_debug("joueur:",joueur,
						' nb_plateaux_reussis=', nb_plateaux_reussis,
						' nb_plateaux_abandonnes=', nb_plateaux_abandonnes)
	return {'reussis': nb_plateaux_reussis, 'abandonnes': nb_plateaux_abandonnes}

func taux_de_reussite_des_plateaux() -> float:
	var infos_plateaux = nombre_de_plateau_reussis_abandonnes()
	var reussis = infos_plateaux.get('reussis')
	var abandonne = infos_plateaux.get('abandonnes')
	if (reussis + abandonne) == 0:
		return 0.
	return 1. * reussis / (reussis + abandonne)

func longueur_max_ascension_terminee() -> int:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var date_debut_campagne = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	# Nombre de plateau reussis
	var val_longueur_max_ascension_terminee: int = 0
	# Parcourir la liste des ascensions
	if SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions", null):
		for ascension in SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions"):
			# Comptabiliser les plateaux sur les ascensions terminées
			if ascension.get("plateaux", null) \
				and ascension.get("date_fin", null) \
				and ascension.get("date_debut") > date_debut_campagne:
				# Longueur ascension initiale
				var longueur_ascension_initiale: int = ascension.get("longueur_initiale", 0)
				if longueur_ascension_initiale == 0:
					# ancienne facon de retrouver la longueur initiale.
					var echecs = ascension.get("longueur_detour", null)
					var realises = ascension.get("plateaux", null).size()
					longueur_ascension_initiale = realises - (2 * echecs)
				if longueur_ascension_initiale > val_longueur_max_ascension_terminee:
					val_longueur_max_ascension_terminee = longueur_ascension_initiale
	LogService.log_debug("joueur:",joueur, ' val_longueur_max_ascension_terminee=', val_longueur_max_ascension_terminee)
	return val_longueur_max_ascension_terminee

func ascension_taux_reussite_les_infos() -> Dictionary:
	"Retourne le nombre d'ascensions parfaites et la longueur de la plus longue"
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var date_debut_campagne = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	# Nombre d'ascension sans erreur
	var taux_min: float = 101.
	var taux_min_lg: int = 0
	var taux_max: float = -1.
	var taux_max_lg: int = 0
	# Parcourir la liste des ascensions
	if SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions", null):
		for ascension in SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions"):
			if  ascension.get("date_debut") > date_debut_campagne:
				var initial = ascension.get("longueur_initiale", 0)
				var echecs = ascension.get("longueur_detour", null)
				var realises = ascension.get("plateaux", null).size()
				if initial == 0:
					# ancienne facon de retrouver la longueur initiale.
					initial = realises - (2 * echecs)
				var taux = 1. * (realises - echecs) / realises
				if taux < taux_min:
					taux_min = taux
					taux_min_lg = initial
				if taux > taux_max:
					taux_max = taux
					taux_max_lg = initial
	# Gommer les valeurs initiales
	if taux_min == 101.:
		taux_min = 0.
	if taux_max == -1.:
		taux_max = 0.
	LogService.log_debug("joueur:",joueur,
						' taux_min=', taux_min,
						' taux_min_lg=', taux_min_lg,
						' taux_max=', taux_max,
						' taux_max_lg=', taux_max_lg)
	return {'taux_min': taux_min, 'taux_min_lg': taux_min_lg, 'taux_max': taux_max, 'taux_max_lg': taux_max_lg}

func plateau_le_temps_moyen_en_s() -> float:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var date_debut_campagne = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	# Plateau termine le plus vite et sa difficulté
	var temps_total_en_ms: float = 0.
	var nb_plateaux: int = 0
	var temps_moyen_en_s: float = 0.
	# Parcourir la liste des ascensions
	if SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions", null):
		for ascension in SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions"):
			# Comptabiliser les plateaux reussis
			if ascension.get("plateaux", null) \
				and ascension.get("date_debut") > date_debut_campagne:
				for plateau_joue in ascension.get("plateaux"):
					var duree_en_ms = plateau_joue.get("duree", 0)
					if duree_en_ms:
						temps_total_en_ms += duree_en_ms
						nb_plateaux += 1
	if nb_plateaux:
		temps_moyen_en_s = temps_total_en_ms / nb_plateaux / 1000.
	LogService.log_debug("joueur:",joueur,
						' temps_moyen=', temps_moyen_en_s)
	return temps_moyen_en_s

func plateau_le_plus_rapide_les_infos() -> Dictionary:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var date_debut_campagne = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	# Plateau termine le plus vite et sa difficulté
	var plus_rapide_temps: float = 0.
	var plus_rapide_difficulte: int = 0
	# Parcourir la liste des ascensions
	if SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions", null):
		for ascension in SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions"):
			# Comptabiliser les plateaux reussis
			if ascension.get("plateaux", null) \
				and ascension.get("date_debut") > date_debut_campagne:
				for plateau_joue in ascension.get("plateaux"):
					var duree_en_ms = plateau_joue.get("duree", 0)
					if duree_en_ms:
						var difficulte = plateau_joue.get("niveau")
						if duree_en_ms <= plus_rapide_temps or plus_rapide_temps == 0.:
							if duree_en_ms == plus_rapide_temps and difficulte > plus_rapide_difficulte:
								plus_rapide_difficulte = difficulte
							else:
								plus_rapide_temps = duree_en_ms
								plus_rapide_difficulte = difficulte
	LogService.log_debug("joueur:",joueur,
						' plus_rapide_temps=', plus_rapide_temps / 1000.,
						' plus_rapide_difficulte=', plus_rapide_difficulte)
	return {'temps_en_s': plus_rapide_temps / 1000., 'difficulte': plus_rapide_difficulte}

func plateau_le_plus_lent_les_infos() -> Dictionary:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var date_debut_campagne = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	# Plateau le plus lent à résoudre et sa difficulté
	var plus_lent_temps: float = 0.
	var plus_lent_difficulte: int = 0
	# Parcourir la liste des ascensions
	if SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions", null):
		for ascension in SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions"):
			# Comptabiliser les plateaux reussis
			if ascension.get("plateaux", null) \
				and ascension.get("date_debut") > date_debut_campagne:
				for plateau_joue in ascension.get("plateaux"):
					var duree_en_ms = plateau_joue.get("duree", 0)
					if duree_en_ms:
						var difficulte = plateau_joue.get("niveau")
						if duree_en_ms >= plus_lent_temps or plus_lent_temps == 0.:
							if duree_en_ms == plus_lent_temps and difficulte > plus_lent_difficulte:
								plus_lent_difficulte = difficulte
							else:
								plus_lent_temps = duree_en_ms
								plus_lent_difficulte = difficulte
	LogService.log_debug("joueur:",joueur,
						' plus_lent_temps=', plus_lent_temps / 1000.,
						' plus_lent_difficulte=', plus_lent_difficulte)
	return {'temps_en_s': plus_lent_temps / 1000., 'difficulte': plus_lent_difficulte}

func plateau_le_plus_galere_les_infos() -> Dictionary:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var date_debut_campagne = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	# Plateau le plus galère à résoudre et sa difficulté
	var plateaux_essais: Dictionary = {}
	# Parcourir la liste des ascensions et collecter les essais sur chaque plateau
	if SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions", null):
		for ascension in SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions"):
			# Comptabiliser les essais de plateaux
			if ascension.get("plateaux", null) \
				and ascension.get("date_debut") > date_debut_campagne:
				for plateau_joue in ascension.get("plateaux"):
					var nom_plateau = plateau_joue.get("nom", 'inconnu')
					if nom_plateau in plateaux_essais:
						plateaux_essais[nom_plateau]['essais'] += 1
					else:
						var niveau_plateau = plateau_joue.get("niveau", 0)
						plateaux_essais[nom_plateau] = {'essais': 1, 'niveau': niveau_plateau}
	var plus_galere_nom: String = ''
	var plus_galere_essais: int = 0
	var plus_galere_difficulte: int = 0
	for nom_plateau in plateaux_essais.keys():
		if plateaux_essais.get(nom_plateau).get('essais') > plus_galere_essais:
			plus_galere_nom = nom_plateau
			plus_galere_essais = plateaux_essais.get(nom_plateau).get('essais')
			plus_galere_difficulte = plateaux_essais.get(nom_plateau).get('niveau')
	# Chercher le plateau avec le plus d'essais
	LogService.log_debug("joueur:",joueur,
						' plus_galere_nom=', plus_galere_nom,
						' plus_galere_essais=', plus_galere_essais,
						' plus_galere_difficulte=', plus_galere_difficulte)
	return {'essais': plus_galere_essais, 'difficulte': plus_galere_difficulte}

func serie_de_victoire_maximum() -> int:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var date_debut_campagne = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	# Serie de victoire la plus grande.
	var serie_de_victoire_maximum: int = 0
	var serie_de_victoire_courante: int = 0
	# Parcourir la liste des ascensions
	if SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions", null):
		for ascension in SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions"):
			# Comptabiliser les plateaux reussis
			if ascension.get("plateaux", null) \
				and ascension.get("date_debut") > date_debut_campagne:
				for plateau_joue in ascension.get("plateaux"):
					if plateau_joue.get("statut") == "reussi":
						serie_de_victoire_courante += 1
					if plateau_joue.get("statut") == "abandonné":
						# Defaite : Enregistrer le max et repartir à zéro.
						if serie_de_victoire_courante > serie_de_victoire_maximum:
							serie_de_victoire_maximum = serie_de_victoire_courante
						serie_de_victoire_courante = 0
		# Pour la derniere serie
		if serie_de_victoire_courante > serie_de_victoire_maximum:
			serie_de_victoire_maximum = serie_de_victoire_courante
	LogService.log_debug("joueur:",joueur, ' serie_de_victoire_maximum=', serie_de_victoire_maximum)
	return serie_de_victoire_maximum
