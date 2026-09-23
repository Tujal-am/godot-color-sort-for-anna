extends RefCounted
class_name PlateauReglesDuJeuService

func est_bloque(liste_piles : Array) -> bool:
	# Pour chaque pile, vérifier si un mouvement est possible
	for pile_depart in liste_piles:
		if not pile_de_depart_de_tansfert_valide(pile_depart):
			continue
		for pile_arrivee in liste_piles:
			var indice_pile_depart = pile_depart.obtenir_reference()
			var indice_pile_arrivee = pile_arrivee.obtenir_reference()
			if est_valide_le_tansfert_de_pile(liste_piles, indice_pile_depart, indice_pile_arrivee):
				return false
	return true

func pile_de_depart_de_tansfert_valide(pile_depart : Pile) -> bool:
	if pile_depart.est_vide():
		#LogService.log_debug("Pile de départ vide")
		return false
	if pile_depart.est_termine():
		#LogService.log_debug("Pile de départ terminée")
		return false
	return true

func est_valide_le_tansfert_de_pile(liste_piles : Array, indice_pile_depart : int, indice_pile_arrivee : int) -> bool:
	if indice_pile_depart == indice_pile_arrivee:
		#LogService.log_debug("Pile de départ et d'arrivée sont les mêmes")
		return false

	var pile_arrivee = liste_piles[indice_pile_arrivee]
	if pile_arrivee.est_pleine():
		#LogService.log_debug("Pile d'arrivée pleine")
		return false

	var pile_depart = liste_piles[indice_pile_depart]
	var indice_jeton_depart = pile_depart.quelle_est_la_couleur_au_sommet()
	var nb_jeton_depart = pile_depart.combien_de_jetons_identiques_au_sommet()

	if pile_arrivee.accepte_jeton(indice_jeton_depart, nb_jeton_depart):
		return true
	else:
		#LogService.log_debug("La pile d'arrivée refuse le(s) ", nb_jeton_depart, " jeton(s)")
		return false

func realiser_le_tansfert_de_pile(liste_piles : Array, indice_pile_depart : int, indice_pile_arrivee : int) -> bool:
	if est_valide_le_tansfert_de_pile(liste_piles, indice_pile_depart, indice_pile_arrivee):
		var pile_depart = liste_piles[indice_pile_depart]
		var pile_arrivee = liste_piles[indice_pile_arrivee]
		var indice_jeton_depart = pile_depart.quelle_est_la_couleur_au_sommet()
		var nb_jeton_depart = pile_depart.combien_de_jetons_identiques_au_sommet()

		for i in range(nb_jeton_depart):
			pile_depart.retirer_le_dernier_jeton()
			pile_arrivee.ajouter_le_jeton_dans_le_vide(indice_jeton_depart)
		# Enregistrer le coup
		SauvegardeBddJoueursService.coups_joues_ajouter_un_nouveau_coup(indice_pile_depart, indice_pile_arrivee)
		return true
	return false
