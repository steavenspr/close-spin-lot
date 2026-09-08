#!/usr/bin/env python3
"""Patch APEX page 51 export with page51.js and page51_inline.css."""

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def to_apex_varchar2_block(content: str) -> str:
    """Convert file content to wwv_flow_t_varchar2 join lines."""
    out = []
    for line in content.splitlines():
        # Normalize em-dash for APEX export compatibility
        line = line.replace("\u2014", "-")
        escaped = line.replace("'", "''")
        out.append(f"'{escaped}',")
    if out:
        out[-1] = out[-1].rstrip(",")
    return "\n".join(out)


def replace_apex_clob(sql: str, param: str, new_body: str, next_marker: str) -> str:
    pattern = (
        rf"(,{re.escape(param)}=>wwv_flow_string\.join\(wwv_flow_t_varchar2\(\n)"
        rf"(.*?)"
        rf"(\n,{re.escape(next_marker)}=>)"
    )
    block = to_apex_varchar2_block(new_body)
    repl = rf"\1{block}\3"
    new_sql, n = re.subn(pattern, repl, sql, count=1, flags=re.DOTALL)
    if n != 1:
        raise RuntimeError(f"Could not replace {param} (matches={n})")
    return new_sql


def main() -> None:
    src = Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT / "apex" / "f1400_page_51.sql"
    dst = Path(sys.argv[2]) if len(sys.argv) > 2 else src

    js = (ROOT / "apex" / "page51.js").read_text(encoding="utf-8")
    css = (ROOT / "apex" / "page51_inline.css").read_text(encoding="utf-8")

    sql = src.read_text(encoding="utf-8")
    sql = replace_apex_clob(sql, "p_javascript_code", js, "p_inline_css")
    sql = replace_apex_clob(sql, "p_inline_css", css, "p_page_template_options")

    dst.write_text(sql, encoding="utf-8", newline="\n")
    print(f"Patched: {dst}")


if __name__ == "__main__":
    main()
