#!/usr/bin/env bash
# ★★★S1c：【採完】的可宣告判準 —— 而它的價值在【母體是封閉的】，不在自動判別。
#
# 問題：名字啟發式窮不盡②型（定義處裸語意），那「採完」怎麼宣告？
# 答：把母體換成【全部裸字面量 int 常數】—— 它是有限且可枚舉的（本次 120 顆）。
#   ⇒ 【採完】= 這 120 顆全部有處置，而不是「我想到的那幾個名字都掃了」。
#
# ★★而下面這個【使用處判準】是省力工具，★★★不是判準本身：
#   它沒過陽性對照 —— 把 MSG_TTL_SHORT 改回裸值 1680，它 hits=0【漏掉】。
#   原因：那顆常數經由 MSG_TTL_BY_TYPE 字典與區域變數 ttl 使用，
#         常數名從未與 tick 符號同行 ⇒ 【間接層打斷了使用處証據】。
#   ★所以它只能用來【排序】（哪幾顆先看），不能用來【結案】。
#
# 輸出：hits|CONST|file —— hits>0 = 使用處碰到 tick 軸（優先看）
TICKSYM='current_tick|_next_tick|_eval_tick|elapsed_ticks|TICKS_PER_|origin_tick'
BARE='^[[:space:]]*const ([A-Z_][A-Z0-9_]*)[[:space:]]*:[[:space:]]*int[[:space:]]*=[[:space:]]*-?[0-9]+[[:space:]]*(#.*)?$'
grep -rhE "$BARE" --include=*.gd scripts/ | grep -v '^scripts/debug/' > /dev/null
for f in $(grep -rlE "$BARE" --include=*.gd scripts/ | grep -v '^scripts/debug/'); do
  grep -E "$BARE" "$f" | sed -E 's/^[[:space:]]*const ([A-Z_][A-Z0-9_]*).*/\1/' | while read -r n; do
    hits=$(grep -rhE "\b$n\b" --include=*.gd scripts/ | grep -vE "^[[:space:]]*const $n\b" | grep -cE "$TICKSYM")
    echo "$hits|$n|$f"
  done
done | sort -t'|' -k1,1nr
