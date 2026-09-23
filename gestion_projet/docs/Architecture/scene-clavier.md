# Clavier

Type : UI

Fichier principal : `sources/Scenes/MenuPrincipal/Clavier/clavier.gd`

## Rôle

Clavier virtuel de saisie. Il collecte les caractères du pseudo et les transmet à la scène qui décide de la suite.

## Responsabilité principale

- Capte les entrées utilisateur du pseudo ou du nom de joueur.
- Valide et transmet les caractères à la scène appelante.
- N’a pas de logique de jeu ; il agit comme un contrôleur d’interface léger.

## Dépendances

- `menu_principal.gd`
- `OS`

## Actions clés

- Ouvre/ferme un clavier spécifique
- Relaye le pseudo saisi à la scène parente

## Points de vigilance

- L'écran ne doit pas écrire directement la sauvegarde si la logique de persistance est déjà dans un service.
- Les signaux doivent rester orientés métier et ne pas mélanger affichage, règles et données.
- Le composant est plus lisible s'il ne contient qu'une logique spécifique à son périmètre.

## Voir aussi

- [README de l'architecture](README.md)
- [Menu principal](scene-menu-principal.md)
- [Campagne](scene-campagne.md)
