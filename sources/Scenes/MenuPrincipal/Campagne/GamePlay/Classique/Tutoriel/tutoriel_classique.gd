extends CanvasLayer

## Cinématique Classique isolée du plateau réel.
## Les composants graphiques sont préconstruits dans la scène : aucun bouton,
## aucune cellule ni aucun jeton n'est créé par le script.
signal termine

const PREF_PATH := "user://rtc_intro_classique.cfg"
const PLATEAU_DEPART := [
	"D", "B", null, "B", "A",
	"B", "D", null, "A", "C",
	"D", "C", null, "A", "C"
]
const PLATEAU_SUIVANT := [
	"A", "C", null, "D", "B",
	"C", "B", null, "D", "A",
	"B", "A", null, "C", "D"
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
var _vu_dans_la_session := false
var _cinematique: Tween

func _ready() -> void:
	hide()
	suivant.pressed.connect(_avancer)
	$Surface/Cartouche/Actions/PasserIntro.pressed.connect(_ignorer_demonstration)
	$Surface/Cartouche/Final/Compris.pressed.connect(_terminer)
	$Surface/Cartouche/Commandes/PlateauUn.configurer(PLATEAU_DEPART)
	$Surface/Cartouche/Commandes/PlateauDeux.configurer(PLATEAU_SUIVANT)
	demo.get_node("B1/Jeton").choisir_jeton(1)
	demo.get_node("B2/Jeton").choisir_jeton(1)
	demo.get_node("C/Jeton").choisir_jeton(2)
	demo.get_node("B3/Jeton").choisir_jeton(1)

func afficher_si_necessaire() -> void:
	if not _vu_dans_la_session and not _pref_masquee():
		_demarrer()

func afficher_manuellement() -> void:
	_demarrer()

func masquer() -> void:
	_stop_animation()
	hide()

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
	if _cinematique != null and _cinematique.is_running():
		_cinematique.kill()

func _demarrer() -> void:
	_vu_dans_la_session = true
	_stop_animation()
	case_ne_plus_afficher.button_pressed = _pref_masquee()
	jeton_b_1.position = Vector2(100, 190)
	jeton_b_2.position = Vector2(100, 248)
	_afficher_phase(0)
	show()
	# 6,5 s : lecture, transfert réel du groupe visuel, résultat.
	# Le plateau du joueur n'est pas instancié ni modifié ici.
	_cinematique = create_tween()
	_cinematique.tween_interval(2.1)
	_cinematique.tween_callback(Callable(self, "_afficher_phase").bind(1))
	_cinematique.tween_property(jeton_b_1, "position", Vector2(258, 190), 1.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	_cinematique.parallel().tween_property(jeton_b_2, "position", Vector2(258, 248), 1.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	_cinematique.tween_callback(Callable(self, "_afficher_phase").bind(2))
	_cinematique.tween_interval(2.6)
	_cinematique.tween_callback(Callable(self, "_afficher_phase").bind(3))

func _afficher_phase(phase: int) -> void:
	_phase_actuelle = phase
	demo.visible = phase <= 2
	commandes.visible = phase >= 3 and phase <= 5
	final.visible = phase == 6
	actions.visible = phase >= 3 and phase <= 5
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
	$Surface/Cartouche/Commandes/ChronoExemple.visible = false

	match phase:
		0:
			titre.text = "Même couleur, même voyage !"
			description.text = "Deux jetons B au sommet voyagent ensemble."
		1:
			titre.text = "Déplace les jetons ensemble."
			description.text = "Ils rejoignent la colonne de même couleur."
		2:
			titre.text = "Réunis les couleurs !"
			description.text = "Le C reste en place. Les trois B sont réunis."
		3:
			titre.text = "JOUER"
			description.text = "Lance le plateau et démarre le chrono."
			icones[0].show()
			$Surface/Cartouche/Commandes/PlateauUn.show()
			$Surface/Cartouche/Commandes/PlateauUn.position = Vector2(115, 234)
		4:
			titre.text = "RECOMMENCER"
			description.text = "Le plateau recommence à son point de départ."
			icones[1].show()
			$Surface/Cartouche/Commandes/PlateauUn.show()
			$Surface/Cartouche/Commandes/PlateauUn.position = Vector2(115, 234)
			$Surface/Cartouche/Commandes/ChronoExemple.show()
		5:
			titre.text = "PASSER"
			description.text = "Un nouveau plateau apparaît.\nAttention, le précédent plateau sera considéré comme perdu."
			icones[2].show()
			$Surface/Cartouche/Commandes/PlateauUn.show()
			$Surface/Cartouche/Commandes/PlateauDeux.show()
			$Surface/Cartouche/Commandes/Fleche.show()
			$Surface/Cartouche/Commandes/PlateauUn.position = Vector2(10, 247)
			$Surface/Cartouche/Commandes/PlateauDeux.position = Vector2(220, 247)
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
	termine.emit()
