-- =============================================================================
-- Page 51 — Page items (region RGN_P51_HIDDEN_PAGE_ITEMS)
-- Create in Page Designer → Items inside hidden region
-- =============================================================================

/*
Item name         Type              Default    Notes
─────────────────────────────────────────────────────────────────────────────
P51_SEARCH        Text Field        (null)     Visible input is in search panel HTML;
                                               sync via same id="P51_SEARCH" or apex.item
P51_FILTER        Hidden            OPEN       OPEN | ALL
P51_LOT_ID        Hidden            (null)     Selected lot_id for CLOSE_LOT
P51_WORKS_ORDER   Hidden            (null)     Selected works order
P51_LOT_JSON      Hidden (optional) (null)     CLOB — last LOAD_LOT JSON if needed
*/

-- Region settings for RGN_P51_HIDDEN_PAGE_ITEMS:
--   Static ID:  RGN_P51_HIDDEN_PAGE_ITEMS
--   Title:      Hidden Items — Search, filter & selected lot state
--   Template:   Blank with Attributes
--   Display:    Never (or CSS Classes: u-hidden)

-- Note: P51_SEARCH can live in RGN_P51_LOT_SEARCH_PANEL as native HTML input
-- with id="P51_SEARCH". APEX item P51_SEARCH should use Source = Null,
-- Session State = Per Session, and no visible label in the hidden region.
