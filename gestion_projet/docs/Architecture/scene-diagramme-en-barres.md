# Diagramme en barres

Type : UI

Fichier principal : `sources/Scenes/MenuPrincipal/Campagne/MenuCampagne/Statistiques/diagramme_en_barres.gd`

## Rôle

Composant visuel de comparaison. Il transforme un ensemble de valeurs en diagramme horizontal ou vertical lisible.

## Responsabilité principale

- Affiche une série de données sous forme de barres pour comparer les performances.
- Organise la lecture visuelle sans ajouter de logique métier au calcul.
- Fournit un support réutilisable pour le tableau de statistiques du jeu.

## Dépendances

- `Statistiques`
- `StatsService`

## Actions clés

- Dessine les barres selon des séries ou des valeurs
- Prépare le support visuel des courbes de succès ou de parties

## Points de vigilance

- L'écran ne doit pas écrire directement la sauvegarde si la logique de persistance est déjà dans un service.
- Les signaux doivent rester orientés métier et ne pas mélanger affichage, règles et données.
- Le composant est plus lisible s'il ne contient qu'une logique spécifique à son périmètre.

## Voir aussi

- [README de l'architecture](README.md)
- [Menu principal](scene-menu-principal.md)
- [Campagne](scene-campagne.md)
