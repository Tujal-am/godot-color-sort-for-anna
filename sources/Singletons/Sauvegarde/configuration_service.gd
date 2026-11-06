####################################
# Gestion de la configuration du jeu
####################################

extends Node

# class_name Configuration

# Dico : {'caracteristique': reglage}
var configuration_du_jeu = {
	'version': 'V1.0.0-rc20',
	'date_debut_campagne': "2026-10-26 00:00:00",
	'musiques': true,
	'effets sonores': true,
	'vibrations': true
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_initialiser_la_configuration()


func _initialiser_la_configuration() -> void:
	var version_courante_disque = '?'
	# Lire la configuration du jeu
	var fichier_configuration_courant = FichiersJsonService.read_json_file("configuration_du_jeu.json")
	if fichier_configuration_courant:
		version_courante_disque = fichier_configuration_courant.get('version', '?')

	if version_courante_disque.split('.')[0] != lire_la_version().split('.')[0] \
		or version_courante_disque.split('.')[1] != lire_la_version().split('.')[1]:
		# Transcription des enregistrements des versions précédentes
		_V0_2_X___V0_3_X()
		_V0_3_X___V0_4_X()
		_V0_4_X___V1_0_X()
		_V1_0_X()

	synchronisation_avec_fichier_configuration_du_jeu()
	LogService.log_debug("configuration_du_jeu = ", configuration_du_jeu)


func _enregistrer_la_configuration() -> void:
	LogService.log_debug("configuration.gd : _enregistrer_la_configuration")
	FichiersJsonService.write_json_file("configuration_du_jeu.json", configuration_du_jeu.duplicate(true))
	LogService.log_debug("Configuration sauvegardée")


func activer_musiques() -> void:
	if not configuration_du_jeu.get('musiques', true):
		configuration_du_jeu['musiques'] = true
		_enregistrer_la_configuration()

func activer_effets_sonores() -> void:
	if not configuration_du_jeu.get('effets sonores', true):
		configuration_du_jeu['effets sonores'] = true
		_enregistrer_la_configuration()

func activer_vibrations() -> void:
	if not configuration_du_jeu.get('vibrations', true):
		configuration_du_jeu['vibrations'] = true
		_enregistrer_la_configuration()

func desactiver_musiques() -> void:
	if configuration_du_jeu.get('musiques', true):
		configuration_du_jeu['musiques'] = false
		_enregistrer_la_configuration()

func desactiver_effets_sonores() -> void:
	if configuration_du_jeu.get('effets sonores', true):
		configuration_du_jeu['effets sonores'] = false
		_enregistrer_la_configuration()

func desactiver_vibrations() -> void:
	if configuration_du_jeu.get('vibrations', true):
		configuration_du_jeu['vibrations'] = false
		_enregistrer_la_configuration()

func musiques_sont_actives() -> bool:
	return configuration_du_jeu.get('musiques', true)

func effets_sonores_sont_actifs() -> bool:
	return configuration_du_jeu.get('effets sonores', true)

func vibrations_sont_actives() -> bool:
	return configuration_du_jeu.get('vibrations', true)

func lire_la_version() -> String:
	return configuration_du_jeu.get('version', '?')

func lire_la_date_debut_campagne_timestamp() -> int:
	var datetime = configuration_du_jeu.get('date_debut_campagne', '?')
	return Time.get_unix_time_from_datetime_string(datetime)

func synchronisation_avec_fichier_configuration_du_jeu() -> void:
	var fichier_configuration_courant = FichiersJsonService.read_json_file("configuration_du_jeu.json")
	if fichier_configuration_courant:
		if 'musiques' in fichier_configuration_courant:
			configuration_du_jeu['musiques'] = fichier_configuration_courant.get('musiques')
		if 'effets sonores' in fichier_configuration_courant:
			configuration_du_jeu['effets sonores'] = fichier_configuration_courant.get('effets sonores')
		if 'vibrations' in fichier_configuration_courant:
			configuration_du_jeu['vibrations'] = fichier_configuration_courant.get('vibrations')

func _V1_0_X() -> void:
	# Traitement global [V1.0.X]

	# ###################################
	# Fichier 'configuration_du_jeu.json'
	# ###################################
	# Conserver les réglages utilisateur avant d'enregistrer la nouvelle version.
	synchronisation_avec_fichier_configuration_du_jeu()

	# Remise à zéro des scores
	SauvegardeTableauDesScoresService.remise_a_zero()
	# Copier nouvelle campagne pour les joueurs + l'initialiser
	SauvegardeBddJoueursService.remplacer_initier_campagne_des_joueurs()
	# Enregistrement de la configuration sur le disque
	_enregistrer_la_configuration()

func _V0_4_X___V1_0_X() -> void:
	# CONVERSION [V0.4.X -> V1.0.X]
	var version_courante_disque = '?'

	# Lire la configuration du jeu
	var fichier_configuration_courant = FichiersJsonService.read_json_file("configuration_du_jeu.json")
	if fichier_configuration_courant:
		version_courante_disque = fichier_configuration_courant.get('version', '?')
	else:
		version_courante_disque = 'V0.4.X' # Version par defaut si fichier absent

	if version_courante_disque.begins_with('V0.4.'):
		# ###################################
		# Fichier 'configuration_du_jeu.json'
		# ###################################
		# Conserver les réglages utilisateur avant d'enregistrer la nouvelle version.
		synchronisation_avec_fichier_configuration_du_jeu()
		# Enregistrer la transcription de configuration 'V0.4.0'
		var version_logicielle = lire_la_version()
		configuration_du_jeu['version'] = 'V1.0.X'
		_enregistrer_la_configuration()
		configuration_du_jeu['version'] = version_logicielle

		# #####################
		# Fichier 'scores.json'
		# #####################
		# Pas de transcription nécessaire

		# ################################
		# Fichier 'liste_des_joueurs.json'
		# ################################
		# Pas de transcription nécessaire

		# ###################################
		# Fichier 'sauvegarde_joueur_XX.json'
		# ###################################
		# Pour chaque joueur:
		#  1 - Effacer    'plateaux/difficulte'
		#  2 - Creer      'plateaux_libres'
		#  3 - Transcrire 'ascensions' => 'enregistrement_campagne'
		#  4 - Transcrire  'plateaux_libres'
		var ancien_fichier_sauvegarde_joueur = {}
		for nom_joueur in SauvegardeListeJoueursService.retourner_la_liste_des_joueurs():
			ancien_fichier_sauvegarde_joueur = SauvegardeListeJoueursService.retourner_le_fichier_de_sauvegarde(nom_joueur)
			SauvegardeBddJoueursService.choisir_le_joueur(nom_joueur, ancien_fichier_sauvegarde_joueur)
			# 1 - Effacer 'plateaux/difficulte'
			var plateaux = SauvegardeBddJoueursService._sauvegarde_joueur.get('plateaux',[])
			var fin_campagne = plateaux.is_empty()
			SauvegardeBddJoueursService._sauvegarde_joueur.erase('plateaux')
			#  2 - Creer 'plateaux_libres'
			SauvegardeBddJoueursService._sauvegarde_joueur['plateaux_libres'] = {}
			var plateaux_libres = SauvegardeBddJoueursService._sauvegarde_joueur['plateaux_libres']
			#  3 - Transcrire 'ascensions' => 'enregistrement_campagne'
			# 'Ascension[]' => 'Campagne_1/Niveaux[]'
			var liste_ascensions = SauvegardeBddJoueursService._sauvegarde_joueur.get('ascensions', [])
			if liste_ascensions:
				# Creer la campagne 'Campagne_1'
				SauvegardeBddJoueursService.enregistrement_campagne_initialiser_une_nouvelle_campagne()
				# Corriger le nom de la campagne
				var derniere_campagne = SauvegardeBddJoueursService.enregistrement_campagne_lire_derniere_campagne()
				SauvegardeBddJoueursService.enregistrement_campagne_modifier_nom_derniere_campagne("campagne_1")
				derniere_campagne['date_debut'] = liste_ascensions[0].get('date_debut', 0.0)
				if fin_campagne:
					# Ajouter le score de fin de campagne
					SauvegardeBddJoueursService.enregistrement_campagne_modifier_score_fin_campagne(500000)
			var valeur_niveau = 1
			for ascension in liste_ascensions:
				SauvegardeBddJoueursService.enregistrement_campagne_initialiser_un_nouveau_niveau(valeur_niveau)
				# Corriger le nom du niveau, date de debut, de fin, 
				var dernier_niveau = SauvegardeBddJoueursService.enregistrement_campagne_lire_dernier_niveau()
				dernier_niveau['niveau'] = SauvegardeBddJoueursService.nom_niveau(valeur_niveau)
				dernier_niveau['date_debut'] = ascension.get('date_debut', 0.0)
				dernier_niveau['date_fin'] = ascension.get('date_fin', 0.0)
				if ascension.has('score'):
					if  ascension.get('score') and ascension.get('score').has('ascension'):
						dernier_niveau['score']['niveau'] = ascension.get('score').get('ascension')
					if  ascension.get('score') and ascension.get('score').has('ascension_sans_detour'):
						dernier_niveau['score']['niveau_parfait'] = ascension.get('score').get('ascension_sans_detour')
				valeur_niveau += 1
				# Parcourir chaque plateau.
				if ascension.has('plateaux'):
					for plateau in ascension.get('plateaux'):
						var nom = plateau.get('nom', 'Plateau_inconnu')
						var gameplay = 'CLASSIQUE'
						var difficulte = plateau.get('niveau', 0)
						SauvegardeBddJoueursService.enregistrement_campagne_initialiser_un_nouveau_plateau(nom, gameplay, difficulte)
						# Corriger le date_debut, date_fin, duree, statut, score, coups joués
						var date_debut = plateau.get('date_debut', 0.)
						var date_fin = plateau.get('date_fin', 0.)
						var duree = plateau.get('duree', 0)
						var statut = plateau.get('statut', 'reussi')
						var score = plateau.get('score', {}).duplicate(true)
						var coups_joues = plateau.get('coups joués', []).duplicate(true)
						var dernier_plateau = SauvegardeBddJoueursService.enregistrement_campagne_lire_dernier_plateau()
						dernier_plateau['date_debut'] = date_debut
						dernier_plateau['date_fin'] = date_fin
						dernier_plateau['duree'] = duree
						dernier_plateau['statut'] = statut
						dernier_plateau['score'] = score
						dernier_plateau['coups joués'] = coups_joues
						#  4 - Transcrire 'plateaux_libres'
						var plateau_libre = {'difficulte': difficulte, 'gameplay': gameplay, 'nom': nom}
						var difficulte_str_int =  str( int(difficulte) )
						if not plateaux_libres.has(difficulte_str_int):
							plateaux_libres[difficulte_str_int] = []
						plateaux_libres[difficulte_str_int].append(plateau_libre)
			# Effacer l'ancienne clé
			SauvegardeBddJoueursService._sauvegarde_joueur.erase('ascensions')

			# Enregistrer les changements
			SauvegardeBddJoueursService._enregistrer_sauvegarde_joueur()
			SauvegardeBddJoueursService.liberer_le_joueur()
			LogService.log_debug("Conversion de la Campagne 1 (V0.4.X) pour le joueur :", nom_joueur)

func _V0_3_X___V0_4_X() -> void:
	# CONVERSION [V0.3.X -> V0.4.X]
	var version_courante_disque = '?'

	# Lire la configuration du jeu
	var fichier_configuration_courant = FichiersJsonService.read_json_file("configuration_du_jeu.json")
	if fichier_configuration_courant:
		version_courante_disque = fichier_configuration_courant.get('version', '?')
	else:
		version_courante_disque = 'V0.3.X' # Version par defaut si fichier absent

	if version_courante_disque.begins_with('V0.3.'):
		# ###################################
		# Fichier 'configuration_du_jeu.json'
		# ###################################
		# Conserver les réglages utilisateur avant d'enregistrer la nouvelle version.
		synchronisation_avec_fichier_configuration_du_jeu()
		# Enregistrer la transcription de configuration 'V0.3.0'
		var version_logicielle = lire_la_version()
		configuration_du_jeu['version'] = 'V0.4.X'
		_enregistrer_la_configuration()
		configuration_du_jeu['version'] = version_logicielle

func _V0_2_X___V0_3_X() -> void:
	# CONVERSION [V0.2.X -> V0.3.X]
	# Effacer le fichier de sauvegarde obsolete qui devient incompatible.
	FichiersJsonService.remove_json_file("sauvegarde.json")
