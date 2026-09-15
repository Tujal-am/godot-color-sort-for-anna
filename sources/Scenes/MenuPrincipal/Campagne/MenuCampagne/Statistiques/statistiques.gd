extends Control

const GradePresentationScript = preload("res://Scenes/MenuPrincipal/Grades/grade_presentation.gd")
const UNAVAILABLE := "—"

func _ready() -> void:
	$Scroll/Content/Retour.pressed.connect(_on_retour_pressed)
	_actualiser_grade()
	_remplir_reels()


func _actualiser_grade() -> void:
	var player_name := StatsService.campagne_nom_joueur()
	var grade := GradePresentationScript.for_player(player_name)
	var avatar := $Scroll/Content/PlayerIdentityRow/Avatar
	avatar.texture = load(str(GradePresentationScript.texture_path_for_stats_player(player_name)))
	_val("Scroll/Content/PlayerIdentityRow/GradeName", grade.get("name", "Bronze"))
	$Scroll/Content/PlayerIdentityRow/GradeName.add_theme_color_override("font_color", GradePresentationScript.color_for_player(player_name))

func _on_retour_pressed() -> void:
	AudioService.son_menu_click()
	if SauvegardeBddJoueursService.campagne_la_campagne_est_terminee():
		get_tree().change_scene_to_file("res://Scenes/MenuPrincipal/menu_principal.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/MenuPrincipal/Campagne/campagne.tscn")

func _val(path: String, value: Variant = UNAVAILABLE) -> void:
	var n := get_node_or_null(NodePath(path)) as Label
	if n:
		n.text = UNAVAILABLE if value == null or str(value).is_empty() else str(value)

func _set_mode(card: Control, title: String, data: Dictionary) -> void:
	card.get_node("ModeTitle").text = title
	for i in 3:
		card.get_node("KpiValue%d" % i).text = str(data.get("kpi%d" % i, UNAVAILABLE))
	for row in 3:
		for col in 4:
			card.get_node("TableR%dC%d" % [row, col]).text = str(data.get("r%d_c%d" % [row, col], UNAVAILABLE))

func _remplir_reels() -> void:
	# Every dynamic field starts as an explicit unavailable marker. This keeps
	# no-data profiles honest while allowing the real StatsService values below.
	for path in [
		"CompletionValue", "TimeValue", "SuccessValue", "StreakValue",
		"CurrentLevelValue", "LevelCompletionValue", "LevelR0C1", "LevelR0C2",
		"LevelR1C1", "LevelR1C2", "MeanTimeValue", "BoardR0C1", "BoardR0C2",
		"BoardR1C1", "BoardR1C2", "BoardR2C1", "BoardR2C2"]:
		_val("Scroll/Content/" + path, UNAVAILABLE)
	_val("Scroll/Content/PlayerIdentityRow/PlayerName", StatsService.campagne_nom_joueur())
	var total := StatsService.nombre_de_plateaux_totaux()
	if total <= 0:
		_set_mode($Scroll/Content/Classique, "Classique", {})
		_set_mode($Scroll/Content/QuiPerdGagne, "Qui perd gagne", {})
		return

	_val("Scroll/Content/CompletionValue", str_arrondir_pourcentage(StatsService.campagne_taux_completion()))
	_val("Scroll/Content/TimeValue", str_arrondir_temps_en_s(StatsService.campagne_temps_total_en_s()))
	_val("Scroll/Content/SuccessValue", str_arrondir_pourcentage(StatsService.campagne_taux_reussite()))
	_val("Scroll/Content/StreakValue", StatsService.campagne_serie_max_reussite())
	_val("Scroll/Content/CurrentLevelValue", StatsService.niveau_longueur_max())
	_val("Scroll/Content/LevelCompletionValue", str_arrondir_pourcentage(StatsService.niveau_taux_completion()))
	_val("Scroll/Content/MeanTimeValue", str_arrondir_temps_en_s(StatsService.plateau_temps_moyen_en_s()))

	var level_infos := StatsService.niveau_taux_reussite_infos()
	_val("Scroll/Content/LevelR0C1", str_arrondir_pourcentage(level_infos.get("taux_max", 0.0)))
	_val("Scroll/Content/LevelR0C2", level_infos.get("taux_max_lg", UNAVAILABLE))
	_val("Scroll/Content/LevelR1C1", str_arrondir_pourcentage(level_infos.get("taux_min", 0.0)))
	_val("Scroll/Content/LevelR1C2", level_infos.get("taux_min_lg", UNAVAILABLE))

	var fast := StatsService.plateau_plus_rapide_infos()
	var slow := StatsService.plateau_plus_lent_infos()
	var hard := StatsService.plateau_plus_galere_infos()
	_val("Scroll/Content/BoardR0C1", str_arrondir_temps_en_s(fast.get("temps_en_s", 0.0)))
	_val("Scroll/Content/BoardR0C2", fast.get("difficulte", UNAVAILABLE))
	_val("Scroll/Content/BoardR1C1", str_arrondir_temps_en_s(slow.get("temps_en_s", 0.0)))
	_val("Scroll/Content/BoardR1C2", slow.get("difficulte", UNAVAILABLE))
	_val("Scroll/Content/BoardR2C1", hard.get("essais", UNAVAILABLE))
	_val("Scroll/Content/BoardR2C2", hard.get("difficulte", UNAVAILABLE))

	# StatsService currently exposes aggregate data only; keep the two mode cards
	# distinct and explicit until dedicated per-mode accessors are available.
	_set_mode($Scroll/Content/Classique, "Classique", {})
	_set_mode($Scroll/Content/QuiPerdGagne, "Qui perd gagne", {})

func str_arrondir_pourcentage(pourcentage: float) -> String:
	var p := 100.0 * pourcentage
	if p < 1.0: return str(round(p * 100.0) / 100.0) + "%"
	if p < 10.0: return str(round(p * 10.0) / 10.0) + "%"
	return str(roundi(p)) + "%"

func str_arrondir_temps_en_s(temps: float) -> String:
	if temps < 1.0: return str(roundi(temps * 1000.0)) + "ms"
	if temps < 10.0: return str(roundi(temps * 10.0) / 10.0) + "s"
	if temps < 3600.0: return str(floori(temps / 60.0)) + "min " + str(roundi(fmod(temps, 60.0))) + "s"
	return str(floori(temps / 3600.0)) + "h " + str(floori(fmod(temps, 3600.0) / 60.0)) + "min"
