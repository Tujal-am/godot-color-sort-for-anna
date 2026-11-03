extends GutTest

const DOSSIER := "res://Scenes/MenuPrincipal/Campagne/Statistiques/"
const SCENE_CARTE_PLATEAU = preload(DOSSIER + "carte_plateau.tscn")
const SCENE_CARTE_MODE = preload(DOSSIER + "carte_mode.tscn")
const SCENE_CARTE_CAMPAGNE = preload(DOSSIER + "carte_campagne.tscn")
const SCENE_CARTE_NIVEAU = preload(DOSSIER + "carte_niveau.tscn")
const SCENE_CARTE_SCORE = preload(DOSSIER + "carte_score.tscn")

const CHAMPS_PLATEAUX := {
	"nb_plateaux": "Nombre/Valeur",
	"nb_essais": "Essais/Valeur",
	"temps_moyen": "TempsMoyen/Valeur",
	"taux_reussite": "Reussite/Valeur",
	"plus_rapide_temps": "Tableau/PlusRapide/Temps",
	"plus_rapide_difficulte": "Tableau/PlusRapide/Difficulte",
	"plus_lent_temps": "Tableau/PlusLent/Temps",
	"plus_lent_difficulte": "Tableau/PlusLent/Difficulte",
	"plus_galere_essais": "Tableau/PlusGalere/Essais",
	"plus_galere_difficulte": "Tableau/PlusGalere/Difficulte"
}

const CHAMPS_CAMPAGNE := {
	"completion": "Completion/Valeur",
	"temps": "Temps/Valeur",
	"serie_max": "SerieMax/Valeur",
	"reussite": "Reussite/Valeur"
}

const CHAMPS_NIVEAU := {
	"en_cours": "EnCours/Valeur",
	"completion": "Completion/Valeur",
	"taux_reussite_minimum": "Tableau/ReussiteMinimum/Pourcent",
	"difficulte_reussite_minimum": "Tableau/ReussiteMinimum/Difficulte",
	"taux_reussite_maximum": "Tableau/ReussiteMaximum/Pourcent",
	"difficulte_reussite_maximum": "Tableau/ReussiteMaximum/Difficulte"
}

const CHAMPS_SCORE := {
	"nom_grade": "GradeIdentite/NomGrade",
	"nom_joueur": "GradeIdentite/PlayerName",
	"score": "Score/Valeur",
	"rapidite": "Rapidite/Valeur",
	"reussite": "Reussite/Valeur",
	"niveau": "Niveau/Valeur",
	"parfait": "Parfait/Valeur",
	"campagne": "Campagne/Valeur"
}

func _verifier_champs_independants(carte: Control, champs: Dictionary) -> void:
	for methode in champs:
		carte.call(methode, "v_" + methode)

	for methode in champs:
		assert_eq(carte.get_node(champs[methode]).text, "v_" + methode, methode)

func test_carte_plateau_ecrit_chaque_champ_dans_son_propre_libelle() -> void:
	_verifier_champs_independants(add_child_autofree(SCENE_CARTE_PLATEAU.instantiate()), CHAMPS_PLATEAUX)

func test_carte_mode_ecrit_chaque_champ_dans_son_propre_libelle() -> void:
	_verifier_champs_independants(add_child_autofree(SCENE_CARTE_MODE.instantiate()), CHAMPS_PLATEAUX)

func test_carte_campagne_ecrit_chaque_champ_dans_son_propre_libelle() -> void:
	_verifier_champs_independants(add_child_autofree(SCENE_CARTE_CAMPAGNE.instantiate()), CHAMPS_CAMPAGNE)

func test_carte_niveau_ecrit_chaque_champ_dans_son_propre_libelle() -> void:
	_verifier_champs_independants(add_child_autofree(SCENE_CARTE_NIVEAU.instantiate()), CHAMPS_NIVEAU)

func test_carte_score_ecrit_chaque_champ_dans_son_propre_libelle() -> void:
	_verifier_champs_independants(add_child_autofree(SCENE_CARTE_SCORE.instantiate()), CHAMPS_SCORE)

func test_carte_plateau_et_carte_mode_remplacent_une_valeur_deja_ecrite() -> void:
	for scene in [SCENE_CARTE_PLATEAU, SCENE_CARTE_MODE]:
		var carte: Control = add_child_autofree(scene.instantiate())

		carte.nb_essais("12")
		carte.nb_essais("0")
		carte.nb_plateaux("7")
		carte.nb_plateaux("")

		assert_eq(carte.get_node("Essais/Valeur").text, "0")
		assert_eq(carte.get_node("Nombre/Valeur").text, "")

func test_carte_mode_a_le_titre_mode_par_defaut() -> void:
	var carte: Control = add_child_autofree(SCENE_CARTE_MODE.instantiate())

	assert_eq(carte.get_node("Titre").text, "Mode")

func test_carte_mode_applique_le_titre_exporte_defini_avant_ready() -> void:
	var carte: Control = SCENE_CARTE_MODE.instantiate()
	carte._titre = "Qui perd gagne"
	add_child_autofree(carte)

	assert_eq(carte.get_node("Titre").text, "Qui perd gagne")

func test_carte_mode_met_a_jour_le_titre_quand_la_propriete_change_apres_ready() -> void:
	var carte: Control = add_child_autofree(SCENE_CARTE_MODE.instantiate())

	carte._titre = "Classique"

	assert_eq(carte.get_node("Titre").text, "Classique")
	assert_eq(carte._titre, "Classique")

func test_carte_plateau_et_carte_mode_ne_partagent_pas_leurs_valeurs() -> void:
	var carte_plateau: Control = add_child_autofree(SCENE_CARTE_PLATEAU.instantiate())
	var carte_mode: Control = add_child_autofree(SCENE_CARTE_MODE.instantiate())

	carte_plateau.nb_essais("5")

	assert_eq(carte_plateau.get_node("Essais/Valeur").text, "5")
	assert_ne(carte_mode.get_node("Essais/Valeur").text, "5")

func test_carte_score_associe_une_medaille_distincte_a_chaque_grade() -> void:
	var carte: Control = add_child_autofree(SCENE_CARTE_SCORE.instantiate())
	var textures := {}

	for grade in ["bronze", "argent", "or", "diamant"]:
		carte.medaille(grade)
		var texture: Texture2D = carte.get_node("GradeIdentite/Medaille").texture
		assert_not_null(texture, grade)
		textures[texture.resource_path] = grade

	assert_eq(textures.size(), 4)
