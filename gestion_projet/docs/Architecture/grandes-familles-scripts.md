# Grandes familles de scripts et rôles

## 0. Schéma mental du projet

Pour ne pas se perdre entre les services, les statistiques, l'UI et les scripts de jeu, le projet se comprend mieux avec cette séparation nette :

```text
UI / navigation
  menu_principal.gd
  campagne.gd
  menu_campagne.gd
  statistiques.gd
  scores.gd
  clavier.gd
     |
     | lit les informations produites par les services
     v
Gameplay / règles de partie
  classique.gd
  qui_perd_gagne.gd
  plateau.gd
  pile.gd
  jeton.gd
     |
     | valide les coups et signale la fin de partie
     v
Services / orchestration
  progression_campagne_service.gd
  score_service.gd
  stats_service.gd
  audio_service.gd
  vibration_service.gd
  log_service.gd
     |
     | centralise l'état du jeu et les calculs transverses
     v
Persistance / données
  bdd_joueurs_service.gd
  bdd_plateaux_service.gd
  liste_joueurs_service.gd
  tableau_scores_service.gd
  configuration_service.gd
  fichiers_json_service.gd
```

### Règle de séparation

- UI / navigation : affiche et orchestre le flux.
- Gameplay : applique les règles spécifiques au mode de jeu.
- Plateau : moteur visuel et mécanique du plateau.
- Services : gardent l'état global et les calculs transverses.
- Persistance : lit et écrit les données réelles du joueur et du projet.

## 1. Scènes de navigation

Ces scripts pilotent le flux du jeu entre écrans et menus.

- `menu_principal.gd` : point d’entrée, sélection du joueur, accès à la campagne, aux scores, aux références et aux réglages.
- `campagne.gd` : orchestrateur de la partie de campagne, avec transition entre menu, gameplay et progression.
- `scores.gd` : écran de classement.
- `retour_menu_principal.gd` : écran utilitaire de retour au menu principal.

## 2. Scènes de gameplay

Ces scripts décrivent les règles spécifiques à un mode de jeu.

- `classique.gd` : gameplay standard de résolution de plateau.
- `qui_perd_gagne.gd` : gameplay de variante, avec logique alternative de victoire.

## 3. Scènes de plateau

Ces scripts représentent le moteur visuel et mécanique du plateau.

- `plateau.gd` : construit le plateau, valide les mouvements, relaye les signaux d’état de jeu.
- `pile.gd` : colonne du plateau, contient les jetons, leur ordre et leur état de sélection.
- `jeton.gd` : pièce colorée du jeu, avec couleur, sélection et soudure.
- `layout_service.gd` : calcul de la disposition sur l’écran.
- `decodeur_service.gd` : parsing du texte du plateau.
- `regle_du_jeu_service.gd` : validation du transfert de jetons entre piles.

## 4. Scènes de UI et statistiques

Ces scripts ne calculent pas la logique métier ; ils affichent les résultats.

- `menu_campagne.gd` : écran intermédiaire avant le lancement d’un plateau.
- `statistiques.gd` : écran de synthèse des données de jeu.
- `kpi.gd` : composant générique pour afficher une valeur clé.
- `diagramme_en_barres.gd` : composant visuel pour barres.
- `courbe.gd` : composant visuel pour courbe de suivi.
- `clavier.gd` : clavier virtuel pour la saisie de pseudo.

## 5. Services globaux

Ces scripts fournissent un service transverse au projet.

- `audio_service.gd` : musique et effets sonores.
- `log_service.gd` : journal de débogage.
- `vibration_service.gd` : retour haptique.
- `progression_campagne_service.gd` : progression de l’ascension et fin de campagne.
- `score_service.gd` : calcul des points après une victoire.
- `stats_service.gd` : agrégation des données pour les KPI et statistiques.

## 6. Services de sauvegarde et données

Ces scripts sont la couche persistance et la source de vérité des données du jeu.

- `bdd_joueurs_service.gd` : sauvegarde du joueur courant.
- `bdd_plateaux_service.gd` : catalogue des niveaux et plateaux.
- `liste_joueurs_service.gd` : index de tous les joueurs connus.
- `tableau_scores_service.gd` : tableau de classement et score total.
- `configuration_service.gd` : réglages globaux du jeu.
- `fichiers_json_service.gd` : lecture/écriture JSON et accès disque.

## 7. Résumé de la séparation des responsabilités

- Les scènes UI / navigation organisent le flux et rendent l’information.
- Les gameplay sont des variantes de règles de victoire.
- Le plateau est le moteur de jeu.
- Les services centralisent la logique transversale.
- Les services de sauvegarde sont la vraie source de vérité des données.
- La logique de persistance ne doit pas être mélangée avec la logique UI ou de plateau.

## 8. Ce qu’il faut retenir

Le projet est cohérent si l’on garde cette séparation :

- navigation -> menu / campagne / scores
- gameplay -> classique / qui_perd_gagne
- moteur -> plateau / pile / jeton
- services -> progression / score / stats / audio / vibration
- persistance -> BDD joueur / plateau / configuration / classement

Cette séparation évite les doublons et permet de retrouver la logique initiale du projet : un moteur de plateau, une couche de progression, et une couche de données persistées en services.
