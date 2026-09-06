####################################
# Gestion de la configuration du jeu
####################################

extends Node

# class_name Configuration

# Dico : {'caracteristique': reglage}
var configuration_du_jeu = {
	'version': 'V0.4.8',
	'date_debut_campagne': "2026-05-08 18:24:14",
	'musiques': true,
	'effets sonores': true,
	'vibrations': true
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_initialiser_la_configuration()


func _initialiser_la_configuration() -> void:
	# CONVERSION [V0.3.1 -> V0.3.2]
	# Effacer le fichier de sauvegarde obsolete qui devient incompatible.
	FichiersJsonService.remove_json_file("user://sauvegarde.json")
	
	# Lire la configuration du jeu
	var fichier_configuration = FichiersJsonService.read_json_file("user://configuration_du_jeu.json")
	if not fichier_configuration:
		_enregistrer_la_configuration()
		fichier_configuration = FichiersJsonService.read_json_file("user://configuration_du_jeu.json")
	# LogService.log_debug(fichier_configuration)
	
	var version_courante_disque = fichier_configuration.get('version')
	
	# Conserver les réglages utilisateur avant d'enregistrer la nouvelle version.
	if fichier_configuration:
		if 'musiques' in fichier_configuration:
			configuration_du_jeu['musiques'] = fichier_configuration.get('musiques')
		if 'effets sonores' in fichier_configuration:
			configuration_du_jeu['effets sonores'] = fichier_configuration.get('effets sonores')
		if 'vibrations' in fichier_configuration:
			configuration_du_jeu['vibrations'] = fichier_configuration.get('vibrations')
		if version_courante_disque != lire_la_version():
			# Les versions explicitement couvertes remplacent la campagne et
			# remettent les scores à zéro avant d'enregistrer la version courante.
			if version_courante_disque in ['V0.3.3', 'V0.3.4', 'V0.3.5', 'V0.3.6',
											'V0.4.0.beta1', 'V0.4.0.beta2', 'V0.4.0.beta3',
											'V0.4.0.beta4', 'V0.4.0.beta5', 'V0.4.0.beta6',
											'V0.4.0.beta7']:
				SauvegardeBddJoueursService.remplacer_campagne_des_joueur()
				SauvegardeTableauDesScoresService.remise_a_zero()
			_enregistrer_la_configuration()
	else:
		# Création du fichier initial
		_enregistrer_la_configuration()
	LogService.log_debug("fichier_configuration = ", fichier_configuration)

func _enregistrer_la_configuration() -> void:
	LogService.log_debug("configuration.gd : _enregistrer_la_configuration")
	FichiersJsonService.write_json_file("user://configuration_du_jeu.json", configuration_du_jeu.duplicate(true))
	LogService.log_debug("Configuration sauvegardée")

func activer_musiques() -> void:
	if not configuration_du_jeu.get('musiques', true):
		configuration_du_jeu['musiques'] = true
		_enregistrer_la_configuration()

func activer_effets_sonores() -> void:
	if not configuration_du_jeu.get('effets sonores', true):
		configuration_du_jeu['effets sonores'] = true
		_enregistrer_la_configuration()

func activer_vibrations() -> void:
	if not configuration_du_jeu.get('vibrations', true):
		configuration_du_jeu['vibrations'] = true
		_enregistrer_la_configuration()

func desactiver_musiques() -> void:
	if configuration_du_jeu.get('musiques', true):
		configuration_du_jeu['musiques'] = false
		_enregistrer_la_configuration()

func desactiver_effets_sonores() -> void:
	if configuration_du_jeu.get('effets sonores', true):
		configuration_du_jeu['effets sonores'] = false
		_enregistrer_la_configuration()

func desactiver_vibrations() -> void:
	if configuration_du_jeu.get('vibrations', true):
		configuration_du_jeu['vibrations'] = false
		_enregistrer_la_configuration()

func musiques_sont_actives() -> bool:
	return configuration_du_jeu.get('musiques', true)

func effets_sonores_sont_actifs() -> bool:
	return configuration_du_jeu.get('effets sonores', true)

func vibrations_sont_actives() -> bool:
	return configuration_du_jeu.get('vibrations', true)

func lire_la_version() -> String:
	return configuration_du_jeu.get('version', '?')

func lire_la_date_debut_campagne_timestamp() -> int:
	var datetime = configuration_du_jeu.get('date_debut_campagne', '?')
	return Time.get_unix_time_from_datetime_string(datetime)
