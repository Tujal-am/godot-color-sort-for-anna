# VibrationService

Type : Service

Fichier principal : `sources/Singletons/vibration_service.gd`

## Rôle

Retour haptique du jeu. Il active les vibrations lorsque le joueur ou le système le demande, selon la configuration active.

## Responsabilité principale

- Contrôle les vibrations de l’appareil selon les événements de jeu.
- Respecte la configuration de l’utilisateur et les préférences d’accessibilité.
- Reste un service transversal, sans prendre en charge la logique de plateau.

## Dépendances

- `SauvegardeConfigurationService`
- `Input`

## Actions clés

- Vibre à la fin d'un plateau
- Vibre à la fin d'une pile
- Vibre à chaque jeton déplacé

## Points de vigilance

- L'écran ne doit pas écrire directement la sauvegarde si la logique de persistance est déjà dans un service.
- Les signaux doivent rester orientés métier et ne pas mélanger affichage, règles et données.
- Le composant est plus lisible s'il ne contient qu'une logique spécifique à son périmètre.

## Voir aussi

- [README de l'architecture](README.md)
- [Menu principal](scene-menu-principal.md)
- [Campagne](scene-campagne.md)
