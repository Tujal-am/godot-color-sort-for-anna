# Arborescence Idéale d’un Projet Godot  
## Architecture Modulaire : Singletons, Scènes Logiques, Scènes UI

Ce document décrit une arborescence recommandée pour structurer un projet Godot de manière claire, modulaire et maintenable.  
Il s’appuie sur trois concepts fondamentaux :

- **Singletons** : logique transverse, accessible partout  
- **Scènes logiques** : logique métier locale, sans UI  
- **Scènes UI** : interface utilisateur, sans logique métier  

---

# 1. Vue d’ensemble de l’arborescence

```
project/
│
├── autoload/              # Singletons (logique transverse)
│   ├── SaveManager.gd
│   ├── Settings.gd
│   ├── Logger.gd
│   └── AudioManager.gd
│
├── modules/               # Scènes logiques (logique métier locale)
│   ├── inventory/
│   │   ├── Inventory.tscn
│   │   └── Inventory.gd
│   ├── backup/
│   │   ├── BackupManager.tscn
│   │   └── BackupManager.gd
│   ├── puzzle/
│   │   ├── PuzzleLogic.tscn
│   │   └── PuzzleLogic.gd
│   └── plateau/
│       ├── PlateauLogic.tscn
│       └── PlateauLogic.gd
│
├── ui/                    # Scènes UI (rendu + interactions)
│   ├── menu/
│   │   ├── MenuPrincipalUI.tscn
│   │   └── MenuPrincipalUI.gd
│   ├── inventory/
│   │   ├── InventoryUI.tscn
│   │   └── InventoryUI.gd
│   ├── settings/
│   │   ├── SettingsUI.tscn
│   │   └── SettingsUI.gd
│   └── puzzle/
│       ├── PuzzleUI.tscn
│       └── PuzzleUI.gd
│
├── scenes/                # Scènes de composition (assemblage logique + UI)
│   ├── Game.tscn
│   ├── Level1.tscn
│   └── Main.tscn
│
├── assets/                # Ressources (images, sons, polices, etc.)
│   ├── textures/
│   ├── audio/
│   └── fonts/
│
├── data/                  # Données (JSON, configs, sauvegardes)
│   ├── config.json
│   └── default_settings.json
│
└── scripts/               # Scripts utilitaires non liés à une scène
    ├── helpers.gd
    └── math_utils.gd
```

---

# 2. Détails et explications

## 2.1. Dossier `autoload/` — Singletons
Les singletons contiennent la **logique transverse**, utilisée par plusieurs scènes ou modules.

### ✔️ Ce qu’on y met
- gestion des sauvegardes  
- gestion des paramètres  
- gestion du son global  
- gestion des logs  
- gestion de la session joueur  

### ❗ Ce qu’on n’y met pas
- UI  
- logique spécifique à une scène  
- états temporaires liés à un niveau  

---

## 2.2. Dossier `modules/` — Scènes logiques
Chaque module logique est une **scène autonome**, sans UI, qui gère un système métier.

### ✔️ Ce qu’on y met
- règles métier  
- états internes  
- signaux  
- timers, animations, sons internes  
- gestion des données  

### ❗ Ce qu’on n’y met pas
- boutons, labels, containers  
- textures, polices  
- interactions utilisateur  

### 🧠 Exemple
```
modules/inventory/
    Inventory.tscn
    Inventory.gd
```

---

## 2.3. Dossier `ui/` — Scènes UI
Chaque scène UI gère **l’affichage** et **les interactions utilisateur**.

### ✔️ Ce qu’on y met
- boutons, labels, panels  
- containers (VBox, HBox, Grid)  
- scripts d’affichage  
- API de remplissage de l’UI  
- signaux envoyés vers la logique  

### ❗ Ce qu’on n’y met pas
- logique métier  
- calculs internes  
- gestion d’état métier  

### 🧠 Exemple
```
ui/inventory/
    InventoryUI.tscn
    InventoryUI.gd
```

---

## 2.4. Dossier `scenes/` — Scènes de composition
Ces scènes assemblent **modules logiques + UI**.

### ✔️ Ce qu’on y met
- la scène principale (`Main.tscn`)  
- les niveaux (`Level1.tscn`)  
- les scènes qui instancient logique + UI  

### 🧠 Exemple
```
Game.tscn
 ├── Inventory (logique)
 └── InventoryUI (interface)
```

---

## 2.5. Dossier `assets/` — Ressources
Contient tout ce qui est visuel ou sonore.

### ✔️ Ce qu’on y met
- textures  
- sons  
- polices  
- icônes  

---

## 2.6. Dossier `data/` — Données
Contient les fichiers JSON, configs, presets, etc.

---

## 2.7. Dossier `scripts/` — Utilitaires
Scripts génériques, non liés à une scène.

---

# 3. Bonnes pratiques générales

## ✔️ 1. Toujours séparer logique et UI
La logique doit pouvoir être testée sans charger l’interface.

## ✔️ 2. Utiliser les signaux pour communiquer
Couplage faible, architecture propre.

## ✔️ 3. Utiliser des références exportées pour connecter UI ↔ logique
```
@export var inventory: Inventory
```

## ✔️ 4. Utiliser des singletons uniquement pour la logique transverse
Pas pour tout.

## ✔️ 5. Documenter l’API de chaque module logique
Pour faciliter la collaboration.

## ✔️ 6. Garder une arborescence stable
Les chemins doivent rester prévisibles.

---

# 🏁 Conclusion
Cette arborescence fournit une base solide pour un projet Godot modulaire, testable et maintenable.  
Elle facilite la collaboration entre développeurs et permet d’évoluer vers une architecture propre où la logique métier et l’UI sont clairement séparées.
