extends Control

signal accepter
signal refuser

func afficher_import(nom_joueur: String, nom_niveau: String) -> void:
	$Fond/Panel/Contenu/NomJoueur.text = "Joueur : " + nom_joueur
	$Fond/Panel/Contenu/NomNiveau.text = "Niveau : " + nom_niveau
	show()

func fermer() -> void:
	hide()

func _on_bouton_accepter_pressed() -> void:
	accepter.emit()

func _on_bouton_refuser_pressed() -> void:
	refuser.emit()
