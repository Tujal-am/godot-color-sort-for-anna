# Classique

Type : Gameplay

Fichier principal : `sources/Scenes/MenuPrincipal/Campagne/GamePlay/Classique/classique.gd`

## Rôle

Mode de jeu standard. Ce script traduit la règle métier du plateau en événements de fin de partie, de victoire ou d’abandon.

## Responsabilité principale

- Évalue si le plateau est terminé selon la logique de jeu classique.
- Émet les signaux de victoire ou d’abandon lorsque la règle est validée.
- Garde la logique de variante propre au mode classique, sans gérer les sauvegardes.

## Dépendances

- `Plateau`
- `Campagne`
- `LogService`

## Actions clés

- Déclenche la victoire quand le plateau est terminé
- Relaye abandon et invalidité
- Couvre la logique de victoire standard

## Points de vigilance

- L'écran ne doit pas écrire directement la sauvegarde si la logique de persistance est déjà dans un service.
- Les signaux doivent rester orientés métier et ne pas mélanger affichage, règles et données.
- Le composant est plus lisible s'il ne contient qu'une logique spécifique à son périmètre.

## Voir aussi

- [README de l'architecture](README.md)
- [Menu principal](scene-menu-principal.md)
- [Campagne](scene-campagne.md)
