extends Control

class_name PartagePerformancesUI

const ADRESSE_COURRIEL_PARTAGE := "rangelescouleurspouranna@gmail.com"

signal fermer

var _donnees_a_partager: Dictionary = {}

func _ready() -> void:
	if not ShareService.share_failed.is_connected(_on_partage_echoue):
		ShareService.share_failed.connect(_on_partage_echoue)
	if not ShareService.share_canceled.is_connected(_on_partage_annule):
		ShareService.share_canceled.connect(_on_partage_annule)
	$Panneau/Contenu/BoutonPartagerFichier.visible = OS.has_feature("android")
	$Panneau/Contenu/BoutonPartagerFichier.disabled = not ShareService.is_available()

## Présente les noms associés à la dernière campagne terminée.
func afficher_export(donnees: Dictionary) -> void:
	_donnees_a_partager = donnees.duplicate(true)
	var campagne: Dictionary = donnees.get("campagne", {})
	var nom_joueur := str(donnees.get("joueur", "inconnue"))
	var nom_campagne := SauvegardeBddJoueursService.enregistrement_campagne_lire_nom_derniere_campagne().capitalize()
	var nom_niveau := SauvegardeBddJoueursService.enregistrement_campagne_lire_nom_dernier_niveau().capitalize()
	if campagne.is_empty():
		nom_campagne = "Inconnue"
	if nom_niveau.is_empty():
		nom_niveau = "Inconnu"

	$Panneau/Contenu/NomJoueur.text = "Joueur : " + nom_joueur
	$Panneau/Contenu/NomCampagne.text = "Campagne : " + nom_campagne
	$Panneau/Contenu/NomNiveau.text = "Dernier niveau : " + nom_niveau
	$Panneau/Contenu/AdresseCourriel.text = ADRESSE_COURRIEL_PARTAGE
	$Panneau/Contenu/Message.visible = false
	$Panneau/Contenu/BoutonPartagerFichier.disabled = not ShareService.is_available()
	show()

func _on_bouton_copier_courriel_pressed() -> void:
	if not DisplayServer.has_feature(DisplayServer.FEATURE_CLIPBOARD):
		_afficher_message("La copie dans le presse-papiers n'est pas disponible.")
		return
	DisplayServer.clipboard_set(ADRESSE_COURRIEL_PARTAGE)
	_afficher_message("Adresse courriel copiée dans le presse-papiers.")

func _on_bouton_partager_fichier_pressed() -> void:
	if not ShareService.is_available():
		_afficher_message("Le partage natif Android n'est pas disponible.")
		return
	$Panneau/Contenu/BoutonPartagerFichier.disabled = true
	var resultat: Dictionary = $PartagePerformancesAPI.partager_campagne(
		ShareService,
		_donnees_a_partager
	)
	if not resultat.get("succes", false):
		_afficher_message(resultat.get("erreur", "Impossible de partager le fichier JSON."))
	$Panneau/Contenu/BoutonPartagerFichier.disabled = not ShareService.is_available()

func _on_bouton_retour_statistiques_pressed() -> void:
	hide()
	fermer.emit()

func _on_partage_echoue(message: String) -> void:
	_afficher_message("Le partage du fichier a échoué : %s" % message)

func _on_partage_annule() -> void:
	$Panneau/Contenu/BoutonPartagerFichier.disabled = not ShareService.is_available()

func _afficher_message(message: String) -> void:
	$Panneau/Contenu/Message.text = message
	$Panneau/Contenu/Message.visible = true
