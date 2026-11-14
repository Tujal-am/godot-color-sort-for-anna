extends CanvasLayer

## Cinématique Classique isolée du plateau réel.
## Les composants graphiques sont préconstruits dans la scène : aucun bouton,
## aucune cellule ni aucun jeton n'est créé par le script.
signal ouvert
signal termine

const PREF_PATH := "user://rtc_intro_classique.cfg"
const PLATEAU_DEPART := [
	"D", "B", null, "B", "A",
	"B", "D", null, "A", "C",
	"D", "C", null, "A", "C"
]
const PLATEAU_SUIVANT := [
	"C", "B", null, "D", "A",
	"A", "C", null, "A", "B",
	"B", "D", null, "C", "D"
]

@onready var cartouche: Panel = $Surface/Cartouche
@onready var titre: Label = $Surface/Cartouche/Titre
@onready var description: Label = $Surface/Cartouche/Description
@onready var demo: Control = $Surface/Cartouche/Demo
@onready var commandes: Control = $Surface/Cartouche/Commandes
@onready var final: Control = $Surface/Cartouche/Final
@onready var actions: Control = $Surface/Cartouche/Actions
@onready var suivant: Button = $Surface/Cartouche/Actions/Suivant
@onready var case_ne_plus_afficher: CheckBox = $Surface/Cartouche/Final/NePlusAfficher
@onready var jeton_b_1: Control = $Surface/Cartouche/Demo/B1
@onready var jeton_b_2: Control = $Surface/Cartouche/Demo/B2

var _phase_actuelle := 0
static var _joueurs_vus: Dictionary = {}
var _cinematique: Tween
const DEPART_B1 := Vector2(126, 166)
const DEPART_B2 := Vector2(126, 228)
const ARRIVEE_B1 := Vector2(224, 166)
const ARRIVEE_B2 := Vector2(224, 228)

func _ready() -> void:
	hide()
	$ApercuMenu.hide()
	_rendre_apercu_passif($ApercuMenu)
	suivant.pressed.connect(_avancer)
	case_ne_plus_afficher.toggled.connect(func(coche: bool): $Surface/Cartouche/Final/Coche.visible = coche)
	$Surface/Cartouche/Actions/PasserIntro.pressed.connect(_ignorer_demonstration)
	$Surface/Cartouche/Final/Compris.pressed.connect(_terminer)
	$Surface/Cartouche/Commandes/PlateauUn.configurer(PLATEAU_DEPART)
	$Surface/Cartouche/Commandes/PlateauDeux.configurer(PLATEAU_SUIVANT)
	demo.get_node("B1/Jeton").choisir_jeton(1)
	demo.get_node("B2/Jeton").choisir_jeton(1)
	demo.get_node("C/Jeton").choisir_jeton(2)
	demo.get_node("B3/Jeton").choisir_jeton(1)

func afficher_si_necessaire() -> void:
	if not _joueurs_vus.has(_nom_joueur()) and not _pref_masquee():
		_demarrer()

func afficher_manuellement() -> void:
	_demarrer()

func masquer() -> void:
	_stop_animation()
	var etait_visible := visible
	$ApercuMenu.hide()
	hide()
	if etait_visible:
		termine.emit()

func _nom_joueur() -> String:
	return SauvegardeBddJoueursService.lire_nom_joueur()

func _pref_masquee() -> bool:
	if _nom_joueur().is_empty():
		return false
	var sauvegarde := ConfigFile.new()
	if sauvegarde.load(PREF_PATH) != OK:
		return false
	return bool(sauvegarde.get_value("classique", _nom_joueur(), false))

func _sauver_pref() -> void:
	var nom := _nom_joueur()
	if nom.is_empty():
		return
	var sauvegarde := ConfigFile.new()
	sauvegarde.load(PREF_PATH)
	sauvegarde.set_value("classique", nom, case_ne_plus_afficher.button_pressed)
	var err := sauvegarde.save(PREF_PATH)
	if err != OK:
		push_warning("Impossible de sauvegarder l'option d'introduction Classique.")

func _stop_animation() -> void:
	if _cinematique != null:
		_cinematique.kill()
		_cinematique = null

func _demarrer() -> void:
	_joueurs_vus[_nom_joueur()] = true
	_stop_animation()
	case_ne_plus_afficher.button_pressed = false
	jeton_b_1.position = DEPART_B1
	jeton_b_2.position = DEPART_B2
	demo.get_node("B1/Jeton").souder_en_bas()
	demo.get_node("B2/Jeton").dessouder()
	demo.get_node("B2/Jeton").souder_en_haut()
	demo.get_node("B3/Jeton").dessouder()
	_afficher_phase(0)
	if not visible:
		ouvert.emit()
	show()
	# 6,1 s : lecture, transfert réel du groupe visuel, résultat.
	# Le plateau du joueur n'est pas instancié ni modifié ici.
	_cinematique = create_tween()
	_cinematique.tween_interval(2.1)
	_cinematique.tween_callback(Callable(self, "_afficher_phase").bind(1))
	_cinematique.tween_property(jeton_b_1, "position", ARRIVEE_B1, 1.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	_cinematique.parallel().tween_property(jeton_b_2, "position", ARRIVEE_B2, 1.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	_cinematique.tween_callback(Callable(self, "_afficher_phase").bind(2))
	_cinematique.tween_interval(2.6)
	_cinematique.tween_callback(Callable(self, "_afficher_phase").bind(3))

func _afficher_phase(phase: int) -> void:
	_phase_actuelle = phase
	demo.visible = phase <= 2
	commandes.visible = phase >= 3 and phase <= 5
	final.visible = phase == 6
	actions.visible = phase <= 5
	suivant.visible = phase >= 3 and phase <= 5
	titre.visible = phase != 6
	description.visible = phase != 6
	var icones := [
		$Surface/Cartouche/Commandes/Jouer,
		$Surface/Cartouche/Commandes/Recommencer,
		$Surface/Cartouche/Commandes/Passer
	]
	for icone in icones:
		icone.hide()
	$Surface/Cartouche/Commandes/PlateauUn.visible = false
	$Surface/Cartouche/Commandes/PlateauDeux.visible = false
	$Surface/Cartouche/Commandes/Fleche.visible = false
	$Surface/Cartouche/Commandes/PlateauUn.presenter_grand_plateau(false)
	$Surface/Cartouche/Commandes/PlateauQuitte.hide()
	$Surface/Cartouche/Commandes/NouveauPlateau.hide()

	_appliquer_disposition(phase)
	actions.position.y = 592 - cartouche.position.y - 456
	match phase:
		0:
			titre.text = "Même couleur, même voyage !"
			description.text = "Deux jetons B au sommet voyagent ensemble."
		1:
			titre.text = "Déplace les jetons ensemble."
			description.text = "Ils rejoignent la colonne de même couleur."
		2:
			demo.get_node("B2/Jeton").souder_en_bas()
			demo.get_node("B3/Jeton").souder_en_haut()
			titre.text = "Réunis les couleurs !"
			description.text = "Le C reste en place. Les trois B sont réunis."
		3:
			titre.text = "JOUER"
			description.text = "Lance le plateau et\ndémarre le chrono."
			icones[0].show()
			$Surface/Cartouche/Commandes/PlateauUn.hide()
		4:
			titre.text = "RECOMMENCER"
			description.text = "Le plateau recommence à\nson point de départ."
			icones[1].show()
			$Surface/Cartouche/Commandes/PlateauUn.show()
			$Surface/Cartouche/Commandes/PlateauUn.position = Vector2(0, 118)
			$Surface/Cartouche/Commandes/PlateauUn.presenter_grand_plateau(true)

		5:
			titre.text = "PASSER"
			description.text = "Un nouveau plateau apparaît.\nAttention, le précédent plateau sera considéré comme perdu."
			icones[2].show()
			$Surface/Cartouche/Commandes/PlateauUn.show()
			$Surface/Cartouche/Commandes/PlateauDeux.show()
			$Surface/Cartouche/Commandes/Fleche.show()
			$Surface/Cartouche/Commandes/PlateauUn.position = Vector2(-12, 202)
			$Surface/Cartouche/Commandes/PlateauDeux.position = Vector2(220, 202)
		6:
			titre.text = "À toi de jouer !"

func _avancer() -> void:
	if _phase_actuelle < 3:
		_stop_animation()
		_afficher_phase(3)
	elif _phase_actuelle < 6:
		_afficher_phase(_phase_actuelle + 1)

func _ignorer_demonstration() -> void:
	_stop_animation()
	_afficher_phase(6)

func _terminer() -> void:
	_sauver_pref()
	masquer()

func _exit_tree() -> void:
	masquer()

func _appliquer_disposition(phase: int) -> void:
	# Quatre encarts reproduits en objets Godot depuis le kit HD validé.
	# Le bandeau de démonstration est une instance du vrai menu RC20,
	# désactivée : aucun signal n'atteint le plateau du joueur.
	var apercu := $ApercuMenu
	apercu.hide()
	if phase == 4 or phase == 5:
		apercu.show_jeu()
		apercu.enregistrer_gameplay("CLASSIQUE")
		apercu.enregistrer_sous_titre_gameplay("Range tes couleurs")
		apercu.enregistrer_chrono("00", "00" if phase == 4 else "02", "0" if phase == 4 else "2")
	else:
		apercu.show_menu()
		apercu.enregistrer_joueur(_nom_joueur())
		apercu.enregistrer_niveau(get_parent().get_node("MenuPlateau").lire_niveau())
		apercu.enregistrer_pourcentage(get_parent().get_node("MenuPlateau/BandeauMenu/Pourcentage").text)
	apercu.get_node("BoutonAide").hide()
	$Surface/Mention.visible = phase >= 3 and phase <= 5
	$Surface/Cartouche/Separateur.visible = phase >= 3 and phase <= 5
	description.visible = phase >= 3 and phase <= 5
	description.add_theme_font_size_override("font_size", 16 if phase == 5 else 17)
	titre.add_theme_font_size_override("font_size", 26 if phase >= 3 and phase <= 5 else 24)
	titre.add_theme_color_override("font_color", Color(0.03, 0.43, 0.60) if phase >= 3 and phase <= 5 else Color(0.03, 0.25, 0.46))
	if phase <= 2:
		cartouche.position = Vector2(32, 168)
		cartouche.size = Vector2(416, 107)
		titre.position = Vector2(15, 18)
		titre.size = Vector2(386, 70)
		titre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	elif phase <= 5:
		cartouche.position = Vector2(32, 195 if phase == 3 else (160 if phase == 4 else 154))
		cartouche.size = Vector2(416, 119 if phase == 3 else (100 if phase == 4 else 133))
		titre.position = Vector2(124, 22)
		titre.size = Vector2(276, 34)
		titre.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		description.position = Vector2(124, 54 if phase != 4 else 49)
		description.size = Vector2(276, 62 if phase == 5 else (48 if phase == 4 else 58))
		$Surface/Cartouche/Separateur.size.y = cartouche.size.y - 40
		if phase == 4:
			$Surface/Cartouche/Commandes/Recommencer.position.y = 20
		if phase == 5:
			$Surface/Cartouche/Commandes/PlateauQuitte.position = Vector2(-14, 176)
			$Surface/Cartouche/Commandes/NouveauPlateau.position = Vector2(218, 176)
			$Surface/Cartouche/Commandes/PlateauQuitte.show()
			$Surface/Cartouche/Commandes/NouveauPlateau.show()
	else:
		cartouche.position = Vector2(32, 192)
		cartouche.size = Vector2(416, 383)

func _rendre_apercu_passif(noeud: Node) -> void:
	if noeud is Control:
		noeud.mouse_filter = Control.MOUSE_FILTER_IGNORE
		noeud.focus_mode = Control.FOCUS_NONE
	for enfant in noeud.get_children():
		_rendre_apercu_passif(enfant)
