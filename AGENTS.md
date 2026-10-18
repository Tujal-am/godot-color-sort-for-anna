# AGENTS.md — Range tes couleurs / Codex

Ces instructions s'appliquent a toute intervention dans ce depot, y compris lors d'une nouvelle session. **Ne jamais supposer que l'etat d'une session precedente est encore valable.**

## Sources de verite et priorite
1. Demande explicite la plus recente de la proprietaire du projet et decisions deja validees.
2. Protocole `AI_WORKFLOW_RANGE_TES_COULEURS.md` (a lire integralement avant toute modification).
3. Masters visuels officiels effectivement fournis pour la tache. Un master complet est une reference, le background separe sert a l'integration lorsque pertinent.
4. Etat reel de la branche cible, scenes/scripts/assets et documentations techniques `gestion_projet/`.
5. `.github/copilot-instructions.md` et les regles de codage existantes, sauf si une indication obsolete contredit l'etat actuel.

**Ne jamais substituer une capture ancienne ou un souvenir au master valide.** Si le master requis manque, stopper l'integration visuelle, sans inventer de remplacement.

## PRE-FLIGHT obligatoire — sans modification
- Lire `git remote -v`, `git branch --show-current`, `git rev-parse HEAD`, `git status --short`, `git fetch` si autorise, et `git rev-parse --abbrev-ref --symbolic-full-name @{upstream}` si applicable.
- Confirmer **depot, branche cible, SHA de depart**, remote et changements locaux. La branche `BR_V1.0.0-rc14` est la reference du chantier jetons d'octobre 2026, **pas une cible universelle** pour toute intervention ulterieure. Ne jamais deviner la branche d'une nouvelle tache.
- Si le depot ou la branche ne correspond pas a la tache, **STOP**: ne pas creer de branche alternative arbitraire, ne pas copier des fichiers ni engager de changements avant diagnostic de l'ecart.
- Auditer en lecture seule les scenes, nodes, signaux, scripts, references d'assets, interactions, hitboxes et tests concernes. Produire un perimetre ferme de fichiers autorises et une liste des controles avant d'editer.
- Distinguer information constatee, hypothese et verification impossible. Ne pas affirmer avoir teste ce qui n'a pas ete execute.

## Regle de modification
- Changement minimal et cible; aucune refonte, aucun nettoyage, migration, renommage, regeneration ou mise a jour de dependance hors demande.
- Respecter le pattern Godot API/Logic/UI documente; ne pas inventer de noeuds.
- Preserver mecanique, deplacements, soudures, signaux, navigation, sauvegardes et gameplay Classique / Qui Perd Gagne lors d'une intervention graphique.
- Assets graphiques proteges : **aucun redessin manuel, aucune reinterpretation graphique**. Pour « Recommencer », la source officielle est un PNG protege : emploi strict ou vectorisation mecanique controlee pixel par pixel seulement si explicitement approuvee. Ne jamais pretendre qu'un redessin est 100 % vectoriel conforme.
- Ne modifier un master valide que sur autorisation explicite; ne pas alterer les autres elements d'ecran.

## Plan et maitrise du quota
- Pour toute tache complexe (multi-fichiers, Git transversal, migrations, gameplay), presenter d'abord un plan court : cible Git, perimetre, risques, tests, criteres de fin. Utiliser `/plan` si disponible.
- Pour une tache simple, appliquer le pre-flight puis executer directement; ne pas multiplier les demandes de validation inutiles.
- Apres **deux tentatives infructueuses** sur le meme obstacle, stopper les retries, diagnostiquer la cause et changer d'approche. Pas de cycles exploratoires ouverts.

## Verification avant commit/push
- Revoir `git diff --name-status`, `git diff --check` et les references des assets; refuser un diff hors perimetre.
- Executer les tests disponibles pertinents (Godot headless, scenes, GUT, mouvements/soudures, tests de campagne et gameplay selon la tache). Noter clairement ce qui n'a pas pu etre execute.
- Pour une UI mobile, verifier les rendus aux resolutions cibles et comparer aux masters; une verification headless ne vaut pas validation visuelle sur appareil.
- Commit/push **uniquement si explicitement autorises** pour la tache et uniquement vers le bon remote/branche. Ne jamais annoncer un push avant verification du SHA distant.
- Rapport final concis obligatoire : depot, branche, SHA avant/apres, fichiers modifies, tests reels PASS/FAIL/NON EXECUTES, risques residuels, lien du commit/PR. Ne jamais qualifier « termine » sans verification, correction si necessaire, validation et documentation.

## Blocage
Si une precondition manque ou qu'une instruction entre en conflit avec le depot reel : **STOP, diagnostic precis, proposition de solution minimale**. Ne pas masquer le blocage par des suppositions.
