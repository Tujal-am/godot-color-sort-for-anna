# LogService

Type : Service

Fichier principal : `sources/Singletons/log_service.gd`

## Rôle

Service de journalisation. Il centralise les événements techniques et les messages utiles au diagnostic.

## Responsabilité principale

- Enregistre les événements importants du système et des erreurs de runtime.
- Aide au débogage sans intervenir sur l’état du gameplay ni sur la UI.
- Conserve une vue unifiée des logs pour les développeurs et la maintenance.

## Dépendances

- `OS`

## Actions clés

- Consolide les arguments en une chaîne de texte
- Affiche les messages de débogage uniquement en build debug

## Points de vigilance

- L'écran ne doit pas écrire directement la sauvegarde si la logique de persistance est déjà dans un service.
- Les signaux doivent rester orientés métier et ne pas mélanger affichage, règles et données.
- Le composant est plus lisible s'il ne contient qu'une logique spécifique à son périmètre.

## Voir aussi

- [README de l'architecture](README.md)
- [Menu principal](scene-menu-principal.md)
- [Campagne](scene-campagne.md)
