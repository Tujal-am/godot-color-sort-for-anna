# Menu principal

Type : Scene

Fichier principal : `sources/Scenes/MenuPrincipal/menu_principal.gd`

## Rôle

Point d’entrée de la navigation du jeu. Le script oriente la sélection du profil, ouvre les écrans de campagne, de scores et de références, et délègue la logique métier aux services.

## Responsabilité principale

- Choisit le profil courant et prépare le flux de navigation du jeu.
- Ouvre les écrans de campagne, de scores et de références sans gérer les règles du plateau.
- Relie la configuration et la sauvegarde aux interactions de l’interface.

## Dépendances

- `ProgressionCampagneService`
- `SauvegardeListeJoueursService`
- `SauvegardeConfigurationService`
- `AudioService`

## Actions clés

- Ouvre les scènes de campagne, scores et références
- Affiche et met à jour les boutons de joueurs
- Applique les réglages audio/vibration

## Points de vigilance

- L'écran ne doit pas écrire directement la sauvegarde si la logique de persistance est déjà dans un service.
- Les signaux doivent rester orientés métier et ne pas mélanger affichage, règles et données.
- Le composant est plus lisible s'il ne contient qu'une logique spécifique à son périmètre.

## Voir aussi

- [README de l'architecture](README.md)
- [ProgressionCampagneService](service-progression-campagne.md)
- [SauvegardeBddJoueursService](service-bdd-joueurs.md)
