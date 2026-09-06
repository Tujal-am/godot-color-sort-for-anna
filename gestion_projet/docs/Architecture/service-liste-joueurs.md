# SauvegardeListeJoueursService

Type : Service de sauvegarde

Fichier principal : `sources/Singletons/Sauvegarde/liste_joueurs_service.gd`

## Rôle

Index des profils connus. Il centralise la liste des joueurs et la correspondance avec leur sauvegarde associée.

## Responsabilité principale

- Maintient la liste des profils disponibles pour le jeu.
- Résout le bon fichier de sauvegarde pour un joueur donné.
- Fournit une couche de navigation durable entre la sélection du joueur et la persistance.

## Dépendances

- `FichiersJsonService`

## Actions clés

- Crée la fiche d'un nouveau joueur
- Vérifie si un joueur existe
- Retourne le fichier de sauvegarde associé

## Points de vigilance

- L'écran ne doit pas écrire directement la sauvegarde si la logique de persistance est déjà dans un service.
- Les signaux doivent rester orientés métier et ne pas mélanger affichage, règles et données.
- Le composant est plus lisible s'il ne contient qu'une logique spécifique à son périmètre.

## Voir aussi

- [README de l'architecture](README.md)
- [Menu principal](scene-menu-principal.md)
- [Campagne](scene-campagne.md)
