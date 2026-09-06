extends Node

var liste_des_scores = [
	{
		'nom': 'Alain Konu',
		'rang': 1,
		'score': 0,
		'score_txt': "0"
	}
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_initialiser_la_liste_des_scores()

func _initialiser_la_liste_des_scores() -> void:
	var lecture_liste_des_scores = FichiersJsonService.read_json_file("scores.json")
	if lecture_liste_des_scores != null:
		liste_des_scores = lecture_liste_des_scores.duplicate(true)
		LogService.log_debug("liste_des_scores = ", liste_des_scores)
	else:
		# Création du fichier initial
		_enregistrer_la_liste_des_scores()
		LogService.log_debug("Création du fichier de score initial")

func _enregistrer_la_liste_des_scores() -> void:
	FichiersJsonService.write_json_file("scores.json", liste_des_scores.duplicate(true))
	LogService.log_debug("Scores sauvegardés")

func _retourner_le_joueur(nom_joueur : String) -> Dictionary:
	for joueur in liste_des_scores:
		if joueur.get('nom') == nom_joueur:
			return joueur
	return {}

func remise_a_zero():
	for joueur in liste_des_scores:
		joueur['score'] = 0
		joueur['score_txt'] = "0"
		LogService.log_debug("Remise à zéro du score de ", joueur)
	_enregistrer_la_liste_des_scores()

func le_joueur_existe(nom_joueur : String) -> bool:
	"""Verifie si le joueur existe"""
	return _retourner_le_joueur(nom_joueur) != {}

func ajouter_un_nouveau_joueur(nom_nouveau_joueur : String) -> bool:
	"""Crée un nouveau joueur si le nom est libre"""
	# Vérifie que le nom est libre
	if not nom_nouveau_joueur:
		return false
	if le_joueur_existe(nom_nouveau_joueur):
		return false
	# Crée le score et l'enregistre
	var score = {
		'nom': nom_nouveau_joueur,
		'rang': len(liste_des_scores)+1,
		'score': 0,
		'score_txt': "0"
	}
	liste_des_scores.append(score.duplicate(true))
	_mettre_a_jour_les_rangs()
	return true

func lire_rang_joueur(nom_joueur : String) -> int:
	var joueur = _retourner_le_joueur(nom_joueur)
	if joueur:
		return joueur.get('rang')
	return 0

func lire_le_trophee_du_joueur(nom_joueur : String) -> String:
	"""Cette méthode retourne le trophé du joueur"""
	var rang = lire_rang_joueur(nom_joueur)
	return lire_le_trophee_du_rang(rang)

func lire_le_trophee_du_rang(rang : int) -> String:
	"""Cette méthode retourne le trophé du rang"""
	var trophees : Dictionary = {}
	if OS.has_feature("web"):
		# [WEB] Spécifier un caractere imprimable pour le WEB.
		trophees = {
			1: 'N°1', # 1er
			2: 'N°2', # 2eme
			3: 'N°3'  # 3eme
		}
		return trophees.get(rang, 'N°X') # = hors podium

	# Unicode : https://www.unicode.org/emoji/charts/emoji-list.html
	trophees = {
		1: String.chr(0x1F3C6), # 1er
		2: String.chr(0x1F948), # 2eme
		3: String.chr(0x1F949)  # 3eme
	}
	return trophees.get(rang, String.chr(0x25FD)) # = hors podium

func lire_score_joueur(nom_joueur : String) -> int:
	var joueur = _retourner_le_joueur(nom_joueur)
	if joueur:
		return joueur.get('score')
	return 0

func lire_score_txt_joueur(nom_joueur : String) -> String:
	var joueur = _retourner_le_joueur(nom_joueur)
	if joueur:
		return joueur.get('score_txt')
	return "0"

func modifier_score_joueur(nom_joueur : String, nouveau_score : int) -> void:
	var joueur = _retourner_le_joueur(nom_joueur)
	if joueur:
		joueur['score'] = nouveau_score
		joueur['score_txt'] = nombre_avec_separateur_de_milliers(nouveau_score, '.')
		_mettre_a_jour_les_rangs()

func incrementer_score_joueur(nom_joueur : String, increment_score : int) -> void:
	var joueur = _retourner_le_joueur(nom_joueur)
	if joueur:
		joueur['score'] += increment_score
		joueur['score_txt'] = nombre_avec_separateur_de_milliers(joueur.get('score'), '.')
		_mettre_a_jour_les_rangs()

func retourner_classement() -> Array:
	"""Retourner une liste de score avec :
		[
			{'rang': 1, 'score': 99999, 'score_txt': '99.999', 'nom': 'Joueur2'},
			{'rang': 2, 'score': 12345, 'score_txt': '12.345', 'nom': 'Joueur1'},
			{'rang': 2, 'score': 12345, 'score_txt': '12.345', 'nom': 'Joueur3'}
		]"""
	var classement = []
	for rang in range(1, len(liste_des_scores)+1):
		for joueur in liste_des_scores:
			if joueur.get('rang') == rang:
				classement.append(joueur.duplicate(true))
	return classement

func _mettre_a_jour_les_rangs() -> void:
	"""Cette méthode met à jour les rangs dans la liste des scores"""
	# Cartographier les scores et les joueurs
	var liste_score_decroissant = []
	var dico_score_nom_joueur = {}
	for joueur in liste_des_scores:
		var nom_joueur = joueur.get('nom')
		var score = int(joueur.get('score'))
		if score not in liste_score_decroissant:
			liste_score_decroissant.append(score)
		if score not in dico_score_nom_joueur:
			dico_score_nom_joueur[score] = [nom_joueur]
		else:
			# Score égalité
			dico_score_nom_joueur[score].append(nom_joueur)
	# Classer les scores par ordre decraoissant
	liste_score_decroissant.sort() # Classement croissant des scores
	liste_score_decroissant.reverse() # Classement decroissant des scores
	
	# Attribuer les rangs
	var rang : int = 1
	for score in liste_score_decroissant:
		for joueur in liste_des_scores:
			if joueur.get('score') == score:
				joueur['rang'] = rang
		rang += len(dico_score_nom_joueur[score])
	
	_enregistrer_la_liste_des_scores()

func nombre_avec_separateur_de_milliers(nombre : int, separateur : String) -> String:
	var nombre_texte = ''
	for division in [1_000_000_000, 1_000_000, 1_000, 1]:
		var dividende = roundi(nombre / division)
		if dividende or nombre_texte:
			# Dès que nombre_texte est peuplé, écrire les zéros.
			if nombre_texte:
				nombre_texte += separateur
				nombre_texte += str(dividende).pad_zeros(3)
			else :
				# Premiere partie du nombre : pas de séparateur entre milliers ou de remplissage de zero.
				nombre_texte += str(dividende)
			nombre -= dividende * division
	if not nombre_texte:
		nombre_texte = "0"
	return nombre_texte
