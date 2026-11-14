extends BaseClassiqueQuiPerdGagne

class_name Classique

var _modes_avant_aide: Dictionary = {}

func _ready() -> void:
	super._ready()
	$MenuPlateau.enregistrer_gameplay("CLASSIQUE")
	$MenuPlateau.enregistrer_sous_titre_gameplay("Range tes couleurs")
	$MenuPlateau.aide_demandee.connect(_afficher_aide_classique)
	$TutorielClassique.ouvert.connect(_suspendre_pour_aide)
	$TutorielClassique.termine.connect(_reprendre_apres_aide)

func commencer_un_nouveau_gameplay() -> void:
	super.commencer_un_nouveau_gameplay()
	$TutorielClassique.afficher_si_necessaire()

func hide() -> void:
	$TutorielClassique.masquer()
	super.hide()

func _afficher_aide_classique() -> void:
	$TutorielClassique.afficher_manuellement()

func est_termine(liste_piles) -> bool:
	var termine := true
	for pile in liste_piles:
		if not pile.est_vide() and not pile.est_termine():
			termine = false
			break
	if termine:
		show_fond()
		LogService.log_debug("[classique] emission signal : victoire")
		victoire.emit()
	return termine

func _suspendre_pour_aide() -> void:
	for noeud in [$MenuPlateau, $Plateau]:
		_modes_avant_aide[noeud] = noeud.process_mode
		noeud.process_mode = Node.PROCESS_MODE_DISABLED
	if $MenuPlateau/BandeauEnJeu.visible:
		SauvegardeBddJoueursService.commencer_pause_aide_classique()

func _reprendre_apres_aide() -> void:
	SauvegardeBddJoueursService.terminer_pause_aide_classique()
	for noeud in _modes_avant_aide:
		if is_instance_valid(noeud):
			noeud.process_mode = _modes_avant_aide[noeud]
	_modes_avant_aide.clear()
