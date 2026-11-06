# Module de partage des performances

Le module `PartagePerformances` exporte la dernière campagne complète du joueur dans un fichier JSON signé. Il utilise le dialogue natif du plugin SHARE sur Android pour l'export et l'import. La collecte des enregistrements reste gérée par le jeu.

## Données exportées

Le contenu signé est un objet JSON avec le nom du joueur et l'enregistrement complet de sa dernière campagne :

```json
{
  "joueur": "Joueuse",
  "campagne": {
    "campagne": "campagne_2",
    "date_debut": 100,
    "date_fin": 200,
    "score": {},
    "niveaux": [
      {
        "niveau": "niveau_3",
        "score": {},
        "plateaux": []
      }
    ]
  }
}
```

Le fichier transmis est une enveloppe JSON contenant `version`, `algorithme`, `donnees_json` et `signature`. Le HMAC-SHA256 est calculé sur les octets UTF-8 exacts de `donnees_json`; l'import vérifie la signature avant de valider la structure ou de modifier une sauvegarde.

## Export et rattrapage

Après la fin d'une campagne, l'écran des statistiques affiche le panneau de partage si cette campagne n'a pas déjà été partagée. Il indique le joueur, le nom de la campagne et le dernier niveau. « Retour aux statistiques » masque le panneau et laisse les statistiques accessibles.

Sur Android, « Partager le fichier JSON » ouvre le dialogue SHARE. Le fichier porte le nom `rtc_[nom_campagne]_[nom_joueur].json`; les caractères interdits dans les noms de fichier sont remplacés par des `_`. Le panneau affiche aussi l'adresse `rangelescouleurspouranna@gmail.com` et permet de la copier dans le presse-papiers, afin que le joueur puisse joindre le fichier JSON à un courriel. Une campagne n'est marquée comme partagée qu'après le signal `share_completed`; une annulation ou un échec ne la marque pas comme telle. Le suivi est stocké dans la sauvegarde du joueur à partir d'une empreinte SHA-256 de la campagne, sans ajouter de métadonnée interne aux données exportées.

## Import

Le fichier reçu par SHARE est contrôlé pour son type, sa signature, le nom du joueur et la structure complète de campagne. L'extension `.json` est acceptée si elle est présente; un fichier sans extension est aussi accepté. Après validation, le menu principal présente le joueur, la campagne et le dernier niveau avant confirmation. « Refuser » ne modifie pas les sauvegardes. « Accepter » crée un profil si le nom est disponible; en cas de collision, le suffixe « (import) » est essayé. La campagne et ses scores sont importés dans le profil. Son empreinte est également enregistrée localement comme déjà partagée afin que le panneau ne propose pas de la réexporter depuis cet appareil, puis les statistiques s'ouvrent.

Un fichier invalide est refusé sans navigation ni changement de sauvegarde. Les fichiers temporaires reçus sont supprimés après traitement.

## Sécurité et limites

La clé est définie par `partage_performances/cle_hmac` dans `sources/project.godot`. Une clé embarquée dans l'application peut être extraite par un client modifié : le HMAC détecte les altérations faites sans cette clé, mais ne constitue pas une preuve d'authenticité face à un client hostile. Pour garantir l'origine des scores, la signature doit être produite par un serveur qui conserve la clé.

Le partage et la réception via SHARE sont disponibles sur Android. Le projet n'envoie pas de courriel automatiquement; l'utilisateur copie l'adresse affichée et choisit son application de messagerie pour joindre le fichier.
