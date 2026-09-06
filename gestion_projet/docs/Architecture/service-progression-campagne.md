# ProgressionCampagneService

Type : Service

Fichier principal : `sources/Singletons/progression_campagne_service.gd`

## Rôle

Cœur de la progression du jeu. Il décide de l’état de l’ascension, du niveau courant et des événements de fin de campagne.

## Responsabilité principale

- Initialise ou met à jour l’ascension en cours selon le résultat d’une partie.
- Publie les signaux de progression et de fin de campagne pour le reste du système.
- Centralise l’état métier de la campagne, sans dépendre directement du rendu UI.

## Dépendances

- `SauvegardeBddJoueursService`
- `SauvegardeListeJoueursService`
- `SauvegardeTableauDesScoresService`
- `ScoreService`

## Actions clés

- Crée une nouvelle ascension
- Passe au niveau supérieur ou inférieur selon le résultat
- Émet les signaux progression_ascension et fin_ascension

## Points de vigilance

- L'écran ne doit pas écrire directement la sauvegarde si la logique de persistance est déjà dans un service.
- Les signaux doivent rester orientés métier et ne pas mélanger affichage, règles et données.
- Le composant est plus lisible s'il ne contient qu'une logique spécifique à son périmètre.

## Voir aussi

- [README de l'architecture](README.md)
- [Menu principal](scene-menu-principal.md)
- [Campagne](scene-campagne.md)
