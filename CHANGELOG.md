# Liste des fonctionnalités

## V0.4.6

- Passage GODOT V4.7.2-stable
- Nouveau menu principal.
- Corrections de robustesse suggérés par ChatGPT.
- Amélioration de la lisibilité de la selection des jetons.

## V0.4.5 / V0.4.5.1

- Passage GODOT V4.7.2-rc1
- Version corrective demarrage android lent.

## V0.4.4

### Jeu

#### Web
- Filtrer le menu des vibrations
- Ajouter un clavier virtuel pour saisir le nom du joueur
- Afficher l'avancement dans l'ascension + Campagne au lieu des icones moches. (Android, Windows et WEB)


#### Deploiement de versions
- prévoir un champs de sauvegarde avec les infos : plateau courant (niveau, indice, nom et "nom" actuel). ABANDON (je ne comprends plus)

#### Accessibilité
- Faire une sorte de buzz pour les mouvements interdits. Pas de son si la selection périme. V0.4.3


## V0.4.3

### Bug V0.4.2 :
- En cas d'effacement d'un joueur, les chemin de fichiers sont décalés. Il faut tous les renommer pour que cela fonctionne à nouveau.

### Jeu

#### Ambiance
- (copilot) Ajouter un son "doux" de click pour la selection d'une pile.
- (copilot) Ajouter un son doux "plop" pour une pile qui s'acheve.


## V0.4.2

### Jeu

#### Statistiques
- Page de statisques contient (de haut en bas):
  - Ascension:
    - [KPI] Pourcentage de complétion de l'ascension en cours,
    - [KPI] nombre d'ascension achevées 
    - [KPI] la plus longue (temps, dépassement de plateaux)
    - [KPI] Taux de reussite max + longueur de l'asecension
    - [KPI] Taux de reussite min + longueur de l'asecension
  - Plateau:
    - [KPI] temps moyen de résolution
    - [KPI] plateau le plus galère


## V0.4.0

### Bug V0.3.2 :
- bug sur score d'ascension qui est calculé sur le nombre de niveaux restant dans le jeu plutot que les niveaux effectivement réalisés dans l'ascension courante.
- dernière ascension, la même musique pendant toute l'ascension.

### Bug V0.3.6 :
- après un abandon, on peut continuer de résoudre un plateau et même le résoudre malgré les menus affichés

### Bug V0.4.0.beta :
- Durée campagne = 1500h et plus. Si un jouer arrete le jeu pendant une partie, au prochain lancement, la partie est terminée avec l'heure du lancement qui peut etre plusieurs semaines apres. Il faudrait laisse "fin" à une valeur connue pour identifier qu'il ne faut pas la compter dans les statistiques de temps. Peut-etre ajouter un champs "fin_inconnue = true".
- Le tableau des scores repete "Alain à 0" 5 fois sur une machine vierge.
- [BLOQUANT] Après un abandon, le menu de campagne n'apparait pas, le jeu est bloqué.
- Le score de fin de campagne/ascension montre une longueur d'ascension eronnée (zero !) => mauvais score d'ascension et de detour.
- Pendant l'ascension, les log montrent une ascension qui est figée à 0% que l'on gagne ou perde.
- La version dans le fichier de configuration enregistrée n'est pas mise à jour lors d'une nouvelle version.
- La musique ne change plus avec la progression en ascension
- Les infos joueur de l'ascension ne sont plus à jour
- Pour l'export, reduire les noms de fichiers, car ils sont tronqués, modifiés.
- Lors du changement de version, effacer tous les plateaux inachevés des joueurs enregistrés..
- Lors du changement de version, remettre à zéro les scores des joueurs enregistrés..

### Jeu
- Pouvoir passer l'apercu du score du plateau par un clique sur l'ecran.
- Page "Campagne" : En même temps que le bouton "Commencer", faire des liens (en haut) vers chaque joueurs pour basculer d'une campagne à l'autre sans passer par le menu => ABANDON
- Lire les plateaux 'Solutions_classees.json' et enregistrer l'UUID. Si l'UUID n'est pas celui de la sauvegarde, effacer toutes les sauvegardes des joueurs. => ABANDON
- (option) enregistrer les dates de jeux et proposer une série de plateaux de chaque niveau. "Semaine 1", proposer les 1er plateaux de chaque niveau. => ABANDON
- (option) prévoir un json avec l'enregistrement des scores de chacun sur chaque semaine. Score total et score semaine. => Calculable avec les statistiques.
- Quand le jeu est terminé (campagne 100%), afficher un globe à coté du nom du joueur dans le menu principal
- Pouvoir passer l'apercu du score du plateau par un clique sur l'ecran.

#### Refactoring
- Structurer tout le dépot pour réorganiser les sources, les outils et les tests
    - plus de singleton
    - découpage des scenes menu_campagne.gd, campagne.gd et menu_principale.gd

#### Statistiques
- Inclure un bouton statistiques dans le menu campagne
- Outils visuels:
  - KPI : Bouton carré avec un chiffre
    - Durée moyenne d’une partie
    - Niveau maximum atteint
    - Nombre total de parties
    - Temps total de jeu
- Page de statisques contient (de haut en bas):
  - En haut : Nom du joueur
  - Campagne:
    - [KPI] Pourcentage de complétion,
    - [KPI] Temps de jeu,
    - [KPI] Taux de réussite
    - [KPI] Série maximum de succès
  - Ascension:
    - [KPI] Pourcentage de complétion de l'ascension en cours,
    - [KPI] nombre d'ascension sans détour,
    - [KPI] la plus longue (temps, dépassement de plateaux)
    - [KPI] durée moyenne d'ascension (temps, plateaux),
    - [KPI] nombre d'ascension achevées 
  - Plateau:
    - [KPI] le plus rapide (temps, profondeur)
    - [KPI] le plus long (temps, profondeur)

## V0.3.6 :Travaux réalisés

### Jeu

#### Ascensions
- Prévoir de donner le choix de l'ascension au départ en indiquant les quantités de chacunes des ascensions et le temps à prévoir.
- Enregistrer le score dans les infos 'joueur' quand l'ascension est terminée. Le score intermédiaire est calculé avec le score enregistré et le calcul partiel. "Score=f(essais, temps)"

### Outillage
- Rendre parametrable depuis les scripts "outil_*" les chemins vers "Analyses" et "Solutions"

#### Revalidation
- Similarité : Difflib : inclus dans python Réalisé avec Rapidfuzz

#### Difficulté de plateau
- Dans la recherche de solution, réorganiser pour conserver:
  - La solution la plus courte (1 seule)
  - La quantité de solution pour chaque longueur
- Baser la difficulté sur le nombre d'alternatives (les occasions de faire une erreur) de la solution
  - noter avec la solution le nombre de coups possibles à chaque étapes.
  - une étape sans alternative est inintéressante.
  - Définir la difficulté:
    - Parcourir la solution la plus courte
    - À chaque coup, identifier s'il y a plusieurs coups jouables.
    - Difficulté = multiplier les coups legaux à chaque étape. Comme ça "1 coup" est neutre sur le score final.
- Ajouter un "outil_divers" pour mettre au nouveau format les solutions déjà trouvées

#### Deploiement de versions
- changement de version : les nouveaux tableaux et les anciens tableaux sont en collision.
- définir le modèle de mise à jour : tout à zéro, on poursuit en cumulé, on poursuit en perdant l'ancien => à définir pour chaque version
- Sauvegarder le numéro de version dans la sauvegarde et l'utiliser lors du lancement d'une nouvelle version pour réaliser tous les travaux de mise à jour de changement de version nécessaire.
- enregistrer la liste des nom de plateaux achevés => dans les statistiques du joueur

## V0.3.1 : Travaux réalisés

### Jeu
- Découper "Gestion_Score" en plusieurs modules indépendants. Campagne, sauvegarde, traitement des données.
- Ajouter des points au score par ascension terminée.
- Annuler la sélection de pile lors d'un pointage sur le fond d'écran
- La sélection ne met en surbrillance que les jetons concernés et pas la pile
- En jeu, représenter les jetons contigus identiques comme "soudés".

#### Ascensions
- Dictionnaire pour les musiques en fonction des niveaux.
- Au commencement d'une ascension, permettre à l'utilisateur de choisir la longueur de son ascension.
- Lors d'un abandon, ne pas rejouer le même plateau abandonné, mais proposer un autre plateau de même difficulté.
- Après une résolution ou abandon, représenter la variation du score avec sa composante "taux de réussite" et "temps de résolution" pour que le joueur comprenne les ressorts d'amélioration du score.
- Ajouter des points spécifiques à la réussite d'une ascension dans le score.

#### Musique
- Attribuer des musiques en fonction de la phase ascensionnelle actuelle. 1 ascension fait défiler toutes les musiques.
- Prévoir des musiques différentes selon l'avancement dans l'ascension.

#### Graphisme
- Représenter 2 jetons identiques l'un sur l'autre comme soudés
- Quand une pile est bloquée, activée une couleur sombre autours (inverse de la selection). Elle n'est plus selectionnable.

#### Congiguration du jeu
- Ajouter une option pour activer/désactiver la musique
- Ajouter une option pour activer/désactiver les vibrations
- Ajouter une option pour activer/désactiver les bruitages

## V0.3.0 : Travaux réalisés

### Jeu
- Ajouter un pictogramme dans les scores pour le TOP 3. Ajouter ce pictogramme dans les infos joueurs de la campagne.
- Gérer un fichier de plateaux avec des niveaux discontinus
- (Anna) retour au menu devient menu
- (Anna) supprimer score dans les infos joueur
- (Anna) progression campagne : carré blanc = montagne.
- (Anna) Remplacer la progression campagne par le nombre d'ascensions des dernières 24h.
- (Anna) Laisser le nombre d'ascensions de manière permanente dans les infos joueurs (trop difficile pour etre volatile)

#### Menu principal
- Supprimer la tuile "Nouveau Joueur"
- Dans le menu "Campagne", ajouter après la liste des joueurs une tuile " + "
- Dans le menu "Campagne, la tuile " + " est éditable, réalise la vérification du nom et ajoute le nouveau joueur

#### Ascensions
- Gérer plusieurs 'ascensions' avec tous les plateaux:
  - 1 ascension = Atteindre un niveau maximum et finir 1 plateau
  - Afficher le message de felicitations "Everest"
  - Réinitiliser le niveau au plus bas pour réaliser un autre "Everest" sur un autre chemin.
- Faire apparaitre l'avancement dans l'ascension. La distance jusqu'à la fin ... (peut-etre une jauge pour chaque niveau)
  	- Remplacer "Niveau X.Y" par "Campagne : XX%" avant de commencer une nouvelle ascension
  	- Remplacer "Niveau X.Y" par "Ascension : XX%" pendant une ascension
- Ajouter un champs 'Ascension' dans les infos joueur pour indiquer le niveau de terminaison de l'ascension actuelle.

#### Android
- Pour Android : réorganiser les piles au centre de l'écran
- Pour Android : élargir la zone de clique pour les piles. Trop de frustration avec des cliques doigts dans le vide.
- Pour Android : essayer un export Web pour voir si cela fonctionne
- Editeur de plateau : La ligne de saisie est masquée par le clavier. Elle doit être en haut de l'écran.
- Faire vibrer le telephone lors de déplacement
- Faire vibrer FORT le telephone lors d'une pile achevée et bloquée.
- Faire vibrer plus FORT le telephone lorsque la partie est gagnée.

#### Graphisme
- Lors de la selection, eclairer le contours des piles d'arrivées valides.
- Quand une pile est bloquée, entourer la pile avec la couleur de jeton assombrie (inverse de la selection). Elle n'est plus selectionnable.


## V0.2 : Travaux réalisés
- jeu : Changer la couleur ou mettre en surbrillance le jeton ou la colonne selectionnée pour un mouvement.
- jeu : lire un JSON des niveaux/plateaux JSON
- jeu : enregistrer/lire un JSON (ou autre) des niveaux en cours
- jeu : sondage sur difficulté du plateau trop facile, bien, trop difficile. Abandon pour échec/réussite automatique
- jeu : si réussite, passer au niveau suivant, si échec descendre de niveau et passer au plateau suivant.
- jeu : prévoir un bouton de retour au menu pour abandonner
- jeu : menu en haut : campagne, éditer et références. ABANDON géré par la page d'accueil
- jeu : Page d'accueil : Nouveau joueur, campagne, scores, éditer et références.
- jeu : Page "Nouveau joueur" : apparence + edition du nom.
- jeu : Page "Campagne" : lien vers jeu + calcul du score + gestion du plateau à jouer + lien vers menu principal
- jeu : Page "Campagne" : Le nom du joueur courant, Niveau courant apparait dans l'écran "Commencer"
- jeu : Page "Menu principal" : L'accès à la campagne se fait par un bouton sans édition de texte
- jeu : Page "Scores" : apparence + calcul des scores + retour au menu principal
- jeu : Page "Editer un plateau" : apparence + edition plateau + jeu plateau + retour menu principal
- jeu : Page "Références" : apparence + retour menu principal
- jeu : Page "Références" : Lien vers les Crédits (GODOT, musique, effet sonore)
- jeu : prévoir un code pour que chaque joueur s'identifie.
- jeu : Détermination du score - Enregistrer le temps cumulé par niveau afin de le comptabiliser dans l'établissement du score. Rapide > lent
- jeu : Détermination du score - Enregistrer le nombre de partie jouées par niveau afin de comptabiliser les essais dans l'établissement du score. 1 essai > n essais
- jeu : Détermination du score - Le nombre d'essais devrait être plus pénalisant que le temps passé. Car pour réussir du premier coup, il faut bien analyser le plateau.
- jeu : Mesure de temps : faut-il comptabiliser le temps pour les victoires uniquements ?
- jeu : Quand un niveau est terminé, faire pointer sur le suivant pour être hors borne et ne plus rejouer le dernier niveau indéfiniement (supprimer 'plateau_victoire_dernier_plateau')

### Bug V0.2 :
- Le Bandeau d'information joueur n'a pas le score à jour après avoir joué (avéré sur l'affichage en fin d'ascension)
  - RAZ memoire + premier tableau fini. Score (bandeau info joueur) = 3600; Score (écran score) = 3776; Score (retour bandeau info joueur) = 3776
- Quand une pile est pleine, elle peut encore être selectionnée alors qu'elle devient immuable.
- Les cliques entre 2 jetons ne sont pas pris en compte.
- l'algorithme de difficulté est mauvais pour un plateau 3x5 qui est surclassé ! ("AABAA.A    .BBBB " 3x5 en X coups = difficulté 28) bien plus facile que ("BCA.CDB.CDA.BDA.   " 5x3 en X coups = 10) Abandon (c'est la cohabitation de l'ancienne échelle de difficulté de 1 à 10 qui cause cette discontinuité.)
- BUG ancien : Sur le plateau de jeu, agrandir la fenetre preserve les piles. Par contre, si l'agrandissement a lieu avant d'appuyer sur le bouton commencer, les piles ne vont pas apparaitre.
-  Ajout d'un nouveau joueur sans nom est accepté.
-  Ajout d'un nouveau joueur puis clique sur campagne double tous les joeurs.

## V0.1 : Liste et organisation pour Godot:

- Jeton : cube de couleur
	- contient la repesentation d'un jeton
- Pile : Colonne sur un plateau de jeu
	- Contient les regles de jeu subjectives :
	- Accepte un/des jeton(s) de couleur,
	- Donne un/des jeton(s) de couleur,
	- Est_terminé (colonne pleine mono-couleur),
	- Est_vide (aucun jeton dans la pile),
	- Est_pleine (aucune emplacement vide dans la pile)
  - Contient les caractéritstiques de la pile :
	- taille
	- Liste des jetons actuels
	- Encodage d'une pile:
		- "[0, 0, 0, 0]" = 4x'A' sur une pile de 4
		- "[0, 0, 0, 0, 32, 32]" = 4x'A' + 2x' ' sur une pile de 6
		- "[0, 1, 2, 32]" = 3x blocs et 1 case vide
- Plateau : ensemble des piles de jeu
	- Associe plusieurs piles pour former le plateau
	- Contient les regles subjectives :
		- Liste des mouvements autorisés, ABANDON géré par le bouton 'Abandonner'
		- Est_terminé (toutes les colonnes sont terminées),
		- Est_bloqué (la liste des mouvements autorisés est vide) ABANDON géré par le bouton 'Abandonner'
	- Encodage de plateau:
		- "AABB.BBAA.    " signifie :
		- pile 1 : "AABB"
		- pile 2 : "BBAA"
		- pile 3 : vide (4 emplacements)
	- "ABAB.BABA.    . "
		- pile 1 : "ABAB"
		- pile 2 : "BABA"
		- pile 3 : vide (4 emplacements)
		- pile 4 : vide (1 emplacement)
- Menu :
	- Page d'accueil
	- Liens entre les plateaux
	- Ligne de saisie pour générer un plateau à résoudre.
	- Lien vers les Crédits (GODOT, musique, effet sonore) Reporté V0.2

### Bug V0.1 :
- La recherche de solution n'implémente pas de déplacement obligatoire de plusieurs jetons
	- "ABBA.AB  .AB  " : ce plateau est impossible
