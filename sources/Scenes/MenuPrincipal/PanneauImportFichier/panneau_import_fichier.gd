extends Control

signal accepter
signal refuser

func afficher_import(nom_joueur: String, nom_campagne: String, nom_niveau: String) -> void:
	$Fond/Panel/Contenu/NomJoueur.text = "Joueur : " + nom_joueur
	$Fond/Panel/Contenu/NomCampagne.text = "Campagne : " + nom_campagne
	$Fond/Panel/Contenu/NomNiveau.text = "Niveau : " + nom_niveau
	show()

func fermer() -> void:
	hide()

func _on_bouton_accepter_pressed() -> void:
	LogService.log_debug("[panneau_import_fichier] emission signal : accepter")
	accepter.emit()

func _on_bouton_refuser_pressed() -> void:
	LogService.log_debug("[panneau_import_fichier] emission signal : refuser")
	refuser.emit()
