# Spec — world-gen variety（技術 / systems HOW）

> 願景 = `2026-07-12-worldgen-variety-design.md`（blueprint，reviewer 對抗① CLEAN）。每 seed 開局世界更變化：據點 seeded 散布（棄 key-order）+ 據點數/勢力數/領土隨 seed 變 + 放野失衡 + **全域結構地板（能跑）**。守 per-seed determinism、地形不動（已 seeded）。

## 現況錨點（characterize，file:line）
- **`world_generator.pick_start_positions(state, n, min_sep)`**：loop `state.world.tiles` **key-order 貪婪**選前 n 個 ≥min_sep → **不用 rng**、掃描式規則、每 seed 同（tiles 生成序固定）。= 主替換靶。
- **`game_setup`**：`rng = RandomNumberGenerator.new(); rng.seed = config.seed`（`:29-30`，**seeded rng 已在，pick_start 沒用它**）；`total_count=10` fixed（`:73`）；`indep_ratio→indep_count`（`:89`）；faction share by weights（`:108-112`）。
- tile 資源值可讀：`ResourceSystem.REGEN_RATE`/`TERRAIN`（plains food 8 / forest material 12 / mountain 等）+ `tile.resources`（wild_game）。
- build-outpost 決策：`faction_ai:3060` / `outpost_system:295-324`（機制在）。

## §1 據點評分 + seeded scatter（棄 key-order，靶A 位置熵護欄）
`pick_start_positions(state, n, min_sep, rng)`（**加 rng 參**）：
1. **評分全 tile**：`score(tile) = 資源價值 × W_RES + 戰略因子 × W_STRAT`
   - 資源價值 = f(terrain 產能 REGEN_RATE food+material + wild_game)——聚落貼資源。
   - 戰略因子 = f(中心度/離邊界、鄰近資源多樣性)——TEST VALUE，先簡（中心度或鄰格資源和）。
2. **★位置熵護欄（防 re-regularize，靶A 硬條件）**：**非純 argmax**——`min_sep` 過濾後的候選池，`rng` 從 **top-K（K=剩餘需求×ENTROPY_MULT）隨機挑**（或 score + `rng` per-tile 噪聲 `×(1+rng.randf_range(-NOISE,NOISE))`）。→ 高分區優先但每 seed 不同、有機非格狀。
3. min_sep 強制（同現行）。回 n 個 seeded 散布位置。

## §2 範圍（TEST VALUE，seeded）
- **據點數**：`total_count` 10 → `rng.randi_range(OUTPOST_MIN(8), OUTPOST_MAX(14))`。**硬上限 = 地圖容量比**（`n <= 地圖 tile 數 × OUTPOST_DENSITY_CAP` 留足空地）。
- **勢力數**：faction count → `rng.randi_range(FAC_MIN(2), FAC_MAX(4))`。
- **領土 share**：faction weights 加 `rng` 擾動（獨霸/群雄/稀疏放野）。indep_ratio 亦可 seeded 微變。

## §3 全域結構地板（靶C，放野內夾這層＝能跑不壞死）
scatter + 分配後**驗 + 修**（不過則調整/重撒，同 seed 仍 deterministic）：
1. **每勢力 ≥1 可達據點**：faction 至少 1 outpost，且其成員起點可達（PathSystem reachable）。
2. **領土連通**：faction 的 outposts 連通（或不強求連通但不孤島全散）。
3. **散布覆蓋度下限**：象限/包圍盒覆蓋 ≥ COVERAGE_MIN（防全擠一角）。
4. **獨立隊不全死角**：independent 隊起點非全被圍死（有覓食/移動空間）。
- 違反 → **retry（rng 續抽下一組，bounded N 次）** 或 fallback 補位（deterministic）。**地板是硬約束、失衡是放野**——夾在地板內自由。

## §4 重 baseline 程序
世界結構變 → `seeded_warring_bed` 基線一次性重生（`WARRING_OUT` 重 dump）。**明確一次性預期位移**（非迴歸 bug），舊 baseline 作廢、新 baseline 存檔。measurer 執行 + 標記「world-gen variety 導致的 baseline 位移」。

## ★硬驗收 gate（measurer 驗）
1. **determinism**：同 seed **byte-identical**（headless 自比兩跑；rng 全 seeded、無牆鐘/全域 randf 洩漏）。
2. **全域地板**：每 seed 每勢力 ≥1 可達據點 + 連通 + 覆蓋過線 + 無死角空轉隊（§3 全綠）。
3. **★build-outpost dispatch>0（靶B 獨立項，never-fire 教訓）**：新開局下 `build-outpost` 決策路徑（`faction_ai:3060`）**實測 fire**。**罕/不 fire → 回報 blueprint**（另一 never-fire 待查，非本 slice 保證留空地=可觀測）。
4. **質感（GUI 人驗）**：布局有機、每 seed 明顯不同、聚落貼資源。
5. framework/coin_eq/憲法閘綠。

## 觸及檔
| 檔 | 改點 |
|---|---|
| `world_generator.gd` | `pick_start_positions` +rng+評分+熵護欄；tile 評分 helper |
| `game_setup.gd` | 據點數/勢力數/領土 seeded range；§3 全域地板 validate+retry |
| `seeded_warring_bed.gd`/baseline | 重 baseline（§4） |
| `warring_harness.gd` | +地板/覆蓋/build-outpost dispatch 探針 |

## 守則
- per-seed determinism 硬守（全 rng seeded，禁牆鐘/未 seed 全域 randf）。
- 地形不動（已 seeded，本 slice 只動據點/勢力/領土）。
- 複用既有（world_generator/game_setup rng、REGEN_RATE 資源評分），禁重造。
- 全走 seeded rng，過框架內冗餘 lens（新評分 term 別跟既有撞）。

## 流程
spec → **R②**（審評分/scatter/地板實作健全 + 冗餘 lens）。R① 已過。→ implementer 疊 worktree → measurer（determinism 自比 + 全域地板 + build-outpost dispatch + 質感 + 重 baseline）→ 數字 to:blueprint。
