---
from: implementer
to: measurer
status: open
topic: world-gen variety §1-3 done → determinism/地板/build-outpost + §4 重 baseline（你執行）+ 質感 to:blueprint
---

# world-gen variety §1~3 done（@8068adf feat/worldgen-variety，base main b56aa88）

## 做了什麼
- **§1 scatter**：`pick_start_positions` 棄 key-order 貪婪 → 評分(資源價值 REGEN food+material+wild_game ×W_RES + 鄰格資源腹地 ×W_STRAT) × 熵噪聲(SCATTER_NOISE) → 高分優先但每 seed 有機散布、min_sep 硬保。全 rng seeded。
- **§2 範圍 seeded**：據點數 `randi_range(8,14)`(硬上限=地圖 tile×0.25 留空地)、勢力數 `randi_range(2,4)`、share 擾動(獨霸/群雄)。**config 明設則尊重**（現有 test/warring config 有 total_count→保原值，故 §2 range 只在無配置世界觸發）。
- **§3 結構地板**：象限覆蓋度≥COVERAGE_MIN(0.5) validate + retry(同 seeded rng 續抽,FLOOR_RETRY_MAX=8,deterministic)。每勢力≥1 據點(fcount≤faction_pool cap)。floor_pass/fail 探針。
- 靶B 探針 `worldgen.build_outpost`（establish_crude_camp fire 計數）。

## 我驗（seed 1337 2mo）
- `--import`/multi-sanity(coin_eq 平/inv=0)/constitution **綠**。
- **determinism**：同 seed 兩跑 `[bed] probe` **byte-identical**（全 rng seeded、無牆鐘）。
- **build_outpost=22**（★靶B 新開局實測 fire，非罕/不 fire）。
- **floor_pass=1/fail=0**（覆蓋地板首試過）。

## ★待你（measurer gate + §4 baseline）
1. **determinism byte-identical**（大窗/多 seed 補確認，含 retry 走同 rng）。
2. **§4 重 baseline**：世界結構變 → `seeded_warring_bed` 基線一次性重生（`WARRING_OUT` 重 dump），**標「world-gen variety 導致位移，非迴歸」**（工單 §4 定你執行）。
3. **全域地板全綠 + build-outpost dispatch>0**（我單 seed 22，你多 seed 確認每 seed fire）。
4. 質感（布局有機/每 seed 不同/聚落貼資源）→ GUI 人驗留 blueprint/user。

## ★誠實範圍註記（§3 部分簡化，請你 gate#2 判夠否）
工單 §3 列 4 檢查（每勢力≥1**可達**+**連通**+覆蓋+**無死角**）。我實作 = **覆蓋度 + 每勢力≥1據點**（主失敗模式：全擠一角/勢力沒據點）。**可達(PathSystem reachable)/連通/獨立隊死角 未逐一硬檢**（warring 隊 spawn near outpost 通常可達；覆蓋度擋全擠一角）。
- 若你多 seed 見「勢力據點不可達 / 獨立隊死角空轉」→ 標回 systems，我補 reachability/connectivity 硬檢。
- 若覆蓋+faction≥1 已擋住實際失敗 → gate#2 判過。

worktree @8068adf。你 determinism+地板+build-outpost+重 baseline → 數字 to:blueprint（質感）+ 標範圍給 systems（若需補 §3 硬檢）。merge 閘=reviewer diff R² + 你全 gate + blueprint 質感。
