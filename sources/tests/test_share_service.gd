extends GutTest

class FauxPartage extends Node:
	signal share_received(received_data)
	signal share_failed(message)
	signal share_completed(activity_type)
	signal share_canceled
	var appels: Array = []
	var cible_definie = null

	func set_share_target(valeur) -> void:
		cible_definie = valeur

	func share_texture(texture, title, subject, content) -> void:
		appels.append([texture, title, subject, content])

	func share_file(path, mime_type, title, subject, content) -> void:
		appels.append([path, mime_type, title, subject, content])

var service

func before_each():
	service = add_child_autofree(load("res://Singletons/share_service.gd").new())
	watch_signals(service)

func _installer_faux_partage() -> FauxPartage:
	var faux = FauxPartage.new()
	faux.share_received.connect(service._on_share_received)
	faux.share_failed.connect(service._on_share_failed)
	faux.share_completed.connect(service._on_share_completed)
	faux.share_canceled.connect(service._on_share_canceled)
	service.add_child(faux)
	service._share_node = faux
	return faux

func test_sans_plugin_le_service_est_indisponible():
	assert_false(service.is_available())

func test_ready_hors_android_ne_cree_pas_de_noeud():
	assert_null(service._share_node)
	assert_eq(service.get_child_count(), 0)

func test_share_texture_sans_plugin_retourne_false():
	assert_false(service.share_texture(null, "titre", "sujet", "contenu"))
	var texture = PlaceholderTexture2D.new()
	assert_false(service.share_texture(texture, "", "", ""))

func test_share_texture_sans_plugin_n_emet_aucun_signal():
	service.share_texture(null, "a", "b", "c")
	assert_signal_not_emitted(service, "share_received")
	assert_signal_not_emitted(service, "share_failed")

func test_noeud_valide_rend_le_service_disponible():
	_installer_faux_partage()
	assert_true(service.is_available())

func test_share_texture_transmet_les_arguments_au_plugin():
	var faux = _installer_faux_partage()
	var texture = PlaceholderTexture2D.new()
	assert_true(service.share_texture(texture, "titre", "sujet", "contenu"))
	assert_eq(faux.appels.size(), 1)
	assert_eq(faux.appels[0], [texture, "titre", "sujet", "contenu"])

func test_share_texture_chaines_vides_et_texture_nulle():
	var faux = _installer_faux_partage()
	assert_true(service.share_texture(null, "", "", ""))
	assert_eq(faux.appels[0], [null, "", "", ""])

func test_share_texture_plusieurs_appels():
	var faux = _installer_faux_partage()
	service.share_texture(null, "1", "", "")
	service.share_texture(null, "2", "", "")
	assert_eq(faux.appels.size(), 2)
	assert_eq(faux.appels[1][1], "2")

func test_share_received_du_plugin_est_reemis():
	var faux = _installer_faux_partage()
	var donnees = RefCounted.new()
	faux.share_received.emit(donnees)
	assert_signal_emitted_with_parameters(service, "share_received", [donnees])
	assert_signal_not_emitted(service, "share_failed")

func test_share_failed_du_plugin_est_reemis():
	var faux = _installer_faux_partage()
	faux.share_failed.emit("erreur")
	assert_signal_emitted_with_parameters(service, "share_failed", ["erreur"])
	assert_signal_not_emitted(service, "share_received")

func test_share_file_transmet_le_fichier_et_ses_metadonnees():
	var faux = _installer_faux_partage()
	var chemin := "user://share_service_test.json"
	var fichier := FileAccess.open(chemin, FileAccess.WRITE)
	fichier.store_string("{}")
	fichier.close()

	assert_true(service.share_file(chemin, "application/json", "titre", "sujet", "contenu"))
	assert_eq(faux.appels, [[chemin, "application/json", "titre", "sujet", "contenu"]])
	DirAccess.remove_absolute(ProjectSettings.globalize_path(chemin))

func test_share_file_refuse_un_fichier_absent_ou_un_type_mime_vide():
	_installer_faux_partage()

	assert_false(service.share_file("user://inexistant.json", "application/json", "", "", ""))
	assert_false(service.share_file("user://share_service_test.json", "", "", "", ""))

func test_signaux_de_fin_et_annulation_du_plugin_sont_reemis():
	var faux = _installer_faux_partage()
	faux.share_completed.emit("mail")
	faux.share_canceled.emit()

	assert_signal_emitted_with_parameters(service, "share_completed", ["mail"])
	assert_signal_emitted(service, "share_canceled")

func test_on_share_received_reemet_tout_type_de_donnee():
	service._on_share_received(null)
	service._on_share_received({"a": 1})
	service._on_share_received("texte")
	assert_signal_emit_count(service, "share_received", 3)
	assert_signal_emitted_with_parameters(service, "share_received", [{"a": 1}], 1)

func test_on_share_failed_message_vide():
	service._on_share_failed("")
	assert_signal_emitted_with_parameters(service, "share_failed", [""])

func test_noeud_libere_rend_le_service_indisponible():
	var faux = _installer_faux_partage()
	faux.free()
	assert_false(service.is_available())
	assert_false(service.share_texture(null, "a", "b", "c"))

func test_noeud_en_attente_de_liberation_reste_disponible_jusqu_a_la_liberation():
	var faux = _installer_faux_partage()
	faux.queue_free()
	assert_true(service.is_available())
	await wait_frames(2)
	assert_false(service.is_available())
