# Implemente toutes les spécificité de la campagnes:
# Lectures des "Sauvegarde*" + synthese en croisant les données
# Il gere tous les mecanismes de regles, de donnees et de comportements de la campagne.

extends Node

class_name Campagne

var _transaction := false
var _classique_en_cours := false

func gameplay_to_ui(gameplay : GameplayTypes.Gameplay) -> Node:
	match gameplay:
		GameplayTypes.Gameplay.CLASSIQUE:
			return $Classique
		GameplayTypes.Gameplay.AU_PLUS_PRES:
			return $AuPlusPres
		GameplayTypes.Gameplay.PILE_POIL:
			return $PilePoil
		GameplayTypes.Gameplay.TOUT_EN_TETE:
			return $ToutEnTete
		GameplayTypes.Gameplay.PROGRAMMATION:
			return $Programmation
		GameplayTypes.Gameplay.PROGRAMMATION_GENIUS:
			return $ProgrammationGenius
		GameplayTypes.Gameplay.QUI_PERD_GAGNE:
			return $QuiPerdGagne
		GameplayTypes.Gameplay.POIDS_PLUME:
			return $PoidsPlume
		GameplayTypes.Gameplay.PILE_OU_FACE:
			return $PileOuFace
		GameplayTypes.Gameplay.MOT_CACHE:
			return $MotCache
		_:
			LogService.log_erreur("Gameplay inconnu : ", str(gameplay))
			return $Classique

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connecter les signaux attendus

	cacher_les_gameplays()
	$MenuCampagne.cacher_accueil()
	$Classique.recommencer.connect(_on_classique_recommencer)
	$Classique.passe.connect(_on_plateau_passe)
	$QuiPerdGagne.passe.connect(_on_plateau_passe)
	call_deferred("_presenter_premier_plateau")

func _prochain_plateau() -> Dictionary:
	var service := SauvegardeBddJoueursService
	var niveau := service.enregistrement_lire_valeur_niveau_joueur() if service.enregistrement_niveau_en_cours() else service.campagne_lire_prochain_niveau()
	return service.campagne_lire_premier_plateau(niveau)

func _presenter_premier_plateau() -> void:
	var gameplay := str(_prochain_plateau().get("gameplay", ""))
	if gameplay in ["CLASSIQUE", "QUI_PERD_GAGNE"]:
		$MenuCampagne.afficher_accueil_niveau_en_cours()
	else:
		_demarrer_premier_plateau()

func _demarrer_premier_plateau() -> void:
	if _transaction or _classique_en_cours:
		return
	_transaction = true
	var prochain := _prochain_plateau()
	var classique: bool = prochain.get("gameplay", "") == "CLASSIQUE"
	if classique and not $Classique.est_valide(str(prochain.get("nom", ""))):
		_on_classique_plateau_invalide()
		_transaction = false
		return
	ProgressionCampagneService.commencer_un_plateau()
	_lancer_plateau_de_campagne()
	_transaction = false

func _on_menu_commencer_plateau() -> void:
	_demarrer_premier_plateau()

func _on_classique_recommencer() -> void:
	if _transaction or not _classique_en_cours:
		return
	_transaction = true
	_classique_en_cours = false
	# Règle existante : échec, durée conservée pour le score, même plateau.
	ProgressionCampagneService.abandonner_un_plateau()
	$Classique.hide()
	_transaction = false
	_demarrer_premier_plateau()

func _lancer_plateau_de_campagne() -> void:
	var plateau : String = SauvegardeBddJoueursService.enregistrement_lire_nom_plateau()
	var gameplay_str : String = SauvegardeBddJoueursService.enregistrement_lire_gameplay_plateau()
	var gameplay : GameplayTypes.Gameplay = GameplayTypes.gameplay_to_enum(gameplay_str)
	var ui_gameplay : Node = gameplay_to_ui(gameplay)

	if ui_gameplay.est_valide(plateau):
		$MenuCampagne.cacher_accueil()
		montrer_le_gameplay(gameplay)
		ui_gameplay.commencer_un_nouveau_plateau(plateau)
		_classique_en_cours = gameplay == GameplayTypes.Gameplay.CLASSIQUE and ui_gameplay._active
		AudioService.son_commencer_un_plateau()
		AudioService.jouer_la_musique()
	else:
		_on_classique_plateau_invalide()


func _on_classique_plateau_invalide() -> void:
	_classique_en_cours = false
	$Classique.hide()
	$MenuCampagne.afficher_accueil_niveau_en_cours()
	$MenuCampagne.afficher_message_simple("Impossible de charger ce plateau.", 2.0)

func _on_classique_victoire() -> void:
	if _transaction or not SauvegardeBddJoueursService.enregistrement_plateau_en_cours():
		return
	_transaction = true
	_classique_en_cours = false
	ProgressionCampagneService.gagner_un_plateau()
	$MenuCampagne.show()
	$MenuCampagne.afficher_background()
	if ProgressionCampagneService.la_campagne_est_terminee():
		$Classique.hide()
		$QuiPerdGagne.hide()
		$MenuCampagne.afficher_fin_campagne()
	elif not ProgressionCampagneService.niveau_en_cours():
		$MenuCampagne.afficher_fin_niveau()
	else:
		$MenuCampagne.afficher_gagner_un_plateau()
	AudioService.son_gagner_un_plateau()
	AudioService.arreter_la_musique()
	_transaction = false

func _on_classique_abandon() -> void:
	if _transaction or not SauvegardeBddJoueursService.enregistrement_plateau_en_cours():
		return
	_transaction = true
	_classique_en_cours = false
	# Mettre à jour les plateaux à jouer
	ProgressionCampagneService.abandonner_un_plateau()
	cacher_les_gameplays()
	$MenuCampagne.show()
	$MenuCampagne.afficher_background()
	$MenuCampagne.afficher_abandonner_un_plateau()
	AudioService.son_abandonner_un_plateau()
	AudioService.arreter_la_musique()
	_transaction = false


func _on_qui_perd_gagne_plateau_invalide() -> void:
	LogService.log_erreur("_on_qui_perd_gagne_plateau_invalide pour la campagne IMPOSSIBLE ! WTF !")

func _on_qui_perd_gagne_victoire() -> void:
	_on_classique_victoire()

func _on_qui_perd_gagne_abandon() -> void:
	_on_classique_abandon()

func cacher_les_gameplays() -> void:
	$Classique.cacher_accueil()
	$QuiPerdGagne.cacher_accueil()

func montrer_le_gameplay(gameplay : GameplayTypes.Gameplay) -> void:
	if gameplay == GameplayTypes.Gameplay.CLASSIQUE:
		$QuiPerdGagne.hide()
		$Classique.show()
	if gameplay == GameplayTypes.Gameplay.QUI_PERD_GAGNE:
		$Classique.hide()
		$QuiPerdGagne.show()

func instance_gameplay(gameplay : GameplayTypes.Gameplay) -> Node:
	if gameplay == GameplayTypes.Gameplay.CLASSIQUE:
		return $Classique
	if gameplay == GameplayTypes.Gameplay.QUI_PERD_GAGNE:
		return $QuiPerdGagne
	LogService.log_erreur("Gameplay inconnu : ", gameplay)
	return null

func _on_plateau_passe() -> void:
	if _transaction or not SauvegardeBddJoueursService.enregistrement_plateau_en_cours():
		return
	_transaction = true
	if ProgressionCampagneService.passer_un_plateau():
		_classique_en_cours = false
		$Classique.hide()
		$QuiPerdGagne.hide()
		AudioService.arreter_la_musique()
		$MenuCampagne.show()
		$MenuCampagne.afficher_passer_un_plateau()
	_transaction = false
