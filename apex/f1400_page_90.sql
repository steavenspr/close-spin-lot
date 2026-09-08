prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- Oracle APEX export file
--
-- You should run this script using a SQL client connected to the database as
-- the owner (parsing schema) of the application or as a database user with the
-- APEX_ADMINISTRATOR_ROLE role.
--
-- This export file has been automatically generated. Modifying this file is not
-- supported by Oracle and can lead to unexpected application and/or instance
-- behavior now or in the future.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_imp.import_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>1601438889569217
,p_default_application_id=>1400
,p_default_id_offset=>4009255697527821
,p_default_owner=>'FSM'
);
end;
/
 
prompt APPLICATION 1400 - FSM - Planning
--
-- Application Export:
--   Application:     1400
--   Name:            FSM - Planning
--   Exported By:     ADMIN
--   Flashback:       0
--   Export Type:     Page Export
--   Manifest
--     PAGE: 90
--   Manifest End
--   Version:         24.2.0
--   Instance ID:     743301615293412
--

begin
null;
end;
/
prompt --application/pages/delete_00090
begin
wwv_flow_imp_page.remove_page (p_flow_id=>wwv_flow.g_flow_id, p_page_id=>90);
end;
/
prompt --application/pages/page_00090
begin
wwv_flow_imp_page.create_page(
 p_id=>90
,p_name=>'Spin Lot Main'
,p_alias=>'SPIN-LOT-MAIN'
,p_step_title=>'Spin Lot Main'
,p_autocomplete_on_off=>'OFF'
,p_javascript_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'/* Page 90 - Spin Lot Main - CLOSED!! stamp */',
'',
'function spin90IsClosedStatus(status) {',
'  var st = (status || "").trim().toUpperCase();',
'  return st === "OK" || st === "DD";',
'}',
'',
'function spin90UpdateClosedStamp() {',
'  var $region = $("#spin-lot-main");',
'  if (!$region.length) {',
'    return;',
'  }',
'',
'  if (!$("#spin90-closed-stamp").length) {',
'    $region.append(',
'      ''<div id="spin90-closed-stamp" class="spin90-closed-stamp spin90-hidden" aria-hidden="true">CLOSED!!</div>''',
'    );',
'  }',
'',
'  var closed = spin90IsClosedStatus($v("P90_STATUS"));',
'  $("#spin90-closed-stamp")',
'    .toggleClass("spin90-hidden", !closed)',
'    .attr("aria-hidden", closed ? "false" : "true");',
'  $region.toggleClass("spin90-is-closed", closed);',
'',
'  var $closeBtn = $("#CLOSE_SPIN_LOT");',
'  if ($closeBtn.length) {',
'    $closeBtn.prop("disabled", closed).toggleClass("u-disabled", closed);',
'  }',
'}',
'',
'apex.jQuery(function () {',
'  spin90UpdateClosedStamp();',
'});'))
,p_inline_css=>wwv_flow_string.join(wwv_flow_t_varchar2(
'/* ===== Page 90 - Spin Lot Main ===== */',
'.t-Body-contentInner{background:linear-gradient(180deg,#f4f7fb 0%,#e8eef5 100%);padding:20px 24px 40px;}',
'#spin-lot-main{border:0;border-radius:18px;overflow:hidden;background:#fff;box-shadow:0 12px 40px rgba(15,23,42,.08);}',
'#spin-lot-main>.t-Region-header{background:#0f2744;border:0;padding:16px 22px;}',
'#spin-lot-main .t-Region-title{color:#fff;font-size:1.02rem;font-weight:700;letter-spacing:.06em;text-transform:uppercase;}',
'#spin-lot-main .t-Region-headerIcon,.t-Region-headerIcon .t-Icon{display:none;}',
'#spin-lot-main .t-Region-body{padding:22px!important;background:#f8fafc;}',
'#spin-lot-main .t-Region-body>.container{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:14px;width:100%;max-width:none;}',
'#spin-lot-main .t-Region-body>.container>.row{display:contents;}',
'#spin-lot-main .t-Region-body .col{background:#fff;border:1px solid #e6edf5;border-radius:12px;padding:12px 14px 14px;min-width:0;display:flex;flex-direction:column;gap:8px;font-size:11px;font-weight:700;letter-spacing:.08em;text-transform:uppercase;'
||'color:#64748b;box-shadow:0 1px 0 rgba(15,23,42,.03);}',
'#spin-lot-main .display_only,#spin-lot-main .apex-item-text{font-size:15px;font-weight:650;letter-spacing:0;text-transform:none;color:#0f172a;min-height:28px;}',
'#spin-lot-main .apex-item-group--popup-lov{width:100%;display:flex;}',
'#spin-lot-main .popup_lov{flex:1;width:100%!important;border:1px solid #d6e0ea;border-radius:8px 0 0 8px;background:#fff;height:38px;box-shadow:none;}',
'#spin-lot-main .a-Button--popupLOV{height:38px;border:0;border-radius:0 8px 8px 0;background:#0f2744;}',
'#spin-lot-main .a-Button--popupLOV .a-Icon{color:#fff;}',
'#spin-lot-main{position:relative;}',
'.spin90-hidden{display:none!important;}',
'.spin90-closed-stamp{position:absolute;top:68px;right:22px;padding:7px 14px;border:2px solid #dc2626;color:#dc2626;font-family:ui-monospace,monospace;font-size:13px;font-weight:600;letter-spacing:.2em;'
||'transform:rotate(-3deg);z-index:20;background:rgba(255,255,255,.96);box-shadow:0 2px 8px rgba(220,38,38,.15);pointer-events:none;animation:spin90-stamp-in .55s cubic-bezier(.34,1.56,.64,1) both;}',
'@keyframes spin90-stamp-in{0%{transform:scale(2.2) rotate(-12deg);opacity:0}65%{transform:scale(.94) rotate(2deg);opacity:1}100%{transform:scale(1) rotate(-3deg);opacity:1}}',
'#spin-lot-main.spin90-is-closed .t-Region-body{background:#fff7f7;}',
'#spin-lot-main.spin90-is-closed #P90_STATUS{display:inline-flex;align-items:center;padding:4px 10px;border-radius:999px;background:#fef2f2;color:#dc2626;font-size:12px;font-weight:800;}',
'#spin-lot-main:not(.spin90-is-closed) #P90_STATUS{display:inline-flex;align-items:center;padding:4px 10px;border-radius:999px;background:#ecfdf5;color:#047857;font-size:12px;font-weight:800;}',
'#spin-lot-main .t-Region-buttons--bottom{background:#fff;border-top:1px solid #e6edf5;padding:14px 18px;}',
'#spin-lot-main .t-Region-buttons-right{display:flex;gap:8px;flex-wrap:wrap;justify-content:flex-end;}',
'#spin-lot-main input[type=button]{border:0;border-radius:10px;padding:10px 16px;font-weight:700;cursor:pointer;box-shadow:0 1px 2px rgba(15,23,42,.12);}',
'#spin-lot-main .t-Button--hot{background:#0f766e;color:#fff;}',
'#spin-lot-main .t-Button--warning{background:#c2410c;color:#fff;}',
'#spin-lot-main .t-Button--primary{background:#0f2744;color:#fff;}',
'@media (max-width:960px){#spin-lot-main .t-Region-body>.container{grid-template-columns:repeat(2,minmax(0,1fr));}}',
'@media (max-width:640px){#spin-lot-main .t-Region-body>.container{grid-template-columns:1fr;}}'))
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'16'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(90000000000000001)
,p_plug_name=>'Spin Lot'
,p_region_name=>'spin-lot-main'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>wwv_flow_imp.id(23091006266588914)
,p_plug_display_sequence=>10
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(90000000000000004)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(90000000000000001)
,p_button_name=>'LOAD_LOT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--hot'
,p_button_template_id=>wwv_flow_imp.id(11803259709492929)
,p_button_image_alt=>'Load lot'
,p_button_position=>'CREATE'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(90000000000000005)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(90000000000000001)
,p_button_name=>'CLOSE_SPIN_LOT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--warning'
,p_button_template_id=>wwv_flow_imp.id(11803259709492929)
,p_button_image_alt=>'Close spin lot'
,p_button_position=>'CREATE'
,p_button_condition=>':P90_LOT_ID IS NOT NULL'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(90000000000000006)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(90000000000000001)
,p_button_name=>'SPLIT_PRODUCT'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#:t-Button--primary'
,p_button_template_id=>wwv_flow_imp.id(11803259709492929)
,p_button_image_alt=>'Split product'
,p_button_position=>'CREATE'
,p_button_redirect_url=>'f?p=&APP_ID.:95:&SESSION.::&DEBUG.:95:P95_WORKS_ORDER,P95_PARENT_LOT_ID:&P90_WORKS_ORDER.,&P90_LOT_ID.'
,p_button_condition=>':P90_LOT_ID IS NOT NULL'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(90000000000000007)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(90000000000000001)
,p_button_name=>'BAGS_INQUIRY'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#:t-Button--primary'
,p_button_template_id=>wwv_flow_imp.id(11803259709492929)
,p_button_image_alt=>'Bags inquiry'
,p_button_position=>'CREATE'
,p_button_redirect_url=>'f?p=&APP_ID.:100:&SESSION.::&DEBUG.:100:P100_LOT_ID:&P90_LOT_ID.'
,p_button_condition=>':P90_LOT_ID IS NOT NULL'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(90000000000000010)
,p_name=>'P90_WORKS_ORDER'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(90000000000000001)
,p_prompt=>'WORKS-ORDER'
,p_display_as=>'NATIVE_POPUP_LOV'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT DISTINCT TRIM(works_order) d, TRIM(works_order) r',
'  FROM prod_lot',
' WHERE TRIM(works_order) = TRIM(lot_no)',
' ORDER BY 1'))
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- Select main spin lot -'
,p_cSize=>30
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'case_sensitive', 'N',
  'display_as', 'POPUP',
  'fetch_on_search', 'N',
  'initial_fetch', 'FIRST_ROWSET',
  'manual_entry', 'N',
  'match_type', 'CONTAINS',
  'min_chars', '0')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(90000000000000011)
,p_name=>'P90_LOT_ID'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(90000000000000001)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(90000000000000012)
,p_name=>'P90_LOT_NO'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(90000000000000001)
,p_prompt=>'LOT#'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(90000000000000013)
,p_name=>'P90_PRODUCT_NO'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(90000000000000001)
,p_prompt=>'PRODUCT#'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(90000000000000014)
,p_name=>'P90_YARN_FLG'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(90000000000000001)
,p_prompt=>'YARN-FLG'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(90000000000000015)
,p_name=>'P90_DATE_SCH'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(90000000000000001)
,p_prompt=>'DATE-SCH'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(90000000000000016)
,p_name=>'P90_DATE_DEL'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(90000000000000001)
,p_prompt=>'DEL. DATE'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(90000000000000017)
,p_name=>'P90_QOH'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(90000000000000001)
,p_prompt=>'QOH'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(90000000000000018)
,p_name=>'P90_INPUT_WT'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(90000000000000001)
,p_prompt=>'INPUT WT'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(90000000000000019)
,p_name=>'P90_QTY_REC'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(90000000000000001)
,p_prompt=>'QTY-REC'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(90000000000000020)
,p_name=>'P90_QC1'
,p_item_sequence=>110
,p_item_plug_id=>wwv_flow_imp.id(90000000000000001)
,p_prompt=>'QC LAB'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(90000000000000021)
,p_name=>'P90_STATUS'
,p_item_sequence=>120
,p_item_plug_id=>wwv_flow_imp.id(90000000000000001)
,p_prompt=>'STATUS'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(90000000000000022)
,p_name=>'P90_QTY_ORD'
,p_item_sequence=>130
,p_item_plug_id=>wwv_flow_imp.id(90000000000000001)
,p_prompt=>'ORDERED'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(90000000000000031)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Close spin lot'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'   SCT_PRD.close_spin_lot(:P90_LOT_ID);',
'EXCEPTION',
'   WHEN OTHERS THEN',
'      apex_error.add_error(',
'         p_message          => SQLERRM,',
'         p_display_location => apex_error.c_inline_in_notification);',
'      RAISE;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_process_error_message=>'Unable to close the spin lot: #SQLERRM_TEXT#'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(90000000000000005)
,p_internal_uid=>90000000000000031
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(90000000000000030)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load main spin lot'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'   l_rec SCT_PRD.t_spin_lot_rec;',
'BEGIN',
'   SCT_PRD.load_main_spin_lot(:P90_WORKS_ORDER, l_rec);',
'',
'   :P90_LOT_ID     := l_rec.lot_id;',
'   :P90_LOT_NO     := l_rec.lot_no;',
'   :P90_PRODUCT_NO := l_rec.product_no;',
'   :P90_YARN_FLG   := l_rec.yarn_flg;',
'   :P90_DATE_SCH   := l_rec.date_sch;',
'   :P90_DATE_DEL   := l_rec.date_del;',
'   :P90_QOH        := l_rec.qoh;',
'   :P90_INPUT_WT   := l_rec.input_wt;',
'   :P90_QTY_REC    := l_rec.qty_rec;',
'   :P90_QC1        := l_rec.qc1;',
'   :P90_STATUS     := l_rec.status;',
'   :P90_QTY_ORD    := l_rec.qty_ord;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>90000000000000030
);
end;
/
prompt --application/end_environment
begin
wwv_flow_imp.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false)
);
commit;
end;
/
set verify on feedback on define on
prompt  ...done
