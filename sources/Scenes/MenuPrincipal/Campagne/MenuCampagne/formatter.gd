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


# MessageRiche
##############

func formater_detail_score(detail_score : Dictionary) -> Dictionary:
	# Afficher le détail du score.
	var bbcode_complet = ''
	var score_total = 0
	var position_y = 100
	var size_y = 350

	# Entete
	bbcode_complet += """[color=#ff98fd][font_size=20][center][b]Bravo ![/b][/center][/font_size]"""
	bbcode_complet += """[font_size=30][center][b]Score[/b][/center][/font_size]"""

	# 'duree'
	var bbcode_duree = """[left][font_size=20][b]Temps[/b] :
[ul] Référence: #duree_ref#s[/ul]
[ul] Réalisé: #duree_real#s[/ul]
[ul] #duree_pts# points[/ul]"""
	bbcode_duree = bbcode_duree.replace('#duree_ref#', str(detail_score.get('duree').get('reference')))
	bbcode_duree = bbcode_duree.replace('#duree_real#', str( snapped(detail_score.get('duree').get('realise'), 0.1) ))
	var points_txt = SauvegardeTableauDesScoresService.nombre_avec_separateur_de_milliers(detail_score.get('duree').get('points'), '.')
	bbcode_duree = bbcode_duree.replace('#duree_pts#', points_txt)
	bbcode_complet += bbcode_duree
	score_total += detail_score.get('duree').get('points')

	# ratio_reussite
	var bbcode_ratio_reussite = """[b]Ratio Réussite[/b]
[ul] Réalisé: #ratio_real#%[/ul]
[ul] #ratio_pts# points[/ul]"""
	bbcode_ratio_reussite = bbcode_ratio_reussite.replace('#ratio_real#', str(detail_score.get('ratio_reussite').get('ratio')))
	points_txt = SauvegardeTableauDesScoresService.nombre_avec_separateur_de_milliers(detail_score.get('ratio_reussite').get('points'), '.')
	bbcode_ratio_reussite = bbcode_ratio_reussite.replace('#ratio_pts#', points_txt)
	bbcode_complet += bbcode_ratio_reussite
	score_total += detail_score.get('ratio_reussite').get('points')

	# niveau
	if detail_score.get('niveau'):
		var bbcode_niveau = """[b]Niveau[/b]
[ul] Longueur: #asc_long# plateaux[/ul]
[ul] #asc_pts# points[/ul]"""
		bbcode_niveau = bbcode_niveau.replace('#asc_long#', str(detail_score.get('niveau').get('longueur')))
		points_txt = SauvegardeTableauDesScoresService.nombre_avec_separateur_de_milliers(detail_score.get('niveau').get('points'), '.')
		bbcode_niveau = bbcode_niveau.replace('#asc_pts#', points_txt)
		bbcode_complet += bbcode_niveau
		score_total += detail_score.get('niveau').get('points')
		size_y += 80

	# niveau_sans_detour
	if detail_score.get('niveau_sans_detour'):
		var bbcode_niveau_sans_detour = """[b]Niveau sans détour[/b]
[ul] Bonus: #asc_detour_bonus#[/ul]
[ul] #asc_detour_pts# points[/ul]"""
		bbcode_niveau_sans_detour = bbcode_niveau_sans_detour.replace('#asc_detour_bonus#', str(detail_score.get('niveau_sans_detour').get('bonus')))
		points_txt = SauvegardeTableauDesScoresService.nombre_avec_separateur_de_milliers(detail_score.get('niveau_sans_detour').get('points'), '.')
		bbcode_niveau_sans_detour = bbcode_niveau_sans_detour.replace('#asc_detour_pts#', points_txt)
		bbcode_complet += bbcode_niveau_sans_detour
		score_total += detail_score.get('niveau_sans_detour').get('points')
		size_y += 80

	# campagne
	if  detail_score.get('campagne'):
		var bbcode_campagne = """[b]Campagne[/b]
[ul] #campag_pts# points[/ul]"""
		points_txt = SauvegardeTableauDesScoresService.nombre_avec_separateur_de_milliers(detail_score.get('campagne').get('points'), '.')
		bbcode_campagne = bbcode_campagne.replace('#campag_pts#', points_txt)
		bbcode_complet += bbcode_campagne
		score_total += detail_score.get('campagne').get('points')
		size_y += 60

	# total
	var bbcode_total = """[/font_size][/left][font_size=30][center][b]Total : #total_pts#[/b][/center][/font_size][/color]"""
	points_txt = SauvegardeTableauDesScoresService.nombre_avec_separateur_de_milliers(score_total, '.')
	bbcode_total = bbcode_total.replace('#total_pts#', points_txt)
	bbcode_complet += bbcode_total

	# Afficher le score
	return {'bbcode':bbcode_complet, 'position_y':position_y, 'size_y':size_y}

func formater_message_simple(message : String) -> Dictionary:
	# Afficher le détail du score.
	var bbcode_complet = ''
	var position_y = 300
	# 90 = marge haut+bas
	# 13 = nb caractees par ligne
	var size_y = 90 + 40 * roundi(len(message)/13.)

	var bbcode_header = """[color=#ff98fd][font_size=30][center][b]"""
	var bbcode_tail = """[/b][/center][/font_size][/color]"""

	bbcode_complet += bbcode_header + message + bbcode_tail
	return {'bbcode':bbcode_complet, 'position_y':position_y, 'size_y':size_y}
