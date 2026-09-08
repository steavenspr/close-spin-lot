-- =============================================================================
-- SC-INV700 Close SPIN-LOT — TEST parcours complet (Toad, TEST DB)
-- Connect as FSM. Enable DBMS Output. Substitution variables: None.
-- TEST: FSM@192.168.150.250:1521/TFKL
--
-- Phase 1 : SELECT only (sections 1–12) — paste results back
-- Phase 2 : Simulation SC-INV700 with SAVEPOINT + ROLLBACK (section 13)
-- Phase 3 : Optional — binôme SCT_PRD.close_spin_lot compare (section 14)
-- =============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

-- -----------------------------------------------------------------------------
-- Pick works order to test (change if needed)
-- -----------------------------------------------------------------------------
DEFINE p_works_order = '2608-0027'

PROMPT === 1) Main spin lot exists? (works_order = lot_no) ===
SELECT lot_id,
       TRIM(lot_no)      AS lot_no,
       TRIM(works_order) AS works_order,
       TRIM(product_no)  AS product_no,
       TRIM(yarn_flg)    AS yarn_flg,
       TRIM(status)      AS status,
       TRIM(mcode)       AS mcode,
       date_del,
       date_sch,
       qty_rec,
       qoh,
       kgs_1,
       kgs_2
  FROM wool.prod_lot
 WHERE TRIM(works_order) = TRIM('&p_works_order')
   AND TRIM(lot_no) = TRIM('&p_works_order');

PROMPT === 2) Open main spin lots (candidates for close test) ===
SELECT TRIM(lot_no)      AS lot_no,
       TRIM(works_order) AS works_order,
       TRIM(status)      AS status,
       TRIM(yarn_flg)    AS yarn_flg,
       lot_id
  FROM wool.prod_lot
 WHERE TRIM(works_order) = TRIM(lot_no)
   AND TRIM(status) NOT IN ('OK', 'DD')
 ORDER BY lot_id DESC
 FETCH FIRST 10 ROWS ONLY;

PROMPT === 3) Already closed? (Speedware CLOSED!!) ===
SELECT TRIM(lot_no) AS lot_no,
       TRIM(status) AS status,
       CASE
         WHEN TRIM(status) IN ('OK', 'DD') THEN 'CLOSED!!'
         ELSE 'OPEN'
       END AS close_flag
  FROM wool.prod_lot
 WHERE TRIM(lot_no) = TRIM('&p_works_order');

PROMPT === 4) M_PARAM date window (SC-INV700 INVALID DATE check) ===
SELECT m_key,
       descr,
       LENGTH(TRIM(descr)) AS descr_len,
       SUBSTR(TRIM(descr), 1, 8)  AS date_from_raw,
       SUBSTR(TRIM(descr), 9, 8)  AS date_to_raw,
       count0
  FROM wool.m_param
 WHERE TRIM(m_key) = 'DATE';

PROMPT === 4b) Date check — try DD-MON-YY (adjust if 4 fails) ===
SELECT SYSDATE AS today,
       CASE
         WHEN SYSDATE BETWEEN
              TO_DATE(SUBSTR(TRIM(descr), 1, 8), 'DD-MON-YY')
          AND TO_DATE(SUBSTR(TRIM(descr), 9, 8), 'DD-MON-YY')
         THEN 'OK'
         ELSE 'INVALID DATE'
       END AS date_check
  FROM wool.m_param
 WHERE TRIM(m_key) = 'DATE';

PROMPT === 5) WIP_HDR — MCODE source (pattern 02xx, backward = last row) ===
SELECT TRIM(works_order) AS works_order,
       TRIM(mcode)       AS mcode,
       TRIM(status)      AS status,
       hrs_avl
  FROM wool.wip_hdr
 WHERE TRIM(works_order) = TRIM('&p_works_order')
 ORDER BY mcode DESC;

PROMPT === 5b) LV-MCODE candidate (last 02xx row) ===
SELECT TRIM(mcode) AS lv_mcode
  FROM (
        SELECT TRIM(mcode) AS mcode
          FROM wool.wip_hdr
         WHERE TRIM(works_order) = TRIM('&p_works_order')
           AND TRIM(mcode) LIKE '02%'
         ORDER BY mcode DESC
       )
 WHERE ROWNUM = 1;

PROMPT === 6) ORD_SHIP chain (AT RECORD Speedware) ===
SELECT TRIM(s.lot_no) AS lot_no,
       s.order_id,
       TRIM(s.status) AS status
  FROM wool.ord_ship s
 WHERE TRIM(s.lot_no) = TRIM('&p_works_order');

PROMPT === 6b) ORD_DET via ORDER_ID ===
SELECT TRIM(d.order_no) AS order_no,
       d.order_id
  FROM wool.ord_ship s
  JOIN wool.ord_det d ON d.order_id = s.order_id
 WHERE TRIM(s.lot_no) = TRIM('&p_works_order');

PROMPT === 7) D_BLENDHDR — cascade target ===
SELECT TRIM(works_order) AS works_order,
       TRIM(order_no)    AS order_no,
       TRIM(status)      AS status
  FROM wool.d_blendhdr
 WHERE TRIM(works_order) = TRIM('&p_works_order');

PROMPT === 8) Related PROD_LOT — SC-INV700 rule (works_order = main lot_no) ===
SELECT TRIM(lot_no)      AS lot_no,
       TRIM(works_order) AS works_order,
       TRIM(product_no)  AS product_no,
       TRIM(yarn_flg)    AS yarn_flg,
       TRIM(status)      AS status,
       kgs_1
  FROM wool.prod_lot
 WHERE TRIM(works_order) = TRIM('&p_works_order')
   AND TRIM(lot_no) <> TRIM('&p_works_order')
 ORDER BY lot_no;

PROMPT === 8b) Related PROD_LOT — binôme rule (product Y% only) ===
SELECT TRIM(lot_no)      AS lot_no,
       TRIM(product_no)  AS product_no,
       TRIM(status)      AS status
  FROM wool.prod_lot
 WHERE TRIM(works_order) = TRIM('&p_works_order')
   AND SUBSTR(TRIM(product_no), 1, 1) = 'Y'
   AND TRIM(lot_no) <> TRIM('&p_works_order')
 ORDER BY lot_no;

PROMPT === 9) Impact counts (before close) ===
SELECT 'main PROD_LOT' AS step, COUNT(*) AS cnt
  FROM wool.prod_lot
 WHERE TRIM(lot_no) = TRIM('&p_works_order')
   AND TRIM(works_order) = TRIM('&p_works_order')
UNION ALL
SELECT 'WIP_HDR', COUNT(*)
  FROM wool.wip_hdr
 WHERE TRIM(works_order) = TRIM('&p_works_order')
UNION ALL
SELECT 'WIP_HDR not OK', COUNT(*)
  FROM wool.wip_hdr
 WHERE TRIM(works_order) = TRIM('&p_works_order')
   AND TRIM(status) NOT IN ('OK')
UNION ALL
SELECT 'D_BLENDHDR', COUNT(*)
  FROM wool.d_blendhdr
 WHERE TRIM(works_order) = TRIM('&p_works_order')
UNION ALL
SELECT 'D_BLENDHDR not OK', COUNT(*)
  FROM wool.d_blendhdr
 WHERE TRIM(works_order) = TRIM('&p_works_order')
   AND TRIM(status) NOT IN ('OK')
UNION ALL
SELECT 'ORD_SHIP', COUNT(*)
  FROM wool.ord_ship
 WHERE TRIM(lot_no) = TRIM('&p_works_order')
UNION ALL
SELECT 'related PROD_LOT (SC-INV700)', COUNT(*)
  FROM wool.prod_lot
 WHERE TRIM(works_order) = TRIM('&p_works_order')
   AND TRIM(lot_no) <> TRIM('&p_works_order')
UNION ALL
SELECT 'related yarn 1x (KGS_1->0)', COUNT(*)
  FROM wool.prod_lot
 WHERE TRIM(works_order) = TRIM('&p_works_order')
   AND TRIM(lot_no) <> TRIM('&p_works_order')
   AND TRIM(yarn_flg) LIKE '1%';

PROMPT === 10) SCT_PRD.load_main_spin_lot — live API test ===
DECLARE
  l_rec fsm.sct_prd.t_spin_lot_rec;
BEGIN
  fsm.sct_prd.load_main_spin_lot(
    p_works_order => '&p_works_order',
    p_result      => l_rec
  );

  IF l_rec.lot_id IS NULL THEN
    DBMS_OUTPUT.put_line('load_main_spin_lot: NO DATA');
  ELSE
    DBMS_OUTPUT.put_line('lot_id     = ' || l_rec.lot_id);
    DBMS_OUTPUT.put_line('lot_no     = [' || TRIM(l_rec.lot_no) || ']');
    DBMS_OUTPUT.put_line('product_no = [' || TRIM(l_rec.product_no) || ']');
    DBMS_OUTPUT.put_line('yarn_flg   = [' || TRIM(l_rec.yarn_flg) || ']');
    DBMS_OUTPUT.put_line('status     = [' || TRIM(l_rec.status) || ']');
    DBMS_OUTPUT.put_line('qty_ord    = ' || l_rec.qty_ord);
    DBMS_OUTPUT.put_line('qoh        = ' || l_rec.qoh);
    DBMS_OUTPUT.put_line('input_wt   = ' || l_rec.input_wt);
  END IF;
END;
/

-- =============================================================================
-- 11) SC-INV700 simulation — FULL cascade, ROLLBACK at end
--     Run ONLY on TEST. Change p_works_order if needed.
--     Do NOT run section 14 in same session after commit.
-- =============================================================================
PROMPT === 11) SC-INV700 close simulation (SAVEPOINT + ROLLBACK) ===

DECLARE
  c_wo          CONSTANT VARCHAR2(10) := TRIM('&p_works_order');
  l_lot_id      wool.prod_lot.lot_id%TYPE;
  l_lot_no      wool.prod_lot.lot_no%TYPE;
  l_works_order wool.prod_lot.works_order%TYPE;
  l_status      wool.prod_lot.status%TYPE;
  l_yarn_flg    wool.prod_lot.yarn_flg%TYPE;
  l_mcode       wool.prod_lot.mcode%TYPE;
  l_date_del    DATE := TRUNC(SYSDATE);
  l_date_from   DATE;
  l_date_to     DATE;
  l_cnt         NUMBER;
BEGIN
  DBMS_OUTPUT.put_line('=== SC-INV700 simulate close for ' || c_wo || ' ===');

  SELECT lot_id, lot_no, works_order, status, yarn_flg
    INTO l_lot_id, l_lot_no, l_works_order, l_status, l_yarn_flg
    FROM wool.prod_lot
   WHERE TRIM(works_order) = c_wo
     AND TRIM(lot_no) = c_wo
     FOR UPDATE;

  IF TRIM(l_works_order) <> TRIM(l_lot_no) THEN
    RAISE_APPLICATION_ERROR(-20001, 'Not a main spin lot');
  END IF;

  IF UPPER(TRIM(l_status)) IN ('OK', 'DD') THEN
    RAISE_APPLICATION_ERROR(-20001, 'Already closed: ' || TRIM(l_status));
  END IF;

  -- M_PARAM date window
  BEGIN
    SELECT TO_DATE(SUBSTR(TRIM(descr), 1, 8), 'DD-MON-YY'),
           TO_DATE(SUBSTR(TRIM(descr), 9, 8), 'DD-MON-YY')
      INTO l_date_from, l_date_to
      FROM wool.m_param
     WHERE TRIM(m_key) = 'DATE';

    IF l_date_del NOT BETWEEN l_date_from AND l_date_to THEN
      RAISE_APPLICATION_ERROR(-20001, 'INVALID DATE (M_PARAM window)');
    END IF;
    DBMS_OUTPUT.put_line('Date OK: ' || TO_CHAR(l_date_del, 'DD-MON-YY'));
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.put_line('WARN: M_PARAM date parse failed — ' || SQLERRM);
      DBMS_OUTPUT.put_line('      Continuing with SYSDATE (fix format in proc)');
  END;

  -- LV-MCODE from WIP_HDR backward (02xx)
  BEGIN
    SELECT TRIM(mcode)
      INTO l_mcode
      FROM (
            SELECT TRIM(mcode) AS mcode
              FROM wool.wip_hdr
             WHERE TRIM(works_order) = c_wo
               AND TRIM(mcode) LIKE '02%'
             ORDER BY mcode DESC
           )
     WHERE ROWNUM = 1;
    DBMS_OUTPUT.put_line('LV-MCODE from WIP = [' || l_mcode || ']');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_mcode := NULL;
      DBMS_OUTPUT.put_line('LV-MCODE: no WIP 02xx — keep existing MCODE');
      SELECT TRIM(mcode) INTO l_mcode FROM wool.prod_lot WHERE lot_id = l_lot_id;
  END;

  SAVEPOINT inv700_close_test;

  -- 1) Main PROD_LOT
  UPDATE wool.prod_lot
     SET status   = 'OK',
         date_del = l_date_del,
         mcode    = NVL(l_mcode, mcode)
   WHERE lot_id = l_lot_id;
  DBMS_OUTPUT.put_line('Updated main PROD_LOT: ' || SQL%ROWCOUNT);

  -- 2) WIP_HDR cascade
  UPDATE wool.wip_hdr
     SET status = 'OK'
   WHERE TRIM(works_order) = c_wo
     AND TRIM(status) NOT IN ('OK');
  DBMS_OUTPUT.put_line('Updated WIP_HDR: ' || SQL%ROWCOUNT);

  -- 3) D_BLENDHDR cascade
  UPDATE wool.d_blendhdr
     SET status = 'OK'
   WHERE TRIM(works_order) = c_wo
     AND TRIM(status) NOT IN ('OK');
  DBMS_OUTPUT.put_line('Updated D_BLENDHDR: ' || SQL%ROWCOUNT);

  -- 4) ORD_SHIP
  UPDATE wool.ord_ship
     SET status = 'OK'
   WHERE TRIM(lot_no) = c_wo
     AND TRIM(status) NOT IN ('OK');
  DBMS_OUTPUT.put_line('Updated ORD_SHIP: ' || SQL%ROWCOUNT);

  -- 5) Related PROD_LOT (SC-INV700: works_order = main lot_no, exclude main)
  UPDATE wool.prod_lot
     SET status   = 'OK',
         mcode    = NVL(l_mcode, mcode),
         date_del = l_date_del,
         kgs_1    = CASE WHEN TRIM(yarn_flg) LIKE '1%' THEN 0 ELSE kgs_1 END
   WHERE TRIM(works_order) = TRIM(l_lot_no)
     AND TRIM(lot_no) <> TRIM(l_lot_no)
     AND TRIM(status) NOT IN ('OK');
  DBMS_OUTPUT.put_line('Updated related PROD_LOT: ' || SQL%ROWCOUNT);

  -- Snapshot after updates
  SELECT COUNT(*)
    INTO l_cnt
    FROM wool.prod_lot
   WHERE TRIM(lot_no) = c_wo
     AND TRIM(status) = 'OK';
  DBMS_OUTPUT.put_line('Main lot status OK: ' || l_cnt);

  ROLLBACK TO inv700_close_test;
  DBMS_OUTPUT.put_line('=== ROLLBACK done — no data changed ===');
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO inv700_close_test;
    DBMS_OUTPUT.put_line('ERROR: ' || SQLERRM);
    RAISE;
END;
/

-- =============================================================================
-- 12) Compare binôme close_spin_lot (optional — uses COMMIT!)
--     Only run on disposable lot OR after section 11 rollback confirmed.
--     Comment out if unsure.
-- =============================================================================
/*
PROMPT === 12) SCT_PRD.close_spin_lot (COMMITS — TEST only) ===
DECLARE
  l_lot_id wool.prod_lot.lot_id%TYPE;
BEGIN
  SELECT lot_id
    INTO l_lot_id
    FROM wool.prod_lot
   WHERE TRIM(lot_no) = TRIM('&p_works_order')
     AND TRIM(works_order) = TRIM('&p_works_order');

  fsm.sct_prd.close_spin_lot(p_lot_id => l_lot_id);
  DBMS_OUTPUT.put_line('close_spin_lot OK lot_id=' || l_lot_id);
  ROLLBACK;  -- only if autocommit off in Toad
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.put_line('close_spin_lot ERR: ' || SQLERRM);
    ROLLBACK;
END;
/
*/

PROMPT === DONE ===
PROMPT Paste back: sections 1, 3, 4/4b, 5b, 7, 8, 9, 11 (DBMS Output)
