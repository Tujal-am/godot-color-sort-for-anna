extends GutTest

const RACINE_TEST = "tests/test_fichiers_json_service"
const FICHIER_SIMPLE = "fichier.json"
const FICHIER_NESTED = "dossier/sous/fichier.json"
const FICHIER_VIDE = "vide.json"
const FICHIER_INVALIDE = "invalide.json"

var racine_initiale = "user://"

func _chemin_absolu(chemin: String) -> String:
	return FichiersJsonService._normaliser_chemin(chemin)

func _nettoyer_fichiers_de_test() -> void:
	FichiersJsonService.definir_racine_utilisateur(RACINE_TEST)
	FichiersJsonService.effacer_racine_utilisateur()

func _ecrire_texte_brut(chemin: String, contenu: String) -> void:
	var chemin_absolu = _chemin_absolu(chemin)
	var parent = chemin_absolu.get_base_dir()
	if parent and not DirAccess.dir_exists_absolute(parent):
		DirAccess.make_dir_recursive_absolute(parent)
	var fichier = FileAccess.open(chemin_absolu, FileAccess.WRITE)
	assert_true(fichier != null)
	fichier.store_string(contenu)
	fichier.close()

func before_each():
	racine_initiale = FichiersJsonService.racine_utilisateur
	FichiersJsonService.definir_racine_utilisateur(RACINE_TEST)
	_nettoyer_fichiers_de_test()

func after_each():
	_nettoyer_fichiers_de_test()
	FichiersJsonService.racine_utilisateur = racine_initiale

func test_definir_racine_utilisateur_gere_vide_relatif_et_absolu():
	FichiersJsonService.definir_racine_utilisateur("")
	assert_eq(FichiersJsonService.racine_utilisateur, "user://")

	FichiersJsonService.definir_racine_utilisateur("tests/module")
	assert_eq(FichiersJsonService.racine_utilisateur, "user://tests/module/")

	FichiersJsonService.definir_racine_utilisateur("user://autre_racine")
	assert_eq(FichiersJsonService.racine_utilisateur, "user://autre_racine/")

func test_reinitialiser_racine_utilisateur_revient_a_user():
	FichiersJsonService.definir_racine_utilisateur("tests/module")
	FichiersJsonService.reinitialiser_racine_utilisateur()
	assert_eq(FichiersJsonService.racine_utilisateur, "user://")

func test_normaliser_chemin_garde_res_et_prefixe_les_chemins_relatifs_et_user():
	FichiersJsonService.definir_racine_utilisateur(RACINE_TEST)

	assert_eq(FichiersJsonService._normaliser_chemin(""), "")
	assert_eq(FichiersJsonService._normaliser_chemin("res://tests/fixture.json"), "res://tests/fixture.json")
	# Un chemin "user://" explicite doit tout de même être redirigé vers la
	# racine de test en vigueur, pour garder les tests isolés du profil réel.
	assert_eq(FichiersJsonService._normaliser_chemin("user://manuel.json"), "user://tests/test_fichiers_json_service/manuel.json")
	assert_eq(FichiersJsonService._normaliser_chemin("fichier.json"), "user://tests/test_fichiers_json_service/fichier.json")
	assert_eq(FichiersJsonService._normaliser_chemin("/fichier.json"), "user://tests/test_fichiers_json_service/fichier.json")

func test_normaliser_chemin_garde_user_intact_quand_aucune_racine_de_test_nest_definie():
	FichiersJsonService.reinitialiser_racine_utilisateur()

	assert_eq(FichiersJsonService._normaliser_chemin("user://manuel.json"), "user://manuel.json")

func test_write_read_et_json_file_exists_fonctionnent_avec_un_fichier_relatif():
	var contenu = {
		"nom": "Alice",
		"score": 42,
		"actif": true
	}

	FichiersJsonService.write_json_file(FICHIER_SIMPLE, contenu)
	var contenu_lu = FichiersJsonService.read_json_file(FICHIER_SIMPLE)

	assert_true(FichiersJsonService.json_file_exists(FICHIER_SIMPLE))
	assert_eq(contenu_lu.get("nom"), "Alice")
	assert_eq(int(contenu_lu.get("score")), 42)
	assert_true(contenu_lu.get("actif"))

func test_write_json_file_cree_les_repertoires_parents_necessaires():
	var contenu = {"ok": true}

	FichiersJsonService.write_json_file(FICHIER_NESTED, contenu)

	assert_true(FichiersJsonService.json_file_exists(FICHIER_NESTED))
	assert_eq(FichiersJsonService.read_json_file(FICHIER_NESTED), contenu)

func test_remove_json_file_efface_un_fichier_existant_et_ignore_un_fichier_absent():
	FichiersJsonService.write_json_file(FICHIER_SIMPLE, {"ok": true})
	assert_true(FichiersJsonService.json_file_exists(FICHIER_SIMPLE))

	FichiersJsonService.remove_json_file(FICHIER_SIMPLE)
	assert_false(FichiersJsonService.json_file_exists(FICHIER_SIMPLE))

	FichiersJsonService.remove_json_file(FICHIER_SIMPLE)
	assert_false(FichiersJsonService.json_file_exists(FICHIER_SIMPLE))

func test_read_json_file_retourne_null_si_le_fichier_n_existe_pas():
	assert_eq(FichiersJsonService.read_json_file("absent.json"), null)

func test_read_json_file_retourne_null_si_le_fichier_est_vide():
	_ecrire_texte_brut(FICHIER_VIDE, "")
	assert_eq(FichiersJsonService.read_json_file(FICHIER_VIDE), null)

func test_read_json_file_retourne_null_si_le_json_est_invalide():
	_ecrire_texte_brut(FICHIER_INVALIDE, "{invalide")
	assert_eq(FichiersJsonService.read_json_file(FICHIER_INVALIDE), null)
