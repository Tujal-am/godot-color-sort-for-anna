extends Node

# signal progression_niveau   # TODO : Le signal n'est lu par personne. Normal ?
signal detail_score_plateau(detail_score : Dictionary)
signal fin_niveau
signal fin_campagne

####################################
# Gestion de données transverses Campagne
####################################
func la_campagne_est_terminee_pour_joueur(nom_joueur : String) -> bool:
	var succes: bool = _choisir_et_corriger_le_joueur(nom_joueur)
	if succes:
		return SauvegardeBddJoueursService.campagne_la_campagne_est_terminee()
	return false

func choisir_le_joueur_pour_la_campagne(nom_joueur : String) -> bool:
	# Choisir le joueur pour la campagne
	return _choisir_et_corriger_le_joueur(nom_joueur)

func _choisir_et_corriger_le_joueur(nom_joueur : String) -> bool:
	# Charge le joueur et l'efface de la liste en cas de probleme.
	if SauvegardeListeJoueursService.le_joueur_existe(nom_joueur):
		# Choisir le joueur pour la campagne
		var nom_fichier = SauvegardeListeJoueursService.retourner_le_fichier_de_sauvegarde(nom_joueur)
		var succes: bool =  SauvegardeBddJoueursService.choisir_le_joueur(nom_joueur, nom_fichier)
		if not succes:
			LogService.log_erreur("Erreur : Impossible de charger le joueur *" + nom_joueur + "*. L'effacer de la liste des joueurs.")
			SauvegardeListeJoueursService.supprimer_un_joueur_orphelin_de_sauvegarde(nom_joueur, nom_fichier)
		return succes
	return false

func liberer_le_joueur_pour_la_campagne():
	SauvegardeBddJoueursService.liberer_le_joueur()

func autoriser_le_nouveau_joueur_pour_la_campagne(nom_nouveau_joueur : String) -> bool:
	return SauvegardeListeJoueursService.le_nom_du_joueur_est_valide(nom_nouveau_joueur) \
			and not SauvegardeListeJoueursService.le_joueur_existe(nom_nouveau_joueur)

func initialiser_le_nouveau_joueur_pour_la_campagne(nom_nouveau_joueur : String) -> bool:
	if autoriser_le_nouveau_joueur_pour_la_campagne(nom_nouveau_joueur):
		# Ajouter le joueur dans la liste des joueurs
		if SauvegardeListeJoueursService.ajouter_un_nouveau_joueur(nom_nouveau_joueur):
			var nom_fichier = SauvegardeListeJoueursService.retourner_le_fichier_de_sauvegarde(nom_nouveau_joueur)
			# Ajouter la sauvegarde personnelle du joueur
			if SauvegardeBddJoueursService.ajouter_un_nouveau_joueur(nom_nouveau_joueur, nom_fichier):
				# Ajouter le joueur dans le tableau des scores
				return SauvegardeTableauDesScoresService.ajouter_un_nouveau_joueur(nom_nouveau_joueur)
	return false

func importer_campagne_nouveau_joueur_externe(nom_nouveau_joueur: String, campagne: Dictionary) -> bool:
	var nom_campagne: String = campagne.get("campagne", "")
	if autoriser_le_nouveau_joueur_pour_la_campagne(nom_nouveau_joueur):
		# Ajouter le joueur dans la liste des joueurs
		if SauvegardeListeJoueursService.ajouter_un_nouveau_joueur(nom_nouveau_joueur):
			var nom_fichier = SauvegardeListeJoueursService.retourner_le_fichier_de_sauvegarde(nom_nouveau_joueur)
			# Ajouter la sauvegarde personnelle du joueur
			if SauvegardeBddJoueursService.ajouter_un_nouveau_joueur(nom_nouveau_joueur, nom_fichier):
				# Effacer sa campagne par defaut
				SauvegardeBddJoueursService.campagne_supprimer_les_plateaux()
				# Ajouter le joueur dans le tableau des scores
				if SauvegardeTableauDesScoresService.ajouter_un_nouveau_joueur(nom_nouveau_joueur):
					if SauvegardeBddJoueursService.enregistrement_campagne_importer_campagne(campagne):
						ScoreService.mettre_a_jour_score_pour_import_campagne(nom_nouveau_joueur, campagne)
						LogService.log_debug("Import de la campagne du nouveau joueur *", nom_nouveau_joueur,
							"* : ", nom_campagne)
						return true
	LogService.log_erreur("Erreur : Impossible d'importer la campagne pour le nouveau joueur *",
		nom_nouveau_joueur, "* : ", nom_campagne)
	return false

func importer_campagne_joueur_externe(nom_joueur: String, campagne: Dictionary) -> bool:
	var nom_campagne: String = campagne.get("campagne", "")
	if SauvegardeListeJoueursService.le_joueur_existe(nom_joueur):
		var nom_fichier = SauvegardeListeJoueursService.retourner_le_fichier_de_sauvegarde(nom_joueur)
		if SauvegardeBddJoueursService.choisir_le_joueur(nom_joueur, nom_fichier):
			# Verifier qu'il s'agit bien d'un joueur importé (campagne effacée)
			# TODO : identifier plus precisement un joueur importé que par sa campagne terminee
			# TODO : existence de remote_uuid dans la liste des joueurs
			if SauvegardeBddJoueursService.campagne_la_campagne_est_terminee():
				if SauvegardeBddJoueursService.enregistrement_campagne_importer_campagne(campagne):
					ScoreService.mettre_a_jour_score_pour_import_campagne(nom_joueur, campagne)
					LogService.log_debug("Import de la campagne pour le joueur *", nom_joueur, "* : ", nom_campagne)
					return true
	LogService.log_erreur("Erreur : Impossible d'importer la campagne pour le joueur *", nom_joueur, "* : ", nom_campagne)
	return false

####################################
# Gestion des mécaniques de jeu
####################################

# Evenements de jeu du plateau
##############################

func niveau_en_cours() -> bool:
	return SauvegardeBddJoueursService.enregistrement_campagne_niveau_en_cours() \
		and SauvegardeBddJoueursService.campagne_lire_prochain_plateau_pour_niveau_courant()

func la_campagne_est_terminee() -> bool:
	return SauvegardeBddJoueursService.campagne_la_campagne_est_terminee()

func commencer_un_plateau() -> void:
	# Si un plateau était en cours, l'abandonner.
	if SauvegardeBddJoueursService.enregistrement_campagne_plateau_en_cours():
		abandonner_un_plateau()

	# Premier niveau sans enregistrement => Initialiser une nouvelle campagne
	if not SauvegardeBddJoueursService.enregistrement_campagne_niveau_existe():
		SauvegardeBddJoueursService.enregistrement_campagne_initialiser_une_nouvelle_campagne()

	# Le niveau en cours est achevé => Initialiser un nouveau niveau
	if not SauvegardeBddJoueursService.enregistrement_campagne_niveau_en_cours():
		SauvegardeBddJoueursService.enregistrement_campagne_initialiser_un_nouveau_niveau()

	# Ajouter le nouveau plateau et incrémenter le compteur de parties de la difficulté courante
	SauvegardeBddJoueursService.commencer_un_plateau()
	LogService.log_debug("Nombre de parties = ", SauvegardeBddJoueursService.enregistrement_campagne_lire_nombre_plateaux_acheves())

func gagner_un_plateau() -> void:
	# Valider le plateau courant (effacer de la liste des plateaux jouables)
	SauvegardeBddJoueursService.gagner_un_plateau()

	# Déterminer si le niveau est achevé (pas de plateau suivant)
	if not SauvegardeBddJoueursService.campagne_lire_prochain_plateau_pour_niveau_courant():
		LogService.log_debug("[progression_campagne_service] emission signal : fin_niveau")
		fin_niveau.emit()

	# Déterminer si la campagne est achevée
	if la_campagne_est_terminee():
		LogService.log_debug("[progression_campagne_service] emission signal : fin_campagne")
		fin_campagne.emit()

	# Calculer le score du plateau et l'enregistrer dans l'historique du niveau
	var detail_score = ScoreService.mettre_a_jour_score_pour_victoire()
	detail_score_plateau.emit(detail_score)

	# Emmettre un signal de mise à jour du niveau
	# TODO : Le signal n'est lu par personne. Normal ?
	# progression_niveau.emit() # Pour mise à jour des BandeauEnJeux d'infos
	afficher_niveau_plateau_parties()

func abandonner_un_plateau() -> void:
	# En cas d'abandon, pas d'enrgistrement du temps.
	SauvegardeBddJoueursService.abandonner_un_plateau()
	# On reste sur le même plateau
	# La campagne et le niveaux sont inchangés

func passer_un_plateau() -> void:
	# En cas de passage, pas d'enrgistrement du temps.
	SauvegardeBddJoueursService.passer_un_plateau()

	# Déterminer si le niveau est achevé (pas de plateau suivant)
	if not SauvegardeBddJoueursService.campagne_lire_prochain_plateau_pour_niveau_courant():
		LogService.log_debug("[progression_campagne_service] emission signal : fin_niveau")
		fin_niveau.emit()

	# Déterminer si la campagne est achevée
	if la_campagne_est_terminee():
		LogService.log_debug("[progression_campagne_service] emission signal : fin_campagne")
		fin_campagne.emit()

	# Calculer le score du plateau et l'enregistrer dans l'historique du niveau
	var detail_score = ScoreService.mettre_a_jour_score_pour_passer()
	detail_score_plateau.emit(detail_score)

	# Emmettre un signal de mise à jour du niveau
	# TODO : Le signal n'est lu par personne. Normal ?
	# progression_niveau.emit() # Pour mise à jour des BandeauEnJeux d'infos
	afficher_niveau_plateau_parties()

func afficher_niveau_plateau_parties():
	LogService.log_debug("[Campagne] Niveau = ", str(SauvegardeBddJoueursService.enregistrement_campagne_lire_valeur_niveau_joueur()),
	 " - Plateau = '", str(SauvegardeBddJoueursService.enregistrement_campagne_lire_nom_plateau()).replace(' ', '-'), "'",
	 " - Pourcentage niveau = ", str(SauvegardeBddJoueursService.lire_pourcentage_niveau_realise()),"%")

# Traitement de niveau
######################

func retourner_le_niveau_le_plus_bas() -> int:
	# Retourner le premier niveau non terminé
	for niveau_le_plus_bas in range(1, 300):
		if not SauvegardeBddJoueursService.campagne_le_niveau_est_termine(niveau_le_plus_bas):
			return niveau_le_plus_bas
	return 0
