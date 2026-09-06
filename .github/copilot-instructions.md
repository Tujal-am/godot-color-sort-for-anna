# Copilot – Instructions globales pour mon projet Godot

Ce fichier contient toutes les consignes destinées à GitHub Copilot pour garantir un code propre, cohérent, et conforme à l’architecture API/Logic utilisée dans ce projet.

---

## 0. Fichier d’instructions pour GitHub Copilot

Infos Godot:
- Version : v4.7.2
- Executable Godot : C:\Program Files\Godot\Godot_v4.7.2-stable_win64.exe
- Executable Console Godot : C:\Program Files\Godot\Godot_v4.7.2-stable_win64_console.exe

Infos Git:
- Chemin du depot : C:\Users\legui\Documents\Sources\godot\godot-csfa_next
- Branche de travail actuelle : multi_gameplay

Infos de conceptions :
- C:\Users\legui\Documents\Sources\godot\godot-csfa_next\gestion_projet\docs\Architecture
- Testing : GUT
- Rules: keep logic in scripts, avoid UI in logic, prefer reproducible tests

---

## 1. Règles générales pour GitHub Copilot

- Respecter le pattern **API/Logic**.
- Ne jamais mélanger **UI** et **logique métier**.
- Ne pas inventer de nodes ou de chemins de nodes.
- Ne pas créer de singletons non nécessaires.
- Utiliser **snake_case** pour les noms de variables et méthodes.
- Préférer des méthodes **courtes**, **claires**, et à **responsabilité unique**.
- Documenter les méthodes publiques.
- Ne jamais utiliser `get_node()` dans la logique métier.
- Ne jamais faire de logique métier dans les scripts UI.

---

## 2. Structure API/Logic Godot

### 2.1. Fichier API (`<Module>API.gd`)

- Contient uniquement :
  - des **signaux**
  - des **méthodes publiques**
- Ne contient **aucune logique métier**.
- Délègue tout à `<Module>Logic.gd`.
- Sert d’interface entre UI et Logic.

### 2.2. Fichier Logic (`<Module>Logic.gd`)

- Contient la **logique métier interne**.
- Ne contient :
  - aucun signal
  - aucun accès à l’UI
  - aucun `get_node()`
- Doit être **testable**, **isolé**, **propre**.

### 2.3. Fichier UI (`<Module>UI.gd`)

- Interagit uniquement avec `<Module>API.gd`.
- Ne contient **aucune logique métier**.
- Peut émettre des signaux vers l’API.

---

## 3. Modèle de module complet

```text
<Module>/
    <Module>API.gd
    <Module>Logic.gd
    <Module>UI.tscn
    <Module>UI.gd
```

---

## 4. Instructions pour les scènes Godot (fichier *.tscn)

```text
# CONTEXTE POUR COPILOT
# Cette scène contient :
# - Un Button nommé "PlayButton"
# - Un Label nommé "StatusLabel"
# - Un Timer nommé "AutoStartTimer"
# Chemins de nodes :
# - $PlayButton
# - $Panel/StatusLabel
# - $AutoStartTimer
```

---

## 5. Consignes pour refactoriser un fichier

```text
# INSTRUCTIONS POUR COPILOT
# - Identifier les responsabilités multiples.
# - Extraire la logique métier dans <Nom>Logic.gd.
# - Garder uniquement les méthodes publiques dans ce fichier.
# - Ajouter des signaux si l’UI doit réagir.
# - Ne pas modifier les signatures publiques existantes.
```

---

## 6. Consignes pour les tests

```text
# INSTRUCTIONS POUR COPILOT
# - Couverture exhaustive
# - Couvrir toutes les méthodes
# - Couvrir plusieurs chemins dans les méthodes
# - Réaliser plusieurs niveaux de couvertures de code pour chaque methodes.
```

---

## 7. Vocabulaire et comportement du jeu

### Plateau, pile et jeton

- Un jeton est un cube de couleur qui contient une lettre pour etre reconnu par le joueur.
- Un jeton se déplace dans une pile vide ou dans une pile qui a un espace vide en haut pour l'accueillir et s'il est posé sur un jeton de même couleurs.
- Une pile est un ensemble de jetons empilés les uns sur les autres. Le but du jeu est de former des piles avec des jetons de la même couleur.
- Un plateau est un ensemble de piles de jetons. Le but du jeu est de former des piles avec des jetons de la même couleur.
- Un plateau peut se jouer avec des objectifs et des regles différentes. C'est ce que je désigne par "gameplay".

### Niveau, campagne, jeu libre et fichier de sauvegarde

- Un Niveau est un ensemble de plateaux. Un niveau est terminé lorsque tous les plateaux qui le composent sont résolus.
- Un Niveau est un ensemble de plateaux dont les gameplay peuvent être différents.
- Une campagne est un ensemble de niveaux. Une campagne est terminée lorsque tous les niveaux qui la composent sont résolus.
- Le fichier de campagne "campagne.json" contient la liste des niveaux et des plateaux qui composent la campagne. Il est utilisé pour charger les niveaux et les plateaux dans le jeu.
- Chaque joueur copie le fichier de campagne "campagne.json" dans son propre fichier de sauvegarde. Il est utilisé pour suivre la progression du joueur dans la campagne.
- Quand un plateau de campagne est résolu, il est enregistré dans le fichier de sauvegarde du joueur au niveau de "enregistrement_campagne". Il est utilisé pour suivre la progression du joueur dans la campagne.
- Quand un plateau de campagne est résolu, il est effacé de la liste des plateaux de son niveau.
- Quand un plateau de campagne est résolu, il est ajouté dans la liste des plateaux de jeu libre avec la clé "plateaux_libres" dans le fichier de sauvegarde du joueur. Il est utilisé pour permettre au joueur de rejouer les plateaux qu'il a déjà résolus avec les gameplay de son choix.
- Dans "plateaux_libres", les plateaux sont indexés par leur difficulté. Chaque plateau est représenté par un dictionnaire contenant son nom et ses caractéritiques spécifiques sauf la difficulté qui est une clé.
- Le jeux libre n'enregistre aucune statistique de jeu.
- Quand un niveau n'a plus de plateau dans "campagne", il est considéré comme terminé et le joueur peut passer au niveau suivant. La clé du niveau est effacée de "campagne".
