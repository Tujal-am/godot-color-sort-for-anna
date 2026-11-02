extends Node

#func _ready() -> void:
	## Utile pour les tests de la page.
	##ProgressionCampagneService.choisir_le_joueur_pour_la_campagne("Alain Konu")
	#ProgressionCampagneService.choisir_le_joueur_pour_la_campagne("toto")
	##ProgressionCampagneService.choisir_le_joueur_pour_la_campagne("Anna")

# ########
# Score
func score() -> String:
	var _score = score_total()
	return SauvegardeTableauDesScoresService.nombre_avec_separateur_de_milliers(_score, '.')

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
	return duree_totale_plateaux_tous_les_niveaux_en_s().get('toutes')

func campagne_taux_reussite() -> float:
	return taux_de_reussite_des_plateaux()

func campagne_serie_max_reussite() -> int:
	return serie_de_victoire_maximum()

# #########
# Niveau
func niveau_taux_completion() -> float:
	return taux_completion_niveau()

func niveau_terminees() -> int:
	return nombre_niveaux_termines()

func niveau_longueur_max() -> int:
	return longueur_max_niveau_termine()

func niveau_taux_reussite_infos() -> Dictionary:
	"Niveaux taux de réussite : min, max et longueur"
	return niveau_taux_reussite_les_infos()

# #######
# Plateau
func plateau_nombre_de_plateaux_joues() -> int:
	return nombre_de_plateaux_joues()

func plateau_nombre_essais_de_plateaux() -> int:
	return nombre_essais_de_plateaux()

func plateau_taux_de_reussite() -> float:
	return taux_de_reussite_des_plateaux()

func plateau_taux_de_realisation() -> float:
	return taux_de_realisation_des_plateaux()

func plateau_temps_moyen_en_s() -> float:
	return plateau_le_temps_moyen_en_s()

func plateau_plus_rapide_infos() -> Dictionary:
	return plateau_le_plus_rapide_les_infos()

func plateau_plus_lent_infos() -> Dictionary:
	return plateau_le_plus_lent_les_infos()

func plateau_plus_galere_infos() -> Dictionary:
	return plateau_le_plus_galere_les_infos()

# #######
# Gameplay Classique
func classique_nombre_de_plateaux_joues() -> int:
	return gameplay_nombre_de_plateaux_joues("CLASSIQUE")

func classique_nombre_essais_de_plateaux() -> int:
	return gameplay_nombre_essais_de_plateaux("CLASSIQUE")

func classique_taux_de_reussite() -> float:
	return gameplay_taux_de_reussite_des_plateaux("CLASSIQUE")

func classique_temps_moyen_en_s() -> float:
	return gameplay_le_temps_moyen_en_s("CLASSIQUE")

func classique_plus_rapide_infos() -> Dictionary:
	return gameplay_le_plus_rapide_les_infos("CLASSIQUE")

func classique_plus_lent_infos() -> Dictionary:
	return gameplay_le_plus_lent_les_infos("CLASSIQUE")

func classique_plus_galere_infos() -> Dictionary:
	return gameplay_le_plus_galere_les_infos("CLASSIQUE")

# #######
# Gameplay Qui Perd Gagne
func qui_perd_gagne_nombre_de_plateaux_joues() -> int:
	return gameplay_nombre_de_plateaux_joues("QUI_PERD_GAGNE")

func qui_perd_gagne_nombre_essais_de_plateaux() -> int:
	return gameplay_nombre_essais_de_plateaux("QUI_PERD_GAGNE")

func qui_perd_gagne_taux_de_reussite() -> float:
	return gameplay_taux_de_reussite_des_plateaux("QUI_PERD_GAGNE")

func qui_perd_gagne_temps_moyen_en_s() -> float:
	return gameplay_le_temps_moyen_en_s("QUI_PERD_GAGNE")

func qui_perd_gagne_plus_rapide_infos() -> Dictionary:
	return gameplay_le_plus_rapide_les_infos("QUI_PERD_GAGNE")

func qui_perd_gagne_plus_lent_infos() -> Dictionary:
	return gameplay_le_plus_lent_les_infos("QUI_PERD_GAGNE")

func qui_perd_gagne_plus_galere_infos() -> Dictionary:
	return gameplay_le_plus_galere_les_infos("QUI_PERD_GAGNE")

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

	var campagne = SauvegardeBddJoueursService.enregistrement_campagne_lire_derniere_campagne()
	if campagne.get("date_debut", 0) >= date_debut_campagne:
		score_fin_campagne = SauvegardeBddJoueursService.enregistrement_campagne_lire_score_derniere_fin_campagne()

	for niveau in SauvegardeBddJoueursService.enregistrement_campagne_lire_niveaux(campagne):
		if niveau.get("date_debut", 0) < date_debut_campagne:
			continue
		score_niveau += SauvegardeBddJoueursService.enregistrement_campagne_lire_score_niveau(niveau)
		score_niveau_parfait += SauvegardeBddJoueursService.enregistrement_campagne_lire_score_niveau_parfait(niveau)
		# Comptabiliser les plateaux reussis
		for plateau in SauvegardeBddJoueursService.enregistrement_campagne_lire_plateaux(niveau):
			if plateau.get("date_debut", 0) < date_debut_campagne:
				continue
			score_rapidite += SauvegardeBddJoueursService.enregistrement_campagne_lire_score_duree_plateau(plateau)
			score_reussite += SauvegardeBddJoueursService.enregistrement_campagne_lire_score_ratio_reussite_plateau(plateau)

	return {
		'joueur': joueur,
		'rapidite': score_rapidite,
		'reussite': score_reussite,
		'niveau': score_niveau,
		'niveau_parfait': score_niveau_parfait,
		'fin_campagne': score_fin_campagne,
	}

func score_total() -> int:
	var score_rapidite :int = detail_score_cumule().get('rapidite', 0)
	var score_reussite :int = detail_score_cumule().get('reussite', 0)
	var score_niveau :int = detail_score_cumule().get('niveau', 0)
	var score_niveau_parfait :int = detail_score_cumule().get('niveau_parfait', 0)
	var score_fin_campagne :int = detail_score_cumule().get('fin_campagne', 0)
	var _score_total :int = score_rapidite \
							+ score_reussite \
							+ score_niveau \
							+ score_niveau_parfait \
							+ score_fin_campagne
	return _score_total

func score_total_pourcentage_rapidite() -> float:
	var _score_total :int = score_total()
	if _score_total == 0:
		return 0.
	var score_rapidite :int = detail_score_cumule().get('rapidite', 0)
	return 1. * score_rapidite / _score_total

func score_total_pourcentage_reussite() -> float:
	var _score_total :int = score_total()
	if _score_total == 0:
		return 0.
	var score_reussite :int = detail_score_cumule().get('reussite', 0)
	return 1. * score_reussite / _score_total

func score_total_pourcentage_niveau() -> float:
	var _score_total :int = score_total()
	if _score_total == 0:
		return 0.
	var score_niveau :int = detail_score_cumule().get('niveau', 0)
	return 1. * score_niveau / _score_total

func score_total_pourcentage_niveau_parfait() -> float:
	var _score_total :int = score_total()
	if _score_total == 0:
		return 0.
	var score_niveau_parfait :int = detail_score_cumule().get('niveau_parfait', 0)
	return 1. * score_niveau_parfait / _score_total

func score_total_pourcentage_fin_campagne() -> float:
	var _score_total :int = score_total()
	if _score_total == 0:
		return 0.
	var score_fin_campagne :int = detail_score_cumule().get('fin_campagne', 0)
	return 1. * score_fin_campagne / _score_total

func nombre_de_plateau_inacheves() -> int:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	# Nombre de plateau inachevés
	var nb_plateaux_inacheves: int = 0
	# Parcourir la liste des plateaux de chaque niveaux
	if SauvegardeBddJoueursService.campagne():
		for nom_niveau in SauvegardeBddJoueursService.campagne_lire_noms_niveaux():
			var valeur_niveau = SauvegardeBddJoueursService.valeur_niveau(nom_niveau)
			var liste_plateaux_campagne = SauvegardeBddJoueursService.campagne_lire_liste_plateaux_du_niveau(valeur_niveau)
			nb_plateaux_inacheves += liste_plateaux_campagne.size()
	LogService.log_debug("joueur:",joueur, ' nb_plateaux_inacheves=', nb_plateaux_inacheves)
	return nb_plateaux_inacheves

func nombre_de_plateau_acheves() -> int:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	# Nombre de plateau achevés
	var nb_plateaux_acheves: int = 0
	# Parcourir la liste des enregistrements de la campagne
	if SauvegardeBddJoueursService.enregistrement_campagne():
		# Comptabiliser les plateaux reussis
		var npra = nombre_de_plateau_reussis_abandonnes_passes()
		nb_plateaux_acheves = npra.get('reussis', 0)
	LogService.log_debug("joueur:",joueur, ' nb_plateaux_acheves=', nb_plateaux_acheves)
	return nb_plateaux_acheves

func nombre_de_plateaux_totaux() -> int:
	return nombre_de_plateau_inacheves() + nombre_de_plateau_acheves()

func taux_completion_campagne() -> float:
	var diviseur : int = nombre_de_plateaux_totaux()
	if not diviseur:
		return 0.
	return 1. * nombre_de_plateau_acheves() / nombre_de_plateaux_totaux()

func taux_completion_niveau() -> float:
	"Taux de complétion du niveau en cours"
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	# Consulter le dernier niveau de campagne enregistré
	if SauvegardeBddJoueursService.enregistrement_campagne():
		var nom_niveau = SauvegardeBddJoueursService.enregistrement_campagne_lire_nom_dernier_niveau()
		if nom_niveau:
			var npra_pour_niveau = nombre_de_plateau_reussis_abandonnes_passes_pour_niveau(nom_niveau)
			var lg_restante: int = SauvegardeBddJoueursService.campagne_lire_nombre_de_plateaux_realisables_pour_niveau_courant()
			var lg_realisee: int = npra_pour_niveau.get('reussis', 0) + npra_pour_niveau.get('passes', 0)
			if (lg_realisee + lg_restante) != 0:
				var completion: float = 1. * lg_realisee / (lg_realisee + lg_restante)
				LogService.log_debug("joueur:",joueur,
									' niveau=', nom_niveau,
									' lg_realisee=', lg_realisee,
									' lg_restante=', lg_restante,
									' completion=', completion)
				return completion
	LogService.log_debug("joueur:",joueur,' completion=', 0.)
	return 0.

func duree_totale_plateaux_tous_les_niveaux_en_s() -> Dictionary:
	"Durée totale de jeu effectif de plateaux dans les niveaux"
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var date_debut_campagne = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	# Nombre de plateau achevés
	var duree_totale_plateaux_tous_les_niveaux: float = 0.
	var duree_totale_plateaux_tous_les_niveaux_termines: float = 0.
	# Parcourir la liste des enregistrements de la campagne

	if SauvegardeBddJoueursService.enregistrement_campagne():
		var campagne = SauvegardeBddJoueursService.enregistrement_campagne_lire_derniere_campagne()
		for niveau in SauvegardeBddJoueursService.enregistrement_campagne_lire_niveaux(campagne):
			for plateau in SauvegardeBddJoueursService.enregistrement_campagne_lire_plateaux(niveau):
				if plateau.get("date_debut", 0) > date_debut_campagne:
					var duree_en_s = plateau.get("duree")
					if duree_en_s:
						# Comptabiliser TOUS les niveaux
						duree_totale_plateaux_tous_les_niveaux += duree_en_s
						if niveau.get("date_fin"):
							# Comptabiliser les niveaux TERMINEES
							duree_totale_plateaux_tous_les_niveaux_termines += duree_en_s
	LogService.log_debug("joueur:",joueur,
						' duree_totale_plateaux_tous_les_niveaux=', duree_totale_plateaux_tous_les_niveaux,
						' duree_totale_plateaux_tous_les_niveaux_termines=', duree_totale_plateaux_tous_les_niveaux_termines)
	return {
		'toutes': duree_totale_plateaux_tous_les_niveaux,
		'terminees': duree_totale_plateaux_tous_les_niveaux_termines
	}

func nombre_niveaux_termines() -> int:
	var date_debut_campagne = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	var nb_niveaux: int = 0
	if SauvegardeBddJoueursService.enregistrement_campagne():
		var campagne = SauvegardeBddJoueursService.enregistrement_campagne_lire_derniere_campagne()
		for niveau in SauvegardeBddJoueursService.enregistrement_campagne_lire_niveaux(campagne):
			if niveau.get("date_debut", 0) > date_debut_campagne \
				and niveau.get("date_fin"):
				nb_niveaux += 1
	return nb_niveaux

func duree_moyenne_niveaux_terminees_en_s() -> float:
	var nnt = nombre_niveaux_termines()
	if nnt == 0:
		return 0.
	var duree_niveaux = duree_totale_plateaux_tous_les_niveaux_en_s()
	return duree_niveaux.get('terminees') / nnt

func nombre_de_plateau_reussis_abandonnes_passes() -> Dictionary:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var date_debut_campagne = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	# Nombre de plateau reussis
	var nb_plateaux_reussis: int = 0
	# Nombre de plateau reussis
	var nb_plateaux_abandonnes: int = 0
	# Nombre de plateau passé
	var nb_plateaux_passes: int = 0
	# Parcourir la liste des enregistrements de la campagne
	if SauvegardeBddJoueursService.enregistrement_campagne():
		var campagne = SauvegardeBddJoueursService.enregistrement_campagne_lire_derniere_campagne()
		for niveau in SauvegardeBddJoueursService.enregistrement_campagne_lire_niveaux(campagne):
			for plateau in SauvegardeBddJoueursService.enregistrement_campagne_lire_plateaux(niveau):
				if plateau.get("date_debut", 0) > date_debut_campagne:
					if plateau.get("statut") == "reussi":
						nb_plateaux_reussis += 1
					if plateau.get("statut") == "abandonné":
						nb_plateaux_abandonnes += 1
					if plateau.get("statut") == "passé":
						nb_plateaux_passes += 1
	LogService.log_debug("joueur:",joueur,
						' nb_plateaux_reussis=', nb_plateaux_reussis,
						' nb_plateaux_abandonnes=', nb_plateaux_abandonnes,
						' nb_plateaux_passes=', nb_plateaux_passes)
	return {'reussis': nb_plateaux_reussis, 'abandonnes': nb_plateaux_abandonnes, 'passes': nb_plateaux_passes}

func nombre_de_plateau_reussis_abandonnes_passes_pour_niveau(nom_niveau : String) -> Dictionary:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var date_debut_campagne = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	# Nombre de plateau reussis
	var nb_plateaux_reussis: int = 0
	# Nombre de plateau reussis
	var nb_plateaux_abandonnes: int = 0
	# Nombre de plateau passé
	var nb_plateaux_passes: int = 0
	# Parcourir la liste des enregistrements de la campagne
	if SauvegardeBddJoueursService.enregistrement_campagne():
		var campagne = SauvegardeBddJoueursService.enregistrement_campagne_lire_derniere_campagne()
		for niveau in SauvegardeBddJoueursService.enregistrement_campagne_lire_niveaux(campagne):
			if nom_niveau == SauvegardeBddJoueursService.enregistrement_campagne_lire_nom_niveau(niveau):
				for plateau in SauvegardeBddJoueursService.enregistrement_campagne_lire_plateaux(niveau):
					# Comptabiliser les plateaux reussis
						if plateau.get("date_debut", 0) > date_debut_campagne:
							if plateau.get("statut") == "reussi":
								nb_plateaux_reussis += 1
							if plateau.get("statut") == "abandonné":
								nb_plateaux_abandonnes += 1
							if plateau.get("statut") == "passé":
								nb_plateaux_passes += 1
	LogService.log_debug("joueur:",joueur,
						' niveau=', nom_niveau,
						' nb_plateaux_reussis=', nb_plateaux_reussis,
						' nb_plateaux_abandonnes=', nb_plateaux_abandonnes,
						' nb_plateaux_passes=', nb_plateaux_passes)
	return {'niveau': nom_niveau,
			'reussis': nb_plateaux_reussis,
			'abandonnes': nb_plateaux_abandonnes,
			'passes': nb_plateaux_passes}

func nombre_essais_de_plateaux() -> int:
	var infos_plateaux = nombre_de_plateau_reussis_abandonnes_passes()
	var reussis = infos_plateaux.get('reussis', 0)
	var abandonne = infos_plateaux.get('abandonnes', 0)
	var passe = infos_plateaux.get('passes', 0)
	return reussis + abandonne + passe

func nombre_de_plateaux_joues() -> int:
	var infos_plateaux = nombre_de_plateau_reussis_abandonnes_passes()
	var reussis = infos_plateaux.get('reussis', 0)
	var passe = infos_plateaux.get('passes', 0)
	return reussis + passe

func taux_de_reussite_des_plateaux() -> float:
	var infos_plateaux = nombre_de_plateau_reussis_abandonnes_passes()
	var reussis = infos_plateaux.get('reussis', 0)
	var abandonne = infos_plateaux.get('abandonnes', 0)
	var passe = infos_plateaux.get('passes', 0)
	var total = reussis + abandonne + passe
	if total == 0:
		return 0.
	return 1. * reussis / total

func taux_de_realisation_des_plateaux() -> float:
	var infos_plateaux = nombre_de_plateau_reussis_abandonnes_passes()
	var reussis = infos_plateaux.get('reussis', 0)
	var passe = infos_plateaux.get('passes', 0)
	var total = reussis + passe
	if total == 0:
		return 0.
	return 1. * reussis / total

func longueur_max_niveau_termine() -> int:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var date_debut_campagne = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	# Nombre de plateau reussis
	var lg_max_niveau_termine: int = 0
	var lg_max_nom_niveau: String = ""
	# Parcourir la liste des enregistrements de la campagne
	if SauvegardeBddJoueursService.enregistrement_campagne():
		var campagne = SauvegardeBddJoueursService.enregistrement_campagne_lire_derniere_campagne()
		for niveau in SauvegardeBddJoueursService.enregistrement_campagne_lire_niveaux(campagne):
			# Comptabiliser les plateaux sur les enregistrements terminées
			if SauvegardeBddJoueursService.enregistrement_campagne_lire_plateaux(niveau) \
				and niveau.get("date_fin", null) \
				and niveau.get("date_debut", 0) > date_debut_campagne:
				# Longueur niveau
				var nom_niveau = niveau.get("niveau", "")
				var npra_pour_niveau = nombre_de_plateau_reussis_abandonnes_passes_pour_niveau(nom_niveau)
				var longueur_niveau: int = npra_pour_niveau.get("reussis", 0)
				if longueur_niveau > lg_max_niveau_termine:
					lg_max_niveau_termine = longueur_niveau
					lg_max_nom_niveau = nom_niveau
	LogService.log_debug("joueur:",joueur,
						' niveau=', lg_max_nom_niveau,
						' longueur_max_niveau_termine=', lg_max_niveau_termine)
	return lg_max_niveau_termine

func niveau_taux_reussite_les_infos() -> Dictionary:
	"Retourne le meilleur et pire taux de réussite les longueurs associées"
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	# Nombre de niveaux sans erreur
	var taux_min: float = 101.
	var taux_min_lg: int = 0
	var taux_min_niveau: int = 0
	var taux_max: float = -1.
	var taux_max_lg: int = 0
	var taux_max_niveau: int = 0
	# Parcourir la liste des enregistrements de la campagne
	if SauvegardeBddJoueursService.enregistrement_campagne():
		var campagne = SauvegardeBddJoueursService.enregistrement_campagne_lire_derniere_campagne()
		for niveau in SauvegardeBddJoueursService.enregistrement_campagne_lire_niveaux(campagne):
			var nom_niveau = niveau.get("niveau", "")
			var npra_pour_niveau = nombre_de_plateau_reussis_abandonnes_passes_pour_niveau(nom_niveau)
			var reussis = npra_pour_niveau.get("reussis", 0)
			var abandonnes = npra_pour_niveau.get("abandonnes", 0)
			var passes = npra_pour_niveau.get("passes", 0)
			var realises = reussis + abandonnes + passes
			if realises:
				var taux = 1. * reussis / realises
				var valeur_niveau = SauvegardeBddJoueursService.valeur_niveau(nom_niveau)
				if taux <= taux_min:
					if taux < taux_min:
						taux_min = taux
						taux_min_lg = reussis
						taux_min_niveau = valeur_niveau
					elif valeur_niveau < taux_min_niveau:
						# Rechercher le plus bas niveau avec le taux minimum
						taux_min_lg = reussis
						taux_min_niveau = valeur_niveau
				if taux >= taux_max:
					if taux > taux_max:
						taux_max = taux
						taux_max_lg = reussis
						taux_max_niveau = valeur_niveau
					elif valeur_niveau > taux_max_niveau:
						# Rechercher le plus bas niveau avec le taux maximum
						taux_max_lg = reussis
						taux_max_niveau = valeur_niveau
	# Gommer les valeurs initiales
	if taux_min == 101.:
		taux_min = 0.
	if taux_max == -1.:
		taux_max = 0.
	LogService.log_debug("joueur:",joueur,
						' taux_min=', taux_min,
						' taux_min_lg=', taux_min_lg,
						' taux_min_niveau=', taux_min_niveau,
						' taux_max=', taux_max,
						' taux_max_lg=', taux_max_lg,
						' taux_max_niveau=', taux_max_niveau)
	return {'taux_min': taux_min, 'taux_min_lg': taux_min_lg, 'taux_min_niveau': taux_min_niveau,
			'taux_max': taux_max, 'taux_max_lg': taux_max_lg, 'taux_max_niveau': taux_max_niveau}

func plateau_le_temps_moyen_en_s() -> float:
	"Temps moyen de résolution d'un plateau. Temps des essais cumulés compte pour 1 plateau."
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var date_debut_campagne = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	# Plateau termine le plus vite et sa difficulté
	var temps_total_en_s: float = 0.
	var nb_plateaux: int = 0
	var temps_moyen_en_s: float = 0.
	# Parcourir la liste des enregistrements de la campagne
	if SauvegardeBddJoueursService.enregistrement_campagne():
		var campagne = SauvegardeBddJoueursService.enregistrement_campagne_lire_derniere_campagne()
		for niveau in SauvegardeBddJoueursService.enregistrement_campagne_lire_niveaux(campagne):
			if niveau.get("date_debut", 0) > date_debut_campagne:
				for plateau in SauvegardeBddJoueursService.enregistrement_campagne_lire_plateaux(niveau):
					# Comptabiliser le temps cumulé des plateaux
					var duree_en_s = plateau.get("duree", 0)
					temps_total_en_s += duree_en_s
					var status = SauvegardeBddJoueursService.enregistrement_campagne_lire_statut_plateau(plateau)
					if status == 'reussi':
						nb_plateaux += 1
	if nb_plateaux:
		# Moyenne = temps total / nombre de plateaux joués (et pas sur l'ensemble des essais)
		temps_moyen_en_s = temps_total_en_s / nb_plateaux
	LogService.log_debug("joueur:",joueur,
						' temps_moyen=', temps_moyen_en_s)
	return temps_moyen_en_s

func plateau_le_plus_rapide_les_infos() -> Dictionary:
	"Plateau le plus rapide. Temps des essais cumulés"
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var date_debut_campagne = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	# Plateau termine le plus vite et sa difficulté
	var temps_plateau_en_s: float = 0.
	var plus_rapide_temps: float = -1.
	var plus_rapide_niveau: int = 0
	var plus_rapide_difficulte: int = 0
	# Parcourir la liste des enregistrements de la campagne
	if SauvegardeBddJoueursService.enregistrement_campagne():
		var campagne = SauvegardeBddJoueursService.enregistrement_campagne_lire_derniere_campagne()
		for niveau in SauvegardeBddJoueursService.enregistrement_campagne_lire_niveaux(campagne):
			if niveau.get("date_debut", 0) > date_debut_campagne:
				var nom_niveau = SauvegardeBddJoueursService.enregistrement_campagne_lire_nom_niveau(niveau)
				var valeur_niveau = SauvegardeBddJoueursService.valeur_niveau(nom_niveau)
				for plateau in SauvegardeBddJoueursService.enregistrement_campagne_lire_plateaux(niveau):
					# Cumuler les essais du plateau
					var duree_en_s = plateau.get("duree", 0)
					temps_plateau_en_s += duree_en_s
					var status = SauvegardeBddJoueursService.enregistrement_campagne_lire_statut_plateau(plateau)
					if status == 'reussi':
						var difficulte = roundi(plateau.get("difficulte", 0))
						if temps_plateau_en_s <= plus_rapide_temps or plus_rapide_temps == -1.:
							if temps_plateau_en_s < plus_rapide_temps or plus_rapide_temps == -1.:
								plus_rapide_temps = temps_plateau_en_s
								plus_rapide_difficulte = difficulte
								plus_rapide_niveau = valeur_niveau
							elif difficulte > plus_rapide_difficulte:
								plus_rapide_difficulte = difficulte
								plus_rapide_niveau = valeur_niveau
					if status == 'reussi' or status == 'passé':
						# Plateau terminé, RAZ temps.
						temps_plateau_en_s = 0
	if plus_rapide_temps == -1.:
		plus_rapide_temps = 0.
	LogService.log_debug("joueur:",joueur,
						' plus_rapide_temps=', plus_rapide_temps,
						' plus_rapide_niveau=', plus_rapide_niveau,
						' plus_rapide_difficulte=', plus_rapide_difficulte)
	return {'temps_en_s': plus_rapide_temps, 'niveau': plus_rapide_niveau, 'difficulte': plus_rapide_difficulte}

func plateau_le_plus_lent_les_infos() -> Dictionary:
	"Plateau le plus lent. Temps des essais cumulés"
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var date_debut_campagne = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	# Plateau le plus lent à résoudre et sa difficulté
	var temps_plateau_en_s: float = 0.
	var plus_lent_temps: float = -1.
	var plus_lent_niveau: int = 0
	var plus_lent_difficulte: int = 0
	# Parcourir la liste des enregistrements de la campagne
	if SauvegardeBddJoueursService.enregistrement_campagne():
		var campagne = SauvegardeBddJoueursService.enregistrement_campagne_lire_derniere_campagne()
		for niveau in SauvegardeBddJoueursService.enregistrement_campagne_lire_niveaux(campagne):
			if niveau.get("date_debut", 0) > date_debut_campagne:
				var nom_niveau = SauvegardeBddJoueursService.enregistrement_campagne_lire_nom_niveau(niveau)
				var valeur_niveau = SauvegardeBddJoueursService.valeur_niveau(nom_niveau)
				for plateau in SauvegardeBddJoueursService.enregistrement_campagne_lire_plateaux(niveau):
					# Cumuler les essais du plateau
					var duree_en_s = plateau.get("duree", 0)
					temps_plateau_en_s += duree_en_s
					var status = SauvegardeBddJoueursService.enregistrement_campagne_lire_statut_plateau(plateau)
					if status == 'reussi':
						var difficulte = roundi(plateau.get("difficulte", 0))
						if temps_plateau_en_s >= plus_lent_temps or plus_lent_temps == -1.:
							if temps_plateau_en_s > plus_lent_temps or plus_lent_temps == -1.:
								plus_lent_temps = temps_plateau_en_s
								plus_lent_difficulte = difficulte
								plus_lent_niveau = valeur_niveau
							elif difficulte > plus_lent_difficulte:
								plus_lent_difficulte = difficulte
								plus_lent_niveau = valeur_niveau
					if status == 'reussi' or status == 'passé':
						# Plateau terminé, RAZ temps.
						temps_plateau_en_s = 0
	if plus_lent_temps == -1.:
		plus_lent_temps = 0.
	LogService.log_debug("joueur:",joueur,
						' plus_lent_temps=', plus_lent_temps,
						' plus_lent_niveau=', plus_lent_niveau,
						' plus_lent_difficulte=', plus_lent_difficulte)
	return {'temps_en_s': plus_lent_temps, 'niveau': plus_lent_niveau, 'difficulte': plus_lent_difficulte}

func plateau_le_plus_galere_les_infos() -> Dictionary:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var date_debut_campagne = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	# Plateau le plus galère à résoudre et sa difficulté
	var plateaux_essais: Dictionary = {}
	# Parcourir la liste des enregistrements de la campagne et collecter les essais sur chaque plateau
	if SauvegardeBddJoueursService.enregistrement_campagne():
		var campagne = SauvegardeBddJoueursService.enregistrement_campagne_lire_derniere_campagne()
		for niveau in SauvegardeBddJoueursService.enregistrement_campagne_lire_niveaux(campagne):
			if niveau.get("date_debut", 0) > date_debut_campagne:
				var nom_niveau = SauvegardeBddJoueursService.enregistrement_campagne_lire_nom_niveau(niveau)
				var valeur_niveau = SauvegardeBddJoueursService.valeur_niveau(nom_niveau)
				for plateau in SauvegardeBddJoueursService.enregistrement_campagne_lire_plateaux(niveau):
					# Comptabiliser les essais de plateaux
					var nom_plateau = plateau.get("nom", 'inconnu')
					if nom_plateau in plateaux_essais:
						plateaux_essais[nom_plateau]['essais'] += 1
					else:
						var plateaux_difficulte : int = roundi(plateau.get("difficulte", 0))
						plateaux_essais[nom_plateau] = {
							'essais': 1,
							'niveau': valeur_niveau,
							'difficulte': plateaux_difficulte
						}
	var plus_galere_nom: String = ''
	var plus_galere_essais: int = 0
	var plus_galere_niveau: int = 0
	var plus_galere_difficulte: int = 0
	for nom_plateau in plateaux_essais.keys():
		if plateaux_essais.get(nom_plateau).get('essais') > plus_galere_essais:
			plus_galere_nom = nom_plateau
			plus_galere_essais = plateaux_essais.get(nom_plateau).get('essais')
			plus_galere_niveau = roundi(plateaux_essais.get(nom_plateau).get('niveau'))
			plus_galere_difficulte = roundi(plateaux_essais.get(nom_plateau).get('difficulte'))
	# Chercher le plateau avec le plus d'essais
	LogService.log_debug("joueur:",joueur,
						' plus_galere_nom=', plus_galere_nom,
						' plus_galere_essais=', plus_galere_essais,
						' plus_galere_niveau=', plus_galere_niveau,
						' plus_galere_difficulte=', plus_galere_difficulte)
	return {'nom': plus_galere_nom, 'essais': plus_galere_essais, 'niveau': plus_galere_niveau, 'difficulte': plus_galere_difficulte}

func serie_de_victoire_maximum() -> int:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var date_debut_campagne = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	# Serie de victoire la plus grande.
	var serie_de_victoire_max: int = 0
	var serie_de_victoire_courante: int = 0
	# Parcourir la liste des enregistrements de la campagne
	if SauvegardeBddJoueursService.enregistrement_campagne():
		# Classer les enregistrements par ordre chronologique
		var campagne_classee = SauvegardeBddJoueursService.enregistrement_campagne_lire_derniere_campagne().duplicate(true)
		var niveaux_classes = SauvegardeBddJoueursService.enregistrement_campagne_lire_niveaux(campagne_classee)
		var change = true
		while change:
			change = false
			for index in range(niveaux_classes.size()-1):
				var niveau_0 = niveaux_classes[index]
				var niveau_1 = niveaux_classes[index+1]
				var debut_0 = niveau_0.get("date_debut", 0)
				var debut_1 = niveau_1.get("date_debut", 0)
				if debut_0 > debut_1:
					niveaux_classes[index] = niveau_1
					niveaux_classes[index+1] = niveau_0
					change = true

		# Lire les enregistrements dans l'ordre chronologique
		for niveau in niveaux_classes:
			# Comptabiliser les plateaux reussis
			if niveau.get("date_debut", 0) > date_debut_campagne:
				for plateau in SauvegardeBddJoueursService.enregistrement_campagne_lire_plateaux(niveau):
					if plateau.get("statut") == "reussi":
						serie_de_victoire_courante += 1
					if plateau.get("statut") == "abandonné" \
						or plateau.get("statut") == "passé":
						# Defaite : Enregistrer le max et repartir à zéro.
						if serie_de_victoire_courante > serie_de_victoire_max:
							serie_de_victoire_max = serie_de_victoire_courante
						serie_de_victoire_courante = 0
		# Pour la derniere serie
		if serie_de_victoire_courante > serie_de_victoire_max:
			serie_de_victoire_max = serie_de_victoire_courante
	LogService.log_debug("joueur:",joueur, ' serie_de_victoire_maximum=', serie_de_victoire_max)
	return serie_de_victoire_max

func gameplay_le_temps_moyen_en_s(gameplay : String) -> float:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var date_debut_campagne = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	# Plateau termine le plus vite et sa difficulté
	var temps_total_en_s: float = 0.
	var nb_plateaux: int = 0
	var temps_moyen_en_s: float = 0.
	# Parcourir la liste des enregistrements de la campagne
	if SauvegardeBddJoueursService.enregistrement_campagne():
		var campagne = SauvegardeBddJoueursService.enregistrement_campagne_lire_derniere_campagne()
		for niveau in SauvegardeBddJoueursService.enregistrement_campagne_lire_niveaux(campagne):
			if niveau.get("date_debut", 0) > date_debut_campagne:
				for plateau in SauvegardeBddJoueursService.enregistrement_campagne_lire_plateaux(niveau):
					if plateau.get("gameplay",'').to_upper() != gameplay.to_upper():
						continue
					var duree_en_s = plateau.get("duree", 0)
					temps_total_en_s += duree_en_s
					var status = SauvegardeBddJoueursService.enregistrement_campagne_lire_statut_plateau(plateau)
					if status == 'reussi':
						nb_plateaux += 1
	if nb_plateaux:
		temps_moyen_en_s = temps_total_en_s / nb_plateaux
	LogService.log_debug("joueur:",joueur,
						"gameplay:", gameplay,
						' temps_moyen=', temps_moyen_en_s)
	return temps_moyen_en_s

func gameplay_nombre_essais_de_plateaux(gameplay : String) -> int:
	var infos_plateaux = gameplay_nombre_de_plateau_reussis_abandonnes_passes(gameplay)
	var reussis = infos_plateaux.get('reussis', 0)
	var abandonne = infos_plateaux.get('abandonnes', 0)
	var passe = infos_plateaux.get('passes', 0)
	return reussis + abandonne + passe

func gameplay_nombre_de_plateaux_joues(gameplay : String) -> int:
	var infos_plateaux = gameplay_nombre_de_plateau_reussis_abandonnes_passes(gameplay)
	var reussis = infos_plateaux.get('reussis', 0)
	var passe = infos_plateaux.get('passes', 0)
	return reussis + passe

func gameplay_taux_de_reussite_des_plateaux(gameplay : String) -> float:
	var infos_plateaux = gameplay_nombre_de_plateau_reussis_abandonnes_passes(gameplay)
	var reussis = infos_plateaux.get('reussis', 0)
	var abandonne = infos_plateaux.get('abandonnes', 0)
	var passe = infos_plateaux.get('passes', 0)
	var total = reussis + abandonne + passe
	if total == 0:
		return 0.
	return 1. * reussis / total

func gameplay_nombre_de_plateau_reussis_abandonnes_passes(gameplay : String) -> Dictionary:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var date_debut_campagne = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	# Nombre de plateau reussis
	var nb_plateaux_reussis: int = 0
	# Nombre de plateau reussis
	var nb_plateaux_abandonnes: int = 0
	# Nombre de plateau reussis
	var nb_plateaux_passes: int = 0
	# Parcourir la liste des enregistrements de la campagne
	if SauvegardeBddJoueursService.enregistrement_campagne():
		var campagne = SauvegardeBddJoueursService.enregistrement_campagne_lire_derniere_campagne()
		for niveau in SauvegardeBddJoueursService.enregistrement_campagne_lire_niveaux(campagne):
			if niveau.get("date_debut", 0) > date_debut_campagne:
				for plateau in SauvegardeBddJoueursService.enregistrement_campagne_lire_plateaux(niveau):
					if plateau.get("gameplay", '').to_upper() != gameplay.to_upper():
						continue
					if plateau.get("date_debut", 0) > date_debut_campagne:
						if plateau.get("statut") == "reussi":
							nb_plateaux_reussis += 1
						if plateau.get("statut") == "abandonné":
							nb_plateaux_abandonnes += 1
						if plateau.get("statut") == "passé":
							nb_plateaux_passes += 1
	LogService.log_debug("joueur:",joueur,
						' nb_plateaux_reussis=', nb_plateaux_reussis,
						' nb_plateaux_abandonnes=', nb_plateaux_abandonnes,
						' nb_plateaux_passes=', nb_plateaux_passes)
	return {'reussis': nb_plateaux_reussis, 'abandonnes': nb_plateaux_abandonnes, 'passes': nb_plateaux_passes}

func gameplay_le_plus_rapide_les_infos(gameplay : String) -> Dictionary:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var date_debut_campagne = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	# Plateau termine le plus vite et sa difficulté
	var temps_plateau_en_s: float = 0.
	var plus_rapide_temps: float = -1.
	var plus_rapide_niveau: int = 0
	var plus_rapide_difficulte: int = 0
	# Parcourir la liste des enregistrements de la campagne
	if SauvegardeBddJoueursService.enregistrement_campagne():
		var campagne = SauvegardeBddJoueursService.enregistrement_campagne_lire_derniere_campagne()
		for niveau in SauvegardeBddJoueursService.enregistrement_campagne_lire_niveaux(campagne):
			if niveau.get("date_debut", 0) > date_debut_campagne:
				var nom_niveau = SauvegardeBddJoueursService.enregistrement_campagne_lire_nom_niveau(niveau)
				var valeur_niveau = SauvegardeBddJoueursService.valeur_niveau(nom_niveau)
				for plateau in SauvegardeBddJoueursService.enregistrement_campagne_lire_plateaux(niveau):
					if plateau.get("gameplay",'').to_upper() != gameplay.to_upper():
						continue
					var duree_en_s = plateau.get("duree", 0)
					temps_plateau_en_s += duree_en_s
					var status = SauvegardeBddJoueursService.enregistrement_campagne_lire_statut_plateau(plateau)
					if status == 'reussi':
						var difficulte = roundi(plateau.get("difficulte", 0))
						if temps_plateau_en_s <= plus_rapide_temps or plus_rapide_temps == -1.:
							if temps_plateau_en_s < plus_rapide_temps or plus_rapide_temps == -1.:
								plus_rapide_temps = temps_plateau_en_s
								plus_rapide_niveau = valeur_niveau
								plus_rapide_difficulte = difficulte
							elif difficulte > plus_rapide_difficulte:
								plus_rapide_difficulte = difficulte
								plus_rapide_niveau = valeur_niveau
					if status == 'reussi' or status == 'passé':
						# Plateau terminé, RAZ temps.
						temps_plateau_en_s = 0
	if plus_rapide_temps == -1.:
		plus_rapide_temps = 0.
	LogService.log_debug("joueur:",joueur,
						"gameplay:", gameplay,
						' plus_rapide_temps=', plus_rapide_temps,
						' plus_rapide_niveau=', plus_rapide_niveau,
						' plus_rapide_difficulte=', plus_rapide_difficulte)
	return {'temps_en_s': plus_rapide_temps, 'niveau': plus_rapide_niveau, 'difficulte': plus_rapide_difficulte}

func gameplay_le_plus_lent_les_infos(gameplay : String) -> Dictionary:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var date_debut_campagne = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	# Plateau le plus lent à résoudre et sa difficulté
	var temps_plateau_en_s: float = 0.
	var plus_lent_temps: float = -1.
	var plus_lent_niveau: int = 0
	var plus_lent_difficulte: int = 0
	# Parcourir la liste des enregistrements de la campagne
	if SauvegardeBddJoueursService.enregistrement_campagne():
		var campagne = SauvegardeBddJoueursService.enregistrement_campagne_lire_derniere_campagne()
		for niveau in SauvegardeBddJoueursService.enregistrement_campagne_lire_niveaux(campagne):
			if niveau.get("date_debut", 0) > date_debut_campagne:
				var nom_niveau = SauvegardeBddJoueursService.enregistrement_campagne_lire_nom_niveau(niveau)
				var valeur_niveau = SauvegardeBddJoueursService.valeur_niveau(nom_niveau)
				for plateau in SauvegardeBddJoueursService.enregistrement_campagne_lire_plateaux(niveau):
					if plateau.get("gameplay",'').to_upper() != gameplay.to_upper():
						continue
					var duree_en_s = plateau.get("duree", 0)
					temps_plateau_en_s += duree_en_s
					var status = SauvegardeBddJoueursService.enregistrement_campagne_lire_statut_plateau(plateau)
					if status == 'reussi':
						var difficulte = roundi(plateau.get("difficulte", 0))
						if temps_plateau_en_s >= plus_lent_temps or plus_lent_temps == -1.:
							if temps_plateau_en_s > plus_lent_temps or plus_lent_temps == -1.:
								plus_lent_temps = temps_plateau_en_s
								plus_lent_niveau = valeur_niveau
								plus_lent_difficulte = difficulte
							elif difficulte < plus_lent_difficulte:
								plus_lent_difficulte = difficulte
								plus_lent_niveau = valeur_niveau
					if status == 'reussi' or status == 'passé':
						# Plateau terminé, RAZ temps.
						temps_plateau_en_s = 0
	if plus_lent_temps == -1.:
		plus_lent_temps = 0.
	LogService.log_debug("joueur:",joueur,
						"gameplay:", gameplay,
						' plus_lent_temps=', plus_lent_temps,
						' plus_lent_niveau=', plus_lent_niveau,
						' plus_lent_difficulte=', plus_lent_difficulte)
	return {'temps_en_s': plus_lent_temps, 'niveau': plus_lent_niveau, 'difficulte': plus_lent_difficulte}

func gameplay_le_plus_galere_les_infos(gameplay : String) -> Dictionary:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var date_debut_campagne = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	# Plateau le plus galère à résoudre et sa difficulté
	var plateaux_essais: Dictionary = {}
	# Parcourir la liste des enregistrements de la campagne et collecter les essais sur chaque plateau
	if SauvegardeBddJoueursService.enregistrement_campagne():
		var campagne = SauvegardeBddJoueursService.enregistrement_campagne_lire_derniere_campagne()
		for niveau in SauvegardeBddJoueursService.enregistrement_campagne_lire_niveaux(campagne):
			if niveau.get("date_debut", 0) > date_debut_campagne:
				var nom_niveau = SauvegardeBddJoueursService.enregistrement_campagne_lire_nom_niveau(niveau)
				var valeur_niveau = SauvegardeBddJoueursService.valeur_niveau(nom_niveau)
				for plateau in SauvegardeBddJoueursService.enregistrement_campagne_lire_plateaux(niveau):
					# Comptabiliser les essais de plateaux
					if plateau.get("gameplay",'').to_upper() != gameplay.to_upper():
						continue
					var nom_plateau = plateau.get("nom", 'inconnu')
					if nom_plateau in plateaux_essais:
						plateaux_essais[nom_plateau]['essais'] += 1
					else:
						var plateaux_difficulte : int = roundi(plateau.get("difficulte", 0))
						plateaux_essais[nom_plateau] = {
							'essais': 1,
							'niveau': valeur_niveau,
							'difficulte': plateaux_difficulte
						}
	var plus_galere_nom: String = ''
	var plus_galere_essais: int = 0
	var plus_galere_niveau: int = 0
	var plus_galere_difficulte: int = 0
	for nom_plateau in plateaux_essais.keys():
		if plateaux_essais.get(nom_plateau).get('essais') > plus_galere_essais:
			plus_galere_nom = nom_plateau
			plus_galere_essais = plateaux_essais.get(nom_plateau).get('essais')
			plus_galere_niveau = plateaux_essais.get(nom_plateau).get('niveau')
			plus_galere_difficulte = roundi(plateaux_essais.get(nom_plateau).get('difficulte'))
	# Chercher le plateau avec le plus d'essais
	LogService.log_debug("joueur:",joueur,
						"gameplay:", gameplay,
						' plus_galere_nom=', plus_galere_nom,
						' plus_galere_essais=', plus_galere_essais,
						' plus_galere_niveau=', plus_galere_niveau,
						' plus_galere_difficulte=', plus_galere_difficulte)
	return {
		'nom': plus_galere_nom,
		'essais': plus_galere_essais,
		'niveau': plus_galere_niveau,
		'difficulte': plus_galere_difficulte
	}
