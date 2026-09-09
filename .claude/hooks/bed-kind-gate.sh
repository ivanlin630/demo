#!/usr/bin/env bash
# 床的【種類標記】閘 —— spec: docs/superpowers/specs/2026-09-08-bed-kind-marker-HOW.md
#
# ★病：「床在」與「床會紅」是兩件事，而 repo 裡沒有任何地方分得出來。
#   同一天兩次血證：薪資床 ALL PASS 而情境沒造出來；gather 純度床判準用 fp 而 fp 不涵蓋被修的欄位。
# ★★止血形狀：只檢查【本次 diff 觸及的】床 ⇒ 存量 371 支不用一次補完，
#   但新增/改動的床跑不掉。
# ★★★而這支閘自己也要有牙：每次跑都先對 fixtures 跑一輪【陽性對照】，
#   四種紅各一格 ＋ 一格反向綠。對照結果不符 ⇒ 本輪作廢（exit 3），不是「順便通過」。
set -u
export LC_ALL=C

# ★★★不用 git-common-dir 算 root：從 worktree 跑時它會指向【主 repo】，
#   於是閘會去量另一棵樹 ―― 本 session 已經因這個踩過一次（tier2 全掃零產出）。
#   ★改用【腳本自己住哪裏】：.claude/hooks/x.sh ⇒ ../.. 就是它那棵樹的 root。
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO" || exit 2
# ★判決行形狀走【共用清單】——兩處各養一份必 drift（血證見 verdict-shapes.sh 檔頭）
. "$(dirname "${BASH_SOURCE[0]}")/verdict-shapes.sh"
FIX=".claude/hooks/fixtures/bed-kind"
TSV="docs/process/merge-gates.tsv"
DEFERS="docs/process/defers.tsv"

# 回一行：OK 或 "紅因"。★單一判斷點：陽性對照與真檢查走【同一個函式】。
check_one() {
  f="$1"
  # ★★★【不存在 ⇒ OK】是本 session 第三次碰到的同一個病（恆空母體）。
  #   真檢查走的 diff filter 是 AM（不含刪除）⇒ 檔案不存在就【不該發生】，
  #   多半是路徑錯或【量錯樹】―― 而那正是今天 tier2 零產出的根因。
  [ -f "$f" ] || { echo "檔案不存在（★diff filter 是 AM，不該有這種情形：路徑錯或樹錯）"; return; }
  kind="$(sed -n '1,8p' "$f" | sed -n 's/^#[[:space:]]*@bed-kind:[[:space:]]*\([a-z]*\).*/\1/p' | head -1)"
  case "$kind" in
    '') echo "沒有 @bed-kind 宣告"; return;;
    invariant|acceptance|diagnostic|pending) ;;
    *) echo "@bed-kind 值不在四選一裡: $kind"; return;;
  esac
  base="$(basename "$f")"
  case "$kind" in
    invariant)
      grep -qF "$base" "$TSV" || { echo "宣告 invariant 卻不在 $TSV（宣告是守衛就必須接電）"; return; };;
    acceptance)
      sed -n '1,8p' "$f" | grep -q '^#[[:space:]]*slice:[[:space:]]*[^[:space:]]' \
        || { echo "宣告 acceptance 卻沒有 slice: 欄"; return; };;
    diagnostic)
      # ★2026-09-09 放寬：舊版只認字面 `=== DONE ===`，而真實床寫的是
      #   `=== UI Flow Test DONE === errors: %d` ⇒ 舊版對它印 ok（★閘替謊蓋章）。
      if grep -qE "$VERDICT_CHANNEL_RE" "$f"; then
        echo "宣告 diagnostic 卻有判決彙總行（有判決通道就不是純診斷）"; return
      fi;;
    pending)
      blocker="$(sed -n '1,8p' "$f" | sed -n 's/^#[[:space:]]*blocker:[[:space:]]*\([^[:space:]]*\).*/\1/p' | head -1)"
      [ -n "$blocker" ] || { echo "宣告 pending 卻沒有 blocker: 欄"; return; }
      # ★只查「有沒有寫」的話,pending 會變成【隨便寫個理由就能拖著不修】
      #   ⇒ 必須在 defers.tsv 的 token 欄找得到,才是真的掛上 defer 追蹤系統。
      awk -F'\t' -v b="$blocker" '$1==b{found=1} END{exit !found}' "$DEFERS" \
        || { echo "pending 的 blocker '$blocker' 不在 $DEFERS 的 token 欄"; return; };;
  esac
  echo "OK"
}

# ── 陽性對照（★每次都跑；★★四種紅各一格 + 一格反向綠）───────────────
selftest() {
  bad=0
  for pair in \
    "unmarked_bed.gd|RED" \
    "invariant_not_wired_bed.gd|RED" \
    "pending_bogus_blocker_bed.gd|RED" \
    "diagnostic_with_verdict_bed.gd|RED" \
    "diagnostic_real_shape_bed.gd|RED" \
    "good_diagnostic_bed.gd|GREEN" \
    "acceptance_no_slice_bed.gd|RED"     "good_pending_bed.gd|GREEN"     "good_acceptance_bed.gd|GREEN"
  do
    n="${pair%|*}"; want="${pair#*|}"
    if [ ! -f "$FIX/$n" ]; then
      echo "[BED-KIND] ★對照樣本不見：$FIX/$n ―― ★★【樣本不在】不算【對照過了】"
      bad=1; continue
    fi
    r="$(check_one "$FIX/$n")"
    case "$r" in OK*) got=GREEN;; *) got=RED;; esac
    if [ "$got" != "$want" ]; then
      echo "[BED-KIND] ★對照失準：$n 期望 $want 實得 $got（$r）"; bad=1
    fi
  done
  [ "$bad" = "0" ]
}

if ! selftest; then
  echo "[BED-KIND] ★ABORT：陽性對照沒過 ⇒ 本輪作廢（不得讀成任何結果）"
  exit 3
fi
echo "[BED-KIND] 陽性對照通過（6 格紅 + 3 格反向綠，涵蓋 §3b 全部四條；含【真實床原句】的 diagnostic 紅）"

# ── 存量規模（★只是讓它可見；★★不宣稱它會因此下降）────────────────
TOTAL="$(git ls-files 'scripts/debug/*.gd' | wc -l | tr -d ' ')"
MARKED="$(git ls-files 'scripts/debug/*.gd' | xargs grep -l '@bed-kind:' 2>/dev/null | wc -l | tr -d ' ')"
echo "[BED-KIND] 已標記 $MARKED / $TOTAL（★存量規模可見；★★要它下降得靠別的機制,不是靠印）"

# ── 真檢查：只看本次 diff 觸及的床 ─────────────────────────────
if [ "$#" -gt 0 ]; then
  FILES="$*"
else
  # ★★★三點 diff 只看【已 commit】的改動 ⇒ 正在寫的床看不到，
  #   而【閘在 commit 之前不會鎮】就是【閘不會鎮】。⇒ 母體 = merge-base 到【工作樹】,
  #   ★再加【未追蹤檔】―― 新床天生是 untracked,而那正是本閘最要擋的那一類。
  _mb="$(git merge-base origin/main HEAD 2>/dev/null || echo HEAD)"
  FILES="$( { git diff --name-only --diff-filter=AM "$_mb" -- 'scripts/debug/*.gd' 2>/dev/null
              git ls-files --others --exclude-standard -- 'scripts/debug/*.gd' 2>/dev/null
            } | sort -u )"
fi
if [ -z "${FILES//[[:space:]]/}" ]; then
  echo "[BED-KIND] 本次 diff 沒有觸及 scripts/debug/*.gd（母體為空 ⇒ 沒有可判的東西）"
  echo "[BED-KIND] PASS"
  exit 0
fi
fails=0; n=0
for f in $FILES; do
  n=$((n+1))
  r="$(check_one "$f")"
  case "$r" in
    OK*) echo "[BED-KIND] ok  $f" ;;
    *)   echo "[BED-KIND] ★紅 $f —— $r"; fails=$((fails+1)) ;;
  esac
done
echo "[BED-KIND] 本次觸及 $n 支｜紅 $fails 支"
if [ "$fails" -gt 0 ]; then
  echo "[BED-KIND] ★處置：在床檔開頭加一行 @bed-kind: invariant|acceptance|diagnostic|pending"
  echo "[BED-KIND]   invariant⇒必須進 $TSV｜acceptance⇒必須寫 slice:｜pending⇒blocker: 必須是 $DEFERS 的 token"
  exit 1
fi
echo "[BED-KIND] PASS"
