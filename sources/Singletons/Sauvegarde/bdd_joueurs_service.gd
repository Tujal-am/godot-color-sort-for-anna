###############################################
# Gestion des sauvegardes de joueurs
###############################################

extends Node

###############################################
# Gestion des niveaux et des plateaux à jouer
###############################################
var sauvegarde_joueur = {
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
# 			'niveau': niveau_20,
# 			'date_debut': 1748785865.997,
# 			'date_fin': 0.,
# 			'score': { 'ascension': 500000, 'ascension_sans_detour': 500000},
# 			'plateaux': [
# 				{
# 					'nom': "AA .BB .AB ",
#					'gameplay': 'CLASSIQUE', # 'CLASSIQUE', 'MEMOIRE', 'DEFI_DU_GOSSE', 'DEFI_DU_BOSS', 'QUI_PERD_GAGNE', 'FLEMMARD', 'DOUBLE_FACE', 'DICO'
# 					'date_debut': 1748785865.997,
# 					'date_fin': 1748785855.0,
# 					'difficulte': 18,
# 					'statut': 'reussi', # 'en cours', 'abandonné', 'reussi'
# 					'duree': 0,
# 					'score': { 'duree': 4000, 'ratio_reussite': 2000 },
# 					'coups joués': [
# 						{'depart': 2, 'arrivee': 1},
# 						{'depart': 2, 'arrivee': 0}
# 					]
# 				}
# 			]
# 		}
# 	]
# }

var fichier_sauvegarde = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connecter les signaux attendus
	var pcs = get_node("/root/ProgressionCampagneService")
	pcs.fin_niveau.connect(_on_progression_campagne_service_fin_niveau)

	# Creation compte initial 'Alain Konu'
	if not FichiersJsonService.json_file_exists("sauvegarde_joueur_00.json"):
		ajouter_un_nouveau_joueur('Alain Konu', 'sauvegarde_joueur_00.json')

func _on_progression_campagne_service_fin_niveau():
	enregistrement_terminer_niveau()


# <<< API externe
func ajouter_un_nouveau_joueur(nom_nouveau_joueur : String, nom_nouveau_fichier : String) -> bool:
	"""Crée un nouveau joueur si le nom est libre"""
	# Vérifie que le nom est libre
	if not nom_nouveau_joueur:
		return false
	if not nom_nouveau_fichier or FichiersJsonService.json_file_exists("user://" + nom_nouveau_fichier):
		return false
	# Crée le compte et l'enregistre
	sauvegarde_joueur = sauvegarde_vierge(nom_nouveau_joueur)
	# Initialiser les plateaux avec 'BDD Plateaux'
	sauvegarde_joueur['campagne'] = SauvegardeBddPlateauxService.plateau_liste_niveaux_duplicate()
	
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
		sauvegarde_joueur = sauvegarde_vierge(nom_joueur)
		# Initialiser les plateaux avec 'BDD Plateaux'
		sauvegarde_joueur['campagne'] = SauvegardeBddPlateauxService.plateau_liste_niveaux_duplicate()
		_enregistrer_sauvegarde_joueur()
		liberer_le_joueur()
		LogService.log_debug("Reset de la campagne pour le joueur :", nom_joueur)

func remplacer_campagne_des_joueurs():
	"""Parcourir tous les joueurs et remplacer les plateaux à jouer par ceux du fichier courant"""
	# Parcourir chaque joueurs
	for nom_joueur in SauvegardeListeJoueursService.retourner_la_liste_des_joueurs():
		fichier_sauvegarde = SauvegardeListeJoueursService.retourner_le_fichier_de_sauvegarde(nom_joueur)
		_lire_sauvegarde_joueur(fichier_sauvegarde)
		# Clore tout niveau en cours.
		enregistrement_terminer_plateau()
		enregistrement_terminer_niveau()
		# Remplacer les plateaux residuels d'une ancienne campagne.
		# avec les plateaux de la nouvelle campagne
		sauvegarde_joueur['campagne'] = SauvegardeBddPlateauxService.plateau_liste_niveaux_duplicate()
		# Enregistrer les changements
		_enregistrer_sauvegarde_joueur()
		liberer_le_joueur()
		LogService.log_debug("Remplacement de campagne pour le joueur :", nom_joueur)

func gagner_un_plateau() -> void:
	# Valider le plateau courant (effacer de la liste des plateaux jouables)
	campagne_supprimer_plateau_courant()

	# Ajouter le temps de jeu dans le niveau courant
	enregistrement_modifier_statut_plateau('reussi')
	enregistrement_terminer_plateau()

func abandonner_un_plateau() -> void:
	# En cas d'abandon, pas d'enrgistrement du temps.
	enregistrement_modifier_statut_plateau('abandonné')
	enregistrement_terminer_plateau()

func commencer_un_plateau() -> void:
	# Ajouter le nouveau plateau
	var prochain_plateau = campagne_lire_prochain_plateau_pour_niveau_courant()
	if prochain_plateau:
		enregistrement_initialiser_un_nouveau_plateau(
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
	var lecture_sauvegarde_joueur = FichiersJsonService.read_json_file(fichier)
	if lecture_sauvegarde_joueur:
		fichier_sauvegarde = fichier
		sauvegarde_joueur = lecture_sauvegarde_joueur.duplicate(true)
		_print_bdd_joueurs()
		return true
	else:
		fichier_sauvegarde = ""
		LogService.log_erreur("Erreur de lecture de la sauvegarde du joueur actuel (", fichier, ")")
	return false

func _print_bdd_joueurs() -> void:
	#LogService.log_debug("sauvegarde_joueur *", sauvegarde_joueur['nom'],"* = ", sauvegarde_joueur)
	LogService.log_debug("sauvegarde_joueur *", sauvegarde_joueur.get('nom', ''),"* :")
	LogService.log_debug('\t', "plateau=", enregistrement_lire_nom_plateau())
	LogService.log_debug('\t', "nombre_de_parties=", sauvegarde_joueur.get('nombre_de_parties', 0))
	LogService.log_debug('\t', "len(enregistrement_campagne)=", len(sauvegarde_joueur.get('enregistrement_campagne', [])))
	#if len(enregistrement()):
	#	LogService.log_debug('\t', "derniere campagne=", enregistrement().back())

func _enregistrer_sauvegarde_joueur() -> void:
	if fichier_sauvegarde:
		FichiersJsonService.write_json_file(fichier_sauvegarde, sauvegarde_joueur.duplicate(true))
		LogService.log_debug("Progression sauvegardée")


###############################################
# Nom
# "nom": "nom joueur"
###############################################

func lire_nom_joueur() -> String:
	if le_joueur_existe():
		return sauvegarde_joueur.get('nom')
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
		return sauvegarde_joueur.get('campagne', {})
	return {} # Campagne épuisée

func campagne_niveau_existe(niveau : int) -> bool:
	return nom_niveau(niveau) in campagne() and not campagne().get(nom_niveau(niveau)).is_empty()

func campagne_nombre_niveaux() -> int:
	return len(campagne())

func lire_campagne_liste_niveaux() -> Array:
	return campagne().keys()

func campagne_lire_prochain_niveau() -> int:
	"Désigne le prochain niveau de campagne à jouer"
	var prochain_niveau = 9999
	for nom_du_niveau in lire_campagne_liste_niveaux():
		var niveau = valeur_niveau(nom_du_niveau)
		if campagne_niveau_existe(niveau) \
			and niveau < prochain_niveau:
			prochain_niveau = niveau
	if prochain_niveau == 9999:
		LogService.log_erreur("Aucun prochain niveau de campagne trouvé")
	return prochain_niveau

func lire_campagne_liste_plateaux_du_niveau(niveau : int) -> Array:
	if campagne_niveau_existe(niveau):
		return campagne().get(nom_niveau(niveau))
	return [] # Liste plateaux vide

func campagne_nombre_plateaux_pour_le_niveau(niveau : int) -> int:
	return len(lire_campagne_liste_plateaux_du_niveau(niveau))

func campagne_lire_premier_plateau(niveau : int) -> Dictionary:
	if campagne_niveau_existe(niveau):
		return lire_campagne_liste_plateaux_du_niveau(niveau).front()
	return {} # Plateau vide

# Methodes haut niveau
func campagne_lire_prochain_plateau_pour_niveau_courant() -> Dictionary:
	"Désigne le prochain plateau de campagne à jouer pour le niveau courant"
	var niveau = enregistrement_lire_valeur_niveau_joueur()
	return campagne_lire_premier_plateau(niveau)

func campagne_supprimer_plateau_courant() -> bool:
	"Efface le plateau courant."
	if le_joueur_existe() and enregistrement_lire_statut_plateau() == 'en cours':
		var niveau = enregistrement_lire_valeur_niveau_joueur()
		var plateau_courant = lire_campagne_liste_plateaux_du_niveau(niveau).pop_front()
		# extraire difficulté de 'plateau_courant'
		var difficulte_int : int = roundi(plateau_courant.get('difficulte'))
		var difficulte_str = str(difficulte_int)
		# Deplacer le plateau dans les plateaux libres
		if not plateaux_libres_difficulte_existe(difficulte_int):
			plateaux_libres()[difficulte_str] = []
		plateaux_libres_lire_liste_plateaux_de_difficulte(difficulte_int).append(plateau_courant)
		if lire_campagne_liste_plateaux_du_niveau(niveau).is_empty():
			# Le niveau est terminé, effacer sa reference dans les plateaux restants.
			campagne().erase(nom_niveau(niveau))
		_enregistrer_sauvegarde_joueur()
		return true
	return false

func campagne_lire_nombre_de_plateaux_realisables_pour_niveau_courant() -> int:
	if le_joueur_existe():
		var niveau = enregistrement_lire_valeur_niveau_joueur()
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
		return sauvegarde_joueur.get('nombre_de_parties')
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
		var niveau = enregistrement_lire_valeur_niveau_joueur()
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
# Niveaux
# 	"enregistrement_campagne": [ 
# 		{
# 			'niveau': 20,
#			'date_debut': 1748785865.997,
# 			'date_fin': 0.,
# 			'score': { 'niveau': 500000, 'niveau_sans_detour': 500000},
# 			'plateaux': [
# 				{
# 					'nom': "AA .BB .AB ",
# 					'date_debut': 1748785865.997,
# 					'date_fin': 1748785855.0,
# 					'difficulte': 18,
# 					'statut': 'reussi', # 'en cours', 'abandonné', 'reussi'
# 					'duree': 0,
# 					'score': { 'duree': 4000, 'ratio_reussite': 2000 },
# 					'coups joués': [
# 						{'depart': 2, 'arrivee': 1},
# 						{'depart': 2, 'arrivee': 0}
# 					]
# 				}
# 			]
# 		}
# 	]
###############################################

func enregistrement() -> Array:
	"Retourne la liste des enregistrements de campagne"
	if le_joueur_existe():
		return sauvegarde_joueur.get('enregistrement_campagne', [])
	return []

func enregistrement_niveau_existe() -> bool:
	"Indique si un niveau existe"
	return not enregistrement().is_empty()

func enregistrement_lire_dernier_niveau() -> Dictionary:
	"Retourne le dernier niveau"
	if enregistrement_niveau_existe():
		return enregistrement().back()
	return {}

func enregistrement_niveau_en_cours() -> bool:
	"Indique si un niveau est en cours de réalisation"
	var niveau_courant = enregistrement_lire_dernier_niveau()
	if niveau_courant:
		return not niveau_courant.get('date_fin')
	return false
	
func enregistrement_initialiser_un_nouveau_niveau() -> bool:
	"Crée et initialise un nouveau niveau"
	var prochain_niveau = lire_prochain_niveau_de_campagne()
	if prochain_niveau:
		var nom_du_niveau = nom_niveau(prochain_niveau)
		if not enregistrement_niveau_en_cours():
			var enregistrement_niveau = {
				'niveau': nom_du_niveau,
				'date_debut': Time.get_unix_time_from_system(), # Timestamp
				'date_fin': 0., # Timestamp
				'score': {},
				'plateaux': []
				}
			if not enregistrement():
				sauvegarde_joueur['enregistrement_campagne'] = []
			sauvegarde_joueur['enregistrement_campagne'].append(enregistrement_niveau)
			_enregistrer_sauvegarde_joueur()
			return true
	return false

func enregistrement_terminer_niveau() -> void:
	"Enregistre la date de fin d'un niveau"
	var niveau_courant = enregistrement_lire_dernier_niveau()
	if niveau_courant:
		niveau_courant['date_fin'] = Time.get_unix_time_from_system() # Timestamp
		_enregistrer_sauvegarde_joueur()

# Haut niveau
func lire_prochain_niveau_de_campagne() -> int:
	"Retourne le prochain niveau de la campagne à jouer (vide si aucun niveau restant)"
	if not enregistrement_niveau_existe() and campagne_nombre_niveaux() == 0:
		# Aucun niveau de campagne n'existe
		LogService.log_erreur('\t', "Aucun niveau de campagne disponible")
		return 0

	if not enregistrement_niveau_existe() or not enregistrement_niveau_en_cours():
		# Prendre le prochain niveau de campagne
		return campagne_lire_prochain_niveau()

	LogService.log_erreur('\t', "Prochain niveau inconnu")
	return 0

###############################################
# Niveaux / Niveau
###############################################

func enregistrement_lire_valeur_niveau_joueur() -> int:
	"Retourne le niveau actuel du joueur"
	var dict_niveau = enregistrement_lire_dernier_niveau()
	if dict_niveau:
		var nom_du_niveau = dict_niveau.get('niveau')
		if nom_du_niveau:
			return valeur_niveau(nom_du_niveau)
	return 0

func enregistrement_lire_niveau_longueur_realisee() -> int:
	"Retourne le nombre de plateaux du niveau réalisés"
	var dernier_niveau = enregistrement_lire_dernier_niveau()
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
	lg_niveau += enregistrement_lire_niveau_longueur_realisee()
	return lg_niveau

func lire_pourcentage_niveau_realise() -> int:
	"Pourcentage de réalisation (retourne 99 pour 99%, 15 pour 15% ...)"
	if enregistrement_niveau_en_cours():
		var nb_niveaux_realises = enregistrement_lire_niveau_longueur_realisee()
		var nb_niveaux_restant = campagne_lire_nombre_de_plateaux_realisables_pour_niveau_courant()
		var nb_niveaux_totaux = nb_niveaux_realises + nb_niveaux_restant
		return roundi(100. * nb_niveaux_realises / nb_niveaux_totaux)
	return 0

###############################################
# Niveaux / Date debut
# Niveaux / Date fin
###############################################


###############################################
# Niveaux / Longueur detour
###############################################

func enregistrment_lire_ratio_reussite_niveau() -> int:
	"Pourcentage de réussite du niveau (retourne 99 pour 99%, 15 pour 15% ...)"
	if enregistrement_niveau_existe():
		var nb_essais  = enregistrement_lire_nombre_plateaux_acheves()
		var nb_succes = enregistrement_lire_niveau_longueur_realisee()
		return roundi(100. * nb_succes / nb_essais)
	return 0

###############################################
# Niveaux / Score / Niveau et Niveau sans détour
# 'score': { 'niveau': 500000, 'niveau_sans_detour': 500000},
###############################################

func enregistrement_modifier_score_niveau(score : int) -> void:
	var niveau_courant = enregistrement_lire_dernier_niveau()
	if niveau_courant:
		if 'score' not in niveau_courant:
			niveau_courant['score'] = {}
		niveau_courant['score']['niveau'] = score
		_enregistrer_sauvegarde_joueur()

func enregistrement_modifier_score_niveau_sans_detour(score : int) -> void:
	var niveau_courant = enregistrement_lire_dernier_niveau()
	if niveau_courant:
		if 'score' not in niveau_courant:
			niveau_courant['score'] = {}
		niveau_courant['score']['niveau_sans_detour'] = score
		_enregistrer_sauvegarde_joueur()

func enregistrement_lire_score_niveau() -> int:
	var niveau_courant = enregistrement_lire_dernier_niveau()
	if niveau_courant:
		if niveau_courant.get('score') and niveau_courant.get('score').get('niveau'):
			return niveau_courant.get('score').get('niveau')
	return 0


###############################################
# Niveaux / Plateaux
# 	'plateaux': [
# 		{
# 			'nom': "AA .BB .AB ",
# 			'date_debut': 1748785865.997,
# 			'date_fin': 1748785855.0,
# 			'difficulte': 18,
# 			'statut': 'reussi', # 'en cours', 'abandonné', 'reussi'
# 			'duree': 0,
# 			'score': { 'duree': 4000, 'ratio_reussite': 2000 },
# 			'coups joués': [
# 				{'depart': 2, 'arrivee': 1},
# 				{'depart': 2, 'arrivee': 0}
# 			]
# 		}
# 	]
###############################################

func enregistrement_plateau_existe() -> bool:
	"Indique si un plateau existe"
	return enregistrement_niveau_existe() and not enregistrement_lire_dernier_niveau().get('plateaux', []).is_empty()

func enregistrement_plateau_en_cours() -> bool:
	"Indique si un plateau est en cours de réalisation"
	if enregistrement_plateau_existe():
		var niveau_courant = enregistrement_lire_dernier_niveau()
		var plateau = niveau_courant.get('plateaux').back()
		return not plateau.get('date_fin')
	return false

func enregistrement_initialiser_un_nouveau_plateau(nom : String,
									gameplay : String,
									difficulte : int) -> bool:
	"Crée et initialise un nouveau plateau"
	if not enregistrement_plateau_en_cours():
		var nouveau_plateau = {
			'nom': nom,
			'gameplay': gameplay,
			'date_debut': Time.get_unix_time_from_system(), # Timestamp
			'date_fin': 0.,
			'duree': 0,
			'difficulte': roundi(difficulte),
			'statut': 'en cours', # 'en cours', 'abandonné', 'reussi'
			'score': {},
			'coups joués': []
			}
		var niveau_courant = enregistrement_lire_dernier_niveau()
		var liste_plateaux = niveau_courant.get('plateaux')
		liste_plateaux.append(nouveau_plateau)
		_enregistrer_sauvegarde_joueur()
		return true
	return false

func enregistrement_terminer_plateau() -> void:
	"Enregistre la date de fin d'un plateau"
	if enregistrement_plateau_en_cours():
		var niveau_courant = enregistrement_lire_dernier_niveau()
		var plateau = niveau_courant.get('plateaux').back()
		plateau['date_fin'] = Time.get_unix_time_from_system() # Timestamp
		plateau['duree'] = plateau.get('date_fin') - plateau.get('date_debut')
		_enregistrer_sauvegarde_joueur()

func enregistrement_lire_nombre_plateaux_acheves() -> int:
	"Retourne le nombre de plateaux achevées"
	if enregistrement_plateau_existe():
		var niveau_courant = enregistrement_lire_dernier_niveau()
		if enregistrement_plateau_en_cours():
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

func enregistrement_lire_dernier_plateau() -> Dictionary:
	if enregistrement_plateau_existe():
		var niveau_courant = enregistrement_lire_dernier_niveau()
		var plateau = niveau_courant.get('plateaux').back()
		return plateau
	return {}

func enregistrement_lire_nom_plateau() -> String:
	var plateau = enregistrement_lire_dernier_plateau()
	if plateau:
		return plateau.get('nom')
	return ""

func enregistrement_lire_gameplay_plateau() -> String:
	var plateau = enregistrement_lire_dernier_plateau()
	if plateau:
		return plateau.get('gameplay')
	return ""

func enregistrement_lire_duree_plateau() -> float:
	var plateau = enregistrement_lire_dernier_plateau()
	if plateau:
		return plateau.get('duree')
	return 0.

func enregistrement_lire_le_temps_du_joueur() -> String: # TODO : INUTILISE !
	"""Formater la durée en une chaîne de caractères lisible."""
	var duree_secondes = enregistrement_lire_duree_plateau()
	if duree_secondes:
		var millisecondes = (duree_secondes * 1000.) % 1000
		duree_secondes = roundi(duree_secondes - millisecondes / 1000.)

		var secondes = duree_secondes % 60
		var duree_minutes = roundi((duree_secondes - secondes) / 60.)

		var minutes = duree_minutes % 60
		var duree_heures = roundi((duree_minutes - minutes) / 60.)

		var heures = duree_heures % 24
		var jours = roundi((duree_heures - heures) / 24.)
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

func enregistrement_lire_difficulte_plateau() -> int:
	var plateau = enregistrement_lire_dernier_plateau()
	if plateau:
		return roundi(plateau.get('difficulte'))
	return 0

###############################################
# Niveaux / Plateaux / Statut
# 'statut': 'en cours', # 'en cours', 'abandonné', 'reussi'
###############################################

func enregistrement_modifier_statut_plateau(statut : String) -> void:
	var plateau = enregistrement_lire_dernier_plateau()
	if plateau:
		plateau['statut'] = statut # 'en cours', 'abandonné', 'reussi'
		_enregistrer_sauvegarde_joueur()

func enregistrement_lire_statut_plateau() -> String:
	var plateau = enregistrement_lire_dernier_plateau()
	if plateau:
		return plateau.get('statut')
	return 'en cours'

###############################################
# Niveaux / Score / Niveau et Niveau sans détour
# 'score': { 'duree': 4000, 'ratio_reussite': 2000 }
###############################################

func enregistrement_modifier_score_duree_plateau(score : int) -> void:
	var plateau = enregistrement_lire_dernier_plateau()
	if plateau:
		if 'score' not in plateau:
			plateau['score'] = {}
		plateau['score']['duree'] = score
		_enregistrer_sauvegarde_joueur()

func enregistrement_modifier_score_ratio_reussite_plateau(score : int) -> void:
	var plateau = enregistrement_lire_dernier_plateau()
	if plateau:
		if 'score' not in plateau:
			plateau['score'] = {}
		plateau['score']['ratio_reussite'] = score
		_enregistrer_sauvegarde_joueur()

###############################################
# Niveaux / Plateaux / Coups joués
# 	'coups joués': [
# 		{'depart': 2, 'arrivee': 1},
# 		{'depart': 2, 'arrivee': 0}
# 	]
###############################################

func coups_joues() -> Array:
	"Retourne la liste des coups"
	if coups_joues_existe():
		return enregistrement_lire_dernier_plateau().get('coups joués')
	return []

func coups_joues_existe() -> bool:
	"Indique si un coups_joues existe"
	return enregistrement_plateau_existe() and 'coups joués' in enregistrement_lire_dernier_plateau()

func coups_joues_ajouter_un_nouveau_coup(depart : int,
							arrivee : int) -> bool:
	"Ajouter un nouveau coup à coups_joues"
	if enregistrement_plateau_en_cours():
		var nouveau_coup = {'depart': roundi(depart), 'arrivee': roundi(arrivee)}
		coups_joues().append(nouveau_coup)
		_enregistrer_sauvegarde_joueur()
		return true
	return false

func lire_nombre_coups() -> int:
	"Retourne le nombre de coups joués"
	if coups_joues_existe():
		return len(coups_joues())
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
		return sauvegarde_joueur.get('plateaux_libres')
	return {} # Aucun plateau libre

func plateaux_libres_difficulte_existe(difficulte : int) -> bool: # TODO : INUTILISE !
	return str(difficulte) in plateaux_libres()

func plateaux_libres_lire_liste_plateaux_de_difficulte(difficulte : int) -> Array: # TODO : INUTILISE !
	if plateaux_libres_difficulte_existe(difficulte):
		return plateaux_libres().get(str(difficulte))
	return [] # Liste plateaux vide
