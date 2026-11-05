extends Node

const FIN_CAMPAGNE := 500_000

func mettre_a_jour_score_pour_victoire() -> Dictionary:
	"Calculer le score suite à une victoire (duree, ratio réussites, niveau, campagne)"
	var score_duree = mettre_a_jour_score_duree() 
	var score_ratio_reussite = mettre_a_jour_score_ratio_reussite()
	var score_niveau = mettre_a_jour_score_niveau()
	var score_niveau_parfait = mettre_a_jour_score_niveau_parfait()
	var score_campagne = mettre_a_jour_score_campagne()

	var score_global = {
					'duree': score_duree,
					'ratio_reussite': score_ratio_reussite,
					'niveau': score_niveau,
					'niveau_parfait': score_niveau_parfait,
					'campagne': score_campagne
					}

	var bonus_anna = bonus_score_anna_damour(score_global)
	if bonus_anna:
		score_global['bonus_anna'] = bonus_anna
	return score_global

func mettre_a_jour_score_pour_import_campagne(nom_joueur: String, campagne: Dictionary) -> void:
	"Ajoute au score du joueur les points de la campagne importée."
	var score_fin_campagne = SauvegardeBddJoueursService.enregistrement_campagne_lire_score_fin_campagne(campagne)
	SauvegardeTableauDesScoresService.incrementer_score_joueur(nom_joueur, score_fin_campagne)
	var niveaux: Variant = campagne.get("niveaux", [])
	if not niveaux is Array:
		return
	for niveau in niveaux:
		if not niveau is Dictionary:
			continue
		var score_niveau = SauvegardeBddJoueursService.enregistrement_campagne_lire_score_niveau(niveau)
		SauvegardeTableauDesScoresService.incrementer_score_joueur(nom_joueur, score_niveau)
		var score_niveau_parfait = SauvegardeBddJoueursService.enregistrement_campagne_lire_score_niveau_parfait(niveau)
		SauvegardeTableauDesScoresService.incrementer_score_joueur(nom_joueur, score_niveau_parfait)
		var plateaux: Variant = niveau.get('plateaux', [])
		if not plateaux is Array:
			continue
		for plateau in plateaux:
			if not plateau is Dictionary:
				continue
			var score_duree_plateau = SauvegardeBddJoueursService.enregistrement_campagne_lire_score_duree_plateau(plateau)
			SauvegardeTableauDesScoresService.incrementer_score_joueur(nom_joueur, score_duree_plateau)
			var score_ratio_reussite_plateau = SauvegardeBddJoueursService.enregistrement_campagne_lire_score_ratio_reussite_plateau(plateau)
			SauvegardeTableauDesScoresService.incrementer_score_joueur(nom_joueur, score_ratio_reussite_plateau)

func mettre_a_jour_score_pour_passer() -> Dictionary:
	"Calculer et enregistrer le score suite au passage d'un plateau"
	var score_global = mettre_a_jour_score_pour_victoire()
	# Les scores locaux du plateaux sont forcés à zéro
	SauvegardeBddJoueursService.enregistrement_campagne_modifier_score_duree_plateau(0)
	SauvegardeBddJoueursService.enregistrement_campagne_modifier_score_ratio_reussite_plateau(0)
	var nom_joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	SauvegardeTableauDesScoresService.incrementer_score_joueur(nom_joueur, -score_global['duree']['points'])
	SauvegardeTableauDesScoresService.incrementer_score_joueur(nom_joueur, -score_global['ratio_reussite']['points'])
	score_global['duree']['points'] = 0
	score_global['duree']['recommence'] = 0
	score_global['duree']['realise'] = 0
	score_global['ratio_reussite']['ratio'] = 0
	score_global['ratio_reussite']['points'] = 0

	if 'bonus_anna' in score_global:
		SauvegardeTableauDesScoresService.incrementer_score_joueur(nom_joueur, -score_global['bonus_anna']['points'])
		score_global.erase('bonus_anna')
		var bonus_anna = bonus_score_anna_damour(score_global)
		score_global['bonus_anna'] = bonus_anna
	return score_global

func mettre_a_jour_score_duree() -> Dictionary:
	"Calculer le score relatif au temps"
	var difficulte = SauvegardeBddJoueursService.enregistrement_campagne_lire_difficulte_plateau()
	var gameplay = SauvegardeBddJoueursService.enregistrement_campagne_lire_gameplay_plateau()
	var temps_reference_en_s = 0.
	if gameplay == "classique":
		temps_reference_en_s = _classique_temps_reference_par_difficulte(difficulte)
	elif gameplay == "qui_perd_gagne":
		temps_reference_en_s = _qui_perd_gagne_temps_reference_par_difficulte(difficulte)
	else:
		LogService.log_erreur("Erreur : Gameplay inattendu pour le score !")

	var bonus_duree = 0
	var nom_joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var duree_recommence_en_s = SauvegardeBddJoueursService.enregistrement_campagne_lire_duree_plateau_recommence()
	var duree_realise_en_s = SauvegardeBddJoueursService.enregistrement_campagne_lire_duree_plateau()
	var duree_totale_en_s = duree_recommence_en_s + duree_realise_en_s
	# Score sur le ratio du temps référence/joué
	var ratio_temps = 0.
	if duree_totale_en_s:
		ratio_temps = temps_reference_en_s / duree_totale_en_s
	bonus_duree = roundi(100 * difficulte * ratio_temps)
	SauvegardeBddJoueursService.enregistrement_campagne_modifier_score_duree_plateau(bonus_duree)
	SauvegardeTableauDesScoresService.incrementer_score_joueur(nom_joueur, bonus_duree)
	return {'type':'duree',
			'reference': temps_reference_en_s,
			'recommence': duree_recommence_en_s,
			'realise': duree_realise_en_s,
			'points': bonus_duree}

func _classique_temps_reference_par_difficulte(difficulte: int) -> int:
	var temps_reference_par_difficulte = {
		9 : 23.5,
		23 : 32.1,
		34 : 35.,
		40 : 35.,
		50 : 43.,
		59 : 54.7,
		72 : 274.,
		78 : 102.,
		90 : 114.8,
		95 : 120.5,
		100 : 120.5
		}
	return _temps_reference_par_difficulte(difficulte, temps_reference_par_difficulte)

func _qui_perd_gagne_temps_reference_par_difficulte(difficulte: int) -> int:
	var temps_reference_par_difficulte = {
		20 : 28.7,
		29 : 28.7,
		42 : 32.9,
		52 : 32.9,
		60 : 32.9,
		71 : 41.4,
		79 : 75.,
		88 : 75.,
		95 : 75.,
		100 : 75.
		}
	return _temps_reference_par_difficulte(difficulte, temps_reference_par_difficulte)

func _temps_reference_par_difficulte(difficulte: int, temps_reference_par_difficulte: Dictionary) -> int:
	var temps_reference_en_s = 0.
	var liste_ref_difficulte_croissant = temps_reference_par_difficulte.keys()
	liste_ref_difficulte_croissant.sort()
	for ref_difficulte in liste_ref_difficulte_croissant:
		if difficulte <= ref_difficulte:
			temps_reference_en_s = temps_reference_par_difficulte[ref_difficulte]
		else:
			break
	if temps_reference_en_s == 0.:
		LogService.log_erreur("Erreur : Difficulté inattendue pour le score !")
	return temps_reference_en_s

func mettre_a_jour_score_ratio_reussite() -> Dictionary:
	"Calculer le score relatif au temps"
	var bonus_ratio_reussite = 0
	var nom_joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var niveau = SauvegardeBddJoueursService.enregistrement_campagne_lire_valeur_niveau_joueur()
	var int_ratio_reussite = SauvegardeBddJoueursService.enregistrement_campagne_lire_ratio_reussite_niveau()
	var ratio_reussite = SauvegardeBddJoueursService.enregistrement_campagne_lire_ratio_reussite_niveau() / 100.
	bonus_ratio_reussite = roundi(500 * niveau * ratio_reussite)
	SauvegardeBddJoueursService.enregistrement_campagne_modifier_score_ratio_reussite_plateau(bonus_ratio_reussite)
	SauvegardeTableauDesScoresService.incrementer_score_joueur(nom_joueur, bonus_ratio_reussite)
	return {'type':'ratio_reussite',
			'ratio': int_ratio_reussite,
			'points': bonus_ratio_reussite}

# TODO : Ceci est l'ancien score d'ascension, est-il encore utile ?
# TODO : S'il est identique pour tous, il ne présente pas d'interet.
func mettre_a_jour_score_niveau() -> Dictionary:
	"Calculer le score suite à un niveau achevé"
	var bonus_niveau = 0
	var niveau_longueur_totale = 0
	if not SauvegardeBddJoueursService.enregistrement_campagne_niveau_en_cours():
		var nom_joueur = SauvegardeBddJoueursService.lire_nom_joueur()
		niveau_longueur_totale = SauvegardeBddJoueursService.lire_longueur_niveau_courant()
		# bonus = 500 x longueur du niveau
		bonus_niveau = roundi(500 * niveau_longueur_totale)
		SauvegardeBddJoueursService.enregistrement_campagne_modifier_score_niveau(bonus_niveau)
		SauvegardeTableauDesScoresService.incrementer_score_joueur(nom_joueur, bonus_niveau)
		return {'type':'niveau',
				'longueur': niveau_longueur_totale,
				'points': bonus_niveau}
	return{}

func mettre_a_jour_score_niveau_parfait() -> Dictionary:
	"Calculer le score suite à un niveau parfaitement achevé (sans détour)"
	var bonus_niveau_parfait = 0
	if not SauvegardeBddJoueursService.enregistrement_campagne_niveau_en_cours() \
		and SauvegardeBddJoueursService.enregistrement_campagne_lire_ratio_reussite_niveau() == 100:
		var nom_joueur = SauvegardeBddJoueursService.lire_nom_joueur()
		bonus_niveau_parfait = SauvegardeBddJoueursService.enregistrement_campagne_lire_score_dernier_niveau()
		SauvegardeBddJoueursService.enregistrement_campagne_modifier_score_niveau_parfait(bonus_niveau_parfait)
		SauvegardeTableauDesScoresService.incrementer_score_joueur(nom_joueur, bonus_niveau_parfait)
		return {'type':'niveau_parfait',
				'bonus': 'x2',
				'points': bonus_niveau_parfait}
	return{}

func mettre_a_jour_score_campagne() -> Dictionary:
	"Calculer le score suite à la campagne achevée"
	var bonus_campagne = 0
	if SauvegardeBddJoueursService.campagne_la_campagne_est_terminee():
		var nom_joueur = SauvegardeBddJoueursService.lire_nom_joueur()
		var ratio_reussite = StatsService.campagne_taux_reussite()
		var ratio_plateaux_realises = StatsService.plateau_taux_de_realisation()
		bonus_campagne = roundi(FIN_CAMPAGNE * ratio_reussite * ratio_plateaux_realises)
		SauvegardeBddJoueursService.enregistrement_campagne_modifier_score_fin_campagne(bonus_campagne)
		SauvegardeTableauDesScoresService.incrementer_score_joueur(nom_joueur, bonus_campagne)
		return {'type':'campagne',
				'points': bonus_campagne}
	return {}

func bonus_score_anna_damour(score_global : Dictionary) -> Dictionary:
	"Bonus spécifique pour Anna d'Amour, la déesse de ce jeu."
	var nom_joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var nom_anna_triche = lire_nom_anna_triche()
	if nom_joueur.to_lower() == nom_anna_triche.to_lower():
		var score_total = 0
		for score in score_global.values():
			score_total += score.get('points', 0)
		var bonus_anna = score_total * 3
		LogService.log_debug("Bonus ", nom_anna_triche, " d'Amour !")
		SauvegardeTableauDesScoresService.incrementer_score_joueur(nom_joueur, bonus_anna)
		return {'type':'bonus_anna', 'points': bonus_anna}
	return {}

func nouveau_joueur_est_nom_anna_triche(nom : String) -> bool:
	return nom.to_lower() == 'Anna'.to_lower()

func lire_nom_anna_triche() -> String:
	var nom_anna_triche = String.chr(0x1F5A4) + 'Anna' + String.chr(0x1F9E1)
	if OS.has_feature("web"):
		nom_anna_triche = '*Anna*'
	return nom_anna_triche
