extends Node

class_name Plateau

signal plateau_invalide

var layout := PlateauLayoutService.new()
var decodeur := PlateauDecodeurService.new()
var regles := PlateauReglesDuJeuService.new()
var gameplay_est_termine: Callable
var bouton_abandonner_size_y: float

@export var pile_scene: PackedScene
var liste_piles = []
static var ESPACE = 32

var sauvegarde_indice_pile_depart : int = -1

# #############
# API Gameplay
func enregistrer_callback_est_termine(cb: Callable):
	gameplay_est_termine = cb

func commencer_un_nouveau_plateau(plateau_texte : String) -> void:
	_effacer_le_plateau()
	if est_valide(plateau_texte):
		var plateau = decodeur.decoder_plateau(plateau_texte)
		_creer_un_plateau(plateau)
	else:
		plateau_invalide.emit()

func hide():
	_effacer_le_plateau()

func _effacer_le_plateau() -> void:
	for pile in liste_piles:
		pile.effacer_la_pile()
		pile.queue_free()
	liste_piles.clear()

func est_valide(plateau_texte : String) -> bool:
	return decodeur.est_valide(plateau_texte)

func est_bloque() -> bool:
	return regles.est_bloque(liste_piles)

func enregistrer_bouton_abandonner_size_y(size_y : float) -> void:
	bouton_abandonner_size_y = size_y

# ########
# Usine >>
func _creer_un_plateau(piles : Array) -> void:
	for jetons_pile_courante in piles:
		# Créer une nouvelle instance de la scene 'Pile'.
		var pile = _instancier_une_pile()
		var indice_pile = len(liste_piles)-1
		_initialiser_une_pile(pile, jetons_pile_courante)
		var position_pile = _positionner_une_pile(len(piles), indice_pile)
		#LogService.log_debug("_creer_un_plateau : position_pile = ", position_pile)
		pile.choisir_position( position_pile )

func _instancier_une_pile() -> Pile:
	# Créer une nouvelle instance de la scene 'Pile'.
	var pile = pile_scene.instantiate()

	# Ajouter la nouvelle scene au plus tot pour que
	# le constructeur '_ready' ait fait ses actions préalables.
	add_child(pile)
	liste_piles.append(pile)
	
	# Fournir l'indice de la pile comme reference
	# Permet d'identifier de quelle pile provient un signal.
	var indice_pile = len(liste_piles)-1
	pile.choisir_reference(indice_pile)
	
	# Connexion au signal 'Pile.clique_gauche'
	pile.connect("clique_gauche", Callable(self, "on_pile_clique_gauche"))
	
	return pile

func _initialiser_une_pile(pile: Pile, jetons_pile_texte) -> void:
	# Initialiser la pile
	var valide = pile.ajouter_les_jetons(jetons_pile_texte)
	# Traiter le cas d'une pile invalide.
	if not valide:
		# la pile est invalide, le plateau aussi
		_effacer_le_plateau()
		plateau_invalide.emit()

func _positionner_une_pile(nb_piles_plateau: int, indice_pile: int) -> Vector2:
	# Definir la position de la pile sur le plateau
	# Constantes pour layout
	layout.taille_bouton_abandonner_originale = bouton_abandonner_size_y
	layout.taille_fenetre_jeu = get_viewport().get_visible_rect().size
	layout.taille_pile_pixels = Vector2(liste_piles[0].largeur(), liste_piles[0].hauteur())
	return layout.calculer_la_position_de_la_pile(nb_piles_plateau, indice_pile)
# Usine >>
# ########

func on_pile_clique_gauche(indice_pile : int) -> void:
	# LogService.log_debug("clique sur la pile : ", indice_pile)
	if not SauvegardeBddJoueursService.enregistrement_plateau_en_cours():
		# Ignorer les cliques sur les jetons quand il n'y a pas de partie ne cours
		return
	var pile_cible = liste_piles[indice_pile]
	if sauvegarde_indice_pile_depart == -1 \
		and regles.pile_de_depart_de_tansfert_valide(pile_cible):
		$SelectionPile.start()
		AudioService.son_jeton_deplacer_debut()
		sauvegarde_indice_pile_depart = indice_pile
		# Selecitonner la pile de depart
		pile_cible.selectionner()
		
		# Parcourir chaque pile pour voir si elle peut etre destination
		for pile_arrivee in range(len(liste_piles)):
			if pile_arrivee != indice_pile \
				and regles.est_valide_le_tansfert_de_pile(liste_piles, indice_pile, pile_arrivee):
				liste_piles[pile_arrivee].selectionner_deplacement_valide()
	else:
		$SelectionPile.stop()
		if regles.realiser_le_tansfert_de_pile(liste_piles, sauvegarde_indice_pile_depart, indice_pile):
			if pile_cible.est_termine():
				pile_cible.bloquer()
				VibrationService.vibration_fin_de_pile()
				AudioService.son_jeton_deplacer_pile_pleine()
			else:
				VibrationService.vibration_de_jeton()
				AudioService.son_jeton_deplacer_succes()
		else:
			# Echec !
			AudioService.son_jeton_deplacer_echec()
		_deselectionner_toutes_les_piles()

	# Vérifier si la partie est achevée (auprès du gameplay)
	if not gameplay_est_termine.is_valid():
		LogService.log_erreur("gameplay_est_termine() n'est pas enregistré !")
	elif gameplay_est_termine.call(liste_piles):
		VibrationService.vibration_fin_de_plateau()

func _deselectionner_toutes_les_piles() -> void:
	# Deselecitonner toutes les piles
	for pile in liste_piles:
			pile.deselectionner()
	# Annulation du coup en cours
	sauvegarde_indice_pile_depart = -1
	# LogService.log_debug("Annulation du coup en cours")

func _on_menu_plateau_deselection_pile() -> void:
	_on_selection_pile_timeout()

func _on_selection_pile_timeout() -> void:
	if liste_piles:
		# Pour vérifier qu'une partie est bien en cours.
		VibrationService.vibration_echec()
		AudioService.son_jeton_deplacer_echec()
		_deselectionner_toutes_les_piles()
