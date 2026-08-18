---
from: systems
to: implementer
status: consumed
topic: "[dispatch perf Phase2刀1(frontier call-scoped memo B+_hex_dist static A、全安全道byte-identical)·base main ef72c002·spec=2026-08-18-perf-phase2-cut1-frontier-memo-hexdist-HOW.md R²-CLEAN(reviewer親驗:_hex_dist純算術faction_ai:3350-3353零instance state可static、frontier_candidates零tile_pos mutation call-scoped memo byte-identical by construction)·★A:_hex_dist改static(faction_ai:3350-3353=(abs(dx)+abs(dx+dy)+abs(dy))/2純算術)→replace全FactionAISystem.new()._hex_dist呼點(goal_resolver:478/534+窮盡grep其他、負斷言先wc-l後宣)為static、免per-call alloc·★B:find_nearest_terrain_tile(goal_resolver:469)結果call-scoped memo於frontier_candidates(local Dict keyed(terrain,max_range)、team當下tile_pos固定)→同team多goal查同terrain首次全掃後續命中、frontier返回即棄(call-scoped⊂tick嚴禁跨tick cache)·★憲法gate硬:byte-identical 3跑機器證(同seed StateFingerprint精確match=安全道命門)+constitution綠+無新常數(memo=機制非旋鈕)·TDD:A①static呼==原instance呼同值②hot path無FactionAISystem.new()(grep證)B③同team多goal同terrain全掃1次非N次(call count)④memo結果==無memo byte-identical⑤frontier返回memo不殘留無跨tick leak·★measurer需quantify前後%(p1.selection within ctx_total、期望顯著降97.5%主塊)·若B後高goal team仍O(tiles)(跨team不共享)→回報刀3 D spatial index議·worktree feat/perf-cut1·與settlement S2b平行·完→handback附measurer·地基KEEP"
---

# dispatch perf Phase2 刀1（frontier memo B + _hex_dist static A、全安全道）

spec=`docs/superpowers/specs/2026-08-18-perf-phase2-cut1-frontier-memo-hexdist-HOW.md`（**R²-CLEAN**、reviewer 親驗純度+memo-safety）。base=main `ef72c002`。與 settlement S2b **平行**。

## ★A：_hex_dist static
`_hex_dist`(faction_ai:3350-3353=`(abs(dx)+abs(dx+dy)+abs(dy))/2` 純算術、零 instance state)→ 改 **static** → replace 全 `FactionAISystem.new()._hex_dist(...)` 呼點（goal_resolver:478/534 + **窮盡 grep 其他、負斷言先 wc-l 後宣**）為 static 呼、免 per-call alloc。

## ★B：find_nearest_terrain_tile call-scoped memo
`find_nearest_terrain_tile`(goal_resolver:469) 結果 **call-scoped memo 於 frontier_candidates**（local Dict、keyed `(terrain, max_range)`、team 當下 tile_pos 固定）→ 同 team 多 goal 查同 terrain 首次全掃、後續命中；**frontier 返回即棄**（call-scoped⊂tick、嚴禁跨 tick cache）。

## ★憲法 gate（硬）
byte-identical 3 跑機器證（同 seed StateFingerprint 精確 match=安全道命門）+ constitution 綠 + **無新常數**（memo=機制非旋鈕）。

## TDD
A：①static 呼==原 instance 呼同值 ②hot path 無 FactionAISystem.new()(grep 證)。B：③同 team 多 goal 同 terrain 全掃 1 次非 N 次(call count) ④memo 結果==無 memo byte-identical ⑤frontier 返回 memo 不殘留(無跨 tick leak)。

## measurer
quantify 前後 %（p1.selection within ctx_total、期望顯著降 97.5% 主塊）。若 B 後高 goal team 仍 O(tiles)（跨 team 不共享）→ 回報刀3 D spatial index 議。

worktree `feat/perf-cut1`。完 → handback 附 measurer。地基 KEEP。
