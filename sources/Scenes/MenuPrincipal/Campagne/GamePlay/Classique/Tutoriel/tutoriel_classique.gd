extends CanvasLayer

## Cinématique Classique isolée du plateau réel.
## Panneaux, textes et cellules séparés dans la scène. Les jetons illustratifs
## réutilisent les vrais enfants du PackedScene RC20 avec overrides locaux mesurés.
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

@onready var _accent_commande: Panel = $Surface/AccentCommande
@onready var cartouche: Panel = $Surface/Cartouche
@onready var titre: Label = $Surface/Cartouche/Titre
@onready var description: Label = $Surface/Cartouche/Description
@onready var demo: Control = $Surface/Cartouche/Demo
@onready var commandes: Control = $Surface/Cartouche/Commandes
@onready var final: Control = $Surface/Cartouche/Final
@onready var case_ne_plus_afficher: CheckBox = $Surface/Cartouche/Final/NePlusAfficher
@onready var jeton_b_1: Control = $Surface/Cartouche/Demo/B1
@onready var jeton_b_2: Control = $Surface/Cartouche/Demo/B2

var _phase_actuelle := 0
static var _joueurs_vus: Dictionary = {}
var _cinematique: Tween
var _transition_commandes: Tween
const DUREES_COMMANDES := {3: 4.0, 4: 4.0, 5: 6.0}
const DEPART_B1 := Vector2(126, 166)
const DEPART_B2 := Vector2(126, 228)
const ARRIVEE_B1 := Vector2(224, 166)
const ARRIVEE_B2 := Vector2(224, 228)

func _ready() -> void:
	hide()
	$ApercuMenu.hide()
	_rendre_apercu_passif($ApercuMenu)
	$ApercuMenu/BandeauMenu.position.y += 26
	$ApercuMenu/BandeauEnJeu.position.y += 26
	$ApercuMenu/BandeauMenu.z_index = 1
	$ApercuMenu/BandeauEnJeu.z_index = 1
	case_ne_plus_afficher.toggled.connect(func(coche: bool): $Surface/Cartouche/Final/Coche.visible = coche)
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
	_stop_transition_commandes()
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
	_stop_transition_commandes()
	_phase_actuelle = phase
	demo.visible = phase <= 2
	commandes.visible = phase >= 3 and phase <= 5
	final.visible = phase == 6
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
	$Surface/Cartouche/Commandes/PlateauDeux.presenter_grand_plateau(false)
	$Surface/Cartouche/Commandes/PlateauQuitte.hide()
	$Surface/Cartouche/Commandes/NouveauPlateau.hide()

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
			$Surface/Cartouche/Commandes/PlateauUn.position = Vector2(8, 126)
			$Surface/Cartouche/Commandes/PlateauUn.presenter_grand_plateau(true)

		5:
			titre.text = "PASSER"
			description.text = "Un nouveau plateau apparaît.\nAttention, le précédent plateau\nsera considéré comme perdu."
			icones[2].show()
			$Surface/Cartouche/Commandes/PlateauUn.show()
			$Surface/Cartouche/Commandes/PlateauDeux.show()
			$Surface/Cartouche/Commandes/Fleche.show()
			$Surface/Cartouche/Commandes/PlateauUn.position = Vector2(-3, 211)
			$Surface/Cartouche/Commandes/PlateauDeux.position = Vector2(231, 211)
		6:
			titre.text = "À toi de jouer !"

	_appliquer_disposition(phase)
	if DUREES_COMMANDES.has(phase):
		_transition_commandes = create_tween()
		_transition_commandes.tween_interval(DUREES_COMMANDES[phase])
		_transition_commandes.tween_callback(_avancer)

func _stop_transition_commandes() -> void:
	if _transition_commandes != null:
		_transition_commandes.kill()
		_transition_commandes = null

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
	# Styles locaux mesurés : mêmes nœuds et SVG natifs, données toujours réelles.
	var police_header: Font = load("res://Art/UI/Fonts/DejaVu/DejaVuSans-Bold.ttf")
	for nom in ["Joueur","Niveau","Pourcentage"]:
		var etiquette: Label = apercu.get_node("BandeauMenu/"+nom)
		etiquette.add_theme_font_override("font",police_header)
		etiquette.add_theme_font_size_override("font_size",14)
	apercu.get_node("BandeauMenu/Joueur").position = Vector2(145,15)
	for configuration in [["Gameplay",18,Vector2(30,22)],["SousTitreGameplay",15,Vector2(31,51)],["Chrono",19,Vector2(294,32)]]:
		var etiquette: Label = apercu.get_node("BandeauEnJeu/"+configuration[0])
		etiquette.add_theme_font_override("font",police_header)
		etiquette.add_theme_font_size_override("font_size",configuration[1])
		etiquette.position = configuration[2]
	apercu.get_node("BandeauMenu/BoutonCommencer").position = Vector2(305,17)
	apercu.get_node("BandeauMenu/BoutonCommencer").size = Vector2(68,68)
	apercu.get_node("BandeauEnJeu/BoutonRecommencer").position = Vector2(198,24)
	apercu.get_node("BandeauEnJeu/BoutonRecommencer").size = Vector2(62,62)
	apercu.get_node("BandeauEnJeu/BoutonPasser").position = Vector2(408,26)
	apercu.get_node("BandeauEnJeu/BoutonPasser").size = Vector2(55,55)
	var accent: Panel = _accent_commande
	accent.visible = phase >= 3 and phase <= 5
	var bandeau: Control = apercu.get_node("BandeauEnJeu" if phase == 4 or phase == 5 else "BandeauMenu")
	if accent.get_parent() != bandeau:
		accent.reparent(bandeau,false)
	bandeau.move_child(accent,1)
	accent.global_position = Vector2(303,42) if phase == 3 else (Vector2(194,45) if phase == 4 else Vector2(402,45))
	accent.size = Vector2(74,73) if phase == 3 else Vector2(70,70)
	apercu.get_node("BoutonAide").hide()
	$Surface/Mention.visible = phase >= 3 and phase <= 5
	$Surface/Cartouche/Separateur.visible = phase >= 3 and phase <= 5
	description.visible = phase >= 3 and phase <= 5
	description.add_theme_font_size_override("font_size", 16 if phase == 5 else 17)
	description.add_theme_constant_override("line_spacing", 6 if phase == 5 else (12 if phase == 4 else 5))
	description.add_theme_color_override("font_color", Color8(21, 70, 117))
	titre.add_theme_font_size_override("font_size", 24 if phase == 4 else (26 if phase >= 3 and phase <= 5 else 24))
	titre.add_theme_color_override("font_color", Color8(20, 107, 151) if phase >= 3 and phase <= 5 else Color8(15,58,104))
	var verre: StyleBoxFlat = cartouche.get_theme_stylebox("panel").duplicate()
	verre.bg_color = Color8(253,244,228,128) if phase == 6 else Color(1.0,248.0/255.0,235.0/255.0,0.545)
	if phase == 4:
		verre.bg_color = Color(253.0/255.0,244.0/255.0,231.0/255.0,0.624)
	elif phase == 5:
		verre.bg_color = Color(1.0,245.0/255.0,231.0/255.0,0.585)
	verre.border_color = Color8(227,133,79,215)
	verre.set_border_width_all(1)
	verre.set_corner_radius_all(31 if phase == 6 else 24)
	cartouche.add_theme_stylebox_override("panel", verre)
	if phase <= 2:
		cartouche.position = Vector2(32, 168)
		cartouche.size = Vector2(416, 107)
		titre.position = Vector2(15, 18)
		titre.size = Vector2(386, 70)
		titre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	elif phase <= 5:
		cartouche.position = Vector2(32, 195 if phase == 3 else (151 if phase == 4 else 153))
		cartouche.size = Vector2(416, 119 if phase == 3 else (117 if phase == 4 else 135))
		titre.position = Vector2(124 if phase == 4 else (125 if phase == 5 else 124), 29 if phase == 3 else (20 if phase == 4 else 31))
		titre.size = Vector2(276, 34)
		titre.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		description.position = Vector2(125 if phase == 3 else 124, 47 if phase == 3 else (55 if phase == 4 else 54))
		description.size = Vector2(276, 68 if phase == 5 else (56 if phase == 4 else 58))
		var separateur := $Surface/Cartouche/Separateur
		separateur.position = Vector2(104 if phase == 5 else 103, 24 if phase == 3 else (14 if phase == 4 else 27))
		separateur.size = Vector2(1, 75 if phase == 3 else (88 if phase == 4 else 77))
		$Surface/Cartouche/Commandes/Jouer.position = Vector2(25,29)
		$Surface/Cartouche/Commandes/Recommencer.position = Vector2(24,29)
		$Surface/Cartouche/Commandes/Passer.position = Vector2(24,41)
		if phase == 5:
			$Surface/Cartouche/Commandes/PlateauQuitte.position = Vector2(-14, 177)
			$Surface/Cartouche/Commandes/PlateauQuitte.size = Vector2(212,180)
			$Surface/Cartouche/Commandes/NouveauPlateau.position = Vector2(219, 177)
			$Surface/Cartouche/Commandes/NouveauPlateau.size = Vector2(211,180)
			for cadre in [$Surface/Cartouche/Commandes/PlateauQuitte,$Surface/Cartouche/Commandes/NouveauPlateau]:
				var cadre_style: StyleBoxFlat = cadre.get_theme_stylebox("panel").duplicate()
				cadre_style.bg_color = Color(1.0,245.0/255.0,231.0/255.0,0.58)
				cadre_style.border_color = Color8(227,133,79,195)
				cadre.add_theme_stylebox_override("panel",cadre_style)
			$Surface/Cartouche/Commandes/PlateauQuitte.show()
			$Surface/Cartouche/Commandes/NouveauPlateau.show()
			$Surface/Cartouche/Commandes/Fleche.position = Vector2(191,234)
			$Surface/Cartouche/Commandes/Fleche.add_theme_color_override("font_color",Color8(221,132,49))
	else:
		cartouche.position = Vector2(31, 192)
		cartouche.size = Vector2(420, 383)
		var titre_final: Label = $Surface/Cartouche/Final/TitreFinal
		titre_final.position = Vector2(23,34)
		titre_final.add_theme_font_size_override("font_size",32)
		titre_final.add_theme_color_override("font_color",Color8(15,58,104))
		var texte_final: Label = $Surface/Cartouche/Final/TexteFinal
		texte_final.position = Vector2(35,102)
		texte_final.add_theme_font_override("font",load("res://Art/UI/Fonts/DejaVu/DejaVuSans.ttf"))
		texte_final.add_theme_font_size_override("font_size",17)
		texte_final.add_theme_color_override("font_color",Color8(9,63,112))
		case_ne_plus_afficher.add_theme_font_override("font",load("res://Art/UI/Fonts/DejaVu/DejaVuSans.ttf"))
		case_ne_plus_afficher.add_theme_constant_override("h_separation",33)
		case_ne_plus_afficher.add_theme_font_size_override("font_size",16)
		case_ne_plus_afficher.position.y = 172
		case_ne_plus_afficher.add_theme_color_override("font_color",Color8(9,63,112))
		$Surface/Cartouche/Final/CaseVide.position = Vector2(34,177)
		$Surface/Cartouche/Final/CaseVide.size = Vector2(32,31)
		$Surface/Cartouche/Final/Compris.position = Vector2(100,291)
		$Surface/Cartouche/Final/Compris.size = Vector2(220,62)
		$Surface/Cartouche/Final/Compris.add_theme_font_override("font",load("res://Art/UI/Fonts/DejaVu/DejaVuSans-Bold.ttf"))
		$Surface/Cartouche/Final/Compris.add_theme_font_size_override("font_size",23)
		var style_texte := StyleBoxEmpty.new()
		style_texte.content_margin_bottom = 10
		for etat in ["normal","hover","pressed"]:
			$Surface/Cartouche/Final/Compris.add_theme_stylebox_override(etat,style_texte)
	var badge_style: StyleBoxFlat = $Surface/Mention.get_theme_stylebox("panel").duplicate()
	badge_style.bg_color = Color(1.0,245.0/255.0,231.0/255.0,0.55)
	$Surface/Mention.add_theme_stylebox_override("panel",badge_style)
	$Surface/Mention/Texte.add_theme_color_override("font_color",Color8(21,70,117))
	$Surface/Mention.position = Vector2(49,653)
	$Surface/Mention.size = Vector2(382,38)

func _rendre_apercu_passif(noeud: Node) -> void:
	if noeud is Control:
		noeud.mouse_filter = Control.MOUSE_FILTER_IGNORE
		noeud.focus_mode = Control.FOCUS_NONE
	for enfant in noeud.get_children():
		_rendre_apercu_passif(enfant)
