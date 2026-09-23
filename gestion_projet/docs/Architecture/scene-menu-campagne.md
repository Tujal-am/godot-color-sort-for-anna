# Menu campagne

Type : UI

Fichier principal : `sources/Scenes/MenuPrincipal/Campagne/MenuCampagne/menu_campagne.gd`

## Rôle

Écran d’interface de préparation avant une partie. Il résume l’ascension du joueur et donne le contexte nécessaire pour démarrer le plateau.

## Responsabilité principale

- Affiche l’état de l’ascension, le niveau courant et les informations utiles au lancement.
- Relaye le démarrage de la partie vers le moteur de jeu sans en porter la logique.
- Sert de vue lisible sur les données déjà produites par les services.

## Dépendances

- `ProgressionCampagneService`
- `StatsService`
- `FormatterMenuCampagne`
- `AudioService`

## Actions clés

- Affiche les infos du joueur
- Choisit la longueur de l'ascension
- Lance le plateau et navigue vers les stats

## Points de vigilance

- L'écran ne doit pas écrire directement la sauvegarde si la logique de persistance est déjà dans un service.
- Les signaux doivent rester orientés métier et ne pas mélanger affichage, règles et données.
- Le composant est plus lisible s'il ne contient qu'une logique spécifique à son périmètre.

## Voir aussi

- [README de l'architecture](README.md)
- [Menu principal](scene-menu-principal.md)
- [Campagne](scene-campagne.md)
