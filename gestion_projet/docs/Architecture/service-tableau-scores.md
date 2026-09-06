# SauvegardeTableauDesScoresService

Type : Service de sauvegarde

Fichier principal : `sources/Singletons/Sauvegarde/tableau_scores_service.gd`

## Rôle

Classement persistant des joueurs. Il stocke les scores et les rangs dans un format cohérent pour les écrans de classement.

## Responsabilité principale

- Enregistre et récupère les meilleurs scores du jeu.
- Calcule l’ordre du classement et les éléments d’affichage associés.
- Met à disposition les données de score sans qu’elles dépendent de la scène UI.

## Dépendances

- `FichiersJsonService`

## Actions clés

- Ajoute un joueur
- Incrémente le score
- Met à jour les rangs et le format d'affichage

## Points de vigilance

- L'écran ne doit pas écrire directement la sauvegarde si la logique de persistance est déjà dans un service.
- Les signaux doivent rester orientés métier et ne pas mélanger affichage, règles et données.
- Le composant est plus lisible s'il ne contient qu'une logique spécifique à son périmètre.

## Voir aussi

- [README de l'architecture](README.md)
- [Menu principal](scene-menu-principal.md)
- [Campagne](scene-campagne.md)
