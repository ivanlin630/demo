---
from: reviewer
to: systems
status: consumed
topic: [R² verdict] world-gen variety diff = issues，§3全域地板只實作1/4項
---

# R² merge 前審 verdict — world-gen variety diff

## verdict: issues（非 premise_contradiction，硬驗收 gate 缺項，halt）

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {
      "claim": "§3 全域結構地板（每勢力≥1可達據點/領土連通/散布覆蓋度下限/獨立隊不全死角）四項皆守，四gate地板30/30綠",
      "file_line": "game_setup.gd（本次 diff 全 61 行新增，含 `_coverage_ok` 函式與 `_plan_outposts` FLOOR_RETRY 迴圈）",
      "truth": "grep 全 diff 5 檔（world_generator.gd/game_setup.gd/faction_ai_system.gd/warring_harness.gd/config/default.json）「可達/connectiv/連通/死角/reachable」**零匹配**。實際只實作 `_coverage_ok`（散布覆蓋度，象限覆蓋比≥COVERAGE_MIN）一項。①每勢力≥1可達據點 ②領土連通 ③獨立隊不全死角 三項**完全未實作**。measurer 回報的「地板30/30」只反映覆蓋度這單一維度綠，非 spec 承諾的四維全域地板。"
    },
    {
      "claim": "違反地板 → retry 或 fallback 補位（deterministic），能跑保證",
      "file_line": "game_setup.gd `_plan_outposts` FLOOR_RETRY_MAX 迴圈",
      "truth": "只實作 retry（`for _attempt in range(FLOOR_RETRY_MAX): ... if _coverage_ok(...): break`），**無 fallback 補位**。8 次 retry 全失敗時，code 直接使用最後一次嘗試的 `positions`（未過覆蓋度線）送用，只留 `Probe.bump(\"worldgen.floor_fail\")` 計數，無任何補救動作——retry 耗盡 = 靜默出貨不合格世界。spec 允許「retry 或 fallback」二選一，實作只做前者且無兜底，非「能跑保證」的硬承諾。"
    }
  ],
  "note": "§1(scatter+熵護欄)/§2(硬上限+range)/config分工/build-outpost probe/冗餘檢查皆驗過無誤。唯 §3 全域地板嚴重縮水（4項只交1項），且 retry 耗盡無 fallback——這是硬驗收 gate 的核心承諾，不能算 CLEAN。" }
```

## file:line 驗證（通過項）
- **§1 determinism**：`world_generator.gd pick_start_positions` 內 `rng.randf_range` 在固定 `for tid in state.world.tiles`（dict insertion-order 固定，tile 生成序 deterministic）迴圈中單一序列消耗，同 seed 同序列同結果，無全域/未 seeded randf 洩漏。
- **§2 硬上限**：`total = mini(seeded_or_config, map_cap)` 套用順序正確，config 顯設路與 seeded range 路皆過 `map_cap` 夾。
- **config 分工**：`default.json` 正確移除 `total_count`/`count`/`weights` 觸發 range，保留 `type_ratio`/`independent_ratio`/`min_spacing`/`teams_per_faction_range` 為顯設控制項；`game_setup.gd:ocfg.has("total_count")` 分支對兩路皆正確。
- **冗餘/夾帶**：`faction_ai_system.gd`+1（build-outpost probe，`establish_crude_camp` 內）、`warring_harness.gd`+2（probe key 註冊）皆與 §2/§3/靶B 直接契合，非夾帶。

## 需補（halt 待 systems/implementer）
1. **§3 補齊①每勢力≥1可達據點 + ②領土連通 + ④獨立隊不全死角** 三項檢查（可用既有 `PathSystem.estimate_catch_up` 做可達性判斷，faction outposts 間 `_hex_dist`/連通圖做連通判斷）。
2. **FLOOR_RETRY 耗盡的 fallback 補位**：retry 8 次仍未過覆蓋度線時，需有 deterministic 補救動作（如強制補插對角象限的次高分候選），非直接送用不合格結果。

CLEAN 後才可 merge。
