# StatsService

Type : Service

Fichier principal : `sources/Singletons/stats_service.gd`

## Rôle

Agrégateur de statistiques. Il transforme les données du jeu en métriques lisibles et réutilisables par l’UI.

## Responsabilité principale

- Collecte les indicateurs de jeu et d’ascension en un état centralisé.
- Calcule les moyennes, totaux et courbes utiles aux écrans de statistiques.
- Fournit des données prêtes à afficher sans mordre sur la logique de rendu.

## Dépendances

- `SauvegardeBddJoueursService`
- `SauvegardeConfigurationService`
- `LogService`

## Actions clés

- Calcule le taux de complétion
- Déduit la durée moyenne des ascensions et des plateaux
- Expose les infos pour l'UI de statistiques

## Points de vigilance

- L'écran ne doit pas écrire directement la sauvegarde si la logique de persistance est déjà dans un service.
- Les signaux doivent rester orientés métier et ne pas mélanger affichage, règles et données.
- Le composant est plus lisible s'il ne contient qu'une logique spécifique à son périmètre.

## Voir aussi

- [README de l'architecture](README.md)
- [Menu principal](scene-menu-principal.md)
- [Campagne](scene-campagne.md)
