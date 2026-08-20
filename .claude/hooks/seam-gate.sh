#!/usr/bin/env bash
# seam-gate.sh — 交接縫閘（P9，2026-08-21 用戶核）。
#
# 為什麼要有：前作八項是「漏了會被發現」，不是「不會漏」。三個洞它們一個都沒堵：
#   ① 信的內容不看——寫一封空信，所有警報立刻閉嘴
#   ② 丟給對的下一站不驗——`to:` 寫錯（該給 reviewer 卻直推 implementer）→ 零紅燈
#   ③ 偵測 ≠ 執行——全部是「1h 後告訴 blueprint」，blueprint 不動就沒有第二層
# 用戶 2026-08-04 立過的法（00_roles:30）：**hook 提醒 ≠ gate；gate 裝執行點（鎖／merge），非 advisory 上游**。
# ⇒ 這支就是那條裝在 merge 執行點上的 gate。與 constitution_gate 並列跑（不混進去：那是原始碼指紋掃描器，類別不符）。
#
# 三支柱：
#   ① slice id 落地：每個產物 frontmatter 一行 `slice: <branch 名去掉 feat/>`＝★唯一的真相來源，不再有第二個
#   ② 分兩檔 tier，★做的人不能自己選（由 systems 在派工單 frontmatter 寫死）
#        full  = 產 code、要 merge 進 main    → spec + R② verdict + handback + .measure.json
#        probe = 列舉盤點／加 tap／診斷／量測 → handback（若下因果結論再加 QA ref）
#      ⛔ 兩檔都不砍 review：**輕流程省的是 paperwork，不是 check**。
#      理由：**能自己選輕流程的 agent，是在改自己的考卷。**
#   ③ 只綁新寫的，★不回溯武裝（沒宣告 slice: 的產物根本不在母體，永遠不可能被標紅＝結構性空洞）
#
# 用法：
#   bash .claude/hooks/seam-gate.sh                 # 用當前 branch
#   bash .claude/hooks/seam-gate.sh convoy-drop-enum
#   SEAM_MODE=hard bash .claude/hooks/seam-gate.sh  # 擋 merge（★baseline 穩定後才可轉）
#   bash .claude/hooks/seam-gate.sh --selftest      # 良品 fixture 自測（證儀器沒壞）
# exit: 0=通過（SOFT 永遠 0）/ 1=HARD 缺件 / 2=★儀器塌陷（母體地板或自測失敗）
set -u
MODE="${SEAM_MODE:-soft}"
_MAIN="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" 2>/dev/null)"
ROOT="${_MAIN:-.}"; cd "$ROOT" || exit 2

SPEC_D="docs/superpowers/specs"
HB_D="docs/superpowers/handbacks"

# 掃「頂層 frontmatter 宣告了 slice: <id>」的 md（只看前 12 行＝frontmatter 區）
_decl_md() {  # $1=dir $2=slice
  local d="$1" id="$2" f
  shopt -s nullglob
  for f in "$d"/*.md; do
    # ★取值後比對，不是整行比對：行尾常有註解／空白，整行比對會假陰性
    #   （2026-08-21 真語料自測踩到：slice: 後面加了 HTML 註解，spec 命中數就掉回 0）
    v=$(head -12 "$f" 2>/dev/null | grep -iE "^slice:" | head -1 | sed -e "s/^[Ss]lice:[[:space:]]*//" -e "s/[[:space:]]*<!--.*//" -e "s/[[:space:]]*#.*//" -e "s/[[:space:]]*$//" | tr -d '\r')
    [ "$v" = "$id" ] && echo "$f"
  done
}
_decl_measure() {  # $1=slice ；.measure.json 用頂層 "slice" key（既有欄位，語意改為 branch slice id）
  grep -rl "\"slice\"[[:space:]]*:[[:space:]]*\"$1\"" docs --include='*.measure.json' 2>/dev/null
}
_any_decl_count() {  # 母體：宣告了任何 slice: 欄的產物總數
  local n=0
  n=$(( n + $(grep -lE "^slice:[[:space:]]*[a-z0-9]" "$SPEC_D"/*.md 2>/dev/null | wc -l) ))
  n=$(( n + $(grep -lE "^slice:[[:space:]]*[a-z0-9]" "$HB_D"/*.md 2>/dev/null | wc -l) ))
  echo "$n"
}

# ── 良品 fixture 自測（★證 regex/解析沒壞；對真語料格式跑，不是對想像跑）──
if [ "${1:-}" = "--selftest" ]; then
  T="$(mktemp -d)"; mkdir -p "$T/$SPEC_D" "$T/$HB_D" "$T/docs/process/verdicts"
  printf -- '---\nslice: fixture-good\ntier: full\n---\n' > "$T/$SPEC_D/x-HOW.md"
  printf -- '---\nfrom: reviewer\nto: systems\nslice: fixture-good\nstatus: open\n---\n' > "$T/$HB_D/r.md"
  printf -- '---\nfrom: systems\nto: implementer\nslice: fixture-good\ntier: full\nstatus: open\n---\n' > "$T/$HB_D/d.md"
  printf -- '{"slice": "fixture-good"}\n' > "$T/docs/process/verdicts/x.measure.json"
  out=$(cd "$T" && SEAM_MODE=hard SEAM_SKIP_FLOOR=1 bash "$ROOT/.claude/hooks/seam-gate.sh" fixture-good 2>&1); rc=$?
  rm -rf "$T"
  if [ "$rc" = "0" ]; then echo "✅ 自測通過：已知良品 slice 四項全解得出來"; exit 0; fi
  echo "🔴 自測失敗（儀器壞了，不是產物缺）——gate 不可信，先修 gate"; echo "$out"; exit 2
fi

SLICE="${1:-}"
if [ -z "$SLICE" ]; then
  br="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
  SLICE="${br#feat/}"
fi
[ -z "$SLICE" ] && { echo "[seam-gate] 取不到 slice id"; exit 2; }

# ── 母體地板（expect_min 精神）：★匹配不到任何東西的檢查會印「0 violations」而讀起來像 PASS ──
if [ "${SEAM_SKIP_FLOOR:-0}" != "1" ]; then
  total="$(_any_decl_count)"
  floor="${SEAM_EXPECT_MIN:-}"
  if [ -z "$floor" ]; then [ "$MODE" = "hard" ] && floor=1 || floor=0; fi
  if [ "$total" -lt "$floor" ]; then
    echo "🔴 母體塌陷：宣告 slice: 欄的產物共 ${total} 份 < 地板 ${floor}"
    echo "   ★這不是「沒有缺件＝綠」，是【還沒有人在用這個欄位】或解析壞了。"
    exit 2
  fi
  [ "$total" -eq 0 ] && echo "（母體 0：還沒有產物宣告 slice: 欄——只綁新寫的，舊產物不溯改，屬正常）"
fi

specs=$(_decl_md "$SPEC_D" "$SLICE"); hbs=$(_decl_md "$HB_D" "$SLICE"); meas=$(_decl_measure "$SLICE")
n_spec=$(printf '%s' "$specs" | grep -c . || true)
n_hb=$(printf '%s'  "$hbs"   | grep -c . || true)
n_meas=$(printf '%s' "$meas" | grep -c . || true)
n_rev=0
if [ -n "$hbs" ]; then
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    head -12 "$f" | grep -qiE '^from:[[:space:]]*reviewer' && n_rev=$((n_rev+1))
  done <<< "$hbs"
fi
# tier：★只認派工單裡寫的（做的人不得自選）
TIER=""
if [ -n "$hbs" ]; then
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    t=$(head -12 "$f" | grep -iE "^tier:" | head -1 | sed -e "s/^[Tt]ier:[[:space:]]*//" -e "s/[[:space:]]*<!--.*//" -e "s/[[:space:]]*#.*//" | tr -d ' \r')
    [ -n "$t" ] && { TIER="$t"; break; }
  done <<< "$hbs"
fi

echo "[seam-gate:${MODE}] slice=${SLICE}  tier=${TIER:-（未宣告）}"
echo "  spec=${n_spec}  handback=${n_hb}  R²verdict=${n_rev}  measure=${n_meas}"

miss=""
case "$TIER" in
  full)
    [ "$n_spec" -eq 0 ] && miss="${miss} spec"
    [ "$n_rev"  -eq 0 ] && miss="${miss} R²verdict"
    [ "$n_hb"   -eq 0 ] && miss="${miss} handback"
    [ "$n_meas" -eq 0 ] && miss="${miss} .measure.json"
    ;;
  probe)
    [ "$n_hb"   -eq 0 ] && miss="${miss} handback"
    ;;
  "")
    echo "  ⚠ 這條 slice 的派工單沒宣告 tier —— ★tier 由 systems 在 dispatch frontmatter 寫死，做的人不得自選"
    [ "$MODE" = "hard" ] && { echo "🔴 HARD：tier 未宣告 = 無法判該欠什麼"; exit 1; }
    exit 0
    ;;
  *) echo "  ⚠ 未知 tier「${TIER}」（只認 full|probe）"; [ "$MODE" = "hard" ] && exit 1; exit 0 ;;
esac

if [ -z "$miss" ]; then
  echo "✅ 交接縫齊全（tier=${TIER}）"
  exit 0
fi
echo "🔴 缺：${miss# }"
echo "   ★機器只驗「產物在不在」，不驗職責/越界、不驗內容品質——那些永遠是人的活。"
if [ "$MODE" = "hard" ]; then exit 1; fi
echo "   （SOFT 階段：只印不擋。baseline 穩定後才轉 HARD；轉硬後【增列 baseline = STOP，要人裁】）"
exit 0
