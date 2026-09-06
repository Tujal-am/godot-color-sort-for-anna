extends Node

class_name Pile

signal clique_gauche(reference_parent)

@export var jeton_scene: PackedScene
var liste_jetons = []
var reference_parent

var position = Vector2(0, 720)
var marge = 4

var couleur_de_deselection = Color("580058")
var couleur_de_deplacement_valide = Color("d800d8")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func choisir_reference(reference : int) -> void:
	reference_parent = reference

func obtenir_reference() -> int:
	return reference_parent

func ajouter_les_jetons(jetons : Array) -> bool:
	# Vérifier la validité de la pile
	if not est_valide(jetons):
		return false # pile invalide
	
	for jeton_courant in jetons:
		# Créer une nouvelle instance de la scene 'Jeton'.
		var jeton = jeton_scene.instantiate()

		# Ajouter la nouvelle scene au plus tot pour que
		# le constructeur '_ready' ait fait ses actions préalables.
		add_child(jeton)
		liste_jetons.append(jeton) 

		# Fournir l'indice du jeton comme reference
		# Permet d'identifier de quel jeton provient un signal.
		var indice_jeton = len(liste_jetons)-1
		jeton.choisir_reference(indice_jeton)
		
		# Connexion au signal 'Jeton.clique_gauche'
		jeton.connect("clique_gauche", Callable(self, "on_jeton_clique_gauche"))
		
		# Definir la position du jeton dans la pile
		var position_jeton = _calculer_la_position_du_jeton(indice_jeton)
		jeton.choisir_position( position_jeton )

		# Definir le type du jeton
		jeton.choisir_jeton(jeton_courant, true)
		
		# Si le jeton est vide, le mettre en arriere plan devant '$Fond'(=0)
		if jeton.est_vide():
			move_child(jeton, 1)

	# Réaliser les soudures
	mettre_a_jour_les_soudures()
	
	# Definir la taille du fond de pile
	var size = Vector2(largeur(), hauteur() )
	$Fond.set_size(size)
	
	# Definir la position du fond de pile
	_ajuster_position_fond()
	return true # pile valide

func ajouter_le_jeton_dans_le_vide(jeton_a_ajouter : int) -> bool:
	var ajoute = false
	if accepte_jeton(jeton_a_ajouter, 1):
		for jeton_courant in liste_jetons:
			if jeton_courant.est_vide():
				jeton_courant.choisir_jeton(jeton_a_ajouter, false)
				# Le jeton est mis au premier plan
				move_child(jeton_courant, -1)
				# TODO : Attention, le jeton 'J' posera un probleme !
				# TODO : 'J' avant = jeton petit
				# TODO : 'J' apres = ok
				ajoute = true
				break
		mettre_a_jour_les_soudures()
	return ajoute

func retirer_le_dernier_jeton() -> bool:
	var retire = false
	var liste_inversee = liste_jetons.duplicate(true)
	liste_inversee.reverse()
	for jeton_courant in liste_inversee:
		if not jeton_courant.est_vide():
			jeton_courant.choisir_jeton(Plateau.ESPACE, false)
			# Le jeton est vide, le mettre en arriere plan devant '$Fond'(=0)
			move_child(jeton_courant, 1)
			# TODO : Attention, le jeton 'J' posera un probleme !
			# TODO : 'J' avant = jeton petit
			# TODO : 'J' apres = ok
			retire = true
			break
	mettre_a_jour_les_soudures()
	return retire

func mettre_a_jour_les_soudures():
	dessouder_les_jetons()
	souder_les_jetons()

func souder_les_jetons():
	"Soude les jetons de même couleur"
	if not est_vide():
		# Pourcourir les N-1 jetons et les souder 2 à 2 avec leur suivant
		var nb_jetons = len(liste_jetons)
		# Parcour les jetons du bas vers le haut
		for indice_jeton in range(nb_jetons - 1):
			if not liste_jetons[indice_jeton].est_vide():
				var jeton = liste_jetons[indice_jeton]
				var jeton_au_dessus = liste_jetons[indice_jeton+1]
				if jeton.indice_jeton == jeton_au_dessus.indice_jeton:
					jeton.souder_en_haut()
					jeton_au_dessus.souder_en_bas()

func dessouder_les_jetons():
	"Dessoude sans conditions"
	if not est_vide():
		for jeton in liste_jetons:
			jeton.dessouder()

func choisir_position(nouvelle_position : Vector2) -> void:
	position = nouvelle_position
	var indice_jeton = 0
	# Changer la position de tous les jetons
	for jeton_courant in liste_jetons:
		var position_jeton = _calculer_la_position_du_jeton(indice_jeton)
		# LogService.log_debug("Pile.choisir_position : position_jeton = ", position_jeton)
		jeton_courant.choisir_position( position_jeton )
		indice_jeton += 1
	_ajuster_position_fond()

func _ajuster_position_fond() -> void:
	if liste_jetons:
		# Position du dernier jeton + Centrage de la pile
		$Fond.set_position(liste_jetons[-1].position() - Vector2(marge, marge))
		# LogService.log_debug("Pile.choisir_position $Fond.get_position()", $Fond.get_position())

func selectionner() -> void:
	selectionner_les_jetons_identiques_au_sommet()

func deselectionner() -> void:
	if not est_termine():
		# Deselection du déplacement valide
		$Fond.color = couleur_de_deselection
		# Deselection des jetons
		for jeton_courant in liste_jetons:
			jeton_courant.deselectionner()

func selectionner_les_jetons_identiques_au_sommet():
	var jeton_sommet = null
	if not est_vide() and not est_termine():
		var liste_inversee = liste_jetons.duplicate(true)
		liste_inversee.reverse()
		# Parcourt les jetons du plus haut au plus bas
		for jeton in liste_inversee:
			if jeton_sommet == null and jeton.indice_jeton == Plateau.ESPACE :
				continue # Ignorer les cases vides au sommet
			elif jeton_sommet == null and jeton.indice_jeton != Plateau.ESPACE :
				# Enregistrer le premier jeton rencontré
				jeton_sommet = jeton.indice_jeton
				# Selectionne le jeton du sommet
				jeton.selectionner()
			elif jeton_sommet != null and jeton.indice_jeton == jeton_sommet:
				# Selectionne le jeton identique
				jeton.selectionner()
			else:
				break # Arret du comptage pour un jeton différent

func selectionner_deplacement_valide() -> void:
	$Fond.color = couleur_de_deplacement_valide

func bloquer() -> void:
	if liste_jetons:
		$Fond.color = liste_jetons[0].couleur_selection()

func largeur() -> int:
	if liste_jetons:
		return liste_jetons[0].largeur() + 2 * marge
	return 0

func hauteur() -> int:
	if liste_jetons:
		return (liste_jetons[0].hauteur() + 2) * len(liste_jetons) + 2 * marge
	return 0

func effacer_la_pile() -> void:
	for jeton in liste_jetons:
		jeton.queue_free()
	position = Vector2(0, 720)
	liste_jetons.clear()

static func est_valide(jetons : Array) -> bool:
	var vide = false
	# Les cases vides sont en haut de la pile
	for jeton_courant in jetons:
		if not vide and jeton_courant == Plateau.ESPACE:
			vide = true
		elif vide and jeton_courant != Plateau.ESPACE:
			return false
	return true


# Methodes pour cadrer les mouvements de jetons
func est_vide() -> bool:
	return liste_jetons.is_empty() \
		or liste_jetons.front().indice_jeton == Plateau.ESPACE

func est_pleine() -> bool:
	return liste_jetons.is_empty() \
		or liste_jetons.back().indice_jeton != Plateau.ESPACE

func est_termine() -> bool:
	# Terminée = pleine monocouleur
	if not est_pleine():
		return false
	# Tous les jetons sont identiques
	var jeton_precedent = null
	for jeton in liste_jetons:
		if jeton_precedent != null and jeton.indice_jeton != jeton_precedent:
			return false
		jeton_precedent = jeton.indice_jeton
	return true

func quelle_est_la_couleur_au_sommet() -> int:
	if not est_vide():
		var liste_inversee = liste_jetons.duplicate(true)
		liste_inversee.reverse()
		for jeton in liste_inversee:
			if jeton.indice_jeton != Plateau.ESPACE:
				return jeton.indice_jeton
	return Plateau.ESPACE
	
func combien_de_jetons_identiques_au_sommet() -> int:
	var nb_identique_sommet = 0
	var jeton_sommet = null
	if not est_vide() and not est_termine():
		var liste_inversee = liste_jetons.duplicate(true)
		liste_inversee.reverse()
		for jeton in liste_inversee:
			if jeton_sommet == null and jeton.indice_jeton == Plateau.ESPACE :
				continue # Ignorer les cases vides au sommet
			elif jeton_sommet == null and jeton.indice_jeton != Plateau.ESPACE :
				# Enregistrer le premier jeton rencontré
				jeton_sommet = jeton.indice_jeton
				nb_identique_sommet += 1
			elif jeton_sommet != null and jeton.indice_jeton == jeton_sommet:
				# Comptabiliser les jetons identiques
				nb_identique_sommet += 1
			else:
				break # Arret du comptage pour un jeton différent
	return nb_identique_sommet

func combien_de_cases_vides_au_sommet() -> int:
	var vide_sommet = 0
	if not est_pleine():
		var liste_inversee = liste_jetons.duplicate(true)
		liste_inversee.reverse()
		for jeton in liste_inversee:
			if jeton.indice_jeton == Plateau.ESPACE:
				vide_sommet += 1
			else:
				break
	return vide_sommet

func accepte_jeton(indice : int, nombre : int) -> bool:
	return (est_vide() or indice == quelle_est_la_couleur_au_sommet()) \
		and nombre <= combien_de_cases_vides_au_sommet()

func _calculer_la_position_du_jeton(indice_jeton : int) -> Vector2:
	var position_jeton = position
	# Inversion sur Y pour commencer à la base de la pile
	position_jeton.y = position.y - indice_jeton * (liste_jetons[indice_jeton].hauteur() + 2)
	return position_jeton

func on_jeton_clique_gauche(_indice_jeton : int) -> void:
	# LogService.log_debug("clique sur le jeton : ", _indice_jeton)
	# Ne pas selectionner une pile terminee
	if not est_termine():
		clique_gauche.emit(reference_parent)

func _on_fond_gui_input(event: InputEvent) -> void:
	# Pour elargir la zone de clique
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			on_jeton_clique_gauche(0)
