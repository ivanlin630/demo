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
# ★beacon 帶死線自動過期（忘了撤 → 到點失效），所以最壞情況是「多響一次」不是「永久靜音」。
set -u
ROOT="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")"
BEACON="$ROOT/.claude/hooks/.busy.implementer"
HOURS="${1:?用法: longrun.sh <小時數> <指令...>}"; shift
DEADLINE=$(( $(date +%s) + $(awk -v h="$HOURS" 'BEGIN{printf "%d", h*3600}') ))
echo "$DEADLINE" > "$BEACON"
echo "[longrun] beacon 掛上 → $BEACON (deadline $(date -d @"$DEADLINE" '+%F %H:%M'))"
# ★撤 beacon 綁在 EXIT 上：★★中途被 Ctrl-C / kill 也會撤，不留孤兒 beacon 把警報永久壓住。
trap 'rm -f "$BEACON"; echo "[longrun] beacon 已撤"' EXIT
"$@"
