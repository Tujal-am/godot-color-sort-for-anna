extends Node

const VIBRATION_PLATEAU = {'duration': 800, 'amplitude': 1.0} # Grosse vibration
const VIBRATION_PILE = {'duration': 200, 'amplitude': 0.5} # Petite vibration
const VIBRATION_JETON = {'duration': 50, 'amplitude': 0.20} # Toute petite vibration
const VIBRATION_ECHEC = {'duration': 50, 'amplitude': 0.20} # Toute petite vibration

func _vibration(vibration : Dictionary) -> void:
	if SauvegardeConfigurationService.vibrations_sont_actives():
		Input.vibrate_handheld(vibration['duration'], vibration['amplitude'])

func vibration_fin_de_plateau():
	_vibration(VIBRATION_PLATEAU)

func vibration_fin_de_pile():
	_vibration(VIBRATION_PILE)

func vibration_de_jeton():
	_vibration(VIBRATION_JETON)

func vibration_echec():
	_vibration(VIBRATION_ECHEC)
