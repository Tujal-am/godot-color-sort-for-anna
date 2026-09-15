# Roadmap d’Évolution – Séparation Logique et Interface Utilisateur (UI) dans Godot

## 🎯 Objectif global
Transformer progressivement le projet pour obtenir :
- des **modules logiques autonomes**, testables et réutilisables ;
- des **scènes UI propres**, faciles à confier à quelqu’un d’autre ;
- une architecture **modulaire**, **maintenable**, et **scalable**.

Cette roadmap décrit les étapes concrètes pour y parvenir.

---

# 🧭 Phase 1 — Analyse du projet (1 à 2 jours)

## Objectifs
- Comprendre l’état actuel du projet.
- Identifier où la logique métier est mélangée à l’UI.
- Prioriser les modules à refactorer.

## Actions
- Lister toutes les scènes existantes.
- Identifier les scripts contenant de la logique métier.
- Repérer les dépendances UI ↔ logique (signaux, accès direct aux nœuds, manipulation de Control dans la logique).
- Prioriser les modules critiques : BackupManager, SaveManager, Inventory, MenuPrincipal, etc.

## Livrable
Un tableau listant :
- chaque scène,
- son rôle actuel,
- son niveau de mélange UI/logique,
- sa priorité de refactorisation.

---

# 🧭 Phase 2 — Extraction des modules logiques (2 à 4 jours)

## Objectifs
Créer des scènes logiques autonomes, sans UI.

## Actions
Pour chaque scène identifiée comme mélangeant UI + logique :
- Créer une scène logique dédiée (`Node` comme racine).
- Déplacer la logique métier dans cette scène :
  - états internes,
  - calculs,
  - règles métier,
  - signaux,
  - interactions avec les données.
- Définir les signaux publics (ex. `data_changed`, `item_added`, `backup_completed`).

## Livrable
Un dossier `modules/` contenant les scènes logiques propres.

---

# 🧭 Phase 3 — Création des scènes UI (2 à 4 jours)

## Objectifs
Créer des scènes UI propres, sans logique métier.

## Actions
Pour chaque module logique :
- Créer la scène UI correspondante (`Control` comme racine).
- Déplacer toute la logique visuelle dans cette scène :
  - mise à jour de l’affichage,
  - interactions utilisateur,
  - boutons, labels, containers.
- Connecter l’UI à la logique :
  - via signaux,
  - via références exportées,
  - via autoload si nécessaire.
- Supprimer toute logique métier des scripts UI.

## Livrable
Un dossier `ui/` propre et autonome.

---

# 🧭 Phase 4 — Réorganisation du projet (1 jour)

## Objectifs
Mettre en place une structure claire et idiomatique.

## Actions
- Créer l’arborescence finale :
```
modules/
    inventory/
    backup/
    save/
    logger/

ui/
    menu/
    inventory/
    settings/
```
- Mettre à jour les chemins d’accès.
- Réduire les dépendances croisées.

## Livrable
Projet structuré, lisible, modulaire.

---

# 🧭 Phase 5 — Tests et stabilisation (2 à 3 jours)

## Objectifs
Garantir la fiabilité des modules logiques et de l’UI.

## Actions
- Créer des tests GUT pour les modules logiques.
- Tester les signaux.
- Tester les interactions UI.
- Corriger les régressions.

## Livrable
Modules logiques testés, UI stable.

---

# 🧭 Phase 6 — Documentation (1 jour)

## Objectifs
Documenter l’architecture pour faciliter la maintenance et la collaboration.

## Actions
- Documenter chaque module logique.
- Documenter chaque scène UI.
- Documenter les signaux.
- Documenter les conventions de nommage.

## Livrable
Documentation interne claire et complète.

---

# 🏁 Résultat final

À la fin de cette roadmap, le projet sera :
- propre,
- modulaire,
- testable,
- maintenable,
- prêt pour une collaboration UI/logique sans friction.

Cette évolution peut être réalisée **progressivement**, scène par scène, sans casser le fonctionnement actuel.
