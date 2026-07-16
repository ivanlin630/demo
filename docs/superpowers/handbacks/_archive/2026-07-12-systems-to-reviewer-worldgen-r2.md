---
from: systems
to: reviewer
status: consumed
topic: [R² world-gen variety merge前審] 5檔diff §1散布+§2/§3 count/faction range+config分工;四gate綠+融合閘PASS+headless零新增,差R²CLEAN即merge
---

# R²：world-gen variety merge 前審（diff）

world-gen variety 收齊，merge 前 R²。前置閘全綠：
- **四 gate（measurer 驗）**：§1 地板30/30、重疊6.6%真異、build-outpost 7/7 fire；§2/§3 default.json 跨 seed 真變（outpost 8-14/faction 2-4、硬上限守、地板綠）；determinism byte-identical；控制 config 隔離。
- **融合閘（systems 跑）**：constitution PASS（sites=29 removed=0）；regression（coin/framework）measurer 綠。
- **headless**：worktree FAIL 集與 main **byte-identical=零新增**（5 個 pre-existing TDD-red，known_issues 記）。

## 審 diff（`git diff main...feat/worldgen-variety`，5 檔 92+/11-）
```
config/default.json                     |  3 --   (§2/§3啟用:移除total_count+faction count顯設→觸發range)
scripts/debug/warring_harness.gd        |  2 ++
scripts/simulation/faction_ai_system.gd |  1 +
scripts/simulation/game_setup.gd        | 61 ++++   (§2 outpost count range+硬上限+FLOOR_RETRY;§3 faction count range)
scripts/simulation/world_generator.gd   | 36 ++++   (§1 pick_start_positions:rng scatter+位置熵)
```

## R² checklist（skeptical,只信 file:line）
1. **§1 scatter/位置熵**：`world_generator.gd pick_start_positions` 的 rng scatter + entropy 有無 determinism 洩漏（randf 流順序穩？seeded rng 非全域）。
2. **§2 硬上限/地板**：`game_setup.gd` `randi_range(OUTPOST_MIN,OUTPOST_MAX)` → `map_cap=tiles*OUTPOST_DENSITY_CAP` mini 夾 → `FLOOR_RETRY_MAX` retry loop。上限與地板同時守？retry 耗盡的 fallback 安全（非 0 據點/非死循環）？
3. **§3 faction count range + weights**：faction count 變 2-4 時 `weights` 陣列長度對得上？（default.json 移除 count 後 weights 如何供給——自生 or 讀殘留？array 長度 mismatch=潛在 index error）。
4. **config 分工**：default.json 移除顯設觸發 range vs warring_states 顯設釘死——`game_setup.gd` `if ocfg.has("total_count")` 分支對兩路都正確？控制 config 不被誤觸 range？
5. **框架內冗餘**：§2/§3 range 邏輯有無與既有 gen 路徑重複求解（兩處算 count/位置）。
6. **warring_harness.gd +2 / faction_ai_system.gd +1**：這兩處小改是什麼、與 §2/§3 契合非夾帶。

CLEAN → to:systems（我 merge + 收尾 blueprint）。premise_contradiction/blocker → halt 回 systems。
