#!/usr/bin/env bash
# expect-min-gate.sh — 母體地板閘（O2，2026-08-21）。
#
# 病：我們的普查（憲法閘 sites／負斷言 grep／信箱掃描）壞掉時，母體會【塌到 0】，
#     而 0 個違規讀起來跟「全綠」一模一樣。
#     血證 memory `feedback_intent_ledger_negative_assertion`：`grep|head` 截斷成假窮盡，
#     宣稱 ~10 處、實際 47 站。我們把它寫成紀律；evora 把它做成 schema 欄位（`expect_min`）。
#     ★本閘＝那條紀律的機械化：**每個普查都要帶下限**。
#
# ★地板要防的是「量測儀器壞掉」，不是「數字自然變動」。
#   所以地板設在【遠低於現值】的位置：抓塌陷，不抓漂移。
#   （例：憲法 sites 現值 74，地板 55——de-patch 讓它慢慢降是【好事】，不該紅燈；
#     但一旦 fingerprint/regex 壞掉會直接掉到 0 或個位數，那才是本閘要攔的。）
#
# 用法：bash .claude/hooks/expect-min-gate.sh          # 全部
#       SKIP_GODOT=1 bash .claude/hooks/expect-min-gate.sh   # 跳過要跑 godot 的（快）
# exit: 0=全部達地板 / 1=有普查塌陷
set -u
_MAIN="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" 2>/dev/null)"
ROOT="${_MAIN:-.}"; cd "$ROOT" || exit 1
SKIP_GODOT="${SKIP_GODOT:-0}"
fail=0

check() {   # name  floor  actual
  local name="$1" floor="$2" actual="$3"
  case "$actual" in (*[!0-9]*|'') actual=-1 ;; esac
  if [ "$actual" -lt 0 ]; then
    echo "🔴 ${name}: 取不到數字（普查本身跑不起來）——地板 ${floor}"
    fail=1
  elif [ "$actual" -lt "$floor" ]; then
    echo "🔴 ${name}: 母體 ${actual} < 地板 ${floor} —— ★不是「零違規＝綠」，是普查塌陷了"
    fail=1
  else
    echo "✅ ${name}: ${actual}（地板 ${floor}）"
  fi
}

# ① 角色註冊表：六個角色都要在表上（表壞掉 → 少於 6）
check "peers 角色數" 6 "$(bash .claude/hooks/peers.sh --tsv 2>/dev/null | wc -l)"

# ② 信箱母體：handbacks【頂層】活躍信（路徑或 glob 壞掉 → 塌到 0）
#    ★注意母體定義：頂層 239 封＝活躍信；遞迴 3544 是含 _archive(3305)+assets，不是同一個母體。
#    （note §3.4 寫「handbacks 1293 檔、扁平目錄」——兩者實測皆不符，見 systems 回信。）
check "handbacks 頂層母體" 150 "$(ls docs/superpowers/handbacks/*.md 2>/dev/null | wc -l)"

# ③ 信箱 frontmatter 可解析數（awk 規則壞掉 → 塌到 0，但檔還在）
check "可解析 to: 的信" 150 "$(grep -l "^to:" docs/superpowers/handbacks/*.md 2>/dev/null | wc -l)"

# ④ 憲法閘 sites（fingerprint 壞掉 → 塌陷；de-patch 自然下降不該紅燈，故地板遠低於現值）
if [ "$SKIP_GODOT" = "1" ]; then
  echo "⏭ 憲法閘 sites: 跳過（SKIP_GODOT=1）"
else
  _out=$(timeout 300 powershell -NoProfile -File tools/godot.ps1 --headless --script scripts/debug/constitution_gate.gd 2>&1 | grep -o "sites=[0-9]*" | head -1)
  check "憲法閘 sites" 55 "${_out#sites=}"
fi

# ⑤ R6 標記母體（stale-claims 自己也有地板；這裡再確認全庫掃跑得起來）
_sc=$(bash .claude/hooks/stale-claims.sh 2>/dev/null | grep -o "掃到量測標記 [0-9]*" | grep -o "[0-9]*")
check "R6 量測標記" 1 "${_sc:-}"

[ "$fail" = "0" ] && echo "★expect-min 全數達地板" || echo "★有普查塌陷 —— 先修儀器，別讀那些「零違規」"
exit "$fail"
