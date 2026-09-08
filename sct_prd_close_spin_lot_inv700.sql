-- =============================================================================
-- FSM.SCT_PRD — add close_spin_lot_inv700 (SC-INV700, separate from close_spin_lot)
-- Validated TEST 2026-09-01 on lot 2608-0027
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1) PACKAGE SPEC — add under "Page 90 - Spin Lot Main", after close_spin_lot
-- -----------------------------------------------------------------------------

   PROCEDURE close_spin_lot_inv700 (
      p_lot_id IN prod_lot.lot_id%TYPE
   );


-- -----------------------------------------------------------------------------
-- 2) PACKAGE BODY — add anywhere before END SCT_PRD (e.g. after close_spin_lot)
-- -----------------------------------------------------------------------------

   PROCEDURE close_spin_lot_inv700 (
      p_lot_id IN prod_lot.lot_id%TYPE
   ) IS
      l_works_order prod_lot.works_order%TYPE;
      l_lot_no      prod_lot.lot_no%TYPE;
      l_status      prod_lot.status%TYPE;
      l_mcode       prod_lot.mcode%TYPE;
      l_date_del    DATE := TRUNC(SYSDATE);
      l_date_from   DATE;
      l_date_to     DATE;
   BEGIN
      IF p_lot_id IS NULL THEN
         raise_application_error(-20001, 'Select a main spin lot first.');
      END IF;

      SELECT works_order, lot_no, status, mcode
        INTO l_works_order, l_lot_no, l_status, l_mcode
        FROM prod_lot
       WHERE lot_id = p_lot_id
         FOR UPDATE;

      IF TRIM(l_works_order) <> TRIM(l_lot_no) THEN
         raise_application_error(-20001, 'Only the main spin lot can be closed.');
      END IF;

      IF UPPER(TRIM(l_status)) IN ('OK', 'DD') THEN
         raise_application_error(-20001, 'This spin lot is already closed.');
      END IF;

      BEGIN
         SELECT TO_DATE(SUBSTR(TRIM(descr), 1, 8), 'YYYYMMDD'),
                TO_DATE(SUBSTR(TRIM(descr), 9, 8), 'YYYYMMDD')
           INTO l_date_from, l_date_to
           FROM m_param
          WHERE TRIM(m_key) = 'DATE';
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_application_error(-20001, 'INVALID DATE');
      END;

      IF l_date_del NOT BETWEEN l_date_from AND l_date_to THEN
         raise_application_error(-20001, 'INVALID DATE');
      END IF;

      BEGIN
         SELECT TRIM(mcode)
           INTO l_mcode
           FROM (
              SELECT TRIM(mcode) AS mcode
                FROM wip_hdr
               WHERE TRIM(works_order) = TRIM(l_works_order)
                 AND TRIM(mcode) LIKE '02%'
               ORDER BY mcode DESC
           )
          WHERE ROWNUM = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END;

      UPDATE prod_lot
         SET status   = 'OK',
             date_del = l_date_del,
             mcode    = NVL(l_mcode, mcode)
       WHERE lot_id = p_lot_id;

      UPDATE wip_hdr
         SET status = 'OK'
       WHERE TRIM(works_order) = TRIM(l_works_order)
         AND TRIM(status) <> 'OK';

      UPDATE d_blendhdr
         SET status = 'OK'
       WHERE TRIM(works_order) = TRIM(l_works_order)
         AND TRIM(status) <> 'OK';

      UPDATE ord_ship
         SET status = 'OK'
       WHERE TRIM(lot_no) = TRIM(l_lot_no)
         AND TRIM(status) <> 'OK';

      UPDATE prod_lot
         SET status   = 'OK',
             mcode    = NVL(l_mcode, mcode),
             date_del = l_date_del,
             kgs_1    = CASE
                            WHEN TRIM(yarn_flg) LIKE '1%' THEN 0
                            ELSE kgs_1
                         END
       WHERE TRIM(works_order) = TRIM(l_works_order)
         AND TRIM(lot_no) <> TRIM(l_lot_no)
         AND TRIM(status) <> 'OK';

   END close_spin_lot_inv700;
