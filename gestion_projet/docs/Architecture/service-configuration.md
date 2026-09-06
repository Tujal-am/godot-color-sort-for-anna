# SauvegardeConfigurationService

Type : Service de sauvegarde

Fichier principal : `sources/Singletons/Sauvegarde/configuration_service.gd`

## Rôle

Service de paramètres globaux. Il garde les préférences du jeu et les transmet à tous les composants qui les utilisent.

## Responsabilité principale

- Stocke les options de jeu telles que la musique, les effets et les vibrations.
- Expose les paramètres à l’interface et aux services qui en ont besoin.
- Centralise l’état des réglages pour éviter la duplication dans les scènes.

## Dépendances

- `FichiersJsonService`

## Actions clés

- Lit et écrit la configuration du jeu
- Vérifie la version et migre les anciennes sauvegardes si nécessaire

## Points de vigilance

- L'écran ne doit pas écrire directement la sauvegarde si la logique de persistance est déjà dans un service.
- Les signaux doivent rester orientés métier et ne pas mélanger affichage, règles et données.
- Le composant est plus lisible s'il ne contient qu'une logique spécifique à son périmètre.

## Voir aussi

- [README de l'architecture](README.md)
- [Menu principal](scene-menu-principal.md)
- [Campagne](scene-campagne.md)
