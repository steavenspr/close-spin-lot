/* Page 90 — Close SPIN-LOT — APEX JS (RGN_P90_JS) */

var inv700 = {
  filter: "OPEN",
  lots: [],
  selectedWo: null,
  lotData: null,
  phase: "idle",
  closingTimer: null,
};

function inv700Init() {
  inv700BindEvents();
  var search = inv700Val("P90_SEARCH");
  if (search) {
    inv700Search();
  }
}

function inv700BindEvents() {
  $("#inv700-btn-load").on("click", inv700Search);
  $("#P90_SEARCH").on("keydown", function (e) {
    if (e.key === "Enter") inv700Search();
  });
  $("#inv700-filter-open").on("click", function () { inv700SetFilter("OPEN"); });
  $("#inv700-filter-all").on("click", function () { inv700SetFilter("ALL"); });
  $("#inv700-lot-list-body").on("click", ".inv700-lot-row", function () {
    inv700SelectLot($(this).data("works-order"));
  });
  $("#inv700-btn-close").on("click", inv700ConfirmClose);
  $("#inv700-btn-clear").on("click", inv700ClearSelection);
}

function inv700Val(item) {
  return ($v(item) || "").trim();
}

function inv700SetFilter(f) {
  inv700.filter = f;
  $("#inv700-filter-open, #inv700-filter-all").removeClass("is-active");
  $("#inv700-filter-" + f.toLowerCase()).addClass("is-active");
  apex.item("P90_FILTER").setValue(f);
  inv700Search();
}

function inv700Search() {
  var q = inv700Val("P90_SEARCH");
  apex.server.process("SEARCH_LOTS", {
    x01: q,
    x02: inv700.filter,
  }, {
    dataType: "json",
    success: function (data) {
      inv700.lots = data.lots || [];
      inv700RenderList();
      if (inv700.lots.length === 1) {
        inv700SelectLot(inv700.lots[0].worksOrder);
      } else if (inv700.lots.length === 0) {
        inv700ClearDetail();
        apex.message.showPageSuccess("No lots found.");
      }
    },
    error: inv700AjaxError,
  });
}

function inv700SelectLot(worksOrder) {
  if (!worksOrder || inv700.phase === "closing") return;

  apex.server.process("LOAD_LOT", {
    x01: worksOrder,
  }, {
    dataType: "json",
    success: function (data) {
      if (!data || !data.lot) {
        apex.message.alert("Lot not found or not a main spin lot.");
        return;
      }
      inv700.selectedWo = worksOrder;
      inv700.lotData = data;
      inv700.phase = data.lot.isClosed ? "closed" : "loaded";
      apex.item("P90_WORKS_ORDER").setValue(worksOrder);
      apex.item("P90_LOT_ID").setValue(data.lot.lotId);
      inv700RenderList();
      inv700RenderDetail();
      inv700UpdateActionBar();
    },
    error: inv700AjaxError,
  });
}

function inv700RenderList() {
  var $body = $("#inv700-lot-list-body");
  var $ws = $("#inv700-workspace");
  var n = inv700.lots.length;

  $("#inv700-lot-count").text(n + " lot" + (n !== 1 ? "s" : ""));

  if (n === 0) {
    $body.empty();
    $ws.removeClass("inv700-workspace--multi");
    return;
  }

  $ws.toggleClass("inv700-workspace--multi", n > 1);

  var html = inv700.lots.map(function (row) {
    var sel = row.worksOrder === inv700.selectedWo ? " is-selected" : "";
    var stClass = row.isClosed ? "inv700-lot-row__status--ok" : "inv700-lot-row__status--sc";
    var st = row.isClosed ? "OK" : "SC";
    return (
      '<button type="button" class="inv700-lot-row' + sel + '" data-works-order="' +
      inv700Esc(row.worksOrder) + '">' +
      '<div class="inv700-lot-row__top">' +
      '<span class="inv700-lot-row__no">' + inv700Esc(row.worksOrder) + "</span>" +
      '<span class="inv700-lot-row__status ' + stClass + '">' + st + "</span>" +
      "</div>" +
      '<div class="inv700-lot-row__sub">' +
      inv700Esc(row.yarnFlg) + " · " + inv700Esc(row.mcode) + " · " + inv700Esc(row.dateSch || "") +
      "</div></button>"
    );
  }).join("");

  $body.html(html);
}

function inv700RenderDetail() {
  var d = inv700.lotData;
  if (!d || !d.lot) {
    inv700ClearDetail();
    return;
  }

  var lot = d.lot;
  var closed = lot.isClosed || inv700.phase === "closed";

  $("#inv700-detail-empty").addClass("inv700-hidden");
  $("#inv700-detail-content").removeClass("inv700-hidden");
  $("#inv700-action-bar").removeClass("inv700-hidden");

  $("#inv700-lot-no").text(lot.lotNo);
  $("#inv700-lot-id").text("lot_id " + lot.lotId);
  $("#inv700-product").text(lot.productNo);
  $("#inv700-yarn").text(lot.yarnFlg);
  $("#inv700-mcode").text(lot.mcode);
  $("#inv700-date-sch").text(lot.dateSch || "—");
  $("#inv700-qty-ord").text(inv700Fmt(lot.qtyOrd, 1));
  $("#inv700-qty-rec").text(inv700Fmt(lot.qtyRec));
  $("#inv700-qoh").text(inv700Fmt(lot.qoh));
  $("#inv700-kgs1").text(inv700Fmt(lot.kgs1));
  $("#inv700-kgs2").text(inv700Fmt(lot.kgs2));

  var $hero = $("#inv700-lot-hero");
  $hero.toggleClass("is-closed", closed);
  $("#inv700-stamp").toggleClass("inv700-hidden", !closed);

  inv700SetStatus(closed ? "closed" : inv700.phase === "closing" ? "closing" : "open");

  var impact = (d.impact || []).filter(function (s) { return s.count > 0; });
  var total = impact.reduce(function (n, s) { return n + s.count; }, 0);
  $("#inv700-impact-summary").text(total + " record" + (total !== 1 ? "s" : "") + " will update");

  var listHtml = impact.map(function (s, i) {
    var done = closed || (inv700.phase === "closing" && i < inv700.closingStep);
    return (
      '<li class="inv700-impact-item' + (done ? " is-done" : "") + '">' +
      '<span class="inv700-impact-item__dot"></span>' +
      '<span class="inv700-impact-item__label">' + inv700Esc(s.label) + "</span>" +
      '<span class="inv700-impact-item__sub">' + s.count + " record" + (s.count !== 1 ? "s" : "") + "</span>" +
      (done ? '<span class="inv700-impact-item__done">Closed</span>' : "") +
      "</li>"
    );
  }).join("");
  $("#inv700-impact-list").html(listHtml);

  var pct = closed ? 100 : inv700.phase === "closing" ? (inv700.closingStep / impact.length) * 100 : 0;
  $("#inv700-progress").toggleClass("inv700-hidden", inv700.phase === "idle" || inv700.phase === "loaded");
  $("#inv700-progress-bar").css("width", pct + "%").toggleClass("is-closed", closed);
}

function inv700UpdateActionBar() {
  var lot = inv700.lotData && inv700.lotData.lot;
  if (!lot) return;

  var closed = lot.isClosed || inv700.phase === "closed";
  $("#inv700-action-lot").text(lot.lotNo);
  $("#inv700-action-msg").text(
    closed ? "Archived" : inv700.phase === "closing" ? "Closing in progress…" : "Ready to close"
  );
  $("#inv700-btn-close")
    .prop("disabled", closed || inv700.phase === "closing")
    .text(closed ? "Already closed" : inv700.phase === "closing" ? "Closing…" : "Close SPIN-LOT");
}

function inv700SetStatus(mode) {
  var $p = $("#inv700-status");
  $p.removeClass("inv700-hidden inv700-pill--open inv700-pill--closing inv700-pill--closed");
  if (mode === "open") {
    $p.addClass("inv700-pill--open").text("Open");
  } else if (mode === "closing") {
    $p.addClass("inv700-pill--closing").text("Closing…");
  } else if (mode === "closed") {
    $p.addClass("inv700-pill--closed").text("Closed");
  } else {
    $p.addClass("inv700-hidden");
  }
}

function inv700ConfirmClose() {
  var lotId = inv700Val("P90_LOT_ID");
  if (!lotId) return;

  apex.message.confirm("Close this SPIN-LOT? This cannot be undone from this page.", function (ok) {
    if (!ok) return;
    inv700RunClose(lotId);
  });
}

function inv700RunClose(lotId) {
  inv700.phase = "closing";
  inv700.closingStep = 0;
  var impact = (inv700.lotData.impact || []).filter(function (s) { return s.count > 0; });
  inv700SetStatus("closing");
  inv700UpdateActionBar();
  inv700RenderDetail();

  var i = 0;
  clearInterval(inv700.closingTimer);
  inv700.closingTimer = setInterval(function () {
    i += 1;
    inv700.closingStep = i;
    inv700RenderDetail();
    if (i >= impact.length) {
      clearInterval(inv700.closingTimer);
    }
  }, 580);

  apex.server.process("CLOSE_LOT", { x01: lotId }, {
    dataType: "json",
    success: function (data) {
      clearInterval(inv700.closingTimer);
      if (data.success) {
        inv700.phase = "closed";
        if (inv700.lotData && inv700.lotData.lot) {
          inv700.lotData.lot.isClosed = true;
        }
        inv700.closingStep = impact.length;
        inv700RenderDetail();
        inv700UpdateActionBar();
        inv700Search();
        apex.message.showPageSuccess(data.message || "SPIN-LOT closed.");
      } else {
        inv700.phase = "loaded";
        inv700RenderDetail();
        inv700UpdateActionBar();
        apex.message.alert(data.message || "Close failed.");
      }
    },
    error: function (xhr, status, err) {
      clearInterval(inv700.closingTimer);
      inv700.phase = "loaded";
      inv700RenderDetail();
      inv700UpdateActionBar();
      inv700AjaxError(xhr, status, err);
    },
  });
}

function inv700ClearSelection() {
  inv700.selectedWo = null;
  inv700.lotData = null;
  inv700.phase = "idle";
  inv700ClearDetail();
  inv700RenderList();
  inv700SetStatus(null);
}

function inv700ClearDetail() {
  $("#inv700-detail-content").addClass("inv700-hidden");
  $("#inv700-detail-empty").removeClass("inv700-hidden");
  $("#inv700-action-bar").addClass("inv700-hidden");
  apex.item("P90_LOT_ID").setValue("");
  apex.item("P90_WORKS_ORDER").setValue("");
}

function inv700Fmt(n, dec) {
  if (n == null || n === "") return "—";
  var x = Number(n);
  if (isNaN(x)) return n;
  return dec ? x.toFixed(dec) : x.toLocaleString("en-US");
}

function inv700Esc(s) {
  return String(s == null ? "" : s)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/"/g, "&quot;");
}

function inv700AjaxError(xhr, status, err) {
  var msg = (xhr.responseJSON && xhr.responseJSON.message) || err || status || "Request failed";
  apex.message.alert(msg);
}
