extends Node

const MUSIQUE_SOLVE_THE_PUZZLE = preload("res://Art/Musique/Solve The Puzzle.ogg")
const MUSIQUE_DREAMING = preload("res://Art/Musique/Dreaming.ogg")
const MUSIQUE_GREAT_LITTLE_CHALLENGE = preload("res://Art/Musique/Great Little Challenge.ogg")
const MUSIQUE_HUMBLE_MATCH = preload("res://Art/Musique/Humble Match.ogg")
const MUSIQUE_SU_TURNO = preload("res://Art/Musique/Su Turno.ogg")
const MUSIQUE_THE_THREE_PRINCESSES_OF_LILAC_MEADOW = preload("res://Art/Musique/The Three Princesses of Lilac Meadow.ogg")

const SON_MENU_CLICK = preload("res://Art/EffetSonore/menu-click.mp3")

const SON_PARTIE_COMMENCER = preload("res://Art/EffetSonore/game-start.mp3")
const SON_PARTIE_VICTOIRE = preload("res://Art/EffetSonore/game-win.mp3")
const SON_PARTIE_ECHEC = preload("res://Art/EffetSonore/game-fail.mp3")

const SON_JETON_DEPLACER_DEBUT_SUCCES = preload("res://Art/EffetSonore/move-start-success.mp3")
const SON_JETON_DEPLACER_PLEINE = preload("res://Art/EffetSonore/move-full.mp3")
const SON_JETON_DEPLACER_ECHEC = preload("res://Art/EffetSonore/move-fail.mp3")

var musique: AudioStreamPlayer
var effet_sonore: AudioStreamPlayer

####################################
# Musiques
####################################

func _ready() -> void:
	musique = AudioStreamPlayer.new()
	add_child(musique)

	effet_sonore = AudioStreamPlayer.new()
	add_child(effet_sonore)

func _musique_play(stream: AudioStream):
	musique.stream = stream
	musique.play()

func _musique_stop():
	musique.stop()

func _effet_sonore_play(stream: AudioStream):
	effet_sonore.stream = stream
	effet_sonore.play()

# API externe
func jouer_la_musique():
	if not SauvegardeConfigurationService.musiques_sont_actives():
		return
	var pourcentage_niveau = roundi(StatsService.niveau_taux_completion() * 100.)
	if pourcentage_niveau <= roundi(100.*1/6):
		_musique_play(MUSIQUE_DREAMING)
	elif pourcentage_niveau <= roundi(100.*2/6):
		_musique_play(MUSIQUE_SU_TURNO)
	elif pourcentage_niveau <= roundi(100.*3/6):
		_musique_play(MUSIQUE_THE_THREE_PRINCESSES_OF_LILAC_MEADOW)
	elif pourcentage_niveau <= roundi(100.*4/6):
		_musique_play(MUSIQUE_SOLVE_THE_PUZZLE)
	elif pourcentage_niveau <= roundi(100.*5/6):
		_musique_play(MUSIQUE_HUMBLE_MATCH)
	else:
		_musique_play(MUSIQUE_GREAT_LITTLE_CHALLENGE)

func arreter_la_musique():
	if SauvegardeConfigurationService.musiques_sont_actives():
		_musique_stop()

func son_menu_click():
	if SauvegardeConfigurationService.effets_sonores_sont_actifs():
		_effet_sonore_play(SON_MENU_CLICK)

func son_commencer_un_plateau():
	if SauvegardeConfigurationService.effets_sonores_sont_actifs():
		_effet_sonore_play(SON_PARTIE_COMMENCER)

func son_abandonner_un_plateau():
	if SauvegardeConfigurationService.effets_sonores_sont_actifs():
		_effet_sonore_play(SON_PARTIE_ECHEC)

func son_gagner_un_plateau():
	if SauvegardeConfigurationService.effets_sonores_sont_actifs():
		_effet_sonore_play(SON_PARTIE_VICTOIRE)

func son_jeton_deplacer_debut():
	if SauvegardeConfigurationService.effets_sonores_sont_actifs():
		_effet_sonore_play(SON_JETON_DEPLACER_DEBUT_SUCCES)

func son_jeton_deplacer_echec():
	if SauvegardeConfigurationService.effets_sonores_sont_actifs():
		_effet_sonore_play(SON_JETON_DEPLACER_ECHEC)

func son_jeton_deplacer_succes():
	if SauvegardeConfigurationService.effets_sonores_sont_actifs():
		_effet_sonore_play(SON_JETON_DEPLACER_DEBUT_SUCCES)

func son_jeton_deplacer_pile_pleine():
	if SauvegardeConfigurationService.effets_sonores_sont_actifs():
		_effet_sonore_play(SON_JETON_DEPLACER_PLEINE)
