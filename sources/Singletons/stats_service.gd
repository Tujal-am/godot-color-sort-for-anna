extends Node

#func _ready() -> void:
	## Utile pour les tests de la page.
	##ProgressionCampagneService.choisir_le_joueur_pour_la_campagne("Alain Konu")
	#ProgressionCampagneService.choisir_le_joueur_pour_la_campagne("toto")
	##ProgressionCampagneService.choisir_le_joueur_pour_la_campagne("Anna")

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
func nombre_de_plateau_inacheves() -> int:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	# Nombre de plateau inachevés
	var nb_plateaux_inacheves: int = 0
	# Parcourir la liste des plateaux de chaque niveaux
	if SauvegardeBddJoueursService.sauvegarde_joueur.get("campagne", null):
		for niveau in SauvegardeBddJoueursService.sauvegarde_joueur.get("campagne").keys():
			var liste_plateaux_campagne = SauvegardeBddJoueursService.sauvegarde_joueur.get("campagne").get(niveau)
			nb_plateaux_inacheves += liste_plateaux_campagne.size()
	LogService.log_debug("joueur:",joueur, ' nb_plateaux_inacheves=', nb_plateaux_inacheves)
	return nb_plateaux_inacheves

func nombre_de_plateau_acheves() -> int:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	# Nombre de plateau achevés
	var nb_plateaux_acheves: int = 0
	# Parcourir la liste des enregistrements de la campagne
	if SauvegardeBddJoueursService.sauvegarde_joueur.get("enregistrement_campagne", null):
		# Comptabiliser les plateaux reussis
		var npra = nombre_de_plateau_reussis_abandonnes()
		nb_plateaux_acheves = npra.get('reussis', 0)
	LogService.log_debug("joueur:",joueur, ' nb_plateaux_acheves=', nb_plateaux_acheves)
	return nb_plateaux_acheves

func nombre_de_plateaux_totaux() -> int:
	return nombre_de_plateau_inacheves() + nombre_de_plateau_acheves()

func taux_completion_campagne() -> float:
	return 1. * nombre_de_plateau_acheves() / nombre_de_plateaux_totaux()

func taux_completion_niveau() -> float:
	"Taux de complétion du niveau en cours"
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	# Consulter le dernier niveau de campagne enregistré
	if SauvegardeBddJoueursService.sauvegarde_joueur.get("enregistrement_campagne", null):
		var niveau = SauvegardeBddJoueursService.sauvegarde_joueur.get('enregistrement_campagne').back()
		var nom_niveau = niveau.get("niveau", "")
		if nom_niveau:
			var npra_pour_niveau = nombre_de_plateau_reussis_abandonnes_pour_niveau(nom_niveau)
			var campagne_niveau = SauvegardeBddJoueursService.sauvegarde_joueur.get('campagne').get(nom_niveau, [])
			var lg_restante: int = campagne_niveau.size()
			var lg_realisee: int = npra_pour_niveau.get('reussis', 0)
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
	if SauvegardeBddJoueursService.sauvegarde_joueur.get("enregistrement_campagne", null):
		for niveau in SauvegardeBddJoueursService.sauvegarde_joueur.get("enregistrement_campagne"):
			# Comptabiliser les plateaux reussis
			if niveau.get("plateaux", null):
				for plateau_joue in niveau.get("plateaux"):
					if plateau_joue.get("date_debut") > date_debut_campagne:
						var duree_en_s = plateau_joue.get("duree")
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
	if SauvegardeBddJoueursService.sauvegarde_joueur.get("enregistrement_campagne", null):
		for niveau in SauvegardeBddJoueursService.sauvegarde_joueur.get("enregistrement_campagne"):
			if niveau.get("date_debut") > date_debut_campagne \
				and niveau.get("date_fin"):
				nb_niveaux += 1
	return nb_niveaux

func duree_moyenne_niveaux_terminees_en_s() -> float:
	var nnt = nombre_niveaux_termines()
	if nnt == 0:
		return 0.
	var duree_niveaux = duree_totale_plateaux_tous_les_niveaux_en_s()
	return duree_niveaux.get('terminees') / nnt

func nombre_de_plateau_reussis_abandonnes() -> Dictionary:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var date_debut_campagne = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	# Nombre de plateau reussis
	var nb_plateaux_reussis: int = 0
	# Nombre de plateau reussis
	var nb_plateaux_abandonnes: int = 0
	# Parcourir la liste des enregistrements de la campagne
	if SauvegardeBddJoueursService.sauvegarde_joueur.get("enregistrement_campagne", null):
		for niveau in SauvegardeBddJoueursService.sauvegarde_joueur.get("enregistrement_campagne"):
			# Comptabiliser les plateaux reussis
			if niveau.get("plateaux", null):
				for plateau_joue in niveau.get("plateaux"):
					if plateau_joue.get("date_debut") > date_debut_campagne:
						if plateau_joue.get("statut") == "reussi":
							nb_plateaux_reussis += 1
						if plateau_joue.get("statut") == "abandonné":
							nb_plateaux_abandonnes += 1
	LogService.log_debug("joueur:",joueur,
						' nb_plateaux_reussis=', nb_plateaux_reussis,
						' nb_plateaux_abandonnes=', nb_plateaux_abandonnes)
	return {'reussis': nb_plateaux_reussis, 'abandonnes': nb_plateaux_abandonnes}

func nombre_de_plateau_reussis_abandonnes_pour_niveau(nom_niveau : String) -> Dictionary:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var date_debut_campagne = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	# Nombre de plateau reussis
	var nb_plateaux_reussis: int = 0
	# Nombre de plateau reussis
	var nb_plateaux_abandonnes: int = 0
	# Parcourir la liste des enregistrements de la campagne
	if SauvegardeBddJoueursService.sauvegarde_joueur.get("enregistrement_campagne", null):
		for niveau in SauvegardeBddJoueursService.sauvegarde_joueur.get("enregistrement_campagne"):
			# Comptabiliser les plateaux reussis
			if niveau.get("niveau", "") == nom_niveau:
				if niveau.get("plateaux", null):
					for plateau_joue in niveau.get("plateaux"):
						if plateau_joue.get("date_debut") > date_debut_campagne:
							if plateau_joue.get("statut") == "reussi":
								nb_plateaux_reussis += 1
							if plateau_joue.get("statut") == "abandonné":
								nb_plateaux_abandonnes += 1
	LogService.log_debug("joueur:",joueur,
						' niveau=', nom_niveau,
						' nb_plateaux_reussis=', nb_plateaux_reussis,
						' nb_plateaux_abandonnes=', nb_plateaux_abandonnes)
	return {'niveau': nom_niveau, 'reussis': nb_plateaux_reussis, 'abandonnes': nb_plateaux_abandonnes}

func taux_de_reussite_des_plateaux() -> float:
	var infos_plateaux = nombre_de_plateau_reussis_abandonnes()
	var reussis = infos_plateaux.get('reussis')
	var abandonne = infos_plateaux.get('abandonnes')
	if (reussis + abandonne) == 0:
		return 0.
	return 1. * reussis / (reussis + abandonne)

func longueur_max_niveau_termine() -> int:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var date_debut_campagne = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	# Nombre de plateau reussis
	var lg_max_niveau_termine: int = 0
	var lg_max_nom_niveau: String = ""
	# Parcourir la liste des enregistrements de la campagne
	if SauvegardeBddJoueursService.sauvegarde_joueur.get("enregistrement_campagne", null):
		for niveau in SauvegardeBddJoueursService.sauvegarde_joueur.get("enregistrement_campagne"):
			# Comptabiliser les plateaux sur les enregistrements terminées
			if niveau.get("plateaux", null) \
				and niveau.get("date_fin", null) \
				and niveau.get("date_debut") > date_debut_campagne:
				# Longueur niveau
				var nom_niveau = niveau.get("niveau", "")
				var npra_pour_niveau = nombre_de_plateau_reussis_abandonnes_pour_niveau(nom_niveau)
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
	var taux_max: float = -1.
	var taux_max_lg: int = 0
	# Parcourir la liste des enregistrements de la campagne
	if SauvegardeBddJoueursService.sauvegarde_joueur.get("enregistrement_campagne", null):
		for niveau in SauvegardeBddJoueursService.sauvegarde_joueur.get("enregistrement_campagne"):
			var nom_niveau = niveau.get("niveau", "")
			var npra_pour_niveau = nombre_de_plateau_reussis_abandonnes_pour_niveau(nom_niveau)
			var reussis = npra_pour_niveau.get("reussis", 0)
			var abandonnes = npra_pour_niveau.get("abandonnes", 0)
			var realises = reussis + abandonnes
			if realises:
				var taux = 1. * reussis / realises
				if taux < taux_min:
					taux_min = taux
					taux_min_lg = reussis
				if taux > taux_max:
					taux_max = taux
					taux_max_lg = reussis
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
	var temps_total_en_s: float = 0.
	var nb_plateaux: int = 0
	var temps_moyen_en_s: float = 0.
	# Parcourir la liste des enregistrements de la campagne
	if SauvegardeBddJoueursService.sauvegarde_joueur.get("enregistrement_campagne", null):
		for niveau in SauvegardeBddJoueursService.sauvegarde_joueur.get("enregistrement_campagne"):
			# Comptabiliser les plateaux reussis
			if niveau.get("plateaux", null) \
				and niveau.get("date_debut") > date_debut_campagne:
				for plateau_joue in niveau.get("plateaux"):
					var duree_en_s = plateau_joue.get("duree", 0)
					if duree_en_s:
						temps_total_en_s += duree_en_s
						nb_plateaux += 1
	if nb_plateaux:
		temps_moyen_en_s = temps_total_en_s / nb_plateaux
	LogService.log_debug("joueur:",joueur,
						' temps_moyen=', temps_moyen_en_s)
	return temps_moyen_en_s

func plateau_le_plus_rapide_les_infos() -> Dictionary:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var date_debut_campagne = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	# Plateau termine le plus vite et sa difficulté
	var plus_rapide_temps: float = 0.
	var plus_rapide_difficulte: int = 0
	# Parcourir la liste des enregistrements de la campagne
	if SauvegardeBddJoueursService.sauvegarde_joueur.get("enregistrement_campagne", null):
		for niveau in SauvegardeBddJoueursService.sauvegarde_joueur.get("enregistrement_campagne"):
			# Comptabiliser les plateaux reussis
			if niveau.get("plateaux", null) \
				and niveau.get("date_debut") > date_debut_campagne:
				for plateau_joue in niveau.get("plateaux"):
					var duree_en_s = plateau_joue.get("duree", 0)
					if duree_en_s:
						var difficulte = roundi(plateau_joue.get("difficulte", 0))
						if duree_en_s <= plus_rapide_temps or plus_rapide_temps == 0.:
							if duree_en_s == plus_rapide_temps and difficulte > plus_rapide_difficulte:
								plus_rapide_difficulte = difficulte
							else:
								plus_rapide_temps = duree_en_s
								plus_rapide_difficulte = difficulte
	LogService.log_debug("joueur:",joueur,
						' plus_rapide_temps=', plus_rapide_temps,
						' plus_rapide_difficulte=', plus_rapide_difficulte)
	return {'temps_en_s': plus_rapide_temps, 'difficulte': plus_rapide_difficulte}

func plateau_le_plus_lent_les_infos() -> Dictionary:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var date_debut_campagne = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	# Plateau le plus lent à résoudre et sa difficulté
	var plus_lent_temps: float = 0.
	var plus_lent_difficulte: int = 0
	# Parcourir la liste des enregistrements de la campagne
	if SauvegardeBddJoueursService.sauvegarde_joueur.get("enregistrement_campagne", null):
		for niveau in SauvegardeBddJoueursService.sauvegarde_joueur.get("enregistrement_campagne"):
			# Comptabiliser les plateaux reussis
			if niveau.get("plateaux", null) \
				and niveau.get("date_debut") > date_debut_campagne:
				for plateau_joue in niveau.get("plateaux"):
					var duree_en_s = plateau_joue.get("duree", 0)
					if duree_en_s:
						var difficulte = roundi(plateau_joue.get("difficulte", 0))
						if duree_en_s >= plus_lent_temps or plus_lent_temps == 0.:
							if duree_en_s == plus_lent_temps and difficulte > plus_lent_difficulte:
								plus_lent_difficulte = difficulte
							else:
								plus_lent_temps = duree_en_s
								plus_lent_difficulte = difficulte
	LogService.log_debug("joueur:",joueur,
						' plus_lent_temps=', plus_lent_temps,
						' plus_lent_difficulte=', plus_lent_difficulte)
	return {'temps_en_s': plus_lent_temps, 'difficulte': plus_lent_difficulte}

func plateau_le_plus_galere_les_infos() -> Dictionary:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var date_debut_campagne = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	# Plateau le plus galère à résoudre et sa difficulté
	var plateaux_essais: Dictionary = {}
	# Parcourir la liste des enregistrements de la campagne et collecter les essais sur chaque plateau
	if SauvegardeBddJoueursService.sauvegarde_joueur.get("enregistrement_campagne", null):
		for niveau in SauvegardeBddJoueursService.sauvegarde_joueur.get("enregistrement_campagne"):
			# Comptabiliser les essais de plateaux
			if niveau.get("plateaux", null) \
				and niveau.get("date_debut") > date_debut_campagne:
				for plateau_joue in niveau.get("plateaux"):
					var nom_plateau = plateau_joue.get("nom", 'inconnu')
					if nom_plateau in plateaux_essais:
						plateaux_essais[nom_plateau]['essais'] += 1
					else:
						var plateaux_difficulte : int = roundi(plateau_joue.get("difficulte", 0))
						plateaux_essais[nom_plateau] = {'essais': 1, 'difficulte': plateaux_difficulte}
	var plus_galere_nom: String = ''
	var plus_galere_essais: int = 0
	var plus_galere_difficulte: int = 0
	for nom_plateau in plateaux_essais.keys():
		if plateaux_essais.get(nom_plateau).get('essais') > plus_galere_essais:
			plus_galere_nom = nom_plateau
			plus_galere_essais = plateaux_essais.get(nom_plateau).get('essais')
			plus_galere_difficulte = roundi(plateaux_essais.get(nom_plateau).get('difficulte'))
	# Chercher le plateau avec le plus d'essais
	LogService.log_debug("joueur:",joueur,
						' plus_galere_nom=', plus_galere_nom,
						' plus_galere_essais=', plus_galere_essais,
						' plus_galere_difficulte=', plus_galere_difficulte)
	return {'nom': plus_galere_nom, 'essais': plus_galere_essais, 'difficulte': plus_galere_difficulte}

func serie_de_victoire_maximum() -> int:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var date_debut_campagne = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	# Serie de victoire la plus grande.
	var serie_de_victoire_max: int = 0
	var serie_de_victoire_courante: int = 0
	# Parcourir la liste des enregistrements de la campagne
	if SauvegardeBddJoueursService.sauvegarde_joueur.get("enregistrement_campagne", null):
		# Classer les enregistrements par ordre chronologique
		var enregistrements_classes = SauvegardeBddJoueursService.sauvegarde_joueur.get("enregistrement_campagne").duplicate()
		var change = true
		while change:
			change = false
			for index in range(enregistrements_classes.size()-1):
				var niveau_0 = enregistrements_classes[index]
				var niveau_1 = enregistrements_classes[index+1]
				var debut_0 = niveau_0.get("date_debut", 0)
				var debut_1 = niveau_1.get("date_debut", 0)
				if debut_0 > debut_1:
					enregistrements_classes[index] = niveau_1
					enregistrements_classes[index+1] = niveau_0
					change = true

		# Lire les enregistrements dans l'ordre chronologique
		for niveau in enregistrements_classes:
			# Comptabiliser les plateaux reussis
			if niveau.get("plateaux", null) \
				and niveau.get("date_debut") > date_debut_campagne:
				for plateau_joue in niveau.get("plateaux"):
					if plateau_joue.get("statut") == "reussi":
						serie_de_victoire_courante += 1
					if plateau_joue.get("statut") == "abandonné":
						# Defaite : Enregistrer le max et repartir à zéro.
						if serie_de_victoire_courante > serie_de_victoire_max:
							serie_de_victoire_max = serie_de_victoire_courante
						serie_de_victoire_courante = 0
		# Pour la derniere serie
		if serie_de_victoire_courante > serie_de_victoire_max:
			serie_de_victoire_max = serie_de_victoire_courante
	LogService.log_debug("joueur:",joueur, ' serie_de_victoire_maximum=', serie_de_victoire_max)
	return serie_de_victoire_max
