#!/usr/bin/env bash
# ★★★長跑包一層：自動掛 busy beacon、跑完自動撤。
#
# ★為什麼要有這支：beacon 我漏了【三次】——而「下次記得」已經被證明無效三次。
#   ★★watchdog 看不到 beacon 只看得到 godot-proc ⇒ 它分不出
#     「implementer 在跑正事」與「有個孤兒 Godot process」⇒ 每次都要人來問一次。
#   ★★★所以修法必須是【掛 beacon 這件事跟起長跑是同一個動作】，不是兩個動作。
#
# 用法：bash tools/longrun.sh <小時數> <powershell 指令...>
#   例：bash tools/longrun.sh 1.5 ".\tools\godot.ps1 --headless --script scripts/debug/x.gd"
#
# ★★★誠實界限（★我先前對 blueprint 講過頭，這裡訂正）：
#   我寫過「中途被 Ctrl-C / kill 也會撤」—— ★★【那句是錯的】。
#   `trap ... EXIT` 對 SIGKILL 【不會 fire】，而 2026-08-28 這一輪就碰到了：
#   背景工作被殺掉 ⇒ Godot 進程還活著，而 beacon 留在原地。
#   ⇒ ★★★真正的安全網是【死線】不是 trap：忘了撤 → 到點自動失效。
#   最壞情況是「這段期間警報被壓住」，不是「永久靜音」—— ★所以死線要給緊，別給 8h。
set -u
ROOT="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")"
# ★★★【主詞修正，systems 2026-10-01】beacon 的角色名原本【寫死成 implementer】——
#   而 `bash-guard.sh` 的護欄逐字是「**別人的** beacon 還在」：它靠檔名 `.busy.<role>` 認主詞。
#   ⇒ ★任何【不是 implementer】的角色用這支包裝跑長跑，蓋出來的章都會寫 implementer
#     ⇒ ①那個角色自己**不會**被自己的旗擋（它以為那是別人的？不 —— 更糟：
#       implementer 會被一面**不是他的**旗擋住，而真正在跑的人**不會**被任何人看見）
#     ⇒ ②警報指向錯的人 ⇒ 去問 implementer「你在跑什麼」而他手上什麼都沒有。
#   ⇒ ★★這是「旗裡的主詞錯」那一族（同 machine-busy 那次：旗裡是 bash $$ 不是 Windows pid）。
#   ⇒ ★★★而它的失效是**靜默**的：兩邊都不報錯，只是警報指著一個沒有在跑的人。
#   ★沒有 SESSION_ROLE 時退回 `unknown`（**不要**退回 implementer —— 那正是這個 bug 的形狀）。
BEACON="$ROOT/.claude/hooks/.busy.${SESSION_ROLE:-unknown}"
HOURS="${1:?用法: longrun.sh <小時數> <指令...>}"; shift
DEADLINE=$(( $(date +%s) + $(awk -v h="$HOURS" 'BEGIN{printf "%d", h*3600}') ))
echo "$DEADLINE" > "$BEACON"
echo "[longrun] beacon 掛上 → $BEACON (deadline $(date -d @"$DEADLINE" '+%F %H:%M'))"
# ★撤 beacon 綁在 EXIT 上：★★中途被 Ctrl-C / kill 也會撤，不留孤兒 beacon 把警報永久壓住。
# ★INT/TERM 也接（EXIT 單獨接不到訊號中斷）；★★SIGKILL 接不到，靠死線。
trap 'rm -f "$BEACON"; echo "[longrun] beacon 已撤"' EXIT INT TERM
"$@"
