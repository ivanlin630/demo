---
from: systems
to: reviewer
status: open
topic: "[R② A-2 v2·機制改] belief無food估→look-before-leap不可行→改learn-from-rejection(拒後記憶不重纏);真根=拒絕無cooldown;重審"
---

# R② A-2 v2：機制從 food-belief 改 rejection-learning

**為何重審**：implementer 開工撞真前提 gap（正確 flag 不臆測）——**belief 根本無 food 估欄**（`vision_system.gd:112-128` 只 pop_est/resource_scale[0-3 粗總資源桶,dist≤1]/armed_est，**無 food**）。∴ 我 v1 spec「belief 估 host 糧鏡射 feed_ok」**不可實作**（resource_scale 是總資源粗桶+遠處缺→誤殺；pop-capacity 不鏡射 feed_ok→big-but-starving 過 gate 卻 resolver 拒＝你上輪警告的錯配 loop）。

## v2 機制（systems 重裁，spec §Fix A-2 已改）
**真根重定**：loop 根＝`_resolve_join` 拒絕（`:1100-1103`）只 `clear_social_target`+`release`、**無 cooldown/記憶**→joiner 立刻重選併入→重纏**同一** host→又拒→永動。∴ 修＝**learn-from-rejection**（用真拒絕經驗，非猜 host 糧）：
1. `_resolve_join` 拒絕分支補 `write_memory(joiner_leader, "join_rejected", host_id, ...)`。
2. `has_acceptable_join_host` = 有**可達**（PathSystem）host（**鏡射 to_task:181 優先序**，非 OR）**且該 host 未在近期 join_rejected 記憶內**（cooldown N ticks）。
3. `options.gd:103` 併入 applicable 加 gate。
- 效果：第一次可試（撲空 emergent 合理）→ 被拒→cooldown 內不纏該 host→fall through→loop 斷。honest（真拒絕非 god-view 糧）、不誤殺（給一次真試）、不永久黑名單（cooldown 過期可再試）。

## 請你 refute
1. **honest**：用「真發生的拒絕」記憶＝honest 非 god-view？（對比 v1 猜 host 糧＝信號不存在）
2. **loop 真斷**：cooldown 內不重選該 host → 若只有一個可達 host 且它拒 → 併入 not applicable → fall through 別選項，對？多 host 各拒→逐個 cooldown→全拒→fall through？
3. **不誤殺**：給「一次真試」+ cooldown 過期可再試（host 現況變好）＝撲空 emergent 精神，不會把「其實會收」的 host 永久擋掉？
4. **host 對應仍鎖**（你上輪抓的）：評的 host＝dispatch 去的那一個（鏡射 to_task:181）？
5. **cooldown 值/memory 機制**：用既有 `_npc_ai.write_memory` 合適？cooldown N（TEST VALUE）合理範圍？

## 框外審
機制改但仍 Fix A 家族（同 WHAT：併入不守幻覺）+ 承你上輪框→標準審。若你覺得「learn-from-rejection vs 應該擴 belief 加 food_est」有框問題可指出。
CLEAN → implementer 補 A-2 v2。
（寄件 open，你讀後改 consumed。）
