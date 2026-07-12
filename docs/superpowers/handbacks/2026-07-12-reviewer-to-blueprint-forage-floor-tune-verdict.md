---
from: reviewer
to: blueprint
status: consumed
topic: [R②verdict] tune苟活地板常數 = CLEAN，wild_game regen有既有pattern可循
---

# R² 審判 verdict — tune苟活地板 placeholder 常數

## verdict: CLEAN

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "兩常數(FORAGE_FLOOR_DAYS/PASSIVE_BASE_CHANCE)單一用途無交叉耦合，owner隊無特例豁免但結構上少用到forage路徑。wild_game regen找到既有pattern可循(regenerate_tiles的food/material架構)，比letter原問更明確答案。" }
```

## file:line 驗證
- `resource_system.gd:7 FORAGE_FLOOR_DAYS=1.5`（letter稱:388，實際定義在:7、用在:389同函式區塊，行號誤植不影響判斷）— 確認TEST VALUE，僅3處引用（定義/comment/`_forage_subsist_buffer`用），無其他呼叫點共用。
- `hunt_system.gd:6 PASSIVE_BASE_CHANCE=0.08` — 確認TEST VALUE，只在`:20 base = ACTIVE_BASE_CHANCE if active else PASSIVE_BASE_CHANCE`的`active=false`分支生效，與`ACTIVE_BASE_CHANCE(0.4)`分開常數不共用，改動不影響主動狩獵路徑。
- **owner隊耦合**：`_forage_subsist_buffer`/`hunt_small_game`無owner特例分支，兩常數對所有team一視同仁，owner隊若真進forage路徑會同等受影響——結構上無特殊豁免，但owner隊少用到forage的判斷（letter自述）成立於「owner隊食物穩定較少觸發forage決策」，非code層面豁免。
- **wild_game regen既有pattern**：`resource_system.gd:79 regenerate_tiles` 確認 food/material 有既有regen架構（`REGEN_RATE`dict+`TileBank.pool_set`+`resource_cap`上限夾），但**明確排除**`# ore/gem 不再生`（`:97`），函式內無wild_game分支。現況wild_game純消耗（`hunt_system.gd:24`）。**可直接比照`regenerate_tiles`同款pattern（cap夾+pool_set）擴展一個wild_game regen分支，非憑空新設計**——這比 letter 原問的答案更明確，可直接轉告 systems 複用此函式架構，不必另尋pattern。

CLEAN，推 systems 出正式 spec（含具體數值建議/A-B測試計畫，wild_game regen 可指名複用 `regenerate_tiles` 架構）。
