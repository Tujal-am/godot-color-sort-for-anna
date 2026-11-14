# Matrice de conformité — Classique

**STOP VALIDATION — aucun rendu antérieur n'est approuvé. Aucun nouveau lot visuel livré.**

Référence de méthode : [commentaire #6868365324](https://github.com/Tujal-am/godot-color-sort-for-anna/pull/4#issuecomment-6868365324). [Contrat et cotes](CONTRACT_MASTER_VERS_GODOT.md). Audit graphique des captures réelles du commit `fd171cf` (sources graphiques conservées dans `ad67b62`), comparées aux quatre **masters uniques normalisés** du ZIP. Les corrections de méthode/contrôles de cette reprise ne transforment pas cet audit en validation graphique.

`OK` = preuve disponible pour le critère indiqué. `KO` = écart mesuré, contrôle incomplet ou arbitrage non établi. Pour `geometry`, le bloc principal seul peut passer mais un titre, une grille ou le bandeau hors tolérance impose KO à l'écran. La conformité globale exige toutes les cellules OK ; aucune moyenne compensatoire.

| Écran | header | geometry | fonts | icons | copy | alpha | jetons | controls | Global |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| JOUER | **KO H1** | **KO G1** | **KO F1** | **KO I1** | **OK C1** | **KO A1** | **OK J0** | **KO N1** | **KO** |
| RECOMMENCER | **KO H1** | **KO G2** | **KO F2** | **KO I1** | **OK C1** | **KO A1** | **KO J1** | **KO N1** | **KO** |
| PASSER | **KO H1** | **KO G3** | **KO F3** | **KO I2** | **OK C1** | **KO A1** | **KO J1** | **KO N1** | **KO** |
| À TOI DE JOUER | **KO H1** | **KO G4** | **KO F4** | **KO I3** | **OK C1** | **KO A2** | **OK J0** | **KO N2** | **KO** |

## Causes, mesures, correctifs

| Code | Constat / mesure | Correctif ou preuve requis pour OK |
| --- | --- | --- |
| H1 | Bandeau natif présent et données liées aux services, mais la capture place le bandeau vers y15–90 ; l'étalon le place vers y40–116 : ≈25–26 px de décalage. | Mesurer et repositionner l'instance d'aperçu native ; conserver ses vraies ressources et ses données, sans redessiner le HUD. Ne pas modifier le HUD du vrai jeu pour corriger l'aperçu. |
| G1 | Encart JOUER proche de la cote (≈1 px) ; titre Godot `[157,222,234,241)` contre `[157,229,235,248)` : **7 px** verticalement. Corps Godot `[157,262,317,292)` contre ≈`[158,255,320,288)` : jusqu'à **7 px**. | Caler séparément l'encre du titre et du corps ; ne pas déplacer tout le panneau déjà correctement situé. |
| G2 | Encart Godot y160–260 contre master y151–267 : jusqu’à **9 px** ; titre Godot y187–206 contre master y176–193 : **11–13 px**. Plateau illustratif du rendu vers y286–461, contre étalon y277–453 : **9 px** au départ. | Reprendre cotes de l'encre et des rangées. Le master normalisé fait foi ; l’aperçu mobile diverge et ne doit plus guider cette page. |
| G3 | Encart/cadres PASSER proches des cotes ; titre Godot y181–200 contre y189–208 : **8 px**. Icône trop haute ; espacement des colonnes dérive vers la dernière colonne. | Placer icône/titre et mesurer chaque colonne, pas seulement les cadres externes. |
| G4 | Grand panneau, case et bouton sont proches (généralement ≤3 px) ; titre Godot `[113,229,364,269)` contre ≈`[113,233,382,272)` : **18 px** sur le bord droit. Soulignement droit au lieu de la forme observée. | Résoudre la police/forme du titre et le soulignement à partir de l'étalon. Ne pas étirer silencieusement le mot pour obtenir un rectangle correct. |
| F1 | Famille native utilisée, mais l'égalité de forme, de corps et d'interligne n'est pas prouvée ; déplacement du corps mesuré. | Comparaison des glyphes, couleur et lignes de base dans une capture jumelée. La présence de TeXGyre dans le dépôt ne vaut pas validation. |
| F2 | Largeur de l'encre du titre Godot ≈196 px ; largeur du titre du master normalisé ≈181 px. Le mélange des masques titre/corps de l'aperçu mobile avait donné une fausse largeur. | Fixer le corps/la graisse par mesure ; consigner l'incertitude. Ne pas renommer ou réécrire le texte. |
| F3 | Corps et titre proches visuellement mais pas de preuve de conformité des formes ; trois lignes du texte exact conservées. | Mesurer corps/poids/couleur et vérifier la dernière ligne à l'intérieur de l'encart. |
| F4 | Inclinaison synthétique et largeur du titre ne correspondent pas à une police identifiée ; texte du corps également décalé. | Identifier une ressource de police équivalente par comparaison ou maintenir KO ; pas de police de substitution présentée comme validée. |
| I1 | Vraies icônes RC20 utilisées ; l'absence de comparaison jumelée publiée après correction empêche de valider leur emprise finale et leurs états. | Comparer les pixels visibles avec la référence et conserver le ratio. KO de preuve, pas constat que la ressource native est erronée. |
| I2 | Icône PASSER rendue vers y185–241 contre référence y195–252 : ≈10–11 px trop haut. | Corriger son placement indépendamment du cadre. |
| I3 | Le bouton Compris est correctement placé mais le rendu est rouge plat ; la référence possède un dégradé. Le trait sous le titre n'est pas équivalent. | Ressource native indépendante reproduisant le style approuvé ; pas de master RGB aplati et pas d'invention de bouton. |
| C1 | Libellés validés conservés ; retours à la ligne de présentation. Nom/niveau/progression du HUD sont dynamiques. | Conserver ces chaînes. Ce OK de contenu ne valide ni typographie ni géométrie. |
| A1 | Panneaux Godot techniquement alpha mais valeur 0,70 choisie sans preuve de correspondance aux trois masters RGB. | Comparaison locale du rendu sur le vrai fond ; documenter le modèle d'alpha estimé et son résidu. Ne pas annoncer un RGBA exact extrait d'un RGB. |
| A2 | Fond final calque exact `(253,244,228,128)` → alpha **0,5019608** ; rendu actuel alpha **0,70**, soit +0,1980392. Bordure/case distinctes également à contrôler. | Appliquer les valeurs prouvées aux composants séparés, puis confirmer contre l'aperçu final. |
| J0 | Aucun jeton ne doit être ajouté sur JOUER ou FINAL. Cette absence est vérifiée dans les captures auditées. | Conserver l'absence. |
| J1 | Native RC20 préservé, mais apparence différente des références : carrés uniformes et ombre de lettre ; maquette arrondie/dégradée. B natif `(138,43,226)` uniforme, référence B exemple haut `(146,73,242)`, bas `(99,37,208)`. | Traiter séparément authenticité de l'instance et fidélité de style. Ne pas fabriquer une nouvelle apparence puis la déclarer validée. Ce point reste KO tant que la correspondance n'est pas démontrée. |
| N1 | Deux gros boutons ajoutés et rejetés dans les captures auditées. | **Suppression demandée prise en charge dans cette reprise.** Aucun « Ignorer l'intro » / « Continuer » substitué. Nouvelle navigation automatique préparée séparément, à tester sans la présenter comme validée. Le KO demeure jusqu'à preuve conjointe rendu/ergonomie. |
| N2 | « Compris » et case fonctionnent dans les tests antérieurs ; le style du bouton et du panneau final n'est pas conforme. | Préserver textes/comportements validés ; ne pas convertir la réussite du clic en validation visuelle. |

## Séparation des validations

- **Technique antérieure** : Godot réellement exécuté, chargement de 104 ressources, tests d'indépendance, préférences par joueur et chrono. Ces preuves restent valables pour ce qu'elles testent, pas comme approbation des captures.
- **Contrôle actuel** : contrat et matrice établis directement depuis les fichiers d'étalon, cotes et RGBA documentés ; gros boutons rejetés à retirer. Aucun nouveau lot d'images présenté comme conforme.
- **Cycle de correction à effectuer** : une passe fondée sur ce contrat, QA interne jumelée, mise à jour de chaque cellule par preuve. Les polices, styles de jetons et dégradés ne doivent pas être déclarés identiques par simple proximité de rectangle.
- **Publication finale bloquée** tant qu'une cellule est KO. Ne pas annoncer une nouvelle planche « à valider » pour transférer ces vérifications à l'utilisatrice.

## Décision du recadrage le plus récent

Le contrat canonique `CONTRACT_MASTER_VERS_GODOT.md` et cette matrice sont publiés **avant toute nouvelle planche**. L’audit de référence reste FAIL sur les quatre écrans. Les essais locaux de correction, non publiés, ne constituent pas une nouvelle référence et ne sont pas approuvés. Leur matrice après correction devra être calculée contre les masters uniques, pas contre l’aperçu RECOMMENCER divergent.

Les libellés rejetés n’ont aucun remplacement autorisé. Le bouton final Compris reste le seul bouton graphique validé. La présence d’un passage automatique local n’est pas une validation d’ergonomie.

Aucun nouveau PNG de rendu, aucune nouvelle planche et aucun ZIP d’images ne sont publiés avec ce contrat initial. Les anciens fichiers accessibles sur GitHub sont des **archives techniques non approuvées**.
