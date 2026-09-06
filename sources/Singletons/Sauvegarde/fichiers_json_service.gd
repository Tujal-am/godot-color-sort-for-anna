extends Node

var clonage: bool = false
var clonage_app_dir: String = "/sdcard/Download/"
var clonage_prefixe: String = "RLC_"
var racine_utilisateur: String = "user://"

func definir_racine_utilisateur(racine: String) -> void:
	"Tests Unitaires : Permet de définir un répertoire de sauvegarde spécifique pour les tests unitaires"
	if not racine:
		racine_utilisateur = "user://"
	elif "://" in racine:
		racine_utilisateur = racine
	else:
		racine_utilisateur = "user://" + racine

	if not racine_utilisateur.ends_with("/"):
		racine_utilisateur += "/"

func reinitialiser_racine_utilisateur() -> void:
	"Tests Unitaires : Permet de réinitialiser le répertoire de sauvegarde des tests unitaires"
	racine_utilisateur = "user://"

func effacer_racine_utilisateur() -> void:
	"Tests Unitaires : Permet d'effacer le répertoire de sauvegarde des tests unitaires"
	if racine_utilisateur == "user://":
		return
	var racine = racine_utilisateur.trim_suffix("/")
	_effacer_repertoire_recursivement(racine)

func _normaliser_chemin(chemin: String) -> String:
	"Tests Unitaires : Permet de normaliser un chemin de fichier par rapport au répertoire de sauvegarde des tests unitaires"
	if not chemin:
		return chemin
	if chemin.begins_with("user://"):
		# Un préfixe de test (définir_racine_utilisateur) doit s'imposer même si
		# l'appelant a explicitement préfixé "user://" (ex: code de production
		# volontairement robuste), pour garder les tests isolés du profil réel.
		if racine_utilisateur != "user://":
			return racine_utilisateur + chemin.trim_prefix("user://")
		return chemin
	if "://" in chemin:
		return chemin
	if chemin.begins_with("/"):
		chemin = chemin.trim_prefix("/")
	return racine_utilisateur + chemin

func json_file_exists(chemin : String) -> Variant:
	chemin = _normaliser_chemin(chemin)
	return FileAccess.file_exists(chemin)

func remove_json_file(chemin : String) -> void:
	var chemin_norm : String = _normaliser_chemin(chemin)
	if FileAccess.file_exists(chemin_norm):
		var erreur = DirAccess.remove_absolute(chemin_norm)
		if erreur != OK:
			LogService.log_erreur("Erreur : Effacement du fichier : ", chemin_norm,
					 " avec l'erreur : ", erreur)
		if OS.get_name() == "Android" and clonage:
			var nom_fichier = clonage_prefixe + chemin
			if FileAccess.file_exists(clonage_app_dir + nom_fichier):
				DirAccess.remove_absolute(clonage_app_dir + nom_fichier)

func read_json_file(chemin : String) -> Variant:
	var chemin_norm : String = _normaliser_chemin(chemin)
	var fichier = null
	var contenu_texte = null
	
	# Lecture du fichier
	if FileAccess.file_exists(chemin_norm):
		fichier = FileAccess.open(chemin_norm, FileAccess.READ)
		if not fichier:
			LogService.log_erreur("read_json_file : ERREUR sur le chemin : ", chemin_norm)
			return null
		contenu_texte = fichier.get_as_text()
		if not contenu_texte :
			LogService.log_erreur("read_json_file : ERREUR sur le contenu : ", chemin_norm, " erreur = ", fichier.get_as_text())
			return null
		fichier.close()
		# LogService.log_debug("contenu_texte = ", contenu_texte)
		
		# Decodage JSON
		var json = JSON.new()
		var error = json.parse(contenu_texte)
		# LogService.log_debug("error = ", error)
		if error == OK:
			if OS.get_name() == "Android" and clonage:
				var nom_fichier = clonage_prefixe + chemin
				# Copier le fichier s'il n'existe pas !
				if not FileAccess.file_exists(clonage_app_dir + nom_fichier):
					fichier = FileAccess.open(clonage_app_dir + nom_fichier, FileAccess.WRITE)
					if not fichier:
						LogService.log_erreur("write_json_file : ERREUR sur le chemin : ", clonage_app_dir + nom_fichier)
					else:
						fichier.store_string(contenu_texte)
						fichier.close()
			return json.get_data()
		LogService.log_erreur("read_json_file : ERREUR sur le décodage JSON: ", json.get_error_message(), " in ", chemin_norm, " at line ", json.get_error_line())
	else:
		LogService.log_erreur("read_json_file : ERREUR, le fichier *", chemin_norm, "* n'existe pas ")
	return null

func write_json_file(chemin : String, contenu) -> void:
	var chemin_norm : String = _normaliser_chemin(chemin)
	var fichier = null
	
	# Ouverture du fichier
	_creer_repertoire_parent_si_necessaire(chemin_norm)
	fichier = FileAccess.open(chemin_norm, FileAccess.WRITE)
	if not fichier:
		LogService.log_erreur("write_json_file : ERREUR sur le chemin : ", chemin_norm)
		return
	# Encodage JSON
	var json_string = JSON.stringify(contenu)
	# LogService.log_debug("json_string = ", json_string)
	# Ecriture du fichier
	fichier.store_string(json_string)
	fichier.close()

	if OS.get_name() == "Android" and clonage:
		var nom_fichier = clonage_prefixe + chemin
		fichier = FileAccess.open(clonage_app_dir + nom_fichier, FileAccess.WRITE)
		if not fichier:
			LogService.log_erreur("write_json_file : ERREUR sur le chemin : ", clonage_app_dir + nom_fichier)
		fichier.store_string(json_string)
		fichier.close()

func _creer_repertoire_parent_si_necessaire(chemin: String) -> void:
	"Tests Unitaires : Permet de créer le répertoire parent d'un fichier si nécessaire"
	var chemin_parent = chemin.get_base_dir()
	if chemin_parent and not DirAccess.dir_exists_absolute(chemin_parent):
		DirAccess.make_dir_recursive_absolute(chemin_parent)

func _effacer_repertoire_recursivement(chemin: String) -> void:
	"Tests Unitaires : Permet d'effacer un répertoire et son contenu récursivement"
	if not chemin or not DirAccess.dir_exists_absolute(chemin):
		return
	var repertoire = DirAccess.open(chemin)
	if repertoire == null:
		LogService.log_erreur("Erreur : Ouverture du répertoire : ", chemin)
		return
	repertoire.list_dir_begin()
	var nom = repertoire.get_next()
	while nom != "":
		if nom != "." and nom != "..":
			var chemin_enfant = chemin.path_join(nom)
			if repertoire.current_is_dir():
				_effacer_repertoire_recursivement(chemin_enfant)
			else:
				var erreur_fichier = DirAccess.remove_absolute(chemin_enfant)
				if erreur_fichier != OK:
					LogService.log_erreur("Erreur : Effacement du fichier : ", chemin_enfant,
						 " avec l'erreur : ", erreur_fichier)
		nom = repertoire.get_next()
	repertoire.list_dir_end()
	var erreur_repertoire = DirAccess.remove_absolute(chemin)
	if erreur_repertoire != OK:
		LogService.log_erreur("Erreur : Effacement du répertoire : ", chemin,
				 " avec l'erreur : ", erreur_repertoire)
