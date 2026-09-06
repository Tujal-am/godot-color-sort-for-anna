# Séparation Logique et Interface Utilisateur dans Godot

## 🎯 Objectif
Mettre en place une architecture où la **logique métier** et l’**interface utilisateur (UI)** sont clairement séparées. Cette évolution vise à rendre le projet plus modulaire, plus testable, plus maintenable, et permettre à quelqu’un d’autre de modifier l’interface sans toucher à la logique.

---

## 📌 Constat actuel
Dans le projet actuel :
- Les scènes contiennent à la fois des éléments UI et de la logique métier.
- Les scripts attachés aux scènes jouent souvent le rôle de modules métier.
- L’interface et la logique sont fortement couplées.

Cette évolution documente la direction à suivre pour améliorer la structure du projet.

---

## 🧩 Principe fondamental
Une scène Godot peut être :
- **purement logique** (aucun Control),
- **purement UI** (uniquement des Control),
- ou un mélange des deux (à éviter).

L’objectif est de tendre vers :
- des **scènes logiques autonomes**, réutilisables, testables,
- des **scènes UI** qui ne font que présenter l’information et relayer les actions utilisateur.

---

## 🧱 Scène logique – Contenu recommandé
Une scène logique contient :
- Un nœud racine `Node`.
- Des nœuds fonctionnels : `Timer`, `AnimationPlayer`, `AudioStreamPlayer`, etc.
- Un script qui gère :
  - l’état interne,
  - les règles métier,
  - les signaux,
  - les interactions avec les données.

Elle **ne contient aucun Control**.

---

## 🎨 Scène UI – Contenu recommandé
Une scène UI contient :
- Un nœud racine `Control`.
- Des éléments graphiques : `Button`, `Label`, `Panel`, `Container`, etc.
- Un script qui gère :
  - les interactions utilisateur,
  - la mise à jour visuelle,
  - la réception des signaux venant de la logique.

Elle **ne contient aucune logique métier**.

---

## 🔗 Connexion logique ↔ UI
Trois méthodes idiomatiques :

### 1. Instanciation dans une scène parent
La scène parent contient la logique et l’UI.

### 2. Autoload pour la logique
La logique devient un singleton accessible partout.

### 3. Référence exportée dans l’UI
```gdscript
@export var inventory: Inventory
```

---

## 🧠 Exemple : Inventory
### Scène logique : `Inventory.tscn`
```
Node
 ├── Timer
 ├── AudioStreamPlayer
 └── AnimationPlayer
```

### Scène UI : `InventoryUI.tscn`
```
Control
 ├── VBoxContainer
 ├── ItemList
 └── Button
```

---

## 📁 Organisation recommandée
```
modules/
    inventory/
        Inventory.tscn
        Inventory.gd
    backup/
        BackupManager.tscn
        BackupManager.gd

ui/
    menu/
        MenuPrincipalUI.tscn
    inventory/
        InventoryUI.tscn
```

---

## 🚀 Bénéfices attendus
- UI modifiable par quelqu’un d’autre.
- Logique testable via GUT.
- Architecture plus propre et maintenable.
- Réutilisation des modules logiques.
- Séparation claire des responsabilités.

---

## 📌 Évolution à planifier
- Identifier les scènes contenant de la logique métier.
- Extraire cette logique dans des scènes dédiées.
- Créer les scènes UI correspondantes.
- Connecter les deux via signaux ou références exportées.
- Réorganiser le projet en dossiers `modules/` et `ui/`.

---

## 🏁 Conclusion
Cette évolution structurelle rendra le projet plus robuste, modulaire, testable et permettra une collaboration plus fluide sur l’interface utilisateur.
