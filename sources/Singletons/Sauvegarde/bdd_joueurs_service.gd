###############################################
# Gestion des sauvegardes de joueurs
###############################################

extends Node

###############################################
# Gestion des niveaux et des plateaux à jouer
###############################################
var _sauvegarde_joueur = {
	# Créé dans '_ready()'
	#'nom': 'Alain Konu',
	#'campagne': {  },
	#'nombre_de_parties': {  },
	#'enregistrement_campagne': [ ],
	#'plateaux_libres': {  },
}

# Exemple de sauvegarde avec Un niveau en cours
# {
# 	"nom": "nom joueur",
# 	"nombre_de_parties": { "18": 5, "20": 4, "24": 4 },
#	"campagne": {
#        "niveau_1": [
#            {"difficulte": 1, "gameplay": "CLASSIQUE", "nom": "AAA.BBB.CCC"},
#            {"difficulte": 2, "gameplay": "MEMOIRE", "nom": "DDD.EEE.FFF"}
#        ],
#        "niveau_2": [
#            {"difficulte": 3, "gameplay": "DEFI_DU_GOSSE", "nom": "GGG.HHH.III"}
#        ],
#        "niveau_10": [
#            {"difficulte": 5, "gameplay": "DEFI_DU_BOSS", "nom": "GGG.HHH.III"}
#        ]
#    },
# 	"enregistrement_campagne": [ 
# 		{
#            "date_debut": 1789901316.0,
#            "date_fin": 1790023184.0,
#            "campagne": "campagne_1",
#            "score": { "campagne": 500000.0 },
#            "niveaux": [
#	 			{
#	 			'niveau': niveau_20,
#	 			'date_debut': 1748785865.997,
#	 			'date_fin': 0.,
#	 			'score': { 'ascension': 500000, 'ascension_sans_detour': 500000},
#	 			'plateaux': [
#	 				{
#	 					'nom': "AA .BB .AB ",
#						'gameplay': 'CLASSIQUE', # 'CLASSIQUE', 'MEMOIRE', 'DEFI_DU_GOSSE', 'DEFI_DU_BOSS', 'QUI_PERD_GAGNE', 'FLEMMARD', 'DOUBLE_FACE', 'DICO'
#	 					'date_debut': 1748785865.997,
#	 					'date_fin': 1748785855.0,
#	 					'difficulte': 18,
#	 					'statut': 'reussi', # 'en cours', 'abandonné', 'passé', 'reussi'
#	 					'duree': 0,
#	 					'score': { 'duree': 4000, 'ratio_reussite': 2000 },
#	 					'coups joués': [
#	 						{'depart': 2, 'arrivee': 1},
#	 						{'depart': 2, 'arrivee': 0}
#	 					]
#	 				}
#	 			}
#            ]
# 		}
# 	]
# }

var fichier_sauvegarde = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connecter les signaux attendus
	var pcs = get_node("/root/ProgressionCampagneService")
	pcs.fin_niveau.connect(_on_progression_campagne_service_fin_niveau)
	pcs.fin_campagne.connect(_on_progression_campagne_service_fin_campagne)

	# Creation compte initial 'Alain Konu'
	if not FichiersJsonService.json_file_exists("sauvegarde_joueur_00.json"):
		ajouter_un_nouveau_joueur('Alain Konu', 'sauvegarde_joueur_00.json')

func _on_progression_campagne_service_fin_niveau():
	enregistrement_campagne_terminer_niveau()

func _on_progression_campagne_service_fin_campagne():
	enregistrement_campagne_terminer_campagne()


# <<< API externe
func ajouter_un_nouveau_joueur(nom_nouveau_joueur : String, nom_nouveau_fichier : String) -> bool:
	"""Crée un nouveau joueur si le nom est libre"""
	# Vérifie que le nom est libre
	if not nom_nouveau_joueur:
		return false
	if not nom_nouveau_fichier or FichiersJsonService.json_file_exists("user://" + nom_nouveau_fichier):
		return false
	# Crée le compte et l'enregistre
	_sauvegarde_joueur = sauvegarde_vierge(nom_nouveau_joueur)
	# Initialiser les plateaux avec 'BDD Plateaux'
	_sauvegarde_joueur['nom_campagne'] = SauvegardeBddPlateauxService.nom_campagne()
	_sauvegarde_joueur['campagne'] = SauvegardeBddPlateauxService.plateau_liste_niveaux_duplicate()
	
	fichier_sauvegarde = nom_nouveau_fichier
	_enregistrer_sauvegarde_joueur()
	return true

func sauvegarde_vierge(nom_nouveau_joueur : String) -> Dictionary:
	return {
		'nom': nom_nouveau_joueur,
		'campagne': {  },
		'nombre_de_parties': {  },
		'enregistrement_campagne': [ ],
		'plateaux_libres': {  }
	}

func choisir_le_joueur(nom : String, fichier : String) -> bool:
	return  _lire_sauvegarde_joueur(fichier) and nom == lire_nom_joueur()

func liberer_le_joueur():
	fichier_sauvegarde = ""

func le_joueur_existe() -> bool:
	return fichier_sauvegarde != ""

func reset_sauvegarde_des_joueurs() -> void:
	"""Parcourir tous les joueurs et reset leur sauvegarde"""
	# Parcourir chaque joueurs
	for nom_joueur in SauvegardeListeJoueursService.retourner_la_liste_des_joueurs():
		fichier_sauvegarde = SauvegardeListeJoueursService.retourner_le_fichier_de_sauvegarde(nom_joueur)
		# Crée le compte et l'enregistre
		_sauvegarde_joueur = sauvegarde_vierge(nom_joueur)
		# Initialiser les plateaux avec 'BDD Plateaux'
		_sauvegarde_joueur['nom_campagne'] = SauvegardeBddPlateauxService.nom_campagne()
		_sauvegarde_joueur['campagne'] = SauvegardeBddPlateauxService.plateau_liste_niveaux_duplicate()
		_enregistrer_sauvegarde_joueur()
		liberer_le_joueur()
		LogService.log_debug("Reset de la campagne pour le joueur :", nom_joueur)

func remplacer_initier_campagne_des_joueurs():
	"""Parcourir tous les joueurs et remplacer les plateaux à jouer par ceux du fichier courant"""
	# Parcourir chaque joueurs
	for nom_joueur in SauvegardeListeJoueursService.retourner_la_liste_des_joueurs():
		fichier_sauvegarde = SauvegardeListeJoueursService.retourner_le_fichier_de_sauvegarde(nom_joueur)
		choisir_le_joueur(nom_joueur, fichier_sauvegarde)
		# Cloturer tout plateau, niveau et campagne en cours.
		enregistrement_campagne_terminer_plateau()
		enregistrement_campagne_terminer_niveau()
		enregistrement_campagne_terminer_campagne()
		# Remplacer les plateaux residuels d'une ancienne campagne.
		# avec les plateaux de la nouvelle campagne
		_sauvegarde_joueur['nom_campagne'] = SauvegardeBddPlateauxService.nom_campagne()
		_sauvegarde_joueur['campagne'] = SauvegardeBddPlateauxService.plateau_liste_niveaux_duplicate()
		# Initialiser la nouvelle campagne pour le joueur
		enregistrement_campagne_initialiser_une_nouvelle_campagne()
		# Enregistrer les changements
		_enregistrer_sauvegarde_joueur()
		liberer_le_joueur()
		LogService.log_debug("Remplacement de campagne pour le joueur : ", nom_joueur)

func gagner_un_plateau() -> void:
	# Valider le plateau courant (effacer de la liste des plateaux jouables)
	campagne_supprimer_et_memoriser_plateau_courant()

	enregistrement_campagne_modifier_statut_plateau('reussi')
	enregistrement_campagne_terminer_plateau()

func abandonner_un_plateau() -> void:
	enregistrement_campagne_modifier_statut_plateau('abandonné')
	enregistrement_campagne_terminer_plateau()

func passer_un_plateau() -> void:
	# Effacer de la liste des plateaux jouables
	campagne_supprimer_et_oublier_plateau_courant()

	enregistrement_campagne_modifier_statut_plateau('passé')
	enregistrement_campagne_terminer_plateau()

func commencer_un_plateau() -> void:
	# Ajouter le nouveau plateau
	var prochain_plateau = campagne_lire_prochain_plateau_pour_niveau_courant()
	if prochain_plateau:
		enregistrement_campagne_initialiser_un_nouveau_plateau(
					prochain_plateau.get('nom'),
					prochain_plateau.get('gameplay'),
					prochain_plateau.get('difficulte')
					)

		# Incrémenter le compteur de parties de la difficulte courante
		nombre_de_parties_incrementer_pour_difficulte_courante()
	else:
		LogService.log_erreur("Pas de prochain plateau pour le niveau courant")
# >>> API externe


func _lire_sauvegarde_joueur(fichier : String) -> bool:
	"Ouvre et charge la sauvegarde du joueur depuis le fichier spécifié."
	var lecture_sauvegarde_joueur = FichiersJsonService.read_json_file(fichier)
	if lecture_sauvegarde_joueur:
		fichier_sauvegarde = fichier
		_sauvegarde_joueur = lecture_sauvegarde_joueur.duplicate(true)
		_print_bdd_joueurs()
		return true
	else:
		fichier_sauvegarde = ""
		LogService.log_erreur("Erreur de lecture de la sauvegarde du joueur actuel (", fichier, ")")
	return false

func _print_bdd_joueurs() -> void:
	#LogService.log_debug("sauvegarde *",lire_nom_joueur(),"* = ", lire_sauvegarde())
	LogService.log_debug("sauvegarde *", lire_nom_joueur(),"* :")
	LogService.log_debug('\t', "plateau=", enregistrement_campagne_lire_nom_plateau())
	LogService.log_debug('\t', "nombre_de_parties=", nombre_de_parties())
	LogService.log_debug('\t', "len(enregistrement_campagne)=", len(enregistrement_campagne()))
	#if len(enregistrement_campagne()):
	#	LogService.log_debug('\t', "dernier niveau=", enregistrement_campagne_lire_dernier_niveau())

func _enregistrer_sauvegarde_joueur() -> void:
	if fichier_sauvegarde:
		FichiersJsonService.write_json_file(fichier_sauvegarde, _sauvegarde_joueur.duplicate(true))
		LogService.log_debug("Progression sauvegardée")


###############################################
# Sauvegarde
###############################################

func lire_sauvegarde() -> Dictionary:
	if le_joueur_existe():
		return _sauvegarde_joueur
	return {}


###############################################
# Sauvegarde
# "nom": "nom joueur"
###############################################

func lire_preference_aide(mode: String) -> String:
	var preferences: Dictionary = lire_sauvegarde().get("preferences_aide", {})
	return preferences.get(mode, "")


func enregistrer_preference_aide(mode: String, choix: String) -> void:
	if not le_joueur_existe() or (choix != "chaque_entree" and choix != "premiere_fois"):
		return
	if lire_preference_aide(mode) == choix:
		return
	var preferences: Dictionary = _sauvegarde_joueur.get("preferences_aide", {})
	preferences[mode] = choix
	_sauvegarde_joueur["preferences_aide"] = preferences
	_enregistrer_sauvegarde_joueur()


func lire_nom_joueur() -> String:
	if le_joueur_existe():
		return lire_sauvegarde().get('nom','')
	return ""


###############################################
# Indice des plateaux non joués
#	"campagne": {
#        "niveau_1": [
#            {"difficulte": 1, "gameplay": "CLASSIQUE", "nom": "AAA.BBB.CCC"},
#            {"difficulte": 2, "gameplay": "MEMOIRE", "nom": "DDD.EEE.FFF"}
#        ],....
###############################################

# Methodes bas niveau
func nom_niveau(niveau : int) -> String:
	if niveau:
		return 'niveau_'+str(niveau)
	return ""

func valeur_niveau(niveau : String) -> int:
	if niveau:
		return int(niveau.substr( len('niveau_') ))
	return 0 # Niveau inconnu

func campagne() -> Dictionary:
	"Pointeur sur la sauvegarde de campagne du joueur."
	if le_joueur_existe():
		return lire_sauvegarde().get('campagne', {})
	return {} # Campagne épuisée

func campagne_niveau_existe(niveau : int) -> bool:
	return nom_niveau(niveau) in campagne() and not campagne().get(nom_niveau(niveau)).is_empty()

func campagne_nombre_niveaux() -> int:
	return len(campagne())

func campagne_lire_noms_niveaux() -> Array:
	return campagne().keys()

func campagne_lire_nom() -> String:
	"Nom de la campagne"
	if le_joueur_existe():
		return lire_sauvegarde().get('nom_campagne', "")
	return ""

func campagne_lire_prochain_niveau() -> int:
	"Désigne le prochain niveau de campagne à jouer"
	var prochain_niveau = 9999
	for nom_du_niveau in campagne_lire_noms_niveaux():
		var niveau = valeur_niveau(nom_du_niveau)
		if campagne_niveau_existe(niveau) \
			and niveau < prochain_niveau:
			prochain_niveau = niveau
	if prochain_niveau == 9999:
		LogService.log_erreur("Aucun prochain niveau de campagne trouvé")
		prochain_niveau = 0
	return prochain_niveau

func campagne_lire_liste_plateaux_du_niveau(niveau : int) -> Array:
	if campagne_niveau_existe(niveau):
		return campagne().get(nom_niveau(niveau))
	return [] # Liste plateaux vide

func campagne_nombre_plateaux_pour_le_niveau(niveau : int) -> int:
	return len(campagne_lire_liste_plateaux_du_niveau(niveau))

func campagne_lire_premier_plateau(niveau : int) -> Dictionary:
	if campagne_niveau_existe(niveau):
		return campagne_lire_liste_plateaux_du_niveau(niveau).front()
	return {} # Plateau vide

# Methodes haut niveau
func campagne_lire_prochain_plateau_pour_niveau_courant() -> Dictionary:
	"Désigne le prochain plateau de campagne à jouer pour le niveau courant"
	var niveau = enregistrement_campagne_lire_valeur_niveau_joueur()
	return campagne_lire_premier_plateau(niveau)

func campagne_lire_prochain_gameplay() -> String:
	"Désigne le prochain gameplay de campagne à jouer"
	var niveau = campagne_lire_prochain_niveau()
	var plateau = campagne_lire_premier_plateau(niveau)
	return plateau.get("gameplay", 'aucun_gameplay')

func campagne_supprimer_et_memoriser_plateau_courant() -> bool:
	"Efface le plateau courant et memorise dans le jeu libre."
	if le_joueur_existe() and enregistrement_campagne_lire_statut_dernier_plateau() == 'en cours':
		var niveau = enregistrement_campagne_lire_valeur_niveau_joueur()
		var liste_plateaux = campagne_lire_liste_plateaux_du_niveau(niveau)
		var plateau_courant = {}
		if not liste_plateaux.is_empty():
			plateau_courant = liste_plateaux.pop_front()
			# extraire difficulté de 'plateau_courant'
			var difficulte_int : int = roundi(plateau_courant.get('difficulte'))
			var difficulte_str = str(difficulte_int)
			# Deplacer le plateau dans les plateaux libres
			if not plateaux_libres_difficulte_existe(difficulte_int):
				plateaux_libres()[difficulte_str] = []
			plateaux_libres_lire_liste_plateaux_de_difficulte(difficulte_int).append(plateau_courant)
		if campagne_lire_liste_plateaux_du_niveau(niveau).is_empty():
			# Le niveau est terminé, effacer sa reference dans les plateaux restants.
			campagne().erase(nom_niveau(niveau))
		_enregistrer_sauvegarde_joueur()
		return len(plateau_courant) != 0
	return false

func campagne_supprimer_et_oublier_plateau_courant() -> bool:
	"Efface et oublie le plateau courant."
	if le_joueur_existe() and enregistrement_campagne_lire_statut_dernier_plateau() == 'en cours':
		var niveau = enregistrement_campagne_lire_valeur_niveau_joueur()
		# Effacer le plateau courant de la campagne
		var liste_plateaux = campagne_lire_liste_plateaux_du_niveau(niveau)
		var plateau_courant = {}
		if not liste_plateaux.is_empty():
			plateau_courant = liste_plateaux.pop_front()
		if campagne_lire_liste_plateaux_du_niveau(niveau).is_empty():
			# Le niveau est terminé, effacer sa reference dans les plateaux restants.
			campagne().erase(nom_niveau(niveau))
		_enregistrer_sauvegarde_joueur()
		return len(plateau_courant) != 0
	return false

func campagne_supprimer_les_plateaux() -> void:
	"Efface toute la campagne."
	if le_joueur_existe():
		campagne().clear()
		_enregistrer_sauvegarde_joueur()

func campagne_lire_nombre_de_plateaux_realisables_pour_niveau_courant() -> int:
	if le_joueur_existe():
		var niveau = enregistrement_campagne_lire_valeur_niveau_joueur()
		return campagne_nombre_plateaux_pour_le_niveau(niveau)
	return 0

func campagne_lire_nombre_de_niveaux_realisables() -> int:
	return campagne_nombre_niveaux()

func campagne_le_niveau_est_termine(niveau : int) -> bool:
	return not campagne_niveau_existe(niveau)

func campagne_la_campagne_est_terminee() -> bool:
	return campagne_nombre_niveaux() == 0

###############################################
# Nombre de parties
# "nombre_de_parties": { "18": 5, "20": 4, "24": 4 }
###############################################

func nombre_de_parties() -> Dictionary:
	if le_joueur_existe():
		return lire_sauvegarde().get('nombre_de_parties', {})
	return {}

func nombre_de_parties_difficulte_existe(difficulte : int) -> bool:
	if le_joueur_existe():
		return str(difficulte) in nombre_de_parties()
	return false

func lire_nombre_de_parties_difficulte(difficulte : int) -> int:
	if nombre_de_parties_difficulte_existe(difficulte):
		return nombre_de_parties()[str(difficulte)]
	return 0

func nombre_de_parties_incrementer_pour_difficulte_courante() -> void:
	if le_joueur_existe():
		var niveau = enregistrement_campagne_lire_valeur_niveau_joueur()
		var difficulte_int : int = roundi(campagne_lire_premier_plateau(niveau).get('difficulte'))
		var difficulte_str = str(difficulte_int)
		if not nombre_de_parties_difficulte_existe(difficulte_int):
			nombre_de_parties()[difficulte_str] = 0
		nombre_de_parties()[difficulte_str] = roundi(nombre_de_parties()[difficulte_str] + 1)
		_enregistrer_sauvegarde_joueur()

func lire_nombre_de_parties_pour_difficulte_courante() -> int:
	if le_joueur_existe():
		var prochain_plateau = campagne_lire_prochain_plateau_pour_niveau_courant()
		if prochain_plateau:
			var difficulte_int : int = roundi(prochain_plateau.get('difficulte'))
			return lire_nombre_de_parties_difficulte(difficulte_int)
	return 0



###############################################
# Enregistrement Campagne
# 	"enregistrement_campagne": [ 
# 		{
#            "date_debut": 1789901316.0,
#            "date_fin": 1790023184.0,
#            "campagne": "campagne_1",
#            "score": { "fin_campagne": 500000.0 },
#            "niveaux": [
#                ...
#            ]
# 		}
# 	]
###############################################

func enregistrement_campagne() -> Array:
	"Retourne la liste des enregistrements de campagne"
	if le_joueur_existe():
		return lire_sauvegarde().get('enregistrement_campagne', [])
	return []

func enregistrement_campagne_existe() -> bool:
	"Indique si une campagne de niveau existe"
	return not enregistrement_campagne().is_empty()

# TODO : inutilise
func enregistrement_campagne_lire_campagne(nom_campagne : String) -> Dictionary:
	"Retourne la campagne"
	if enregistrement_campagne_existe():
		for campagne in enregistrement_campagne():
			if campagne.get('campagne') == nom_campagne:
				return campagne
	return {}

func enregistrement_campagne_lire_derniere_campagne() -> Dictionary:
	"Retourne la dernière campagne"
	if enregistrement_campagne_existe():
		return enregistrement_campagne().back()
	return {}

func enregistrement_campagne_importer_campagne(campagne: Dictionary) -> bool:
	"Importe l'intégralité d'une campagne dans la sauvegarde du joueur."
	var nom_campagne: Variant = campagne.get('campagne', '')
	var niveaux: Variant = campagne.get('niveaux', null)
	if not le_joueur_existe() or not nom_campagne is String \
		or nom_campagne.strip_edges().is_empty() or not niveaux is Array:
		LogService.log_erreur("Bdd joueurs : données de campagne importées invalides.")
		return false
	if enregistrement_campagne_lire_campagne(nom_campagne):
		LogService.log_erreur("Bdd joueurs : campagne déjà présente dans la sauvegarde.")
		return false
	if not lire_sauvegarde().has('enregistrement_campagne'):
		lire_sauvegarde()['enregistrement_campagne'] = []
	enregistrement_campagne().append(campagne.duplicate(true))
	_enregistrer_sauvegarde_joueur()
	return true

func enregistrement_campagne_fichier_est_partage(empreinte: String) -> bool:
	if not le_joueur_existe() or empreinte.is_empty():
		return false
	var campagnes_partagees: Variant = lire_sauvegarde().get('campagnes_partagees_fichiers', [])
	return campagnes_partagees is Array and campagnes_partagees.has(empreinte)

func enregistrement_campagne_marquer_fichier_partage(empreinte: String) -> bool:
	if not le_joueur_existe() or empreinte.is_empty():
		return false
	var sauvegarde := lire_sauvegarde()
	if not sauvegarde.has('campagnes_partagees_fichiers'):
		sauvegarde['campagnes_partagees_fichiers'] = []
	var campagnes_partagees: Variant = sauvegarde['campagnes_partagees_fichiers']
	if not campagnes_partagees is Array:
		LogService.log_erreur("Bdd joueurs : liste des campagnes partagées invalide.")
		return false
	if not campagnes_partagees.has(empreinte):
		campagnes_partagees.append(empreinte)
		_enregistrer_sauvegarde_joueur()
	return true

func enregistrement_campagne_lire_nom_derniere_campagne() -> String:
	"Retourne le nom de la dernière campagne"
	if enregistrement_campagne_existe():
		return enregistrement_campagne_lire_derniere_campagne().get('campagne', '')
	return ""

func enregistrement_campagne_modifier_nom_derniere_campagne(nouveau_nom : String) -> bool:
	"Modifie le nom de la dernière campagne"
	if enregistrement_campagne_existe():
		enregistrement_campagne_lire_derniere_campagne()['campagne'] = nouveau_nom
		_enregistrer_sauvegarde_joueur()
		return true
	return false

func enregistrement_campagne_en_cours() -> bool:
	"Indique si une campagne est en cours de réalisation"
	var campagne_courante = enregistrement_campagne_lire_derniere_campagne()
	if campagne_courante:
		return not campagne_courante.get('date_fin')
	return false
	
func enregistrement_campagne_initialiser_une_nouvelle_campagne() -> bool:
	"Crée et initialise une nouvelle campagne"
	if le_joueur_existe() and not enregistrement_campagne_en_cours():
		var enregistrement_nouvelle_campagne = {
			'campagne': campagne_lire_nom(),
			'date_debut': Time.get_unix_time_from_system(), # Timestamp
			'date_fin': 0., # Timestamp
			'score': {},
			'niveaux': []
			}
		if not enregistrement_campagne():
			lire_sauvegarde()['enregistrement_campagne'] = []
		lire_sauvegarde()['enregistrement_campagne'].append(enregistrement_nouvelle_campagne)
		_enregistrer_sauvegarde_joueur()
		return true
	return false

func enregistrement_campagne_terminer_campagne() -> void:
	"Enregistre la date de fin de la campagne"
	var campagne_courante = enregistrement_campagne_lire_derniere_campagne()
	if campagne_courante:
		if not campagne_courante.get('date_fin'):
			campagne_courante['date_fin'] = Time.get_unix_time_from_system() # Timestamp
			_enregistrer_sauvegarde_joueur()


###############################################
# Enregistrement Campagne / Score / Campagne
#    "score": { "fin_campagne": 500000.0 }
###############################################

func enregistrement_campagne_modifier_score_fin_campagne(score : int) -> void:
	var campagne_courante = enregistrement_campagne_lire_derniere_campagne()
	if campagne_courante:
		if 'score' not in campagne_courante:
			campagne_courante['score'] = {}
		campagne_courante['score']['fin_campagne'] = score
		_enregistrer_sauvegarde_joueur()

func enregistrement_campagne_lire_score_derniere_fin_campagne() -> int:
	var derniere_campagne = enregistrement_campagne_lire_derniere_campagne()
	if derniere_campagne:
		if derniere_campagne.get('score') and derniere_campagne.get('score').get('fin_campagne'):
			return derniere_campagne.get('score').get('fin_campagne')
	return 0

func enregistrement_campagne_lire_score_fin_campagne(campagne  : Dictionary) -> int:
	if campagne:
		if campagne.get('score') and campagne.get('score').get('fin_campagne'):
			return campagne.get('score').get('fin_campagne')
	return 0

###############################################
# ENREGISTREMENT CAMPAGNE / NIVEAUX
# "niveaux": [
# {
#     'niveau': niveau_20,
#     'date_debut': 1748785865.997,
#     'date_fin': 0.,
#     'score': { 'ascension': 500000, 'ascension_sans_detour': 500000},
#     'plateaux': [
#        {
#            'nom': "AA .BB .AB ",
#            'gameplay': 'CLASSIQUE', # 'CLASSIQUE', 'MEMOIRE', 'DEFI_DU_GOSSE', 'DEFI_DU_BOSS', 'QUI_PERD_GAGNE', 'FLEMMARD', 'DOUBLE_FACE', 'DICO'
#            'date_debut': 1748785865.997,
#            'date_fin': 1748785855.0,
#            'difficulte': 18,
#            'statut': 'reussi', # 'en cours', 'abandonné', 'passé', 'reussi'
#            'duree': 0,
#            'score': { 'duree': 4000, 'ratio_reussite': 2000 },
#            'coups joués': [
#               {'depart': 2, 'arrivee': 1},
#               {'depart': 2, 'arrivee': 0}
#            ]
#        }
#     ]
# }
###############################################

func enregistrement_campagne_niveau_existe() -> bool:
	"Indique si un niveau existe"
	return enregistrement_campagne_lire_derniere_campagne() \
		and not enregistrement_campagne_lire_derniere_campagne().get('niveaux', []).is_empty()

func enregistrement_campagne_lire_niveaux(campagne : Dictionary) -> Array:
	"Retourne les niveaux"
	if campagne:
		return campagne.get('niveaux', [])
	return []

func enregistrement_campagne_lire_derniers_niveaux() -> Array:
	"Retourne les derniers niveaux"
	if enregistrement_campagne_niveau_existe():
		return enregistrement_campagne_lire_derniere_campagne().get('niveaux', [])
	return []

# TODO : inutilise
func enregistrement_campagne_lire_niveau(nom_campagne : String, nom_niveau : String) -> Dictionary:
	"Retourne le niveau de la campagne"
	var campagne = enregistrement_campagne_lire_campagne(nom_campagne)
	if campagne:
		for niveau in campagne.get('niveaux', []):
			if niveau.get('niveau') == nom_niveau:
				return niveau
	return {}

func enregistrement_campagne_lire_nom_niveau(niveau : Dictionary) -> String:
	"Retourne le nom du niveau"
	return niveau.get('niveau', '')

func enregistrement_campagne_lire_dernier_niveau() -> Dictionary:
	"Retourne le dernier niveau"
	if enregistrement_campagne_niveau_existe():
		return enregistrement_campagne_lire_derniers_niveaux().back()
	return {}

func enregistrement_campagne_lire_nom_dernier_niveau() -> String:
	"Retourne le nom du dernier niveau"
	if enregistrement_campagne_niveau_existe():
		return enregistrement_campagne_lire_dernier_niveau().get('niveau', '')
	return ""

func enregistrement_campagne_niveau_en_cours() -> bool:
	"Indique si un niveau est en cours de réalisation"
	var niveau_courant = enregistrement_campagne_lire_dernier_niveau()
	if niveau_courant:
		return not niveau_courant.get('date_fin')
	return false
	
func enregistrement_campagne_initialiser_un_nouveau_niveau(forcer_valeur_niveau = 0) -> bool:
	"Crée et initialise un nouveau niveau"
	var valeur_prochain_niveau
	if forcer_valeur_niveau:
		valeur_prochain_niveau = forcer_valeur_niveau
	else:
		valeur_prochain_niveau = lire_prochain_niveau_de_campagne()
	if valeur_prochain_niveau:
		var nom_prochain_niveau = nom_niveau(valeur_prochain_niveau)
		if le_joueur_existe() \
			and enregistrement_campagne_en_cours() \
			and not enregistrement_campagne_niveau_en_cours():
			var enregistrement_campagne_niveau = {
				'niveau': nom_prochain_niveau,
				'date_debut': Time.get_unix_time_from_system(), # Timestamp
				'date_fin': 0., # Timestamp
				'score': {},
				'plateaux': []
				}
			enregistrement_campagne_lire_derniere_campagne()['niveaux'].append(enregistrement_campagne_niveau)
			_enregistrer_sauvegarde_joueur()
			return true
	return false

func enregistrement_campagne_terminer_niveau() -> void:
	"Enregistre la date de fin d'un niveau"
	var niveau_courant = enregistrement_campagne_lire_dernier_niveau()
	if niveau_courant:
		if not niveau_courant.get('date_fin'):
			niveau_courant['date_fin'] = Time.get_unix_time_from_system() # Timestamp
			_enregistrer_sauvegarde_joueur()

# Haut niveau
func lire_prochain_niveau_de_campagne() -> int:
	"Retourne le prochain niveau de la campagne à jouer (vide si aucun niveau restant)"
	if not enregistrement_campagne_niveau_existe() and campagne_nombre_niveaux() == 0:
		# Aucun niveau de campagne n'existe
		LogService.log_erreur('\t', "Aucun niveau de campagne disponible")
		return 0

	if not enregistrement_campagne_niveau_existe() or not enregistrement_campagne_niveau_en_cours():
		# Prendre le prochain niveau de campagne
		return campagne_lire_prochain_niveau()

	LogService.log_erreur('\t', "Prochain niveau inconnu")
	return 0

func enregistrement_campagne_inserer_niveau(nom_campagne : String, niveau : Dictionary) -> bool:
	"Insere un niveau dans le respect de sa chronologie"
	var _nom_niveau = niveau.get('niveau', '')
	if nom_campagne and _nom_niveau:
		var campagne_enregistrement = enregistrement_campagne_lire_campagne(nom_campagne)
		if campagne_enregistrement:
			var date_debut_niveau = niveau.get('date_debut', 0.)
			# Parcourir les niveaux dans l'ordre croissant de date
			var liste_niveaux = enregistrement_campagne_lire_niveaux(campagne_enregistrement)
			var nb_niveaux = len(liste_niveaux)
			for index in range(nb_niveaux):
				var enregistrement_courant = liste_niveaux[index]
				if enregistrement_courant.get('date_debut', 0.) > date_debut_niveau:
					# Le niveau à inserer est antérieur, prendre la place du niveau courant
					liste_niveaux.insert(index, niveau)
					_enregistrer_sauvegarde_joueur()
					return true
			# Le niveau à inserer est le dernier
			liste_niveaux.append(niveau)
			_enregistrer_sauvegarde_joueur()
			return true
	LogService.log_erreur("Bdd joueurs : campagne ", nom_campagne, " - Aucune insertion enregistrement du niveau ", _nom_niveau)
	return false

func enregistrement_campagne_inserer_campagne(nom_campagne : String, donnees_campagne : Dictionary) -> void:
	"Importe une campagne dans l'enregistrement du joueur"
	var campagne_importee: Dictionary = donnees_campagne.duplicate(true)
	if le_joueur_existe() and not enregistrement_campagne_lire_campagne(nom_campagne):
		# Importe la nouvelle campagne
		campagne_importee['niveaux'] = []
		if not lire_sauvegarde().has('enregistrement_campagne'):
			lire_sauvegarde()['enregistrement_campagne'] = []
		enregistrement_campagne().append(campagne_importee)
		_enregistrer_sauvegarde_joueur()
	if campagne_importee.get('score'):
		var campagne_enregistree : Dictionary = enregistrement_campagne_lire_campagne(nom_campagne)
		campagne_enregistree['score'] = campagne_importee['score'].duplicate(true)
		_enregistrer_sauvegarde_joueur()

###############################################
# Niveaux / Niveau
###############################################

func enregistrement_campagne_lire_niveau_joueur() -> String:
	"Retourne le niveau actuel du joueur"
	var dict_niveau = enregistrement_campagne_lire_dernier_niveau()
	if dict_niveau:
		return dict_niveau.get('niveau','')
	return ''

func enregistrement_campagne_lire_valeur_niveau_joueur() -> int:
	"Retourne le niveau actuel du joueur"
	var nom_du_niveau = enregistrement_campagne_lire_niveau_joueur()
	if nom_du_niveau:
		return valeur_niveau(nom_du_niveau)
	return 0

func enregistrement_campagne_lire_niveau_longueur_realisee() -> int:
	"Retourne le nombre de plateaux du niveau réalisés"
	var dernier_niveau = enregistrement_campagne_lire_dernier_niveau()
	if dernier_niveau:
		var lg_niveau = 0
		for plateau in dernier_niveau.get('plateaux', []):
			if plateau.get('statut') == 'reussi':
				lg_niveau += 1
		return lg_niveau
	return 0

# Haut niveau
func lire_longueur_niveau_courant() -> int:
	"Retourne le nombre de plateaux du niveau (total)"
	var lg_niveau = campagne_lire_nombre_de_plateaux_realisables_pour_niveau_courant()
	lg_niveau += enregistrement_campagne_lire_niveau_longueur_realisee()
	return lg_niveau

func lire_pourcentage_niveau_realise() -> int:
	"Pourcentage de réalisation (retourne 99 pour 99%, 15 pour 15% ...)"
	if enregistrement_campagne_niveau_en_cours():
		var nb_niveaux_realises = enregistrement_campagne_lire_niveau_longueur_realisee()
		var nb_niveaux_restant = campagne_lire_nombre_de_plateaux_realisables_pour_niveau_courant()
		var nb_niveaux_totaux = nb_niveaux_realises + nb_niveaux_restant
		if not nb_niveaux_totaux:
			return 0
		return roundi(100. * nb_niveaux_realises / nb_niveaux_totaux)
	return 0

###############################################
# Niveaux / Date debut
# Niveaux / Date fin
###############################################


###############################################
# Niveaux / Longueur detour
###############################################

func enregistrement_campagne_lire_ratio_reussite_niveau() -> int:
	"Pourcentage de réussite du niveau (retourne 99 pour 99%, 15 pour 15% ...)"
	if enregistrement_campagne_niveau_existe():
		var nb_essais  = enregistrement_campagne_lire_nombre_plateaux_acheves()
		var nb_succes = enregistrement_campagne_lire_niveau_longueur_realisee()
		if not nb_essais:
			return 0
		return roundi(100. * nb_succes / nb_essais)
	return 0

###############################################
# Niveaux / Score / Niveau et Niveau parfait
# 'score': { 'niveau': 500000, 'niveau_parfait': 500000},
###############################################

func enregistrement_campagne_modifier_score_niveau(score : int) -> void:
	var niveau_courant = enregistrement_campagne_lire_dernier_niveau()
	if niveau_courant:
		if 'score' not in niveau_courant:
			niveau_courant['score'] = {}
		niveau_courant['score']['niveau'] = score
		_enregistrer_sauvegarde_joueur()

func enregistrement_campagne_modifier_score_niveau_parfait(score : int) -> void:
	var niveau_courant = enregistrement_campagne_lire_dernier_niveau()
	if niveau_courant:
		if 'score' not in niveau_courant:
			niveau_courant['score'] = {}
		niveau_courant['score']['niveau_parfait'] = score
		_enregistrer_sauvegarde_joueur()

func enregistrement_campagne_lire_score_dernier_niveau() -> int:
	var niveau_courant = enregistrement_campagne_lire_dernier_niveau()
	if niveau_courant:
		if niveau_courant.get('score') and niveau_courant.get('score').get('niveau'):
			return niveau_courant.get('score').get('niveau')
	return 0

func enregistrement_campagne_lire_score_niveau(niveau  : Dictionary) -> int:
	if niveau and niveau.get('score') and niveau.get('score').get('niveau'):
		return niveau.get('score').get('niveau')
	return 0

func enregistrement_campagne_lire_score_niveau_parfait(niveau  : Dictionary) -> int:
	if niveau and niveau.get('score') and niveau.get('score').get('niveau_parfait'):
		return niveau.get('score').get('niveau_parfait')
	return 0


###############################################
# Niveaux / Plateaux
# 	'plateaux': [
# 		{
# 			'nom': "AA .BB .AB ",
# 			'date_debut': 1748785865.997,
# 			'date_fin': 1748785855.0,
# 			'difficulte': 18,
# 			'statut': 'reussi', # 'en cours', 'abandonné', 'passé', 'reussi'
# 			'duree': 0,
# 			'score': { 'duree': 4000, 'ratio_reussite': 2000 },
# 			'coups joués': [
# 				{'depart': 2, 'arrivee': 1},
# 				{'depart': 2, 'arrivee': 0}
# 			]
# 		}
# 	]
###############################################

func enregistrement_campagne_plateau_existe() -> bool:
	"Indique si un plateau existe"
	return enregistrement_campagne_niveau_existe() and not enregistrement_campagne_lire_dernier_niveau().get('plateaux', []).is_empty()

func enregistrement_campagne_plateau_en_cours() -> bool:
	"Indique si un plateau est en cours de réalisation"
	if enregistrement_campagne_plateau_existe():
		var niveau_courant = enregistrement_campagne_lire_dernier_niveau()
		var plateau = niveau_courant.get('plateaux').back()
		return not plateau.get('date_fin')
	return false

func enregistrement_campagne_initialiser_un_nouveau_plateau(nom : String,
									gameplay : String,
									difficulte : int) -> bool:
	"Crée et initialise un nouveau plateau"
	if le_joueur_existe() \
		and enregistrement_campagne_en_cours() \
		and enregistrement_campagne_niveau_en_cours() \
		and not enregistrement_campagne_plateau_en_cours():
		var nouveau_plateau = {
			'nom': nom,
			'gameplay': gameplay,
			'date_debut': Time.get_unix_time_from_system(), # Timestamp
			'date_fin': 0.,
			'duree': 0,
			'difficulte': roundi(difficulte),
			'statut': 'en cours', # 'en cours', 'abandonné', 'passé', 'reussi'
			'score': {},
			'coups joués': []
			}
		var niveau_courant = enregistrement_campagne_lire_dernier_niveau()
		if niveau_courant:
			var liste_plateaux = niveau_courant.get('plateaux')
			liste_plateaux.append(nouveau_plateau)
			_enregistrer_sauvegarde_joueur()
			return true
	return false

func enregistrement_campagne_terminer_plateau() -> void:
	"Enregistre la date de fin d'un plateau"
	if enregistrement_campagne_plateau_en_cours():
		var niveau_courant = enregistrement_campagne_lire_dernier_niveau()
		var plateau = niveau_courant.get('plateaux').back()
		if plateau.get('statut') == 'en cours':
			# Reprise avec un plateau inachevé => durée nulle + statut 'passé'
			plateau['date_fin'] = plateau['date_debut'] # Timestamp
			plateau['duree'] = 0.
			plateau['statut'] = 'passé'
		else:
			# Fin du plateau courant
			plateau['date_fin'] = Time.get_unix_time_from_system() # Timestamp
			plateau['duree'] = plateau.get('date_fin') - plateau.get('date_debut')
		_enregistrer_sauvegarde_joueur()

func enregistrement_campagne_lire_nombre_plateaux_acheves() -> int:
	"Retourne le nombre de plateaux achevées"
	if enregistrement_campagne_plateau_existe():
		var niveau_courant = enregistrement_campagne_lire_dernier_niveau()
		if enregistrement_campagne_plateau_en_cours():
			return len(niveau_courant.get('plateaux')) - 1
		else:
			return len(niveau_courant.get('plateaux'))
	return 0

###############################################
# Niveaux / Plateaux / Nom
# Niveaux / Plateaux / Gameplay
# Niveaux / Plateaux / Date debut
# Niveaux / Plateaux / Date fin
# Niveaux / Plateaux / duree
# Niveaux / Plateaux / Difficulte
###############################################

func enregistrement_campagne_lire_plateaux(niveau : Dictionary) -> Array:
	"Retourne les niveaux"
	if niveau:
		return niveau.get('plateaux', [])
	return []

# TODO : inutilise
func enregistrement_campagne_lire_plateau(nom_campagne : String,
										nom_niveau : String,
										nom_plateau : String) -> Dictionary:
	"Retourne le plateau du niveau de la campagne"
	var niveau = enregistrement_campagne_lire_niveau(nom_campagne, nom_niveau)
	if niveau:
		for plateau in niveau.get('plateaux', []):
			if plateau.get('nom') == nom_plateau:
				return plateau
	return {}

func enregistrement_campagne_lire_dernier_plateau() -> Dictionary:
	if enregistrement_campagne_plateau_existe():
		var niveau_courant = enregistrement_campagne_lire_dernier_niveau()
		var plateau = niveau_courant.get('plateaux').back()
		return plateau
	return {}

func enregistrement_campagne_lire_nom_plateau() -> String:
	var plateau = enregistrement_campagne_lire_dernier_plateau()
	if plateau:
		return plateau.get('nom')
	return ""

func enregistrement_campagne_lire_gameplay_plateau() -> String:
	var plateau = enregistrement_campagne_lire_dernier_plateau()
	if plateau:
		return plateau.get('gameplay')
	return ""

func enregistrement_campagne_lire_duree_plateau() -> float:
	var plateau = enregistrement_campagne_lire_dernier_plateau()
	if plateau:
		if not plateau.get('date_fin'):
			# Plateau en cours
			var now = Time.get_unix_time_from_system() # Timestamp
			plateau['duree'] = now - plateau.get('date_debut')
		return plateau.get('duree')
	return 0.
	
func enregistrement_campagne_lire_duree_plateau_recommence() -> float:
	var duree_recommence_en_s : float = 0.
	var plateau_ref = enregistrement_campagne_lire_dernier_plateau()
	if plateau_ref:
		# Cumuler le temps passé en abandon sur ce plateau
		var nom_plateau_ref = plateau_ref.get('nom')
		var dernier_niveau = enregistrement_campagne_lire_dernier_niveau()
		if dernier_niveau:
			for plateau in dernier_niveau.get('plateaux', []):
				if plateau.get('nom') == nom_plateau_ref and plateau.get('statut') == 'abandonné':
					duree_recommence_en_s += plateau.get('duree', 0.)
	return duree_recommence_en_s

func enregistrement_campagne_lire_le_temps_du_joueur() -> String: # TODO : INUTILISE !
	"""Formater la durée en une chaîne de caractères lisible."""
	var duree_secondes : float = enregistrement_campagne_lire_duree_plateau()
	var duree_restante_en_s : float = duree_secondes
	if duree_secondes:
		var millisecondes : int = roundi(fmod(duree_secondes * 1000., 1000))
		duree_restante_en_s -= millisecondes / 1000.

		var secondes : int = roundi(fmod(duree_restante_en_s, 60))
		duree_restante_en_s -= secondes

		var minutes : int =  roundi(fmod(duree_restante_en_s / 60., 60))
		duree_restante_en_s -= minutes * 60.

		var heures : int =  roundi(fmod(duree_restante_en_s / (60.*60.), 24))
		duree_restante_en_s -= heures * 60. * 60.

		var jours : int =  roundi(duree_restante_en_s / (60*60*24))
		duree_restante_en_s -= jours * 60. * 60. * 24.

		if duree_restante_en_s != 0.:
			LogService.log_erreur("enregistrement_campagne_lire_le_temps_du_joueur() : Duree restante non nulle : "
									+ str(duree_restante_en_s))

		if jours > 0:
			return str(jours) + " jours " + str(heures) + " heures"
		elif heures > 0:
			return str(heures) + " heures " + str(minutes) + " minutes"
		elif minutes > 0:
			return str(minutes) + " minutes " + str(secondes) + " secondes"
		elif secondes > 0:
			return str(secondes) + " secondes"
		else:
			return str(millisecondes) + " millisecondes"
	return ""

func enregistrement_campagne_lire_difficulte_plateau() -> int:
	var plateau = enregistrement_campagne_lire_dernier_plateau()
	if plateau:
		return roundi(plateau.get('difficulte'))
	return 0

###############################################
# Niveaux / Plateaux / Statut
# 'statut': 'en cours', # 'en cours', 'abandonné', 'passé', 'reussi'
###############################################

func enregistrement_campagne_modifier_statut_plateau(statut : String) -> void:
	var plateau = enregistrement_campagne_lire_dernier_plateau()
	if plateau:
		plateau['statut'] = statut # 'en cours', 'abandonné', 'passé', 'reussi'
		_enregistrer_sauvegarde_joueur()

func enregistrement_campagne_lire_statut_dernier_plateau() -> String:
	var plateau = enregistrement_campagne_lire_dernier_plateau()
	if plateau:
		return plateau.get('statut')
	return 'en cours'

func enregistrement_campagne_lire_statut_plateau(plateau : Dictionary) -> String:
	return plateau.get('statut', 'en cours')

###############################################
# Niveaux / Score / Niveau et Niveau parfait
# 'score': { 'duree': 4000, 'ratio_reussite': 2000 }
###############################################

func enregistrement_campagne_modifier_score_duree_plateau(score : int) -> void:
	var plateau = enregistrement_campagne_lire_dernier_plateau()
	if plateau:
		if 'score' not in plateau:
			plateau['score'] = {}
		plateau['score']['duree'] = score
		_enregistrer_sauvegarde_joueur()

func enregistrement_campagne_modifier_score_ratio_reussite_plateau(score : int) -> void:
	var plateau = enregistrement_campagne_lire_dernier_plateau()
	if plateau:
		if 'score' not in plateau:
			plateau['score'] = {}
		plateau['score']['ratio_reussite'] = score
		_enregistrer_sauvegarde_joueur()

func enregistrement_campagne_lire_score_duree_plateau(plateau : Dictionary) -> int:
	if plateau:
		if plateau.get('score') and plateau.get('score').get('duree'):
			return plateau.get('score').get('duree')
	return 0

func enregistrement_campagne_lire_score_ratio_reussite_plateau(plateau : Dictionary) -> int:
	if plateau:
		if plateau.get('score') and plateau.get('score').get('ratio_reussite'):
			return plateau.get('score').get('ratio_reussite')
	return 0

###############################################
# Niveaux / Plateaux / Coups joués
# 	'coups joués': [
# 		{'depart': 2, 'arrivee': 1},
# 		{'depart': 2, 'arrivee': 0}
# 	]
###############################################

func enregistrement_campagne_coups_joues() -> Array:
	"Retourne la liste des coups"
	if enregistrement_campagne_coups_joues_existe():
		return enregistrement_campagne_lire_dernier_plateau().get('coups joués')
	return []

func enregistrement_campagne_coups_joues_existe() -> bool:
	"Indique si un coups_joues existe"
	return enregistrement_campagne_plateau_existe() and 'coups joués' in enregistrement_campagne_lire_dernier_plateau()

func enregistrement_campagne_coups_joues_ajouter_un_nouveau_coup(depart : int,
							arrivee : int) -> bool:
	"Ajouter un nouveau coup à coups_joues"
	if enregistrement_campagne_plateau_en_cours():
		var nouveau_coup = {'depart': roundi(depart), 'arrivee': roundi(arrivee)}
		var coups_joues = enregistrement_campagne_coups_joues()
		if coups_joues != null:
			coups_joues.append(nouveau_coup)
			_enregistrer_sauvegarde_joueur()
			return true
	return false

func enregistrement_campagne_lire_nombre_coups() -> int:
	"Retourne le nombre de coups joués"
	if enregistrement_campagne_coups_joues_existe():
		return len(enregistrement_campagne_coups_joues())
	return 0


###############################################
# Plateaux lébérés par la campagne
#	"plateaux_libres": {
#        "1": [
#            {"difficulte": 1, "gameplay": "CLASSIQUE", "nom": "AAA.BBB.CCC"},
#        ],
#        "2": [
#            {"difficulte": 2, "gameplay": "MEMOIRE", "nom": "DDD.EEE.FFF"}
#        ],....
###############################################

func plateaux_libres() -> Dictionary: # TODO : INUTILISE !
	"Pointeur sur la sauvegarde des plateaux libres du joueur."
	if le_joueur_existe():
		return lire_sauvegarde().get('plateaux_libres', {})
	return {} # Aucun plateau libre

func plateaux_libres_difficulte_existe(difficulte : int) -> bool: # TODO : INUTILISE !
	return str(difficulte) in plateaux_libres()

func plateaux_libres_lire_liste_plateaux_de_difficulte(difficulte : int) -> Array: # TODO : INUTILISE !
	if plateaux_libres_difficulte_existe(difficulte):
		return plateaux_libres().get(str(difficulte))
	return [] # Liste plateaux vide
