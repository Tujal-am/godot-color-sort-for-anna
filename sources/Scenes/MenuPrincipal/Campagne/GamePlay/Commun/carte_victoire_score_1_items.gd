extends Control

@export var _titre: String = "Titre Score":
	set(texte):
		_titre = texte
		# Si le nœud est prêt dans l'arbre, on met à jour le Label
		if is_inside_tree():
			$Titre.text = texte

@export_file("victoire_*.png") var _chemin_logo: String = "res://Art/UI/Gameplay/Commun/victoire_temps.png":
	set(chemin):
		_chemin_logo = chemin
		# Si le nœud est prêt dans l'arbre, on met à jour le Label
		if is_inside_tree():
			$MarginContainer/Logo.texture = load(_chemin_logo)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	titre(_titre)
	logo(_chemin_logo)

func logo(chemin_logo : String) -> void:
	_chemin_logo = chemin_logo
	$MarginContainer/Logo.texture = load(chemin_logo)

func titre(texte : String) -> void:
	_titre = texte

func item1(texte : String) -> void:
	$ListeItems/Item1/Texte.text = texte
