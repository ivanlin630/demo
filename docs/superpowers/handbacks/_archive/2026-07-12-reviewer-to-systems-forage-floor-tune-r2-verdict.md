---
from: reviewer
to: systems
status: consumed
topic: [R² verdict] 苟活地板tune spec = CLEAN，balance數學驗算通過
---

# R² 審判 verdict — 苟活地板 tune spec

## verdict: CLEAN

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "balance守門數學代入驗算：5天檔buffer=pop×4.0 < 建國門pop×5.6，確實不誤開成長路；7天檔=pop×5.6恰貼齊建國門(非略低是相等)，spec已誠實標此風險待A/B。常數改動範圍乾淨、wild_game regen複用正確、determinism/範圍鎖/冗餘皆過。" }
```

## file:line 驗證（含balance數學驗算）
- `FOOD_PER_PERSON_PER_DAY=0.8`(`resource_system.gd:3`) + `FOUND_FOOD_SURPLUS_DAYS=7.0`(`faction_ai_system.gd:47`) — 確認。代入 `_forage_subsist_buffer` 公式：
  - floor 5天 → buffer = pop×0.8×5 = **pop×4.0**
  - 建國門 = pop×0.8×7 = **pop×5.6**
  - 4.0 < 5.6，**5天檔數學上確實低於建國門**，「苟活不誤開成長」balance意圖守住。
  - floor 7天（A/B另一檔）→ buffer = pop×0.8×7 = **pop×5.6，恰好等於建國門**（非略低是相等）——spec §1已誠實標此風險「7天檔逼近7門要A/B看會否誤開成長路」，非隱瞞。
- `hunt_system.gd:5 ACTIVE_BASE_CHANCE=0.4` / `:6 PASSIVE_BASE_CHANCE`（0.08→0.30提案）/ `:20 active=false`分支 — 確認0.30仍<0.4，只碰passive分支，不誤傷active路徑。
- `world_generator.gd:123 tile.resource_cap["wild_game"]=int(tile.resources["wild_game"])` — 確認wild_game上限夾＝世代初始值，regen不破稀有度不變量。
- `regenerate_tiles:79` — 確認新增wild_game分支複用同款pattern（rate×day_fraction+pool_set+cap夾），零randf。

## 逐項checklist
1. 常數改乾淨：過（3處引用/active-passive分離確認）。
2. wild_game regen複用正確：過（cap來源/pattern一致/零randf確認）。
3. balance守門：過（數學代入驗算，5<7成立，7天恰貼齊已誠實標risk）。
4. determinism：過（純常數+zero-randf regen）。
5. 範圍鎖：過（無其他機制被動）。
6. 框架內冗餘：過（既有函式擴展非新求解器）。

CLEAN，dispatch implementer。
