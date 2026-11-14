# Contrat MASTER → Godot — Classique 480×720

**Statut : contrat de contrôle mesuré, pas une validation des rendus précédents.** Application du [recadrage #6868365324](https://github.com/Tujal-am/godot-color-sort-for-anna/pull/4#issuecomment-6868365324). Aucun nouveau lot visuel ne doit être publié tant que la [matrice](MATRICE_CONFORMITE_CLASSIQUE.md) contient un KO. RC20 reste intacte ; QPG exclu.

## 1. Étalons et conventions

Le ZIP contient des **références**, pas des composants Godot prêts à assembler. Les quatre fichiers de `01_REFERENCES_VALIDEES` sont les **masters uniques**, conformément au dernier recadrage. Ils sont normalisés chacun vers 480×720 avec leur propre facteur ; les aperçus mobiles sont secondaires. Les mesures ne partent pas d'une reconstitution ou des rendus Godot précédents.

| Écran | Dimensions constatées du master | Facteur réel vers 480×720 | Master unique |
| --- | --- | --- | --- |
| JOUER | 960×1440 | 0,5 | `01_REFERENCES_VALIDEES/01_JOUER_HD.png` |
| RECOMMENCER | 960×1440 | 0,5 | `01_REFERENCES_VALIDEES/02_RECOMMENCER_HD.png` |
| PASSER | 960×1440 | 0,5 | `01_REFERENCES_VALIDEES/03_PASSER_HD.png` |
| FINAL | 1024×1536 | **0,46875** | `01_REFERENCES_VALIDEES/04_A_TOI_DE_JOUER_HD.png` |

Les 14 PNG correspondent au manifeste SHA-256 du kit. [Mesures numériques et provenance](gestion_projet/verification/tutoriel_classique/mesures/mesures_masters_480.json) ; [script reproductible](gestion_projet/verification/tutoriel_classique/mesures/mesurer_masters.py). Les références restent inchangées et ne sont pas ajoutées comme textures d'interface.

**Écart factuel avec le dernier message :** le ZIP ne contient pas quatre masters 1024×1536. Les dimensions ci-dessus sont lues avec Pillow et concordent avec le manifeste SHA-256. Appliquer 0,46875 aux trois fichiers 960×1440 donnerait **450×675**, pas 480×720. Aucune cote n'est calculée avec ce facteur erroné.

**Divergence interne du kit confirmée :** les aperçus JOUER, PASSER et FINAL sont strictement égaux aux masters normalisés en Lanczos. RECOMMENCER ne l'est pas : 8,2607 % des pixels diffèrent ; erreur RGB moyenne 2,7574/255. Son aperçu place l'encart y160–260 et le titre y197–214 ; le master normalisé place l'encart **y151–267** et le titre **y176–193**. Le master est retenu ; le choix antérieur de l'aperçu est abandonné. [Preuve numérique](gestion_projet/verification/tutoriel_classique/mesures/divergence_masters_apercus.json).

Coordonnées en pixels logiques, origine en haut à gauche, boîtes **semi-ouvertes** `[x0,y0,x1,y1)` ; largeur `x1−x0`. Un bord raster peut occuper le pixel `x1−1`. Incertitude ±1 px sur les traits, ±1–2 px sur l'encre antialiasée. Une boîte d'encre n'est pas la boîte `Label` : le contrôle peut être plus grand mais doit produire l'encre à l'endroit mesuré.

Tolérance issue de la consigne : objectif **≤4 px** par bord de bloc majeur ; maximum **6 px**. Plus de 6 px = KO. Un écart ≤6 px ne rend pas automatiquement conformes la police, l'icône, le dégradé ou le texte. Les contenus réels nom/niveau/progression sont exclus de la comparaison de contenu, pas les positions du bandeau. Aucun alignement automatique du rendu pour masquer un décalage.

## 2. Correspondance géométrique

Préfixe de nœud `T = Classique/TutorielClassique`. `C = T/Surface/Cartouche`. Les boîtes ci-dessous décrivent les **pixels visibles attendus**, pas des mesures supposées de l'intérieur des PNG.

| Écran / objet | Boîte étalon 480×720 | Nœud / ressource attendu | Contrôle |
| --- | --- | --- | --- |
| JOUER / bandeau menu | zone y40–116 ; maison ≈x16–78/y47–109 ; jouer ≈x307–370/y47–110 | `T/ApercuMenu/BandeauMenu`, instance native `menu_plateau_classique.tscn` | BandeauMenu réel, nom/niveau/progression liés aux services ; aucune valeur inventée ; géométrie du bandeau contrôlée séparément |
| JOUER / encart | `[32,195,449,314)` | `C`, `Panel` + `StyleBoxFlat` | Traits forts mesurés x32/448 et y195/313 ; pas de grand panneau supplémentaire |
| JOUER / icône | `[59,226,114,281)` | `C/Commandes/Jouer`, `button_play.svg` natif | Conserver le ratio, comparer les pixels visibles et non le rectangle TextureRect uniquement |
| JOUER / titre, encre | `[157,229,235,248)` | `C/Titre`, `Label` | « JOUER » ; couleur, graisse, forme et ligne de base |
| JOUER / corps, encre | ≈`[158,255,320,288)` | `C/Description`, `Label` | Deux lignes : « Lance le plateau et » / « démarre le chrono. » |
| JOUER / séparation | `[135,219,136,294)` | `C/Separateur`, `ColorRect` | Trait fin ; aucune barre épaisse |
| JOUER / plateau | **absent** | `PlateauUn`/`PlateauDeux` masqués | Ne pas ajouter d'illustration sous l'encart |
| RECOMMENCER / bandeau | y40–116 | `T/ApercuMenu/BandeauEnJeu` natif | CLASSIQUE, sous-titre, recommencer, chrono illustratif 00:00.0, passer ; aucune action de jeu |
| RECOMMENCER / encart | `[32,151,449,268)` | `C` | Traits forts du **master** normalisé x32/448 et y151/267 ; l'aperçu mobile diverge |
| RECOMMENCER / icône | `[58,181,114,237)` | `C/Commandes/Recommencer`, PNG natif | Même ressource que le vrai jeu, sans redessin |
| RECOMMENCER / titre, encre | `[158,176,339,194)` | `C/Titre` | « RECOMMENCER » ; masque de couleur du master normalisé, sans le confondre avec le corps |
| RECOMMENCER / corps, encre | ≈`[157,214,379,254)` | `C/Description` | « Le plateau recommence à » / « son point de départ. » ; l'écart avec le titre doit suivre le master, pas leur quasi-chevauchement dans l'aperçu divergent |
| RECOMMENCER / séparation | `[135,178,136,243)` | `C/Separateur` | Pas d'extrapolation à partir de JOUER |
| RECOMMENCER / plateau complet | ≈`[40,277,441,453)` | `C/Commandes/PlateauUn`, cellules natives séparées | Trois rangées ; cinq colonnes ; col. 3 vide ; pas d'étirement non uniforme des lettres |
| PASSER / bandeau | y40–116 | `T/ApercuMenu/BandeauEnJeu` natif | Chrono illustratif 00:02.2 ; aucun chrono réel lancé par cette page |
| PASSER / encart | `[32,153,449,288)` | `C` | Traits forts x32/448, y153/287 ; aucun texte au-delà du panneau |
| PASSER / icône | `[57,195,113,252)` | `C/Commandes/Passer`, SVG natif | Pixels visibles ; ressource du vrai jeu |
| PASSER / titre, encre | `[159,189,246,208)` | `C/Titre` | « PASSER » |
| PASSER / corps, encre | ≈`[158,213,404,272)` | `C/Description` | « Un nouveau plateau apparaît. » / « Attention, le précédent plateau » / « sera considéré comme perdu. » |
| PASSER / séparation | `[136,180,137,257)` | `C/Separateur` | Trait fin |
| PASSER / cadre gauche | ≈`[18,330,230,510)` | `C/Commandes/PlateauQuitte` | Titre exact « PLATEAU QUITTÉ » ; fond alpha ; aucune donnée réelle de partie |
| PASSER / cadre droit | ≈`[251,330,462,510)` | `C/Commandes/NouveauPlateau` | Titre exact « NOUVEAU PLATEAU » ; tableau distinct |
| PASSER / grilles | gauche ≈x29–211/y364–474 ; droite ≈x263–445/y364–474 | `PlateauUn`, `PlateauDeux` | Mesurer première et dernière colonnes, pas seulement l'emprise du parent ; pas de dérive cumulée de l'espacement |
| PASSER / flèche | ≈`[228,402,254,427)` | `C/Commandes/Fleche`, `Label` ou objet vectoriel natif | Position et couleur issues de l'étalon ; pas une nouvelle icône |
| Trois commandes / badge | ≈`[49,653,431,691)` | `T/Surface/Mention` + `Texte` | Texte exact « Démonstration • aucune action réelle » ; pas de badge au FINAL |
| FINAL / panneau | ≈`[31,192,451,576)` | `C`, `Panel` alpha | Support alpha exact du calque projeté : `[30.9375,191.25,450.9375,575.625)` ; le master RGB normalisé reste l'étalon visible |
| FINAL / titre, encre | ≈`[113,233,382,272)` | `C/Final/TitreFinal`, `Label` | « À toi de jouer ! » ; gras incliné ; pas une police de remplacement déclarée conforme sans preuve |
| FINAL / soulignement | ≈`[160,272,335,281)` | `C/Final/Soulignement` | Trait courbe/orange observé ; la ligne droite actuelle n'est pas réputée équivalente |
| FINAL / corps, encre | ≈x128–353/y302–337 | `C/Final/TexteFinal`, `Label` | « C'est parti ! Lance la partie » / « et range les couleurs ! » |
| FINAL / case vide | ≈`[65,369,98,401)` | `NePlusAfficher`, `CaseVide`, `Coche` | Décochée à chaque ouverture, contour bleu, fond réellement translucide ; symbole coché uniquement après action |
| FINAL / libellé case | ≈`[128,375,400,390)` | `NePlusAfficher` | « Ne plus afficher cette introduction » ; ne pas renommer |
| FINAL / Compris | ≈`[131,483,351,545)` | `C/Final/Compris`, vrai `Button` | « Compris » ; rouge dégradé observé, coins arrondis ; aucun bouton ajouté à côté |

Les approximations marquées `≈` restent des observations raster, pas des cotes vectorielles inventées. Pour un OK final, la capture jumelée doit confirmer les bords des vrais objets.

## 3. Styles, couleurs, alpha, polices

### FINAL : valeurs prouvées par le calque RGBA

| Élément | Valeur RGBA prouvée (0–255) | Valeur Godot attendue / réserve |
| --- | --- | --- |
| Fond du panneau | **(253,244,228,128)**, 564658 pixels exacts dans le calque | `Color(253/255,244/255,228/255,128/255)` ; **alpha 0,5019608**, pas 0,70 |
| Contour | (227,133,79,215) | Bordure native, épaisseur et rayon contrôlés à l'écran ; ne pas confondre alpha du bord et du fond |
| Titre | (15,58,104,255) | Couleur distincte du corps |
| Corps / libellé | (9,63,112,255) | Nœuds Label séparés ; ne pas intégrer l'image entière |
| Contour case | (32,86,135,240) | Trait natif ; intérieur du calque : blanc alpha 55/255 |
| Bouton rouge | **dégradé non uniforme**, ex. centre haut HD `(239,101,56)` à y1032 ; bas `(187,63,36)` à y1140 | Le remplissage plat actuel ne suffit pas ; reconstruire l'effet approuvé en ressource native indépendante, jamais découper tout le panneau RGB |

Un master RGB aplati ne permet pas de retrouver de façon unique la couleur **et** l'alpha d'origine. Les RGBA ci-dessus viennent du calque indépendant ; leur correspondance visuelle au PNG final doit encore être contrôlée. Pour les trois commandes, les couleurs sombres de texte mesurées autour de `(20,107,151)` (titres) et `(21,70,117)` (corps) servent de points de contrôle, pas de prétendus styles vectoriels extraits d'un RGB.

### Polices et jetons : preuves exigées, pas de substitution silencieuse

Le ZIP ne contient ni fichier de police, ni fichier de scène jeton approuvé. Le dépôt RC20 contient TeXGyreAdventor regular/bold et le jeton carré `jeton.tscn`. Le titre final actuellement en TeX bold avec inclinaison synthétique **n'est pas démontré identique** à l'étalon. Sa largeur d'encre mesurée est 251 px dans Godot contre ≈269 px dans la référence. Un ajustement de taille ou un étirement ne vaut pas identification de police.

Les jetons de la maquette sont arrondis et dégradés. Exemple B de RECOMMENCER : pixels RGB `(146,73,242)` en haut et `(99,37,208)` en bas ; le `Carre` RC20 est uniformément `(138,43,226)`. Les instances doivent rester séparées et indépendantes du vrai plateau. **Le maintien du jeton natif et la fidélité graphique à la maquette sont deux contrôles distincts** ; ne pas déclarer le second OK au seul motif que le premier est respecté. Aucun nouveau style de jeton n'est réputé approuvé par ce document. Tout override local doit être comparé au master ; le jeton du vrai jeu reste intact.

## 4. Comportements et contrôles

- Supprimer les gros boutons « Terminer l'aide » et « Suivant », leur conteneur visible et leurs styles exclusifs. Ne pas substituer « Ignorer l'intro », « Continuer » ou un autre libellé non validé.
- Seul « Compris » est un bouton final validé. Il ramène à l'écran avant plateau lors de la première visite ; il ne lance pas le chrono.
- Préparer la navigation hors du graphisme approuvé : déroulement automatique proposé techniquement de 4 s JOUER, 4 s RECOMMENCER, 6 s PASSER, puis attente sur le FINAL. **Ces durées sont une hypothèse de fonctionnement, pas une validation d'ergonomie.** Aucun nouveau libellé ou pictogramme. Les sorties/réouvertures doivent annuler les transitions retardées.
- Préférence séparée par joueur ; case initialement décochée ; « ? » permet de revoir l'aide. Noms/niveaux/progression du bandeau proviennent des services réels.
- Les deux mini-plateaux de PASSER sont des illustrations distinctes, jamais une mutation du plateau réel. Ni coups, ni règles, ni progression ne sont modifiés par les animations. L'aide en partie suspend/reprend correctement le chrono.

## 5. Porte de contrôle avant toute publication d'images

1. Vérifier le manifeste et les quatre dimensions d'étalon, sans facteur global aux masters.
2. Pour chaque écran, conserver en interne : master normalisé 480×720, capture réelle Godot 480×720, vue jumelée, différence/superposition, dump des rectangles et styles des nœuds. Le HUD dynamique reste identifié comme tel.
3. Mesurer les bords des objets et l'encre des textes **dans la capture**, en complément du dump Godot. Tester les coordonnées sans translation préalable du rendu.
4. Remplir les huit colonnes : header, geometry, fonts, icons, copy, alpha, jetons, controls. Un doute ou un élément non vérifié est **KO**, jamais « probablement OK ».
5. Vérifier indépendance du plateau, transfert B/B, réouverture, case par joueur, chrono et progression, puis les régressions. Les tests logiques verts ne valident pas l'esthétique.
6. **Un KO bloque la planche et le ZIP de validation.** Publier seulement le contrat, les mesures et l'état des blocages tant que la porte n'est pas franchie. Les anciennes captures restent des traces techniques explicitement non approuvées.

## 6. Ressources et effets — limite de reconstruction

Les contrôles sont des objets natifs distincts. Les seuls découpages éventuellement autorisés concernent les effets non reconstructibles nativement, après nécessité documentée et provenance exacte. **Pas de découpage automatique d'un avatar, d'un bandeau ou d'un bouton dans un master RGB pour masquer une correspondance manquante.** Les essais locaux non approuvés ne sont pas intégrés à un lot de validation. Aucun master aplati en interface jouable.

Le fichier historique `CONTRAT_MAQUETTE_VERS_GODOT.md` renvoie à ce contrat canonique. Il n'existe pas deux contrats graphiques concurrents.
