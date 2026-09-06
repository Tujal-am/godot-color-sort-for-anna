# Campagne

Type : Scene

Fichier principal : `sources/Scenes/MenuPrincipal/Campagne/campagne.gd`

## Rôle

Orchestrateur de la campagne. Il décide quelle variante de jeu est lancée, suit les résultats et fait passer l’état de progression d’un écran à l’autre.

## Responsabilité principale

- Lance la scène de gameplay correspondante à la progression du joueur.
- Relie les événements de victoire, défaite et abandon au service de progression.
- Ne calcule pas le plateau : il coordonne le parcours de jeu et l’affichage associé.

## Dépendances

- `ProgressionCampagneService`
- `SauvegardeBddJoueursService`
- `SauvegardeTableauDesScoresService`
- `StatsService`
- `AudioService`

## Actions clés

- Lance le bon gameplay pour un plateau
- Met à jour la progression de l'ascension
- Fait évoluer l'état de victoire ou d'abandon

## Points de vigilance

- L'écran ne doit pas écrire directement la sauvegarde si la logique de persistance est déjà dans un service.
- Les signaux doivent rester orientés métier et ne pas mélanger affichage, règles et données.
- Le composant est plus lisible s'il ne contient qu'une logique spécifique à son périmètre.

## Voir aussi

- [README de l'architecture](README.md)
- [ProgressionCampagneService](service-progression-campagne.md)
- [SauvegardeBddJoueursService](service-bdd-joueurs.md)
