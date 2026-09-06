# Tests Unitaires dans Godot avec GUT  
## Conventions • Patterns • Organisation • Exemples

Ce document décrit les conventions de tests unitaires pour les **modules logiques** d’un projet Godot utilisant **GUT** (Godot Unit Test).  
Il s’applique uniquement à la **logique métier**, jamais à l’UI.

---

# 1. Principes fondamentaux

## ✔️ 1. Tester uniquement la logique métier
Les tests doivent cibler :
- les modules logiques (`Inventory`, `PlateauLogic`, `PuzzleLogic`, etc.),
- les fonctions métier,
- les signaux,
- les états internes.

## ✔️ 2. Ne jamais tester l’UI
L’UI dépend du moteur, du rendu, des containers, des signaux visuels → non testable en unit test.

## ✔️ 3. Chaque module logique doit être testable sans scène UI
Les modules logiques doivent :
- ne pas dépendre de `Control`,
- ne pas accéder à des nœuds visuels,
- ne pas manipuler de textures.

## ✔️ 4. Les tests doivent être isolés
Chaque test doit :
- instancier sa propre scène logique,
- ne pas dépendre d’un état global,
- ne pas dépendre d’un singleton (sauf mocks).

---

# 2. Organisation des tests

## 📁 Arborescence recommandée
```
project/
│
├── modules/
│   ├── inventory/
│   │   ├── Inventory.tscn
│   │   └── Inventory.gd
│   └── plateau/
│       ├── PlateauLogic.tscn
│       └── PlateauLogic.gd
│
└── tests/
    ├── inventory/
    │   └── test_inventory.gd
    ├── plateau/
    │   └── test_plateau_logic.gd
    └── helpers/
        └── mocks.gd
```

## ✔️ Règles
- Un fichier de test par module logique.
- Les tests ne doivent jamais être dans les dossiers `modules/` ou `ui/`.
- Les mocks doivent être regroupés dans `tests/helpers/`.

---

# 3. Structure d’un fichier de test GUT

## 📌 Convention
```
extends "res://addons/gut/test.gd"

var inventory

func before_each():
    inventory = load("res://modules/inventory/Inventory.tscn").instantiate()

func after_each():
    inventory = null
```

## ✔️ Règles
- Toujours utiliser `before_each()` pour instancier la scène logique.
- Ne jamais réutiliser une instance entre les tests.
- Utiliser `assert_*` pour vérifier les comportements.

---

# 4. Tester les fonctions métier

## 🧠 Exemple : Inventory

### Logique
```gdscript
func add_item(item):
    items.append(item)
    emit_signal("item_added", item)
```

### Test
```gdscript
func test_add_item():
    inventory.add_item("sword")
    assert_eq(inventory.items.size(), 1)
    assert_eq(inventory.items[0], "sword")
```

---

# 5. Tester les signaux

## 📌 Concept
Les signaux sont essentiels dans une architecture propre.  
Ils doivent être testés pour garantir que l’UI recevra les bons événements.

## 🧠 Exemple
```gdscript
func test_signal_item_added():
    var emitted_item = null

    inventory.item_added.connect(func(item):
        emitted_item = item
    )

    inventory.add_item("shield")

    assert_eq(emitted_item, "shield")
```

---

# 6. Tester les états internes

## 📌 Concept
Les modules logiques gèrent des états internes (plateau, inventaire, puzzle, etc.).  
Les tests doivent vérifier que ces états évoluent correctement.

## 🧠 Exemple : PlateauLogic
```gdscript
func test_update_state():
    var new_state = [1, 2, 3]
    inventory.update_state(new_state)
    assert_eq(inventory.state, new_state)
```

---

# 7. Tester les erreurs et cas limites

## ✔️ Cas à tester
- valeurs nulles,
- valeurs hors limites,
- états invalides,
- double ajout,
- suppression d’un élément absent,
- signaux non émis.

## 🧠 Exemple
```gdscript
func test_remove_item_not_present():
    inventory.add_item("apple")
    inventory.remove_item("banana")
    assert_eq(inventory.items.size(), 1)
```

---

# 8. Mocks et doubles de test

## 📌 Concept
Les modules logiques peuvent dépendre :
- d’un singleton,
- d’un autre module logique,
- d’un fichier JSON.

Ces dépendances doivent être **mockées**.

## 🧠 Exemple de mock
```
# tests/helpers/mocks.gd
extends Node

func fake_save(data):
    return true
```

### Utilisation
```gdscript
func test_save_called():
    SaveManager.save = mocks.fake_save
    assert_true(SaveManager.save({}))
```

---

# 9. Tests de performance (optionnel)

## ✔️ À tester
- boucles lourdes,
- calculs complexes,
- génération de plateau,
- validation de puzzle.

## 🧠 Exemple
```gdscript
func test_performance_generate():
    var start = Time.get_ticks_msec()
    inventory.generate()
    var duration = Time.get_ticks_msec() - start
    assert_lt(duration, 50)
```

---

# 10. Règles d’or

## ✔️ Tester la logique, jamais l’UI  
## ✔️ Tester les signaux  
## ✔️ Tester les états internes  
## ✔️ Tester les cas limites  
## ✔️ Utiliser des mocks pour les dépendances  
## ✔️ Garder les tests isolés  
## ✔️ Garder une arborescence claire  
## ✔️ Un test = un comportement métier  

---

# 🏁 Conclusion

Les tests unitaires GUT permettent :
- de sécuriser les modules logiques,
- d’éviter les