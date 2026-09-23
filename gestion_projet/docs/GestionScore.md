# Scene "GestionScore"

## Description

Cette classe correspond à un singleton accessible depuis toutes les scènes. Il gère le système de sauvegarde de la progression, la gestion du joueur courant, l'enchainement des plateaux pour la campagne, la consultation du fichier des plateaux de jeux (Solutions_classees.json) et l'enregistrement des indicateurs pour le calcul du score.

## Diagramme de classe

```mermaid
classDiagram
namespace gestion_score.gd {

    class Gestion_des_niveaux_et_des_plateaux_à_jouer {
        <<pseudo class>> 
        joueur_actuel
        plateau_liste_difficulte
        initialiser_les_plateaux()
        _read_json_file(chemin)
        _write_json_file(chemin, contenu)
        _ajouter_duree_de_partie(duree_en_ms : int)
        commencer()
        gagner(duree_en_ms : int)
        abandonner()
        lire_plateau_courant()
        _le_plateau_courant_est_le_dernier_du_niveau()
        _le_niveau_courant_est_le_dernier()
        _retourner_le_niveau_superieur(niveau : int)
        _retourner_le_niveau_inferieur(niveau : int)
        l_ascension_est_terminee()
        la_campagne_est_terminee()
    }

    class Gestion_des_sauvegardes {
        <<pseudo class>> 
        liste_des_sauvegardes
        lire_sauvegarde_joueurs()
        _enregistrer_sauvegarde_joueurs()
        _retourner_le_joueur(nom_joueur)
        choisir_le_joueur(nom_joueur)
        ajouter_un_nouveau_joueur(nom_nouveau_joueur : String)
    }

    class Gestion_du_joueur_actuel {
        <<pseudo class>> 
        lire_le_nom_du_joueur_actuel()
        lire_le_niveau_du_joueur_actuel()
        lire_indice_plateau_du_joueur_actuel()
        lire_le_score_du_joueur_actuel()
        lire_le_trophee_du_joueur_actuel()
        lire_le_rang_du_joueur_actuel()
    }

    class Gestion_des_infos_des_joueurs {
        <<pseudo class>> 
        lire_classement_des_joueurs()
        lire_le_rang_du_joueur(nom_joueur : String)
        lire_le_score_du_joueur(nom_joueur : String)
        lire_le_temps_du_joueur(nom_joueur : String, niveau : int)
        lire_la_liste_des_joueurs()
    }
}
```