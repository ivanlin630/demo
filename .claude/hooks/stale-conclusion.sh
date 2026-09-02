#!/usr/bin/env bash
# ★★★休眠中 —— 【故意沒有註冊進 docs/process/merge-gates.tsv】（2026-09-03 systems 裁，理由如下）
#
#   ★蓋完之後量它的真涵蓋率，答案是【9.0%】：
#       134 顆 verdict 裡指名得出 scripts 路徑的有 73 顆（54.5%）——
#       ★★但其中 61 顆指名的是【床】（scripts/debug/*_bed.gd），而床【永遠不會出現在 production 的 diff 裡】
#       ⇒ 真正指名得出 production 路徑的只有 ★12 顆（9.0%），盲區 122 顆（91%）。
#   ★★而 9.0% 正是我三小時前拿來否定「measured_at_commit 當地基」的那個數量級（8.2%）
#     ⇒ ★★★我差一步就蓋出【我自己剛批評過的東西】，而且會拿著它去跟 reviewer 說涵蓋 55%。
#   ★試過的補救（也量了，也失敗）：床→production 反查。130 張床【平均直接引用 0 個】 production 檔
#     ——它們走 Godot `class_name` 全域名，不走 `res://` 路徑 ⇒ 路徑交集這把鑰匙在我們的資料裡不存在。
#
#   ⇒ ★★★裁定：**不註冊**。warn-only ＋ 9% 涵蓋 ＝ 裝飾，而我自己立的標準是
#      「多一份沒人看的輸出，比沒有這道閘更糟」。
#   ⇒ **啟用觸發（不是時鐘，是事件）**：當 verdict 開始帶 `touches`（production 路徑陣列）、
#      且**指名得出 production 路徑的比例 ≥ 50%** 時，把本檔加進註冊表（expect: `\[STALE-CONCL\]`）。
#      ★本檔的 PASS 行【每次都會印涵蓋率】，所以那個門檻是可觀察的，不必靠誰記得。
#
# ★★★stale-conclusion —— 「根修會讓建立在舊世界上的結論默默過期，而它們不會自己舉手。」
#   本閘讓它們舉手。★warn-only：只列候選，不擋 merge、不改任何檔、不作廢任何結論。
#
# ★★2026-09-03 設計血證（★三個都是【量出來的】，不是想出來的）：
#   ①`measured_at_commit` 靠不住：134 顆 verdict 裡抓得到 hash 的只有 11 顆（8.2%），97 顆根本沒這欄
#     ⇒ 拿它當地基＝蓋一個只查得到 8% 卻看起來管好了的橡皮圖章。
#   ②reviewer 找到的 false-freshness 反例【是真的】：worktree 上量、延遲才 merge 進 main
#     ⇒ 我原本的修法是「改用 author date」，★★而量完發現【author date 與 committer date 完全一樣】
#       （36 顆可比對的 verdict，5 顆落後 4 天，Δa 與 Δc 逐顆相等）⇒ ★★★author date 一點保護都沒有。
#     ⇒ 真修法：**寬限窗**。實測最大落差 4 天、>7 天 0 顆 ⇒ 取 7 天（★這個常數來自我們自己的資料）。
#   ③檔案交集法天生盲 45%：74/134 指名得出 scripts 路徑，60 顆一個都沒有（追 raw report 只撈回 1 顆）。
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)" || exit 2
VDIR="docs/process/verdicts"
GRACE_DAYS=7          # ★見檔頭②：實測最大落差 4 天，取 7 天寬限（誤報 ≫ 漏報）

# ── ⓪陽性對照（★休眠中的守衛更需要它：沒人跑的東西壞了不會有人知道） ──
#   餵一個【已知被 verdict 指名】的 production 檔，必須列得出候選；餵一個沒人指名的，必須列不出。
if [ "${1:-}" = "--self-test" ]; then
  V="docs/process/verdicts"
  hit=0; for f in "$V"/*.json; do grep -qaF 'scripts/simulation/faction_ai_system.gd' "$f" && hit=$((hit+1)); done
  miss=0; for f in "$V"/*.json; do grep -qaF 'scripts/simulation/no_such_system_xyz.gd' "$f" && miss=$((miss+1)); done
  if [ "$hit" -ge 1 ] && [ "$miss" -eq 0 ]; then
    echo "[STALE-CONCL] SELF-TEST PASS（陽性 faction_ai_system.gd=$hit 顆／陰性 no_such_system_xyz.gd=$miss 顆）"; exit 0
  fi
  echo "[STALE-CONCL] SELF-TEST FAIL（陽性=$hit 應 ≥1／陰性=$miss 應 =0）"
  echo "  ★陽性掉到 0 最可能的意思不是「壞了」，是【那顆 verdict 被改名或搬走了】—— 先查它，再查本閘。"
  exit 1
fi

# ── ①本次改了哪些 production 檔 ────────────────────────────────
BASE=$(git merge-base HEAD origin/main 2>/dev/null || true)
if [ -n "$BASE" ] && [ "$BASE" != "$(git rev-parse HEAD)" ]; then
  CHANGED=$(git diff --name-only "$BASE"...HEAD -- 'scripts/*' 2>/dev/null)
  SCOPE="branch vs origin/main（$(git rev-parse --short "$BASE")...HEAD）"
else
  CHANGED=$(git diff --name-only HEAD~1..HEAD -- 'scripts/*' 2>/dev/null)
  SCOPE="HEAD~1..HEAD（★沒有 branch 可比，退回單顆 commit）"
fi
CHANGED=$(printf '%s\n' "$CHANGED" | sed '/^$/d' | sort -u)
NCH=$(printf '%s\n' "$CHANGED" | sed '/^$/d' | wc -l | tr -d ' ')

# ── ②盲區大小（每輪都算，★不是註腳） ──────────────────────────
TOTV=0; BLIND=0
for f in "$VDIR"/*.json; do
  [ -f "$f" ] || continue
  TOTV=$((TOTV+1))
  grep -qaoE 'scripts/(simulation|data|ui|core)[A-Za-z0-9_/]*\.gd' "$f" || BLIND=$((BLIND+1))
done

if [ "$NCH" -eq 0 ]; then
  echo "[STALE-CONCL] PASS：本次沒有改到 scripts/ ⇒ 沒有結論會因此過期（掃描範圍：$SCOPE）"
  echo "[STALE-CONCL] ★誠實限①：$BLIND/$TOTV 顆結論【指名不出 production 路徑】（含只指名床的）⇒ 本閘對它們天生盲"
  exit 0
fi

# ── ③交集 ────────────────────────────────────────────────────
CUT=$(python -c "
import datetime,sys
print((datetime.date.today()-datetime.timedelta(days=int(sys.argv[1]))).isoformat())
" "$GRACE_DAYS" 2>/dev/null || echo 1970-01-01)

HITS=""; NHIT=0
for f in "$VDIR"/*.json; do
  [ -f "$f" ] || continue
  HIT=""
  for p in $(grep -aoE 'scripts/(simulation|data|ui|core)[A-Za-z0-9_/]*\.gd' "$f" | sort -u); do
    printf '%s\n' "$CHANGED" | grep -qxF "$p" && HIT="$HIT $p"
  done
  [ -n "$HIT" ] || continue
  # ★寬限窗：落地日期在 CUT 之後的，視為「可能是這一輪自己產的」，不列
  ADD=$(git log -1 --diff-filter=A --format='%h %ad' --date=short -- "$f" 2>/dev/null)
  ADATE=${ADD##* }
  if [ -n "$ADATE" ] && [ "$ADATE" \> "$CUT" ]; then continue; fi
  NHIT=$((NHIT+1))
  HITS="$HITS
  · $(basename "$f")  ［落地 ${ADD:-未追蹤}］
      命中：$(echo $HIT)"
done

if [ "$NHIT" -eq 0 ]; then
  echo "[STALE-CONCL] PASS：改了 $NCH 個 production 檔，沒有任何既有結論指名到它們"
  echo "[STALE-CONCL] ★誠實限①：$BLIND/$TOTV 顆結論【指名不出 production 路徑】（含只指名床的）⇒ 本閘對它們天生盲"
  exit 0
fi

# ── ④有命中才吵（★沉默＝沒有候選；★★這是它不被 13 道閘的輸出牆埋掉的方式） ──
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║ [STALE-CONCL] ★★★$NHIT 顆舊結論可能已經過期 —— 它們建立在你剛改的 code 上 ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo "本次改了 $NCH 個 production 檔（$SCOPE）"
echo "$HITS"
echo ""
echo "[STALE-CONCL] ★誠實限①（★最大失效面，不是註腳）：$BLIND/$TOTV 顆結論一個 code 路徑都沒指名 ⇒ 本閘對它們【天生盲】"
echo "[STALE-CONCL] ★誠實限②：只印不判 —— 不擋 merge、不作廢任何結論；要不要重驗是【人】的判斷"
echo "[STALE-CONCL] ★誠實限③：時間用【檔案落地日】＋${GRACE_DAYS}天寬限（實測 worktree 延遲最大 4 天）⇒ 會誤列新結論，方向保守"
echo "[STALE-CONCL] PASS（warn-only）"
exit 0
