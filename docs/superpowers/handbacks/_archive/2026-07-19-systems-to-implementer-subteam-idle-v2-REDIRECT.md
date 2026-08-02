---
from: systems
to: implementer
status: consumed
topic: "[REDIRECT·subteam-idle-latch v2 供給環·R² CLEAN·extend 036fc42c] hold 解除。v2 R² CLEAN(供給環坐實 try_merge_back→_transfer 真交糧,sated-gated 不 re-thrash)。在你 branch feat/subteam-idle@036fc42c 上 extend(別新 branch,你 1 行修保留當基):1727 對 survival-work 的 merge 由『全排除』改『條件』——`if current_task in SURVIVAL_TASKS and not (_forager_sated(sub) or _parent_needs_food(state,parent)): return`(未食足+母團不缺→留 tile 覓食);else merge_queue(食足/母團缺糧/非-survival→歸建交糧)。加兩 helper+兩 TEST VALUE 常數:_forager_sated=survival_food_days(sub)>=FORAGE_SATED_DAYS、_parent_needs_food=parent!=null and survival_food_days(parent)<PARENT_LOW_DAYS。TDD 補:①未食足留 tile ②食足→歸建交糧(food 進 parent)③母團缺糧→即使沒滿也交 ④sated 後無 re-thrash。→to:measurer(seed42 famine 回 0+囤糧消+6 隊解+無 re-thrash;gate 值 tune)。★off LOCAL(禁 origin),pre-push hook 兩閘。"
---

# REDIRECT：subteam-idle-latch v2 供給環（extend 036fc42c）

hold 解除。v2 R² **CLEAN**（供給環前提坐實 `try_merge_back→_transfer` 真交糧；sated-gated 條件 merge 不 re-thrash、非抑制補丁；reviewer 認 v1 terminal-sticky non-blocker 判太輕）。

## 在同 branch extend（別新 branch）
`feat/subteam-idle@036fc42c`（你 1 行修保留當基）上加供給環。`faction_ai:1727` 由「全排除 survival-work」改「**條件 merge**」：
```gdscript
if sub.move_target == Vector2i(-1, -1) and sub.current_task != TeamData.TASK_IDLE:
    if sub.current_task in SURVIVAL_TASKS \
            and not (_forager_sated(sub) or _parent_needs_food(state, parent)):
        return   # 未食足+母團不缺 → 留 tile 覓食（collect_resources 累積，不 thrash）
    merge_queue.append(sub.team_id)   # 食足/母團缺糧/非-survival → 歸建交糧（try_merge_back）
    return
```
（注意 `parent` 在此 scope 是否已取；_evaluate_subteam 早段有 `state.teams.get(sub.parent_team_id)`——若無，取一下。）

## 兩 helper + 兩 TEST VALUE
```gdscript
const FORAGE_SATED_DAYS: float = ...   # TEST VALUE — forager 攜糧夠多值得回交（measurer tune）
const PARENT_LOW_DAYS: float = ...     # TEST VALUE — 母團缺糧閾（measurer tune）
func _forager_sated(sub) -> bool: return _survival_food_days(state, sub) >= FORAGE_SATED_DAYS
func _parent_needs_food(state, parent) -> bool: return parent != null and _survival_food_days(state, parent) < PARENT_LOW_DAYS
```

## TDD（補 v1 之外）
①未食足+母團不缺 → 留 tile 覓食（不 merge，food 累積）②食足 → 歸建交糧（`try_merge_back`，food 進 parent）③母團缺糧 → forager 即使沒滿也歸建交糧 ④sated 後歸建移向 parent、food 足不 re-pick forage → **無 re-thrash**。（v1 的 7 TDD 保留/調整。）

## 驗收
gate PASS / headless 0 new / determinism 2 跑 byte-identical。→ `to:measurer` measure：**seed42 famine 0→10 regression 回 0**（v2 核心）+ 囤糧 200-2000 food-days 現象消 + 6 隊（62/71/73/79/84/90）解 + 無 re-thrash + 42/1337/4201 無新 regression。**gate 值（FORAGE_SATED/PARENT_LOW）measurer tune**（env override 或你給初值 measurer 掃）。

## base
★off LOCAL（branch 已在 036fc42c，extend 即可），禁 origin。pre-push hook 已裝 push 起兩閘。

## 完成判定
= systems + reviewer/QA。做完 → to:measurer measure → 回鏈。
