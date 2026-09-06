# SauvegardeBddPlateauxService

Type : Service de sauvegarde

Fichier principal : `sources/Singletons/Sauvegarde/bdd_plateaux_service.gd`

## Rôle

Banque de niveaux et de plateaux. Il expose les configurations de jeu nécessaires à la génération et au chargement d’un niveau.

## Responsabilité principale

- Charge les définitions des niveaux et des grilles de jeu depuis la base du projet.
- Fournit les données structurées nécessaires au plateau et au gameplay.
- Sert de source de vérité pour les configurations de contenu sans les mélanger à l’UI.

## Dépendances

- `FichiersJsonService`

## Actions clés

- Lit la campagne depuis le JSON
- Extrait les niveaux et les plateaux
- Fournit la structure de données à la sauvegarde d'un joueur

## Points de vigilance

- L'écran ne doit pas écrire directement la sauvegarde si la logique de persistance est déjà dans un service.
- Les signaux doivent rester orientés métier et ne pas mélanger affichage, règles et données.
- Le composant est plus lisible s'il ne contient qu'une logique spécifique à son périmètre.

## Voir aussi

- [README de l'architecture](README.md)
- [Menu principal](scene-menu-principal.md)
- [Campagne](scene-campagne.md)
