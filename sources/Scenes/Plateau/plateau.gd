extends Node

class_name Plateau

const FNV1A_OFFSET_BASIS_32: int = 2166136261
const FNV1A_PRIME_32: int = 16777619
const ANIMATION_TRANSFERT_BLOC = preload(
		"res://Scenes/Plateau/animation_transfert_bloc.gd")

signal victoire
signal plateau_invalide
signal abandon

var layout := PlateauLayoutService.new()
var decodeur := PlateauDecodeurService.new()
var regles := PlateauReglesDuJeuService.new()

@export var pile_scene: PackedScene
@export var theme_visuel_demande: StringName = Jeton.THEME_CLASSIQUE
@export var couleur_fond_plateau := Color(0.34363, 8.53118e-05, 0.346463, 1)
@export var couleur_fond_pile := Color("580058")
@export var couleur_case_vide := Color("DARK_MAGENTA")
@export var animation_transfert_active := false
var liste_piles = []
static var ESPACE = 32
var theme_visuel_effectif: StringName = Jeton.THEME_CLASSIQUE
var catalogue_variantes: Dictionary = Jeton.CATALOGUE_VARIANTES
var plateau_canonique_initial: String = ""

var sauvegarde_indice_pile_depart : int = -1
var animation_transfert_en_cours := false
var animateur_transfert = ANIMATION_TRANSFERT_BLOC.new()
var tween_transfert: Tween

func _ready() -> void:
	$Fond.color = couleur_fond_plateau

func commencer_un_nouveau_plateau(plateau_texte : String) -> void:
	if decodeur.est_valide(plateau_texte):
		plateau_canonique_initial = plateau_texte.to_upper()
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

static func determiner_id_variante_visuelle(theme_effectif: StringName,
														plateau_canonique: String,
														indice_couleur: int,
														indice_pile_initiale: int,
														indice_case_initiale: int,
														catalogue: Dictionary) -> StringName:
	if theme_effectif == Jeton.THEME_CLASSIQUE:
		return &""
	var variantes: Array = catalogue.get(theme_effectif, {}).get(indice_couleur, [])
	if variantes.is_empty():
		return &""
	var graine := composer_graine_variante(theme_effectif,
			plateau_canonique,
			indice_couleur,
			indice_pile_initiale,
			indice_case_initiale)
	return variantes[fnv1a_32(graine) % variantes.size()]

static func composer_graine_variante(theme_effectif: StringName,
											plateau_canonique: String,
											indice_couleur: int,
											indice_pile_initiale: int,
											indice_case_initiale: int) -> String:
	return "%s|%s|%d|%d|%d" % [
		str(theme_effectif),
		plateau_canonique,
		indice_couleur,
		indice_pile_initiale,
		indice_case_initiale,
	]

static func fnv1a_32(texte: String) -> int:
	var resultat: int = FNV1A_OFFSET_BASIS_32
	for octet in texte.to_utf8_buffer():
		resultat = ((resultat ^ octet) * FNV1A_PRIME_32) & 0xffffffff
	return resultat


# ########
# Usine >>
func _creer_un_plateau(piles : Array) -> void:
	for jetons_pile_courante in piles:
		# Créer une nouvelle instance de la scene 'Pile'.
		var pile = _instancier_une_pile()
		var indice_pile = len(liste_piles)-1
		_initialiser_une_pile(pile, jetons_pile_courante, indice_pile)
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
	pile.couleur_de_deselection = couleur_fond_pile
	pile.get_node("Fond").color = couleur_fond_pile
	
	# Fournir l'indice de la pile comme reference
	# Permet d'identifier de quelle pile provient un signal.
	var indice_pile = len(liste_piles)-1
	pile.choisir_reference(indice_pile)
	
	# Connexion au signal 'Pile.clique_gauche'
	pile.connect("clique_gauche", Callable(self, "on_pile_clique_gauche"))
	
	return pile

func _initialiser_une_pile(pile: Pile,
									jetons_pile_texte: Array,
									indice_pile_initiale: int) -> void:
	# Initialiser la pile
	var valide = pile.ajouter_les_jetons(jetons_pile_texte)
	for indice_case_initiale in range(pile.liste_jetons.size()):
		var jeton = pile.liste_jetons[indice_case_initiale]
		jeton.choisir_theme_visuel_effectif(theme_visuel_effectif)
		jeton.choisir_id_variante_visuelle(determiner_id_variante_visuelle(
				theme_visuel_effectif,
				plateau_canonique_initial,
				jetons_pile_texte[indice_case_initiale],
				indice_pile_initiale,
				indice_case_initiale,
				catalogue_variantes))
	_appliquer_couleur_cases_vides(pile)
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
	if animation_transfert_en_cours:
		return
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
		var pile_depart = liste_piles[sauvegarde_indice_pile_depart]
		var capture_animation := {}
		if animation_transfert_active \
			and regles.est_valide_le_tansfert_de_pile(
					liste_piles, sauvegarde_indice_pile_depart, indice_pile):
			capture_animation = animateur_transfert.capturer_transfert(
					pile_depart, pile_cible)
		if regles.realiser_le_tansfert_de_pile(liste_piles, sauvegarde_indice_pile_depart, indice_pile):
			_appliquer_couleur_cases_vides(pile_depart)
			_appliquer_couleur_cases_vides(pile_cible)
			if animation_transfert_active:
				_demarrer_animation_transfert(pile_cible, capture_animation)
				return
			_traiter_consequences_transfert_reussi(pile_cible)
		else:
			AudioService.son_jeton_deplacer_echec()
		_on_selection_pile_timeout()

func _demarrer_animation_transfert(pile_arrivee: Pile, capture: Dictionary) -> void:
	animation_transfert_en_cours = true
	for pile in liste_piles:
		pile.deselectionner()
	for jeton in animateur_transfert.jetons_arrives(pile_arrivee, capture):
		jeton.selectionner()
	tween_transfert = animateur_transfert.animer(self, pile_arrivee, capture)
	if tween_transfert == null:
		_terminer_animation_transfert(pile_arrivee)
	else:
		animateur_transfert.animation_terminee.connect(
				func() -> void: _terminer_animation_transfert(pile_arrivee),
				CONNECT_ONE_SHOT)

func _terminer_animation_transfert(pile_arrivee: Pile) -> void:
	animation_transfert_en_cours = false
	if not is_instance_valid(pile_arrivee):
		return
	for jeton in pile_arrivee.liste_jetons:
		jeton.deselectionner()
	_on_selection_pile_timeout()
	_traiter_consequences_transfert_reussi(pile_arrivee)

func _traiter_consequences_transfert_reussi(pile_cible: Pile) -> void:
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

func _appliquer_couleur_cases_vides(pile: Pile) -> void:
	for jeton in pile.liste_jetons:
		if jeton.est_vide():
			jeton.get_node("Carre").color = couleur_case_vide

func _on_selection_pile_timeout() -> void:
	# Deselecitonner toutes les piles
	for pile in liste_piles:
			pile.deselectionner()
	# Annulation du coup en cours
	sauvegarde_indice_pile_depart = -1
	# LogService.log_debug("Annulation du coup en cours")

func _on_bouton_abandon_pressed() -> void:
	if animation_transfert_en_cours:
		return
	$BoutonAbandon.hide()
	abandon.emit()

func _on_fond_gui_input(event: InputEvent) -> void:
	if animation_transfert_en_cours:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# LogService.log_debug("Clique souris sur le fond du plateau")
			# Parcourir les piles et déselectionner la pile (comme "timeout" sur la selection)
			_on_selection_pile_timeout()
			
