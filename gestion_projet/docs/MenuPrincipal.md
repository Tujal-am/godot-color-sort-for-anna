# Scene "MenuPrincipal"

## Description

Cette classe est le point d'entrée du projet GODOT. Elle représente le 1er menu de l'IHM et oriente vers les différentes activités.

## Diagramme de classe

```mermaid
classDiagram
class menu_principal.tscn {
    Label.TitreDuJeu
    BoutonJoueur
    TexteJoueur
    BoutonCampagne
    GridContainer.JoueursCampagne
    BoutonScore
    BoutonRéférences
    -_ready()
    -_on_bouton_joueur_pressed()
    -_on_texte_joueur_text_submitted(String nom_nouveau_joueur)
    -_on_bouton_campagne_pressed()
    -_mettre_a_jour_boutons_joueurs_campagne()
    -_creer_boutons_joueurs_campagne()
    -_on_joueurs_campagne_pressed(String nom_joueur)
    -_effacer_boutons_joueurs_campagne()
    -_on_bouton_scores_pressed()
    -_on_bouton_références_pressed()
}

menu_principal.tscn --> GestionScore
menu_principal.tscn --> references.tscn : change_scene_to_file()
menu_principal.tscn --> scores.tscn : change_scene_to_file()
menu_principal.tscn --> campagne.tscn : change_scene_to_file()

class GestionScore {
    initialiser_les_plateaux()
    lire_sauvegarde_joueurs()
    ajouter_un_nouveau_joueur()
    lire_la_liste_des_joueurs()
    choisir_le_joueur()
}
```
