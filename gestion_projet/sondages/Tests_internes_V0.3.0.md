## V0.3 : phase de tests internes

## Retour de phase de tests internes

### [Sur mon mobile] Papa (77 ans)
- La compréhension des regles sont difficiles.
- Poursuit l'expérience avec un accompagnement bienveillant et des explications.
- La manipulation fine pour deplacer les jetons lui demande de la concentration.
- La réussite du plateau le stimule à poursuivre au plateau suivant.

### [Sur mon mobile] Maman (72 ans)
- Pas interessé par les jeux numériques.
- Pas motivée pour investir plus d'energie.
- Abandon au 1er plateau.

### Dorian
- Frustrant de rebondir sur un plateau difficile et de ne pas pouvoir défaire un coup perdant.
  - Proposition : Ne pas revenir en arrière, enregistrer l'echec et proposer un autre plateau du même niveau.
  - Mon compromis : Revenir en arrière et proposer un autre niveau quand on revient.
- La barre d'avancement est imprécise, j'aimerais savoir combien de plateaux reussir pour allumer la case suivante.
  - Proposition : Ajouter un autre element graphique pour symboliser l'avancement entre les niveaux.
  - Mon compromis : Agrandire les carrés blancs pour les dizaines et utiliser des petits carré pour symboliser les unités dans l'avancement. Encore mieux, les petits carrés pourraient être au nombre de plateaux à réussir. (25% = 2 GROS + 5 petits OU 2 GROS + x petits plateaux)
- Le score manque de pédagogie, il pourrait être décomposé selon le temps et le ratio de réussite pour montrer au joueur comment performer.
  - [À FAIRE] À chaque fin de plateau, afficher:
    - Bravo !
    - Score pour le temps : xxxx points
    - Score pour le ratio win/lose : yyy points
    - Score pour l'ascension : zzz points
- Le score est conservé pour toutes les ascensions, cela ne permet pas de comparer les ascensions entre elles. Pour voir les progrès, il serait bien de repartir à zéro et de pouvoir mettre des statistiques à disposition.
  - Proposition : Avoir un score global et un score par ascension.
  - Mon compromis : Cela necessite d'enregistrer un historique de joueur tres poussé qui pourra servir aussi pour les statistiques.
- Au sein d'un même niveau, il y a trop de similarité entre les plateaux. On a le sentiment de refaire le même.
- Questionnaire : Terminé
- [Après questionnaire] : lisibilité faible pour l'aide de l'éditeur de plateaux. Rincer le fond d'écran.
- [Après questionnaire] : Ajouter les regles directement dans le menu principal. (ou avec un "?" dans un coin du plateau de jeu)

### Aleksandar
- la musique d’echec est toujours aussi cruelle
- lorsque l’utilisateur clique sur l’arrière plan, annuler la sélection courante
  - Mon compromis : Ajouter en combinant avec un élargissement de la zone de selection.
- Questionnaire : Terminé

### Pila
- Les plateaux sont trop similaires et trop faciles au début.
- L'effet de surbrillance donne l'impression d'une dictée sur les plateaux triviaux.
- La zone de clique est trop étroite, cela ne marche pas tout le temps.
- Le "glisser" serait plus appréciable que le clique sur le départ et l'arrivée.
  - Mon Compromis : Utiliser 'InputEventScreenTouch' et 'InputEventScreenDrag' pour gerer le SWIPE.
- Décrire rapidement le but du jeu.
  - Mon compromis : Est présent dans la description de l'application, mais pas visible dans la phase de test ouverte.
- Dans la barre d'info du joueur, les carrés d'avancement n'apparaissent pas sur son telephone.

### Fabrice
- Les plateaux sont répétitifs parfois.
- Les selections (surbrillances) sont bien faits.
- Les couleurs des jetons sont bien choisis.
- Il manque une aide en jeu pour expliquer les regles et le but.
- L'avancement serait plus précis avec un nombre.

### Anatole
- Pas de remarque personnelle, mais rejoins certaines remarque de Dorian

### [Sur mon mobile] Anna (usager IPhone)
- Trop de plateaux similaires (les 2 premieres piles sont souvent identiques)
  - Mon compromis :
    - Considerer les plateaux qui ont trop de colonnes identiques en doublon.
    - Considérer les petits plateaux comme plus interessants pour une même profondeur
- L'ascension est trop longue
- Il n'y a pas assez de formats de plateaux différents (2 seulement : tres larges et bas ou haut et étroits)

### Maman
- Pas de retour pour participer aux tests

### Romain
- Bon jeu, facile à prendre en main
- Difficulté : Améliorer l'indicateur de difficulté. Plutot que de baser la difficulté sur la profondeur de la solution, la baser sur le nombre d'alternatives de la solution et le risque de se tromper.
- Ajouter une option pour activer/désactiver la musique
- Ajouter une option pour activer/désactiver les bruitages
- Ajouter une option pour activer/désactiver les vibrations

### Patou
- Une notice serait appréciable pour faciliter l'apprentissage
- Difficulté sur les regles de deplacement des jetons (deplacer seulement les jetons au sommet de la pile)
- C'est ludique et ne s'est pas lassée.
- Plus de challenge

### Zephyr
- au début la solution est tjrs semblable, même si le niveau est différent
- ça permet aussi de jouer sans trop réfléchir
- au début la solution est tjrs semblable, c'est pas trop un défi
- la difficulté ne semble pas linéaire en ressenti. Améliorer l'indicateur de difficulté.

### Thierry
- Frustrant et peu amusant d'être bloqué à un plateau en cas d'échecs

### Fatoumata
- Trop mignon "Anna d'Amour" : Je veux plus de déclarations comme ça
  - Mon idée : Pour le joueur "Anna", Ajouter des messages d'amour, de soutien et coquins.
  - Mon idée : "Anna" pourrait encourager les joueurs à poursuivre avec des phrases, des citations, car ils font cela pour elle.
- **En attente de retour**

### Claudine
- Agaçant avec la difficulté

### Denis
- **En attente de retour**

### Aloes
- Musique un peu répétitive
- Amusant

## Demandes d'évolutions

Voici la liste ordonnées des évolutions votées lors de la version V0.3.0 (Rang | Score | Description):

1.	Score: 1,4	- Ajouter une option pour activer/désactiver la musique
2.	Score: 1,4	- Ajouter une option pour activer/désactiver les vibrations
3.	Score: 1,4	- Annuler la sélection de pile lors d'un pointage sur le fond d'écran
4.	Score: 1,4	- Des plateaux encore plus difficiles !
5.	Score: 1,6	- Ajouter une option pour activer/désactiver les bruitages
6.	Score: 1,7	- Au commencement d'une ascension, permettre à l'utilisateur de choisir la longueur de son ascension.
7.	Score: 1,7	- Réduire la similitude des plateaux de faible niveaux qui se ressemblent trop.
8.	Score: 1,9	- Baser la difficulté sur le nombre d'alternatives (les occasions de faire une erreur) de la solution
9.	Score: 2,0	- Lors d'un abandon, ne pas rejouer le même plateau abandonné, mais proposer un autre plateau de même difficulté.
10.	Score: 2,0	- Améliorer la précision de l'avancement dans l'ascension
11.	Score: 2,0	- La sélection ne met en surbrillance que les jetons concernés et pas la pile complète
12.	Score: 2,1	- Dans le menu principal, donner accès à des statistiques de jeu des joueurs.
13.	Score: 2,1	- Dans la page de statistiques, présenter des statistiques de "Campagne" : Pourcentage de complétion,  Temps de jeu, Nombre de parties, Nombre de défaites, Taux de. réussite, Série maximum de succès
14.	Score: 2,1	- Dans la page de statistiques, présenter des statistiques de "Ascension" : Pourcentage de complétion de l'ascension en cours, nombre d'ascension sans détour, la pl.us longue (temps, dépassement de plateaux) durée moyenne d'ascension (temps, plateaux), nombre d'ascension achevées
15.	Score: 2,1	- Prévoir 2 tableaux de scores : un classement globale et cumulatif de tous les plateaux joués et un classement par ascension.
16.	Score: 2,1	- Implémenter le "GLISSER" pour le déplacement de jeton en plus du mécanisme actuel.
17.	Score: 2,2	- Sauvegarder le jeu pendant la résolution d'un plateau pour reprendre au milieu d'un plateau.
18.	Score: 2,3	- Ajouter une description du but du jeu dans la description de l'application
19.	Score: 2,3	- Ajouter une description des règles du jeu dans la description de l'application.
20.	Score: 2,4	- Agrandir la zone de sélection autours de la pile, car elle est trop étroite..
21.	Score: 2,6	- Dans la page de statistiques, présenter des graphiques de statistiques de "Difficulté" : échecs par difficulté, taux de réussite, temps moyen, complétion.
22.	Score: 2,6	- Après une résolution ou abandon, représenter la variation du score avec sa composante "taux de réussite" et "temps de résolution" pour que le joueur comprenne les ressorts d'amélioration du score.
23.	Score: 2,9	- Ajouter une musique dans les menus
24.	Score: 3,0	- Prévoir des musiques différentes selon l'avancement dans l'ascension.
25.	Score: 3,0	- Ajouter des points spécifiques à la réussite d'une ascension dans le score..
26.	Score: 3,0	- En jeu, représenter les jetons contigus identiques comme "soudés"..
27.	Score: 3,0	- Quand un joueur tarde à résoudre un plateau, faire une animation pour l'inviter à abandonner (troll).
28.	Score: 3,2	- Réaliser une animation de jeton qui se déplace
29.	Score: 3,3	- Dans la page "Campagne" à coté du bouton "Menu", prévoir un bouton pour changer de joueur sans retourner au menu principal.
30.	Score: 3,3	- Ajouter des fonds et des emojis de plateaux à thème (exemple : une cuisine avec des jetons d'aliments)
31.	Score: 3,4	- Le score augmente comme sur une machine à sous.
32.	Score: 3,8	- Afficher une image en fond plutôt que le fond uni.
