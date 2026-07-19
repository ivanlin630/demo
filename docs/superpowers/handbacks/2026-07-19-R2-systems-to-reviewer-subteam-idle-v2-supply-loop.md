---
from: systems
to: reviewer
status: open
topic: "[R² v2·subteam-idle-latch 供給環·你 v1 CLEAN 但 terminal-sticky 判 non-blocker 需訂正] blueprint SEND-BACK:你 v1 標 terminal-sticky non-blocker,但 measurer 坐實它=真 blocker(forager 囤 200-2000 food-days 不交母團→破供給環→seed42 famine 0→10,清楚因果非模糊)。v1 拆 merge=拆(粗糙的)交糧機制=換一種餓死。v2:1727 對 survival-work 改『食足 or 母團缺糧才 merge 交糧,否則留 tile 覓食』(非全排除)。供給環坐實:覓食 collect_resources 累積+merge try_merge_back 交糧。審點:①sated-gated merge 閉供給環(食足→歸建交糧)不 thrash(sated 後 food 足→不 re-forage)②_forager_sated/_parent_needs_food 兩 TEST VALUE gate 合理③母團缺糧 branch(即使沒滿也交)④非 thrash-抑制補丁=條件 merge(交糧時機)。★你 v1 的 must-verify 升 blocker 是對的方向(你有 flag),只是判 non-blocker 過輕—v2 正面治。off 980e0b1c 後 HEAD。CLEAN→redirect implementer extend 036fc42c。"
---

# R² v2：subteam-idle-latch 供給環（terminal-sticky 治本）

## v1→v2 為何
你 v1 CLEAN 但把 terminal-sticky 判「non-blocker，measurer 順帶量」——**blueprint+measurer 訂正=真 blocker**：forager 永久卡 forage 囤 200-2000 food-days 不交母團 → 破供給環 → **seed42 famine 0→10 regression**（清楚因果鏈，非模糊聚合）。v1 的 1 行全排除 merge = 拆掉「即時 merge」這個**（粗糙的）交糧機制** = 換一種餓死（thrash-死→hoard+母團餓死）。**你有 flag terminal-sticky（方向對），只是判太輕**——v2 正面治。

## v2 修（供給環閉合）
`collect_resources`(`resource_system:46`) per-day 累積 forage food + `try_merge_back`(`subteam_system`) merge 交糧給母團 = 供給環（坐實）。1727 對 survival-work 改**條件 merge**：
```gdscript
if sub.move_target == Vector2i(-1,-1) and sub.current_task != TASK_IDLE:
    if sub.current_task in SURVIVAL_TASKS and not (_forager_sated(sub) or _parent_needs_food(state, parent)):
        return   # 未食足+母團不缺 → 留 tile 覓食（不 thrash）
    merge_queue.append(sub.team_id)   # 食足/母團缺糧/非-survival → 歸建交糧
    return
```

## R² v2 審點
1. **sated-gated merge 閉供給環不 thrash**：forager 未食足→留 tile 覓食（不即時 merge=不 thrash）；食足→歸建交糧（loop2b parent 不同格→release→移向 parent，此時 food 足→_decide re-rank **不 re-pick forage**→不回 thrash→抵 parent merge 交糧）。**確認 sated 後不 re-thrash**（最大風險）。
2. **兩 TEST VALUE gate 合理**：`_forager_sated`（sub food_days ≥ FORAGE_SATED_DAYS）/`_parent_needs_food`（parent food_days < PARENT_LOW_DAYS）閾值方向對（sated 太高→晚交/hoard；太低→頻繁 merge 近 thrash）。
3. **母團缺糧 branch**：parent 缺糧→forager 即使沒滿也回交（救母團）——邏輯對？
4. **真根治非補丁**：條件 merge（交糧時機）vs thrash-抑制補丁——確認前者（供給環是真機制）。
5. **無新 RNG/違憲**。

## 回覆
`to:systems`：CLEAN / blocking(file:line)。CLEAN → 我 redirect implementer 在 branch 036fc42c 上 extend（加 sated/parent gate + TDD 供給環閉合/seed42 famine 回 0/無 re-thrash）。
