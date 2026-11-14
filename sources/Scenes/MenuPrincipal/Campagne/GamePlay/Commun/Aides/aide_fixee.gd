extends CanvasLayer

signal fermee

const SURFACE_SIZE := Vector2(480, 720)
const FONT := preload("res://Art/UI/Fonts/TeXGyreAdventor/texgyreadventor-regular.otf")
const BOLD := preload("res://Art/UI/Fonts/TeXGyreAdventor/texgyreadventor-bold.otf")
const RECOMMENCER := preload("res://Art/UI/Gameplay/Classique/button_restart.png")

@export var qpg := false

var _zone: Control
var _compris: Button
var _chaque: CheckBox
var _premiere: CheckBox


func _ready() -> void:
	visible = false
	_zone = $Surface/Zone
	$Surface.resized.connect(_ajuster_zone)
	_construire()
	_ajuster_zone()


func ouvrir(preference: String) -> void:
	_chaque.set_pressed_no_signal(preference == "chaque_entree")
	_premiere.set_pressed_no_signal(preference == "premiere_fois")
	show()
	_compris.grab_focus()


func choix() -> String:
	if _chaque.button_pressed:
		return "chaque_entree"
	if _premiere.button_pressed:
		return "premiere_fois"
	return ""


func _ajuster_zone() -> void:
	var espace: Vector2 = $Surface.size
	var ratio := minf(espace.x / SURFACE_SIZE.x, espace.y / SURFACE_SIZE.y)
	_zone.scale = Vector2.ONE * ratio
	_zone.position = (espace - SURFACE_SIZE * ratio) / 2.0


func _construire() -> void:
	var encre := Color("#fff5ff") if qpg else Color("#081954")
	var accent := Color("#ff83eb") if qpg else Color("#a81b08")
	var aigu := Color("#38f5ff") if qpg else Color("#009bbe")
	var fond := Color("#170636") if qpg else Color("#fff0df")
	var contour := Color("#f784ff") if qpg else Color("#fff9ef")
	var mode := "QuiPerdGagne" if qpg else "Classique"
	var assets := "res://Art/UI/Gameplay/" + mode + "/"
	var cle := "qpg" if qpg else "classique"
	var aire := Rect2(29, 66, 418, 562) if qpg else Rect2(62, 5, 354, 643)

	_image("Fond", Rect2(Vector2.ZERO, SURFACE_SIZE), load(assets + "background.png"))
	_panneau(aire, fond, contour, 25, 2, Color("#bd36fa") if qpg else Color("#d47a40"))
	if qpg:
		_panneau(Rect2(154, 47, 172, 37), Color("#200240"), contour, 18, 2, Color("#c441ff"))
		_texte("Bloque le jeu", Rect2(154, 48, 172, 31), 19, aigu, true)
		_image("Diablotin", Rect2(70, 79, 57, 57), load(assets + "devil.png"))
		_texte("Comment jouer ?", Rect2(121, 78, 310, 40), 30, encre, true)
		_texte("Voici l’essentiel.", Rect2(83, 111, 315, 25), 19, aigu, true)
		_texte("Touche la colonne de départ, puis celle d’arrivée.", Rect2(43, 134, 394, 24), 14, encre)
	else:
		_panneau(Rect2(150, 13, 180, 25), Color("#ffe0bd"), Color("#df9a66"), 13, 1)
		_texte("RANGE TES COULEURS", Rect2(150, 12, 180, 27), 14, accent, true)
		_texte("Comment jouer ?", Rect2(67, 36, 346, 41), 30, encre, true)
		_texte("Voici l’essentiel.", Rect2(72, 69, 336, 26), 17, aigu)
		_texte("Deux jetons de même couleur au sommet ?\nIls voyagent ensemble.", Rect2(68, 98, 344, 37), 15, encre, true)
		_texte("Touche la colonne de départ, puis celle d’arrivée.", Rect2(72, 135, 336, 22), 13, encre)

	var rectangle_schema := Rect2(49, 161, 379, 124) if qpg else Rect2(75, 160, 330, 132)
	if qpg:
		_panneau(Rect2(48, 161, 380, 157), Color("#200442"), contour, 20, 1)
	_image("Schema", rectangle_schema, load("res://Art/UI/Gameplay/Aides/schema_" + cle + ".png"))
	if qpg:
		_texte("Après ce coup, aucune colonne n’est vide et aucun sommet\nn’accepte un nouveau groupe. Le jeu est bloqué : tu gagnes.", Rect2(53, 280, 374, 31), 12, encre)
	else:
		_texte("Déplace tout le groupe vers une colonne vide ou une\ncolonne dont le sommet est de la même couleur,\nà condition qu’il y ait assez de place.", Rect2(69, 294, 342, 48), 12, encre)

	var y_gagner := 316 if qpg else 343
	var y_commandes := 376 if qpg else 400
	var y_choix := 508 if qpg else 534
	_titre_section("Pour gagner", y_gagner, accent, aire, 122)
	var regle := ("Il suffit d’empêcher les empilements parfaits\nafin de bloquer le jeu." if qpg
		else "Chaque colonne utilisée doit être complète et d’une seule\ncouleur. Il est possible de laisser une colonne totalement vide.")
	_texte(regle, Rect2(aire.position.x + 8, y_gagner + 22, aire.size.x - 16, 32), 13 if qpg else 11, encre)
	_titre_section("Les commandes", y_commandes, accent, aire, 151)
	var libelles := ["Jouer", "Recommencer", "Passer"]
	var descriptions := ["Lance le plateau et le chrono.", "Relance ce plateau à zéro.",
		"Va au plateau suivant. Le plateau\nquitté est considéré comme perdu."]
	var textures: Array[Texture2D] = [load(assets + "button_play.svg"), RECOMMENCER,
		load(assets + "button_pass.svg")]
	var gauche := 68 if qpg else 88
	var largeur_titre := [43, 108, 51] if qpg else [43, 98, 51]
	for index in range(libelles.size()):
		var y := y_commandes + 25 + index * 35
		_image(libelles[index], Rect2(gauche, y, 36, 32), textures[index])
		var x := gauche + 54
		_texte(libelles[index], Rect2(x, y - 1, largeur_titre[index], 26), 14 if qpg else 13, encre, true, false)
		_texte("— " + descriptions[index], Rect2(x + largeur_titre[index], y + 2, 0, 26), 13 if qpg else 11, encre, false, false)

	_titre_section("Afficher cette aide", y_choix, accent, aire, 168)
	_chaque = _case("À chaque entrée", Vector2(57, y_choix + 24) if qpg else Vector2(82, y_choix + 24), encre, contour if qpg else accent)
	_premiere = _case("La première fois uniquement", Vector2(217, y_choix + 24) if qpg else Vector2(222, y_choix + 24), encre, contour if qpg else accent)
	var groupe := ButtonGroup.new()
	groupe.allow_unpress = true
	_chaque.button_group = groupe
	_premiere.button_group = groupe

	_compris = Button.new()
	_compris.name = "Compris"
	_compris.text = "Compris"
	_compris.add_theme_font_override("font", BOLD)
	_compris.add_theme_font_size_override("font_size", 22 if qpg else 19)
	_compris.add_theme_stylebox_override("normal", _style_compris(contour, accent))
	_compris.add_theme_stylebox_override("hover", _style(Color("#ed1495") if qpg else Color("#dc3d27"), contour, 22, 2, accent))
	_compris.add_theme_stylebox_override("pressed", _style(Color("#a8006f") if qpg else Color("#9a130a"), contour, 22, 2))
	var focus := _style(Color.TRANSPARENT, Color("#f8a5fb") if qpg else Color("#ffc098"), 22, 1)
	focus.draw_center = false
	_compris.add_theme_stylebox_override("focus", focus)
	_compris.pressed.connect(func(): fermee.emit())
	_placer(_compris, Rect2(124, 565, 220, 48) if qpg else Rect2(147, 592, 184, 40))


func _placer(noeud: Control, rectangle: Rect2) -> void:
	_zone.add_child(noeud)
	noeud.position = rectangle.position
	noeud.size = rectangle.size


func _texte(texte: String, rectangle: Rect2, taille: int, couleur: Color, gras := false, centre := true) -> void:
	var label := Label.new()
	label.text = texte
	label.add_theme_font_override("font", BOLD if gras else FONT)
	label.add_theme_font_size_override("font_size", taille)
	label.add_theme_color_override("font_color", couleur)
	label.add_theme_constant_override("line_spacing", -1)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if centre:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_placer(label, rectangle)


func _image(nom: String, rectangle: Rect2, texture: Texture2D) -> void:
	var image := TextureRect.new()
	image.name = nom
	image.texture = texture
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_placer(image, rectangle)


func _titre_section(texte: String, y: float, couleur: Color, aire: Rect2, largeur: float) -> void:
	var bord := aire.position.x + 20.0
	var gauche := (480.0 - largeur) / 2.0
	var droite := gauche + largeur
	for ligne in [Rect2(bord, y + 15, gauche - bord, 1), Rect2(droite, y + 15, aire.end.x - 16 - droite, 1)]:
		var filet := ColorRect.new()
		filet.color = couleur
		filet.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_placer(filet, ligne)
	_texte(texte, Rect2(gauche, y, largeur, 27), 18 if qpg else 17, couleur, true)


func _panneau(rectangle: Rect2, fond: Color, bord: Color, rayon: int, epaisseur: int, lueur := Color.TRANSPARENT) -> void:
	var panneau := Panel.new()
	panneau.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panneau.add_theme_stylebox_override("panel", _style(fond, bord, rayon, epaisseur, lueur))
	_placer(panneau, rectangle)


func _style(fond: Color, bord: Color, rayon: int, epaisseur: int, lueur := Color.TRANSPARENT) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fond
	style.border_color = bord
	style.set_border_width_all(epaisseur)
	style.set_corner_radius_all(rayon)
	if lueur.a > 0:
		style.shadow_color = Color(lueur, 0.64)
		style.shadow_size = 8
	return style


func _style_compris(contour: Color, accent: Color) -> StyleBoxTexture:
	var largeur := 220 if qpg else 184
	var hauteur := 48 if qpg else 40
	var image := Image.create_empty(largeur, hauteur, false, Image.FORMAT_RGBA8)
	var haut := Color("#ff25cf") if qpg else Color("#ff6141")
	var bas := Color("#7e004a") if qpg else Color("#951700")
	var rayon := hauteur / 2.0
	for y in range(hauteur):
		for x in range(largeur):
			var point := Vector2(x + 0.5, y + 0.5)
			var centre := Vector2(clampf(point.x, rayon, largeur - rayon), rayon)
			var distance := point.distance_to(centre)
			if distance <= rayon:
				var couleur := haut.lerp(bas, point.y / hauteur)
				if distance > rayon - 1.5:
					couleur = contour.lerp(accent, 0.15)
				couleur.a = clampf(rayon - distance, 0.0, 1.0)
				image.set_pixel(x, y, couleur)
	var style := StyleBoxTexture.new()
	style.texture = ImageTexture.create_from_image(image)
	return style


func _case(texte: String, origine: Vector2, encre: Color, contour: Color) -> CheckBox:
	var option := CheckBox.new()
	option.text = texte
	option.add_theme_font_override("font", FONT)
	option.add_theme_font_size_override("font_size", 13 if qpg else 12)
	option.add_theme_color_override("font_color", encre)
	option.add_theme_color_override("font_hover_color", encre)
	option.add_theme_color_override("font_pressed_color", encre)
	option.add_theme_color_override("font_focus_color", encre)
	var vide := _icone_case(contour, false)
	var coche := _icone_case(contour, true)
	option.add_theme_icon_override("unchecked", vide)
	option.add_theme_icon_override("checked", coche)
	option.add_theme_icon_override("radio_unchecked", vide)
	option.add_theme_icon_override("radio_checked", coche)
	_placer(option, Rect2(origine, Vector2(0, 24)))
	return option


func _icone_case(couleur: Color, coche: bool) -> Texture2D:
	var image := Image.create_empty(17, 17, false, Image.FORMAT_RGBA8)
	image.fill_rect(Rect2i(1, 1, 15, 15), couleur)
	image.fill_rect(Rect2i(3, 3, 11, 11), Color.TRANSPARENT)
	if coche:
		image.fill_rect(Rect2i(5, 5, 7, 7), couleur)
	return ImageTexture.create_from_image(image)
