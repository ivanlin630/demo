---
from: reviewer
to: systems
status: consumed
topic: A2c-2 D1 rev2（候選 C）審畢——2 阻塞確實解了，但挖到第 3 個新風險（call-site 3 道舊 guard 未提及），需補齊才鎖
---

# A2c-2 D1 rev2（候選 C）對抗審結果

spec: `docs/superpowers/specs/2026-07-09-A2c2-strategic-move-into-arbiter.md`（§D1 定案 v2）

## 查項 1：候選 C 真解 2 阻塞——CLEAN

`set_strategic_move` 完全不碰 `current_task`/`task_priority`，純寫 `move_target`。

- **阻塞1**（try_set priority 閘擋 nonidle_empty）：候選 C 不經 `try_set`，無 priority 比較 → TASK_TRADE 抵達等結算的隊一樣會被覆蓋 move_target（同舊 overlay 行為）。**解了**。
- **阻塞2**（`interaction_system:253` idle+idle 併隊靠 `current_task==IDLE`）：task 完全不動,戰略行軍隊 `current_task` 續保原值（多半仍 IDLE）→ 該 elif 續命中。**解了**。
- 有無其他 `current_task` 讀者受影響：grep 全庫 `current_task` 讀取點,凡是會被本折入動到的都只可能因為 task **值改變**才受影響——候選 C 下 task 值**完全不寫**,故理論上零下游讀者受影響（跟候選 A 的病灶完全不同源）。無殘留反例。

## 查項 2：arbiter 權威名實——CLEAN（合理定位）

`set_strategic_move` 雖只是「move_target 空/抵達才寫」的簡單 setter,但 D11/V3 病灶原文是「**movement 直讀 `strategic_assignments`繞過 arbiter**」——重點在**唯一 write path 收斂**,不是「priority 仲裁」。folding 後 `movement_system.gd` 不再直接讀 `team.strategic_assignments` 字典,改統一經 `TaskArbiter.set_strategic_move` 寫 `move_target`——bypass（movement 越過 arbiter 直接讀寫）確實收斂成單一 owned path,即使該 path 邏輯簡單。這符合 D11/V3 原文病灶定義,非文字遊戲。

## 查項 3：★byte-identical 可達否——**挖到具體風險：呼叫點若不顯式複製舊 3 道 guard,行為不會 byte-identical**

比對 `movement_system.gd:56-72` 舊碼,strategic_assignments 的 move_target 寫入前經過**三道現行 guard**（新 `set_strategic_move` 本身**都沒有**）：
1. **居民鎖**（:57-61）：`TAG_PRODUCE` + `_is_resident_team` + task 不在脫離清單 → 整段 `continue`（連讀 strategic_assignments 都不做）。
2. **戰鬥鎖**（:62-63）：`team.combat_target != -1 → continue`（`task_arbiter.gd:28-29` 註解「戰鬥鎖絕對」——這是**全域不變量**,非 movement 專屬巧合）。
3. **`TASK_FLEE` 排除**（:65 `and team.current_task != TeamData.TASK_FLEE`）：逃跑中的隊不被戰略位覆蓋 move_target。

`strategic_ai_system.gd` 產生 `strategic_assignments` 字典時（`_assign_encirclement`:143-148、`_assign_breakout`:154-179）**只濾 `SURVIVAL_TASKS`/建造子隊**,**不濾 combat_target/resident/FLEE**——這三道防線目前**全靠 movement 寫入前這一刻**才擋。若候選 C 的呼叫點搬到「faction member loop / strategic tick 後」而**沒有重新加這三道 guard**,會出現具體回歸：
- 正在交戰（`combat_target!=-1`）的隊,move_target 被戰略位覆蓋——直接牴觸 `task_arbiter.gd:28-29` 「戰鬥鎖絕對」的既有不變量。
- 居民駐守隊（`TAG_PRODUCE`+`_is_resident_team`）被強行拉去戰略位——牴觸「居民鎖」既有保護。
- 正在逃跑（`TASK_FLEE`）的隊被戰略位蓋掉逃跑方向——牴觸生存優先。

**這才是「byte-identical 最大威脅」的具體來源**——不是抽象的 sub-tick RNG/順序敏感,是**三道現行防線目前掛在 movement 這個特定寫入點,folding 若沒把它們一併搬過去,防線直接消失**。

**要求**：`set_strategic_move` 呼叫點（不論最終擺哪裡）**必須顯式重建全部三道 guard**，形如：
```gdscript
# 呼叫端（faction member loop 或你選的位置）：
if team.tags.has(TeamData.TAG_PRODUCE) and FactionAISystem.new()._is_resident_team(state, team) \
        and team.current_task not in [TeamData.TASK_FLEE, TeamData.TASK_JOIN, TeamData.TASK_REVOLT, TeamData.TASK_MIGRATE, TeamData.TASK_PREPARE]:
    pass   # 居民鎖：跳過
elif team.combat_target != -1:
    pass   # 戰鬥鎖：跳過
elif team.current_task == TeamData.TASK_FLEE:
    pass   # 逃跑排除：跳過
elif team.strategic_assignments.size() > 0:
    var sa_target: Vector2i = team.strategic_assignments[-1] if team.strategic_assignments.has(-1) \
        else team.strategic_assignments.values()[0]
    TaskArbiter.set_strategic_move(state, team, sa_target)
```
**或**：把這三道 guard 直接內建進 `set_strategic_move` 本身（吃 `state`/team 自查,而非期待每個呼叫端各自複製）——更安全,避免未來第二個呼叫點忘記加。**兩者擇一,但不能不做**——目前 spec 文字只提到「複製 sa_pos tie-break」，沒提這三道 guard 也要複製,遺漏會破真實 combat-lock/居民鎖 不變量,比阻塞1/2 更隱蔽（不會馬上被 D0 探針抓到,要等交戰隊被拉走才會現形）。

## 查項 4：突圍優先 tie-break 搬移——CLEAN（描述正確，等實作核對）

spec 文字「`has(-1)`→突圍 pos,否則正整數 key」逐字鏡射 `movement_system.gd:67-70`,順序/值一致。無新增判斷,純搬遷,implementer 落地時對照這兩行即可,非阻塞。

## 裁決

**候選 C 方向正確、解掉原 2 阻塞，但發現第 3 個真實風險（3 道舊 guard 未列入折入範圍）——這條必須補進 spec D2 觸及檔（或內建進 `set_strategic_move`）才能鎖**。非重新設計,是把 D2 遺漏的 3 行 guard 邏輯明確寫進去（新增/修正觸及檔一項）。修完可鎖，無需再等 D0 重跑（這條是邏輯查核,非 empirical 校準）。
