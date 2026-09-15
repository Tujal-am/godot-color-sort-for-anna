# ScoreService

Type : Service

Fichier principal : `sources/Singletons/score_service.gd`

## Rôle

Calculateur de score. Il convertit le déroulement d’une partie en score exploitable par la progression et le classement.

## Responsabilité principale

- Compose le score final à partir du résultat, du temps et du contexte de campagne.
- Applique les bonus ou coefficients propres à une ascension ou à un niveau.
- Exporte un résultat cohérent pour les services de sauvegarde et d’affichage.

## Dépendances

- `SauvegardeBddJoueursService`
- `SauvegardeTableauDesScoresService`
- `LogService`

## Actions clés

- Évalue le score de durée
- Évalue le score de ratio de réussite
- Applique le bonus Anna

## Points de vigilance

- L'écran ne doit pas écrire directement la sauvegarde si la logique de persistance est déjà dans un service.
- Les signaux doivent rester orientés métier et ne pas mélanger affichage, règles et données.
- Le composant est plus lisible s'il ne contient qu'une logique spécifique à son périmètre.

## Voir aussi

- [README de l'architecture](README.md)
- [Menu principal](scene-menu-principal.md)
- [Campagne](scene-campagne.md)
