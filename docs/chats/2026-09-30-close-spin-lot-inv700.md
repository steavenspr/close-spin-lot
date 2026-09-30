# Close SPIN-LOT (SC-INV700) — conversation export

| | |
|---|---|
| **Date export** | 2026-09-30 |
| **Conversation** | 2026-09-01 → 2026-09-30 (Cursor chat *Close SPIN LOT*) |
| **Transcript** | `bc9c0197-b945-41fe-82df-77edcb83130c` |
| **Repo** | https://github.com/steavenspr/close-spin-lot |
| **APEX** | App **1400** (FSM Planning) — Page **51** Close SPIN-LOT (+ Page **90** Spin Lot Main stamp) |
| **Legacy** | Speedware **SC-INV700** |

> **Note qualité :** ce fichier n’est **pas** un dump intégral du transcript (~1 Mo JSONL). C’est une synthèse structurée, avec **citations user réelles** extraites du transcript, pour qu’un autre agent / collègue reconstitue *comment* le projet a été construit.

---

## 1. Contexte / objectif

Migrer l’écran Speedware **Close SPIN-LOT** (SC-INV700) vers **Oracle APEX** :

- une page interactive (recherche → liste → détail → impact → close) ;
- logique métier alignée SC-INV700 (main spin, date `M_PARAM`, cascade WIP / blend / ship / lots liés) ;
- confirmation APEX (popup) à la place du champ Speedware `LV-OK = Y/N` ;
- procédure PL/SQL **séparée** dans le package du binôme `FSM.SCT_PRD`, sans casser `close_spin_lot` existant ;
- UI en **anglais** ; discussion FR uniquement.

Lot de test historique : **`2608-0027`** (`lot_id` **374680**), status `SC`.

---

## 2. Histoire chronologique (extraits utiles)

### 2026-09-01 — Analyse Speedware + discovery Toad

User (captures SC-INV700) :

> « voici al page Close SPIN LOT — analyse dabord la logique , on doit savoir ce que fait cette page »

Puis :

> « on ne mets plus le Y et N pour la page, est ce quil y a une procedure deja fait ou bine cest code en dur? »

> « avant de decider de fair eune procedure, on vatester en base… donne moi les requtes je vais aller sur toad et jte colle les resultatts »

**Découvertes :**

- `LV-OK` = variable locale d’écran Speedware (« OK TO CLOSE SPIN-LOT »), pas une colonne Oracle.
- Package `FSM.SCT_PRD` existe déjà : `t_spin_lot_rec`, `load_main_spin_lot`, `close_spin_lot` (Page 90).
- Tables WOOL via synonymes FSM : `PROD_LOT`, `WIP_HDR`, `D_BLENDHDR`, `ORD_SHIP`, `M_PARAM`.

User (binôme) :

> « mon binopme vient de creer le package, on ne va pas encore touche ca porurai compremettre son travail »

### 2026-09-01 — Maquettes UX (Canvas → HTML)

Itération design rapide :

1. Première maquette rejetée (« jaime pas… je veux que tu m'eblouie »).
2. Trois variantes → choix **A** + recherche (« jaime bien le A… embelli un peut »).
3. Règles UI posées par l’user :
   - > « pour le spages apex, tout est en angalais sauf nous deux aui discute »
   - > « et les bordure de cartes on sait tres bien que cets lIA »
   - animation Close demandée de retour (« LA NIMATION DE LA CARTE… JAIMAI BIEN »).
4. Oscillation dark / light : trop sombre → trop blanc → dark → light final pour APEX/mockup.
5. Master-detail : « imagine sil y en a plsueiurs? » → liste gauche + détail droite.

### 2026-09-01 — Spec package + procédure INV700

User colle le SPEC `FSM.SCT_PRD` et demande :

> « donc le code de mon binome fait laffaire? »

> « on suit la logique de sc inv700 mais pour Y et N pas besoin »

> « on peut ajouter notre propore procedure non? »

> « procedure separe je prefere »

Décision : **`close_spin_lot_inv700(p_lot_id)`** à côté de `close_spin_lot`, logique SC-INV700 complète (date `M_PARAM`, cascade).

Test Toad (user) sur `374680` :

> « OK - lot_id=374680 — PL/SQL procedure successfully completed. »

Simulation préalable avec SAVEPOINT/ROLLBACK (WIP 0, blend 1, ship 1, related 0, Date OK).

### 2026-09-01 — Architecture APEX Page 51

User :

> « commenceons a limpolementatiopn… que du html css et js en separant les sections par regions »

Régions Static Content + CSS/JS (inline ou fichiers) + Ajax. Nommage explicite (`RGN_P51_*`). Export page collé depuis Downloads (`f1400_page_51*.sql`).

Puis :

> « au lieu de canva, tu peux me refaire la maquette en html css js? »

→ dossier `mockup/` (thème light).

### 2026-09-01 / 09-03 — Debug Page Designer

Problèmes rencontrés et corrigés ensemble :

| Symptôme | Cause / fix |
|----------|-------------|
| Écran « petit au milieu » vs maquette full-bleed | CSS largeur / shell UT (`max-width` ~1400px, padding) |
| Theme trop sombre / trop blanc | CSS variables light `#f4f4f6` / white |
| Auto-load Open à l’ouverture | `inv700Search({ silent: true })` |
| Toujours 50 lots après Entrée | submit formulaire APEX → `preventDefault` sur Enter |
| Deux dialogues confirmation | confirm + success qui se chevauchent → `inv700DismissDialogs()` |
| Header SC-INV700 / pill Open | région header **supprimée** (demande user + `ETAPES.md`) |

User :

> « ma question pourquoi il y a toujours 50 lots, ou bien cets el max? »

→ cap SQL `FETCH FIRST 50 ROWS ONLY` (volontaire).

> « quand je tape et que je clique sur entree, ca maffiche toujours ca »

→ bug Enter / submit form.

### 2026-09-01 — Close réel + Page 90 stamp

> « cest bon testeons de closer un lot »

> « mets le tampon closed aussi dans cette pas [Page 90] si le workorder selectionner est close »

→ stamp **CLOSED!!** si status OK/DD (`page90_spin_main_stamp.*`).

### 2026-09-03 — Migration PROD

> « cets bon on va bouger dans prod, mais quest ce quon doit faire dabord en base et apex pour migrer »

Checklist : synonymes FSM→WOOL, compiler `close_spin_lot_inv700`, vérifier `M_PARAM` DATE, importer Page 51.

User :

> « cest fait ca a pu importer en prod »

### 2026-09-08 — GitHub + maquette locale

Repo poussé (`steavenspr/close-spin-lot`). Maquette relancée via `npx serve` dans `mockup/`.

### 2026-09-10 — Lots « étranges » / étoiles `*`

User :

> « en fait, ce quon a fait comment on peut voir que des lot son encor ene production? »

> « ou il ya les etoile la » / « da ns la base je parle »

Résultats PROD collés : beaucoup de `LOT_NO` contenant `*` (`9308N657*`, `008*-0140B`, status `11`, `DL`, `**`, etc.).

Conclusions partagées :

- `*` est un **caractère dans `LOT_NO`**, pas un flag status.
- Filtre APEX **Open** = status **pas** OK/DD → remonte SC **et** bruits (`11`, `**`, lots `*`).
- Speedware Close **n’a pas** de condition anti-`*` / anti-`**` dans la logique reprise.

User :

> « mais close spin lot dans le speedware il nya pas la condition ** la? test sur? dans la lgoique »

Réponse : **non** — gates = main spin + pas OK/DD + `M_PARAM` + confirm.

Puis clarification métier :

> « donc pour le statuis SC cets quoi jai pas comrpis, explique moi les condition pour pouvoir close et cuex qui sont deja close »

### 2026-09-11 / 09-30

> « ce projet est deja sur github? » → oui, remote `origin`.

> Export conversation Markdown demandé (ce fichier) → commit local, **pas de push** sauf demande explicite.

---

## 3. Décisions finales

| Sujet | Décision |
|-------|----------|
| Pages APEX | **1 page principale** : Page **51** Close SPIN-LOT ; Page **90** garde load + stamp CLOSED!! |
| Y/N Speedware | Remplacé par **confirm APEX** (pas de champ `LV-OK`) |
| Procédure close | **`close_spin_lot_inv700`** séparée de `close_spin_lot` (ne pas casser le binôme) |
| Main spin | `TRIM(works_order) = TRIM(lot_no)` |
| Already closed | `STATUS IN ('OK','DD')` |
| Open (filtre UI) | Status **≠ OK et ≠ DD** (souvent SC ; peut inclure bruits) |
| Date | `M_PARAM` clé `DATE`, `descr` = `YYYYMMDD`×2 |
| UI language | **English** labels ; chat FR |
| Architecture UI | HTML/CSS/JS en régions Static Content + Ajax Callbacks |
| CSS/JS | Inline Page Designer OK (fichiers `apex/page51_*` = source de vérité repo) |
| Theme final | **Light** (`#f4f4f6` / white) |
| Cap liste | **50** rows (`FETCH FIRST 50`) |
| Header titre | **Retiré** |
| Filtre `*` / Open=SC only | **Proposé**, **pas encore appliqué** (attente TL / métier) |
| Git | Remote existant ; commits auteur `steavenspr` ; push seulement sur demande |

---

## 4. Points techniques importants

### Conditions Close (métier)

```
Main spin (works_order = lot_no)
  AND status NOT IN ('OK','DD')   -- souvent SC
  AND SYSDATE in M_PARAM DATE window
  AND user confirms
→ status := OK (+ cascade WIP / D_BLENDHDR / ORD_SHIP / related PROD_LOT)
```

### Cascade `close_spin_lot_inv700` (résumé)

1. Lock `prod_lot` by `lot_id`
2. Validate main spin + not already closed
3. Read `m_param` DATE window
4. Optional `wip_hdr.mcode` like `02%`
5. Update main `prod_lot` → OK, `date_del`, `mcode`
6. Update open `wip_hdr` / `d_blendhdr` / `ord_ship` → OK
7. Update related `prod_lot` (same WO, other lot_no) → OK (+ `kgs_1=0` si yarn `1%`)

Fichier : `sct_prd_close_spin_lot_inv700.sql`

### Ajax Page 51

| Callback | Rôle |
|----------|------|
| `SEARCH_LOTS` | Main spin + filtre OPEN/ALL + search term, max 50 |
| `LOAD_LOT` | `load_main_spin_lot` + COUNTs impact |
| `CLOSE_LOT` | `close_spin_lot_inv700` |

Fichier : `apex/page51_ajax.sql`

### Pièges perf / UX

- **Enter** sans `preventDefault` → submit page APEX → toujours les 50 Open.
- **Value Protected = Yes** sur `P51_FILTER` → filtre figé côté serveur.
- Dialogues APEX qui **s’empilent** (confirm + success).
- Liste Open **≠** « lots SC purs » → bruit data (`*`, status `**`/`11`).
- Close = **COMMIT** définitif — tester avec SAVEPOINT/ROLLBACK en Toad d’abord (`toad_inv700_close_test.sql`).

### Fichiers clés

| Chemin | Rôle |
|--------|------|
| `apex/page51.js` | UI state, search/load/close, Enter fix, dialogs |
| `apex/page51_inline.css` | Theme light |
| `apex/page51_regions.html` | HTML régions |
| `apex/page51_ajax.sql` | Callbacks |
| `apex/PAGE51_ARCHITECTURE.md` | Architecture |
| `apex/f1400_page_51.sql` | Export référence |
| `sct_prd_close_spin_lot_inv700.sql` | Patch package |
| `toad_inv700_close_test.sql` | Parcours Toad |
| `mockup/` | Maquette HTML |
| `MANUEL-UTILISATION.md` / `ETAPES.md` / `README.md` | Docs |

---

## 5. Cheat sheet — utile pour un IA / un dev

### Conventions

- UI English ; conversation FR.
- Ne pas toucher `close_spin_lot` du binôme ; étendre via `close_spin_lot_inv700`.
- Toujours coller **codes complets** dans le chat quand l’user demande (« donne toujours les codes dans cette conversation »).
- Toad : scripts sans credentials dans le repo ; user exécute et colle les résultats.

### Erreurs fréquentes

| Message / symptôme | Piste |
|--------------------|-------|
| `Only the main spin lot can be closed` | `works_order ≠ lot_no` |
| `This spin lot is already closed` | status OK/DD |
| `INVALID DATE` | `M_PARAM` DATE manquant ou hors fenêtre |
| `Select a main spin lot first` | `lot_id` null |
| JSON / `sqlerrm` au clic lot | bug `LOAD_LOT` / grants WOOL |
| Close → procédure introuvable | package non compilé / mauvais schéma |
| Liste = toujours 50 Open | Enter submit / filtre non mis à jour |

### Mesures / ordres de grandeur (PROD, session 2026-09-10)

- ~1491 lots avec `*` dans `lot_no` (ordre de grandeur discuté).
- Centaines de main spin `*` encore « Open » (≠ OK/DD).
- Peu de main+`*` en status **SC** pur (~dizaines) vs beaucoup d’autres status.

### Requêtes utiles (sans secrets)

```sql
-- Main spin open (candidats close)
SELECT TRIM(lot_no), TRIM(status), lot_id
  FROM prod_lot
 WHERE TRIM(works_order) = TRIM(lot_no)
   AND TRIM(status) NOT IN ('OK','DD')
 ORDER BY lot_id DESC
 FETCH FIRST 50 ROWS ONLY;

-- Lots with asterisk in LOT_NO
SELECT TRIM(lot_no), TRIM(status), lot_id
  FROM prod_lot
 WHERE INSTR(TRIM(lot_no), '*') > 0
 ORDER BY lot_id DESC
 FETCH FIRST 50 ROWS ONLY;
```

### Patterns code APEX

- Items cachés : `P51_FILTER` (default `OPEN`, Value Protected **No**), `P51_LOT_ID`, `P51_WORKS_ORDER`.
- Pas d’item caché dupliqué `P51_SEARCH` si l’input HTML suffit.
- Impact : n’afficher que les steps avec `count > 0`.
- Stamp CLOSED!! en rouge pour OK/DD.

---

## 6. Actions restantes

1. **TL / métier** : confirmer si les lots avec `*` (et status bizarres) sont le problème signalé par les users.
2. Si oui : resserrer `SEARCH_LOTS` — ex. `INSTR(lot_no,'*') = 0` et/ou Open = status **`SC` only** (amélioration UX, pas copie Speedware stricte).
3. Optionnel : cleanup data status `**` (hors scope page seule).
4. Redéployer patch Ajax/docs TEST puis PROD si filtre appliqué.
5. Push GitHub **seulement** si demandé explicitement (« push »).

---

## 7. Comment on a travaillé ensemble (patterns)

1. **Speedware d’abord** — captures + analyse logique avant code.
2. **Toad en boucle** — l’IA donne les SQL ; l’user exécute, colle résultats, on décide.
3. **Ne pas casser le binôme** — procédure séparée dans le même package.
4. **Front avant branchement** — maquette (Canvas puis HTML) + animations, puis Ajax réel.
5. **Itération visuelle agressive** — dark/light, anti-cartes IA, anglais UI, master-detail.
6. **Codes complets dans le chat** — collage Page Designer sans chasse aux fichiers.
7. **Export APEX Downloads** (`f1400_page_51 (N).sql`) comme vérité runtime à comparer au repo.
8. **TEST → PROD** avec checklist base (synonymes, package VALID, `M_PARAM`) puis import page.
9. **Investigation data** quand le métier voit des « lots bizarres » — distinguer règle Speedware vs filtre liste APEX.
10. **Git** : remote existant, commit local, push sur demande ; auteur commits `steavenspr`.

---

## 8. Liens rapides

- Repo : https://github.com/steavenspr/close-spin-lot  
- Manuel : [`MANUEL-UTILISATION.md`](../../MANUEL-UTILISATION.md)  
- Architecture Page 51 : [`apex/PAGE51_ARCHITECTURE.md`](../../apex/PAGE51_ARCHITECTURE.md)  
- Maquette : [`mockup/`](../../mockup/) — `npx --yes serve -p 8765`
