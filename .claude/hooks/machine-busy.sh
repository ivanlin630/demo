#!/usr/bin/env bash
# 機器忙不忙？——★六個角色交接機器時的【共用判準】（systems 建 2026-09-23）。
#
# ★★★為什麼需要這支（implementer 2026-09-23 揭，血證）：
#   我們整天用「Godot 行程數 = 0」當交接訊號，而它【不足以判機器空】——
#   他量到 0 的那一刻，我的電池正在跑（2 個 bash 在跑 merge-gates.sh，判決檔 8 秒前才寫過）。
#   ★那個 0 是【兩支床之間的空檔】：電池是一連串短跑，兩跑之間 Godot 真的是 0。
#   ⇒ ★★取樣式的判準對【一連串短工作】天生盲目 —— 不是量錯，是那個量在錯的軸上。
#
# ★★所以這支問兩件事，而【第一件是構造的、不是取樣的】：
#   ①電池標記檔（跑的人自己寫 PID，落在 main 工作樹 ⇒ worktree 也看得到）
#   ②Godot 行程數（抓單次長跑、用戶自己的遊戲、孤兒子樹）
#
# ★★★誠實限（寫在這裡，因為守衛不該讓人自己去猜它蓋不蓋得到）：
#   ★它蓋不到「有人正在手跑一支床、而剛好在兩次啟動之間」——那種用法沒有標記檔。
#     ⇒ 要跑一串床的人，請自己寫標記（或就用電池）。
#   ★★它不知道【誰】在用：FREE 只代表「現在沒有人在跑」，不代表「沒有人正要跑」。
#     ⇒ 交接仍然要寄信，這支只是讓那封信裡的數字是對的。
set -u
# ★★★2026-09-23：本支【可以直接幫你擋】—— 用法二（implementer 血證）：
#     bash .claude/hooks/machine-busy.sh -- <你的指令…>
#   ⇒ FREE 才執行那個指令；BUSY 就【不執行】並回 1。
#   ★血證：他寫 `machine-busy.sh; <指令>` —— ★★那個 `;` 讓檢查【只是印字】，
#     而指令照樣跑上我的電池。⇒ ★★★「回傳碼 1」只有在呼叫端【接了】它的時候才算擋。
#   ⇒ 所以把「要記得用 && 或 if」換成【本支自己執行那個指令】：★規矩變成會擋的東西。
_mb_cmd_mode=0
if [ "${1:-}" = "--" ]; then _mb_cmd_mode=1; shift; fi
_gc="$(git rev-parse --git-common-dir 2>/dev/null || echo .git)"
_root="$(cd "$(dirname "$_gc")" && pwd)"
FLAG="$_root/.claude/hooks/.merge-gates-running"

busy=0
# ★★★掃【所有樹】的標記，不只 main（systems 修 2026-09-23，implementer 當場逮到）：
#   main 的 merge-gates.sh 今天改成把標記寫進 main 工作樹，★而【別棵樹上的 code 還是舊版】
#   ——分支／worktree 要等它們把 main 併進來才會拿到那個修法。
#   ⇒ ★★所以舊版寫的標記仍然落在【它自己那棵樹】⇒ 只看 main 就會回 FREE，而電池正在跑。
#   ⇒ ★★★通則：**一個依賴「大家都跑新版」的守衛不是守衛。**
#     讀取端要能看見【舊寫入端會寫的每一個位置】，而不是只看新位置。
#   ★★★而【樹的清單要問 git，不要用路徑樣式猜】（systems 再修 2026-09-23）：
#     我第一版寫 "$_root"/.worktrees/*/… —— ★實測 `git worktree list` 共 68 棵，
#     其中 **6 棵不在 .worktrees/ 底下**（A:/GDS/_gt4…_gt8 那幾棵）⇒ 那個 glob 對它們全瞎。
#   ⇒ ★★同一族的老病：**列舉一個【別人決定的集合】時，要去問那個決定者**（這裡是 git），
#     而不是照著「它們長得像什麼」去猜 —— 猜出來的集合會因為別人多做一件事就變不完整。
while IFS= read -r _wt; do
  [ -n "$_wt" ] || continue
  FLAG="$_wt/.claude/hooks/.merge-gates-running"
  [ -f "$FLAG" ] || continue
  pid=$(awk '{print $1; exit}' "$FLAG" 2>/dev/null)
  rest=$(awk '{$1=""; print; exit}' "$FLAG" 2>/dev/null)
  _where="${FLAG#$_root/}"
  if [ -n "${pid:-}" ] && kill -0 "$pid" 2>/dev/null; then
    echo "[machine] ⛔ BUSY：電池在跑（PID $pid${rest:+ —$rest}）"
    echo "[machine]   ⇒ 標記：$_where"
    echo "[machine]   ⇒ ★★這一格【不看 Godot 行程數】—— 電池在兩支床之間那個數是 0"
    busy=1
  else
    echo "[machine] ⚪ 舊標記（PID ${pid:-?} 已不在）：$_where ⇒ 不算忙；★而【標記舊】不代表機器空"
  fi
done <<EOF_WT
$(git worktree list --porcelain 2>/dev/null | awk '/^worktree /{ $1=""; sub(/^ /,""); print }')
EOF_WT

n=$(powershell -NoProfile -Command '@(Get-Process godot* -ErrorAction SilentlyContinue).Count' 2>/dev/null | tr -dc '0-9')
if [ "${n:-0}" != "0" ]; then
  echo "[machine] ⛔ BUSY：Godot 行程數 = $n"
  # ★★★歸屬（systems 2026-09-23）：今天有兩次「看到 Godot=2 而查不出是誰的」，
  #   而規矩是【不准殺用戶的遊戲】⇒ 查不出來時唯一安全的動作是【什麼都不做】，
  #   ★而那也表示孤兒永遠不會被清。⇒ tools/godot.ps1 現在會為它起的每一個 Godot 落一個 PID 信標，
  #   ★★這裡把它讀回來，把「不知道」換成【我們的 N／不知道是誰的 M】。
  #   ★★★而 M > 0 仍然【不准殺】—— 它的意思是【去問】，不是【去清】。
  _mb_bdir="$_root/.claude/hooks/.godot-pids"
  _mb_ours=0
  if [ -d "$_mb_bdir" ]; then
    for _bf in "$_mb_bdir"/*.txt; do
      [ -f "$_bf" ] || continue
      _bp=$(basename "$_bf" .txt)
      if kill -0 "$_bp" 2>/dev/null; then
        _mb_ours=$((_mb_ours+1))
        echo "[machine]     ・我們的：$(head -1 "$_bf")"
      else
        rm -f "$_bf" 2>/dev/null   # ★死掉的信標順手清（它不是證據，是殘骸）
      fi
    done
  fi
  _mb_unknown=$(( n - _mb_ours ))
  echo "[machine]   ⇒ 歸屬：我們起的 ${_mb_ours}／不知道是誰的 $(( _mb_unknown < 0 ? 0 : _mb_unknown ))"
  if [ "$_mb_unknown" -gt 0 ]; then
    echo "[machine]   ⇒ ★★★不知道是誰的 > 0 ⇒【不要殺】：可能是用戶自己在玩（他優先）"
    echo "[machine]     ⇒ ★要清孤兒，先在信裡問過；★★而殺的時候要殺整棵樹（Windows 殺父不帶走子孫）"
    echo "[machine]   ⇒ ★★誠實限：信標是 2026-09-23 才加的 ⇒【在那之前起的 Godot 沒有信標】"
    echo "[machine]     ⇒ 所以「不知道是誰的」也可能是【我們起的、只是起得比信標早】——★★★不要讀成「一定是孤兒」"
  fi
  busy=1
fi

if [ "$busy" = 0 ]; then
  echo "[machine] ✅ FREE：無電池標記、Godot 行程數 = ${n:-0}"
  echo "[machine]   ⇒ ★這是【此刻】的答案，不是預約 —— 要用機器請寄信說一聲（交接靠信，不靠這個數）"
else
  echo "[machine]   ⇒ ★★★若你是用 \`machine-busy.sh; <指令>\` 這種寫法：那個 \`;\` 不會擋你。"
  echo "[machine]     改用：bash .claude/hooks/machine-busy.sh -- <你的指令…>（FREE 才跑）"
fi
if [ "$_mb_cmd_mode" = 1 ]; then
  if [ "$busy" != 0 ]; then
    echo "[machine] ⛔ 不執行你的指令（機器忙）：$*"
    exit 1
  fi
  echo "[machine] ▶ 機器空，執行：$*"
  "$@"
  exit $?
fi
exit "$busy"
