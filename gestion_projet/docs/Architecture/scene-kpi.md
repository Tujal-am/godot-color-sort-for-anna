# KPI

Type : UI

Fichier principal : `sources/Scenes/MenuPrincipal/Campagne/MenuCampagne/Statistiques/kpi.gd`

## Rôle

Composant de métrique minimaliste. Son rôle est de rendre une donnée chiffrée compréhensible visuellement.

## Responsabilité principale

- Affiche une valeur chiffrée dans un format réutilisable.
- Rend les KPI cohérents visuellement sans recalculer leur logique.
- Donne au tableau de bord un bloc de lecture rapide et standardisé.

## Dépendances

- `statistiques.gd`

## Actions clés

- Affiche des indicateurs simples de manière homogène
- Permet de répéter la même structure pour plusieurs métriques

## Points de vigilance

- L'écran ne doit pas écrire directement la sauvegarde si la logique de persistance est déjà dans un service.
- Les signaux doivent rester orientés métier et ne pas mélanger affichage, règles et données.
- Le composant est plus lisible s'il ne contient qu'une logique spécifique à son périmètre.

## Voir aussi

- [README de l'architecture](README.md)
- [Menu principal](scene-menu-principal.md)
- [Campagne](scene-campagne.md)
