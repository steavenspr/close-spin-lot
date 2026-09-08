# Close SPIN-LOT (SC-INV700) — Page 51 APEX

Migration Speedware **SC-INV700 Close SPIN-LOT** vers Oracle APEX **App 1400 — Page 51**, avec maquette HTML standalone et assets APEX (HTML / CSS / JS / Ajax).

Repo de référence frontend + collage Page Designer. **Pas de secrets ni `.env`.**

---

## Documents du repo

| Fichier | Rôle |
|---------|------|
| [MANUEL-UTILISATION.md](MANUEL-UTILISATION.md) | Manuel utilisateur (métier / support) |
| [apex/PAGE51_ARCHITECTURE.md](apex/PAGE51_ARCHITECTURE.md) | Architecture Page 51 |
| [apex/page51_regions.html](apex/page51_regions.html) | HTML des régions APEX |
| [apex/page51_inline.css](apex/page51_inline.css) | CSS Inline Page 51 |
| [apex/page51.js](apex/page51.js) | JavaScript Page 51 |
| [apex/page51_ajax.sql](apex/page51_ajax.sql) | Callbacks Ajax SEARCH / LOAD / CLOSE |
| [apex/f1400_page_51.sql](apex/f1400_page_51.sql) | Export page APEX (référence) |
| [sct_prd_close_spin_lot_inv700.sql](sct_prd_close_spin_lot_inv700.sql) | Patch package `FSM.SCT_PRD.close_spin_lot_inv700` |
| [toad_inv700_close_test.sql](toad_inv700_close_test.sql) | Scripts test Toad (sans credentials) |
| [mockup/](mockup/) | Maquette HTML claire (thème light) |

Page 90 (Spin Lot Main — tampon CLOSED!!) : fichiers `apex/page90_*` et `apex/f1400_page_90.sql`.

---

## Lancer la maquette

HTML statique — pas de `npm install` obligatoire.

```powershell
cd mockup
npx --yes serve -p 8765
```

Puis ouvrir : [http://localhost:8765/](http://localhost:8765/)

Fichiers : `mockup/index.html`, `mockup.css`, `mockup.js` (données démo préfixe `2608`).

---

## Coller / déployer dans APEX (Page 51)

1. **Base** : package `FSM.SCT_PRD` avec `close_spin_lot_inv700` (VALID) + synonymes WOOL.
2. **Page Designer** — coller :
   - CSS Inline ← `apex/page51_inline.css`
   - JavaScript (Function and Global Variable Declaration) ← `apex/page51.js`
   - Régions Static Content ← blocs dans `apex/page51_regions.html`
   - Ajax Callbacks ← `SEARCH_LOTS`, `LOAD_LOT`, `CLOSE_LOT` dans `apex/page51_ajax.sql`
3. Items cachés : `P51_FILTER` (default `OPEN`, Value Protected = **No**), `P51_LOT_ID`, `P51_WORKS_ORDER`.
4. **Save** → Ctrl+F5.

Détail architecture : [apex/PAGE51_ARCHITECTURE.md](apex/PAGE51_ARCHITECTURE.md).

---

## Aide rapide

| Problème | Où regarder |
|----------|-------------|
| Liste toujours 50 lots après Entrée | `page51.js` — `preventDefault` sur Enter |
| JSON / `sqlerrm` au clic lot | Ajax `LOAD_LOT` (`page51_ajax.sql`) |
| Close → INVALID DATE | `M_PARAM` clé `DATE` (fenêtre YYYYMMDD) |
| Maquette ne démarre pas | `npx serve` dans `mockup/` |

---

## Description GitHub (champ Description)

> Oracle APEX Page 51 (SC-INV700 Close SPIN-LOT) — HTML mockup, APEX HTML/CSS/JS/Ajax, SCT_PRD SQL, full user manual. Private; no secrets or .env.
