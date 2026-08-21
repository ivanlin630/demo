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
MODE="${SEAM_MODE:-hard}"   # ★2026-08-21 轉 HARD（兩件對齊完成+逐slice表零誤殺;逃生門 SEAM_MODE=soft）
_MAIN="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" 2>/dev/null)"
ROOT="${_MAIN:-.}"; cd "$ROOT" || exit 2

SPEC_D="docs/superpowers/specs"
HB_D="docs/superpowers/handbacks"

# ★單次 awk 掃描（2026-08-21 perf 修）：原版對每個檔 spawn 一次 head ⇒ 300+ 封信 ＝ 600+ 進程，
#   實測【單次跑 1m47s】，當 merge 閘完全不能用。
#   ★而 handback-inbox.sh 的檔頭正好記著 2026-07-05 修過同一個病（每檔 spawn 3 進程 → 33s 撞 timeout
#   → 改單次 awk）——我寫這支時原封不動重犯了一次。這裡照同一個藥修。
_scan() {   # 一次 awk 掃完 specs+handbacks，輸出：slice|kind|from|tier
  #   ★分隔符用直線而非 tab：本檔經多層工具寫入，反斜線跳脫會被吃掉（實測踩過兩次）。
  #   awk 內全程用 [[:space:]]、不寫任何反斜線 ⇒ 沒有可壞的地方。
  #   ★perf：原版對每個檔 spawn 一次 head ⇒ 300+ 封信 = 600+ 進程，實測【單次 1m47s】完全不能當 merge 閘。
  #   handback-inbox.sh 檔頭記著 2026-07-05 修過同一個病（改單次 awk），我寫這支時原封不動重犯一次。
  shopt -s nullglob
  local files=("$SPEC_D"/*.md "$HB_D"/*.md)
  [ "${#files[@]}" -eq 0 ] && return 0
  awk '
    FNR==1 { sl=""; fr=""; ti=""; qa=""; done=0; knd = (FILENAME ~ /specs/) ? "spec" : "hb" }
    FNR<=12 {
      low = tolower($0)
      if (low ~ /^slice:/) { v=$0; sub(/^[^:]*:[[:space:]]*/,"",v); sub(/[[:space:]]*<!--.*/,"",v); sub(/[[:space:]]*#.*/,"",v); gsub(/[[:space:]]/,"",v); sl=v }
      if (low ~ /^from:/)  { v=tolower($0); sub(/^[^:]*:[[:space:]]*/,"",v); gsub(/[[:space:]]/,"",v); fr=v }
      if (low ~ /^tier:/)  { v=$0; sub(/^[^:]*:[[:space:]]*/,"",v); sub(/[[:space:]]*<!--.*/,"",v); sub(/[[:space:]]*#.*/,"",v); gsub(/[[:space:]]/,"",v); ti=v }
      if (low ~ /^qa:/)    { v=tolower($0); sub(/^[^:]*:[[:space:]]*/,"",v); sub(/[[:space:]]*<!--.*/,"",v); gsub(/[[:space:]]/,"",v); qa=v }
      if (FNR==12 && sl != "" && !done) { print sl "|" knd "|" fr "|" ti "|" qa; done=1 }
    }
    ENDFILE { if (!done && sl != "") print sl "|" knd "|" fr "|" ti "|" qa }
  ' "${files[@]}"
}

_decl_measure() {  # .measure.json 用頂層 "slice" key
  grep -rl "\"slice\"[[:space:]]*:[[:space:]]*\"$1\"" docs --include='*.measure.json' 2>/dev/null
}
_any_decl_count() { _scan | awk -F'|' '$1!=""{n++} END{print n+0}'; }

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

# ★一次掃描、四個數字全從同一份結果算（原版對每檔 spawn head，實測 1m47s）
_S=$(_scan)
n_spec=$(printf '%s\n' "$_S" | awk -F'|' -v s="$SLICE" '$1==s && $2=="spec"{n++} END{print n+0}')
n_hb=$(printf '%s\n' "$_S" | awk -F'|' -v s="$SLICE" '$1==s && $2=="hb"{n++} END{print n+0}')
n_rev=$(printf '%s\n' "$_S" | awk -F'|' -v s="$SLICE" '$1==s && $2=="hb" && $3=="reviewer"{n++} END{print n+0}')
# tier：★只認派工單裡寫的（做的人不得自選）——取該 slice 第一個有 tier 的 handback
TIER=$(printf '%s\n' "$_S" | awk -F'|' -v s="$SLICE" '$1==s && $4!=""{print $4; exit}')
# ★QA 閘機械化（用戶拍板 2026-08-21，刀1）：把 2026-08-04 立的 QA-verdict 閘從 systems 自律升成 merge 閘機械驗。
#   判準來源＝派工單的 `qa:` 欄（**由 systems 定，同 tier**）：`required` ＝ 這條 slice 會下長跑因果結論。
#   ★機器只驗「QA verdict 在不在」，不驗它判得對不對——那永遠是人的活。
QA_REQ=$(printf '%s
' "$_S" | awk -F'|' -v s="$SLICE" '$1==s && $5!=""{print $5; exit}')
n_qa=$(printf '%s
' "$_S" | awk -F'|' -v s="$SLICE" '$1==s && $2=="hb" && $3=="qa"{n++} END{print n+0}')
meas=$(_decl_measure "$SLICE")
n_meas=$(printf '%s' "$meas" | grep -c . || true)

echo "[seam-gate:${MODE}] slice=${SLICE}  tier=${TIER:-（未宣告）}"
echo "  spec=${n_spec}  handback=${n_hb}  R²verdict=${n_rev}  measure=${n_meas}  QA=${n_qa}${QA_REQ:+（qa:${QA_REQ}）}"

miss=""
case "$TIER" in
  full)
    [ "$n_spec" -eq 0 ] && miss="${miss} spec"
    [ "$n_rev"  -eq 0 ] && miss="${miss} R²verdict"
    [ "$n_hb"   -eq 0 ] && miss="${miss} handback"
    [ "$n_meas" -eq 0 ] && miss="${miss} .measure.json"
    [ "$QA_REQ" = "required" ] && [ "$n_qa" -eq 0 ] && miss="${miss} QA-verdict"
    ;;
  probe)
    [ "$n_hb"   -eq 0 ] && miss="${miss} handback"
    ;;
  "")
    # ★HARD 入場券（blueprint 核准 2026-08-21）：【有含 tier 的 dispatch handback】才進 HARD 管轄。
    #   用派工票劃代 ⇒ 紀律生效前的老 slice 自然不在管轄內，【零回溯武裝】
    #   （回溯武裝是結構性空洞：沒宣告的東西根本不在母體，永遠不可能被標紅）。
    #   ★逃生門的責任歸屬寫明：dispatch handback 是 systems 寫的 ⇒ 漏寫 tier 是 systems 自己的失誤，
    #   而且【SOFT/HARD 都會印這行】，看得見。
    echo "  ⚠ 這條 slice 沒有含 tier 的派工單 —— ★tier 由 systems 在 dispatch frontmatter 寫死，做的人不得自選"
    if [ "$MODE" = "hard" ]; then
      echo "  ⏭ HARD 不管轄（無派工票＝紀律生效前的 slice，或 systems 漏寫 tier）——★這行本身就是給 systems 看的"
    fi
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
