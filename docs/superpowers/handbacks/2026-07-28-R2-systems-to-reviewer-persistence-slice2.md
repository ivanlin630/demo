---
from: systems
to: reviewer
status: consumed
topic: "[R²·持守統一 Slice 2 執行層寫回新鮮度·cd22a91e·persist_strength隨真construction-tick progress更新(非時間proxy):sunk=(total−ticks_left)/total(★construction_ticks_total重建)+_tick_construction每tick+movement _on_arrival重算→執行層Slice3讀當下值·驗persist test 7組+gate74+determinism byte-identical+★世界不凍(attrition1.13%/teams49→64活)] Slice 2 新鮮度 done。審真進度sunk+total重建+每tick重算perf+世界不凍。"
branch: feat/persistence-slice2-writeback-freshness (cd22a91e)
---

# R²：持守統一 Slice 2（執行層寫回 + 新鮮度）

## 做（spec §5）
- persist_strength **隨真 construction-tick progress 更新**（非時間 proxy）：
  - ① 施工中 `sunk=(total−ticks_left)/total`，★`OutpostSystem.construction_ticks_total` **重建**（原本只存 ticks_left 無 total）。
  - ② `_tick_construction` 每 tick + movement `_on_arrival` 抵達 → 重算 persist_strength → 執行層（Slice 3）讀當下值。
- 新鮮度落差解（決策層 cadence vs 執行層讀）。

## 驗
- persist test **7 組**（含 ⑥真進度非時間 proxy、⑦新鮮度即更新）。
- ★世界不凍（latch 反例回歸）：attrition 1.13% / teams 49→64 成長=活。
- headless 0-new + gate 74 + determinism byte-identical(ae27853f)。不碰 try_set 門檻（Slice 3）。

## ★reviewer focus（refute）
1. **construction_ticks_total 重建對否**：sunk=(total−ticks_left)/total 的 total 準否（重建邏輯 vs 原始 BUILD_TICKS/cost ticks）？有沒有 total 取錯 → sunk 失真？
2. **真進度非時間 proxy 對否**：sunk 用 construction_ticks（真投入）非 elapsed time——這正是 progressive-only 意圖（已投入越多越黏）？
3. **★新鮮度每 tick 重算 perf**：`_tick_construction` 每 tick 重算施工隊 persist_strength——cheap 純算術否？大量施工隊時無 O(N²)？
4. **★世界不凍真否**（attrition/teams 活=latch 反例回歸，別又凍）？
5. movement `_on_arrival` 重算覆蓋對否（campaign/trade run 抵達進度）？

**CLEAN → merge Slice 2 → Slice 3（try_set 門檻式 §6，執行層真持守）。** 有洞 → 回 `to:systems`。
