extends Control

@export var titre: String = "Mode":
	set(text):
		titre = text
		# Si le nœud est prêt dans l'arbre, on met à jour le Label
		if is_inside_tree():
			$Titre.text = text

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Titre.text = titre

func nb_plateaux(valeur : String) -> void:
	$Plateaux/Valeur.text = valeur

func temps_moyen(valeur : String) -> void:
	$TempsMoyen/Valeur.text = valeur

func taux_reussite(valeur : String) -> void:
	$Reussite/Valeur.text = valeur

func plus_rapide_temps(valeur : String) -> void:
	$Tableau/PlusRapide/Temps.text = valeur

func plus_rapide_difficulte(valeur : String) -> void:
	$Tableau/PlusRapide/Difficulte.text = valeur

func plus_lent_temps(valeur : String) -> void:
	$Tableau/PlusLent/Temps.text = valeur

func plus_lent_difficulte(valeur : String) -> void:
	$Tableau/PlusLent/Difficulte.text = valeur

func plus_galere_essais(valeur : String) -> void:
	$Tableau/PlusGalere/Essais.text = valeur

func plus_galere_difficulte(valeur : String) -> void:
	$Tableau/PlusGalere/Difficulte.text = valeur
