extends Node

func mettre_a_jour_score_pour_victoire() -> Dictionary:
	"Calculer le score suite à une victoire (duree, ratio réussites, niveau, campagne)"
	var score_duree = mettre_a_jour_score_duree() 
	var score_ratio_reussite = mettre_a_jour_score_ratio_reussite()
	var score_niveau = mettre_a_jour_score_niveau()
	var score_niveau_sans_detour = mettre_a_jour_score_niveau_sans_detour()
	var score_campagne = mettre_a_jour_score_campagne()

	var score_global = {
					'duree': score_duree,
					'ratio_reussite': score_ratio_reussite,
					'niveau': score_niveau,
					'niveau_sans_detour': score_niveau_sans_detour,
					'campagne': score_campagne
					}

	bonus_score_anna_damour(score_global)
	return score_global

func mettre_a_jour_score_duree() -> Dictionary:
	"Calculer le score relatif au temps"
	var temps_reference_par_difficulte = {
		9 : 9.,
		10 : 12.,
		20 : 14.,
		30 : 16.,
		40 : 18.,
		50 : 20.,
		60 : 25.,
		71 : 30.,
		81 : 60.,
		100 : 120.
		}

	var difficulte = SauvegardeBddJoueursService.enregistrement_lire_difficulte_plateau()
	var temps_reference_en_s = temps_reference_par_difficulte[9]
	if difficulte <= 9:
		temps_reference_en_s = temps_reference_par_difficulte[9]
	elif difficulte <= 10:
		temps_reference_en_s = temps_reference_par_difficulte[10]
	elif difficulte <= 20:
		temps_reference_en_s = temps_reference_par_difficulte[20]
	elif difficulte <= 30:
		temps_reference_en_s = temps_reference_par_difficulte[30]
	elif difficulte <= 40:
		temps_reference_en_s = temps_reference_par_difficulte[40]
	elif difficulte <= 50:
		temps_reference_en_s = temps_reference_par_difficulte[50]
	elif difficulte <= 60:
		temps_reference_en_s = temps_reference_par_difficulte[60]
	elif difficulte <= 71:
		temps_reference_en_s = temps_reference_par_difficulte[71]
	elif difficulte <= 81:
		temps_reference_en_s = temps_reference_par_difficulte[81]
	elif difficulte <= 100:
		temps_reference_en_s = temps_reference_par_difficulte[100]
	else :
		LogService.log_erreur("Erreur : Difficulté inattendue pour le score !")

	var bonus_duree = 0
	var nom_joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var duree_en_s = SauvegardeBddJoueursService.enregistrement_lire_duree_plateau()
	# Score sur le ratio du temps référence/joué
	var ratio_temps = temps_reference_en_s / duree_en_s
	bonus_duree = roundi(100 * difficulte * ratio_temps)
	SauvegardeBddJoueursService.enregistrement_modifier_score_duree_plateau(bonus_duree)
	SauvegardeTableauDesScoresService.incrementer_score_joueur(nom_joueur, bonus_duree)
	return {'type':'duree', 'reference': temps_reference_en_s, 'realise': duree_en_s, 'points': bonus_duree}

func mettre_a_jour_score_ratio_reussite() -> Dictionary:
	"Calculer le score relatif au temps"
	var bonus_ratio_reussite = 0
	var nom_joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var niveau = SauvegardeBddJoueursService.enregistrement_lire_valeur_niveau_joueur()
	var int_ratio_reussite = SauvegardeBddJoueursService.enregistrment_lire_ratio_reussite_niveau()
	var ratio_reussite = SauvegardeBddJoueursService.enregistrment_lire_ratio_reussite_niveau() / 100.
	bonus_ratio_reussite = roundi(100 * niveau * ratio_reussite)
	SauvegardeBddJoueursService.enregistrement_modifier_score_ratio_reussite_plateau(bonus_ratio_reussite)
	SauvegardeTableauDesScoresService.incrementer_score_joueur(nom_joueur, bonus_ratio_reussite)
	return {'type':'ratio_reussite', 'ratio': int_ratio_reussite, 'points': bonus_ratio_reussite}

# TODO : Ceci est l'ancien score d'ascension, est-il encore utile ?
# TODO : S'il est identique pour tous, il ne présente pas d'interet.
func mettre_a_jour_score_niveau() -> Dictionary:
	"Calculer le score suite à un niveau achevé"
	var bonus_niveau = 0
	var niveau_longueur_totale = 0
	if not SauvegardeBddJoueursService.enregistrement_niveau_en_cours():
		var nom_joueur = SauvegardeBddJoueursService.lire_nom_joueur()
		niveau_longueur_totale = SauvegardeBddJoueursService.lire_longueur_niveau_courant()
		# bonus = 100 x Dénivelé ^2 (bonus non linéaire)
		bonus_niveau = roundi(50 * pow(niveau_longueur_totale, 2))
		SauvegardeBddJoueursService.enregistrement_modifier_score_niveau(bonus_niveau)
		SauvegardeTableauDesScoresService.incrementer_score_joueur(nom_joueur, bonus_niveau)
		return {'type':'niveau', 'longueur': niveau_longueur_totale, 'points': bonus_niveau}
	return{}

func mettre_a_jour_score_niveau_sans_detour() -> Dictionary:
	"Calculer le score suite à un niveau parfaitement achevé (sans détour)"
	var bonus_niveau_sans_detour = 0
	var lg_niveau = SauvegardeBddJoueursService.lire_longueur_niveau_courant()
	var succes = SauvegardeBddJoueursService.enregistrement_lire_niveau_longueur_realisee()
	if not SauvegardeBddJoueursService.enregistrement_niveau_en_cours() \
		and lg_niveau == succes:
		var nom_joueur = SauvegardeBddJoueursService.lire_nom_joueur()
		bonus_niveau_sans_detour = SauvegardeBddJoueursService.enregistrement_lire_score_niveau()
		SauvegardeBddJoueursService.enregistrement_modifier_score_niveau_sans_detour(bonus_niveau_sans_detour)
		SauvegardeTableauDesScoresService.incrementer_score_joueur(nom_joueur, bonus_niveau_sans_detour)
		return {'type':'niveau_sans_detour', 'bonus': 'x2', 'points': bonus_niveau_sans_detour}
	return{}

func mettre_a_jour_score_campagne() -> Dictionary:
	"Calculer le score suite à la campagne achevée"
	var bonus_campagne = 0
	if SauvegardeBddJoueursService.campagne_la_campagne_est_terminee():
		var nom_joueur = SauvegardeBddJoueursService.lire_nom_joueur()
		bonus_campagne = 2_000_000
		SauvegardeTableauDesScoresService.incrementer_score_joueur(nom_joueur, bonus_campagne)
		return {'type':'campagne', 'points': bonus_campagne}
	return {}

func bonus_score_anna_damour(score_global : Dictionary) -> void:
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

func nouveau_joueur_est_nom_anna_triche(nom : String) -> bool:
	return nom.to_lower() == 'Anna'.to_lower()

func lire_nom_anna_triche() -> String:
	var nom_anna_triche = String.chr(0x1F5A4) + 'Anna' + String.chr(0x1F9E1)
	if OS.has_feature("web"):
		nom_anna_triche = '*Anna*'
	return nom_anna_triche
