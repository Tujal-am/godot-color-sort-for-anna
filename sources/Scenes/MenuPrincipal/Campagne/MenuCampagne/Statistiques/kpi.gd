extends Control

@export var titre := "Titre"
@export var valeur := 0
@export var couleur_texte := Color("WHITE")
@export var couleur_fond := Color("DEEP PINK")
@export var taille_minimum := Vector2(140, 50)

func _ready():
	clip_contents = true
	$VBox/Label_Title.text = titre
	$VBox/Label_Value.text = str(valeur)
	set_color(couleur_texte, couleur_fond)
	set_minimum_size(taille_minimum)

func set_title(title: String):
	$VBox/Label_Title.text = title

func set_value(v):
	$VBox/Label_Value.text = str(v)

func set_color(texte : Color , fond : Color):
	$VBox/Label_Title.add_theme_color_override("font_color", texte)
	$VBox/Label_Value.add_theme_color_override("font_color", texte)
	$Fond.color = fond

func set_minimum_size(new_size: Vector2):
	taille_minimum = new_size
	set_custom_minimum_size(taille_minimum) 
	$Fond.set_custom_minimum_size(taille_minimum) 
	$VBox.set_custom_minimum_size(taille_minimum) 
