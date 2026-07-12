---
from: systems
to: implementer
status: open
topic: [工單] 苟活地板tune—FORAGE_FLOOR_DAYS 1.5→5/PASSIVE 0.08→0.30/wild_game regen;spec+R²CLEAN;疊新worktree feat/forage-floor-tune
---

# 工單：苟活地板 tune（急性餓死崩上游修，established 鏈第五輪）

spec：`docs/superpowers/specs/2026-07-12-forage-floor-tune-technical.md`（R² CLEAN，balance 數學驗算過）。急性崩根：苟活地板 1.5 天 hand-to-mouth + passive 0.08 + wild_game 不 regen。**新 worktree `feat/forage-floor-tune` 疊當前 main（已 push）。**

## 做（三項，全 tune 現有）
1. **§1 `FORAGE_FLOOR_DAYS` `resource_system.gd:7` `1.5 → 5.0`**（TEST，A/B 檔）。
2. **§2 `PASSIVE_BASE_CHANCE` `hunt_system.gd:6` `0.08 → 0.30`**（TEST）。只碰 passive 分支,不動 ACTIVE_BASE_CHANCE(0.4)。
3. **§3 wild_game regen**：`resource_system.gd regenerate_tiles:79` 加 wild_game 分支（見 spec §3 pseudocode）+ 常數 `const WILD_GAME_REGEN_PER_DAY: float = 0.15`（TEST）。**複用同款 pattern**（rate×day_fraction + `TileBank.pool_set` + `resource_cap["wild_game"]` 上限夾）。**零 randf**（deterministic）。

## 不動（spec §範圍鎖）
- 苟活 latch 機制本體（`_forage_subsist_buffer` 公式結構、「超額不 bank」封頂）不動——只改 FORAGE_FLOOR_DAYS 值。
- entry gate（`_evaluate_survival` 何時觸發）不動。
- ACTIVE 狩獵路徑不動。其他 regen（food/material/herb）不動。

## TDD + 驗收
- 加 headless_test 斷言：①FORAGE_FLOOR_DAYS=5 → `_forage_subsist_buffer` 回 pop×4.0 ②wild_game regen：低於 cap 的 tile 經 N 天 wild_game 回升、不超 resource_cap ③passive hunt 0.30 生效。
- 完成 → handback **to:measurer**（驗收見 spec §驗收法 + ★下方 A/B）。

## ★A/B 給 measurer（reviewer 數學驗算銳化）
- **5 天檔=pop×4.0 < 建國門 pop×5.6（安全，不誤開成長）**。
- **7 天檔=pop×5.6 恰等於建國門**（非略低！）→ **measurer A/B 特別看 7 檔:覓食隊會否因 buffer 貼齊建國門而誤達 accum_ok 建國盈餘**（不想要的成長路）。若 7 檔誤開 → 選 5 檔。
- A/B 兩檔皆配 passive 0.30 + wild_game regen。挑「苟活住（attrition 降）但不誤開成長（farming_level=0 隊 pop 不爆長）」的檔。

## 註
- 行為改動（食物流→存活→established），非 regression。measurer 標「forage-floor tune 位移」重生 baseline（比照 world-gen）。
- established 調查鏈第五輪:攻上游急性崩,理論一修多解鬆四層門（farming/A門/B2/週轉）。誠實:若 A門/B2 仍卡則標「急性窗解但 established 需下游補」。
- 卡點 → to:systems（別問 user）。
