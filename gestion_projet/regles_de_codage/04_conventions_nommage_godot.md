# Conventions de Nommage – Projet Godot  
## Singletons • Modules Logiques • UI • Scripts • Dossiers

Ce document définit les conventions de nommage pour garantir une architecture Godot cohérente, lisible et maintenable.

---

# 1. Règles générales

## ✔️ Style
- Utiliser **PascalCase** pour les scènes et scripts (`InventoryUI.tscn`, `SaveManager.gd`).
- Utiliser **snake_case** pour les variables (`current_score`, `item_list`).
- Utiliser **SCREAMING_SNAKE_CASE** pour les constantes (`MAX_ITEMS`).
- Utiliser **snake_case** pour les fonctions (`add_item()`, `update_ui()`).
- Utiliser **snake_case** pour les signaux (`add_item`  ).

## ✔️ Préfixes et suffixes
- Les scènes UI doivent être suffixées par **UI**.
- Les scènes logiques doivent être nommées selon leur rôle métier.
- Les singletons doivent être nommés selon leur responsabilité globale.

---

# 2. Singletons (Autoload)

## 📌 Convention
```
Nom : <Responsabilité>Manager.gd
Exemples :
- SaveManager.gd
- SettingsManager.gd
- AudioManager.gd
- Logger.gd
```

## 🎯 Raison
- Le suffixe **Manager** indique une responsabilité transverse.
- Le nom exprime clairement le domaine métier.

## ✔️ Règles
- Un singleton est toujours un **script** (pas une scène).
- Le nom doit être **unique** dans le projet.
- Le nom doit exprimer **une seule responsabilité**.

---

# 3. Scènes Logiques (Modules)

## 📌 Convention
```
Nom : <ConceptMetier>.tscn
Script : <ConceptMetier>.gd
Exemples :
- Inventory.tscn
- BackupManager.tscn
- PlateauLogic.tscn
- PuzzleLogic.tscn
```

## 🎯 Raison
- Le nom doit exprimer le **concept métier**.
- Le suffixe **Logic** est utilisé quand le module représente un système interne.

## ✔️ Règles
- Pas de suffixe UI.
- Pas de termes visuels (Panel, Button, etc.).
- Le script porte le même nom que la scène.

---

# 4. Scènes UI

## 📌 Convention
```
Nom : <ConceptMetier>UI.tscn
Script : <ConceptMetier>UI.gd
Exemples :
- InventoryUI.tscn
- MenuPrincipalUI.tscn
- SettingsUI.tscn
- PuzzleUI.tscn
```

## 🎯 Raison
- Le suffixe **UI** identifie immédiatement une scène d’interface.
- Le nom exprime le **module logique auquel l’UI est liée**.

## ✔️ Règles
- Contient uniquement des nœuds `Control`.
- Le script expose une **API de remplissage** :
  - `update_items(items)`
  - `set_score(value)`
  - `show_error(message)`
- Aucun calcul métier dans l’UI.

---

# 5. Scripts Utilitaires

## 📌 Convention
```
Nom : <Fonction>Utils.gd
Exemples :
- MathUtils.gd
- FileUtils.gd
- StringUtils.gd
```

## 🎯 Raison
- Le suffixe **Utils** indique un ensemble de fonctions génériques.

## ✔️ Règles
- Pas de dépendance à une scène.
- Pas de logique métier.
- Pas d’accès à l’UI.

---

# 6. Dossiers

## 📌 Convention
```
autoload/
modules/
ui/
scenes/
assets/
data/
scripts/
```

## 🎯 Raison
- Séparation claire des responsabilités.
- Structure stable et prévisible.

## ✔️ Règles
- Chaque module logique a son propre dossier :
  ```
  modules/inventory/
  modules/backup/
  modules/puzzle/
  ```
- Chaque UI a son propre dossier :
  ```
  ui/inventory/
  ui/menu/
  ui/settings/
  ```

---

# 7. Signaux

## 📌 Convention
```
signal <action>_<objet>
Exemples :
signal item_added(item)
signal backup_completed()
signal score_updated(value)
```

## ✔️ Règles
- Toujours en snake_case.
- Toujours orienté “événement”.

---

# 8. Variables

## 📌 Convention
```
var <nom_en_snake_case>
Exemples :
var current_score := 0
var item_list := []
var is_paused := false
```

## ✔️ Règles
- Noms explicites.
- Pas d’abréviations obscures.

---

# 9. Fonctions

## 📌 Convention
```
func <action><Objet>()
Exemples :
func add_item(item)
func remove_item(item)
func update_ui()
func load_save()
```

## ✔️ Règles
- Toujours en camelCase.
- Le nom doit exprimer une action.

---

# 🏁 Conclusion

Ces conventions garantissent :
- une architecture claire,
- une séparation stricte logique/UI,
- une meilleure lisibilité,
- une collaboration facilitée,
- une maintenance simplifiée.

Elles constituent une base solide pour structurer un projet Godot professionnel et évolutif.
