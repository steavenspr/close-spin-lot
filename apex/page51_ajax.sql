-- Page 51 — AJAX Callbacks (wool.prod_lot — TEST DB)

-- =============================================================================
-- SEARCH_LOTS
-- =============================================================================
DECLARE
  l_search VARCHAR2(100) := apex_application.g_x01;
  l_filter VARCHAR2(10)  := UPPER(NVL(apex_application.g_x02, 'OPEN'));
BEGIN
  apex_json.open_object;
  apex_json.open_array('lots');
  FOR r IN (
    SELECT TRIM(p.lot_no) AS works_order, p.lot_id,
           TRIM(p.yarn_flg) AS yarn_flg, TRIM(p.mcode) AS mcode,
           TO_CHAR(p.date_sch, 'DD-MON-YY') AS date_sch,
           CASE WHEN TRIM(p.status) IN ('OK', 'DD') THEN 1 ELSE 0 END AS is_closed
      FROM wool.prod_lot p
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
EXCEPTION
  WHEN OTHERS THEN
    apex_json.open_object;
    apex_json.write('success', false);
    apex_json.write('message', SQLERRM);
    apex_json.open_array('lots');
    apex_json.close_array;
    apex_json.close_object;
END;

-- =============================================================================
-- LOAD_LOT — direct wool.prod_lot (+ qty_ord via SCT_PRD si dispo)
-- =============================================================================
DECLARE
  l_wo        VARCHAR2(100) := TRIM(apex_application.g_x01);
  l_wo_t      VARCHAR2(30);
  l_cnt       NUMBER;
  l_qty_ord   NUMBER;
  l_lot_id    wool.prod_lot.lot_id%TYPE;
  l_lot_no    wool.prod_lot.lot_no%TYPE;
  l_product   wool.prod_lot.product_no%TYPE;
  l_yarn      wool.prod_lot.yarn_flg%TYPE;
  l_mcode     wool.prod_lot.mcode%TYPE;
  l_date_sch  wool.prod_lot.date_sch%TYPE;
  l_qty_rec   wool.prod_lot.qty_rec%TYPE;
  l_qoh       wool.prod_lot.qoh%TYPE;
  l_kgs1      wool.prod_lot.kgs_1%TYPE;
  l_kgs2      wool.prod_lot.kgs_2%TYPE;
  l_status    wool.prod_lot.status%TYPE;
  l_rec       fsm.sct_prd.t_spin_lot_rec;
BEGIN
  IF l_wo IS NULL THEN
    apex_json.open_object;
    apex_json.write('success', false);
    apex_json.write('message', 'Works order required.');
    apex_json.close_object;
    RETURN;
  END IF;

  BEGIN
    fsm.sct_prd.load_main_spin_lot(
      p_works_order => l_wo,
      p_result      => l_rec
    );
    l_qty_ord := l_rec.qty_ord;
  EXCEPTION
    WHEN OTHERS THEN
      l_qty_ord := NULL;
  END;

  SELECT p.lot_id,
         TRIM(p.lot_no),
         TRIM(p.product_no),
         TRIM(p.yarn_flg),
         TRIM(p.mcode),
         p.date_sch,
         p.qty_rec,
         p.qoh,
         p.kgs_1,
         p.kgs_2,
         TRIM(p.status)
    INTO l_lot_id,
         l_lot_no,
         l_product,
         l_yarn,
         l_mcode,
         l_date_sch,
         l_qty_rec,
         l_qoh,
         l_kgs1,
         l_kgs2,
         l_status
    FROM wool.prod_lot p
   WHERE TRIM(p.lot_no) = l_wo
     AND TRIM(p.works_order) = TRIM(p.lot_no);

  l_wo_t := l_lot_no;

  apex_json.open_object;
  apex_json.open_object('lot');
  apex_json.write('lotId', l_lot_id);
  apex_json.write('lotNo', l_lot_no);
  apex_json.write('productNo', l_product);
  apex_json.write('yarnFlg', l_yarn);
  apex_json.write('mcode', l_mcode);
  apex_json.write('dateSch', TO_CHAR(l_date_sch, 'DD-MON-YY'));
  apex_json.write('qtyOrd', l_qty_ord);
  apex_json.write('qtyRec', l_qty_rec);
  apex_json.write('qoh', l_qoh);
  apex_json.write('kgs1', l_kgs1);
  apex_json.write('kgs2', l_kgs2);
  apex_json.write('isClosed', UPPER(l_status) IN ('OK', 'DD'));
  apex_json.close_object;

  apex_json.open_array('impact');

  apex_json.open_object;
  apex_json.write('id', 'spin');
  apex_json.write('label', 'Spin lot');
  apex_json.write('count', 1);
  apex_json.close_object;

  BEGIN
    SELECT COUNT(*) INTO l_cnt
      FROM wool.wip_hdr
     WHERE TRIM(works_order) = l_wo_t
       AND TRIM(status) NOT IN ('OK');
    IF l_cnt > 0 THEN
      apex_json.open_object;
      apex_json.write('id', 'wip');
      apex_json.write('label', 'Work in progress');
      apex_json.write('count', l_cnt);
      apex_json.close_object;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN NULL;
  END;

  BEGIN
    SELECT COUNT(*) INTO l_cnt
      FROM wool.d_blendhdr
     WHERE TRIM(works_order) = l_wo_t
       AND TRIM(status) NOT IN ('OK');
    IF l_cnt > 0 THEN
      apex_json.open_object;
      apex_json.write('id', 'blend');
      apex_json.write('label', 'Blend orders');
      apex_json.write('count', l_cnt);
      apex_json.close_object;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN NULL;
  END;

  BEGIN
    SELECT COUNT(*) INTO l_cnt
      FROM wool.ord_ship
     WHERE TRIM(lot_no) = l_wo_t
       AND TRIM(status) NOT IN ('OK');
    IF l_cnt > 0 THEN
      apex_json.open_object;
      apex_json.write('id', 'ship');
      apex_json.write('label', 'Shipment');
      apex_json.write('count', l_cnt);
      apex_json.close_object;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN NULL;
  END;

  BEGIN
    SELECT COUNT(*) INTO l_cnt
      FROM wool.prod_lot
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
  EXCEPTION
    WHEN OTHERS THEN NULL;
  END;

  apex_json.close_array;
  apex_json.close_object;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    apex_json.open_object;
    apex_json.write('success', false);
    apex_json.write('message', 'Lot not found or not a main spin lot.');
    apex_json.close_object;
  WHEN OTHERS THEN
    apex_json.open_object;
    apex_json.write('success', false);
    apex_json.write('message', SQLERRM);
    apex_json.close_object;
END;

-- =============================================================================
-- CLOSE_LOT
-- =============================================================================
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
