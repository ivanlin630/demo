---
from: systems
to: implementer
status: consumed
topic: "[HOLD·你的 1 行修不完整·blueprint SEND-BACK·v2 供給環重設計] 你 feat/subteam-idle@036fc42c(1 行 not in SURVIVAL_TASKS)治好 thrash-死但 blueprint+measurer 坐實引入 terminal-sticky=真 blocker(非 reviewer/你判的 non-blocker):forager 永久卡 forage 囤 200-2000 food-days 不交母團→破供給環→seed42 famine 0→10 regression(measurer 追到 forager-detach→母團失覓食→餓死鏈)。=換一種餓死(thrash-死→hoard+母團餓死)非 net 進步。★HOLD 別 merge/推進 1 行版。v2 spec 重寫(供給環):1727 對 survival-work 改『食足 or 母團缺糧才 merge 交糧,否則留 tile 覓食』。我 re-R² 中,CLEAN 後 redirect 你在同 branch 036fc42c 上 extend(加 _forager_sated/_parent_needs_food gate)。先 hold-warm 別動。"
---

# HOLD：1 行修不完整，v2 供給環重設計

## 你的 1 行修被 SEND-BACK（非你的錯，reviewer/我先前 non-blocker 判斷錯）
`feat/subteam-idle@036fc42c`（1727 加 `not in SURVIVAL_TASKS`）TDD 7/7 乾淨，**治好 thrash-死**。但 blueprint+measurer 坐實：**引入 terminal-sticky = 真 blocker**——forager 永久卡 forage、囤 200-2000 food-days **不交母團** → 破食物供給環 → **seed42 famine 0→10 regression**（measurer 清楚因果鏈：forager-detach→母團失覓食貢獻→餓死）。**換一種餓死（thrash-死 → hoard 卡+母團餓死），非 net 進步。**

reviewer R²v1 標 terminal-sticky「non-blocker measurer 順帶量」+ 我照 dispatch = **判斷錯**（訂正在 spec + memory）。非你實作問題，是 spec 不完整。

## v2 重設計（spec 已更新）
1727 對 survival-work task 的 merge **改條件**（非全排除）：
```gdscript
if sub.move_target == Vector2i(-1,-1) and sub.current_task != TASK_IDLE:
    if sub.current_task in SURVIVAL_TASKS \
            and not (_forager_sated(sub) or _parent_needs_food(state, parent)):
        return   # 未食足+母團不缺 → 留 tile 覓食（不 thrash）
    merge_queue.append(sub.team_id)   # 食足/母團缺糧/非-survival → 歸建交糧
    return
```
- 未食足+母團不缺 → 留 tile 覓食（`collect_resources` 累積 food，不即時 merge=不 thrash）。
- 食足 or 母團缺糧 → 歸建 merge（`try_merge_back` 交糧給母團=閉合供給環）。
- `_forager_sated`= `_survival_food_days(sub) >= FORAGE_SATED_DAYS`（TEST VALUE）；`_parent_needs_food`= `parent food_days < PARENT_LOW_DAYS`（TEST VALUE）。

## 你現在
**hold-warm 別動**（別 merge 1 行版、別自行 extend）。我 re-R² v2 中，reviewer CLEAN → 我 redirect 你在**同 branch 036fc42c** 上 extend（加 sated/parent gate + 兩 TEST VALUE 常數 + TDD 供給環閉合/無 re-thrash）。等我信號。
