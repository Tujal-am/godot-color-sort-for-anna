extends Node

class_name MenuPlateau

# Banbeau en jeu
signal abandon
signal passe
signal deselection_pile

# Bandeau du menu
# Notifie la scene `campagne` que le bouton est pressé
signal commencer_plateau

@export var scene_aide: PackedScene
@export var mode_aide := ""

var _aide: CanvasLayer
var _aides_vues := {}


func _ready() -> void:
	if scene_aide == null:
		return
	_aide = scene_aide.instantiate()
	add_child(_aide)
	_aide.fermee.connect(_fermer_aide)
	$BandeauMenu/BoutonAide.pressed.connect(_ouvrir_aide)


func _ouvrir_aide() -> void:
	_aide.ouvrir(SauvegardeBddJoueursService.lire_preference_aide(mode_aide))
	$BandeauMenu.hide()


func _fermer_aide() -> void:
	var choix: String = _aide.choix()
	SauvegardeBddJoueursService.enregistrer_preference_aide(mode_aide, choix)
	_aides_vues[SauvegardeBddJoueursService.fichier_sauvegarde] = true
	_aide.hide()
	$BandeauMenu.show()
	$BandeauMenu/BoutonAide.grab_focus()


func _afficher_aide_si_necessaire() -> void:
	if _aide == null:
		return
	var joueur = SauvegardeBddJoueursService.fichier_sauvegarde
	var preference := SauvegardeBddJoueursService.lire_preference_aide(mode_aide)
	if preference == "chaque_entree" or (preference.is_empty() and not _aides_vues.has(joueur)):
		_ouvrir_aide()

func _process(_delta: float) -> void:
	# Afficher le temps
	_maj_chrono()
	# Afficher le nombre de coups
	_maj_coups()

# #############
# API Gameplay
# Bandeau en jeu
func enregistrer_gameplay(gameplay : String, font_size : int = 18):
	$BandeauEnJeu/Gameplay.text = gameplay
	$BandeauEnJeu/Gameplay.add_theme_font_size_override("font_size", font_size)

func enregistrer_sous_titre_gameplay(sous_titre_gameplay : String, font_size : int = 15):
	$BandeauEnJeu/SousTitreGameplay.text = sous_titre_gameplay
	$BandeauEnJeu/SousTitreGameplay.add_theme_font_size_override("font_size", font_size)

func enregistrer_chrono(minutes : String,
						secondes : String,
						decisecondes : String):
	var text_chrono : String = minutes + ':' + secondes + '.' + decisecondes
	$BandeauEnJeu/Chrono.text = text_chrono

func enregistrer_coups(coups : String):
	$BandeauEnJeu/Coups.text = coups

# Bandeau de menu
func enregistrer_joueur(joueur : String):
	$BandeauMenu/Joueur.text = joueur

func enregistrer_niveau(niveau : String):
	$BandeauMenu/Niveau.text = niveau

func lire_niveau() -> String:
	return $BandeauMenu/Niveau.text

func enregistrer_pourcentage(pourcentage : String):
	$BandeauMenu/Pourcentage.text = pourcentage


func show_fond():
	hide()
	$Fond.show()

func show_menu():
	$Fond.show()
	show_bandeau_menu()
	hide_bandeau_en_jeu()
	_afficher_aide_si_necessaire()

func show_jeu():
	$Fond.show()
	show_bandeau_en_jeu()
	hide_bandeau_menu()

func show_bandeau_en_jeu():
	$BandeauEnJeu.show()
	$BandeauEnJeu/Fond.show()
	$BandeauEnJeu/Gameplay.show()
	$BandeauEnJeu/SousTitreGameplay.show()
	$BandeauEnJeu/Chrono.show()
	# $BandeauEnJeu/Coups.show()
	$BandeauEnJeu/BoutonRecommencer.show()
	$BandeauEnJeu/BoutonPasser.show()

func show_bandeau_menu():
	$BandeauMenu.show()
	$BandeauMenu/Fond.show()
	$BandeauMenu/Joueur.show()
	$BandeauMenu/Niveau.show()
	$BandeauMenu/Pourcentage.show()
	$BandeauMenu/BoutonMenuPrincipal.show()
	$BandeauMenu/BoutonCommencer.show()
	$BandeauMenu/BoutonStatistiques.show()

func hide():
	$Fond.hide()
	hide_bandeau_en_jeu()
	hide_bandeau_menu()

func hide_bandeau_en_jeu():
	$BandeauEnJeu.hide()
	$BandeauEnJeu/Fond.hide()
	$BandeauEnJeu/Gameplay.hide()
	$BandeauEnJeu/SousTitreGameplay.hide()
	$BandeauEnJeu/Chrono.hide()
	# $BandeauEnJeu/Coups.hide()
	$BandeauEnJeu/BoutonRecommencer.hide()
	$BandeauEnJeu/BoutonPasser.hide()

func hide_bandeau_menu():
	if _aide != null:
		_aide.hide()
	$BandeauMenu.hide()
	$BandeauMenu/Fond.hide()
	$BandeauMenu/Joueur.hide()
	$BandeauMenu/Niveau.hide()
	$BandeauMenu/Pourcentage.hide()
	$BandeauMenu/BoutonMenuPrincipal.hide()
	$BandeauMenu/BoutonCommencer.hide()
	$BandeauMenu/BoutonStatistiques.hide()

# ########
# Interne
func _maj_chrono() -> void:
	"Met à jour le temps du plateau en direct"
	var temps_ecoule_en_s : float = SauvegardeBddJoueursService.enregistrement_campagne_lire_duree_plateau()
	var minutes : int = floori(temps_ecoule_en_s / 60.)
	var secondes : int = floori(temps_ecoule_en_s - 60 * minutes)
	var decisecondes : int = roundi( (temps_ecoule_en_s - 60 * minutes - secondes) * 10.)
	# Gerer l'arrondi des decisecondes
	if decisecondes == 10:
		decisecondes = 0; secondes += 1
	if secondes == 60:
		secondes = 0; minutes += 1
	
	enregistrer_chrono(	str(minutes).pad_zeros(2),
						str(secondes).pad_zeros(2),
						str(decisecondes))

func _maj_coups() -> void:
	"Met à jour le nombre de coups du plateau en direct"
	var nb_coups = SauvegardeBddJoueursService.enregistrement_campagne_lire_nombre_coups()
	var pluriel = "" if nb_coups < 2 else "s"
	enregistrer_coups(str(nb_coups) + " Coup" + pluriel)

# ########
# Usine >>
# Boutons du bandeau de jeu
func _on_bouton_recommencer_pressed() -> void:
	show_fond()
	LogService.log_debug("[menu_plateau] emission signal : abandon")
	abandon.emit()

func _on_bouton_passer_pressed() -> void:
	show_fond()
	LogService.log_debug("[menu_plateau] emission signal : passe")
	passe.emit()

# Boutons du bandeau de menu
func _on_fond_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# LogService.log_debug("Clique souris sur le fond du plateau")
			# Parcourir les piles et déselectionner la pile (comme "timeout" sur la selection)
			deselection_pile.emit()

func _on_bouton_menu_principal_pressed() -> void:
	AudioService.son_menu_click()
	VibrationService.vibration_click()
	get_tree().change_scene_to_file("res://Scenes/MenuPrincipal/menu_principal.tscn")

func _on_bouton_statistiques_pressed() -> void:
	AudioService.son_menu_click()
	VibrationService.vibration_click()
	get_tree().change_scene_to_file("res://Scenes/MenuPrincipal/Campagne/Statistiques/statistiques.tscn")

func _on_bouton_commencer_pressed() -> void:
	AudioService.son_menu_click()
	VibrationService.vibration_click()
	var date_debut_campagne = SauvegardeConfigurationService.lire_la_date_debut_campagne_timestamp()
	if Time.get_unix_time_from_system() < date_debut_campagne:
		# var datetime_debut_campagne = Time.get_datetime_dict_from_unix_time( date_debut_campagne )
		# var annee = datetime_debut_campagne.get('year')
		# var mois = datetime_debut_campagne.get('month')
		# var jour = datetime_debut_campagne.get('day')
		# var heure = datetime_debut_campagne.get('hour')
		# var minute = datetime_debut_campagne.get('minute')

		# TODO : Faire un message pour l'usager.
		# var message = "Soyez patient, la campagne commence le " \
		# 	+ str(jour).pad_zeros(2) +"/"+str(mois).pad_zeros(2)+"/"+str(annee)+"."
		# afficher_message_simple(message, 5.)
		pass
	else:
		LogService.log_debug("[menu_plateau] emission signal : commencer_plateau")
		commencer_plateau.emit()
