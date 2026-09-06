# Scene "Scores"

## Description

Cette classe correspond à la scene des scores. Consuklte la liste de joueurs et les classes selon leur score et attribue un trophé au podium.

## Diagramme de classe

```mermaid
classDiagram
class scores.tscn {
    Fond
    TitreScores
    ListeScore
    emoji_1er
    emoji_2ond
    emoji_3eme
    liste_format_scores
    _ready()
}

    scores.tscn --> retour_menu_principal.gd
    scores.tscn --> GestionScore

class GestionScore {
    lire_la_liste_des_joueurs()
    lire_le_score_du_joueur()
}
```