#!/usr/bin/env bash
# ★★★merge-gate runner —— 讀 docs/process/merge-gates.tsv，逐支跑，彙總。
#   ★用戶裁「搬」2026-09-01；★★而「搬完要可執行」是 systems 的 HOW 裁。
#   ★★★2026-09-01 補正（implementer 揭）：原版【沒有執行註冊表的判準欄】
#     ⇒ 一支「跑了、exit 0、什麼都不斷言」的閘會拿到 ✓ ⇒ ★那是假綠。
#     ⇒ 現在：★★exit code 通過【還不夠】，輸出必須命中 expect；★★★沒寫 expect 的行直接 FAIL。
#   ★誠實限：runner 讓「跑」變便宜，但【跑得久】仍會讓人跳過 ⇒ 報每支耗時與總時。
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)" || exit 2
REG="docs/process/merge-gates.tsv"

# ★★★判決要落地（2026-09-07 血證）：本 runner 的判決原本【只走 stdout】。
#   ★外層 shell 被殺 ⇒ 閘跑完了，而判決消失在一個沒有人接收的管道裡。
#   ⇒ 把事實放在【活得比呼叫者久】的地方。不改行為：stdout 照舊，只是同時寫檔。
MG_LOG="${MG_LOG:-.claude/hooks/.merge-gates-last.log}"
mkdir -p "$(dirname "$MG_LOG")" 2>/dev/null
exec > >(tee "$MG_LOG") 2>&1
echo "[MERGE-GATES] ★判決同時寫入 $MG_LOG（外層 shell 若被殺，結論仍在這裡）"

# ★★★判決要能【歸因】（2026-09-08 血證）：★本 runner 讀【工作區】不是 HEAD。
#   ★.merge-gates-last.log 記著 `✓ computed-prop`，而 HEAD 上那行 expect 是
#     [COMPUTED-PROP] PASS ⇒ grep -qE 把它當【字元類】⇒ 在 HEAD 上永遠不可能綠；
#     那次的綠是靠一份【未 commit 的修改】跑出來的。
#   ⇒ ★★沒有 provenance 的「35/35 全綠」【不能】被引用成「main 是綠的」。
#   ★★★不拒絕執行（改自己的 slice 時本來就該髒）——改成【標明適用範圍】。
_mg_head=$(git rev-parse --short HEAD 2>/dev/null || echo '?')
_mg_reg=$(git --no-optional-locks status --porcelain -- "$REG" 2>/dev/null | head -c1)
_mg_run=$(git --no-optional-locks status --porcelain -- .claude/hooks 2>/dev/null | head -c1)
_mg_code=$(git --no-optional-locks status --porcelain -- scripts tools 2>/dev/null | grep -v '^??' | wc -l | tr -d ' ')
echo "[MERGE-GATES] [TREE] HEAD=$_mg_head registry=$([ -n "$_mg_reg" ] && echo DIRTY || echo clean) runner=$([ -n "$_mg_run" ] && echo DIRTY || echo clean) code-dirty=$_mg_code"
if [ -n "$_mg_reg$_mg_run" ]; then
  echo "[MERGE-GATES] ★★本次判決【只適用於你的工作區】——註冊表或 runner 有未 commit 的修改"
  echo "[MERGE-GATES]   ⇒ 綠【不等於】HEAD $_mg_head 是綠的。要引用成「main 綠」必須先 commit 再重跑。"
else
  echo "[MERGE-GATES] ★本次判決適用於 HEAD=$_mg_head（註冊表與 runner 皆乾淨）"
fi

# ★★★註冊表新鮮度（2026-09-03，implementer 提、systems 實作）——★病：閘自己會印 PASS，而它【不知道自己少了幾支】。
#   ★血證同型兩次（同一天）：branch 上只有 10 支卻連報四次「全部通過」；後來 12 支 vs main 14 支。
#   ★★「以後記得先 fetch」防不到 —— **忘記的時候沒有任何東西會響**（失效是靜默的）。
#   ⇒ 做法：跟 origin/main 比【閘名集合】，少了就把結論印成 `PASS（12/14）★註冊表落後 main：缺 X, Y`。
#   ★不擋（離線／刻意分叉是合法的），★★但【不准它印出一個看起來完整的 PASS】。
#   ★★★關掉：`MG_NO_FETCH=1`（離線）。
STALE_NOTE=""
if [ "${MG_NO_FETCH:-0}" != "1" ]; then
  git fetch -q origin 2>/dev/null || true
  UP=$(git show origin/main:docs/process/merge-gates.tsv 2>/dev/null | grep -v '^#' | cut -f1 | sed '/^$/d' | LC_ALL=C sort)
  LOC=$(grep -v '^#' "$REG" 2>/dev/null | cut -f1 | sed '/^$/d' | LC_ALL=C sort)
  UPFULL=$(git show origin/main:docs/process/merge-gates.tsv 2>/dev/null | grep -v '^#' | sed '/^$/d')
  LOCFULL=$(grep -v '^#' "$REG" 2>/dev/null | sed '/^$/d')
  if [ -n "$UP" ]; then
    MISSING=$(comm -23 <(printf '%s
' "$UP") <(printf '%s
' "$LOC") | tr '
' ' ' | sed 's/ *$//')
    EXTRA=$(comm -13 <(printf '%s
' "$UP") <(printf '%s
' "$LOC") | tr '
' ' ' | sed 's/ *$//')
    UPN=$(printf '%s
' "$UP" | grep -c .)
    # ★★★分開兩種:【缺】才是警報,【多】只是分叉(本地新註冊還沒 push)——
    #   ★血證 2026-09-03:第一版把兩者混成同一句 ⇒ 本地只多一支時,它印出「缺的那幾支沒有跑過」
    #   ⇒ ★★守衛自己說了一句【不是事實】的話,而那比沒有守衛更糟。
    [ -n "$MISSING" ] && STALE_NOTE="★註冊表落後 origin/main：缺 $MISSING"
    [ -n "$EXTRA" ] && FORK_NOTE="★本地多出（分叉，非缺失；多半是還沒 push 的新閘）：$EXTRA"
    # ★★★定義差異（2026-09-08 血證）—— 舊版只比【閘名集合】(cut -f1)，
    #   而閘可以名字在、【定義壞掉】。血證：`computed-prop` 的 expect 在 main 上已修成
    #   `\[COMPUTED-PROP\] PASS`，而兩支 feature branch 上還是未跳脫的版本
    #   ⇒ grep -qE 把 `[...]` 當字元類 ⇒ ★那支閘在那兩棵樹上【永遠不可能綠】，
    #     而新鮮度檢查說【一支也不缺】。
    #   ⇒ ★★一個只看名字的新鮮度檢查，對【定義腐壞】天生盲。
    DEFDIFF=$(awk -F'	' 'NR==FNR{u[$1]=$0; next} ($1 in u) && u[$1]!=$0 {printf "%s ", $1}'       <(printf '%s
' "$UPFULL") <(printf '%s
' "$LOCFULL") 2>/dev/null | sed 's/ *$//')
    [ -n "$DEFDIFF" ] && DEF_NOTE="★定義與 origin/main 不同（名字在、內容不一樣）：$DEFDIFF"
    [ -n "${DEF_NOTE:-}" ] && echo "[MERGE-GATES] $DEF_NOTE"   # ★無條件印：算了不印＝沒接電
    UPSTREAM_N="$UPN"
  fi
fi
MG_BASE=".claude/hooks/.merge-gates-main-baseline"
# ★★★main 基線紅數（blueprint 裁 2026-09-10）：「main 紅了沒有人發現」不能再靠
#   誰去開一個 worktree 重跑才知道 —— ★紅的閘＝沒有閘：main 基線紅 ⇒ 每個 branch 都
#   「跟 main 一樣紅」⇒ 閘零鑑別力，而它【比擋住更糟：它在默默放行】。
# ★★而這個數字是【快取】⇒ 它會過期 ⇒ 所以連同 HEAD 一起印，並印出 main 已經走了幾個 commit
#   （★★★把過期【變成看得見的】，而不是讓它安靜地騙人）。
if [ -f "$MG_BASE" ]; then
  IFS=$'	' read -r _b_head _b_red _b_when < "$MG_BASE"
  _b_gap=$(git rev-list --count "$_b_head"..main 2>/dev/null || echo "?")
  if [ "${_b_red:-0}" -gt 0 ] 2>/dev/null; then
    echo "[MERGE-GATES] ★★★main 基線紅數 ＝ $_b_red（量於 $_b_head / $_b_when；main 之後又走了 $_b_gap 個 commit）"
    echo "[MERGE-GATES]   ⇒ ★在它歸零之前，本輪的紅【不能直接算在你頭上】，而綠也【不代表 main 是綠的】。"
  else
    echo "[MERGE-GATES] main 基線紅數 ＝ 0（量於 $_b_head / $_b_when；main 之後又走了 $_b_gap 個 commit）"
  fi
else
  echo "[MERGE-GATES] ★main 基線紅數【從未量過】—— 在 main、乾淨工作區跑一次本 runner 就會記下來"
fi
[ -f "$REG" ] || { echo "[MERGE-GATES] FAIL：註冊表不存在 $REG"; exit 1; }
# ★★★註冊表不得有重複 id（systems 2026-09-10 血證）：
#   `gather-purity` 曾經有【兩列】，兩列的 expect 不同 ⇒ 同一支閘跑兩次、
#   一次✓一次 no-verdict，★而沒有任何人看得出來那是【同一支】——
#   ★★它看起來像「閘時好時壞」，實際上是兩個判準在比同一份輸出。
_mg_dup=$(awk -F'	' '!/^#/ && NF>=2 {print $1}' "$REG" | sort | uniq -d)
if [ -n "$_mg_dup" ]; then
  echo "[MERGE-GATES] ★★★註冊表有重複 id：$_mg_dup ⇒ 同一支閘會跑多次且判準不一致"
  exit 2
fi
# ★★★分批跑（systems 2026-09-12）：這台機器與用戶的遊戲共用，整包跑被 OOM 殺過兩次。
#   `MG_FROM` / `MG_TO`（第幾支，1-based，含頭含尾）⇒ 只跑那一段。
#   ★而它有一個危險：**跑一半也會印完成**，人會把它讀成【綿了】。
#   ⇒ ★★所以分批時**橫幅印 PARTIAL**，且結尾明文寫【不可當 merge 判決】。
MG_FROM="${MG_FROM:-0}"; MG_TO="${MG_TO:-0}"
if [ "$MG_FROM" != "0" ] || [ "$MG_TO" != "0" ]; then
  echo "[MERGE-GATES] ★★★PARTIAL：本輪只跑第 ${MG_FROM:-1}–${MG_TO:-末} 支 ⇒ **不可當 merge 判決**"
fi
FAILED=(); TOTAL0=$SECONDS; N=0; RUN_N=0
# ★★★2026-09-06:讀進來先剝 ``(systems 血證)——工作區的 TSV 若被某人用 Windows 換行寫過,
#   `expect` 會尾帶 `` ⇒ grep 永遠匹配不到 ⇒ ★【23 支全部 no-verdict】而閘本身全是好的。
#   ★★而 .gitattributes 已 eol=lf ⇒ repo 的 blob 是乾淨的,壞的只有【工作區那一份】
#   ⇒ ★★★所以修在【讀取端】:誰寫的都不會再毒到判準。
while IFS=$'	' read -r id cmd purpose expect; do
  id="${id%$''}"; cmd="${cmd%$''}"; purpose="${purpose%$''}"; expect="${expect%$''}"
  case "$id" in ''|'#'*) continue;; esac
  N=$((N+1)); T0=$SECONDS
  if [ "$MG_FROM" != "0" ] && [ "$N" -lt "$MG_FROM" ]; then continue; fi
  if [ "$MG_TO" != "0" ] && [ "$N" -gt "$MG_TO" ]; then continue; fi
  RUN_N=$((RUN_N+1))
  if [ -z "${expect:-}" ]; then
    echo "[MERGE-GATES] ✗ $id —— ★沒有 expect 欄：不能有「沒有判準也算過」的路徑"
    FAILED+=("$id(no-expect)"); continue
  fi
  OUT=$(eval "$cmd" 2>&1); RC=$?
  DT=$((SECONDS-T0))
  # ★★★2026-09-02 修假紅（implementer 揭）：原本這裡還 grep 輸出裡的 "FAIL"
  #   ⇒ ★而閘【自己的說明文字】裡就有那個字（例：bare-tick 檔頭解釋什麼情況會 FAIL）
  #   ⇒ ★★於是一支 exit 0、且印了 PASS 的閘被判 ✗ —— ★★★「談論一個字」與「用它下判決」在文字上不可分
  #   ⇒ 修法：★只信【exit code】＋【expect 命中】—— 兩者都是【結構化位置】，不是正文。
  if [ $RC -ne 0 ]; then
    echo "[MERGE-GATES] ✗ $id （${DT}s）—— $purpose"
    # ★★★2026-09-15：原本這裡只印【最後五行】⇒ 而【被點名的那幾行】常常在前面
    #   ⇒ ★★【主詞被截掉】。血證：bed-kind 印了「紅 2 支」，
    #   而那兩行「★紅 <檔名>」恰好被排出最後五行
    #   ⇒ 讀的人只看到一個可歸因的原因就停了，漏掉另一支。
    #   ⇒ ★【判決沒有主詞】不是閘的錯，是【這裡】把主詞丟掉的。
    #   ★★只改【顯示】不改【判決】：判決仍然只信 exit code ＋ expect 命中。
    _mg_named=$(printf '%s
' "$OUT" | grep -E '紅 |FAIL：|違規|未宣告|缺【' | grep -vE '^\[MERGE-GATES\]' | tail -8)
    if [ -n "$_mg_named" ]; then printf '%s
' "$_mg_named"; fi
    printf '%s
' "$OUT" | tail -5; FAILED+=("$id")
  elif ! printf '%s' "$OUT" | grep -qE -- "$expect"; then
    echo "[MERGE-GATES] ✗ $id （${DT}s）—— ★★跑完了但【沒有印出它該印的結論】"
    echo "    expect: $expect"; printf '%s
' "$OUT" | tail -3
    FAILED+=("$id(no-verdict)")
  else
    echo "[MERGE-GATES] ✓ $id （${DT}s）"
  fi
done < "$REG"
# ★★★2026-09-16：**一輪之內兩棵樹**。血證：55 支正在跑的時候有人 commit
#   ⇒ ★**前半輪與後半輪跑在不同的樹上**，而開跑那一刻的 [TREE] 戳記看不到這件事
#   ⇒ ★★**只戳開頭，答不出中間有沒有變** —— 與「只印起跑的 host 記憶體」同構
#   ⇒ ★★★**結束時再戳一次並比對；不同 ⇒ 大聲印 ＋ 本輪【不可判】**
_mg_head_end=$(git rev-parse --short HEAD 2>/dev/null || echo '?')
if [ "$_mg_head_end" != "$_mg_head" ]; then
  echo "[MERGE-GATES] ★★★本輪【不可判】：開跑 HEAD=$_mg_head，結束 HEAD=$_mg_head_end"
  echo "[MERGE-GATES]   ⇒ ★一輪之內兩棵樹 —— 前半與後半跑的不是同一份 code。"
  echo "[MERGE-GATES]   ⇒ ★★綠與紅都不算 —— 停掉、乾淨重跑。"
fi
echo "───────────────────────────────"
if [ "$MG_FROM" != "0" ] || [ "$MG_TO" != "0" ]; then
  echo "[MERGE-GATES] ★★★PARTIAL：【實跑 $RUN_N 支】（註冊表 $N 支）｜總時 $((SECONDS-TOTAL0))s"
  echo "[MERGE-GATES]   ⇒ ★**不可當 merge 判決** —— 判決需要各批的【聯集】覆蓋整張註冊表。"
else
echo "[MERGE-GATES] 註冊表 $N 支｜總時 $((SECONDS-TOTAL0))s"
fi
# ★★「乾淨」只算【會影響判決的那幾個路徑】（scripts / .claude / 註冊表）：
#   ★★★本專案是多終端共用同一個 main 工作區，它【幾乎永遠是髒的】（別人的信、量測檔）
#   ⇒ 若要求全樹乾淨，這個基線【永遠不會被記下來】＝又一支裝好但沒接電的守衛。
# ★★★記的是【開跑那一刻的 HEAD】（$_mg_head）而不是結束時的：
#   一輪要跑十分鐘，期間別人（或我自己）很可能又 commit 了
#   ⇒ 用結束時的 HEAD 會把【根本沒被跑過的 code】記成已經量過。
# ★只有【在 main 上、且工作區乾淨】的那一輪才有資格更新基線（否則記的是某個人的工作區）
# ★★★2026-09-15 第二個洞（同一段）：舊條件只看【分支＋工作區乾淨】，沒看【有沒有跑完】
#   ⇒ ★一輪 **分批跑**（MG_FROM/MG_TO）會拿【邨分的紅數】去寫基線
#   ⇒ ★★而配上剛加的 ratchet（降低就寫）**反而更壞**：分批跑的紅數天生較小
#     ⇒ **基線會被一輪沒跑完的路静默地洗到 0**。
#   ⇒ ★★★**只有完整跑的那一輪才有資格碰基線。**
if [ "$(git rev-parse --abbrev-ref HEAD 2>/dev/null)" = "main" ] && [ -z "$(git --no-optional-locks status --porcelain -- scripts .claude docs/process/merge-gates.tsv 2>/dev/null)" ] && [ "$MG_FROM" = "0" ] && [ "$MG_TO" = "0" ]; then
  # ★★★2026-09-15：基線【只准往下】（ratchet）—— 血證：本輪跑出一個【新】紅（defer-phrase），
  #   而舊邏輯把它直接寫成新基線 1 → 2 ⇒ ★**新紅在它的第一輪就被洗進基線**
  #   ⇒ ★★「第二個紅就是新造的」這條紀律會自己解體（門檻跟著錯誤一起往上走）。
  #   ⇒ ★★★修法：**降低才自動寫入；上升要明示 `MG_BASELINE_RAISE=1`**（而且要印得大聲）。
  _mg_prev=$(cut -f2 "$MG_BASE" 2>/dev/null | head -1)
  case "$_mg_prev" in ''|*[!0-9]*) _mg_prev=-1 ;; esac
  if [ "$_mg_prev" -ge 0 ] && [ ${#FAILED[@]} -gt "$_mg_prev" ] && [ "${MG_BASELINE_RAISE:-0}" != "1" ]; then
    echo "[MERGE-GATES] ★★★基線【未更新】：本輪紅數 ${#FAILED[@]} ＞ 基線 $_mg_prev"
    echo "[MERGE-GATES]   ⇒ ★基線只准往下（ratchet）—— **否則新紅會在它的第一輪就被洗進基線**，"
    echo "[MERGE-GATES]     而「第二個紅就是新造的」這條紀律會自己解體。"
    echo "[MERGE-GATES]   ⇒ ★★修掉那個紅，或者確定要抬門檻就跨 MG_BASELINE_RAISE=1 重跑（並在 commit 說明理由）。"
  else
    printf '%s	%s	%s
' "$_mg_head" "${#FAILED[@]}" "$(date -u +%Y-%m-%dT%H:%MZ)" > "$MG_BASE"
    echo "[MERGE-GATES] ★已更新 main 基線紅數 ＝ ${#FAILED[@]}"
  fi
else
  # ★★★2026-09-15：這一行原本只講【三個可能原因之一】而不講【是哪一個】
  #   ⇒ ★又是【判決沒有主詞】（同一支檔今天已經為這件事修過一次）⇒ 逐條點名。
  _mg_why=""
  [ "$(git rev-parse --abbrev-ref HEAD 2>/dev/null)" != "main" ] && _mg_why="$_mg_why 不在 main"
  [ -n "$(git --no-optional-locks status --porcelain -- scripts .claude docs/process/merge-gates.tsv 2>/dev/null)" ] && _mg_why="$_mg_why scripts/.claude/註冊表有未-commit 改動"
  { [ "$MG_FROM" != "0" ] || [ "$MG_TO" != "0" ]; } && _mg_why="$_mg_why 本輪是分批跑（沒跑完整註冊表）"
  echo "[MERGE-GATES] ★本輪【沒有】更新 main 基線紅數 —— 原因：$_mg_why"
  echo "[MERGE-GATES]   ⇒ ★★這一行必須存在：静默的【沒有記下來】跟【記下來了】在畫面上長得一樣。"
fi
if [ ${#FAILED[@]} -gt 0 ]; then
  echo "[MERGE-GATES] FAIL：${FAILED[*]}"
  echo "★註冊表在 $REG —— ★★新增閘＝往那裡加一行（★★★含 expect，否則直接 FAIL）"
  exit 1
fi
if [ -n "${STALE_NOTE:-}" ]; then
  echo "[MERGE-GATES] PASS（$N/${UPSTREAM_N:-?}）—— $STALE_NOTE"
  echo "[MERGE-GATES] ★★這【不是】「全部通過」：★★★缺的那幾支【沒有跑過】，而它們正是最新加的（多半在守你剛做的東西）"
elif [ "${RUN_N:-0}" = "0" ]; then
  # ★★★【實跑 0 格 ＝ 紅】（systems 立 2026-09-12）：
  #   「一支也沒跑」與「全部通過」在畫面上一樣 —— 兩者都是**沒有紅字 ＋ rc=0**。
  #   ★而這支工具自己就有這個洞：`MG_FROM=999` ⇒ 跑 0 支 ⇒ 印 PASS、rc=0。
  echo "[MERGE-GATES] ★★★紅：【實跑 0 支】—— 這不是「全過」，是【什麼都沒跑】"
  echo "[MERGE-GATES]   ⇒ 檢查 MG_FROM/MG_TO 是不是把整張註冊表濾掉了"
  exit 1
elif [ -n "${FORK_NOTE:-}" ]; then
  echo "[MERGE-GATES] PASS：本地這 $N 支全部通過｜${FORK_NOTE}"
else
  echo "[MERGE-GATES] PASS：全部通過（★每一支都印出了它該印的結論）"
fi
