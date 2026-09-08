# Page 90 — Close SPIN-LOT (SC-INV700)

One APEX page, **HTML / CSS / JS in separate Static Content regions**, data via **AJAX Callbacks** + `FSM.SCT_PRD`.

---

## Page layout (regions top → bottom)

| Order | Static ID | Type | Role |
|------:|-----------|------|------|
| 1 | `RGN_P90_CSS` | Static Content | `<link>` or inline `@import` → `page90.css` |
| 2 | `RGN_P90_ITEMS` | Static Content (hidden) | Page items only (no visible HTML) |
| 3 | `RGN_P90_HEADER` | Static Content | Title + status pill (`#inv700-status`) |
| 4 | `RGN_P90_SEARCH` | Static Content | Search bar + Open/All toggles |
| 5 | `RGN_P90_WORKSPACE` | Static Content | Master-detail shell (list + detail + impact) |
| 6 | `RGN_P90_ACTIONS` | Static Content | Fixed bottom bar (Close SPIN-LOT) |
| 7 | `RGN_P90_JS` | Static Content | `<script src="page90.js">` + `inv700Init()` on load |

**Template:** Universal Theme — **Standard** or **Blank with Attributes** for workspace/JS regions.

**Page property:** `JavaScript → Function and Global Variable Declaration` → leave empty (all in `RGN_P90_JS`).

---

## Page items (`RGN_P90_ITEMS`)

| Item | Type | Purpose |
|------|------|---------|
| `P90_SEARCH` | Text Field | Search text |
| `P90_FILTER` | Hidden | `OPEN` or `ALL` |
| `P90_LOT_ID` | Hidden | Selected lot_id for close |
| `P90_WORKS_ORDER` | Hidden | Selected works order |
| `P90_LOT_JSON` | Hidden (CLOB) | Last LOAD_LOT JSON for JS re-render |

Display-only items optional (can be pure JS DOM); hidden items enough for processes.

---

## AJAX Callbacks

| Callback | In | Out | PL/SQL |
|----------|----|----|--------|
| `SEARCH_LOTS` | `x01`=search, `x02`=filter | JSON array | SELECT main spin lots |
| `LOAD_LOT` | `x01`=works_order | JSON lot + impact | `load_main_spin_lot` + COUNTs |
| `CLOSE_LOT` | `x01`=lot_id | JSON `{success, message}` | `close_spin_lot_inv700` |

---

## Dynamic Actions (minimal)

| # | Event | Action |
|---|-------|--------|
| 1 | Page Load | Execute JS → `inv700Init()` |
| 2 | Click `.inv700-lot-row` | Execute JS → `inv700SelectLot(worksOrder)` |
| 3 | Click `#inv700-btn-load` | Execute JS → `inv700Search()` |
| 4 | Click `#inv700-btn-close` | Execute JS → `inv700ConfirmClose()` |
| 5 | Click `#inv700-filter-open/all` | Execute JS → toggle filter + refresh list |

No DA for each field — **JS owns UI state** (same as mockup).

---

## Files in repo

```
apex/
  PAGE90_ARCHITECTURE.md   ← this file
  page90.css               ← RGN_P90_CSS
  page90.js                ← RGN_P90_JS
  page90_regions.html      ← paste into Static Content regions
  page90_ajax.sql          ← AJAX callback PL/SQL
  page90_items.sql           ← item list + LOV notes
```

---

## Deploy in APEX

1. Create page **90**, alias `CLOSE-SPIN-LOT`, English.
2. Add regions in order above; paste HTML from `page90_regions.html`.
3. Upload `page90.css` / `page90.js` as **Static Application Files** (or workspace files) and reference in regions.
4. Create 3 AJAX callbacks from `page90_ajax.sql`.
5. Test: search `2608` → list → select → close (TEST DB).

---

## UI behaviour (matches mockup)

- Search returns **main spin lots only** (`works_order = lot_no`, status not OK/DD).
- **List left / detail right** when >1 result.
- **Closing impact** shows only steps with `count > 0`.
- **CLOSED!!** stamp and closed state in **red**.
- One lot closed per confirmation (no batch).
