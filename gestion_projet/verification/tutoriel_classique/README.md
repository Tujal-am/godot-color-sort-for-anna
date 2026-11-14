> **STOP VALIDATION GRAPHIQUE — LOT NON APPROUVÉ.** Ces captures documentent le premier passage fonctionnel, pas une conformité aux masters. Consulter le [contrat canonique](../../../CONTRACT_MASTER_VERS_GODOT.md) et la [matrice FAIL](../../../MATRICE_CONFORMITE_CLASSIQUE.md). Aucune nouvelle planche ne doit être publiée avant la porte de contrôle.

# Tutoriel Classique RC20 — exécution et contrôle du 14 novembre 2026

[Planche des quatre captures](PLANCHE_GODOT.png) · [ZIP des captures et de la vidéo](RTC_CLASSIQUE_CAPTURES_ET_VIDEO.zip) · [Vidéo Godot, 22 secondes](CLASSIQUE_GODOT.mp4)

Les quatre captures individuelles sont nommées [JOUER](captures/JOUER.png), [RECOMMENCER](captures/RECOMMENCER.png), [PASSER](captures/PASSER.png) et [À TOI DE JOUER](captures/A_TOI_DE_JOUER.png). Chaque capture provient directement du viewport Godot 480×720, sans recomposition de son contenu. La planche ajoute seulement les titres autour des captures. Le MP4 est l'encodage H.264 d'un enregistrement `--write-movie` du moteur : 647 images, 30 i/s, 480×720, 21,57 secondes, sans son.

## Référence et périmètre

- Branche travaillée : `feature/rc20-tutoriel-classique-scenes`, PR #4 maintenue en brouillon. Aucun merge.
- Révision de départ : `a64f76f2f6a82c90e6e58e8721978152a4c6c863`.
- Branche distante RC20 vérifiée avant/après : `f3cb63b82ed68a5d113e139a81473d0656c0e389`, inchangée.
- Kit fourni : `RTC_RC20_Classique_Kit_Integration_Visuels_HD.zip`, SHA-256 `0c43505638e5c8df754cda3552c5e92a059f51ad114c78b53f2d97c59977fda0`. Les 14 fichiers PNG correspondent au manifeste joint. Les quatre HD RGB servent uniquement de références ; aucun master aplati n'est ajouté au runtime.
- Le calque RGBA est identifié comme ressource alpha indépendante, mais n'est pas utilisé : les panneaux sont des `Panel` / `StyleBoxFlat` Godot avec alpha réel.
- Dispositions du kit reprises : encarts compacts des commandes, deux plateaux distincts pour PASSER, panneau final 416×383 à (32,192), case vide de 30×30, texte et bouton séparés.
- Les fonds, HUD, boutons de jeu, couleurs et lettres restent ceux des sources RC20. Les jetons sont les vrais carrés RC20, et non les jetons arrondis visibles dans certaines maquettes. La typographie est celle des polices natives du dépôt. Il ne s'agit donc pas d'une copie pixel à pixel des images RGB.
- QPG exclu de cette livraison ; aucune scène ou règle QPG modifiée.

## Corrections

1. **Transformation et visibilité des jetons.** La scène native du jeton a une racine `Node` : ses enfants ne reçoivent pas les transformations du conteneur du tutoriel. Le premier rendu montrait tous les jetons superposés à (0,0). L'adaptateur local `jeton_tutoriel.tscn` conserve exactement le script et les cinq composants graphiques natifs, avec une racine `Control`, sans modifier le jeton du vrai plateau. Aucun UID de scène dupliqué. Les mini-plateaux utilisent aussi cet adaptateur.
2. **Cycle de vie.** L'aperçu du bandeau RC20 est une instance indépendante et passive, sans signaux de jeu connectés. Ses contrôles ignorent les entrées et le focus. Il est explicitement masqué avec le CanvasLayer : aucun fond ou contrôle résiduel ne gêne le bouton « ? » après fermeture. Le tween est arrêté à la fermeture, au redémarrage et à la sortie de l'arbre.
3. **Transfert B/B.** Les deux B gardent leur distance pendant le transfert, le C reste immobile, les soudures natives relient le groupe. Chaque ouverture restaure les positions et les soudures du départ.
4. **Présentation.** Ancrage plein viewport, panneaux translucides, textes du kit conservés (retours à la ligne de présentation), navigation lisible, possibilité de terminer la démonstration dès le début. La conclusion conserve « À toi de jouer ! », la case initialement décochée et « Compris ».
5. **Joueurs.** Présentation automatique une fois par joueur et par session, y compris après recréation de la scène. `ConfigFile` conserve « Ne plus afficher » séparément par nom de joueur. L'aide manuelle reste disponible ; décocher puis confirmer réactive les prochaines sessions.
6. **Vrai plateau.** Pendant l'aide en jeu, les entrées et le traitement du menu/plateau sont suspendus puis restaurés. La lecture du chrono est figée ; le temps de lecture est exclu de la durée à la reprise et au calcul final, sans changer les dates réelles, les coups, les règles ou les jetons. Le champ supplémentaire `duree_aide_classique` n'est renseigné que pour une partie ayant effectivement ouvert l'aide Classique.

## Tests réellement exécutés

Environnement : Linux, Godot **4.6.3 stable officiel**, rendu OpenGL Compatibility / llvmpipe sur serveur Xorg virtuel. GUT **9.5.0** (`8255c63`), installé localement dans le dossier ignoré `addons/gut`. Sauvegardes de test séparées par `XDG_DATA_HOME` ; aucune sauvegarde personnelle utilisée.

| Vérification | Résultat | Preuve |
| --- | --- | --- |
| Chargement par Godot des scripts/scènes de `Scenes` et `Singletons` | **104 ressources, 0 échec de chargement** | [Journal](logs/chargement_104_ressources.log) |
| Intégration graphique, pointeurs injectés dans le viewport réel | **50 contrôles, 0 échec** | [Journal complet](logs/integration_50_controles.log) |
| Pause et calcul de durée, tests GUT ajoutés | **3 tests, 13 assertions, tous réussis** | [Journal](logs/pause_aide_3_tests.log) |
| Classique / MenuPlateau / Campagne, suites existantes | **21/21 + 25/25 + 16/16 réussis** | [Journal des 198 tests](logs/regression_198_tests.log) |
| Régression élargie incluant les sauvegardes | **196/198 réussis, 2 échecs préexistants** | [Journal](logs/regression_198_tests.log) |
| Même régression sur la révision de départ, checkout séparé | **192/195 réussis, 3 échecs** | [Contre-test de départ](logs/regression_branche_initiale_195_tests.log) |
| Accueil réel → création joueur → campagne → cinématique → Compris | **Retour au menu avant plateau, chrono non lancé** | [Journal vidéo](logs/parcours_accueil_video.log) |
| ZIP / PNG / MP4 livrés | ZIP relu sans erreur ; PNG 480×720 ; MP4 décodé et quatre passages inspectés | Fichiers ci-dessus |

Les 50 contrôles couvrent notamment : premier accès, surface 480×720, clic derrière le panneau sans lancement, transfert et conservation de C, soudures, enchaînement des commandes par clic, contenu dans les panneaux, conclusion, fermeture, bouton « ? », interruption puis réouverture, passage direct à la fin, case cliquable, relecture de préférence depuis le disque, deuxième joueur indépendant, sauvegarde et piles réelles inchangées pendant l'animation, nombre de coups inchangé, pause/reprise du chrono, sortie et destruction de la scène.

**La suite élargie n'est pas entièrement verte.** Les deux échecs finaux sont `test_terminer_campagne_renseigne_la_date_de_fin_une_seule_fois` (égalité exacte d'un flottant de date après JSON) et `test_coups_joues_sur_un_plateau_sans_cle_coups_joues_conserve_le_coup`. Ils échouent également sur la révision initiale. Un troisième test de date de fin de niveau échoue sur le contre-test initial mais passe sur l'essai final : comportement intermittent de comparaison de flottants. Ces problèmes n'ont pas été masqués ni corrigés dans le périmètre du tutoriel.

L'import de l'éditeur produit aussi les messages existants de compatibilité des presets d'export (`runnable` absent, projet déclaré 4.7 ouvert en 4.6.3), ainsi que l'avertissement sur le plugin SharePlugin absent du checkout. Voir [journal d'import](logs/import_editeur.log). Ils ne sont pas des erreurs de parsing GDScript/.tscn ; les exports Web/Android/iOS ne sont pas validés par cet essai.

## Reproduire

Depuis la racine du dépôt, avec Godot 4 disponible :

```bash
rtc_test_dir=$(mktemp -d)
mkdir -p "$rtc_test_dir/captures"
XDG_DATA_HOME="$rtc_test_dir/data" XDG_CONFIG_HOME="$rtc_test_dir/config" XDG_CACHE_HOME="$rtc_test_dir/cache" godot --headless --path sources --editor --import --quit
RTC_CAPTURE_DIR="$rtc_test_dir/captures" XDG_DATA_HOME="$rtc_test_dir/data" XDG_CONFIG_HOME="$rtc_test_dir/config" XDG_CACHE_HOME="$rtc_test_dir/cache" godot --path sources --script res://tests/tutoriel_classique_integration.gd --audio-driver Dummy
```

Le second appel nécessite un affichage graphique pour les captures. Le script utilise uniquement les comptes « Anna (test) » et « Joueur B (test) » dans ce dossier temporaire. Ne pas exécuter ces parcours avec les sauvegardes personnelles. Pour filmer le parcours de l'accueil, utiliser un **autre dossier temporaire neuf** et `res://tests/presentation_classique.gd --write-movie /tmp/classique.avi --fixed-fps 30`.

## Validation restante

La fidélité créative finale appartient à l'utilisatrice à partir des captures et de la vidéo fournies. Aucun essai sur téléphone physique, export jouable Web/Android/iOS ni validation du son. RC20 reste intacte et la PR reste en brouillon jusqu'à cette validation.
