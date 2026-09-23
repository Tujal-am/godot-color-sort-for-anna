# Plateau

Type : Scene

Fichier principal : `sources/Scenes/MenuPrincipal/Campagne/Plateau/plateau.gd`

## Rôle

Moteur visuel du plateau. Il construit la structure du terrain, valide les mouvements et reflète l’état du jeu au bon niveau de granularité.

## Responsabilité principale

- Crée les piles et les jetons à partir de la configuration du niveau.
- Valide les déplacements au niveau du plateau et applique la logique de sélection.
- Relaye la fin de partie au gameplay sans absorber la logique métier de progression.

## Dépendances

- `PlateauLayoutService`
- `PlateauDecodeurService`
- `PlateauReglesDuJeuService`
- `SauvegardeBddJoueursService`
- `AudioService`
- `VibrationService`

## Actions clés

- Crée les piles à partir du texte du plateau
- Valide le déplacement d'un jeton ou d'une pile
- Détecte la fin de partie via le callback gameplay

## Points de vigilance

- L'écran ne doit pas écrire directement la sauvegarde si la logique de persistance est déjà dans un service.
- Les signaux doivent rester orientés métier et ne pas mélanger affichage, règles et données.
- Le composant est plus lisible s'il ne contient qu'une logique spécifique à son périmètre.

## Voir aussi

- [README de l'architecture](README.md)
- [ProgressionCampagneService](service-progression-campagne.md)
- [SauvegardeBddJoueursService](service-bdd-joueurs.md)
