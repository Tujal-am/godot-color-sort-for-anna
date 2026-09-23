# Courbe

Type : UI

Fichier principal : `sources/Scenes/MenuPrincipal/Campagne/MenuCampagne/Statistiques/courbe.gd`

## Rôle

Composant de visualisation temporelle. Il montre l’évolution d’un indicateur sur la durée de la campagne ou d’une ascension.

## Responsabilité principale

- Trace une courbe à partir des données disponibles en entrée.
- Met en valeur la progression ou la variation d’un indicateur sur le temps.
- Reste un outil d’affichage, sans décider de la progression ni des règles du jeu.

## Dépendances

- `StatsService`
- `Statistiques`

## Actions clés

- Trace la courbe d'évolution du temps ou du score
- Complète l'offre visuelle des statistiques

## Points de vigilance

- L'écran ne doit pas écrire directement la sauvegarde si la logique de persistance est déjà dans un service.
- Les signaux doivent rester orientés métier et ne pas mélanger affichage, règles et données.
- Le composant est plus lisible s'il ne contient qu'une logique spécifique à son périmètre.

## Voir aussi

- [README de l'architecture](README.md)
- [Menu principal](scene-menu-principal.md)
- [Campagne](scene-campagne.md)
