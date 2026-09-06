# Qui perd gagne

Type : Gameplay

Fichier principal : `sources/Scenes/MenuPrincipal/Campagne/GamePlay/QuiPerdGagne/qui_perd_gagne.gd`

## Rôle

Variante de règle alternative. Il oriente la fin de partie selon une autre lecture du plateau et de ses états.

## Responsabilité principale

- Applique une règle de fin de partie spécifique au mode « qui perd gagne ».
- Convertit les états du plateau en verdict de partie exploitable par la campagne.
- Isole la règle métier de la variante pour garder le moteur de plateau plus générique.

## Dépendances

- `Plateau`
- `Campagne`
- `LogService`

## Actions clés

- Déclenche la victoire lorsque la règle de jeu est satisfaite
- Relaye les signaux d'abandon et d'erreur

## Points de vigilance

- L'écran ne doit pas écrire directement la sauvegarde si la logique de persistance est déjà dans un service.
- Les signaux doivent rester orientés métier et ne pas mélanger affichage, règles et données.
- Le composant est plus lisible s'il ne contient qu'une logique spécifique à son périmètre.

## Voir aussi

- [README de l'architecture](README.md)
- [Menu principal](scene-menu-principal.md)
- [Campagne](scene-campagne.md)
