-- =============================================================================
-- Page 90 — AJAX Callbacks (paste into Page Designer → AJAX Callbacks)
-- App process names: SEARCH_LOTS, LOAD_LOT, CLOSE_LOT
-- =============================================================================

-- -----------------------------------------------------------------------------
-- SEARCH_LOTS — x01=search, x02=OPEN|ALL
-- Returns JSON: { "lots": [ { worksOrder, lotId, yarnFlg, mcode, dateSch, isClosed } ] }
-- -----------------------------------------------------------------------------
/*
DECLARE
  l_search VARCHAR2(100) := apex_application.g_x01;
  l_filter VARCHAR2(10)  := UPPER(NVL(apex_application.g_x02, 'OPEN'));
  l_cur    SYS_REFCURSOR;
BEGIN
  OPEN l_cur FOR
    SELECT TRIM(p.lot_no)      AS works_order,
           p.lot_id,
           TRIM(p.yarn_flg)    AS yarn_flg,
           TRIM(p.mcode)       AS mcode,
           TO_CHAR(p.date_sch, 'DD-MON-YY') AS date_sch,
           CASE WHEN TRIM(p.status) IN ('OK', 'DD') THEN 1 ELSE 0 END AS is_closed
      FROM prod_lot p
     WHERE TRIM(p.works_order) = TRIM(p.lot_no)
       AND (l_filter = 'ALL' OR TRIM(p.status) NOT IN ('OK', 'DD'))
       AND (
            l_search IS NULL
            OR TRIM(l_search) IS NULL
            OR UPPER(TRIM(p.lot_no))      LIKE '%' || UPPER(TRIM(l_search)) || '%'
            OR UPPER(TRIM(p.product_no)) LIKE '%' || UPPER(TRIM(l_search)) || '%'
            OR UPPER(TRIM(p.yarn_flg))  LIKE '%' || UPPER(TRIM(l_search)) || '%'
            OR UPPER(TRIM(p.mcode))      LIKE '%' || UPPER(TRIM(l_search)) || '%'
           )
     ORDER BY p.lot_id DESC
     FETCH FIRST 50 ROWS ONLY;

  apex_json.open_object;
  apex_json.open_array('lots');
  FOR r IN (
    SELECT TRIM(p.lot_no) AS works_order, p.lot_id,
           TRIM(p.yarn_flg) AS yarn_flg, TRIM(p.mcode) AS mcode,
           TO_CHAR(p.date_sch, 'DD-MON-YY') AS date_sch,
           CASE WHEN TRIM(p.status) IN ('OK', 'DD') THEN 1 ELSE 0 END AS is_closed
      FROM prod_lot p
     WHERE TRIM(p.works_order) = TRIM(p.lot_no)
       AND (l_filter = 'ALL' OR TRIM(p.status) NOT IN ('OK', 'DD'))
       AND (
            l_search IS NULL OR TRIM(l_search) IS NULL
            OR UPPER(TRIM(p.lot_no))      LIKE '%' || UPPER(TRIM(l_search)) || '%'
            OR UPPER(TRIM(p.product_no)) LIKE '%' || UPPER(TRIM(l_search)) || '%'
            OR UPPER(TRIM(p.yarn_flg))  LIKE '%' || UPPER(TRIM(l_search)) || '%'
            OR UPPER(TRIM(p.mcode))      LIKE '%' || UPPER(TRIM(l_search)) || '%'
           )
     ORDER BY p.lot_id DESC
     FETCH FIRST 50 ROWS ONLY
  ) LOOP
    apex_json.open_object;
    apex_json.write('worksOrder', r.works_order);
    apex_json.write('lotId', r.lot_id);
    apex_json.write('yarnFlg', r.yarn_flg);
    apex_json.write('mcode', r.mcode);
    apex_json.write('dateSch', r.date_sch);
    apex_json.write('isClosed', r.is_closed = 1);
    apex_json.close_object;
  END LOOP;
  apex_json.close_array;
  apex_json.close_object;
END;
*/

-- -----------------------------------------------------------------------------
-- LOAD_LOT — x01=works_order
-- Returns JSON: { lot: {...}, impact: [ { id, label, count } ] }
-- -----------------------------------------------------------------------------
/*
DECLARE
  l_wo   VARCHAR2(30) := TRIM(apex_application.g_x01);
  l_rec  fsm.sct_prd.t_spin_lot_rec;
  l_wo_t VARCHAR2(30);
  l_cnt  NUMBER;
BEGIN
  fsm.sct_prd.load_main_spin_lot(l_wo, l_rec);

  IF l_rec.lot_id IS NULL THEN
    apex_json.open_object;
    apex_json.write('success', false);
    apex_json.write('message', 'Lot not found or not a main spin lot.');
    apex_json.close_object;
    RETURN;
  END IF;

  l_wo_t := TRIM(l_rec.lot_no);

  apex_json.open_object;
  apex_json.open_object('lot');
  apex_json.write('lotId', l_rec.lot_id);
  apex_json.write('lotNo', TRIM(l_rec.lot_no));
  apex_json.write('productNo', TRIM(l_rec.product_no));
  apex_json.write('yarnFlg', TRIM(l_rec.yarn_flg));
  apex_json.write('mcode', TRIM(l_rec.mcode));
  apex_json.write('dateSch', TO_CHAR(l_rec.date_sch, 'DD-MON-YY'));
  apex_json.write('qtyOrd', l_rec.qty_ord);
  apex_json.write('qtyRec', l_rec.qty_rec);
  apex_json.write('qoh', l_rec.qoh);
  apex_json.write('kgs1', l_rec.input_wt);
  apex_json.write('kgs2', NULL);
  apex_json.write('isClosed', UPPER(TRIM(l_rec.status)) IN ('OK', 'DD'));
  apex_json.close_object;

  apex_json.open_array('impact');

  apex_json.open_object;
  apex_json.write('id', 'spin');
  apex_json.write('label', 'Spin lot');
  apex_json.write('count', 1);
  apex_json.close_object;

  SELECT COUNT(*) INTO l_cnt FROM wip_hdr
   WHERE TRIM(works_order) = l_wo_t AND TRIM(status) NOT IN ('OK');
  IF l_cnt > 0 THEN
    apex_json.open_object;
    apex_json.write('id', 'wip');
    apex_json.write('label', 'Work in progress');
    apex_json.write('count', l_cnt);
    apex_json.close_object;
  END IF;

  SELECT COUNT(*) INTO l_cnt FROM d_blendhdr
   WHERE TRIM(works_order) = l_wo_t AND TRIM(status) NOT IN ('OK');
  IF l_cnt > 0 THEN
    apex_json.open_object;
    apex_json.write('id', 'blend');
    apex_json.write('label', 'Blend orders');
    apex_json.write('count', l_cnt);
    apex_json.close_object;
  END IF;

  SELECT COUNT(*) INTO l_cnt FROM ord_ship
   WHERE TRIM(lot_no) = l_wo_t AND TRIM(status) NOT IN ('OK');
  IF l_cnt > 0 THEN
    apex_json.open_object;
    apex_json.write('id', 'ship');
    apex_json.write('label', 'Shipment');
    apex_json.write('count', l_cnt);
    apex_json.close_object;
  END IF;

  SELECT COUNT(*) INTO l_cnt FROM prod_lot
   WHERE TRIM(works_order) = l_wo_t
     AND TRIM(lot_no) <> l_wo_t
     AND TRIM(status) NOT IN ('OK', 'DD');
  IF l_cnt > 0 THEN
    apex_json.open_object;
    apex_json.write('id', 'linked');
    apex_json.write('label', 'Related lots');
    apex_json.write('count', l_cnt);
    apex_json.close_object;
  END IF;

  apex_json.close_array;
  apex_json.close_object;
END;
*/

-- -----------------------------------------------------------------------------
-- CLOSE_LOT — x01=lot_id
-- -----------------------------------------------------------------------------
/*
DECLARE
  l_lot_id NUMBER := TO_NUMBER(apex_application.g_x01);
BEGIN
  fsm.sct_prd.close_spin_lot_inv700(l_lot_id);

  apex_json.open_object;
  apex_json.write('success', true);
  apex_json.write('message', 'SPIN-LOT closed successfully.');
  apex_json.close_object;
EXCEPTION
  WHEN OTHERS THEN
    apex_json.open_object;
    apex_json.write('success', false);
    apex_json.write('message', SQLERRM);
    apex_json.close_object;
END;
*/
