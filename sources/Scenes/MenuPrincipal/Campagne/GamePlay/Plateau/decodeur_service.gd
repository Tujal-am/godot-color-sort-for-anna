extends RefCounted
class_name PlateauDecodeurService

var string2int = {}

func _init() -> void:
	_initialiser_table_conversion()

func est_valide(plateau_texte : String) -> bool:
	# Invalide : Plateau vide
	if plateau_texte.is_empty():
		return false
	if plateau_texte.replacen(' ','').replacen('.','').is_empty():
		return false
	# Vérifier si chaque pile est valide
	var taille_pile = 0
	for pile in decoder_plateau(plateau_texte):
		taille_pile = max(taille_pile, len(pile))
		if not Pile.est_valide(pile):
			return false

	var nb_jetons = plateau_texte.count(plateau_texte[0])
	# Invalide : Nombre de jetons != taille pile
	if nb_jetons != taille_pile:
		return false
	# Invalide : Nombre de jetons inégaux
	for lettre in plateau_texte:
		if lettre == '.':
			continue
		if plateau_texte.count(lettre) != nb_jetons:
			return false

	return true

func decoder_plateau(plateau_texte : String) -> Array:
	plateau_texte = plateau_texte.to_upper()
	#LogService.log_debug("decoder_plateau : ", plateau_texte)
	var plateau_liste = []
	#plateau_texte = plateau_texte.replace(' ','')
	for pile in plateau_texte.split('.'):
		plateau_liste.append(decoder_pile(pile))
	#LogService.log_debug("  decoder_plateau : ", plateau_texte, " => ", plateau_liste)
	#LogService.log_debug("decoder_plateau : fin")
	return plateau_liste

func decoder_pile(pile_texte : String) -> Array:
	var pile_liste = []
	for c in pile_texte:
		pile_liste.append(string2int[c])
	#LogService.log_debug("  decoder_pile : ", pile_texte, " => ", pile_liste)
	return pile_liste

func _initialiser_table_conversion() -> void:
	if string2int:
		return
	for i in range(26):
		string2int[String.chr(65+i)] = i
	string2int[String.chr(Plateau.ESPACE)] = Plateau.ESPACE # chr(ESPACE)=' '
