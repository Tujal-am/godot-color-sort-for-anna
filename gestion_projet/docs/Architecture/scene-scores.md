# Scores

Type : UI

Fichier principal : `sources/Scenes/MenuPrincipal/Scores/scores.gd`

## Rôle

Écran du classement. Il donne une vue de hiérarchie sur les résultats obtenus et les performances récentes.

## Responsabilité principale

- Lit le tableau des scores et le classe dans l’ordre attendu.
- Affiche le rang, le score et les résultats du joueur courant.
- Reste un écran de présentation, sans décider de la logique de calcul du score.

## Dépendances

- `SauvegardeTableauDesScoresService`
- `AudioService`

## Actions clés

- Lit le classement
- Met à jour l'affichage du podium
- Relie le retour au menu principal

## Points de vigilance

- L'écran ne doit pas écrire directement la sauvegarde si la logique de persistance est déjà dans un service.
- Les signaux doivent rester orientés métier et ne pas mélanger affichage, règles et données.
- Le composant est plus lisible s'il ne contient qu'une logique spécifique à son périmètre.

## Voir aussi

- [README de l'architecture](README.md)
- [Menu principal](scene-menu-principal.md)
- [Campagne](scene-campagne.md)
