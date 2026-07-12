---
from: implementer
to: measurer
status: open
topic: 苟活地板tune 實作交付 — FORAGE_FLOOR_DAYS 5/passive 0.30/wild_game regen;branch feat/forage-floor-tune已push,待A/B驗收
---
# Hand Back: 苟活地板 tune

branch `feat/forage-floor-tune`（已 push，疊 origin/main base a740f03）。spec `docs/superpowers/specs/2026-07-12-forage-floor-tune-technical.md`。

## 實作摘要（三項全 tune 現有）
- `scripts/simulation/resource_system.gd`：
  - `FORAGE_FLOOR_DAYS` 1.5 → **5.0**（latch cap pop×0.8×5 = **pop×4.0**）。
  - 新常數 `WILD_GAME_REGEN_PER_DAY = 0.15`。
  - `regenerate_tiles`：food/material regen 後加 wild_game 分支——`wg_cap>0` 時 `pool_set(minf(cur + 0.15×day_fraction, cap))`，複用同款 pattern，上限夾 `resource_cap["wild_game"]`，**零 randf**。
- `scripts/simulation/hunt_system.gd`：`PASSIVE_BASE_CHANCE` 0.08 → **0.30**（只碰 passive，ACTIVE_BASE_CHANCE 0.4 不動）。
- `scripts/debug/headless_test.gd`：+1 test `_test_forage_floor_tune`（buffer=pop×4.0 / passive=0.30<active / wild_game regen +0.15 守 cap / 無 cap 不憑空生），PASS。

## 我方自驗（非驗收，供參）
- 量測：pop10 buffer=40.0（=pop×4.0 ✓）。passive=0.30<active 0.4 ✓。wild_game 2.0→2.15/天、夾 cap 10.0 不超、無 cap 地不生 ✓。
- headless `=== DONE ===`，**新增 0 SCRIPT ERROR**。3 pre-existing assert（p2a/combat-197/rung）在 origin/main baseline 亦同 → 非本 slice 回歸。
- constitution_gate PASS（sites=29，removed=0）。
- 我 ship **5 天檔**（工單 §1）。A/B 7 檔由你 tune FORAGE_FLOOR_DAYS=7 重跑。

## ★A/B 待你驗（reviewer 數學銳化）
- **5 天檔=pop×4.0 < 建國門 pop×5.6（安全，不誤開成長）**——我 ship 此檔。
- **7 天檔=pop×5.6 恰等於建國門** → **A/B 特別看 7 檔:覓食隊會否因 buffer 貼齊建國門而誤達 accum_ok 建國盈餘**（不想要的成長路）。若 7 檔誤開 → 選 5 檔。
- 兩檔皆配 passive 0.30 + wild_game regen（已在 branch）。挑「苟活住(attrition 降)但不誤開成長(farming_level=0 隊 pop 不爆長)」的檔。

## 待驗收（spec §驗收法）
1. **A/B 5 vs 7**：default.json 12mo——月1-3 attrition 降幅（目標 45%→顯著降）、終局 pop、established。
2. **急性窗解**：86-96% 開局負流 → 覓食隊食物流轉正/持平。
3. **★balance 驗**：覓食隊 pop 不因覓食成長（farming_level=0 隊 pop 平/緩降，非爆長）——苟活≠繁榮守住。
4. **established 鏈**（一修多解驗證）：attrition 降 → pop 攢 8（A門）→ leader 累統領（B2）→ established 是否 >0。**誠實**：若 A門/B2 仍卡標「急性窗解但 established 需下游補」。
5. **determinism** byte-identical + **baseline 位移標記**（forage-floor tune 位移，比照 world-gen）。**融合閘**綠。

## 連動風險
- 食物流全面上調 → 存活率/pop/established/戰力全下游位移（即 baseline 位移，重生 baseline 標記）。
- wild_game regen → 依賴 wild_game 枯竭的任何平衡（若有）鬆動；上限夾 resource_cap 守稀有度不變量。
- combat-197 pre-existing assert 或因食物流位移改計數，仍 pre-existing failure 非本 slice 新增。
