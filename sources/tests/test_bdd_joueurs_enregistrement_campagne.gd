extends GutTest

var singleton
var _liste_joueurs_initiale = []

const RACINE_TEST = "tests/test_bdd_joueurs_enregistrement_campagne"
const FICHIER = "joueur_campagne.json"
const NOM = "Joueur Campagne"

# ---------------------------------------------------------
# OUTILS
# ---------------------------------------------------------

func _nettoyer_fichiers_utilisateur():
	FichiersJsonService.effacer_racine_utilisateur()

func _entree(nom: String, difficulte: int = 1, gameplay: String = "CLASSIQUE") -> Dictionary:
	return {"nom": nom, "difficulte": difficulte, "gameplay": gameplay}

func _plateau(nom: String, statut: String = "reussi", debut: float = 100.0, fin: float = 110.0,
		difficulte: int = 1, gameplay: String = "CLASSIQUE", score: Dictionary = {}) -> Dictionary:
	return {
		"nom": nom,
		"gameplay": gameplay,
		"date_debut": debut,
		"date_fin": fin,
		"duree": (fin - debut) if fin else 0.0,
		"difficulte": difficulte,
		"statut": statut,
		"score": score,
		"coups joués": []
	}

func _plateau_en_cours(nom: String, debut: float = 200.0, difficulte: int = 2) -> Dictionary:
	return _plateau(nom, "en cours", debut, 0.0, difficulte)

func _niveau(nom: String, plateaux: Array = [], debut: float = 0.0, fin: float = 0.0,
		score: Dictionary = {}) -> Dictionary:
	return {"niveau": nom, "date_debut": debut, "date_fin": fin, "score": score, "plateaux": plateaux}

func _campagne_enreg(nom: String, niveaux: Array = [], debut: float = 1000.0, fin: float = 0.0,
		score: Dictionary = {}) -> Dictionary:
	return {"campagne": nom, "date_debut": debut, "date_fin": fin, "score": score, "niveaux": niveaux}

func _charger(enregistrements: Array = [], campagne: Dictionary = {}, extra: Dictionary = {}) -> void:
	var sauvegarde = {
		"nom": NOM,
		"nom_campagne": "campagne_a",
		"campagne": campagne,
		"nombre_de_parties": {},
		"enregistrement_campagne": enregistrements,
		"plateaux_libres": {}
	}
	sauvegarde.merge(extra, true)
	FichiersJsonService.write_json_file(FICHIER, sauvegarde)
	assert_true(singleton.choisir_le_joueur(NOM, FICHIER))

func _relire() -> Dictionary:
	return FichiersJsonService.read_json_file(FICHIER)

func _derniere_campagne_relue() -> Dictionary:
	return _relire()["enregistrement_campagne"].back()

# Niveau 1 terminé (2 réussis), niveau 2 en cours (réussi, abandonné, en cours)
func _charger_campagne_en_cours() -> void:
	var niveau_1 = _niveau("niveau_1", [
		_plateau("A1", "reussi", 1010.0, 1020.0, 1),
		_plateau("A2", "reussi", 1030.0, 1040.0, 1)
	], 1000.0, 1100.0, {"niveau": 300, "niveau_parfait": 400})
	var niveau_2 = _niveau("niveau_2", [
		_plateau("B1", "reussi", 1110.0, 1120.0, 2),
		_plateau("B2", "abandonné", 1130.0, 1140.0, 2),
		_plateau_en_cours("B3", 1150.0, 2)
	], 1100.0, 0.0)
	_charger([_campagne_enreg("campagne_a", [niveau_1, niveau_2])], {
		"niveau_2": [_entree("B3", 2, "MEMOIRE"), _entree("B4", 2)],
		"niveau_3": [_entree("C1", 3, "DEFI_DU_BOSS")]
	}, {"nombre_de_parties": {"2": 3, "1": 7}})

func _charger_niveau_avec_plateaux(plateaux: Array) -> void:
	_charger([_campagne_enreg("campagne_a", [_niveau("niveau_1", plateaux, 1000.0)])], {})

func _charger_plateau_en_cours(debut: float = 200.0) -> void:
	_charger_niveau_avec_plateaux([_plateau_en_cours("P1", debut)])

func before_all():
	FichiersJsonService.definir_racine_utilisateur(RACINE_TEST)
	_nettoyer_fichiers_utilisateur()

func before_each():
	_nettoyer_fichiers_utilisateur()
	_liste_joueurs_initiale = SauvegardeListeJoueursService.liste_des_joueurs.duplicate(true)
	SauvegardeListeJoueursService.liste_des_joueurs = []
	singleton = add_child_autofree(load("res://Singletons/Sauvegarde/bdd_joueurs_service.gd").new())
	await get_tree().process_frame

func after_each():
	SauvegardeListeJoueursService.liste_des_joueurs = _liste_joueurs_initiale
	_nettoyer_fichiers_utilisateur()

func after_all():
	_nettoyer_fichiers_utilisateur()


# ---------------------------------------------------------
# SAUVEGARDE / JOUEUR
# ---------------------------------------------------------

func test_lire_sauvegarde_retourne_vide_sans_joueur_puis_la_sauvegarde_du_joueur():
	singleton.liberer_le_joueur()
	assert_eq(singleton.lire_sauvegarde(), {})
	_charger()
	assert_eq(singleton.lire_sauvegarde().get("nom"), NOM)
	assert_eq(singleton.lire_sauvegarde().get("nom_campagne"), "campagne_a")

func test_liberer_le_joueur_masque_toutes_les_donnees_sans_toucher_au_fichier():
	_charger_campagne_en_cours()
	singleton.liberer_le_joueur()

	assert_false(singleton.le_joueur_existe())
	assert_eq(singleton.lire_sauvegarde(), {})
	assert_eq(singleton.lire_nom_joueur(), "")
	assert_eq(singleton.campagne_lire_nom(), "")
	assert_eq(singleton.campagne_nombre_niveaux(), 0)
	assert_false(singleton.enregistrement_campagne_existe())
	assert_true(FichiersJsonService.json_file_exists(FICHIER))
	assert_eq(_relire()["enregistrement_campagne"].size(), 1)

func test_liberer_le_joueur_empeche_toute_ecriture_dans_son_fichier():
	_charger_campagne_en_cours()
	singleton.liberer_le_joueur()
	singleton.campagne_supprimer_les_plateaux()
	singleton.enregistrement_campagne_terminer_campagne()
	assert_eq(_relire()["campagne"].size(), 2)

func test_un_joueur_absent_retourne_des_valeurs_par_defaut_partout():
	singleton.liberer_le_joueur()
	assert_false(singleton.le_joueur_existe())
	assert_eq(singleton.campagne(), {})
	assert_eq(singleton.campagne_lire_noms_niveaux(), [])
	assert_eq(singleton.campagne_lire_liste_plateaux_du_niveau(1), [])
	assert_eq(singleton.campagne_nombre_plateaux_pour_le_niveau(1), 0)
	assert_eq(singleton.campagne_lire_premier_plateau(1), {})
	assert_eq(singleton.campagne_lire_prochain_plateau_pour_niveau_courant(), {})
	assert_eq(singleton.campagne_lire_nombre_de_plateaux_realisables_pour_niveau_courant(), 0)
	assert_eq(singleton.lire_nombre_de_parties_pour_difficulte_courante(), 0)
	assert_eq(singleton.lire_nombre_de_parties_difficulte(1), 0)
	assert_false(singleton.campagne_supprimer_et_memoriser_plateau_courant())
	assert_false(singleton.campagne_supprimer_et_oublier_plateau_courant())
	assert_eq(singleton.enregistrement_campagne(), [])
	assert_false(singleton.enregistrement_campagne_existe())
	assert_eq(singleton.enregistrement_campagne_lire_campagne("campagne_a"), {})
	assert_eq(singleton.enregistrement_campagne_lire_derniere_campagne(), {})
	assert_eq(singleton.enregistrement_campagne_lire_nom_derniere_campagne(), "")
	assert_false(singleton.enregistrement_campagne_modifier_nom_derniere_campagne("x"))
	assert_false(singleton.enregistrement_campagne_en_cours())
	assert_eq(singleton.enregistrement_campagne_lire_score_derniere_fin_campagne(), 0)
	assert_false(singleton.enregistrement_campagne_niveau_existe())
	assert_eq(singleton.enregistrement_campagne_lire_derniers_niveaux(), [])
	assert_eq(singleton.enregistrement_campagne_lire_dernier_niveau(), {})
	assert_eq(singleton.enregistrement_campagne_lire_nom_dernier_niveau(), "")
	assert_false(singleton.enregistrement_campagne_niveau_en_cours())
	assert_eq(singleton.enregistrement_campagne_lire_niveau_joueur(), "")
	assert_eq(singleton.enregistrement_campagne_lire_valeur_niveau_joueur(), 0)
	assert_eq(singleton.enregistrement_campagne_lire_niveau_longueur_realisee(), 0)
	assert_eq(singleton.enregistrement_campagne_lire_ratio_reussite_niveau(), 0)
	assert_eq(singleton.enregistrement_campagne_lire_score_dernier_niveau(), 0)
	assert_false(singleton.enregistrement_campagne_plateau_existe())
	assert_false(singleton.enregistrement_campagne_plateau_en_cours())
	assert_eq(singleton.enregistrement_campagne_lire_nombre_plateaux_acheves(), 0)
	assert_eq(singleton.enregistrement_campagne_lire_dernier_plateau(), {})
	assert_eq(singleton.enregistrement_campagne_lire_nom_plateau(), "")
	assert_eq(singleton.enregistrement_campagne_lire_gameplay_plateau(), "")
	assert_eq(singleton.enregistrement_campagne_lire_duree_plateau(), 0.0)
	assert_eq(singleton.enregistrement_campagne_lire_difficulte_plateau(), 0)
	assert_eq(singleton.enregistrement_campagne_coups_joues(), [])
	assert_false(singleton.enregistrement_campagne_coups_joues_existe())
	assert_eq(singleton.enregistrement_campagne_lire_nombre_coups(), 0)

func test_les_modificateurs_sans_joueur_ne_plantent_pas_et_ne_creent_aucun_fichier():
	singleton.liberer_le_joueur()
	singleton.campagne_supprimer_les_plateaux()
	singleton.enregistrement_campagne_terminer_campagne()
	singleton.enregistrement_campagne_terminer_niveau()
	singleton.enregistrement_campagne_terminer_plateau()
	singleton.enregistrement_campagne_modifier_score_fin_campagne(10)
	singleton.enregistrement_campagne_modifier_score_niveau(10)
	singleton.enregistrement_campagne_modifier_score_niveau_parfait(10)
	singleton.enregistrement_campagne_modifier_statut_plateau("reussi")
	singleton.enregistrement_campagne_modifier_score_duree_plateau(10)
	singleton.enregistrement_campagne_modifier_score_ratio_reussite_plateau(10)
	assert_false(singleton.enregistrement_campagne_coups_joues_ajouter_un_nouveau_coup(0, 1))
	assert_false(FichiersJsonService.json_file_exists(FICHIER))


# ---------------------------------------------------------
# CAMPAGNE (plateaux restant à jouer)
# ---------------------------------------------------------

func test_campagne_lire_nom():
	_charger()
	assert_eq(singleton.campagne_lire_nom(), "campagne_a")

func test_campagne_lire_nom_absent_retourne_vide():
	_charger([], {}, {"nom_campagne": null})
	var sauvegarde = singleton.lire_sauvegarde()
	sauvegarde.erase("nom_campagne")
	assert_eq(singleton.campagne_lire_nom(), "")

func test_campagne_lire_noms_niveaux_et_nombre_de_niveaux():
	_charger([], {"niveau_1": [_entree("A")], "niveau_4": [_entree("B")], "niveau_2": []})
	assert_eq(singleton.campagne_nombre_niveaux(), 3)
	var noms = singleton.campagne_lire_noms_niveaux()
	noms.sort()
	assert_eq(noms, ["niveau_1", "niveau_2", "niveau_4"])
	assert_eq(singleton.campagne_lire_nombre_de_niveaux_realisables(), 3)

func test_campagne_niveau_existe_ignore_les_niveaux_vides_et_inconnus():
	_charger([], {"niveau_1": [_entree("A")], "niveau_2": []})
	assert_true(singleton.campagne_niveau_existe(1))
	assert_false(singleton.campagne_niveau_existe(2))
	assert_false(singleton.campagne_niveau_existe(3))
	assert_false(singleton.campagne_niveau_existe(0))
	assert_false(singleton.campagne_le_niveau_est_termine(1))
	assert_true(singleton.campagne_le_niveau_est_termine(2))
	assert_true(singleton.campagne_le_niveau_est_termine(3))

func test_campagne_lire_liste_plateaux_du_niveau_et_nombre():
	_charger([], {"niveau_1": [_entree("A"), _entree("B")], "niveau_2": []})
	var liste = singleton.campagne_lire_liste_plateaux_du_niveau(1)
	assert_eq(liste.size(), 2)
	assert_eq(liste[0].get("nom"), "A")
	assert_eq(singleton.campagne_nombre_plateaux_pour_le_niveau(1), 2)
	assert_eq(singleton.campagne_lire_liste_plateaux_du_niveau(2), [])
	assert_eq(singleton.campagne_nombre_plateaux_pour_le_niveau(2), 0)
	assert_eq(singleton.campagne_nombre_plateaux_pour_le_niveau(99), 0)

func test_campagne_lire_premier_plateau():
	_charger([], {"niveau_1": [_entree("A"), _entree("B")], "niveau_2": []})
	assert_eq(singleton.campagne_lire_premier_plateau(1).get("nom"), "A")
	assert_eq(singleton.campagne_lire_premier_plateau(2), {})
	assert_eq(singleton.campagne_lire_premier_plateau(7), {})

func test_campagne_lire_prochain_niveau_compare_les_valeurs_numeriques():
	_charger([], {"niveau_10": [_entree("A")], "niveau_2": [_entree("B")], "niveau_3": []})
	assert_eq(singleton.campagne_lire_prochain_niveau(), 2)

func test_campagne_lire_prochain_niveau_sans_niveau_retourne_zero():
	_charger([], {"niveau_1": []})
	assert_eq(singleton.campagne_lire_prochain_niveau(), 0)

func test_campagne_lire_prochain_gameplay():
	_charger([], {"niveau_2": [_entree("B", 2, "MEMOIRE")], "niveau_1": [_entree("A", 1, "DICO")]})
	assert_eq(singleton.campagne_lire_prochain_gameplay(), "DICO")

func test_campagne_lire_prochain_gameplay_campagne_vide():
	_charger([], {})
	assert_eq(singleton.campagne_lire_prochain_gameplay(), "aucun_gameplay")

func test_campagne_lire_prochain_plateau_pour_niveau_courant():
	_charger_campagne_en_cours()
	var plateau = singleton.campagne_lire_prochain_plateau_pour_niveau_courant()
	assert_eq(plateau.get("nom"), "B3")
	assert_eq(plateau.get("gameplay"), "MEMOIRE")

func test_campagne_lire_prochain_plateau_pour_niveau_courant_sans_enregistrement():
	_charger([], {"niveau_1": [_entree("A")]})
	assert_eq(singleton.campagne_lire_prochain_plateau_pour_niveau_courant(), {})

func test_campagne_lire_nombre_de_plateaux_realisables_pour_niveau_courant():
	_charger_campagne_en_cours()
	assert_eq(singleton.campagne_lire_nombre_de_plateaux_realisables_pour_niveau_courant(), 2)

func test_campagne_lire_nombre_de_plateaux_realisables_sans_niveau_courant():
	_charger([], {"niveau_1": [_entree("A")]})
	assert_eq(singleton.campagne_lire_nombre_de_plateaux_realisables_pour_niveau_courant(), 0)

func test_campagne_la_campagne_est_terminee_selon_les_niveaux_restants():
	_charger([], {"niveau_1": [_entree("A")]})
	assert_false(singleton.campagne_la_campagne_est_terminee())
	singleton.campagne_supprimer_les_plateaux()
	assert_true(singleton.campagne_la_campagne_est_terminee())

func test_campagne_supprimer_les_plateaux_vide_la_campagne_et_persiste():
	_charger_campagne_en_cours()
	singleton.campagne_supprimer_les_plateaux()
	assert_eq(singleton.campagne_nombre_niveaux(), 0)
	assert_eq(_relire()["campagne"], {})
	assert_eq(_relire()["enregistrement_campagne"].size(), 1)

func test_campagne_supprimer_et_memoriser_deplace_le_plateau_dans_les_plateaux_libres():
	_charger_campagne_en_cours()
	assert_true(singleton.campagne_supprimer_et_memoriser_plateau_courant())

	assert_eq(singleton.campagne_nombre_plateaux_pour_le_niveau(2), 1)
	assert_eq(singleton.campagne_lire_premier_plateau(2).get("nom"), "B4")
	assert_true(singleton.plateaux_libres_difficulte_existe(2))
	var libres = singleton.plateaux_libres_lire_liste_plateaux_de_difficulte(2)
	assert_eq(libres.size(), 1)
	assert_eq(libres[0].get("nom"), "B3")
	var relu = _relire()
	assert_eq(relu["campagne"]["niveau_2"].size(), 1)
	assert_eq(relu["plateaux_libres"]["2"][0]["nom"], "B3")

func test_campagne_supprimer_et_memoriser_efface_le_niveau_epuise_et_cumule_les_libres():
	_charger_campagne_en_cours()
	assert_true(singleton.campagne_supprimer_et_memoriser_plateau_courant())
	assert_true(singleton.campagne_supprimer_et_memoriser_plateau_courant())

	assert_false(singleton.campagne_niveau_existe(2))
	assert_false("niveau_2" in singleton.campagne())
	assert_eq(singleton.campagne_nombre_niveaux(), 1)
	var libres = singleton.plateaux_libres_lire_liste_plateaux_de_difficulte(2)
	assert_eq([libres[0].get("nom"), libres[1].get("nom")], ["B3", "B4"])
	assert_false("niveau_2" in _relire()["campagne"])

func test_campagne_supprimer_et_memoriser_refuse_un_plateau_deja_termine():
	_charger_niveau_avec_plateaux([_plateau("P1", "reussi")])
	singleton.lire_sauvegarde()["campagne"]["niveau_1"] = [_entree("P1")]
	assert_false(singleton.campagne_supprimer_et_memoriser_plateau_courant())
	assert_eq(singleton.campagne_nombre_plateaux_pour_le_niveau(1), 1)
	assert_false(singleton.plateaux_libres_difficulte_existe(1))

func test_campagne_supprimer_et_memoriser_sans_plateau_courant_ne_plante_pas_et_retourne_false():
	_charger([], {"niveau_1": [_entree("A")]})
	var resultat = singleton.campagne_supprimer_et_memoriser_plateau_courant()
	assert_false(resultat)
	assert_eq(singleton.campagne_nombre_plateaux_pour_le_niveau(1), 1)

func test_campagne_supprimer_et_oublier_retire_le_plateau_sans_le_memoriser():
	_charger_campagne_en_cours()
	assert_true(singleton.campagne_supprimer_et_oublier_plateau_courant())

	assert_eq(singleton.campagne_nombre_plateaux_pour_le_niveau(2), 1)
	assert_eq(singleton.campagne_lire_premier_plateau(2).get("nom"), "B4")
	assert_false(singleton.plateaux_libres_difficulte_existe(2))
	assert_eq(_relire()["campagne"]["niveau_2"].size(), 1)

func test_campagne_supprimer_et_oublier_efface_le_niveau_epuise():
	_charger_campagne_en_cours()
	assert_true(singleton.campagne_supprimer_et_oublier_plateau_courant())
	assert_true(singleton.campagne_supprimer_et_oublier_plateau_courant())
	assert_false("niveau_2" in singleton.campagne())
	assert_eq(singleton.campagne_lire_nombre_de_niveaux_realisables(), 1)
	assert_false("niveau_2" in _relire()["campagne"])

func test_campagne_supprimer_et_oublier_refuse_un_plateau_deja_termine():
	_charger_niveau_avec_plateaux([_plateau("P1", "abandonné")])
	singleton.lire_sauvegarde()["campagne"]["niveau_1"] = [_entree("P1")]
	assert_false(singleton.campagne_supprimer_et_oublier_plateau_courant())
	assert_eq(singleton.campagne_nombre_plateaux_pour_le_niveau(1), 1)

func test_campagne_supprimer_et_oublier_sans_plateau_courant_retourne_false():
	_charger([], {"niveau_1": [_entree("A")]})
	assert_false(singleton.campagne_supprimer_et_oublier_plateau_courant())
	assert_eq(singleton.campagne_nombre_plateaux_pour_le_niveau(1), 1)


# ---------------------------------------------------------
# NOMBRE DE PARTIES
# ---------------------------------------------------------

func test_lire_nombre_de_parties_pour_difficulte_courante():
	_charger_campagne_en_cours()
	assert_eq(singleton.lire_nombre_de_parties_pour_difficulte_courante(), 3)

func test_lire_nombre_de_parties_pour_difficulte_courante_sans_compteur():
	_charger_campagne_en_cours()
	singleton.lire_sauvegarde()["nombre_de_parties"].clear()
	assert_eq(singleton.lire_nombre_de_parties_pour_difficulte_courante(), 0)

func test_lire_nombre_de_parties_pour_difficulte_courante_sans_prochain_plateau():
	_charger([_campagne_enreg("campagne_a", [_niveau("niveau_1", [], 1000.0)])], {},
		{"nombre_de_parties": {"1": 5}})
	assert_eq(singleton.lire_nombre_de_parties_pour_difficulte_courante(), 0)

func test_lire_nombre_de_parties_difficulte_inconnue():
	_charger_campagne_en_cours()
	assert_eq(singleton.lire_nombre_de_parties_difficulte(1), 7)
	assert_eq(singleton.lire_nombre_de_parties_difficulte(5), 0)


# ---------------------------------------------------------
# ORCHESTRATION : PASSER UN PLATEAU / SIGNAUX
# ---------------------------------------------------------

func test_passer_un_plateau_retire_le_plateau_et_le_marque_passe_sans_compteur():
	_charger_campagne_en_cours()
	singleton.passer_un_plateau()

	assert_eq(singleton.enregistrement_campagne_lire_statut_dernier_plateau(), "passé")
	assert_false(singleton.enregistrement_campagne_plateau_en_cours())
	assert_gt(singleton.enregistrement_campagne_lire_dernier_plateau().get("date_fin"), 1150.0)
	assert_eq(singleton.campagne_lire_premier_plateau(2).get("nom"), "B4")
	assert_false(singleton.plateaux_libres_difficulte_existe(2))
	assert_eq(singleton.lire_nombre_de_parties_difficulte(2), 3)
	var plateau = _derniere_campagne_relue()["niveaux"][1]["plateaux"][2]
	assert_eq(plateau["statut"], "passé")

func test_passer_un_plateau_sans_plateau_en_cours_ne_modifie_pas_la_campagne():
	_charger_niveau_avec_plateaux([_plateau("P1", "reussi")])
	singleton.lire_sauvegarde()["campagne"]["niveau_1"] = [_entree("P1"), _entree("P2")]
	singleton.passer_un_plateau()
	assert_eq(singleton.campagne_nombre_plateaux_pour_le_niveau(1), 2)
	assert_eq(singleton.enregistrement_campagne_lire_statut_dernier_plateau(), "passé")

func test_les_signaux_de_progression_sont_connectes_aux_gestionnaires():
	assert_true(ProgressionCampagneService.fin_niveau.is_connected(singleton._on_progression_campagne_service_fin_niveau))
	assert_true(ProgressionCampagneService.fin_campagne.is_connected(singleton._on_progression_campagne_service_fin_campagne))

func test_on_fin_niveau_termine_le_niveau_courant():
	_charger_campagne_en_cours()
	assert_true(singleton.enregistrement_campagne_niveau_en_cours())
	singleton._on_progression_campagne_service_fin_niveau()
	assert_false(singleton.enregistrement_campagne_niveau_en_cours())
	assert_gt(_derniere_campagne_relue()["niveaux"][1]["date_fin"], 0.0)

func test_on_fin_campagne_termine_la_campagne_courante():
	_charger_campagne_en_cours()
	assert_true(singleton.enregistrement_campagne_en_cours())
	singleton._on_progression_campagne_service_fin_campagne()
	assert_false(singleton.enregistrement_campagne_en_cours())
	assert_gt(_derniere_campagne_relue()["date_fin"], 0.0)


# ---------------------------------------------------------
# ENREGISTREMENT CAMPAGNE : CAMPAGNES
# ---------------------------------------------------------

func test_enregistrement_campagne_existe_et_liste():
	_charger()
	assert_false(singleton.enregistrement_campagne_existe())
	assert_eq(singleton.enregistrement_campagne(), [])
	_charger([_campagne_enreg("campagne_a")])
	assert_true(singleton.enregistrement_campagne_existe())
	assert_eq(singleton.enregistrement_campagne().size(), 1)

func test_enregistrement_campagne_lire_campagne_par_nom():
	_charger([_campagne_enreg("campagne_a", [], 1000.0), _campagne_enreg("campagne_b", [], 2000.0)])
	assert_eq(singleton.enregistrement_campagne_lire_campagne("campagne_b").get("date_debut"), 2000.0)
	assert_eq(singleton.enregistrement_campagne_lire_campagne("campagne_a").get("date_debut"), 1000.0)
	assert_eq(singleton.enregistrement_campagne_lire_campagne("inconnue"), {})
	assert_eq(singleton.enregistrement_campagne_lire_campagne(""), {})

func test_enregistrement_campagne_lire_campagne_sans_enregistrement():
	_charger()
	assert_eq(singleton.enregistrement_campagne_lire_campagne("campagne_a"), {})

func test_enregistrement_campagne_lire_derniere_campagne_parmi_plusieurs():
	_charger([_campagne_enreg("campagne_a"), _campagne_enreg("campagne_b"), _campagne_enreg("campagne_c")])
	assert_eq(singleton.enregistrement_campagne_lire_nom_derniere_campagne(), "campagne_c")
	assert_eq(singleton.enregistrement_campagne_lire_derniere_campagne().get("campagne"), "campagne_c")

func test_enregistrement_campagne_lire_derniere_campagne_sans_enregistrement():
	_charger()
	assert_eq(singleton.enregistrement_campagne_lire_derniere_campagne(), {})
	assert_eq(singleton.enregistrement_campagne_lire_nom_derniere_campagne(), "")

func test_enregistrement_campagne_modifier_nom_derniere_campagne_persiste():
	_charger([_campagne_enreg("campagne_a"), _campagne_enreg("campagne_b")])
	assert_true(singleton.enregistrement_campagne_modifier_nom_derniere_campagne("renommee"))
	assert_eq(singleton.enregistrement_campagne_lire_nom_derniere_campagne(), "renommee")
	var relu = _relire()["enregistrement_campagne"]
	assert_eq([relu[0]["campagne"], relu[1]["campagne"]], ["campagne_a", "renommee"])

func test_enregistrement_campagne_modifier_nom_derniere_campagne_sans_enregistrement():
	_charger()
	assert_false(singleton.enregistrement_campagne_modifier_nom_derniere_campagne("x"))

func test_enregistrement_campagne_en_cours_depend_de_la_date_de_fin_de_la_derniere():
	_charger()
	assert_false(singleton.enregistrement_campagne_en_cours())
	_charger([_campagne_enreg("campagne_a", [], 1000.0, 0.0)])
	assert_true(singleton.enregistrement_campagne_en_cours())
	_charger([_campagne_enreg("campagne_a", [], 1000.0, 1500.0)])
	assert_false(singleton.enregistrement_campagne_en_cours())
	_charger([_campagne_enreg("campagne_a", [], 1000.0, 1500.0), _campagne_enreg("campagne_b", [], 2000.0, 0.0)])
	assert_true(singleton.enregistrement_campagne_en_cours())
	_charger([_campagne_enreg("campagne_a", [], 1000.0, 0.0), _campagne_enreg("campagne_b", [], 2000.0, 2500.0)])
	assert_false(singleton.enregistrement_campagne_en_cours())

func test_initialiser_une_nouvelle_campagne_cree_l_enregistrement_initial():
	_charger()
	var avant = Time.get_unix_time_from_system()
	assert_true(singleton.enregistrement_campagne_initialiser_une_nouvelle_campagne())

	var campagne = singleton.enregistrement_campagne_lire_derniere_campagne()
	assert_eq(campagne.get("campagne"), "campagne_a")
	assert_eq(campagne.get("date_fin"), 0.0)
	assert_eq(campagne.get("score"), {})
	assert_eq(campagne.get("niveaux"), [])
	assert_almost_eq(campagne.get("date_debut"), avant, 5.0)
	assert_true(singleton.enregistrement_campagne_en_cours())
	assert_eq(_relire()["enregistrement_campagne"].size(), 1)

func test_initialiser_une_nouvelle_campagne_refuse_si_une_campagne_est_en_cours():
	_charger([_campagne_enreg("campagne_a", [], 1000.0, 0.0)])
	assert_false(singleton.enregistrement_campagne_initialiser_une_nouvelle_campagne())
	assert_eq(singleton.enregistrement_campagne().size(), 1)

func test_initialiser_une_nouvelle_campagne_apres_une_campagne_terminee_en_ajoute_une_seconde():
	_charger([_campagne_enreg("campagne_a", [], 1000.0, 1500.0, {"fin_campagne": 42})], {},
		{"nom_campagne": "campagne_b"})
	assert_true(singleton.enregistrement_campagne_initialiser_une_nouvelle_campagne())
	assert_eq(singleton.enregistrement_campagne().size(), 2)
	assert_eq(singleton.enregistrement_campagne_lire_nom_derniere_campagne(), "campagne_b")
	assert_eq(singleton.enregistrement_campagne_lire_campagne("campagne_a").get("date_fin"), 1500.0)
	assert_eq(_relire()["enregistrement_campagne"].size(), 2)

func test_initialiser_une_nouvelle_campagne_recree_la_liste_si_la_cle_est_absente():
	_charger()
	singleton.lire_sauvegarde().erase("enregistrement_campagne")
	assert_true(singleton.enregistrement_campagne_initialiser_une_nouvelle_campagne())
	assert_eq(singleton.enregistrement_campagne().size(), 1)

func test_initialiser_une_nouvelle_campagne_sans_joueur_retourne_false_sans_planter():
	singleton.liberer_le_joueur()
	var resultat = singleton.enregistrement_campagne_initialiser_une_nouvelle_campagne()
	assert_false(resultat)
	assert_false(FichiersJsonService.json_file_exists(FICHIER))

func test_terminer_campagne_renseigne_la_date_de_fin_une_seule_fois():
	_charger([_campagne_enreg("campagne_a", [], 1000.0, 0.0)])
	var avant = Time.get_unix_time_from_system()
	singleton.enregistrement_campagne_terminer_campagne()
	var date_fin = singleton.enregistrement_campagne_lire_derniere_campagne().get("date_fin")
	assert_almost_eq(date_fin, avant, 5.0)
	assert_false(singleton.enregistrement_campagne_en_cours())
	assert_eq(_derniere_campagne_relue()["date_fin"], date_fin)

	singleton.lire_sauvegarde()["enregistrement_campagne"].back()["date_fin"] = 1234.0
	singleton.enregistrement_campagne_terminer_campagne()
	assert_eq(singleton.enregistrement_campagne_lire_derniere_campagne().get("date_fin"), 1234.0)

func test_terminer_campagne_ne_touche_que_la_derniere_campagne():
	_charger([_campagne_enreg("campagne_a", [], 1000.0, 1500.0), _campagne_enreg("campagne_b", [], 2000.0, 0.0)])
	singleton.enregistrement_campagne_terminer_campagne()
	var relu = _relire()["enregistrement_campagne"]
	assert_eq(relu[0]["date_fin"], 1500.0)
	assert_gt(relu[1]["date_fin"], 2000.0)

func test_terminer_campagne_sans_enregistrement_ne_cree_rien():
	_charger()
	singleton.enregistrement_campagne_terminer_campagne()
	assert_eq(singleton.enregistrement_campagne(), [])


# ---------------------------------------------------------
# ENREGISTREMENT CAMPAGNE : SCORE DE FIN DE CAMPAGNE
# ---------------------------------------------------------

func test_modifier_et_lire_le_score_fin_campagne():
	_charger([_campagne_enreg("campagne_a", [], 1000.0, 0.0)])
	assert_eq(singleton.enregistrement_campagne_lire_score_derniere_fin_campagne(), 0)
	singleton.enregistrement_campagne_modifier_score_fin_campagne(5000)
	assert_eq(singleton.enregistrement_campagne_lire_score_derniere_fin_campagne(), 5000)
	assert_eq(singleton.enregistrement_campagne_lire_score_fin_campagne(singleton.enregistrement_campagne_lire_derniere_campagne()), 5000)
	assert_eq(_derniere_campagne_relue()["score"]["fin_campagne"], 5000.0)

func test_modifier_score_fin_campagne_cree_la_cle_score_et_conserve_les_autres_scores():
	_charger([_campagne_enreg("campagne_a")])
	singleton.enregistrement_campagne_lire_derniere_campagne().erase("score")
	singleton.enregistrement_campagne_modifier_score_fin_campagne(7)
	assert_eq(singleton.enregistrement_campagne_lire_score_derniere_fin_campagne(), 7)

	_charger([_campagne_enreg("campagne_a", [], 1000.0, 0.0, {"autre": 1})])
	singleton.enregistrement_campagne_modifier_score_fin_campagne(9)
	assert_eq(singleton.enregistrement_campagne_lire_derniere_campagne()["score"]["autre"], 1.0)
	assert_eq(singleton.enregistrement_campagne_lire_score_derniere_fin_campagne(), 9)

func test_modifier_score_fin_campagne_ne_modifie_que_la_derniere_campagne():
	_charger([_campagne_enreg("campagne_a", [], 1000.0, 1500.0, {"fin_campagne": 11}), _campagne_enreg("campagne_b")])
	singleton.enregistrement_campagne_modifier_score_fin_campagne(22)
	assert_eq(singleton.enregistrement_campagne_lire_score_fin_campagne(singleton.enregistrement_campagne_lire_campagne("campagne_a")), 11)
	assert_eq(singleton.enregistrement_campagne_lire_score_derniere_fin_campagne(), 22)

func test_lire_score_fin_campagne_retourne_zero_pour_les_cas_vides():
	assert_eq(singleton.enregistrement_campagne_lire_score_fin_campagne({}), 0)
	assert_eq(singleton.enregistrement_campagne_lire_score_fin_campagne({"score": {}}), 0)
	assert_eq(singleton.enregistrement_campagne_lire_score_fin_campagne({"score": {"fin_campagne": 0}}), 0)
	assert_eq(singleton.enregistrement_campagne_lire_score_fin_campagne({"score": {"fin_campagne": 12}}), 12)
	_charger()
	singleton.enregistrement_campagne_modifier_score_fin_campagne(5)
	assert_eq(singleton.enregistrement_campagne_lire_score_derniere_fin_campagne(), 0)


# ---------------------------------------------------------
# ENREGISTREMENT CAMPAGNE : NIVEAUX
# ---------------------------------------------------------

func test_niveau_existe_et_lecture_des_niveaux():
	_charger([_campagne_enreg("campagne_a")])
	assert_false(singleton.enregistrement_campagne_niveau_existe())
	assert_eq(singleton.enregistrement_campagne_lire_derniers_niveaux(), [])
	assert_eq(singleton.enregistrement_campagne_lire_dernier_niveau(), {})
	assert_eq(singleton.enregistrement_campagne_lire_nom_dernier_niveau(), "")
	assert_false(singleton.enregistrement_campagne_niveau_en_cours())

	_charger_campagne_en_cours()
	assert_true(singleton.enregistrement_campagne_niveau_existe())
	assert_eq(singleton.enregistrement_campagne_lire_derniers_niveaux().size(), 2)
	assert_eq(singleton.enregistrement_campagne_lire_nom_dernier_niveau(), "niveau_2")
	assert_eq(singleton.enregistrement_campagne_lire_dernier_niveau().get("niveau"), "niveau_2")
	assert_true(singleton.enregistrement_campagne_niveau_en_cours())

func test_lire_niveaux_d_une_campagne_donnee():
	_charger_campagne_en_cours()
	var campagne = singleton.enregistrement_campagne_lire_campagne("campagne_a")
	assert_eq(singleton.enregistrement_campagne_lire_niveaux(campagne).size(), 2)
	assert_eq(singleton.enregistrement_campagne_lire_niveaux({}), [])
	assert_eq(singleton.enregistrement_campagne_lire_niveaux({"campagne": "x"}), [])

func test_lire_niveau_par_nom_de_campagne_et_de_niveau():
	_charger_campagne_en_cours()
	var niveau = singleton.enregistrement_campagne_lire_niveau("campagne_a", "niveau_1")
	assert_eq(niveau.get("niveau"), "niveau_1")
	assert_eq(singleton.enregistrement_campagne_lire_nom_niveau(niveau), "niveau_1")
	assert_eq(singleton.enregistrement_campagne_lire_niveau("campagne_a", "niveau_9"), {})
	assert_eq(singleton.enregistrement_campagne_lire_niveau("inconnue", "niveau_1"), {})
	assert_eq(singleton.enregistrement_campagne_lire_nom_niveau({}), "")

func test_lire_niveau_distingue_deux_campagnes_ayant_des_niveaux_homonymes():
	_charger([
		_campagne_enreg("campagne_a", [_niveau("niveau_1", [], 1000.0)], 1000.0, 1500.0),
		_campagne_enreg("campagne_b", [_niveau("niveau_1", [], 2000.0)], 2000.0)
	])
	assert_eq(singleton.enregistrement_campagne_lire_niveau("campagne_a", "niveau_1").get("date_debut"), 1000.0)
	assert_eq(singleton.enregistrement_campagne_lire_niveau("campagne_b", "niveau_1").get("date_debut"), 2000.0)
	assert_eq(singleton.enregistrement_campagne_lire_niveau_joueur(), "niveau_1")

func test_initialiser_un_nouveau_niveau_prend_le_prochain_niveau_de_campagne():
	_charger([_campagne_enreg("campagne_a", [_niveau("niveau_1", [], 1000.0, 1100.0)])],
		{"niveau_3": [_entree("C1", 3)], "niveau_5": [_entree("E1", 5)]})
	var avant = Time.get_unix_time_from_system()
	assert_true(singleton.enregistrement_campagne_initialiser_un_nouveau_niveau())

	var niveau = singleton.enregistrement_campagne_lire_dernier_niveau()
	assert_eq(niveau.get("niveau"), "niveau_3")
	assert_eq(niveau.get("date_fin"), 0.0)
	assert_eq(niveau.get("score"), {})
	assert_eq(niveau.get("plateaux"), [])
	assert_almost_eq(niveau.get("date_debut"), avant, 5.0)
	assert_eq(singleton.enregistrement_campagne_lire_derniers_niveaux().size(), 2)
	assert_eq(_derniere_campagne_relue()["niveaux"].size(), 2)

func test_initialiser_un_nouveau_niveau_refuse_si_un_niveau_est_en_cours():
	_charger_campagne_en_cours()
	assert_false(singleton.enregistrement_campagne_initialiser_un_nouveau_niveau())
	assert_false(singleton.enregistrement_campagne_initialiser_un_nouveau_niveau(7))
	assert_eq(singleton.enregistrement_campagne_lire_derniers_niveaux().size(), 2)

func test_initialiser_un_nouveau_niveau_avec_niveau_force():
	_charger([_campagne_enreg("campagne_a", [], 1000.0)], {"niveau_1": [_entree("A")]})
	assert_true(singleton.enregistrement_campagne_initialiser_un_nouveau_niveau(4))
	assert_eq(singleton.enregistrement_campagne_lire_nom_dernier_niveau(), "niveau_4")
	assert_eq(singleton.enregistrement_campagne_lire_valeur_niveau_joueur(), 4)

func test_initialiser_un_nouveau_niveau_sur_une_campagne_vide_prend_le_premier_niveau():
	_charger([_campagne_enreg("campagne_a", [], 1000.0)], {"niveau_2": [_entree("B", 2)], "niveau_1": [_entree("A")]})
	assert_true(singleton.enregistrement_campagne_initialiser_un_nouveau_niveau())
	assert_eq(singleton.enregistrement_campagne_lire_nom_dernier_niveau(), "niveau_1")

func test_initialiser_un_nouveau_niveau_sans_niveau_restant_retourne_false():
	_charger([_campagne_enreg("campagne_a", [], 1000.0)], {})
	assert_false(singleton.enregistrement_campagne_initialiser_un_nouveau_niveau())
	assert_eq(singleton.enregistrement_campagne_lire_derniers_niveaux(), [])

func test_initialiser_un_nouveau_niveau_apres_le_dernier_niveau_ne_cree_pas_de_niveau_fantome():
	_charger([_campagne_enreg("campagne_a", [_niveau("niveau_1", [], 1000.0, 1100.0)])], {})
	var resultat = singleton.enregistrement_campagne_initialiser_un_nouveau_niveau()
	assert_false(resultat)
	assert_eq(singleton.enregistrement_campagne_lire_derniers_niveaux().size(), 1)

func test_initialiser_un_nouveau_niveau_sans_enregistrement_de_campagne_ne_plante_pas():
	_charger([], {"niveau_1": [_entree("A")]})
	var resultat = singleton.enregistrement_campagne_initialiser_un_nouveau_niveau()
	assert_false(resultat)

func test_terminer_niveau_renseigne_la_date_de_fin_une_seule_fois():
	_charger_campagne_en_cours()
	var avant = Time.get_unix_time_from_system()
	singleton.enregistrement_campagne_terminer_niveau()
	var date_fin = singleton.enregistrement_campagne_lire_dernier_niveau().get("date_fin")
	assert_almost_eq(date_fin, avant, 5.0)
	assert_false(singleton.enregistrement_campagne_niveau_en_cours())
	assert_eq(_derniere_campagne_relue()["niveaux"][1]["date_fin"], date_fin)
	assert_eq(_derniere_campagne_relue()["niveaux"][0]["date_fin"], 1100.0)

	singleton.lire_sauvegarde()["enregistrement_campagne"].back()["niveaux"].back()["date_fin"] = 999.0
	singleton.enregistrement_campagne_terminer_niveau()
	assert_eq(singleton.enregistrement_campagne_lire_dernier_niveau().get("date_fin"), 999.0)

func test_terminer_niveau_sans_niveau_ne_fait_rien():
	_charger([_campagne_enreg("campagne_a")])
	singleton.enregistrement_campagne_terminer_niveau()
	assert_eq(singleton.enregistrement_campagne_lire_derniers_niveaux(), [])

func test_lire_prochain_niveau_de_campagne():
	_charger([], {})
	assert_eq(singleton.lire_prochain_niveau_de_campagne(), 0)

	_charger([], {"niveau_4": [_entree("D", 4)], "niveau_2": [_entree("B", 2)]})
	assert_eq(singleton.lire_prochain_niveau_de_campagne(), 2)

	_charger([_campagne_enreg("campagne_a", [_niveau("niveau_1", [], 1000.0, 0.0)])], {"niveau_3": [_entree("C", 3)]})
	assert_eq(singleton.lire_prochain_niveau_de_campagne(), 0)

	_charger([_campagne_enreg("campagne_a", [_niveau("niveau_1", [], 1000.0, 1100.0)])], {"niveau_3": [_entree("C", 3)]})
	assert_eq(singleton.lire_prochain_niveau_de_campagne(), 3)

func test_lire_prochain_niveau_de_campagne_apres_le_dernier_niveau_retourne_zero():
	_charger([_campagne_enreg("campagne_a", [_niveau("niveau_1", [], 1000.0, 1100.0)])], {})
	assert_eq(singleton.lire_prochain_niveau_de_campagne(), 0)


# ---------------------------------------------------------
# ENREGISTREMENT CAMPAGNE : INSERTION / IMPORT
# ---------------------------------------------------------

func _noms_niveaux(nom_campagne: String) -> Array:
	var noms = []
	var campagne = singleton.enregistrement_campagne_lire_campagne(nom_campagne)
	for niveau in singleton.enregistrement_campagne_lire_niveaux(campagne):
		noms.append(niveau.get("niveau"))
	return noms

func _charger_campagne_a_deux_niveaux() -> void:
	_charger([_campagne_enreg("campagne_a", [
		_niveau("niveau_1", [], 100.0, 150.0),
		_niveau("niveau_3", [], 300.0, 350.0)
	], 50.0, 0.0)])

func test_inserer_niveau_respecte_la_chronologie():
	_charger_campagne_a_deux_niveaux()
	assert_true(singleton.enregistrement_campagne_inserer_niveau("campagne_a", _niveau("niveau_2", [], 200.0)))
	assert_eq(_noms_niveaux("campagne_a"), ["niveau_1", "niveau_2", "niveau_3"])
	assert_true(singleton.enregistrement_campagne_inserer_niveau("campagne_a", _niveau("niveau_0", [], 10.0)))
	assert_eq(_noms_niveaux("campagne_a"), ["niveau_0", "niveau_1", "niveau_2", "niveau_3"])
	assert_true(singleton.enregistrement_campagne_inserer_niveau("campagne_a", _niveau("niveau_9", [], 900.0)))
	assert_eq(_noms_niveaux("campagne_a"), ["niveau_0", "niveau_1", "niveau_2", "niveau_3", "niveau_9"])
	assert_eq(_derniere_campagne_relue()["niveaux"].size(), 5)

func test_inserer_niveau_de_meme_date_est_place_apres_l_existant():
	_charger_campagne_a_deux_niveaux()
	assert_true(singleton.enregistrement_campagne_inserer_niveau("campagne_a", _niveau("niveau_bis", [], 100.0)))
	assert_eq(_noms_niveaux("campagne_a"), ["niveau_1", "niveau_bis", "niveau_3"])

func test_inserer_niveau_dans_une_campagne_vide_et_sans_date():
	_charger([_campagne_enreg("campagne_a", [], 50.0)])
	assert_true(singleton.enregistrement_campagne_inserer_niveau("campagne_a", {"niveau": "niveau_1"}))
	assert_eq(_noms_niveaux("campagne_a"), ["niveau_1"])

func test_inserer_niveau_cible_la_bonne_campagne():
	_charger([_campagne_enreg("campagne_a", [], 50.0, 60.0), _campagne_enreg("campagne_b", [], 70.0)])
	assert_true(singleton.enregistrement_campagne_inserer_niveau("campagne_a", _niveau("niveau_1", [], 55.0)))
	assert_eq(_noms_niveaux("campagne_a"), ["niveau_1"])
	assert_eq(_noms_niveaux("campagne_b"), [])

func test_inserer_niveau_refuse_les_parametres_invalides():
	_charger_campagne_a_deux_niveaux()
	assert_false(singleton.enregistrement_campagne_inserer_niveau("inconnue", _niveau("niveau_2", [], 200.0)))
	assert_false(singleton.enregistrement_campagne_inserer_niveau("", _niveau("niveau_2", [], 200.0)))
	assert_false(singleton.enregistrement_campagne_inserer_niveau("campagne_a", {"date_debut": 200.0}))
	assert_false(singleton.enregistrement_campagne_inserer_niveau("campagne_a", {}))
	assert_eq(_noms_niveaux("campagne_a"), ["niveau_1", "niveau_3"])

func test_inserer_niveau_sans_joueur_retourne_false():
	singleton.liberer_le_joueur()
	assert_false(singleton.enregistrement_campagne_inserer_niveau("campagne_a", _niveau("niveau_1", [], 1.0)))

func test_inserer_campagne_importe_une_nouvelle_campagne_sans_ses_niveaux():
	_charger()
	var donnees = {"campagne": "campagne_x", "date_debut": 5.0, "date_fin": 9.0, "score": {},
		"niveaux": [_niveau("niveau_1")]}
	singleton.enregistrement_campagne_inserer_campagne("campagne_x", donnees)
	var campagne = singleton.enregistrement_campagne_lire_campagne("campagne_x")
	assert_eq(campagne.get("date_debut"), 5.0)
	assert_eq(campagne.get("date_fin"), 9.0)
	assert_eq(campagne.get("niveaux"), [])
	assert_eq(donnees["niveaux"].size(), 1)
	assert_eq(_relire()["enregistrement_campagne"].size(), 1)

func test_inserer_campagne_existante_remplace_uniquement_le_score():
	_charger([_campagne_enreg("campagne_x", [_niveau("niveau_1")], 1.0, 2.0, {"fin_campagne": 1})])
	singleton.enregistrement_campagne_inserer_campagne("campagne_x",
		{"campagne": "campagne_x", "date_debut": 99.0, "score": {"fin_campagne": 77}})
	assert_eq(singleton.enregistrement_campagne().size(), 1)
	var campagne = singleton.enregistrement_campagne_lire_campagne("campagne_x")
	assert_eq(campagne.get("date_debut"), 1.0)
	assert_eq(campagne.get("niveaux").size(), 1)
	assert_eq(singleton.enregistrement_campagne_lire_score_fin_campagne(campagne), 77)

func test_inserer_campagne_existante_avec_score_vide_conserve_le_score():
	_charger([_campagne_enreg("campagne_x", [], 1.0, 2.0, {"fin_campagne": 5})])
	singleton.enregistrement_campagne_inserer_campagne("campagne_x", {"campagne": "campagne_x", "score": {}})
	assert_eq(singleton.enregistrement_campagne_lire_score_fin_campagne(singleton.enregistrement_campagne_lire_campagne("campagne_x")), 5)

func test_inserer_campagne_recree_la_liste_si_la_cle_est_absente():
	_charger()
	singleton.lire_sauvegarde().erase("enregistrement_campagne")
	singleton.enregistrement_campagne_inserer_campagne("campagne_x", {"campagne": "campagne_x", "score": {}})
	assert_eq(singleton.enregistrement_campagne().size(), 1)

func test_inserer_campagne_sans_cle_score_ne_plante_pas():
	_charger()
	singleton.enregistrement_campagne_inserer_campagne("campagne_x", {"campagne": "campagne_x"})
	assert_eq(singleton.enregistrement_campagne().size(), 1)

func test_importer_une_campagne_complete_conserve_tous_les_niveaux_et_plateaux():
	_charger()
	var campagne := {
		"campagne": "campagne_x",
		"date_debut": 5.0,
		"date_fin": 9.0,
		"score": {"fin_campagne": 123},
		"niveaux": [
			_niveau("niveau_1", [_plateau("P1")], 6.0, 8.0),
			_niveau("niveau_2", [_plateau("P2")], 10.0, 12.0)
		]
	}
	assert_true(singleton.enregistrement_campagne_importer_campagne(campagne))
	assert_eq(singleton.enregistrement_campagne_lire_derniere_campagne(), campagne)

func test_importer_campagne_refuse_les_donnees_invalides_et_les_noms_existants():
	_charger()
	assert_false(singleton.enregistrement_campagne_importer_campagne({"campagne": "", "niveaux": []}))
	assert_false(singleton.enregistrement_campagne_importer_campagne({"campagne": "campagne_x", "niveaux": "invalid"}))
	assert_true(singleton.enregistrement_campagne_importer_campagne({
		"campagne": "campagne_x",
		"niveaux": [_niveau("niveau_1")]
	}))
	assert_false(singleton.enregistrement_campagne_importer_campagne({
		"campagne": "campagne_x",
		"niveaux": [_niveau("niveau_2")]
	}))


# ---------------------------------------------------------
# ENREGISTREMENT CAMPAGNE : NIVEAU DU JOUEUR
# ---------------------------------------------------------

func test_lire_niveau_joueur_et_valeur():
	_charger_campagne_en_cours()
	assert_eq(singleton.enregistrement_campagne_lire_niveau_joueur(), "niveau_2")
	assert_eq(singleton.enregistrement_campagne_lire_valeur_niveau_joueur(), 2)

func test_lire_niveau_joueur_sans_niveau():
	_charger([_campagne_enreg("campagne_a")])
	assert_eq(singleton.enregistrement_campagne_lire_niveau_joueur(), "")
	assert_eq(singleton.enregistrement_campagne_lire_valeur_niveau_joueur(), 0)

func test_lire_niveau_joueur_lit_le_niveau_de_la_derniere_campagne_uniquement():
	_charger([
		_campagne_enreg("campagne_a", [_niveau("niveau_8", [], 1000.0, 1100.0)], 1000.0, 1200.0),
		_campagne_enreg("campagne_b", [_niveau("niveau_1", [], 2000.0)], 2000.0)
	])
	assert_eq(singleton.enregistrement_campagne_lire_valeur_niveau_joueur(), 1)

func test_lire_niveau_joueur_sur_une_nouvelle_campagne_sans_niveau():
	_charger([
		_campagne_enreg("campagne_a", [_niveau("niveau_8", [], 1000.0, 1100.0)], 1000.0, 1200.0),
		_campagne_enreg("campagne_b", [], 2000.0)
	])
	assert_eq(singleton.enregistrement_campagne_lire_niveau_joueur(), "")
	assert_false(singleton.enregistrement_campagne_niveau_existe())

func test_longueur_realisee_ne_compte_que_les_plateaux_reussis():
	_charger_campagne_en_cours()
	assert_eq(singleton.enregistrement_campagne_lire_niveau_longueur_realisee(), 1)
	assert_eq(singleton.lire_longueur_niveau_courant(), 3)

func test_longueur_realisee_sans_plateau():
	_charger([_campagne_enreg("campagne_a", [_niveau("niveau_1", [], 1000.0)])], {"niveau_1": [_entree("A"), _entree("B")]})
	assert_eq(singleton.enregistrement_campagne_lire_niveau_longueur_realisee(), 0)
	assert_eq(singleton.lire_longueur_niveau_courant(), 2)

func test_ratio_reussite_du_niveau():
	_charger_niveau_avec_plateaux([_plateau("P1", "reussi"), _plateau("P2", "abandonné"), _plateau_en_cours("P3")])
	assert_eq(singleton.enregistrement_campagne_lire_ratio_reussite_niveau(), 50)

func test_ratio_reussite_du_niveau_arrondi_et_cas_extremes():
	_charger_niveau_avec_plateaux([_plateau("P1"), _plateau("P2"), _plateau("P3", "passé")])
	assert_eq(singleton.enregistrement_campagne_lire_ratio_reussite_niveau(), 67)
	_charger_niveau_avec_plateaux([_plateau("P1"), _plateau("P2", "abandonné"), _plateau("P3", "abandonné")])
	assert_eq(singleton.enregistrement_campagne_lire_ratio_reussite_niveau(), 33)
	_charger_niveau_avec_plateaux([_plateau("P1"), _plateau("P2")])
	assert_eq(singleton.enregistrement_campagne_lire_ratio_reussite_niveau(), 100)
	_charger_niveau_avec_plateaux([_plateau("P1", "abandonné")])
	assert_eq(singleton.enregistrement_campagne_lire_ratio_reussite_niveau(), 0)

func test_ratio_reussite_du_niveau_sans_plateau_acheve():
	_charger_niveau_avec_plateaux([])
	assert_eq(singleton.enregistrement_campagne_lire_ratio_reussite_niveau(), 0)
	_charger_plateau_en_cours()
	assert_eq(singleton.enregistrement_campagne_lire_ratio_reussite_niveau(), 0)


# ---------------------------------------------------------
# ENREGISTREMENT CAMPAGNE : SCORES DU NIVEAU
# ---------------------------------------------------------

func test_modifier_et_lire_les_scores_du_dernier_niveau():
	_charger_campagne_en_cours()
	assert_eq(singleton.enregistrement_campagne_lire_score_dernier_niveau(), 0)
	singleton.enregistrement_campagne_modifier_score_niveau(1500)
	singleton.enregistrement_campagne_modifier_score_niveau_parfait(2500)

	var niveau = singleton.enregistrement_campagne_lire_dernier_niveau()
	assert_eq(singleton.enregistrement_campagne_lire_score_dernier_niveau(), 1500)
	assert_eq(singleton.enregistrement_campagne_lire_score_niveau(niveau), 1500)
	assert_eq(singleton.enregistrement_campagne_lire_score_niveau_parfait(niveau), 2500)
	var relu = _derniere_campagne_relue()["niveaux"]
	assert_eq(relu[1]["score"], {"niveau": 1500.0, "niveau_parfait": 2500.0})
	assert_eq(relu[0]["score"], {"niveau": 300.0, "niveau_parfait": 400.0})

func test_lire_les_scores_d_un_niveau_precedent():
	_charger_campagne_en_cours()
	var niveau_1 = singleton.enregistrement_campagne_lire_niveau("campagne_a", "niveau_1")
	assert_eq(singleton.enregistrement_campagne_lire_score_niveau(niveau_1), 300)
	assert_eq(singleton.enregistrement_campagne_lire_score_niveau_parfait(niveau_1), 400)

func test_modifier_score_niveau_cree_la_cle_score_si_absente():
	_charger_campagne_en_cours()
	singleton.enregistrement_campagne_lire_dernier_niveau().erase("score")
	singleton.enregistrement_campagne_modifier_score_niveau(11)
	assert_eq(singleton.enregistrement_campagne_lire_score_dernier_niveau(), 11)
	singleton.enregistrement_campagne_lire_dernier_niveau().erase("score")
	singleton.enregistrement_campagne_modifier_score_niveau_parfait(12)
	assert_eq(singleton.enregistrement_campagne_lire_score_niveau_parfait(singleton.enregistrement_campagne_lire_dernier_niveau()), 12)

func test_lire_scores_niveau_retourne_zero_pour_les_cas_vides():
	assert_eq(singleton.enregistrement_campagne_lire_score_niveau({}), 0)
	assert_eq(singleton.enregistrement_campagne_lire_score_niveau({"score": {}}), 0)
	assert_eq(singleton.enregistrement_campagne_lire_score_niveau({"score": {"niveau": 0}}), 0)
	assert_eq(singleton.enregistrement_campagne_lire_score_niveau_parfait({}), 0)
	assert_eq(singleton.enregistrement_campagne_lire_score_niveau_parfait({"score": {"niveau": 5}}), 0)

func test_modifier_score_niveau_sans_niveau_ne_cree_rien():
	_charger([_campagne_enreg("campagne_a")])
	singleton.enregistrement_campagne_modifier_score_niveau(10)
	singleton.enregistrement_campagne_modifier_score_niveau_parfait(10)
	assert_eq(singleton.enregistrement_campagne_lire_derniers_niveaux(), [])
	assert_eq(singleton.enregistrement_campagne_lire_score_dernier_niveau(), 0)


# ---------------------------------------------------------
# ENREGISTREMENT CAMPAGNE : PLATEAUX
# ---------------------------------------------------------

func test_plateau_existe_et_en_cours():
	_charger([_campagne_enreg("campagne_a", [_niveau("niveau_1", [], 1000.0)])])
	assert_false(singleton.enregistrement_campagne_plateau_existe())
	assert_false(singleton.enregistrement_campagne_plateau_en_cours())
	_charger_niveau_avec_plateaux([_plateau("P1")])
	assert_true(singleton.enregistrement_campagne_plateau_existe())
	assert_false(singleton.enregistrement_campagne_plateau_en_cours())
	_charger_plateau_en_cours()
	assert_true(singleton.enregistrement_campagne_plateau_existe())
	assert_true(singleton.enregistrement_campagne_plateau_en_cours())

func test_plateau_existe_sans_campagne_ni_niveau():
	_charger()
	assert_false(singleton.enregistrement_campagne_plateau_existe())
	_charger([_campagne_enreg("campagne_a")])
	assert_false(singleton.enregistrement_campagne_plateau_existe())
	assert_false(singleton.enregistrement_campagne_plateau_en_cours())

func test_initialiser_un_nouveau_plateau_cree_un_plateau_en_cours():
	_charger_niveau_avec_plateaux([])
	var avant = Time.get_unix_time_from_system()
	assert_true(singleton.enregistrement_campagne_initialiser_un_nouveau_plateau("AAA.BBB", "MEMOIRE", 5))

	var plateau = singleton.enregistrement_campagne_lire_dernier_plateau()
	assert_eq(plateau.get("nom"), "AAA.BBB")
	assert_eq(plateau.get("gameplay"), "MEMOIRE")
	assert_eq(plateau.get("difficulte"), 5)
	assert_eq(plateau.get("statut"), "en cours")
	assert_eq(plateau.get("date_fin"), 0.0)
	assert_eq(plateau.get("duree"), 0)
	assert_eq(plateau.get("score"), {})
	assert_eq(plateau.get("coups joués"), [])
	assert_almost_eq(plateau.get("date_debut"), avant, 5.0)
	assert_true(singleton.enregistrement_campagne_plateau_en_cours())
	assert_eq(_derniere_campagne_relue()["niveaux"][0]["plateaux"][0]["nom"], "AAA.BBB")

func test_initialiser_un_nouveau_plateau_refuse_si_un_plateau_est_en_cours():
	_charger_plateau_en_cours()
	assert_false(singleton.enregistrement_campagne_initialiser_un_nouveau_plateau("X", "CLASSIQUE", 1))
	assert_eq(singleton.enregistrement_campagne_lire_nom_plateau(), "P1")
	assert_eq(_derniere_campagne_relue()["niveaux"][0]["plateaux"].size(), 1)

func test_initialiser_un_nouveau_plateau_apres_un_plateau_termine_l_ajoute_a_la_suite():
	_charger_niveau_avec_plateaux([_plateau("P1")])
	assert_true(singleton.enregistrement_campagne_initialiser_un_nouveau_plateau("P2", "DICO", 2))
	assert_eq(singleton.enregistrement_campagne_lire_nom_plateau(), "P2")
	assert_eq(singleton.enregistrement_campagne_lire_derniers_niveaux()[0]["plateaux"].size(), 2)

func test_initialiser_un_nouveau_plateau_sans_niveau_ne_plante_pas_et_retourne_false():
	_charger([_campagne_enreg("campagne_a")])
	var resultat = singleton.enregistrement_campagne_initialiser_un_nouveau_plateau("P1", "CLASSIQUE", 1)
	assert_false(resultat)

func test_terminer_plateau_en_cours_sans_progression_le_marque_passe():
	_charger_plateau_en_cours(500.0)
	singleton.enregistrement_campagne_terminer_plateau()
	var plateau = singleton.enregistrement_campagne_lire_dernier_plateau()
	assert_eq(plateau.get("statut"), "passé")
	assert_eq(plateau.get("date_fin"), 500.0)
	assert_eq(plateau.get("duree"), 0.0)
	assert_false(singleton.enregistrement_campagne_plateau_en_cours())
	assert_eq(_derniere_campagne_relue()["niveaux"][0]["plateaux"][0]["statut"], "passé")

func test_terminer_plateau_avec_statut_modifie_calcule_la_duree():
	var debut = Time.get_unix_time_from_system() - 30.0
	_charger_plateau_en_cours(debut)
	singleton.enregistrement_campagne_modifier_statut_plateau("reussi")
	singleton.enregistrement_campagne_terminer_plateau()
	var plateau = singleton.enregistrement_campagne_lire_dernier_plateau()
	assert_eq(plateau.get("statut"), "reussi")
	assert_gt(plateau.get("date_fin"), debut)
	assert_almost_eq(plateau.get("duree"), 30.0, 5.0)
	assert_false(singleton.enregistrement_campagne_plateau_en_cours())
	assert_almost_eq(_derniere_campagne_relue()["niveaux"][0]["plateaux"][0]["duree"], 30.0, 5.0)

func test_terminer_plateau_deja_termine_ne_le_modifie_pas():
	_charger_niveau_avec_plateaux([_plateau("P1", "abandonné", 100.0, 130.0)])
	singleton.enregistrement_campagne_terminer_plateau()
	var plateau = singleton.enregistrement_campagne_lire_dernier_plateau()
	assert_eq(plateau.get("date_fin"), 130.0)
	assert_eq(plateau.get("duree"), 30.0)
	assert_eq(plateau.get("statut"), "abandonné")

func test_terminer_plateau_sans_plateau_ne_fait_rien():
	_charger([_campagne_enreg("campagne_a", [_niveau("niveau_1")])])
	singleton.enregistrement_campagne_terminer_plateau()
	assert_false(singleton.enregistrement_campagne_plateau_existe())

func test_lire_nombre_plateaux_acheves():
	_charger([_campagne_enreg("campagne_a", [_niveau("niveau_1")])])
	assert_eq(singleton.enregistrement_campagne_lire_nombre_plateaux_acheves(), 0)
	_charger_plateau_en_cours()
	assert_eq(singleton.enregistrement_campagne_lire_nombre_plateaux_acheves(), 0)
	_charger_niveau_avec_plateaux([_plateau("P1"), _plateau("P2", "abandonné")])
	assert_eq(singleton.enregistrement_campagne_lire_nombre_plateaux_acheves(), 2)
	_charger_niveau_avec_plateaux([_plateau("P1"), _plateau("P2", "passé"), _plateau_en_cours("P3")])
	assert_eq(singleton.enregistrement_campagne_lire_nombre_plateaux_acheves(), 2)

func test_lire_plateaux_d_un_niveau():
	_charger_campagne_en_cours()
	var niveau_2 = singleton.enregistrement_campagne_lire_dernier_niveau()
	assert_eq(singleton.enregistrement_campagne_lire_plateaux(niveau_2).size(), 3)
	assert_eq(singleton.enregistrement_campagne_lire_plateaux({}), [])
	assert_eq(singleton.enregistrement_campagne_lire_plateaux({"niveau": "niveau_9"}), [])

func test_lire_plateau_par_campagne_niveau_et_nom():
	_charger_campagne_en_cours()
	assert_eq(singleton.enregistrement_campagne_lire_plateau("campagne_a", "niveau_2", "B2").get("statut"), "abandonné")
	assert_eq(singleton.enregistrement_campagne_lire_plateau("campagne_a", "niveau_1", "A1").get("difficulte"), 1.0)
	assert_eq(singleton.enregistrement_campagne_lire_plateau("campagne_a", "niveau_1", "B2"), {})
	assert_eq(singleton.enregistrement_campagne_lire_plateau("campagne_a", "niveau_9", "A1"), {})
	assert_eq(singleton.enregistrement_campagne_lire_plateau("inconnue", "niveau_1", "A1"), {})

func test_lire_dernier_plateau_nom_gameplay_et_difficulte():
	_charger_campagne_en_cours()
	assert_eq(singleton.enregistrement_campagne_lire_dernier_plateau().get("nom"), "B3")
	assert_eq(singleton.enregistrement_campagne_lire_nom_plateau(), "B3")
	assert_eq(singleton.enregistrement_campagne_lire_gameplay_plateau(), "CLASSIQUE")
	assert_eq(singleton.enregistrement_campagne_lire_difficulte_plateau(), 2)

func test_lire_dernier_plateau_sans_plateau():
	_charger([_campagne_enreg("campagne_a", [_niveau("niveau_1")])])
	assert_eq(singleton.enregistrement_campagne_lire_dernier_plateau(), {})
	assert_eq(singleton.enregistrement_campagne_lire_nom_plateau(), "")
	assert_eq(singleton.enregistrement_campagne_lire_gameplay_plateau(), "")
	assert_eq(singleton.enregistrement_campagne_lire_difficulte_plateau(), 0)

func test_lire_duree_plateau_en_cours_est_calculee_en_direct():
	_charger_plateau_en_cours(Time.get_unix_time_from_system() - 12.0)
	assert_almost_eq(singleton.enregistrement_campagne_lire_duree_plateau(), 12.0, 5.0)

func test_lire_duree_plateau_termine_retourne_la_duree_enregistree():
	_charger_niveau_avec_plateaux([_plateau("P1", "reussi", 100.0, 142.5)])
	assert_eq(singleton.enregistrement_campagne_lire_duree_plateau(), 42.5)

func test_lire_duree_plateau_recommence_cumule_les_abandons_du_meme_plateau():
	_charger_niveau_avec_plateaux([
		_plateau("X", "abandonné", 100.0, 104.0),
		_plateau("Y", "abandonné", 110.0, 116.0),
		_plateau("X", "abandonné", 120.0, 123.0),
		_plateau("X", "reussi", 130.0, 150.0),
		_plateau_en_cours("X", 160.0)
	])
	assert_eq(singleton.enregistrement_campagne_lire_duree_plateau_recommence(), 7.0)

func test_lire_duree_plateau_recommence_sans_abandon_ou_sans_plateau():
	_charger_niveau_avec_plateaux([_plateau("X", "reussi", 100.0, 104.0), _plateau_en_cours("X", 110.0)])
	assert_eq(singleton.enregistrement_campagne_lire_duree_plateau_recommence(), 0.0)
	_charger([_campagne_enreg("campagne_a", [_niveau("niveau_1")])])
	assert_eq(singleton.enregistrement_campagne_lire_duree_plateau_recommence(), 0.0)

func test_modifier_et_lire_le_statut_du_plateau():
	_charger_plateau_en_cours()
	assert_eq(singleton.enregistrement_campagne_lire_statut_dernier_plateau(), "en cours")
	singleton.enregistrement_campagne_modifier_statut_plateau("abandonné")
	assert_eq(singleton.enregistrement_campagne_lire_statut_dernier_plateau(), "abandonné")
	assert_eq(singleton.enregistrement_campagne_lire_statut_plateau(singleton.enregistrement_campagne_lire_dernier_plateau()), "abandonné")
	assert_eq(_derniere_campagne_relue()["niveaux"][0]["plateaux"][0]["statut"], "abandonné")

func test_lire_statut_sans_plateau_retourne_en_cours():
	_charger([_campagne_enreg("campagne_a", [_niveau("niveau_1")])])
	assert_eq(singleton.enregistrement_campagne_lire_statut_dernier_plateau(), "en cours")
	assert_eq(singleton.enregistrement_campagne_lire_statut_plateau({}), "en cours")
	assert_eq(singleton.enregistrement_campagne_lire_statut_plateau({"statut": "passé"}), "passé")

func test_modifier_statut_ne_touche_que_le_dernier_plateau():
	_charger_campagne_en_cours()
	singleton.enregistrement_campagne_modifier_statut_plateau("reussi")
	var plateaux = singleton.enregistrement_campagne_lire_dernier_niveau().get("plateaux")
	assert_eq([plateaux[0]["statut"], plateaux[1]["statut"], plateaux[2]["statut"]], ["reussi", "abandonné", "reussi"])

func test_modifier_les_scores_du_plateau():
	_charger_plateau_en_cours()
	singleton.enregistrement_campagne_modifier_score_duree_plateau(1200)
	singleton.enregistrement_campagne_modifier_score_ratio_reussite_plateau(80)
	var plateau = singleton.enregistrement_campagne_lire_dernier_plateau()
	assert_eq(singleton.enregistrement_campagne_lire_score_duree_plateau(plateau), 1200)
	assert_eq(singleton.enregistrement_campagne_lire_score_ratio_reussite_plateau(plateau), 80)
	assert_eq(_derniere_campagne_relue()["niveaux"][0]["plateaux"][0]["score"], {"duree": 1200.0, "ratio_reussite": 80.0})

func test_modifier_les_scores_du_plateau_cree_la_cle_score_si_absente():
	_charger_plateau_en_cours()
	singleton.enregistrement_campagne_lire_dernier_plateau().erase("score")
	singleton.enregistrement_campagne_modifier_score_duree_plateau(5)
	assert_eq(singleton.enregistrement_campagne_lire_score_duree_plateau(singleton.enregistrement_campagne_lire_dernier_plateau()), 5)
	singleton.enregistrement_campagne_lire_dernier_plateau().erase("score")
	singleton.enregistrement_campagne_modifier_score_ratio_reussite_plateau(6)
	assert_eq(singleton.enregistrement_campagne_lire_score_ratio_reussite_plateau(singleton.enregistrement_campagne_lire_dernier_plateau()), 6)

func test_lire_les_scores_d_un_plateau_retourne_zero_pour_les_cas_vides():
	assert_eq(singleton.enregistrement_campagne_lire_score_duree_plateau({}), 0)
	assert_eq(singleton.enregistrement_campagne_lire_score_duree_plateau({"score": {}}), 0)
	assert_eq(singleton.enregistrement_campagne_lire_score_duree_plateau({"score": {"duree": 0}}), 0)
	assert_eq(singleton.enregistrement_campagne_lire_score_ratio_reussite_plateau({}), 0)
	assert_eq(singleton.enregistrement_campagne_lire_score_ratio_reussite_plateau({"score": {"duree": 3}}), 0)

func test_lire_les_scores_d_un_plateau_precedent():
	_charger_niveau_avec_plateaux([_plateau("P1", "reussi", 100.0, 110.0, 1, "CLASSIQUE", {"duree": 900, "ratio_reussite": 70}), _plateau_en_cours("P2")])
	var plateau = singleton.enregistrement_campagne_lire_plateau("campagne_a", "niveau_1", "P1")
	assert_eq(singleton.enregistrement_campagne_lire_score_duree_plateau(plateau), 900)
	assert_eq(singleton.enregistrement_campagne_lire_score_ratio_reussite_plateau(plateau), 70)


# ---------------------------------------------------------
# ENREGISTREMENT CAMPAGNE : COUPS JOUES
# ---------------------------------------------------------

func test_coups_joues_ajouter_et_lire():
	_charger_plateau_en_cours()
	assert_true(singleton.enregistrement_campagne_coups_joues_existe())
	assert_eq(singleton.enregistrement_campagne_lire_nombre_coups(), 0)
	assert_true(singleton.enregistrement_campagne_coups_joues_ajouter_un_nouveau_coup(2, 1))
	assert_true(singleton.enregistrement_campagne_coups_joues_ajouter_un_nouveau_coup(0, 3))

	assert_eq(singleton.enregistrement_campagne_lire_nombre_coups(), 2)
	var coups = singleton.enregistrement_campagne_coups_joues()
	assert_eq(coups[0], {"depart": 2, "arrivee": 1})
	assert_eq(coups[1], {"depart": 0, "arrivee": 3})
	var relu = _derniere_campagne_relue()["niveaux"][0]["plateaux"][0]["coups joués"]
	assert_eq(relu.size(), 2)
	assert_eq(relu[1]["arrivee"], 3.0)

func test_coups_joues_refuse_un_plateau_termine():
	_charger_niveau_avec_plateaux([_plateau("P1")])
	assert_true(singleton.enregistrement_campagne_coups_joues_existe())
	assert_false(singleton.enregistrement_campagne_coups_joues_ajouter_un_nouveau_coup(1, 2))
	assert_eq(singleton.enregistrement_campagne_lire_nombre_coups(), 0)

func test_coups_joues_sans_plateau():
	_charger([_campagne_enreg("campagne_a", [_niveau("niveau_1")])])
	assert_false(singleton.enregistrement_campagne_coups_joues_existe())
	assert_eq(singleton.enregistrement_campagne_coups_joues(), [])
	assert_false(singleton.enregistrement_campagne_coups_joues_ajouter_un_nouveau_coup(1, 2))
	assert_eq(singleton.enregistrement_campagne_lire_nombre_coups(), 0)

func test_coups_joues_ne_concerne_que_le_dernier_plateau():
	_charger_niveau_avec_plateaux([_plateau("P1"), _plateau_en_cours("P2")])
	assert_true(singleton.enregistrement_campagne_coups_joues_ajouter_un_nouveau_coup(1, 2))
	assert_eq(singleton.enregistrement_campagne_lire_derniers_niveaux()[0]["plateaux"][0]["coups joués"].size(), 0)
	assert_eq(singleton.enregistrement_campagne_lire_nombre_coups(), 1)

func test_coups_joues_sur_un_plateau_sans_cle_coups_joues_conserve_le_coup():
	_charger_plateau_en_cours()
	singleton.enregistrement_campagne_lire_dernier_plateau().erase("coups joués")
	assert_false(singleton.enregistrement_campagne_coups_joues_existe())
	var resultat = singleton.enregistrement_campagne_coups_joues_ajouter_un_nouveau_coup(1, 2)
	assert_eq(resultat, singleton.enregistrement_campagne_lire_nombre_coups() == 1)


# ---------------------------------------------------------
# SCENARIOS COMPLETS
# ---------------------------------------------------------

func test_scenario_campagne_complete_du_premier_au_dernier_niveau():
	_charger([], {"niveau_1": [_entree("A1", 1)], "niveau_2": [_entree("B1", 2, "MEMOIRE")]})
	assert_true(singleton.enregistrement_campagne_initialiser_une_nouvelle_campagne())
	assert_false(singleton.enregistrement_campagne_initialiser_une_nouvelle_campagne())

	assert_true(singleton.enregistrement_campagne_initialiser_un_nouveau_niveau())
	singleton.commencer_un_plateau()
	assert_eq(singleton.enregistrement_campagne_lire_nom_plateau(), "A1")
	singleton.gagner_un_plateau()
	assert_false(singleton.campagne_niveau_existe(1))
	assert_eq(singleton.enregistrement_campagne_lire_ratio_reussite_niveau(), 100)
	singleton._on_progression_campagne_service_fin_niveau()

	assert_true(singleton.enregistrement_campagne_initialiser_un_nouveau_niveau())
	assert_eq(singleton.enregistrement_campagne_lire_nom_dernier_niveau(), "niveau_2")
	singleton.commencer_un_plateau()
	singleton.abandonner_un_plateau()
	assert_eq(singleton.campagne_nombre_plateaux_pour_le_niveau(2), 1)
	singleton.commencer_un_plateau()
	singleton.gagner_un_plateau()
	assert_eq(singleton.enregistrement_campagne_lire_ratio_reussite_niveau(), 50)
	assert_true(singleton.campagne_la_campagne_est_terminee())
	singleton._on_progression_campagne_service_fin_niveau()
	singleton._on_progression_campagne_service_fin_campagne()

	assert_false(singleton.enregistrement_campagne_en_cours())
	var relu = _derniere_campagne_relue()
	assert_eq(relu["niveaux"].size(), 2)
	assert_eq(relu["niveaux"][1]["plateaux"].size(), 2)
	assert_gt(relu["date_fin"], 0.0)

func test_scenario_deux_campagnes_successives_sont_independantes():
	_charger([], {"niveau_1": [_entree("A1", 1)]})
	singleton.enregistrement_campagne_initialiser_une_nouvelle_campagne()
	singleton.enregistrement_campagne_initialiser_un_nouveau_niveau()
	singleton.commencer_un_plateau()
	singleton.gagner_un_plateau()
	singleton.enregistrement_campagne_modifier_score_fin_campagne(100)
	singleton._on_progression_campagne_service_fin_niveau()
	singleton._on_progression_campagne_service_fin_campagne()

	singleton.lire_sauvegarde()["campagne"] = {"niveau_1": [_entree("Z1", 1)]}
	singleton.lire_sauvegarde()["nom_campagne"] = "campagne_b"
	assert_true(singleton.enregistrement_campagne_initialiser_une_nouvelle_campagne())
	assert_eq(singleton.enregistrement_campagne().size(), 2)
	assert_eq(singleton.enregistrement_campagne_lire_score_derniere_fin_campagne(), 0)
	assert_eq(singleton.enregistrement_campagne_lire_score_fin_campagne(singleton.enregistrement_campagne_lire_campagne("campagne_a")), 100)
	assert_false(singleton.enregistrement_campagne_niveau_existe())
	assert_eq(singleton.enregistrement_campagne_lire_valeur_niveau_joueur(), 0)
	assert_true(singleton.enregistrement_campagne_initialiser_un_nouveau_niveau())
	assert_eq(singleton.enregistrement_campagne_lire_nom_dernier_niveau(), "niveau_1")

# Pause de lecture de l'aide Classique (aucune dépendance à l'UI).
func test_pause_aide_fige_la_duree_sans_modifier_les_dates_ni_les_coups():
	_charger_plateau_en_cours(Time.get_unix_time_from_system() - 10.0)
	singleton.commencer_pause_aide_classique()
	var avant = singleton.lire_sauvegarde().duplicate(true)
	var duree = singleton.enregistrement_campagne_lire_duree_plateau()
	await wait_seconds(0.08)
	assert_eq(singleton.enregistrement_campagne_lire_duree_plateau(), duree)
	assert_eq(singleton.lire_sauvegarde(), avant)
	singleton.commencer_pause_aide_classique() # Idempotent : ne réinitialise pas la pause.
	singleton.terminer_pause_aide_classique()
	var plateau = singleton.enregistrement_campagne_lire_dernier_plateau()
	assert_gt(plateau.get("duree_aide_classique", 0.0), 0.05)
	assert_eq(plateau["date_debut"], avant["enregistrement_campagne"][0]["niveaux"][0]["plateaux"][0]["date_debut"])
	assert_eq(plateau["coups joués"], [])
	assert_almost_eq(singleton.enregistrement_campagne_lire_duree_plateau(), duree, 0.05)

func test_fin_plateau_exclut_le_temps_de_lecture_aide_et_conserve_les_dates_reelles():
	_charger_plateau_en_cours(Time.get_unix_time_from_system() - 20.0)
	var plateau = singleton.enregistrement_campagne_lire_dernier_plateau()
	plateau["duree_aide_classique"] = 5.0
	plateau["statut"] = "reussi"
	singleton.enregistrement_campagne_terminer_plateau()
	assert_almost_eq(plateau["duree"], 15.0, 1.0)
	assert_almost_eq(plateau["date_fin"] - plateau["date_debut"], 20.0, 1.0)

func test_pause_aide_sans_plateau_et_double_fermeture_sont_sans_effet():
	_charger()
	var avant = singleton.lire_sauvegarde().duplicate(true)
	singleton.commencer_pause_aide_classique()
	singleton.terminer_pause_aide_classique()
	singleton.terminer_pause_aide_classique()
	assert_eq(singleton.lire_sauvegarde(), avant)
	assert_true(singleton._plateau_en_aide.is_empty())
