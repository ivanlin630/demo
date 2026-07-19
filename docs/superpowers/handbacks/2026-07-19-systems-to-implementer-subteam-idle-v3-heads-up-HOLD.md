---
from: systems
to: implementer
status: open
topic: "[HOLD·v3 結構修來·別 merge v2] 你 v2(供給環 sated-gated merge)build 完 measurer 量出 seed1337 惡化(6→10)=真結構洞非 cascade:v2 的 _parent_needs_food 召回只在 move_target==-1(駐 forage tile)查→旅途中 forager 不監看母團→垂危召不回。v3 兩結構修(連續監看+orphan)重寫 spec,我 re-R² 中。★HOLD 別 merge/推進 v2,hold-warm 等 R²-CLEAN redirect。v3 在同 036fc42c extend:①_check_discipline 後加連續母團監看(foraging subteam 每 tick 查 parent,母團缺糧→merge_queue 掉頭交糧;parent==null→orphan detach 轉獨立)②v2 sated-merge 保留。等我信號。"
---

# HOLD：v3 結構修（連續母團監看 + orphan），別 merge v2

## v2 也不夠（measurer 結構洞坐實，非你的錯）
你 v2（供給環 sated-gated merge）build 乾淨，但 measurer 量 seed1337 惡化（6→10）= **真結構洞**：v2 的 `_parent_needs_food` 召回在 `move_target==-1` 分支內（只 forager 駐 forage tile 才查）→ **旅途中 forager 不監看母團** → 母團垂危召不回（forager 已飽卻交糧太慢）。這是 spec 沒涵蓋的第三層洞，非你實作問題。

## v3（spec 已更新，re-R² 中）
同 `036fc42c` extend：
1. **連續母團監看**（`_check_discipline` 後、position-branch 前）：`if sub.current_task in SURVIVAL_TASKS:` → `parent==null` → orphan detach 轉獨立；`_parent_needs_food(parent)` → `merge_queue.append`（掉頭交糧，不等駐點/sated）。
2. **orphan-forager**：`detach_subteam + remove_tag(TAG_SUBTEAM) + release`（沿用 discipline_fail 路）。
3. v2 sated-merge 保留。

## 你現在
**hold-warm 別動**（別 merge v2、別自 extend v3）。我 re-R² CLEAN → 發 redirect 給你 extend。gate 值（SATED/PARENT_LOW）tune 排 v3 結構修之後。等信號。
