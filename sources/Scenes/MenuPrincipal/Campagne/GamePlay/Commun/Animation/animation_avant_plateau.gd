extends Control

const CUBES := preload("res://Scenes/MenuPrincipal/Campagne/GamePlay/Commun/Animation/cubes_ambiance.png")
const COULEURS := preload("res://Scenes/MenuPrincipal/Campagne/GamePlay/Commun/Animation/cubes_classique.png")
const DIABLOTIN := preload("res://Art/UI/Gameplay/QuiPerdGagne/devil.png")
const POLICE := preload("res://Art/UI/Fonts/TeXGyreAdventor/texgyreadventor-bold.otf")
const DUREE_BOUCLE := 5.0
const CENTRES_QPG := [
	Vector2(105, 386), Vector2(163, 440), Vector2(101, 505),
	Vector2(240, 505), Vector2(317, 440), Vector2(379, 505), Vector2(375, 386)
]
const INDICES_QPG := [2, 3, 5, 6, 4, 8, 7]
const CENTRES_CLASSIQUE := [
	Vector2(116, 290), Vector2(147, 394), Vector2(345, 284),
	Vector2(367, 388), Vector2(301, 477)
]
const DEPARTS_B := [Vector2(174, 482), Vector2(310, 348), Vector2(219, 230)]
const LETTRES := ["A", "", "D", "E", "F"]
const INDICES_CLASSIQUE := [0, 1, 1, 2, 3]

@export var qpg := false

var _tween: Tween
var _phase := 0.0
var _empilement_termine := false


func lancer() -> void:
	arreter()
	_empilement_termine = false
	_actualiser(0.0)
	show()
	_tween = create_tween().set_loops()
	_tween.tween_method(_actualiser, 0.0, TAU, DUREE_BOUCLE)
	_tween.tween_callback(_achever_empilement)


func arreter() -> void:
	if _tween != null:
		_tween.kill()
		_tween = null
	hide()


func _achever_empilement() -> void:
	_empilement_termine = true


func _placement_b(rang: int) -> float:
	if _empilement_termine:
		return 1.0
	return smoothstep(0.14 + 0.10 * rang, 0.35 + 0.10 * rang, _phase / TAU)


func _actualiser(phase: float) -> void:
	_phase = phase
	queue_redraw()


func _draw() -> void:
	if qpg:
		_dessiner_qpg()
	else:
		_dessiner_classique()


func _dessiner_classique() -> void:
	var colonne := Vector2(243, 426)
	for rang in range(DEPARTS_B.size()):
		var placement := _placement_b(rang)
		var onde := _phase - rang * 0.8
		var depart: Vector2 = DEPARTS_B[rang] + Vector2(5 * cos(onde), -8 * sin(onde))
		var centre := depart.lerp(colonne - Vector2(0, 50 * rang), placement)
		centre.y -= 16 * sin(PI * placement)
		_cube(CUBES, 0, centre, 1.0, 0.12 * sin(onde) * (1.0 - placement), Color.WHITE)
	for i in range(CENTRES_CLASSIQUE.size()):
		var onde := _phase - i * 0.8
		var centre: Vector2 = CENTRES_CLASSIQUE[i] + Vector2(8 * cos(onde), -13 * sin(onde))
		var lettre: String = LETTRES[i]
		var texture := CUBES if lettre.is_empty() else COULEURS
		var indice: int = INDICES_CLASSIQUE[i]
		_cube(texture, indice, centre, 0.90, 0.13 * sin(onde), Color.WHITE, lettre)


func _dessiner_qpg() -> void:
	var temps := _phase / TAU
	var approche := smoothstep(0.04, 0.91, temps)
	var opacite := smoothstep(0.0, 0.08, temps) * (1.0 - smoothstep(0.87, 0.98, temps))
	var diablotin := Vector2(205, 189).lerp(Vector2(241, 278), approche)
	for i in range(CENTRES_QPG.size()):
		var position_cube: Vector2 = CENTRES_QPG[i]
		var direction := (position_cube - Vector2(240, 299)).normalized()
		var distance := position_cube.distance_to(Vector2(240, 365))
		var impact := 0.52 + distance / 1100.0
		var anticipation := smoothstep(impact - 0.09, impact - 0.035, temps) * (1.0 - smoothstep(impact - 0.035, impact, temps))
		var rebond := smoothstep(impact, impact + 0.065, temps) * (1.0 - smoothstep(impact + 0.065, impact + 0.23, temps))
		var onde := _phase - i * 0.75
		var centre := position_cube + Vector2(4 * sin(onde), -7 * sin(onde))
		centre += direction * (31 * rebond - 8 * anticipation) - Vector2(0, 13 * rebond)
		_cube(CUBES, INDICES_QPG[i], centre, 0.90 + 0.08 * rebond - 0.06 * anticipation,
			0.10 * sin(onde) + direction.x * 0.28 * rebond, Color.WHITE)
	draw_set_transform(diablotin, -0.11 * approche)
	var taille := lerpf(66.0, 266.0, approche) + 60.0 * smoothstep(0.52, 0.94, approche)
	draw_texture_rect(DIABLOTIN, Rect2(Vector2.ONE * -taille / 2, Vector2.ONE * taille), false, Color(1, 1, 1, opacite))
	draw_set_transform(Vector2.ZERO)


func _cube(texture: Texture2D, indice: int, centre: Vector2, echelle: float,
		angle: float, teinte: Color, lettre := "") -> void:
	var taille := Vector2(58, 53) * echelle
	var region := Rect2(indice * 106 + 5, 12, 96, 88)
	draw_set_transform(centre, angle)
	draw_texture_rect_region(texture, Rect2(-taille / 2, taille), region, teinte)
	if not lettre.is_empty():
		var corps := roundi(26 * echelle)
		var largeur := POLICE.get_string_size(lettre, HORIZONTAL_ALIGNMENT_LEFT, -1, corps).x
		draw_string(POLICE, Vector2(-largeur / 2.0, 9), lettre, HORIZONTAL_ALIGNMENT_LEFT, -1, corps)
	draw_set_transform(Vector2.ZERO)
