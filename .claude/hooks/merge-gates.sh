#!/usr/bin/env bash
# ★★★merge-gate runner —— 讀 docs/process/merge-gates.tsv，逐支跑，彙總。
#   ★用戶裁「搬」2026-09-01；★★而「搬完要可執行」是 systems 的 HOW 裁。
#   ★★★2026-09-01 補正（implementer 揭）：原版【沒有執行註冊表的判準欄】
#     ⇒ 一支「跑了、exit 0、什麼都不斷言」的閘會拿到 ✓ ⇒ ★那是假綠。
#     ⇒ 現在：★★exit code 通過【還不夠】，輸出必須命中 expect；★★★沒寫 expect 的行直接 FAIL。
#   ★誠實限：runner 讓「跑」變便宜，但【跑得久】仍會讓人跳過 ⇒ 報每支耗時與總時。
set -u
# ★★★離開碼印在卷面上（systems 2026-09-23，implementer 指出）：
#   我在信裡要人回報「BATTERY_RC= 那一行的數字」——★而這支 runner 從來沒印過那個字面，
#   那一行只存在於【我自己那層 shell 的 echo】⇒ 我要的是一個【不存在於這份卷面】的東西。
#   ★★而回報的人只能改口報離開碼，那一步靠的是他誠實，不是靠卷面。
#   ⇒ 用 trap 印在【每一條離開路徑】上：包含 exit 1／exit 2／提前 exit 0，一條都不會漏。
#   ★★★這是【構造保證】：在每個 exit 前面各加一行，會因為有人新增一條路徑而漏掉。
trap '_rc=$?; rm -f "${MG_RUNFLAG:-}" 2>/dev/null; echo "[MERGE-GATES] BATTERY_RC=$_rc"' EXIT

# ★★★【一次只准一份】的剎車（blueprint 指派 2026-09-23，血證：兩輪電池平行跑把機器吃爆）
#   ★★為什麼不用「掃命令列裡有沒有 merge-gates」：★那會抓到【正在查這件事的那條指令自己】
#     —— 2026-09-23 同一小時內三個人各踩一次（systems／implementer／blueprint）
#     ⇒ 普查的第一個問題不是「有沒有別人」，是【樣本裡有沒有我自己】。
#   ⇒ ★改成【構造】而不是【普查】：自己寫一個標記檔，裡面放自己的 PID。
# ★★★而標記檔【單獨不夠】：harness 殺 shell 時 trap 不會跑 ⇒ 標記是舊的，
#   而它的 Windows 子樹【還活著】（那正是 2026-09-23 那兩輪孤兒電池的形狀）
#   ⇒ 所以第二道是【Godot 行程數】：開跑前不是 0 就不可判。
# ★★★標記檔必須落在【main 工作樹】，不是「跑的人所在的那棵樹」（systems 修 2026-09-23）：
#   2026-09-23 起電池改在 worktree 跑（共用 main dir 上 HEAD 會漂移）⇒ 相對路徑的標記
#   會寫進【worktree 自己的】.claude/hooks/ ⇒ ★main 裡的人看不到它
#   ⇒ ★★這道「一次只跑一輪」的煞車會【被 worktree 破解】（兩棵樹各跑一輪，互相看不見）
#   ⇒ ★★★而更常見的後果是交接誤判：別的角色量「Godot=0」就以為機器空了 —— 見下一格。
#   `--git-common-dir` 在 worktree 裡回傳 main 的 .git；在 main 裡回傳 .git ⇒ 一份程式碼兩邊都對。
_mg_gc="$(git rev-parse --git-common-dir 2>/dev/null || echo .git)"
_mg_root="$(cd "$(dirname "$_mg_gc")" && pwd)"
MG_RUNFLAG="$_mg_root/.claude/hooks/.merge-gates-running"
# ★★★偵測端要掃【所有樹】，不只 main（systems 修 2026-09-23，implementer 當場逮到）：
#   上面那個「標記落 main 工作樹」的修法只存在於【已經把 main 併進來的樹】——
#   分支／worktree 上的這支檔案可能還是舊版，而舊版把標記寫進【它自己那棵樹】。
#   ⇒ ★只看 main 的路徑 ⇒ 看不到舊版正在跑的那一輪 ⇒ 兩輪同時跑。
#   ⇒ ★★★通則：**一個依賴「大家都跑新版」的守衛不是守衛。**
#     寫入端可以只寫新位置；★讀取端必須看得見【舊寫入端會寫的每一個位置】。
#   ★★★樹的清單問 git，不要用路徑樣式猜：實測 68 棵裡有 6 棵不在 .worktrees/ 底下。
while IFS= read -r _mg_wt; do
  [ -n "$_mg_wt" ] || continue
  _mg_f="$_mg_wt/.claude/hooks/.merge-gates-running"
  [ -f "$_mg_f" ] || continue
  _mg_other=$(awk '{print $1; exit}' "$_mg_f" 2>/dev/null)
  if [ -n "$_mg_other" ] && kill -0 "$_mg_other" 2>/dev/null; then
    echo "[MERGE-GATES] ★★★本輪【不可判】：已經有一輪電池在跑（PID $_mg_other）"
    echo "[MERGE-GATES]   ⇒ 標記：${_mg_f#$_mg_root/}"
    echo "[MERGE-GATES]   ⇒ 兩輪平行跑會互相拖慢並把機器吃爆（2026-09-23 血證）"
    echo "[MERGE-GATES]   ⇒ ★等它跑完，或確認那顆 PID 已死之後刪那個檔"
    exit 2
  fi
  echo "[MERGE-GATES] ★舊標記（PID ${_mg_other:-?} 已不在）：${_mg_f#$_mg_root/} ⇒ 接手。★★而【標記舊】不代表機器空：見下一格"
done <<EOF_MGWT
$(git worktree list --porcelain 2>/dev/null | awk '/^worktree /{ $1=""; sub(/^ /,""); print }')
EOF_MGWT
# ★只寫數字在第一行（後面那些欄位是給【人】讀的，程式只讀第一個 token）——
#   含跳脫字元的寫法在寫檔時會變成真的換行，今天已經咬過兩次。
printf '%s tree=%s since=%s
' "$$" "$(pwd)" "$(date +%FT%T)" > "$MG_RUNFLAG"
# 只留數字：不要用含跳脫字元的寫法（那個跳脫在寫檔時會變成真的換行，今天已經咬過兩次）
_mg_godot_n=$(powershell -NoProfile -Command '@(Get-Process godot* -ErrorAction SilentlyContinue).Count' | tr -dc '0-9')
if [ "${_mg_godot_n:-0}" != "0" ]; then
  echo "[MERGE-GATES] ★★★本輪【不可判】：開跑前 Godot 行程數 ＝ $_mg_godot_n（必須是 0）"
  echo "[MERGE-GATES]   ⇒ 可能是①別人在跑床 ②用戶自己的遊戲 ③上一輪被殺之後留下的【孤兒子樹】"
  echo "[MERGE-GATES]   ⇒ ★★③的清法是【殺整棵樹】不是殺根：Windows 上殺父不會帶走子孫"
  echo "[MERGE-GATES]   ⇒ ★★★而②【不准殺】—— 機器是跟用戶的遊戲共用的"
  rm -f "$MG_RUNFLAG"
  exit 2
fi


# ★★★記憶體卷面（blueprint 要求 2026-09-23，上一輪在第 6／75 支被 OOM 收掉）：
#   ★跑前印 FreeMB ＋ top-5；跑中每 5 支印一次 ⇒ 下次被殺時，卷面自己說得出【當時剩多少】。
#   ★★沒有這一格的話，「為什麼被殺」永遠只能事後猜。
_mg_freemb() {
  powershell -NoProfile -Command "[int]((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory/1KB)" 2>/dev/null | tr -d "
"
}

cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)" || exit 2
# ★★★2026-09-23：讓註冊表路徑可被 MG_REG 覆寫 —— ★理由是【這支 runner 自己要能被驗】。
#   血證：我當天加了「執行期錯誤 ⇒ 判紅」這條判決，★而我【拿不出它會紅的證據】——
#     真正的註冊表上 76 支沒有一支會印 SCRIPT ERROR（那是好事），
#     ⇒ ★★所以那條新判決在真實電池上【永遠不會被走到】，它跟一條恆綠的守衛沒有差別。
#   ⇒ ★★★而我整天都在要求別人「拿出它會紅的注射」—— 這一行就是讓我能對自己做同一件事。
#   ★預設不變；只有明確設了 MG_REG 才換（★而換了會在開頭印出來，不讓它靜默）。
REG="${MG_REG:-docs/process/merge-gates.tsv}"
[ "$REG" != "docs/process/merge-gates.tsv" ] && echo "[MERGE-GATES] ★★註冊表被覆寫：$REG（★這一輪【不是】正式判決）"

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
# ★★★2026-09-16：**runner 自己的指紋**。血證：implementer 寫「這一輪沒有印【不可判】
#   ⇒ 開跑與結束是同一棵樹」—— ★**而那支偵測器根本不在他跑的那一份裡**
#   （他 worktree 的 runner 227 行、0 個「不可判」；main 的 237 行、2 個）
#   ⇒ ★★**他把「儀器沒裝」讀成了「沒發生」**。
#   ⇒ ★★★**而這個 repo 有 20 個 worktree ⇒ 20 份複本、版本各不相同**
#     ⇒ **「某個守衛沒叫」在複本不一致的期間【不可當證據】。**
#   ⇒ 修法：**讓 runner 宣告自己是哪一份** —— **沉默就不再是證據，缺席變得可見。**
_mg_self="$(git hash-object "${BASH_SOURCE[0]}" 2>/dev/null | cut -c1-8)"
[ -z "$_mg_self" ] && _mg_self="?"
echo "[MERGE-GATES] runner-self=$_mg_self lines=$(wc -l < "${BASH_SOURCE[0]}" | tr -d ' ') run-id=$$-$(date +%H%M%S)｜★兩人對照綠不綠之前，先對這一串；★★同一份檔裡出現兩個不同的 run-id ＝ **兩輪的輸出疊在一起→不可判**"
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
    # ★★★2026-09-22（systems，implementer 撞到）：這兩句原本【只掛在最後的 PASS 分支上】
    #   ⇒ 只要有任何一支紅，FAILED 那段的 `exit 1` 就先走掉 ⇒ ★【少跑了哪幾支】整句消失。
    #   ★血證：電池 2 紅 ⇒ implementer 是【自己用手 grep】才發現 world-fp 兩行沒跑到。
    #   ⇒ ★★守衛的輸出不可以被【另一個守衛開火】吃掉 ⇒ 在這裡無條件印一次。
    [ -n "${STALE_NOTE:-}" ] && echo "[MERGE-GATES] $STALE_NOTE ★★這幾支【沒有跑過】"
    [ -n "${FORK_NOTE:-}" ] && echo "[MERGE-GATES] $FORK_NOTE"
    UPSTREAM_N="$UPN"
  fi
fi
# ★★★2026-09-17（systems，merge 時自撞）：這個路徑原本是【相對】的 ——
#   而 `.claude/hooks/*` 是 gitignored ⇒ 基線檔【只存在於主工作區】。
#   ⇒ 在【暫時 merge worktree】裡跑（★而那正是唯一判 merge 的地方），它找不到檔
#     ⇒ 每一次 merge 都印「★main 基線紅數【從未量過】」⇒ ★★**分不出【本票造成的紅】與【main 本來就紅】**
#     ⇒ 正是上面那段 blueprint 裁定要防的事（「紅的閘＝沒有閘…它在默默放行」）
#   ⇒ ★★★修法是【接線】不是加閘：一律解析到【主工作區】的那一份。
_mg_common=$(git rev-parse --git-common-dir 2>/dev/null || echo ".git")
MG_BASE="$(dirname "$_mg_common")/.claude/hooks/.merge-gates-main-baseline"
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
ENVFAIL=()
# ★★★2026-09-06:讀進來先剝【CR＝0x0D】(systems 血證)——工作區的 TSV 若被某人用 Windows 換行寫過,
#   expect 會尾帶 0x0D ⇒ grep 永遠匹配不到 ⇒ ★【23 支全部 no-verdict】而閘本身全是好的。
#   ★★而 .gitattributes 已 eol=lf ⇒ repo 的 blob 是乾淨的,壞的只有【工作區那一份】
#   ⇒ ★★★所以修在【讀取端】:誰寫的都不會再毒到判準。
# ★★★2026-09-22 systems 自犯:上面那段【原本用一個真的 0x0D 位元組來說明 0x0D】,
#   而編輯工具把它換成 0x0A ⇒ 下一行的 ${id%...} 變成剝換行 ⇒ read 早就剝掉了 ⇒ ★純 no-op。
#   ⇒ ★★守衛死了、語法仍合法、不報錯;腐蝕方向是【綠→紅】(:174 expect 未命中不走 pass) 所以沒造假綠。
#   ⇒ ★★★修法:文件裡【不要放那個位元組本身】,寫它的名字。改動本檔後必跑剝除的陽性對照。
echo "[MERGE-GATES] ★開跑前 FreeMB=$(_mg_freemb)｜top-5 記憶體："
powershell -NoProfile -Command "Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 5 Name,@{n='MB';e={[int](\$_.WorkingSet64/1MB)}} | ForEach-Object { '[MERGE-GATES]   ' + \$_.Name + ' ' + \$_.MB + 'MB' }" 2>/dev/null
echo "[MERGE-GATES]   ★Godot 行程數=$(powershell -NoProfile -Command '@(Get-Process godot* -ErrorAction SilentlyContinue).Count' 2>/dev/null | tr -d '
')（★開跑前必須是 0）"
while IFS=$'	' read -r id cmd purpose expect; do
  id="${id%$''}"; cmd="${cmd%$''}"; purpose="${purpose%$''}"; expect="${expect%$''}"
  case "$id" in ''|'#'*) continue;; esac
  N=$((N+1)); T0=$SECONDS
  if [ "$MG_FROM" != "0" ] && [ "$N" -lt "$MG_FROM" ]; then continue; fi
  if [ "$MG_TO" != "0" ] && [ "$N" -gt "$MG_TO" ]; then continue; fi
  RUN_N=$((RUN_N+1))
  if [ $((RUN_N % 5)) -eq 1 ]; then
    echo "[MERGE-GATES] ★記憶體：第 ${RUN_N} 支之前 FreeMB=$(_mg_freemb)"
  fi
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
  # ★★★2026-09-22：【環境紅 ≠ 測試紅】—— 血證：新機的 PowerShell 停用指令碼執行
  #   ⇒ tools/godot.ps1 【一次都沒被載入】
  #   ★★★訂正（2026-09-22 當天，implementer 揭）：我原本在這裡寫「而它的 rc＝0、第一道 RC 判準抓不到」
  #     —— 【那是錯的】：實測 rc＝1（runner 的 OUT=$(eval …); RC=$? 沒接管線，拿得到真值）
  #     ★我那個 0 是【我自己接了 | head 吃掉回傳碼】量出來的 ⇒ 同日第三次同家族（2>/dev/null／| tail -1／| head）
  #   ⇒ ★★所以本分類的理由【不是 rc 騙人】，是【環境失敗與測試失敗要分顏色】：
  #     兩者都是 rc≠0，而它們要人做的事完全相反（一個去換發射器，一個去修 code）
  #   ⇒ ★★將【引擎沒啟動】判成【測試失敗】＝把環境的病記在 code 頭上
  #   ★★★順序有意義：【真的通過】先判（rc＝0 且 expect 命中）—— 否則一支【談論這些字】的閘會被誤判成環境紅
  #   ★誠實限：本判準只認【已知的環境簽名】；新的環境毛病會被归回測試紅（而那時就把它釘進來）
  _mg_env=0
  if ! { [ $RC -eq 0 ] && printf '%s' "$OUT" | grep -qE -- "$expect"; }; then
    # ★★★2026-09-23 追加 0xC0000142（implementer 血證）：`child exit=-1073741502`
    #   ＝ DLL initialization failed ⇒ ★【行程根本沒起來】—— 引擎一次都沒被執行
    #   ⇒ ★★它與「測試失敗」是兩件事，而它在畫面上長得一模一樣（都是一支紅）
    #   ★★★而它那一輪是在【記憶體壓力】之下發生的（同一輪電池稍後被 harness 收掉）
    #     ⇒ 這個碼出現時要先看 FreeMB，不要先查那支床
    # ★★★而【成因要分開講】：這一行原本對所有環境紅都印「PowerShell 停用指令碼執行」
    #   ⇒ 而 0xC0000142 那一種根本不是那個成因 ⇒ ★守衛印了一個【錯的解釋】，
    #     那比不印更糟（讀的人會照著它去查錯的東西）。
    _mg_env_why=""
    if printf '%s' "$OUT" | grep -qE 'UnauthorizedAccess|已停用指令碼執行|running scripts is disabled|無法載入.*\.ps1|cannot be loaded'; then
      _mg_env=1; _mg_env_why="PowerShell 停用指令碼執行（★修法：PSExecutionPolicyPreference=Bypass）"
    elif printf '%s' "$OUT" | grep -qE 'child exit=-1073741502|0xC0000142'; then
      _mg_env=1; _mg_env_why="DLL init failed（0xC0000142）＝行程根本沒起來 ★先看 FreeMB，不要先查那支床"
    elif printf '%s' "$OUT" | grep -qE '這一輪沒有真的重跑'; then
      _mg_env=1; _mg_env_why="這一輪沒有真的重跑"
    elif printf '%s' "$OUT" | grep -qaE 'Exception setting "OutputEncoding"|管道另一端上無任何處理程序|No process is on the other end of the pipe|commit=UNKNOWN \(git said nothing\)'; then
      # ★★★2026-09-23（第三族，來自 .gate-fail 落檔）：wrapper 在第 20 行設
      #   [Console]::OutputEncoding 就炸了，成因是【stdout 管道的另一端沒有了】
      #   ⇒ ★整個外層已經在死 —— 那不是那支床的錯
      #   ★★而同一份落檔裡 `[TREE] commit=UNKNOWN (git said nothing)` 也是同一個症狀：
      #     連 git 都叫不起來 ⇒ ★★★行程層級的問題，不是測試層級的
      _mg_env=1; _mg_env_why="stdout 管道已斷／外層正在死（★常與記憶體回收同時發生）★先看 FreeMB"
    fi
  fi
  if [ "$_mg_env" = "1" ]; then
    echo "[MERGE-GATES] ⚡ENV $id （${DT}s）—— ★★★環境失敗：引擎【一次都沒被啟動】（${_mg_env_why:-成因未分類}）"
    printf '%s
' "$OUT" | grep -E 'UnauthorizedAccess|已停用指令碼執行|無法載入|沒有真的重跑' | head -2
    ENVFAIL+=("$id"); continue
  fi
  # ★★★2026-09-23：紅的時候把【該支的完整輸出】落檔（systems 補，血證在下）。
  #   血證：ui-flow 在一輪電池裡紅了，而卷面上只留 expect 與實際那一行
  #   ⇒ ★格名在更前面的輸出裡，而那段【沒有被存下來】
  #   ⇒ ★★一個【不可重現】的紅，它的診斷資訊是一次性的 —— 錯過就沒有了
  #   ⇒ ★★★而這不是加閘：是讓既有的閘把【它已經拿在手上的東西】存下來。
  #   ★只在紅的時候寫（綠的輸出沒有人會回頭讀，寫了只是讓目錄長大）。
  _mg_dump() {
    local _d="$_mg_root/docs/measurements/.gate-fail"
    mkdir -p "$_d" 2>/dev/null
    local _f="$_d/$(date +%Y%m%d-%H%M%S)-$1.txt"
    printf '%s
' "$OUT" > "$_f" 2>/dev/null && echo "[MERGE-GATES]   ⇒ ★完整輸出已落檔：${_f#$_mg_root/}"
  }
  if [ $RC -ne 0 ]; then
    echo "[MERGE-GATES] ✗ $id （${DT}s）—— $purpose"
    # ★★★2026-09-15：原本這裡只印【最後五行】⇒ 而【被點名的那幾行】常常在前面
    #   ⇒ ★★【主詞被截掉】。血證：bed-kind 印了「紅 2 支」，
    #   而那兩行「★紅 <檔名>」恰好被排出最後五行
    #   ⇒ 讀的人只看到一個可歸因的原因就停了，漏掉另一支。
    #   ⇒ ★【判決沒有主詞】不是閘的錯，是【這裡】把主詞丟掉的。
    #   ★★只改【顯示】不改【判決】：判決仍然只信 exit code ＋ expect 命中。
    _mg_named=$(printf '%s
' "$OUT" | grep -E '✗|紅 |FAIL：|違規|未宣告|缺【' | grep -vE '^\[MERGE-GATES\]' | tail -8)
    if [ -n "$_mg_named" ]; then printf '%s
' "$_mg_named"; fi
    printf '%s
' "$OUT" | tail -5; _mg_dump "$id"; FAILED+=("$id")
  elif printf '%s' "$OUT" | grep -qaE '^(SCRIPT ERROR|USER SCRIPT ERROR|FATAL):'; then
    # ★★★2026-09-23：執行期錯誤【不能算綠】（systems 加，血證在下）。
    #   血證：ui_flow_test 一輪印了 64 次 `SCRIPT ERROR: Invalid call. Nonexistent 'String' constructor.`
    #     —— 那個錯把 `_build_survival_lines` 從中間砍斷（前面兩個 append 的結果一起消失），
    #     ★而那一輪的卷面是「errors: 1｜到場點名 31／31」：**點名滿分**。
    #   ⇒ ★★「到場點名」守的是【格有沒有跑完】，它守不住【格裡面的函式有沒有被砍斷】。
    #   ⇒ ★★★而 rc 也守不住：Godot 對執行期錯誤不改離開碼（這一輪 child exit=0）。
    #   ★三支既有 hook 早就認得這個形狀（bed-triage-sweep／headless-regression／test-ran-floor），
    #     ★★而 runner 本身【不認得】—— 這裡補的是那個缺口，不是新增一支閘。
    _mg_se=$(printf '%s' "$OUT" | grep -acE '^(SCRIPT ERROR|USER SCRIPT ERROR|FATAL):')
    echo "[MERGE-GATES] ✗ $id （${DT}s）—— ★★★執行期錯誤 ${_mg_se} 次（★expect 有命中、rc 也是 0，而它【不算綠】）"
    printf '%s' "$OUT" | grep -aE '^(SCRIPT ERROR|USER SCRIPT ERROR|FATAL):' | sort | uniq -c | sort -rn | head -3
    echo "[MERGE-GATES]   ⇒ ★一個執行期錯誤可以把【函式從中間砍斷】而讓它回傳空值，"
    echo "[MERGE-GATES]     ★★而呼叫端看到的是「這裡沒有東西」——那與「這裡本來就沒有東西」在卷面上長得一樣。"
    _mg_dump "$id-script-error"
    FAILED+=("$id(script-error)")
  elif ! printf '%s' "$OUT" | grep -qE -- "$expect"; then
    echo "[MERGE-GATES] ✗ $id （${DT}s）—— ★★跑完了但【沒有印出它該印的結論】"
    echo "    expect: $expect"; printf '%s
' "$OUT" | tail -3
    _mg_dump "$id-no-verdict"
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
  # ★★★2026-09-22 訂正（systems 自己踩到）：原本這一段【只有 print】——
  #   ⇒ 若所有閘都通過，下面照樣印「PASS：全部通過」而且 exit 0
  #   ⇒ ★**同一輪同時印「本輪不可判」與「全部通過」，回 rc=0** ＝ 一個假綠
  #   ⇒ ★★而「全部通過」這句在樹變過的那一輪【不指向任何一棵樹】
  #   ⇒ 修法：立旗標，讓它像環境紅一樣【壓過】PASS，並用同一個離開碼 2（不可判）
  _mg_undecidable=1
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
#     ⇒ **基線會被一輪沒跑完的路靜默地洗到 0**。
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
  echo "[MERGE-GATES]   ⇒ ★★這一行必須存在：靜默的【沒有記下來】跟【記下來了】在畫面上長得一樣。"
fi
# ★★★2026-09-22：【環境紅】先於【測試紅】報，而且它讓本輪【不可判】
#   ★理由：引擎沒啟動的那幾支，網與紅【都不算】—— 它們根本沒有被執行過
#   ★★而剩下那幾支的網也不能拿來充數：【部分樣本的綠】不是【全部通過】
#   ★★★且它【不進任何統計】：不進 FAILED、不更新基線紅數
if [ ${#ENVFAIL[@]} -gt 0 ]; then
  echo "[MERGE-GATES] ⚡環境紅 ${#ENVFAIL[@]} 支：${ENVFAIL[*]}"
  echo "[MERGE-GATES] ★★★本輪【不可判】—— 引擎在這幾支上【一次都沒被啟動】，綠與紅都不算"
  echo "[MERGE-GATES]   ⇒ ★這不是【測試失敗】，是【環境失敗】；兩者在畫面上曾經長得一模一樣"
  echo "[MERGE-GATES]   ⇒ ★★這一輪是【從錯的發射器】起跑的，而【修法是這一行】（2026-09-23 實測）："
  echo "[MERGE-GATES]"
  echo "[MERGE-GATES]        PSExecutionPolicyPreference=Bypass bash .claude/hooks/merge-gates.sh"
  echo "[MERGE-GATES]"
  echo "[MERGE-GATES]   ⇒ ★成因：Claude Code 的 PowerShell 工具進程 Process scope 已是 Bypass ⇒ 從那裡起跑就通；"
  echo "[MERGE-GATES]   ⇒ ★★Bash 工具裡 spawn 的 powershell 沒有那個 Process scope ⇒ 被擋（機器層本來就是 Undefined）"
  echo "[MERGE-GATES]   ⇒ ★★★上面那個環境變數會被子行程繼承 ⇒ 不必動註冊表的 76 列，也不要改機器的執行原則"
  echo "[MERGE-GATES]   ⇒ ★另一件同族的（跑之前先做）：電池要跑在【釘死 HEAD 的 worktree】，"
  echo "[MERGE-GATES]      否則共用 main dir 上 20 分鐘內 HEAD 會被別的角色推動 ⇒ 判【一輪之內兩棵樹】："
  echo "[MERGE-GATES]        git worktree add --detach .worktrees/battery \"\$(git rev-parse HEAD)\""
  echo "[MERGE-GATES]   ⇒ ★另一種環境紅：child exit=-1073741502（0xC0000142，DLL init failed）"
  echo "[MERGE-GATES]     ＝【行程根本沒起來】⇒ ★★先看 FreeMB（實測它與記憶體壓力同時發生），不要先查那支床"
  echo "[MERGE-GATES]   ⇒ ★★★本輪不更新基線、不計入任何統計"
  [ -n "${STALE_NOTE:-}" ] && echo "[MERGE-GATES]   ⇒ ★且本輪【少跑了】：$STALE_NOTE"
  exit 2
fi
if [ ${#FAILED[@]} -gt 0 ]; then
  echo "[MERGE-GATES] FAIL：${FAILED[*]}"
  [ -n "${STALE_NOTE:-}" ] && echo "[MERGE-GATES]   ⇒ ★★且本輪【少跑了】：$STALE_NOTE ★紅與【沒跑】是兩件事，別把後者讀成前者的配菜"
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
elif [ "${_mg_undecidable:-0}" = "1" ]; then
  echo "[MERGE-GATES] ★★★本輪【不可判】：每一支都通過了，★**但它們不是跑在同一棵樹上**"
  echo "[MERGE-GATES]   ⇒ ★**不得當作 merge 判決** —— 乾淨重跑一輪再說。"
  exit 2
elif [ -n "${FORK_NOTE:-}" ]; then
  echo "[MERGE-GATES] PASS：本地這 $N 支全部通過｜${FORK_NOTE}"
else
  echo "[MERGE-GATES] PASS：全部通過（★每一支都印出了它該印的結論）"
fi
