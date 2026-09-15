# Documentation de conception
Documentation de l'architecture et la conception du jeu:
- [Document de conception](docs/Godot-Color-Sort-For-Anna.md)

# Outils
Outils de productions et de résolution des plateaux de jeux:
- [Color sort for Anna TOOLS](https://github.com/leguims/color_sort_for_anna_tools)

# Demandes d'évolutions
Listes des évolutions votées par les testeurs:
- [Evolutions](Evolutions.md)

# Liste des fonctionnalités

Depuis la phase de tests internes de la version V0.3.0, les fonctionnalités sont votées par les testeurs. L'attribution des fonctionnalités par versions ci-dessous devrait devenir obsolète pour préférer un classement global des testeurs. Cependant, les deux vont vivre pendant une phase de transition.

## V1.0.0 : Travaux pour la prochaine version

### Bugs

#### Bug V0.3.0 :
- [à surveiller] L'affichage "Niveau = 5 - indice Plateau = 0 - Nombre de parties = <null>" est en erreur !

#### Bug V0.4.0 :
- Définir une combinaison secrete pour declencher l'export des fichiers JSON.

### Jeu

#### Changement d'architecture pour accueillir plusieurs gameplay
- ~~Séparer la gestions du plateaux : plateau, pile et jeton~~
- ~~Séparer les regles de vies des plateaux : creation plateau, deplacement de jetons~~
- ~~Séparer les regles du plateau et les regles du jeu : condition de victoire appartient au gameplay~~
- ~~Séparer la campagne des plateaux et interfacer le gameplay entre eux.~~
- ~~Structurer le fichier 'Solutions_classees.json' pour incorporer le déroulé de la campagne (sequence plateaux et gameplay)~~
  - ~~Le contenu devra être identique à la section "Campagne" du fichier vierge de sauvegarde d'un joueur.~~
- ~~Structurer la sauvegarde 'sauvegarde_joueur_XX.json' pour incorporer la campagne~~
  - ~~"ascensions" devient "enregistrement_campagne" pour les statistiques~~
  - ~~Un plateau terminé en campagne devient accessible pour le jeu libre~~
  - ~~La liste des plateaux de la campagne contient le gameplay de chacun + spécificités facultatives (coups_min, dico)~~
- Associer les statistiques à la campagne
- ~~Ajuster les decodages de fichiers plateaux : bdd_plateaux_service~~
- Ajuster les decodages de fichiers de progression campagne : progression_campagne_service
- ~~Effacer tous les outils d'initialisation libre de la campagne (jauge + nombre de plateau)~~
- ~~Les enregistrements de campagne permettent de conserver plusieurs niveaux en cours. (exemple : Niveau_1 et Niveau_10)~~ ABANDON
- ~~Comme tous les niveaux sont enregistrés dans la campagne, on pourrait commencer plusieurs niveaux sans avoir fini le précédent.~~ ABANDON
- ~~On pourrait dire qu'un niveau passé à moitié ouvre l'accès au niveau suivant..~~ ABANDON
- ~~Changement de vocable:~~
  - ~~Notions globales:~~
    - ~~Campagne = Campagne~~
      - ~~Ascension => Niveau~~
        - ~~Plateau => Plateau~~
          - ~~Niveau => Difficulté~~
          - ~~0 => Gameplay~~
  - ~~fichier de sauvegarde:~~
    - ~~ascension => enregistrement_campagne~~
    - ~~plateaux => campagne~~
    - ~~plateaux => plateaux_libres (peuplé par les plateaux de campagne terminés)~~

#### Suggestions générales
- (Faro) Aligner les piles sur la même ligne pour que ca soit plus facile à jouer (-1 Totol)
- Sauvegarder l'état du plateau en cours après chaque coup. Le joueur qui quitte le jeu, reprend là où il était. Quand il revient, il commence avec son temps moyen sur ce type de niveau.
- (Aleksandar): thème sur le fond du décors. Trop austère.
- Selon ton humeur, demander 5 plateaux faciles ou 5 ultras difficiles. (mode libre)
- pour les plateaux impossibles à perdre, les classer dans DÉTENTE
- pour les plateaux impossibles à gagner, proposer au joueur de trouver la combinaison pour perdre. (Mode No Win)
- Pouvoir effacer un joueur (avec confirmation)
- Effacer automatiquement un joueur sans fichier de statistiques.
- Ajouter un menu pour effacer un joueur (avec resolution d'un plateau pour confirmer)
- (Anatole) Gagner des pieces sur des reussite majeur et les utiliser pour passer un plateau.

#### Web
- Ajouter un menu pour exporter les sauvegardes (avec chiffrage secret)
- Ajouter un menu pour importer les sauvegardes chiffrées

#### Niveaux
- Prevoir une musique spéciale pour la réussite de la derniere ascension possible et le message de félicitations.
- Il faudrait prevoir un jeu libre avec choix de difficulté et choix de longueur d'ascension + La campagne qui orchestre les longueurs d'ascensions à faire (10 puis 20 ...)
- TRICHE ANATOLE :
    - Quand anatole comme 'nom' on peux mettre n'importe quelle couleur sur n'importe quelle couleur et ça marche mais pas beaucoup de point
    - Il y aura un bouton gagner Ou quand tout les Block seront dans une case remplie

#### Statistiques
- Outils visuels:
  - GAUGE (Jauge) : jauge circulaire ou semi-circulaire
    - Progression vers un objectif mensuel
    - Pourcentage de niveaux complétés
    - Temps de jeu par rapport à un objectif
  - Bar chart (daigramme en barres) : 
    - Victoires / défaites
    - Nombre de parties par jour
    - Temps de jeu par mois
  - Line chart (courbe) : 
    - Temps de jeu par mois
    - Durée moyenne des parties au fil du temps
  - Le plus simple sur GODOT 4.5: utiliser la bibliotheque de base.
    - Control + TextureProgressBar + Label + Graphiques "faits maison"
- Page de statisques contient (de haut en bas):
  - Campagne:
    - [Line chart] Temps de jeu,
    - [Bar chart 1] Nombre de parties
    - [Bar chart 1] Nombre de défaites
  - Ascension:
    - [Line chart] durée d'ascension (temps, plateaux), 
  - Niveau (notion artificielle à construire):
    - [Line chart] Idée de représentation graphique : Dessiner une courbe avec x=niveaux et y=f(x)=echecs, taux de réussite ...
    - [Line chart] Idée : Representer les courbes sur 1 mois d'activité et comparer au dernier mois (en pointillé) 
    - [Bar chart 2] échecs par niveau, 
    - [Bar chart 2] taux de réussite par niveau, 
    - [Bar chart 2] temps moyen par niveau,
    - [Bar chart 2] complétion par niveau,
- Prévoir un téléchargement des stats:
    - nommer le téléphone + compte google
    - indiquer la date de création.
    - zipper les données : comptes de jeux, scores et séquences de jeu.
    - réaliser un SHA1 de l'ensemble
    - envoyer le tout à l'adresse mail du jeu.
    - Prévoir côté mail :
      - vérifier le zip avec le SHA1
      - créer une base de donnée avec tous les joueurs
      - faire un classement de tout le monde.
- Automatisation des scores:
    - activer Google Play Games Services (GPGS)
    - créer un leaderboard
    - enregistrer l'ID. 
    - importer le plug in GPGS dans godot.
    - https://godotengine.org/asset-library/asset/2440#:~:text=2.0%20Tools%204.0%20Community,%2D%20Load%20events%20by%20ids

#### Android
- Pour Android : voir si une astuce de zoom existe sur Godot pour grandir les piles suivant la taille des piles.

#### Ambiance
- (Anna) Le score est animé quand il augmente. Comme une machine à sous.
- (Faro) Ajouter de la musique dans les menus (+1 Totol)
- (option) détecter une position de plateau bloquée ou impossible.
- (Totol) Quand un joueur met du temps à jouer, faire une animation pour dire d'abandonner ou faire apparaître une main qui y invite. C'est du troll.
- (Guigui) messages d'amour pour joueuse d'amour !
- (copilot) Ajouter des defis (complete en moins de X mouvements)
- (Guigui) Pour le son de fin de rangée, interroger la taille de la rangée pour boucler un son en fonction de sa taille.
- (Guigui) Changer de thème quand on joue une 2onde fois un plateau en échec. (Rouge avec un logo "Attention")
- (Guigui) en jeu, afficher la complétion de l'ascension et de la campagne sous le nom sous forme de pourcentage.
- (Guigui) Cloner les sons de  victoire, debut, fin, echecs pour varier les plaisirs.
- (Anatole) Fond d'écran mobile avec un lapin mignon qui devient flippant, furieux après 2 minutes, puis tout mignon à nouveau. Un screamer à 2 minutes.

#### Accessibilité
- Le tremblement peut faire selectioner/désélectionner une pile dans le même temps. Faire une tempo pour sélectionner une pile afin de se protéger des tremblements.
- Augmenter la zone de sélection des piles
- Augmenter le contraste des cases vides
- Augmenter le temps de deselection automatique

## V1.0 : Pour une version long terme

### Campagne

- 1 campagne = Plusieurs niveaux
- 1 niveau = Plusieurs plateaux de difficulté et gameplay différents
- Les niveaux sont prédéfinis dans la campagne (pas d'ajustement selon le niveau des joueurs).
- La campagne est un ensemble de plateaux séquencés et non aléatoires. Tout se déroule dans le même ordre et permet la comparaison des score d'un joueur à l'autre : __Jeu Compétitif__.
- Un plateau non résolu est bloquant, le joueur doit le résoudre pour passer au suivant
- Un __Plateau Rare__ est un plateau exceptionnel qui offre un défi unique et des récompenses spéciales:
  - Il apparait en dernier plateau de la campagne.
  - Son gameplay est unique.
  - Son gain est affiché avant de commencer le plateau.
  - S'il est gagné:
    -  Il rapporte un gros bonus (1.000.000 points)
    -  Il est reversé dans le jeu libre
  - S'il est perdu:
    -  La campagne passe au plateau suivant
    -  Le plateau n'est pas reversé dans le jeu libre.
  - Proposition : __Programmation Genius__

### Jeu libre

- Sont jouables tous les plateaux résolus de la campagne.
- Selon le gameplay du plateau de la campagne, les modes accessibles seront:
  - Groupe __Classique__:  
    - Classique
    - Tout En Tête
    - Programmation
    - Qui Perd Gagne
    - Pile Ou Face
  - Groupe __Nombre De Coups__:
    - Au Plus Près
    - Pile Poil
  - Groupe __Poids Jeton__:
    - Poids Plume
  - Groupe __Mot__:
    - Mot Caché
  - Groupe __Plateau RARE__:
    - Programmation Genius
- Tous les plateaux d'un groupe seront jouable dans tous les gameplay de ce groupe.

### Nouveaux styles de jeux:

#### Noms

  - Classique
  - Au Plus Près
  - Pile Poil
  - Tout En Tête
  - Programmation
  - Programmation Genius
  - Qui Perd Gagne
  - Poids Plume
  - Pile Ou Face
  - Mot Caché

#### Descriptions

- Classique :
  - Regle du jeu actuelle.
- Au Plus Près :
  - Pour les plateaux avec plusieurs longueur de solutions
  - Indiquer la longueur de la solution la plus courte
  - Un bonus est donné selon la logueur de la solution trouvée.
  - Difficulté : faible
- Pile Poil :
  - Pour les plateaux avec plusieurs longueur de solutions
  - Indiquer la longueur de la solution la plus courte
  - La partie est perdue si la solution la plus courte n'est pas trouvée
  - Afficher le compteur de coups actuel à coté de la cible
  - Difficulté : élevée
- Tout En Tête :
  - Commencer le chrono quand le premier coup est joué.
  - ??? Définir quel type de plateau conviendrait.
  - Difficulté : faible
- Programmation :
  - Prévoir tous les coups jusqu'à la fin.
  - Tout s'anime quand c'est fini. 
  - ??? Définir quel type de plateau conviendrait.
  - Difficulté : élevée
- __Plateau RARE__ Programmation Genius :
  - Prévoir tous les coups jusqu'à la fin.
  - À chaque coup, les piles bougent sur l'interface.
  - Le joueur doit mémoriser l'état courant du plateau après le mouvement.
  - Tout s'anime quand c'est fini. 
  - Difficulté : Ultra élevée
- Qui Perd Gagne:
  - Regle du jeu actuel inversée.
  - Il faut trouver une position de plateau bloquée et non résolue
- Poids Plume :
  - Commencer le chrono quand le premier coup est joué.
  - Résoudre le plateau avec le moins de déplacement de jeton
  - Chaque jeton qui bouge augmente un "malus"
  - 2 jetons qui bougent coutent plus de malus qu'1 seul jeton
  - Afficher le malus en direct
- Pile Ou Face :
  - Présenter le plateau dans les 2 modes CLASSIQUE et QUI PERD GAGNE en simultané.
  - Le joueur gagne en résolvant l'un des deux.
  - À lui de choisir le plus avantageux.
  - Adapté pour les plateaux avec peu de jetons (hauteur et largeur)
- Mot Caché:
  - la résolution du plateau forme un mot (ANNA, LOVE, SEXE ...).

#### Interface Graphique

- Classique :
    - Afficher le chrono en haut à droite.
- Au Plus Près :
    - Afficher le nombre de coups courant à coté de la cible.
- Pile Poil :
    - Afficher le nombre de coups courant à coté de la cible.
- Tout En Tête :
    - Afficher le chrono en haut à droite figé avant le 1er coup.
- Programmation :
    - Afficher les coups avant leur déroulement
    - Afficher un bouton "Dérouler"
- Qui Perd Gagne:
    - Afficher le chrono en haut à droite.
- Poids Plume :
    - Afficher le nombre de jetons déplacés.
    - Afficher le chrono en haut à droite.
- Pile Ou Face :
    - Afficher le chrono.
    - Afficher un panneau "Gagné" ou "Perdu" selon le mode.
    - Le panneau s'illumine en cas de victoire.
- Mot Caché:
    - Afficher le mot à chercher
- [GFX] STATS : faire apparaître le type de game play pour chaque min et max.
- [GFX] CHRONO : le chrono est tout le temps visible sur l'écran.
- [GFX] COUPS : le nombre de coups courant est tout le temps visible sur l'écran.

## V2.0 : Pour une version long terme

### Divers
- faire une animation du bloc qui se déplace
- enregistrer dans les données immédiatement les déplacements, mais l'animation décide quand afficher/masquer les jetons selon son avancement. (idée, plusieurs coups sont enchaînés et joués même si l'animation n'est pas terminée. Le résultat donne une séquence d'animation magique)
- pour les jetons, dissocier les caractéristiques : indice de jeton, couleur, nom, famille. Une famille pourrait avoir plusieurs jetons avec un nom ou une couleur différente.
- réfléchir à une écriture de plateau qui porte l'organisation des piles dans le plateau. Par exemple '.' pour le changement de pile et '..' pour le changement de ligne.
- varier la représentation des jetons et le fond du plateau :
	- fruits avec fond de cuisine,
	- médicaments avec fond d'hôpital,
	- animaux avec un zoo,
	- pacman/fantômes et le labyrinthe
- Surement faisable avec des EMOJI : String.chr(unicode) (https://www.unicode.org/emoji/charts/emoji-list.html)
- Idee de nouveau gameplay, chaque colonne est en mouvement, comme si les jetons étaient sur un tapis roulant. Le joueurs doit donner l'ordre d'échange au bon moment !
- (Anna) Réaliser une version portugaise.

### Nouveaux styles de jeux:

#### Noms

  - CLASSIQUE :
  - DÉFI DU GOSSE => Au Plus Près
  - DÉFI DU BOSS => Pile Poil
  - MÉMOIRE => Tout En Tête
  - Programmation
  - QUI PERD GAGNE => Qui Perd Gagne
  - FLEMMARD / ECOLOGIE => Poids Plume
  - DOUBLE FACE => Pile Ou Face
  - DICO => Mot Caché

#### Descriptions

  - Classique :
    - Regle du jeu actuelle.
  - Au Plus Près :
    - Pour les plateaux avec plusieurs longueur de solutions
    - Indiquer la longueur de la solution la plus courte
    - Un bonus est donné selon la logueur de la solution trouvée.
    - Difficulté : faible
  - Pile Poil :
    - Pour les plateaux avec plusieurs longueur de solutions
    - Indiquer la longueur de la solution la plus courte
    - La partie est perdue si la solution la plus courte n'est pas trouvée
    - Afficher le compteur de coups actuel à coté de la cible
    - Difficulté : élevée
  - Tout En Tête :
    - Commencer le chrono quand le premier coup est joué.
    - ??? Définir quel type de plateau conviendrait.
    - Difficulté : faible
  - Programmation :
    - Prévoir tous les coups jusqu'à la fin.
    - Tout s'anime quand c'est fini. 
    - ??? Définir quel type de plateau conviendrait.
    - Difficulté : élevée
  - Qui Perd Gagne:
    - Regle du jeu actuel inversée.
    - Il faut trouver une position de plateau bloquée et non résolue
  - Poids Plume :
    - Commencer le chrono quand le premier coup est joué.
    - Résoudre le plateau avec le moins de déplacement de jeton
    - Chaque jeton qui bouge augmente un "malus"
    - 2 jetons qui bougent coutent plus de malus qu'1 seul jeton
    - Afficher le malus en direct
  - Pile Ou Face :
    - Présenter le plateau dans les 2 modes CLASSIQUE et QUI PERD GAGNE en simultané.
    - Le joueur gagne en résolvant l'un des deux.
    - À lui de choisir le plus avantageux.
    - Adapté pour les plateaux avec peu de jetons (hauteur et largeur)
  - Mot Caché:
    - la résolution du plateau forme un mot (ANNA, LOVE, SEXE ...).

#### Interface Graphique

  - Classique :
      - Afficher le chrono en haut à droite.
  - Au Plus Près :
      - Afficher le nombre de coups courant à coté de la cible.
  - Pile Poil :
      - Afficher le nombre de coups courant à coté de la cible.
  - Tout En Tête :
      - Afficher le chrono en haut à droite figé avant le 1er coup.
  - Programmation :
      - Afficher les coups avant leur déroulement
      - Afficher un bouton "Dérouler"
  - Qui Perd Gagne:
      - Afficher le chrono en haut à droite.
  - Poids Plume :
      - Afficher le nombre de jetons déplacés.
      - Afficher le chrono en haut à droite.
  - Pile Ou Face :
      - Afficher le chrono.
      - Afficher un panneau "Gagné" ou "Perdu" selon le mode.
      - Le panneau s'illumine en cas de victoire.
  - Mot Caché:
      - Afficher le mot à chercher
  - [GFX] STATS : faire apparaître le type de game play pour chaque min et max.
  - [GFX] CHRONO : le chrono est tout le temps visible sur l'écran.
  - [GFX] COUPS : le nombre de coups courant est tout le temps visible sur l'écran.

## V3.0 : Idées du futur:
- Game play "Message" :
	- Réaliser des tableaux dont la solution est un message (Anna.Loves.Sex).
	- Réorganiser Jeton et construction de plateau pour arriver à ce résultat.
	- (Aleksandar): +1 sur le mode avec des mots.
- jeu en réseau : course de joueurs sur un même plateau avec chrono
- chrono enregistré sur les plateaux. Plateau masqué avant le départ.
- fond de plateaux dynamiques :
	- un hublot avec des nuages qui passent
	- des oiseaux qui passent
	- des feuilles d'automne qui passent

## V4.0 : Ascension émotionnelle plutot qu'une montagne

### Campagne

L'ascension doit refléter:
- une relation amoureuse naissante
- une relation à entretenir
- relation avec incompréhension.
- reconstruction difficile,
- une relation à réparer
- après reconstruction/réparation, une attention quotidienne est plus facile

Des messages doivent apparaître pour la ponctuer :
- texte : maxime, proverbe, message Anna
  - Avec toi dans une cage, je me sens en liberté.
  - En cage à tes côtés, je peux voler vers des cieux merveilleux.
- audio : message Anna
- animation : représentation d'une émotion d'Anna.

Ce qui était la campagne avant doit devenir "jeu libre".

Le tableau des scores doit se dissocier.
- jeu libre = points
- campagne = coeurs

# Phases de tests

## V0.3.0
- [Phase de tests internes](Tests_internes_V0.3.0.md)
