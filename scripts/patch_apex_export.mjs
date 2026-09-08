/**
 * Patch APEX page 51 export with page51.js and page51_inline.css
 * Usage: node patch_apex_export.mjs <src.sql> <dst.sql>
 */
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, "..");

function toApexLines(content) {
  const lines = content.replace(/\r\n/g, "\n").split("\n");
  return lines
    .map((line, i) => {
      const normalized = line.replace(/\u2014/g, "-").replace(/'/g, "''");
      const suffix = i === lines.length - 1 ? "" : ",";
      return `'${normalized}'${suffix}`;
    })
    .join("\n");
}

function replaceApexClob(sql, param, newBody, nextMarker) {
  const pattern = new RegExp(
    `(,${param.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}=>wwv_flow_string\\.join\\(wwv_flow_t_varchar2\\(\\n)` +
      `[\\s\\S]*?` +
      `(\\n,${nextMarker.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}=>)`,
    "m"
  );
  const block = toApexLines(newBody);
  const next = sql.replace(pattern, `$1${block}$2`);
  if (next === sql) throw new Error(`Could not replace ${param}`);
  return next;
}

const src = process.argv[2] || path.join(ROOT, "apex", "f1400_page_51.sql");
const dst = process.argv[3] || src;

const js = fs.readFileSync(path.join(ROOT, "apex", "page51.js"), "utf8");
const css = fs.readFileSync(path.join(ROOT, "apex", "page51_inline.css"), "utf8");
let sql = fs.readFileSync(src, "utf8");

sql = replaceApexClob(sql, "p_javascript_code", js, "p_inline_css");
sql = replaceApexClob(sql, "p_inline_css", css, "p_page_template_options");

fs.writeFileSync(dst, sql, "utf8");
console.log(`Patched: ${dst}`);
