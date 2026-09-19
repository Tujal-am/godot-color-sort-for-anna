extends RefCounted
class_name FormatterMenuCampagne

# Infos joueur
###############
func formater_infos_joueur() -> String:
	var nom = SauvegardeBddJoueursService.lire_nom_joueur()
	var trophee = SauvegardeTableauDesScoresService.lire_le_trophee_du_joueur(nom)

	var niveau_courant : int = 0
	if SauvegardeBddJoueursService.enregistrement_niveau_existe():
		niveau_courant = SauvegardeBddJoueursService.enregistrement_lire_valeur_niveau_joueur()
	else:
		niveau_courant = SauvegardeBddJoueursService.lire_prochain_niveau_de_campagne()

	var pourcentage_niveau_realise = StatsService.niveau_taux_completion() * 100.
	var pourcentage_campagne_realise = StatsService.campagne_taux_completion() * 100.
	var score_texte = SauvegardeTableauDesScoresService.lire_score_txt_joueur(nom)
	
	var texte = "[center][font_size=30]"
	texte += nom + " " + trophee + " " + score_texte + "\n"
	texte += "[font_size=20]Niveau " + String.num_int64(niveau_courant) + " : " + String.num_int64(pourcentage_niveau_realise) + "%"
	texte += " - "
	texte += "Campagne : " + String.num_int64(pourcentage_campagne_realise) + "%[/font_size]"
	texte += "[/font_size][/center]"
	return texte
