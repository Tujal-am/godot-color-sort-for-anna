# Jetons QPG — report RC14

Base : Tujal-am/godot-color-sort-for-anna, BR_V1.0.0-rc14, 322ca73 (QPG V26).
Visuels validés : dix textures A–J, bombe pleine, diablotin plein aux yeux en amande et sourire fin.

Production : ajout des textures et de scènes héritées jeton_qpg/pile_qpg. Dans qui_perd_gagne.tscn, seule la ressource pile_scene de Plateau est surchargée. Scripts existants identiques octet pour octet à322ca73. Fond, HUD, boutons, pile vide et Classique inchangés.

Vérification Godot4.6.1 : identité/couleur métier, sélection/clic, visibilité, position/échelle, cases vides/K/Z, ajout/retrait PASS. En QPG et Classique : refus destination pleine, deux transferts natifs, pile complète, soudures haut/bas et pile terminée non déplaçable PASS. Rendu réel : pile cinq symboles identiques, puis dix piles de cinq, largeurs360/390/480 PASS. Les captures utiles du jeu conservent son ratio2:3. Aucun essai matériel téléphone, aucun parcours complet campagne, version4.7.2 non testée.

Lancer les scripts de vérification avec Godot --headless --path sources --script [chemin absolu du script].
