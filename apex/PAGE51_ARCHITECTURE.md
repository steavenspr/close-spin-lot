# Page 51 — Close SPIN-LOT (SC-INV700)

One APEX page, **HTML / CSS / JS in separate Static Content regions**, data via **AJAX Callbacks** + `FSM.SCT_PRD`.

---

## Page layout (regions top → bottom)

| Order | Static ID | Region title (Page Designer) | Type | Role |
|------:|-----------|------------------------------|------|------|
| 1 | `RGN_P51_STYLESHEET` | Assets — INV700 stylesheet | Static Content (hidden) | `#APP_FILES#page51.css` |
| 2 | `RGN_P51_HIDDEN_PAGE_ITEMS` | Hidden Items — Search, filter & selected lot state | Static Content (hidden) | Page items only |
| 3 | `RGN_P51_PAGE_HEADER` | Page Header — Close SPIN-LOT title & status | Static Content | Title + status pill |
| 4 | `RGN_P51_LOT_SEARCH_PANEL` | Lot Search — Find lot & Open/All filter | Static Content | Search bar + filters |
| 5 | `RGN_P51_MASTER_DETAIL_WORKSPACE` | Master-Detail — Lot list, lot detail & closing impact | Static Content | Fused middle workspace |
| 6 | `RGN_P51_CLOSE_ACTION_BAR` | Action Bar — Close SPIN-LOT confirmation | Static Content | Fixed bottom bar |
| 7 | `RGN_P51_JAVASCRIPT` | Assets — INV700 page scripts | Static Content (hidden) | `#APP_FILES#page51.js` + init |

**Template:** Universal Theme — **Standard** (visible regions) or **Blank with Attributes** (hidden asset regions).

**Page property:** `JavaScript → Function and Global Variable Declaration` → leave empty (all in `RGN_P51_JAVASCRIPT`).

---

## Screen map

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  RGN_P51_PAGE_HEADER                                                         │
│  Close SPIN-LOT                                          ● Ready             │
├──────────────────────────────────────────────────────────────────────────────┤
│  RGN_P51_LOT_SEARCH_PANEL                                                    │
│  Find lot  [ … ]  [ Load lot ]     [ Open ] [ All ]                          │
├──────────────────────────────────────────────────────────────────────────────┤
│  RGN_P51_MASTER_DETAIL_WORKSPACE                                             │
│  ┌─────────────────────┬────────────────────────────────────────────────┐   │
│  │ #inv700-lot-list    │  #inv700-detail + #inv700-impact               │   │
│  └─────────────────────┴────────────────────────────────────────────────┘   │
├──────────────────────────────────────────────────────────────────────────────┤
│  RGN_P51_CLOSE_ACTION_BAR                                                    │
│  [ Clear selection ]                              [ Close SPIN-LOT ]       │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## Page items (`RGN_P51_HIDDEN_PAGE_ITEMS`)

| Item | Type | Purpose |
|------|------|---------|
| `P51_SEARCH` | Text Field (hidden in region) | Search text — bound to visible input in search panel |
| `P51_FILTER` | Hidden | `OPEN` or `ALL` |
| `P51_LOT_ID` | Hidden | Selected `lot_id` for close |
| `P51_WORKS_ORDER` | Hidden | Selected works order |
| `P51_LOT_JSON` | Hidden (CLOB, optional) | Last LOAD_LOT JSON for re-render |

See `page51_items.sql` for create notes.

---

## AJAX Callbacks

| Callback | In | Out | PL/SQL |
|----------|----|----|--------|
| `SEARCH_LOTS` | `x01`=search, `x02`=filter | JSON `{ lots: [...] }` | Main spin lots query |
| `LOAD_LOT` | `x01`=works_order | JSON `{ lot, impact }` | `load_main_spin_lot` + COUNTs |
| `CLOSE_LOT` | `x01`=lot_id | JSON `{ success, message }` | `close_spin_lot_inv700` |

Paste PL/SQL from `page51_ajax.sql`.

---

## Dynamic Actions (minimal)

| # | Event | Action |
|---|-------|--------|
| 1 | Page Load | Execute JS → `inv700Init()` |
| 2 | Click `.inv700-lot-row` | *(optional — handled in JS)* |
| 3 | Click `#inv700-btn-load` | *(optional — handled in JS)* |
| 4 | Click `#inv700-btn-close` | *(optional — handled in JS)* |

All UI events are bound in `page51.js` on init — no extra DAs required.

---

## Files in repo

```
apex/
  PAGE51_ARCHITECTURE.md   ← this file
  page51.css               ← RGN_P51_STYLESHEET
  page51.js                ← RGN_P51_JAVASCRIPT
  page51_regions.html      ← paste into Static Content regions
  page51_items.sql         ← page item checklist
  page51_ajax.sql          ← AJAX callback PL/SQL
```

Legacy `page90_*` files kept for reference; use **page51_*** for Page 51.

---

## Deploy in APEX (checklist)

1. **Page 51** — name `Close SPIN-LOT`, alias `CLOSE-SPIN-LOT`, language English.
2. **Static Application Files** — upload `page51.css`, `page51.js`.
3. **Regions** — create 7 regions in order; set Static ID + Title from table above.
4. **Hidden regions** — Template: Blank with Attributes; CSS Classes: `u-hidden` (or Display: Never).
5. **Items** — create items in `RGN_P51_HIDDEN_PAGE_ITEMS` per `page51_items.sql`.
6. **HTML** — paste blocks from `page51_regions.html` into matching regions.
7. **AJAX** — create 3 callbacks from `page51_ajax.sql`.
8. **Test** — search `2608` → list → select lot → close (TEST DB).

---

## UI behaviour

- Search returns **main spin lots only** (`works_order = lot_no`, status not OK/DD when filter OPEN).
- **List left / detail right** when >1 result (CSS grid inside `RGN_P51_MASTER_DETAIL_WORKSPACE`).
- **Closing impact** shows only steps with `count > 0`.
- **CLOSED!!** stamp and closed state in **red**.
- One lot closed per confirmation (no batch).
