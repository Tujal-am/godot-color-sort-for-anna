# Communication entre UI et Logique dans Godot  
## Signaux • Exports • Autoloads • Patterns de Connexion

Ce document décrit les conventions et bonnes pratiques pour assurer une communication propre, claire et maintenable entre :

- les **scènes UI** (interface utilisateur),
- les **scènes logiques** (modules métier),
- les **singletons** (logique transverse).

---

# 1. Principes fondamentaux

## ✔️ 1. La logique ne doit jamais accéder directement à l’UI
La logique doit être indépendante du rendu.  
Elle ne doit pas manipuler de `Label`, `Button`, `Panel`, etc.

## ✔️ 2. L’UI ne doit jamais contenir de logique métier
Elle doit uniquement :
- afficher des données,
- recevoir des actions utilisateur,
- relayer ces actions vers la logique.

## ✔️ 3. La communication doit être **faiblement couplée**
Utiliser :
- **signaux**,
- **références exportées**,
- **autoloads**.

Éviter :
- les accès directs via `get_node()` vers la logique,
- les dépendances circulaires.

---

# 2. Communication via Signaux (méthode recommandée)

## 📌 Concept
Les signaux permettent à la logique d’annoncer des événements à l’UI sans connaître son existence.

## ✔️ Exemple logique → UI
### Logique (Inventory.gd)
```gdscript
signal item_added(item)
signal item_removed(item)

func add_item(item):
    items.append(item)
    emit_signal("item_added", item)
```

### UI (InventoryUI.gd)
```gdscript
func _ready():
    inventory.item_added.connect(_on_item_added)

func _on_item_added(item):
    $ItemList.add_item(item.name)
```

## 🎯 Avantages
- Couplage faible
- Testabilité accrue
- Architecture propre

---

# 3. Communication via Références Exportées

## 📌 Concept
L’UI reçoit une référence vers la logique via une variable exportée.

## ✔️ Exemple
### UI (InventoryUI.gd)
```gdscript
@export var inventory: Inventory

func _ready():
    inventory.item_added.connect(_on_item_added)
```

## 🎯 Avantages
- Simple à connecter dans l’éditeur
- Lisible
- Pas besoin d’autoload

## ❗ À éviter
- Exporter des singletons (inutile)
- Exporter des scènes UI dans la logique (inversion des responsabilités)

---

# 4. Communication via Autoloads (Singletons)

## 📌 Concept
Un singleton est accessible partout via son nom global.

## ✔️ Exemple
### Singleton (SaveManager.gd)
```gdscript
func save(data):
    FileAccess.open("user://save.json", FileAccess.WRITE).store_var(data)
```

### UI
```gdscript
SaveManager.save(current_state)
```

## 🎯 Avantages
- Idéal pour la logique transverse
- Accessible depuis UI et logique

## ❗ À éviter
- Utiliser un autoload pour remplacer une scène logique locale
- Mettre de l’UI dans un autoload

---

# 5. Patterns de communication recommandés

## ✔️ Pattern 1 — UI → Logique (action utilisateur)
```
UI détecte une action → appelle une fonction de la logique
```

### Exemple
```gdscript
func _on_add_button_pressed():
    inventory.add_item(selected_item)
```

---

## ✔️ Pattern 2 — Logique → UI (mise à jour visuelle)
```
Logique modifie l’état → émet un signal → UI met à jour l’affichage
```

### Exemple
```gdscript
func _on_item_added(item):
    $ItemList.add_item(item.name)
```

---

## ✔️ Pattern 3 — Logique ↔ Singleton (données globales)
```
Logique locale → utilise un singleton pour sauvegarder, charger, configurer
```

### Exemple
```gdscript
SaveManager.save(inventory.items)
```

---

## ✔️ Pattern 4 — UI ↔ Singleton (paramètres globaux)
```
UI modifie un paramètre → singleton met à jour → UI se met à jour via signal
```

### Exemple
```gdscript
SettingsManager.set_volume(value)
```

---

# 6. Patterns à éviter

## ❌ 1. Logique qui manipule directement l’UI
```
$Label.text = "..."
```
→ interdit dans un module logique

## ❌ 2. UI qui modifie directement les données métier
```
items.append