-- Test close_spin_lot_inv700 — SAVEPOINT + ROLLBACK
SET SERVEROUTPUT ON SIZE UNLIMITED;

DECLARE
  c_wo     CONSTANT VARCHAR2(10) := '2608-0027';
  l_rec    fsm.sct_prd.t_spin_lot_rec;
  l_status prod_lot.status%TYPE;
BEGIN
  fsm.sct_prd.load_main_spin_lot(c_wo, l_rec);

  IF l_rec.lot_id IS NULL THEN
    raise_application_error(-20001, 'Lot not found: ' || c_wo);
  END IF;

  DBMS_OUTPUT.put_line('Before — lot_id=' || l_rec.lot_id
    || ' status=[' || TRIM(l_rec.status) || ']');

  SAVEPOINT sp_test;

  fsm.sct_prd.close_spin_lot_inv700(l_rec.lot_id);

  SELECT TRIM(status) INTO l_status FROM prod_lot WHERE lot_id = l_rec.lot_id;

  DBMS_OUTPUT.put_line('After  — main status=[' || l_status || ']');
  DBMS_OUTPUT.put_line('D_BLENDHDR OK: '
    || (SELECT COUNT(*) FROM d_blendhdr
        WHERE TRIM(works_order) = c_wo AND TRIM(status) = 'OK'));
  DBMS_OUTPUT.put_line('ORD_SHIP OK: '
    || (SELECT COUNT(*) FROM ord_ship
        WHERE TRIM(lot_no) = c_wo AND TRIM(status) = 'OK'));

  ROLLBACK TO sp_test;
  DBMS_OUTPUT.put_line('ROLLBACK OK');
END;
/
