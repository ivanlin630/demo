#!/usr/bin/env bash
# stale-claims.sh — 量測主張保鮮期掃描（R6，2026-08-21 用戶定案）。
#
# 病：`00_roles §量測可溯源鐵律` 管的是「寫進去那一刻」，不管「三天後還在被引用」。
#     D1 血證：`統領 0.08` 當初完全合規寫入，之後被當成世界的性質掛在清單上數日，
#     今日實測 AT_CAP=0.0% / 統領 0.600 → 因果鏈死掉，差點買下一整個 arc。
#     ★手寫的「量測數字」跟手寫的 `status: done` 一樣會過期，而且更毒——它讀起來像事實不像狀態。
#
# 主張分三級（混級才是病）：
#   結構（這步存在／誰 owner）→ 不會過期，引用帶 file:line
#   量測（統領 0.08 / AT_CAP 0.0%）→ ★會過期，引用必帶 commit + 日期 + 重跑指令
#   裁定（owner 拍板）→ 不會過期，直到被新裁定推翻；★但若地基是量測，地基過期＝裁定進複查名單
#
# 掃描的標記格式（★只綁新寫的，舊的不溯改——沒標記＝不掃，不噴噪音）：
#   量測： AT_CAP=0.0% @ee5e879f 2026-08-21 · repro: `<指令>`
#   裁定： D1 降為非擋考 —— 裁定 2026-08-21，地基＝AT_CAP 量測 @ee5e879f
#
# 用法：
#   bash .claude/hooks/stale-claims.sh              # 全掃
#   bash .claude/hooks/stale-claims.sh docs/process/2026-08-21-model-completion-checklist.md
#   STALE_DAYS=7 STALE_COMMITS=20 bash ...          # 調閾值
#
# exit: 0=全新鮮 / 1=有過期 / 2=★母體塌陷（掃不到任何標記＝regex 或路徑壞了，不是「零違規＝綠」）
#   （exit 2 是 O2 `expect_min` 的同一條防線：glob/regex 壞掉 → 母體塌到 0 → 假綠。
#    血證 memory `feedback_intent_ledger_negative_assertion`：grep|head 截斷成假窮盡，~10 處實際 47 站。）
set -u
STALE_DAYS="${STALE_DAYS:-7}"
STALE_COMMITS="${STALE_COMMITS:-20}"
# 母體地板：掃到的標記數少於此 → exit 2。
# ★預設值分兩種，因為「不溯改」讓舊檔【本來就該是 0 筆】：
#   全庫掃(未指定路徑) → 地板 1（確知至少有標記存在；掃到 0 就是 regex/路徑壞了）
#   指定檔案掃         → 地板 0（舊檔沒標記是合法狀態，不是故障）
#   ⇒ 要對某份清單斷言「它應該有標記」，呼叫端自己給 EXPECT_MIN=<n>。
#   母體地板只能對「你確知該有標記」的母體宣告，否則地板本身就在製造假警報。

_MAIN="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" 2>/dev/null)"
ROOT="${_MAIN:-.}"
cd "$ROOT" || exit 2

if [ "$#" -gt 0 ]; then TARGETS=("$@"); DEFAULT_MIN=0; else TARGETS=(docs); DEFAULT_MIN=1; fi
EXPECT_MIN="${EXPECT_MIN:-$DEFAULT_MIN}"

# 標記 = @<7-40 hex> 後面接 ISO 日期（同行內，中間允許空白/全形標點）
RE='@[0-9a-f]{7,40}[^0-9]{0,4}[0-9]{4}-[0-9]{2}-[0-9]{2}'

total=0; stale=0; unknown=0
# ★用陣列存輸出、最後用 %s 印。原本 printf "%b" 會解釋內容裡的反斜線跳脫，
#   把 repro 指令 `.	ools\godot.ps1` 印成 `.<TAB>ools...` ＝竄改了給人重跑的指令。
declare -a OUT=()
while IFS= read -r line; do
  [ -z "$line" ] && continue
  file="${line%%:*}"; rest="${line#*:}"; lno="${rest%%:*}"; text="${rest#*:}"
  sha=$(printf '%s' "$text" | grep -oE '@[0-9a-f]{7,40}' | head -1 | tr -d '@')
  wdate=$(printf '%s' "$text" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1)
  [ -z "$sha" ] && continue
  total=$((total+1))
  if ! git cat-file -e "${sha}^{commit}" 2>/dev/null; then
    unknown=$((unknown+1))
    OUT+=("❓ ${file}:${lno}  @${sha} 不是本 repo 的 commit（打錯或來自別的 repo）")
    continue
  fi
  ct=$(git log -1 --format=%ct "$sha" 2>/dev/null || echo 0)
  age_d=$(( ( $(date +%s) - ct ) / 86400 ))
  behind=$(git rev-list --count "${sha}..main" 2>/dev/null || echo 0)
  flag=""
  [ "$age_d" -ge "$STALE_DAYS" ]      && flag="${flag}已 ${age_d} 天 "
  [ "$behind" -ge "$STALE_COMMITS" ]  && flag="${flag}落後 main ${behind} 個 commit "
  if [ -n "$flag" ]; then
    stale=$((stale+1))
    snippet=$(printf '%s' "$text" | sed 's/^[[:space:]]*//' | cut -c1-90)
    OUT+=("⚠ ${file}:${lno}  ${flag}")
    OUT+=("   @${sha} ${wdate}  ${snippet}")
  fi
done < <(grep -rnoE "$RE.*" --include='*.md' "${TARGETS[@]}" 2>/dev/null)

echo "[stale-claims] 掃到量測標記 ${total} 筆（閾值：${STALE_DAYS} 天 / 落後 ${STALE_COMMITS} commit）"
if [ "$total" -lt "$EXPECT_MIN" ]; then
  echo "🔴 母體塌陷：掃到 ${total} 筆 < 地板 ${EXPECT_MIN}。這不是「零過期＝綠」，是 regex／路徑壞了。"
  exit 2
fi
if [ "$stale" -eq 0 ] && [ "$unknown" -eq 0 ]; then
  if [ "$total" -eq 0 ]; then
    echo "（母體 0 筆：這些檔還沒上 R6 標記——舊檔不溯改，屬正常，不是「全部新鮮」）"
  else
    echo "✅ 全部新鮮"
  fi
  exit 0
fi
[ "${#OUT[@]}" -gt 0 ] && printf '%s\n' "${OUT[@]}"
echo "—— 過期 ${stale} 筆、來源不明 ${unknown} 筆。"
echo "→ 這些數字**不可再當作世界的性質引用**：重跑（照該行的 repro 指令）或標「地基待重驗」。"
echo "→ 若它是某個裁定的地基（『地基＝…』），該裁定同時進複查名單（見 09_exam_gate）。"
exit 1
