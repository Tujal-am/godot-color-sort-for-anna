# Références

Type : UI

Fichier principal : `sources/Scenes/MenuPrincipal/References/retour_menu_principal.gd`

## Rôle

Écran de références et d’information. Il centralise le contexte du projet et les liens utiles sans prendre de décision de jeu.

## Responsabilité principale

- Affiche les références au projet et les éléments d’aide contextuelle.
- Fournit les points d’entrée de navigation vers les autres écrans.
- Conserve un rôle de documentation et d’orientation, sans logique métier.

## Dépendances

- `AudioService`

## Actions clés

- Retourne au menu principal

## Points de vigilance

- L'écran ne doit pas écrire directement la sauvegarde si la logique de persistance est déjà dans un service.
- Les signaux doivent rester orientés métier et ne pas mélanger affichage, règles et données.
- Le composant est plus lisible s'il ne contient qu'une logique spécifique à son périmètre.

## Voir aussi

- [README de l'architecture](README.md)
- [Menu principal](scene-menu-principal.md)
- [Campagne](scene-campagne.md)
