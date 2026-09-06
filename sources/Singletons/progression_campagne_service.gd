extends Node

signal progression_niveau
signal detail_score_plateau(detail_score : Dictionary)
signal fin_niveau
# TODO : signal fin_campagne

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
	return not SauvegardeListeJoueursService.le_joueur_existe(nom_nouveau_joueur)

func initialiser_le_nouveau_joueur_pour_la_campagne(nom_nouveau_joueur : String) -> bool:
	if autoriser_le_nouveau_joueur_pour_la_campagne(nom_nouveau_joueur):
		# Ajouter le joueur dans la liste des joueurs
		if SauvegardeListeJoueursService.ajouter_un_nouveau_joueur(nom_nouveau_joueur):
			var nom_fichier = SauvegardeListeJoueursService.retourner_le_fichier_de_sauvegarde(nom_nouveau_joueur)
			# Ajouter la sauvegarde personnelle du joueur
			if SauvegardeBddJoueursService.ajouter_un_nouveau_joueur(nom_nouveau_joueur, nom_fichier):
				# Ajouter le joueur dans le tableau des scores
				if SauvegardeTableauDesScoresService.ajouter_un_nouveau_joueur(nom_nouveau_joueur):
					return true
				SauvegardeBddJoueursService.annuler_creation_joueur(nom_fichier)
			SauvegardeListeJoueursService.supprimer_un_joueur_orphelin_de_sauvegarde(nom_nouveau_joueur, nom_fichier)
	return false

####################################
# Gestion des mécaniques de jeu
####################################

# Evenements de jeu du plateau
##############################

func niveau_en_cours() -> bool:
	return SauvegardeBddJoueursService.enregistrement_niveau_en_cours() \
		and SauvegardeBddJoueursService.campagne_lire_prochain_plateau_pour_niveau_courant()

func la_campagne_est_terminee() -> bool:
	return SauvegardeBddJoueursService.campagne_la_campagne_est_terminee()

func commencer_un_plateau() -> void:
	# Si un plateau était en cours, l'abandonner.
	if SauvegardeBddJoueursService.enregistrement_plateau_en_cours():
		abandonner_un_plateau()

	# Premier niveau sans enregistrement => Initialiser un nouveau niveau
	if not SauvegardeBddJoueursService.enregistrement_niveau_existe():
		SauvegardeBddJoueursService.enregistrement_initialiser_un_nouveau_niveau()

	# Le niveau en cours est achevé => Initialiser un nouveau niveau
	if not SauvegardeBddJoueursService.enregistrement_niveau_en_cours():
		SauvegardeBddJoueursService.enregistrement_initialiser_un_nouveau_niveau()

	# Ajouter le nouveau plateau et incrémenter le compteur de parties de la difficulté courante
	SauvegardeBddJoueursService.commencer_un_plateau()
	LogService.log_debug("Nombre de parties = ", SauvegardeBddJoueursService.enregistrement_lire_nombre_plateaux_acheves())

func gagner_un_plateau() -> void:
	# Valider le plateau courant (effacer de la liste des plateaux jouables)
	SauvegardeBddJoueursService.gagner_un_plateau()

	# Déterminer si l'ascension est achevée (pas de plateau suivant)
	if not SauvegardeBddJoueursService.campagne_lire_prochain_plateau_pour_niveau_courant():
		# BDD joueur + Préparer la jauge pour la prochaine ascension
		fin_niveau.emit()

	# Calculer le score du plateau et l'enregistrer dans l'historique du niveau
	var detail_score = ScoreService.mettre_a_jour_score_pour_victoire()
	detail_score_plateau.emit(detail_score)

	# Emmettre un signal de mise à jour du niveau
	progression_niveau.emit() # Pour mise à jour des bandeaux d'infos
	afficher_niveau_plateau_parties()

func abandonner_un_plateau() -> void:
	# En cas d'abandon, pas d'enrgistrement du temps.
	SauvegardeBddJoueursService.abandonner_un_plateau()
	# On reste sur le même plateau
	# La campagne et le niveaux sont inchangés

func afficher_niveau_plateau_parties():
	LogService.log_debug("[Campagne] Niveau = ", str(SauvegardeBddJoueursService.enregistrement_lire_valeur_niveau_joueur()),
	 " - Plateau = '", str(SauvegardeBddJoueursService.enregistrement_lire_nom_plateau()).replace(' ', '-'), "'",
	 " - Pourcentage niveau = ", str(SauvegardeBddJoueursService.lire_pourcentage_niveau_realise()),"%")

# Traitement de niveau
######################

func retourner_le_niveau_le_plus_bas() -> int:
	# Retourner le premier niveau non terminé
	for niveau_le_plus_bas in range(1, 300):
		if not SauvegardeBddJoueursService.campagne_le_niveau_est_termine(niveau_le_plus_bas):
			return niveau_le_plus_bas
	return 0
