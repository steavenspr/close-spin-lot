/* Page 90 — Spin Lot Main — CLOSED!! stamp when status OK/DD */

function spin90IsClosedStatus(status) {
  var st = (status || "").trim().toUpperCase();
  return st === "OK" || st === "DD";
}

function spin90UpdateClosedStamp() {
  var $region = $("#spin-lot-main");
  if (!$region.length) {
    return;
  }

  if (!$("#spin90-closed-stamp").length) {
    $region.append(
      '<div id="spin90-closed-stamp" class="spin90-closed-stamp spin90-hidden" aria-hidden="true">CLOSED!!</div>'
    );
  }

  var closed = spin90IsClosedStatus($v("P90_STATUS"));
  $("#spin90-closed-stamp")
    .toggleClass("spin90-hidden", !closed)
    .attr("aria-hidden", closed ? "false" : "true");
  $region.toggleClass("spin90-is-closed", closed);

  var $closeBtn = $("#CLOSE_SPIN_LOT");
  if ($closeBtn.length) {
    $closeBtn.prop("disabled", closed).toggleClass("u-disabled", closed);
  }
}

apex.jQuery(function () {
  spin90UpdateClosedStamp();
});
