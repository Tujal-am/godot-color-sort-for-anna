extends BaseClassiqueQuiPerdGagne

class_name Classique

func _ready() -> void:
	super._ready()
	$MenuPlateau.enregistrer_gameplay("CLASSIQUE")
	$MenuPlateau.enregistrer_sous_titre_gameplay("Range tes couleurs")
	$MenuPlateau.aide_demandee.connect(_afficher_aide_classique)

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
