# Implemente toutes les spécificité de la campagnes:
# Lectures des "Sauvegarde*" + synthese en croisant les données
# Il gere tous les mecanismes de regles, de donnees et de comportements de la campagne.

extends Node

class_name Campagne

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
	$MenuCampagne.show()
	$MenuCampagne.afficher_accueil_niveau_en_cours()

func _on_menu_commencer_plateau() -> void:
	ProgressionCampagneService.commencer_un_plateau()
	_lancer_plateau_de_campagne()

func _lancer_plateau_de_campagne() -> void:
	var plateau : String = SauvegardeBddJoueursService.enregistrement_lire_nom_plateau()
	var gameplay_str : String = SauvegardeBddJoueursService.enregistrement_lire_gameplay_plateau()
	var gameplay : GameplayTypes.Gameplay = GameplayTypes.gameplay_to_enum(gameplay_str)
	var ui_gameplay : Node = gameplay_to_ui(gameplay)

	if ui_gameplay.est_valide(plateau):
		$MenuCampagne.cacher_accueil()
		montrer_le_gameplay(gameplay)
		ui_gameplay.commencer_un_nouveau_plateau(plateau)
		AudioService.son_commencer_un_plateau()
		AudioService.jouer_la_musique()
	else:
		_on_classique_plateau_invalide()

func _on_classique_plateau_invalide() -> void:
	# Pas de plateau invalide en campagne
	LogService.log_erreur("_on_classique_plateau_invalide pour la campagne IMPOSSIBLE ! WTF !")

func _on_classique_victoire() -> void:
	ProgressionCampagneService.gagner_un_plateau()
	$MenuCampagne.show()
	if ProgressionCampagneService.la_campagne_est_terminee():
		$MenuCampagne.afficher_fin_campagne()
	elif not ProgressionCampagneService.niveau_en_cours():
		$MenuCampagne.afficher_fin_niveau()
	else:
		$MenuCampagne.afficher_gagner_un_plateau()
	AudioService.son_gagner_un_plateau()
	AudioService.arreter_la_musique()

func _on_classique_abandon() -> void:
	# Mettre à jour les plateaux à jouer
	ProgressionCampagneService.abandonner_un_plateau()
	cacher_les_gameplays()
	$MenuCampagne.show()
	$MenuCampagne.afficher_abandonner_un_plateau()
	AudioService.son_abandonner_un_plateau()
	AudioService.arreter_la_musique()


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
