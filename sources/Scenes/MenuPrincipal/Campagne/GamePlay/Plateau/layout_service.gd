extends RefCounted
class_name PlateauLayoutService

var taille_bouton_abandonner_originale = 0.
var taille_fenetre_jeu = 0.
var taille_pile_pixels = Vector2()

func calculer_la_position_de_la_pile(nb_piles : int, indice_pile : int) -> Vector2:
	# en haut à gauche (0,0)
	# en bas à droite (infini, infini)
	var taille_bouton_abandonner = taille_bouton_abandonner_originale * 0.5
	# TODO : Facteur 0,5 ajouté par bricolage, car la hauteur de la pile ne semble pas être
	#        ... exactement celle retournée par liste_piles[0].hauteur()
	#        ... ou sinon, son affichage est décallé
	var taille_plateau = convertir_nb_piles_en_taille_plateau(nb_piles)
	var coordonnees_pile = convertir_indice_pile_coordonnees(nb_piles, indice_pile)
	var position_pile = Vector2()
	if taille_plateau.y == 1:
		# 1 ligne de piles : 'y' constant
		position_pile.y = taille_bouton_abandonner + (taille_fenetre_jeu.y - taille_bouton_abandonner) / 2 + taille_pile_pixels.y / 2
		var nb_ecarts_x = nb_piles + 1
		var vide_x = (taille_fenetre_jeu.x - (nb_piles * taille_pile_pixels.x)) / nb_ecarts_x
		var ecart_x = vide_x + taille_pile_pixels.x
		var taille_plateau_totale_x = nb_piles * taille_pile_pixels.x + (nb_piles - 1) * vide_x
		position_pile.x = taille_fenetre_jeu.x / 2 - taille_plateau_totale_x / 2 + ecart_x * (indice_pile)
	else:
		# N lignes de piles
		var nb_ecarts = Vector2i(taille_plateau.x + 1, taille_plateau.y + 1)
		var vide = Vector2( (taille_fenetre_jeu.x - (taille_plateau.x * taille_pile_pixels.x)) / nb_ecarts.x,
							 (taille_fenetre_jeu.y - taille_bouton_abandonner - (taille_plateau.y * taille_pile_pixels.y)) / nb_ecarts.y)
		var ecart = Vector2( vide.x + taille_pile_pixels.x,
							 vide.y + taille_pile_pixels.y)
		var taille_plateau_totale = Vector2( taille_plateau.x * taille_pile_pixels.x + (taille_plateau.x - 1) * vide.x,
												taille_plateau.y * taille_pile_pixels.y + (taille_plateau.y - 1) * vide.y)
		position_pile = Vector2( taille_fenetre_jeu.x / 2 - taille_plateau_totale.x / 2 + ecart.x * (coordonnees_pile.x),
									taille_bouton_abandonner + (taille_fenetre_jeu.y - taille_bouton_abandonner) / 2 + taille_plateau_totale.y / 2 - ecart.y * (coordonnees_pile.y) )
	return position_pile

func convertir_indice_pile_coordonnees(nb_piles : int, indice_pile : int) -> Vector2i:
	var coordonnees = Vector2i(0,0)
	var nb_pile_par_ligne = convertir_nb_piles_en_taille_plateau(nb_piles).x
	if nb_pile_par_ligne != 0:
		coordonnees.y = floori(1. * indice_pile / nb_pile_par_ligne) # Division entiere
		coordonnees.x = indice_pile - coordonnees.y * nb_pile_par_ligne # Reste de la division entiere
	return coordonnees

func convertir_nb_piles_en_taille_plateau(nb_piles : int) -> Vector2i:
	var taille_plateau = Vector2i(0,0)
	if nb_piles:
		# 13 piles max par ligne, mais rendu surchargé
		# 6 piles par ligne = rendu agréable. Correspond à un écart d'une pile vide entre chaque pile.
		taille_plateau.y = ceili(nb_piles / 6.) # Nombre de ligne necessaires
		taille_plateau.x = roundi(1. * nb_piles / taille_plateau.y) # Nombre de pile par ligne
	return taille_plateau
