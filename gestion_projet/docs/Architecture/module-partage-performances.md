# Module de partage des performances

Le module `PartagePerformances` fournit une API pour signer des enregistrements JSON et les présenter dans un QR. Il ne collecte pas les enregistrements : le code appelant lui transmet le dictionnaire extrait du niveau terminé.

## Intégration avec les enregistrements du niveau

Après avoir extrait les enregistrements, appeler le menu de campagne :

```gdscript
$MenuCampagne.afficher_partage_performances(enregistrements_du_niveau)
```

Le dictionnaire doit être sérialisable en JSON. À la fin d'un niveau ou de la campagne, le panneau de score s'affiche en premier. Lorsque le joueur le quitte, le partage s'ouvre automatiquement et lit les données via `PartagePerformancesAPI.lire_donnees_dernier_niveau()` :

```gdscript
{
    "nom": SauvegardeBddJoueursService.lire_nom_joueur(),
    "niveau": SauvegardeBddJoueursService.enregistrement_lire_dernier_niveau()
}
```

Après fermeture du partage, le jeu reprend son parcours normal : niveau suivant ou statistiques de campagne. `MenuCampagne.afficher_partage_performances()` reste disponible pour afficher le panneau avec un dictionnaire fourni par un appelant.

Le panneau conserve deux options :

- Sur Android, « Partager le QR code » transmet l'image QR au dialogue natif de partage (`Share.share_texture`). Le joueur choisit ensuite l'application de destination.
- L'adresse `rangelescouleurspouranna@gmail.com` reste affichée et peut être copiée. Pour l'envoyer manuellement par courriel, le joueur peut faire une capture d'écran du QR et la joindre à son message.

Le projet n'envoie aucun courriel automatiquement.

## Réception et validation d'un QR

La scène expose `recevoir_image_qr(image: Image)`. Le décodage est asynchrone via Godot QR Plugin. Après validation de l'enveloppe et du HMAC avec la clé configurée, la scène émet `partage_qr_code(donnees_json: Dictionary)`. Aucune donnée n'est émise si le QR est mal formé, si la signature est invalide ou si le plugin n'est pas disponible.

```gdscript
$PanneauPartagePerformances.partage_qr_code.connect(_on_partage_qr_code)
$PanneauPartagePerformances.recevoir_image_qr(image_qr)

func _on_partage_qr_code(donnees_json: Dictionary) -> void:
    print(donnees_json)
```

Sur Android, l'autoload `ShareService` maintient le plugin SHARE disponible et active la réception d'images dans le sélecteur de partage. `PartagePerformancesImportService` écoute `share_received`, charge l'image reçue et la transmet au décodeur existant. Après validation de la signature et de la structure attendue, il émet également son signal global `partage_qr_code(qr_data: Dictionary)`.

Un QR valide ouvre le menu principal et son panneau de confirmation, qui affiche le nom et le niveau importés. « Refuser » annule l'opération et laisse le joueur dans le menu. « Accepter » crée le profil sous le nom du QR s'il est disponible (comparaison insensible à la casse) ; sinon, le suffixe « (import) » est essayé. Si ce profil suffixé existe déjà, les statistiques sont importées dans ce profil, à condition que sa campagne soit terminée. Après un import réussi, le jeu ouvre les statistiques de ce joueur.

Un QR invalide ne déclenche aucune navigation ni modification de sauvegarde. L'image reçue et les ressources de décodage sont libérées, puis `LogService.log_erreur("Erreur sur import QR, aucune action.")` trace l'échec.

## Format du QR

Le QR contient un objet JSON de la forme :

```json
{
  "version": 1,
  "algorithme": "HMAC-SHA256",
  "donnees_json": "{\"niveau\":3}",
  "signature": "empreinte hexadécimale"
}
```

La signature porte sur les octets UTF-8 exacts de `donnees_json`. Le texte JSON des enregistrements est donc conservé dans l'enveloppe pour permettre au destinataire de recalculer la signature sans ambiguïté de sérialisation.

## Clé et sécurité

La clé est définie par `partage_performances/cle_hmac` dans `sources/project.godot`. La valeur livrée est une clé de démonstration à remplacer. Toute clé incluse dans une application distribuée peut être extraite : ce HMAC aide à détecter une altération accidentelle, mais ne prouve pas l'authenticité d'un score face à un client modifié. Pour une validation fiable, le HMAC devra être produit par un service serveur qui conserve la clé hors du jeu.

## Plateformes

Le plugin QR Godot Mobile v1.2 est utilisé pour Android et iOS. Le partage natif Godot Share v6.0 est utilisé pour l'envoi et la réception sur Android. Ces addons sont exclus du dépôt par le `.gitignore` racine et doivent être installés localement. La génération et le décodage du QR dépendent de l'extension native; la réception par le sélecteur de partage et le partage natif sont réservés à Android. L'adresse du courriel reste copiable sur toutes les plateformes.

## À développer

- À terme, remplacer le panneau dédié par un bouton « Partager » directement dans le panneau de score de fin de niveau ou de fin de campagne.
- Le panneau de partage détaillé actuel est conservé uniquement pour la bêta-test et pourra être retiré lorsque l'export depuis les panneaux de score sera prêt.
