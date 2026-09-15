# Architecture Logique / UI dans Godot  
## Concepts fondamentaux et bonnes pratiques

Ce document décrit trois piliers essentiels pour structurer proprement un projet Godot :  
- les **singletons**,  
- les **scènes logiques**,  
- les **scènes UI**.  

Il explique quand les utiliser, pourquoi, et comment les articuler ensemble.

---

# 1. Singleton (Autoload)
## 📌 Définition
Un **singleton** (autoload dans Godot) est un script ou une scène chargée automatiquement au démarrage du jeu et accessible depuis n’importe quel script via son nom global.

## 🎯 Usage recommandé
Un singleton est utilisé lorsque la logique est **transverse**, c’est‑à‑dire qu’elle doit être accessible depuis plusieurs scènes ou modules.

## ✔️ Cas d’usage typiques
- Gestion des sauvegardes (`SaveManager`)
- Gestion des paramètres (`Settings`)
- Gestion du son global (`AudioManager`)
- Gestion des logs (`Logger`)
- Gestion du joueur ou de la session (`PlayerSession`)
- Gestion des données partagées (inventaire global, progression, statistiques)

## ❗ À éviter
- Mettre de l’UI dans un singleton  
- Mettre de la logique spécifique à une scène dans un singleton  
- Utiliser un singleton comme “fourre‑tout”

## 🧠 Exemple
```
# Autoload : SaveManager.gd
var save_path := "user://save.json"

func save(data):
    FileAccess.open(save_path, FileAccess.WRITE).store_var(data)

func load():
    return FileAccess.open(save_path, FileAccess.READ).get_var()
```

Accessible partout :
```
SaveManager.save(player_stats)
```

---

# 2. Scène logique
## 📌 Définition
Une **scène logique** est une scène Godot qui contient uniquement de la **logique métier**, sans aucun élément d’interface (`Control`).  
Elle représente un **module autonome**, circonscrit à un contexte unique.

## 🎯 Usage recommandé
Utilisée lorsque la logique est **locale** à un système ou un module, et ne doit pas être globale.

## ✔️ Cas d’usage typiques
- Inventaire d’un niveau  
- Gestion d’un puzzle  
- Gestion d’un timer ou d’un cycle interne  
- Gestion d’un mini‑jeu  
- Gestion d’un système de scoring  
- Gestion d’un plateau (dans ton projet Godot)

## 🧱 Contenu typique
```
Node
 ├── Timer
 ├── AudioStreamPlayer
 └── AnimationPlayer
```

## 🧠 Exemple
```
# Inventory.gd (scène logique)
extends Node

signal item_added(item)
signal item_removed(item)

var items := []

func add_item(item):
    items.append(item)
    emit_signal("item_added", item)

func remove_item(item):
    items.erase(item)
    emit_signal("item_removed", item)
```

## ❗ À éviter
- Accéder directement à des nœuds UI  
- Modifier des labels, boutons, textures  
- Mélanger logique métier et rendu visuel

---

# 3. Scène UI
## 📌 Définition
Une **scène UI** est une scène Godot qui contient uniquement des éléments d’interface (`Control`) et un script qui gère **l’affichage**, **les interactions utilisateur**, et **l’API de remplissage de l’UI**.

Elle ne doit **jamais** contenir de logique métier.

## 🎯 Usage recommandé
Utilisée pour :
- afficher des données,
- recevoir des actions utilisateur,
- relayer ces actions vers la logique.

## ✔️ Cas d’usage typiques
- Menu principal  
- Inventaire visuel  
- HUD  
- Fenêtre de paramètres  
- Panneau de statistiques  
- Interface de puzzle (boutons, sliders, etc.)

## 🧱 Contenu typique
```
Control
 ├── VBoxContainer
 ├── Label
 ├── Button
 └── TextureRect
```

## 🧠 Exemple
```
# InventoryUI.gd (scène UI)
extends Control

@export var inventory: Inventory

func _ready():
    inventory.item_added.connect(_on_item_added)
    inventory.item_removed.connect(_on_item_removed)

func _on_item_added(item):
    $ItemList.add_item(item.name)

func _on_item_removed(item):
    $ItemList.remove_item(item.name)
```

## ❗ À éviter
- Stocker des données métier dans l’UI  
- Faire des calculs métier dans l’UI  
- Gérer des états internes complexes dans l’UI  

---

# 4. Comment articuler les trois ensemble

## 🔗 Flux idéal
1. **Singleton** : gère les données globales ou transverses  
2. **Scène logique** : gère les règles métier locales  
3. **Scène UI** : affiche les données et relaye les actions utilisateur  

## 🔄 Exemple complet
```
UI → demande une action → Scène logique → modifie l’état → émet un signal → UI → met à jour l’affichage
```

---

# 5. Bonnes pratiques générales

## ✔️ 1. Toujours séparer logique et UI
La logique doit pouvoir être testée sans charger l’interface.

## ✔️ 2. Utiliser les signaux pour communiquer
Les signaux permettent un couplage faible.

## ✔️ 3. Utiliser des références exportées pour connecter UI ↔ logique
```
@export var inventory: Inventory
```

## ✔️ 4. Utiliser des singletons uniquement pour la logique transverse
Pas pour tout.

## ✔️ 5. Organiser le projet en dossiers
```
modules/
ui/
autoload/
```

## ✔️ 6. Documenter l’API de chaque module logique
Pour faciliter la collaboration.

---

# 🏁 Conclusion
Cette architecture permet :
- une meilleure modularité,
- une UI facilement modifiable,
- des tests unitaires propres,
- une logique métier réutilisable,
- une maintenance simplifiée.

Elle constitue une base solide pour faire évoluer ton projet Godot proprement et durablement.
