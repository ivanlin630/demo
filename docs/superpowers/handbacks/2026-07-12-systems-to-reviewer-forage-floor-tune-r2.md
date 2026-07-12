---
from: systems
to: reviewer
status: consumed
topic: [R² spec審] 苟活地板tune—FORAGE_FLOOR_DAYS 1.5→5/PASSIVE 0.08→0.30/wild_game regen複用;審常數乾淨/regen正確/balance守5<7門/determinism
---

# R²：苟活地板 tune spec 審

spec：`docs/superpowers/specs/2026-07-12-forage-floor-tune-technical.md`。你先前 R² CLEAN 的是 premise（常數皆 placeholder、wild_game regen 可複用 regenerate_tiles）。**這次審 tune 設計**（dispatch implementer 前）。

## 設計摘要
- **§1** `FORAGE_FLOOR_DAYS 1.5→5`（TEST，A/B 5 vs 7）——latch cap pop×1.2→pop×4.0。
- **§2** `PASSIVE_BASE_CHANCE 0.08→0.30`——passive 覓食命中（仍 < ACTIVE 0.4）。
- **§3** wild_game regen 分支加進 `regenerate_tiles`（`WILD_GAME_REGEN_PER_DAY=0.15` + TileBank.pool_set + resource_cap["wild_game"] 上限夾，zero-randf）。
- **§4 balance**：floor 5 天 < 建國 7 天盈餘門 → 覓食保命但不成長（保 farming/貿易對繁榮必要）。

## R² checklist
1. **常數改乾淨**：FORAGE_FLOOR_DAYS（3 處引用）/PASSIVE_BASE_CHANCE（只 passive 分支）改動範圍無漏無誤傷 active 路徑？
2. **wild_game regen 複用正確**：分支放 regenerate_tiles 對；`resource_cap["wild_game"]` 上限夾正確（不超初始=不破稀有度不變量）；zero-randf；pool_set 用法對？
3. **★balance 守門**：floor 5 天 < FOUND_FOOD_SURPLUS_DAYS(7) → 覓食隊真的攢不出建國盈餘（成長仍需 farm/貿易）？7 檔逼近 7 門會不會誤開成長路（A/B 要看）？「超額不 bank」latch 機制未動確認？
4. **determinism**：§3 regen zero-randf；§1/§2 純常數 → byte-identical？passive hunt 既有 randf 不受影響（只改機率值非加 randf）？
5. **範圍鎖**：只 tune 這三 + wild_game regen,未動苟活 latch 機制本體/entry gate/其他？
6. **框架內冗餘**：wild_game regen 分支 vs 既有 herb/food regen 無重複求解（同 pattern 不同資源，正當擴展非冗餘）？

CLEAN → to:systems（dispatch implementer）。issues → halt 回。
