# FichiersJsonService

Type : Service technique

Fichier principal : `sources/Singletons/Sauvegarde/fichiers_json_service.gd`

## Rôle

Couche technique de lecture et d’écriture JSON. Il gère les fichiers de données sans répartir cette responsabilité dans les scènes.

## Responsabilité principale

- Lit les structures JSON du jeu et les transforme en objets utilisables.
- Écrit les données persistantes et centralise les erreurs de chargement.
- Fournit une interface stable à la persistance sans coupler les services à un format brut.

## Dépendances

- `FileAccess`
- `JSON`

## Actions clés

- Lit un fichier JSON
- Écrit un fichier JSON
- Supprime ou vérifie l'existence d'un fichier

## Points de vigilance

- L'écran ne doit pas écrire directement la sauvegarde si la logique de persistance est déjà dans un service.
- Les signaux doivent rester orientés métier et ne pas mélanger affichage, règles et données.
- Le composant est plus lisible s'il ne contient qu'une logique spécifique à son périmètre.

## Voir aussi

- [README de l'architecture](README.md)
- [Menu principal](scene-menu-principal.md)
- [Campagne](scene-campagne.md)
