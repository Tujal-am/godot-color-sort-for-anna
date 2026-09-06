# Statistiques

Type : UI

Fichier principal : `sources/Scenes/MenuPrincipal/Campagne/MenuCampagne/Statistiques/statistiques.gd`

## Rôle

Tableau de bord des performances. Il assemble les métriques de jeu et les rend lisibles pour le joueur ou la campagne.

## Responsabilité principale

- Lit les services de statistiques et de progression pour reconstruire l’état actuel.
- Affiche des KPI et des séries de données sans calculer la logique métier.
- Donne une vue cohérente sur l’ascension, le plateau et les performances globales.

## Dépendances

- `StatsService`
- `SauvegardeBddJoueursService`
- `AudioService`

## Actions clés

- Affiche les KPI campagne/ascension/plateau
- Retourne vers le menu campagne ou principal
- Synthétise les valeurs de score et de temps

## Points de vigilance

- L'écran ne doit pas écrire directement la sauvegarde si la logique de persistance est déjà dans un service.
- Les signaux doivent rester orientés métier et ne pas mélanger affichage, règles et données.
- Le composant est plus lisible s'il ne contient qu'une logique spécifique à son périmètre.

## Voir aussi

- [README de l'architecture](README.md)
- [Menu principal](scene-menu-principal.md)
- [Campagne](scene-campagne.md)
