# gen 參數校準（狼密度 + 開局緩坡）— Plan（L2,藍圖裁定=spec）

> 裁定 `2026-07-03-blueprint-to-systems-gen-params-ruling`:①a roving 拉高（驗收:**每 seed ≥~1 狼候選+知足/商業仍多數**）②c gen pop≈承載力 1.2×+開局糧倉 buffer 緩坡（驗收:**6 月 pop 緩坡無滅團潮+稀缺壓力仍在 raid/貿易照 fire**）。
> 量測基礎:承載力係數實測=現初始 pop 的 42-43%（兩 config 同）→ 目標初始 ≈ 現值 ×0.51（=1.2×承載）or 抬承載。工具:`gen_census_bed`（GC_CONFIG/GC_SEEDS,秒級）+ `longwindow_bed`（LW_CONFIG=default,6 月 pop 曲線）。

## Task 1 — 狼密度（config 免審批層）
1. `config/default.json` `roving_count_range` 2-4 → 6-10（起點;warring 4-8 → 6-10 同步微調）。
2. `gen_census_bed` 10 seeds 驗:狼候選 ≥~1.0/seed、獨立 archetype 商業+定居仍 >60%（知足多數）。不達 → 調 range 重跑（census 秒級,迭代便宜）。

## Task 2 — 開局緩坡
1. **降 pop 或抬承載組合**（實作選,原則:別把隊壓到 EXPAND_MIN_POP=8 以下太多——狼要能爬）:
   - 候選 a:`teams_per_faction_range`/`factions.count` 降隊數（保 population_range [8,25] 個體隊健康）。
   - 候選 b:`outposts.total_count`/`resource_richness` 抬承載（順帶密度+接觸=戲,但改承載值本身,校準迴圈定）。
   - 組合皆可,以 Task 2.3 驗收為準。
2. **開局糧倉 buffer**:world_generator/game_setup outpost 初始 `public_storage["food"]` 注入 config 旋鈕（`opening_granary_food`,TEST VALUE）——**走 TileBank.deposit（bootstrap 豁免區亦建議走 bank,reason="gen_seed"）**。
3. 校準迴圈:`longwindow_bed` LW_CONFIG=default 6 月（~10 分/輪,**錯開跑勿並行**）——驗收:pop 曲線緩坡至穩態（**無前 3 月滅團潮**:月降幅 <15%,TEST 判準）+ `surv.loot_dispatch>0`+`[Market] 成交>0`（稀缺壓力仍在）。預算 2-3 輪迭代。
4. warring config 同係數調整（其為考試賽道,開局屠殺同病;倍率沿 default 校得值）。

## Task 3 — 驗收彙整
1. census 終值（狼/seed+archetype 佔比）+ default 6 月 pop 曲線（前後對照:197→83 舊 vs 新緩坡）。
2. 回歸:headless（1 FAIL pre-existing 容忍）+0 SCRIPT ERROR、framework 7/7、coin_eq delta=0、InvariantAudit 0。**seeded pointwise 必 DIRTY**（gen 參數變=世界不同,免跑;行為對照=月線曲線）。
3. warring 既有 bed baseline JSON 全作廢（gen 變）——handback 標明,重擷新 baseline（`WARRING_BASELINE` 流程）。

## Handback
`2026-07-03-gen-params-calibration.md`:終值 config diff、census 前後、pop 曲線前後、baseline 重擷說明、TEST VALUE 清單。

## 注意
Godot wrapper;longwindow 5400 背景輸出落檔;census 秒級隨便跑。config 任何層自由改;gen 碼=buffer 旋鈕最小侵入。禁碰:決策/asm/combat 邏輯（純 gen/config 校準）。
