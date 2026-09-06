# Architecture du projet

Ce document résume les grandes familles de scripts et le rôle de chacun, sans se baser uniquement sur les commentaires. Il a été vérifié sur les fichiers réels du projet dans `sources/Scenes` et `sources/Singletons`.

## Vue d'ensemble rapide

Le projet se lit mieux si on le pense en 4 couches distinctes, qui communiquent entre elles mais ne doivent pas se mélanger :

```text
UI / navigation
    menu_principal.gd
    campagne.gd
    menu_campagne.gd
    statistiques.gd
        | lit les données de services
        v
Gameplay / règles de partie
    classique.gd
    qui_perd_gagne.gd
    plateau.gd
    pile.gd
    jeton.gd
        | décide la fin de partie / émet les événements
        v
Services / orchestration
    progression_campagne_service.gd
    score_service.gd
    stats_service.gd
    audio_service.gd
    vibration_service.gd
    log_service.gd
        | garde l'état du système et les calculs transverses
        v
Persistence / données
    bdd_joueurs_service.gd
    bdd_plateaux_service.gd
    liste_joueurs_service.gd
    tableau_scores_service.gd
    configuration_service.gd
    fichiers_json_service.gd
```

Ce schéma mental est important :

- L'UI ne doit pas contenir la logique de progression du jeu.
- Le gameplay ne doit pas gérer la persistance des joueurs.
- Les services sont le point de convergence de l'état global.
- La sauvegarde est la source de vérité des données.

## 1. Les grandes familles de scripts

### A. Scènes de navigation et d'entrée
Ce sont les écrans qui dirigent le flux du jeu et ouvrent les autres scènes.

- `menu_principal.gd`
  - Point d'entrée du projet.
  - Gère la création d'un joueur, le choix du profil, l'accès à la campagne, aux scores et aux références.
  - Ne contient pas la logique métier des plateaux : il délègue vers les services.

- `campagne.gd`
  - Orchestrateur de la campagne.
  - Choisit le bon gameplay, lance un plateau, suit les victoires/défaites et pilote la progression globale.
  - Relie la logique de progression à l'interface du menu campagne.

- `scores.gd`
  - Écran du classement.
  - Lit le tableau des scores et affiche le rang et le score global.

- `retour_menu_principal.gd`
  - Simple écran de référence / retour.
  - Son rôle est surtout de navigation, pas de logique de jeu.

### B. Scènes de gameplay
Ce sont les règles spécifiques à une variante de jeu.

- `classique.gd`
  - Gameplay standard.
  - Détecte si le plateau est terminé selon la logique "piles non vides et monochromes".
  - Émet les signaux de victoire, abandon ou plateau invalide.

- `qui_perd_gagne.gd`
  - Variante de gameplay.
  - Relaye la fin de partie selon une règle spécifique.
  - Sa logique reste isolée du moteur de plateau.

### C. Scènes de plateau, piles et jetons
Ce sont les éléments du moteur de jeu du plateau.

- `plateau.gd`
  - Moteur du plateau.
  - Crée les piles, valide les déplacements, détermine les sélections et relaye la fin de partie.
  - C'est le point central de la mécanique de jeu sur le plateau.

- `pile.gd`
  - Représente une colonne du plateau.
  - Gère les jetons contenus, leur ordre, leur sélection, leur couleur au sommet, leur statut terminé/bloqué.
  - C'est le composant qui sait si une pile est jouable ou non.

- `jeton.gd`
  - Unité visuelle et logique d'un jeton.
  - Gère la couleur, la sélection, la soudure entre jetons identiques, et la position dans la pile.

- `decodeur_service.gd`
  - Outil de parsing du plateau.
  - Convertit une chaine de plateau en structure exploitable par le moteur.

- `layout_service.gd`
  - Service de placement.
  - Calcule la disposition des piles et la position de chaque élément sur l'écran.

- `regle_du_jeu_service.gd`
  - Règles de mouvement et validation des transferts.
  - Applique les conditions booléennes permettant ou refusant un déplacement.

### D. Scènes d'interface et de statistiques
Ce sont les écrans d'affichage de l'état du joueur.

- `menu_campagne.gd`
  - Interface intermédiaire entre la campagne et le plateau.
  - Affiche l'état du joueur, la longueur d'ascension, les messages de victoire/défaite et le bouton de démarrage.

- `statistiques.gd`
  - Tableau de bord des performances.
  - Lit les services statistiques et affiche KPI / valeurs de campagne / ascension / plateau.

- `kpi.gd`
  - Petit composant d'affichage de métrique.
  - Ne calcule pas : il affiche simplement des valeurs dans un format réutilisable.

- `diagramme_en_barres.gd`
  - Composant visuel pour représenter des séries ou comparaisons.

- `courbe.gd`
  - Composant visuel pour tracer l'évolution de données temporelles ou progressives.

- `clavier.gd`
  - Clavier virtuel pour la saisie d'un pseudo.
  - N'a pas de logique de jeu : il relaye simplement la saisie à la scène appelante.

### E. Services globaux du jeu
Ce sont les pièces qui gardent l'état du système et exposent des méthodes transverses.

- `audio_service.gd`
  - Joue les musiques et effets sonores du jeu.
  - Choisit la musique selon le niveau de progression de l'ascension.

- `log_service.gd`
  - Service de debug.
  - Centralise l'affichage des logs et erreurs du projet.

- `vibration_service.gd`
  - Retour haptique du jeu.
  - S'applique uniquement si les vibrations sont activées.

- `progression_campagne_service.gd`
  - Cœur de la progression.
  - Gère les ascensions, les changements de niveau, la fin de campagne et les signaux de progression.

- `score_service.gd`
  - Calcule le score obtenu après une victoire.
  - Intègre le temps, le ratio, l'ascension, la campagne et le bonus spécifique.

- `stats_service.gd`
  - Agrège les données de jeu pour produire les statistiques visibles.
  - Il ne rend pas l'UI ; il fournit les chiffres.

### F. Services de sauvegarde et données
Ce sont les services qui lisent et écrivent les données persistantes.

- `bdd_joueurs_service.gd`
  - Sauvegarde de la progression du joueur courant.
  - Gère le nom, les plateaux restants, l'ascension en cours, les parties, etc.

- `bdd_plateaux_service.gd`
  - Banque de niveaux et de plateaux.
  - Lit le fichier JSON de campagne et fournit les listes de plateaux.

- `liste_joueurs_service.gd`
  - Index central des joueurs connus.
  - Gère la correspondance entre nom et fichier de sauvegarde.

- `tableau_scores_service.gd`
  - Classement des joueurs.
  - Gère score, rang, affichage et trophée.

- `configuration_service.gd`
  - Paramètres globaux du jeu : version, musique, effets sonores, vibrations.

- `fichiers_json_service.gd`
  - Couche technique pour lire et écrire les fichiers JSON.
  - Centralise le parsing et les erreurs de lecture/écriture.

## 2. Rôle général des familles de scripts

- Les scènes de navigation pilotent le flux du jeu.
- Les scènes de gameplay ne stockent pas l'état persistant du joueur.
- Les scènes de plateau sont le moteur de la mécanique de jeu.
- Les services fournissent l'état global et la logique transversale.
- Les services de sauvegarde sont la source de vérité des données.
- Les interfaces (UI) lisent les services pour afficher les informations, sans décider de la logique métier.

## 3. Règle de séparation

- Les scènes s'occupent du rendu et de l'orchestration.
- Les services gèrent les règles et les données transverses.
- Les règles spécifiques à un mode de jeu restent dans les scripts de gameplay.
- La persistance n'est pas dans la scène de plateau ni dans l'UI.

## 4. Synthèse rapide

Si on simplifie l'architecture du projet :

- `menu_principal` lance le jeu.
- `campagne` décide du chemin de progression.
- `plateau` exécute le gameplay visuel.
- `pile` et `jeton` représentent les briques du plateau.
- `classique` et `qui_perd_gagne` définissent les variantes de victoire.
- `progression_campagne_service` pilote la structure de progression.
- `bdd_*` et `tableau_scores` protègent les données persistantes.
- `audio`, `score`, `stats` et `vibration` donnent le comportement global du système.

Pour aller plus loin, voir les fichiers detailles dans ce dossier :

- [scene-menu-principal.md](scene-menu-principal.md)
- [scene-campagne.md](scene-campagne.md)
- [scene-plateau.md](scene-plateau.md)
- [service-progression-campagne.md](service-progression-campagne.md)
- [service-bdd-joueurs.md](service-bdd-joueurs.md)
- [service-stats.md](service-stats.md)
