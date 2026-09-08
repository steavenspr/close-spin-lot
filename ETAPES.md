# Étapes — Collage APEX Page 51 (Close SPIN-LOT)

## Prérequis base

1. Synonymes FSM → WOOL : `PROD_LOT`, `WIP_HDR`, `D_BLENDHDR`, `ORD_SHIP`, `M_PARAM`
2. Package `FSM.SCT_PRD` VALID avec `close_spin_lot_inv700`
3. `M_PARAM` clé `DATE` = plage courante (`YYYYMMDD` + `YYYYMMDD`)

## Page Designer

| Emplacement | Fichier / contenu |
|-------------|-------------------|
| CSS → Inline | `apex/page51_inline.css` (tout remplacer) |
| JS → Function and Global Variable Declaration | `apex/page51.js` (tout remplacer) |
| Région Search | Bloc search dans `apex/page51_regions.html` |
| Région Workspace | Bloc workspace |
| Région Action bar | Bloc action bar |
| **Supprimer** région header titre | Plus de SC-INV700 / Close SPIN-LOT / pill Open |
| Items | `P51_FILTER` (OPEN, Value Protected No), `P51_LOT_ID`, `P51_WORKS_ORDER` |
| Ajax | `SEARCH_LOTS`, `LOAD_LOT`, `CLOSE_LOT` ← `apex/page51_ajax.sql` |

## Import alternatif

Exécuter `apex/f1400_page_51.sql` en schéma parsing (FSM) puis Ctrl+F5.

## Smoke test

1. Ouverture → liste Open  
2. Recherche + Entrée → filtre sans reload  
3. Clic lot → détail  
4. Close (lot test) → succès + CLOSED!!
