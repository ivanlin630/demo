---
from: systems
to: implementer
status: consumed
topic: [world-gen variety 開工] 據點seeded scatter+範圍+全域地板+重baseline;R² CLEAN
---

# 實作工單：world-gen variety（R② CLEAN）

spec `specs/2026-07-12-worldgen-variety-technical.md`（R② CLEAN）。新 worktree `feat/worldgen-variety`（基於最新 main，先確認 push）。每 seed 開局世界更變化，**守 per-seed determinism（byte-identical）+ 地形不動**。

## 改（§1~4）
1. **`pick_start_positions(state, n, min_sep, rng)`**（`world_generator.gd`，+rng 參）：
   - 評分全 tile：`score = 資源價值(REGEN_RATE food+material + wild_game)×W_RES + 戰略因子(中心度/鄰格資源和)×W_STRAT`。
   - **位置熵護欄（靶A，防 re-regularize）**：min_sep 過濾後候選池，`rng` 從 top-K 隨機挑（K=剩餘需求×ENTROPY_MULT）**或** score×`(1+rng.randf_range(-NOISE,NOISE))` 噪聲。**非純 argmax。**
   - min_sep 強制保留。TEST VALUE：W_RES/W_STRAT/ENTROPY_MULT/NOISE。
2. **範圍 seeded**（`game_setup.gd`）：`total_count`→`rng.randi_range(8,14)`（硬上限=地圖 tile×OUTPOST_DENSITY_CAP 留空地）；faction count→`rng.randi_range(2,4)`；領土 share 加 rng 擾動（獨霸/群雄/稀疏放野）。
3. **全域結構地板（靶C）**（`game_setup.gd` scatter+分配後 validate+retry）：每勢力≥1可達據點 + 連通 + 覆蓋度(象限/包圍盒)≥COVERAGE_MIN + 獨立隊不全死角。**違反→同 seeded rng 續抽 retry(bounded N 次)** 或 deterministic fallback 補位。**地板硬、失衡放野。**
4. **探針**（`warring_harness.gd`）：+地板檢查結果/覆蓋度/**build-outpost dispatch 計數**。
5. **重 baseline（§4）**：改完 `seeded_warring_bed` 基線一次性重生（`WARRING_OUT` 重 dump），標「world-gen variety 導致位移，非迴歸」。

## 硬驗收 gate（handback to:measurer）
1. **determinism byte-identical**：同 seed 兩跑逐項相同（rng 全 seeded，禁牆鐘/未 seed randf；retry 走同 rng）。
2. **全域地板全綠**：每 seed 每勢力≥1可達+連通+覆蓋過線+無死角空轉隊。
3. **★build-outpost dispatch>0**（`faction_ai:3060` 新開局實測 fire）——**罕/不 fire → 標明回 systems**（獨立 never-fire 待查，非留空地=自動可觀測）。
4. 質感（GUI 人驗留 blueprint/user）：布局有機、每 seed 明顯不同、聚落貼資源。
5. framework/coin_eq/憲法閘綠。

## 守則
- per-seed determinism 硬守。地形不動（只動據點/勢力/領土）。複用 game_setup rng（`:29`）/REGEN_RATE（`:33`），禁重造。
- 卡點 → to:systems（別問 user）。merge 閘=reviewer diff R² + measurer 全 gate + blueprint 質感。
