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
# ★★★節級保護白名單（2026-08-25 血證）：標題含「觸發式必讀」「憲法」「governing invariant」
#   「鐵律」「不可妥協」的節 ★不得被任何切刀移走 —— 血證：切刀把剛加的「觸發式必讀」
#   當成最肥的節切進 detail，★而那張表移到 detail 就完全失去意義（它的用途是「在動手那一刻看見入口」）。
#   ⇒ ★★機械切刀不知道哪一節【必須完整】，所以保護必須寫成【標記】,不能靠人記得。
#
# warn-only：★永不阻擋（同既有兩條紀律：只警告絕不阻擋、fail-open）。
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)" || exit 0
n() { [ -f "$1" ] && wc -l < "$1" | tr -d ' ' || echo 0; }

# ★★★上限數字的來源（2026-08-25 訂，★不是拍腦袋 —— 是【先砍到極限，才知道硬底在哪】）
#   ★實測硬底：`CLAUDE.md 92` ＋ `invariants 184`（★只剩憲法級 ＋ 索引表）＋ `00_roles 135` ＝ **411**
#     ⇒ ★★`invariants` 我判【不該再壓】：索引表的價值正是「知道有這一條」，壓掉它＝條目變隱形。
#   ★★所以上限訂在【略緊於現況】，逼出持續改善，而不是【照現況訂】（那等於沒有拘束力）。
#   ★★★也不因為達不到就放寬 —— ★我第一版訂 500，實測最大 610；
#     ★★正確反應是「先砍到 610」再談數字，不是先把 500 改成 700。
CAP_CLAUDE=100; CAP_INV=190; CAP_ROLES=140; CAP_ROLE_DOC=200; CAP_PER_ROLE=600

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

# ★★★第二層檢查：**未閉合 code fence**（2026-08-27 systems 立，血證見下）
#   ★病：把節「壓縮進 detail」的動作會截在 ``` 中間 —— 留下孤兒【開】或孤兒【閉】。
#     孤兒【開】⇒ 從它到檔尾整段 render 成一坨 code；孤兒【閉】⇒ 位移整條 parity。
#   ★★為什麼會拖這麼久沒人發現：**我們讀這些檔用 `cat`／`grep`／`sed`，而它壞掉的方式只在 render 時可見**
#     —— ⇒ ★★★這種壞法對【我們的閱讀方式】天生隱形，所以只能機械檢查，不能靠「有人會注意到」。
#   ★血證 2026-08-27：母體 35 檔裡 **7 檔** parity 是奇數，★全部集中在 `docs/process/`
#     （＝正好是動過「壓縮進 detail」手術的那批），domain doc 零命中。
#   ★★同一份 handback 模板甚至被切成兩半住在兩個檔（`03_implementer` 有尾、它的 cases 有頭）。
_fence_pop() { ls docs/*.md docs/process/*.md docs/process/detail/*.md CLAUDE.md 2>/dev/null; }
_odd=0; _oddlist=""
while read -r f; do
  [ -f "$f" ] || continue
  # grep -c 無命中時 exit 1 但仍印 0 ⇒ 不可再接 || echo 0（會多印一行 0 ⇒ 算式炸掉）
  c=$(grep -c '^```' "$f" 2>/dev/null); c=${c:-0}
  if [ $((c % 2)) -ne 0 ]; then _odd=$((_odd+1)); _oddlist="${_oddlist}
  ★未閉合 fence（n=${c}）  ${f}"; fi
done < <(_fence_pop)
if [ "$_odd" -gt 0 ]; then
  warn=$((warn+_odd))
  out="${out}${_oddlist}"
fi

if [ "$warn" -gt 0 ]; then
  echo "[doc-cap] 🟡 必讀區超限 ${warn} 項（warn-only，不阻擋）：${out}"
  echo "[doc-cap] ★上限不是品味問題：★★超限＝【開場就讀不完】＝規則存在但不會被用到。"
  echo "[doc-cap] ★處置＝搬到【按需讀】的地方（domain doc／spec／memory），不是刪掉。"
  echo "[doc-cap] ★★而「搬走」只做了一半：★★★主檔留下的殘骸要【合併成一行表列】——否則 N 個殘骸＝N 個入口＝一樣讀不完。"
  echo "[doc-cap] ★未閉合 fence 的修法＝補回被截掉的那一半（body 常常還活在對應的 detail 檔裡），不是刪掉那個 \`\`\`。"
else
  echo "[doc-cap] ✅ 必讀區全部在上限內"
fi
exit 0
