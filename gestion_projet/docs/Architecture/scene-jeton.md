# Jeton

Type : Scene

Fichier principal : `sources/Scenes/MenuPrincipal/Campagne/Plateau/Pile/Jeton/jeton.gd`

## Rôle

Unité élémentaire du plateau. Il porte la couleur, la sélection et le rendu du jeton au sein de la pile.

## Responsabilité principale

- Représente visuellement un jeton avec ses attributs de couleur et de position.
- Renseigne la pile sur l’état de sélection et de connexion avec les jetons adjacents.
- Permet au plateau de raisonner sur des éléments simples et homogènes.

## Dépendances

- `Pile`
- `Plateau`

## Actions clés

- Gère l'apparence du jeton
- Indique son niveau de sélection et de soudure
- Fournit la couleur / index au plateau

## Points de vigilance

- L'écran ne doit pas écrire directement la sauvegarde si la logique de persistance est déjà dans un service.
- Les signaux doivent rester orientés métier et ne pas mélanger affichage, règles et données.
- Le composant est plus lisible s'il ne contient qu'une logique spécifique à son périmètre.

## Voir aussi

- [README de l'architecture](README.md)
- [ProgressionCampagneService](service-progression-campagne.md)
- [SauvegardeBddJoueursService](service-bdd-joueurs.md)
