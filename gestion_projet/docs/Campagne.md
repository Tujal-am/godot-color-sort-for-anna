# Scene "Campagne"

## Description

Cette classe correspond à la scène de la campagne. Cette classe doit gérer les victoires, les défaites du joueur et lui faire suivre un chemin de plateaux en fonction de sa réussite. La campagne enregistre aussi des indicateurs (nombre de parties, avancement dans les plateaux, temps de résolution ...) afin de pouvoir calculer le score du joueur. C'est la campagne qui enregistre l'avancement du joueur dans l'ensemble des plateaux existants.

## Diagramme de classe

```mermaid
classDiagram
class campagne.tscn {
    |SCENE| PlateauDeJeu
    |SCENE| MenuCampagne
    AudioService
    ProgressionCampagneService
    SauvegardeBddJoueursService
    heure_debut_en_ms
    duree_en_ms
    _ready()
    _on_menu_commencer_plateau()
    _lancer_plateau_de_campagne(String plateau)
    _on_plateau_de_jeu_victoire()
    _on_plateau_de_jeu_plateau_invalide()
    _on_plateau_de_jeu_abandon()
}

Node --|> campagne.tscn
campagne.tscn --o plateau.tscn
campagne.tscn --o menu_campagne.gd : set_script(MenuCampagne)
menu.gd --|> menu_campagne.gd
campagne.tscn --o AudioService
campagne.tscn --> ProgressionCampagneService
campagne.tscn --> SauvegardeBddJoueursService

namespace Services {
    class ProgressionCampagneService {
        progression_ascension()
        fin_ascension()
        commencer_un_plateau()
        gagner_un_plateau(duree_en_ms)
        la_campagne_est_terminee()
        ascension_en_cours()
    }

    class SauvegardeBddJoueursService {
        lire_nom_plateau()
    }

    class AudioService {
        son_commencer_un_plateau()
        jouer_la_musique()
    }
}

class plateau.tscn {
    SIGNAL--> victoire
    SIGNAL--> plateau_invalide
    SIGNAL--> abandon
    est_valide()
    effacer_le_plateau()
    commencer_un_nouveau_plateau()
}

class menu_campagne.gd {
    SIGNAL--> commencer_plateau
    modifier_tempo_message()
    modifier_message_vertical_align()
    show()
    afficher_accueil()
    cacher_accueil()
    afficher_fin_campagne()
    afficher_fin_ascension()
    afficher_victoire(duree_en_ms / 1000)
    afficher_abandon()
}
