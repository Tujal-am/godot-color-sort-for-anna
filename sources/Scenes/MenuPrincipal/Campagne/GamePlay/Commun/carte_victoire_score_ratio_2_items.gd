extends Control

@export var _titre: String = "Titre Score":
	set(texte):
		_titre = texte
		# Si le nœud est prêt dans l'arbre, on met à jour le Label
		if is_inside_tree():
			$Titre.text = texte

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	titre(_titre)

func titre(texte : String) -> void:
	_titre = texte

func item1(texte : String) -> void:
	$ListeItems/Item1/Texte.text = texte
	var percent : float = texte.lstrip('Réalisé : ').rstrip('%').to_float()
	$MarginContainer/ArcProgressBar.percentage = percent

func item2(texte : String) -> void:
	$ListeItems/Item2/Texte.text = texte
