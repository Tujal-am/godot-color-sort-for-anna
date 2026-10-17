extends SceneTree
func _initialize():
    call_deferred("run")
func run():
    for mode in ["QuiPerdGagne/qui_perd_gagne", "Classique/classique"]:
        var scene = load("res://Scenes/MenuPrincipal/Campagne/GamePlay/"+mode+".tscn").instantiate()
        root.add_child(scene)
        scene.commencer_un_nouveau_plateau("AB.BA.  ")
        var p = scene.get_node("Plateau")
        assert(not p.regles.est_valide_le_tansfert_de_pile(p.liste_piles,0,1))
        assert(p.regles.realiser_le_tansfert_de_pile(p.liste_piles,0,2))
        assert(p.liste_piles[0].liste_jetons[1].est_vide())
        assert(p.liste_piles[2].liste_jetons[0].indice_jeton==1)
        assert(p.regles.realiser_le_tansfert_de_pile(p.liste_piles,1,0))
        assert(p.liste_piles[0].est_termine())
        assert(p.liste_piles[0].liste_jetons[0].get_node("SoudureHaute").visible)
        assert(p.liste_piles[0].liste_jetons[1].get_node("SoudureBasse").visible)
        assert(not p.regles.pile_de_depart_de_tansfert_valide(p.liste_piles[0]))
        var token = p.liste_piles[0].liste_jetons[0]
        assert(token.has_node("Carre/VisuelQPG") == mode.begins_with("QuiPerdGagne"))
        print("PASS ",mode,": refus destination pleine, 2 transferts natifs, cases vides, pile terminée/soudée/bloquée, routage UI")
        scene.queue_free()
        await process_frame
    quit()
