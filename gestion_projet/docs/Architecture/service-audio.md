# AudioService

Type : Service

Fichier principal : `sources/Singletons/audio_service.gd`

## Rôle

Moteur audio global. Il choisit la musique et les effets sonores selon le contexte courant du jeu et les réglages du joueur.

## Responsabilité principale

- Joue la musique adaptée à l’état du jeu et à la progression de l’ascension.
- Gère les effets sonores d’interface et de résultat sans dépendre du rendu de scène.
- Lit la configuration du joueur pour appliquer les préférences audio de manière cohérente.

## Dépendances

- `SauvegardeConfigurationService`
- `StatsService`

## Actions clés

- Joue les musiques de progression d'ascension
- Joue les sons d'interface / mouvement / victoire / abandon

## Points de vigilance

- L'écran ne doit pas écrire directement la sauvegarde si la logique de persistance est déjà dans un service.
- Les signaux doivent rester orientés métier et ne pas mélanger affichage, règles et données.
- Le composant est plus lisible s'il ne contient qu'une logique spécifique à son périmètre.

## Voir aussi

- [README de l'architecture](README.md)
- [Menu principal](scene-menu-principal.md)
- [Campagne](scene-campagne.md)
