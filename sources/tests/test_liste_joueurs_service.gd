extends GutTest

var service
const RACINE_TEST = "tests/test_liste_joueurs_service"

func _nettoyer_fichiers_utilisateur() -> void:
	FichiersJsonService.effacer_racine_utilisateur()

func _lire_liste_fichier():
	return FichiersJsonService.read_json_file("liste_des_joueurs.json")

func _creer_service(liste_joueurs = null):
	_nettoyer_fichiers_utilisateur()
	if liste_joueurs != null:
		FichiersJsonService.write_json_file("liste_des_joueurs.json", liste_joueurs)
	service = add_child_autofree(load("res://Singletons/Sauvegarde/liste_joueurs_service.gd").new())
	return service

func _assert_joueur_eq(joueur_actuel : Dictionary, joueur_attendu : Dictionary) -> void:
	assert_eq(int(joueur_actuel.get("indice")), int(joueur_attendu.get("indice")))
	assert_eq(joueur_actuel.get("nom"), joueur_attendu.get("nom"))
	assert_eq(joueur_actuel.get("fichier_sauvegarde"), joueur_attendu.get("fichier_sauvegarde"))

func _assert_liste_joueurs_eq(liste_actuelle : Array, liste_attendue : Array) -> void:
	assert_eq(liste_actuelle.size(), liste_attendue.size())
	for index in range(liste_attendue.size()):
		_assert_joueur_eq(liste_actuelle[index], liste_attendue[index])

func before_each():
	FichiersJsonService.definir_racine_utilisateur(RACINE_TEST)
	_nettoyer_fichiers_utilisateur()

func after_each():
	_nettoyer_fichiers_utilisateur()
	FichiersJsonService.reinitialiser_racine_utilisateur()

func test_ready_garde_la_liste_par_defaut_si_le_fichier_est_absent():
	_creer_service()

	var liste_par_defaut = [{
		"indice": 0,
		"nom": "Alain Konu",
		"fichier_sauvegarde": "sauvegarde_joueur_00.json"
	}]

	_assert_liste_joueurs_eq(service.liste_des_joueurs, liste_par_defaut)
	assert_true(FichiersJsonService.json_file_exists("liste_des_joueurs.json"))
	_assert_liste_joueurs_eq(_lire_liste_fichier(), liste_par_defaut)

func test_ready_charge_la_liste_des_joueurs_depuis_le_fichier():
	var liste = [
		{"indice": 0, "nom": "Alice", "fichier_sauvegarde": "test_liste_joueurs_00.json"},
		{"indice": 1, "nom": "Bob", "fichier_sauvegarde": "test_liste_joueurs_01.json"}
	]

	_creer_service(liste)

	_assert_liste_joueurs_eq(service.liste_des_joueurs, liste)
	_assert_liste_joueurs_eq(_lire_liste_fichier(), liste)

func test_ready_corrige_les_anciens_joueurs_sans_indice():
	var ancienne_liste = [
		{"nom": "Alice", "fichier_sauvegarde": "sauvegarde_joueur_07.json"},
		{"indice": 8, "nom": "Bob", "fichier_sauvegarde": "sauvegarde_joueur_08.json"}
	]

	_creer_service(ancienne_liste)

	assert_eq(service.liste_des_joueurs.size(), 2)
	assert_eq(int(service.liste_des_joueurs[0].get("indice")), 7)
	assert_eq(int(service.liste_des_joueurs[1].get("indice")), 8)
	assert_eq(int(_lire_liste_fichier()[0].get("indice")), 7)

func test_corriger_absence_indice_ne_fait_rien_si_la_liste_est_vide():
	_creer_service([
		{"indice": 0, "nom": "Alice", "fichier_sauvegarde": "test_liste_joueurs_00.json"}
	])
	service.liste_des_joueurs = []
	service._corriger_absence_indice()
	assert_eq(service.liste_des_joueurs, [])

func test_le_joueur_existe_et_retourner_le_fichier_de_sauvegarde_couvrent_present_et_absent():
	_creer_service([
		{"indice": 0, "nom": "Alice", "fichier_sauvegarde": "test_liste_joueurs_00.json"}
	])

	assert_true(service.le_joueur_existe("Alice"))
	assert_false(service.le_joueur_existe("Bob"))
	assert_eq(service.retourner_le_fichier_de_sauvegarde("Alice"), "test_liste_joueurs_00.json")
	assert_eq(service.retourner_le_fichier_de_sauvegarde("Bob"), "")

func test_retourner_la_liste_des_joueurs_retourne_les_noms_sans_exposer_la_structure_interne():
	_creer_service([
		{"indice": 0, "nom": "Alice", "fichier_sauvegarde": "test_liste_joueurs_00.json"},
		{"indice": 1, "nom": "Bob", "fichier_sauvegarde": "test_liste_joueurs_01.json"}
	])

	var noms = service.retourner_la_liste_des_joueurs()
	assert_eq(noms, ["Alice", "Bob"])
	noms.append("Charlie")
	assert_eq(service.retourner_la_liste_des_joueurs(), ["Alice", "Bob"])

func test_ajouter_un_nouveau_joueur_refuse_un_nom_vide_ou_deja_pris():
	_creer_service([
		{"indice": 0, "nom": "Alice", "fichier_sauvegarde": "test_liste_joueurs_00.json"}
	])

	assert_false(service.ajouter_un_nouveau_joueur(""))
	assert_false(service.ajouter_un_nouveau_joueur("Alice"))
	assert_eq(service.liste_des_joueurs.size(), 1)

func test_ajouter_un_nouveau_joueur_cree_le_premier_compte_si_la_liste_est_vide():
	_creer_service([])

	assert_true(service.ajouter_un_nouveau_joueur("Alice"))
	assert_eq(service.liste_des_joueurs.size(), 1)
	assert_eq(int(service.liste_des_joueurs[0].get("indice")), 0)
	assert_eq(service.liste_des_joueurs[0].get("fichier_sauvegarde"), "sauvegarde_joueur_00.json")
	assert_eq(_lire_liste_fichier()[0].get("nom"), "Alice")

func test_ajouter_un_nouveau_joueur_utilise_l_indice_du_dernier_joueur_plus_un():
	_creer_service([
		{"indice": 3, "nom": "Alice", "fichier_sauvegarde": "sauvegarde_joueur_03.json"},
		{"indice": 7, "nom": "Bob", "fichier_sauvegarde": "sauvegarde_joueur_07.json"}
	])

	assert_true(service.ajouter_un_nouveau_joueur("Charlie"))
	assert_eq(int(service.liste_des_joueurs[2].get("indice")), 8)
	assert_eq(service.liste_des_joueurs[2].get("fichier_sauvegarde"), "sauvegarde_joueur_08.json")
	assert_eq(_lire_liste_fichier()[2].get("nom"), "Charlie")

func test_supprimer_un_joueur_orphelin_refuse_les_parametres_invalides_et_les_mismatches():
	_creer_service([
		{"indice": 0, "nom": "Alice", "fichier_sauvegarde": "test_liste_joueurs_00.json"}
	])

	assert_false(service.supprimer_un_joueur_orphelin_de_sauvegarde("", "test_liste_joueurs_00.json"))
	assert_false(service.supprimer_un_joueur_orphelin_de_sauvegarde("Alice", ""))
	assert_false(service.supprimer_un_joueur_orphelin_de_sauvegarde("Bob", "test_liste_joueurs_00.json"))
	assert_false(service.supprimer_un_joueur_orphelin_de_sauvegarde("Alice", "test_liste_joueurs_01.json"))
	assert_eq(service.liste_des_joueurs.size(), 1)

func test_supprimer_un_joueur_orphelin_supprime_l_entree_et_persiste():
	_creer_service([
		{"indice": 0, "nom": "Alice", "fichier_sauvegarde": "test_liste_joueurs_00.json"},
		{"indice": 1, "nom": "Bob", "fichier_sauvegarde": "test_liste_joueurs_01.json"}
	])

	assert_true(service.supprimer_un_joueur_orphelin_de_sauvegarde("Alice", "test_liste_joueurs_00.json"))
	assert_eq(service.retourner_la_liste_des_joueurs(), ["Bob"])
	assert_eq(_lire_liste_fichier().size(), 1)
	assert_eq(_lire_liste_fichier()[0].get("nom"), "Bob")

func test_supprimer_un_joueur_retourne_false_si_le_joueur_ne_peut_pas_etre_supprime():
	_creer_service([
		{"indice": 0, "nom": "Alice", "fichier_sauvegarde": "test_liste_joueurs_00.json"}
	])
	FichiersJsonService.write_json_file("test_liste_joueurs_00.json", {"nom": "Alice"})

	assert_false(service.supprimer_un_joueur("Bob", "test_liste_joueurs_00.json"))
	assert_true(service.le_joueur_existe("Alice"))
	assert_true(FichiersJsonService.json_file_exists("test_liste_joueurs_00.json"))

func test_supprimer_un_joueur_supprime_aussi_le_fichier_de_sauvegarde_du_joueur():
	_creer_service([
		{"indice": 0, "nom": "Alice", "fichier_sauvegarde": "test_liste_joueurs_00.json"}
	])
	FichiersJsonService.write_json_file("test_liste_joueurs_00.json", {"nom": "Alice"})

	assert_true(FichiersJsonService.json_file_exists("test_liste_joueurs_00.json"))
	assert_true(service.supprimer_un_joueur("Alice", "test_liste_joueurs_00.json"))
	assert_false(service.le_joueur_existe("Alice"))
	assert_false(FichiersJsonService.json_file_exists("test_liste_joueurs_00.json"))
