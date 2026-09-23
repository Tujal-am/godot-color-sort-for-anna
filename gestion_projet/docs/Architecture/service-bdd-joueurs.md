# SauvegardeBddJoueursService

Type : Service de sauvegarde

Fichier principal : `sources/Singletons/Sauvegarde/bdd_joueurs_service.gd`

## Rôle

Sauvegarde du profil et de la progression du joueur. Il garde l’état du compte, de l’ascension et des données de jeu en cours.

## Responsabilité principale

- Lit et écrit les données personnelles du joueur courant.
- Conserve les plateaux restants, l’ascension en cours et l’état de progression.
- Fournit la source de vérité des données de joueur pour la campagne et l’UI.

## Dépendances

- `FichiersJsonService`
- `ProgressionCampagneService`
- `SauvegardeListeJoueursService`

## Actions clés

- Lit / écrit la sauvegarde du joueur
- Gère les plateaux non joués et les plateaux en cours
- Termine ou abandonne un plateau/ascension

## Points de vigilance

- L'écran ne doit pas écrire directement la sauvegarde si la logique de persistance est déjà dans un service.
- Les signaux doivent rester orientés métier et ne pas mélanger affichage, règles et données.
- Le composant est plus lisible s'il ne contient qu'une logique spécifique à son périmètre.

## Voir aussi

- [README de l'architecture](README.md)
- [Menu principal](scene-menu-principal.md)
- [Campagne](scene-campagne.md)
