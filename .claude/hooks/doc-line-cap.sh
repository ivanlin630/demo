#!/usr/bin/env bash
# ★★★必讀區行數上限【機械檢查】（2026-08-25 HOLD 批 #4，用戶定 WHAT：不可只是約定）
#   用戶原話引出的問題：「以後會讀對／記對嗎」——★瘦身若只靠約定，三個月後必回肥。
#
# ★★兩層上限，缺一都會被繞過：
#   ①單檔上限      —— 防單一檔失控
#   ★②per-role 開場合計 —— ★★★防「把肥擠到沒設限的那個檔」
#      （血證 2026-08-25：我把 invariants 的 176 行搬進 01_architect，
#       ★若只管 invariants 的行數，我可以「達標」而角色開場負擔【一行都沒少】。）
#
# warn-only：★永不阻擋（同既有兩條紀律：只警告絕不阻擋、fail-open）。
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)" || exit 0
n() { [ -f "$1" ] && wc -l < "$1" | tr -d ' ' || echo 0; }

CAP_CLAUDE=100; CAP_INV=150; CAP_ROLES=80; CAP_ROLE_DOC=200; CAP_PER_ROLE=500

c_claude=$(n CLAUDE.md); c_inv=$(n docs/invariants.md); c_roles=$(n docs/process/00_roles.md)
warn=0; out=""
_w() { warn=$((warn+1)); out="${out}
  ★$1"; }

[ "$c_claude" -gt "$CAP_CLAUDE" ] && _w "CLAUDE.md            ${c_claude} > ${CAP_CLAUDE}"
[ "$c_inv"    -gt "$CAP_INV"    ] && _w "invariants.md        ${c_inv} > ${CAP_INV}"
[ "$c_roles"  -gt "$CAP_ROLES"  ] && _w "00_roles.md          ${c_roles} > ${CAP_ROLES}"

# 角色 → 它開場要讀的那份 process doc
declare -A ROLEDOC=(
  [systems]=docs/process/01_architect.md      [reviewer]=docs/process/02_reviewer.md
  [implementer]=docs/process/03_implementer.md [measurer]=docs/process/03b_measurer.md
  [qa]=docs/process/04_qa.md                   [blueprint]=docs/process/00_roles.md
)
base=$(( c_claude + c_inv + c_roles ))
for role in "${!ROLEDOC[@]}"; do
  d="${ROLEDOC[$role]}"; c=$(n "$d")
  [ "$c" -gt "$CAP_ROLE_DOC" ] && _w "$(printf '%-20s' "$(basename "$d")")${c} > ${CAP_ROLE_DOC}  （${role}）"
  tot=$(( base + c ))
  [ "$tot" -gt "$CAP_PER_ROLE" ] && _w "$(printf '%-20s' "${role} 開場合計")${tot} > ${CAP_PER_ROLE}  ★（CLAUDE+invariants+00_roles+自己那份）"
done

if [ "$warn" -gt 0 ]; then
  echo "[doc-cap] 🟡 必讀區超限 ${warn} 項（warn-only，不阻擋）：${out}"
  echo "[doc-cap] ★上限不是品味問題：★★超限＝【開場就讀不完】＝規則存在但不會被用到。"
  echo "[doc-cap] ★處置＝搬到【按需讀】的地方（domain doc／spec／memory），不是刪掉。"
else
  echo "[doc-cap] ✅ 必讀區全部在上限內"
fi
exit 0
