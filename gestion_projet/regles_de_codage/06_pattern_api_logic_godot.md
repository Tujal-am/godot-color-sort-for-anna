# Pattern API / Logic dans Godot  
## Séparer contrat, implémentation et interface utilisateur

Ce document présente un pattern architectural permettant de structurer proprement la logique dans Godot en séparant :

- **l’API logique** (contrat : signaux + méthodes publiques),
- **l’implémentation logique** (traitements métier),
- **l’UI** (interface utilisateur, découplée de la logique).

Ce pattern améliore la modularité, la testabilité et la robustesse du projet.

---

# 1. Objectifs du pattern

- Découpler totalement l’UI de la logique métier  
- Stabiliser l’API exposée à l’UI  
- Permettre plusieurs implémentations d’un même module logique  
- Faciliter les tests unitaires  
- Documenter naturellement les signaux et méthodes publiques  
- Rendre la logique interchangeable sans modifier l’UI  

---

# 2. Structure du module

```
modules/
    inventory/
        InventoryAPI.gd
        InventoryLogic.gd

ui/
    inventory/
        InventoryUI.gd
```

---

# 3. API logique (contrat)

## Fichier : `InventoryAPI.gd`

```gdscript
extends Node
class_name InventoryAPI

signal item_added(item)
signal item_removed(item)

func add_item(item):
    push_error("InventoryAPI.add_item() not implemented")

func remove_item(item):
    push_error("InventoryAPI.remove_item() not implemented")

func get_items():
    push_error("InventoryAPI.get_items() not implemented")
    return []
```

### Rôle
- Déclare les **signaux** que l’implémentation doit émettre  
- Déclare les **méthodes publiques** que l’UI peut appeler  
- Ne contient **aucune logique métier**  
- Sert de **contrat officiel** entre UI ↔ logique  

---

# 4. Implémentation logique (traitements)

## Fichier : `InventoryLogic.gd`

```gdscript
extends InventoryAPI
class_name InventoryLogic

var items: Array = []

func add_item(item):
    items.append(item)
    emit_signal("item_added", item)

func remove_item(item):
    items.erase(item)
    emit_signal("item_removed", item)

func get_items():
    return items.duplicate()
```

### Rôle
- Implémente les méthodes publiques définies dans l’API  
- Gère l’état interne du module  
- Émet les signaux définis dans l’API  
- Ne dépend jamais de l’UI  

---

# 5. UI (interface utilisateur)

## Fichier : `InventoryUI.gd`

```gdscript
extends Control
class_name InventoryUI

@export var inventory: InventoryAPI

func _ready():
    inventory.item_added.connect(_on_item_added)
    inventory.item_removed.connect(_on_item_removed)
    _refresh_list()

func _on_item_added(item):
    $ItemList.add_item(str(item))

func _on_item_removed(item):
    _refresh_list()

func _refresh_list():
    $ItemList.clear()
    for item in inventory.get_items():
        $ItemList.add_item(str(item))

func _on_add_button_pressed():
    inventory.add_item("épée")

func _on_remove_button_pressed():
    inventory.remove_item("épée")
```

### Rôle
- Appelle les méthodes publiques de l’API  
- Écoute les signaux de l’API  
- Met à jour l’affichage  
- Ne contient aucune logique métier  

---

# 6. Instanciation dans une scène

```
Game.tscn
 ├── InventoryLogic (Node)
 └── InventoryUI (Control)
```

Dans l’inspecteur de `InventoryUI` :

```
inventory: [drag & drop InventoryLogic instance]
```

---

# 7. Avantages du pattern

## ✔️ API stable
L’UI dépend uniquement de `InventoryAPI`, jamais de l’implémentation.

## ✔️ Logique interchangeable
Plusieurs implémentations possibles :

- `InventoryLogicSimple.gd`
- `InventoryLogicOptimized.gd`
- `InventoryLogicDebug.gd`

L’UI reste identique.

## ✔️ Testabilité
Les tests unitaires ciblent uniquement l’implémentation logique.

## ✔️ Documentation naturelle
Le fichier `InventoryAPI.gd` **est** la documentation de l’API.

## ✔️ Couplage faible
L’UI ne connaît pas l’implémentation, seulement le contrat.

---

# 8. Bonnes pratiques

- Suffixer les implémentations par `Logic`
- Suffixer les interfaces par `UI`
- Mettre l’API dans le dossier du module
- Mettre l’UI dans le dossier UI
- Ne jamais faire dépendre l’implémentation de l’UI
- Ne jamais mettre de logique métier dans l’UI
- Documenter les signaux et méthodes publiques dans l’API

---

# 9. Résumé

Ce pattern “API + Logic + UI” permet :

- une architecture propre et modulaire  
- une UI découplée de la logique  
- des modules logiques testables  
- des implémentations interchangeables  
- une documentation automatique via l’API  

Il est idéal pour les projets Godot complexes ou évolutifs.
