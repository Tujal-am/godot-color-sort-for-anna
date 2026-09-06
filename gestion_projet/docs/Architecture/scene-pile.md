# Pile

Type : Scene

Fichier principal : `sources/Scenes/MenuPrincipal/Campagne/Plateau/Pile/pile.gd`

## Rôle

Colonne de jeu du plateau. Elle représente une pile concrète et garde le sens de l’ordre et de la hauteur des jetons.

## Responsabilité principale

- Stocke l’état interne d’une pile et ses jetons actifs.
- Détermine si la pile est jouable, sélectionnable ou bloquée selon la règle de jeu.
- Fournit le contexte visuel nécessaire aux interactions de déplacement sur le plateau.

## Dépendances

- `Jeton`
- `Plateau`
- `PlateauReglesDuJeuService`

## Actions clés

- Applique les couleurs et la validité du sommet
- Choisit le jeton de départ et les destinations valides
- Marque les piles bloquées ou terminées

## Points de vigilance

- L'écran ne doit pas écrire directement la sauvegarde si la logique de persistance est déjà dans un service.
- Les signaux doivent rester orientés métier et ne pas mélanger affichage, règles et données.
- Le composant est plus lisible s'il ne contient qu'une logique spécifique à son périmètre.

## Voir aussi

- [README de l'architecture](README.md)
- [ProgressionCampagneService](service-progression-campagne.md)
- [SauvegardeBddJoueursService](service-bdd-joueurs.md)
