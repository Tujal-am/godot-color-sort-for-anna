extends Node

class_name Plateau

signal victoire
signal plateau_invalide
signal abandon

var layout := PlateauLayoutService.new()
var decodeur := PlateauDecodeurService.new()
var regles := PlateauReglesDuJeuService.new()

@export var pile_scene: PackedScene
@export var theme_visuel_demande: StringName = Jeton.THEME_CLASSIQUE
var liste_piles = []
static var ESPACE = 32
var theme_visuel_effectif: StringName = Jeton.THEME_CLASSIQUE
var catalogue_variantes: Dictionary = Jeton.CATALOGUE_VARIANTES

var sauvegarde_indice_pile_depart : int = -1

func commencer_un_nouveau_plateau(plateau_texte : String) -> void:
	if decodeur.est_valide(plateau_texte):
		var plateau = decodeur.decoder_plateau(plateau_texte)
		theme_visuel_effectif = determiner_theme_visuel_effectif(
				theme_visuel_demande, plateau, catalogue_variantes)
		_creer_un_plateau(plateau)
	else:
		plateau_invalide.emit()

func effacer_le_plateau() -> void:
	for pile in liste_piles:
		pile.effacer_la_pile()
		pile.queue_free()
	liste_piles.clear()
	$BoutonAbandon.show()

func est_valide(plateau_texte : String) -> bool:
	return decodeur.est_valide(plateau_texte)

static func determiner_theme_visuel_effectif(theme_demande: StringName,
													piles: Array,
													catalogue: Dictionary) -> StringName:
	if theme_demande == Jeton.THEME_CLASSIQUE:
		return Jeton.THEME_CLASSIQUE
	var catalogue_theme: Dictionary = catalogue.get(theme_demande, {})
	var couleurs_utilisees: Array[int] = []
	for pile in piles:
		for indice_couleur in pile:
			if indice_couleur != ESPACE and indice_couleur not in couleurs_utilisees:
				couleurs_utilisees.append(indice_couleur)
	var couleurs_manquantes: Array[int] = []
	for indice_couleur in couleurs_utilisees:
		var variantes = catalogue_theme.get(indice_couleur, [])
		if not variantes is Array or variantes.is_empty():
			couleurs_manquantes.append(indice_couleur)
	if not couleurs_manquantes.is_empty():
		push_warning(("Thème visuel '%s' incomplet pour les couleurs %s : " \
				+ "le plateau entier reste classique.") % [theme_demande, couleurs_manquantes])
		return Jeton.THEME_CLASSIQUE
	return theme_demande


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
	for jeton in pile.liste_jetons:
		jeton.choisir_theme_visuel_effectif(theme_visuel_effectif)
	# Traiter le cas d'une pile invalide.
	if not valide:
		# la pile est invalide, le plateau aussi
		effacer_le_plateau()
		plateau_invalide.emit()

func _positionner_une_pile(nb_piles_plateau: int, indice_pile: int) -> Vector2:
	# Definir la position de la pile sur le plateau
	# Constantes pour layout
	layout.taille_bouton_abandonner_originale = $BoutonAbandon.size.y
	layout.taille_fenetre_jeu = get_viewport().get_visible_rect().size
	layout.taille_pile_pixels = Vector2(liste_piles[0].largeur(), liste_piles[0].hauteur())
	return layout.calculer_la_position_de_la_pile(nb_piles_plateau, indice_pile)
# Usine >>
# ########

func on_pile_clique_gauche(indice_pile : int) -> void:
	# LogService.log_debug("clique sur la pile : ", indice_pile)
	if not SauvegardeBddJoueursService.plateau_en_cours():
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
				# Vérifier si la partie est achevée
				if regles.est_termine(liste_piles):
					$BoutonAbandon.hide()
					victoire.emit()
					VibrationService.vibration_fin_de_plateau()
				else:
					VibrationService.vibration_fin_de_pile()
					AudioService.son_jeton_deplacer_pile_pleine()
			else:
				VibrationService.vibration_de_jeton()
				AudioService.son_jeton_deplacer_succes()
		else:
			AudioService.son_jeton_deplacer_echec()
		_on_selection_pile_timeout()

func _on_selection_pile_timeout() -> void:
	# Deselecitonner toutes les piles
	for pile in liste_piles:
			pile.deselectionner()
	# Annulation du coup en cours
	sauvegarde_indice_pile_depart = -1
	# LogService.log_debug("Annulation du coup en cours")

func _on_bouton_abandon_pressed() -> void:
	$BoutonAbandon.hide()
	abandon.emit()

func _on_fond_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# LogService.log_debug("Clique souris sur le fond du plateau")
			# Parcourir les piles et déselectionner la pile (comme "timeout" sur la selection)
			_on_selection_pile_timeout()
			
