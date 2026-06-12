# Hand Back: 馬爾薩斯陷阱修正

> Branch: `feat/malthus-fixes`，plan: `docs/superpowers/plans/2026-06-12-malthus-fixes.md`

## 實作摘要

- `scripts/simulation/faction_ai_system.gd`：[Site] 選址 diff print（同 faction 同址不重印）；`_dispatch_builder` 各失敗點原因 log（資源不足 1.5x / 無 advisor / pop 不足 / subteam dispatch 失敗，同 faction 同原因 dedupe）；`_try_resume_construction` 加 3 天糧門檻；infra cadence 接 `check_construction_timeout`
- `scripts/data/tile_data.gd`：加 `construction_started_tick` / `construction_last_progress_tick`
- `scripts/simulation/outpost_system.gd`：`CONSTRUCTION_TIMEOUT`（30 天）+ `check_construction_timeout`（退 50% 料給施工團、tile 釋放）+ `construction_cost_of`；開工點記 started tick；`_tick_construction` 每次實扣進度更新 last_progress
- `scripts/simulation/resource_system.gd`：`COLLECT_RATE` 常數化，0.01 → 0.05（量測驅動，見下）
- `scripts/debug/game_sim_multi.gd`：FoodLedger 月度糧收支儀器（burn 估算 + ΔF 反推 income + tile 診斷欄位）；`SIM_CONFIGS` env 平行分工
- `scripts/debug/headless_test.gd`：Malthus Task1 / Task2a / Task2b 測試

## tune 迴圈記錄

### R0 基線（COLLECT_RATE=0.01，90 天）

全世界 food 釘 0 常駐（ledger income 估算在釘 0 時退化 = burn，不可信）。唯一健康樣本 merchant team2（pop1 outpost）income 3.4/day 反推 tile 池 ≈ cap（200-300）。

結構分析：
- tile 池常駐 cap（regen 8/call × ~26 call/day 遠超採集汲取）→ **REGEN_RATE 加大無效**（knob 1 跳過，量測驅動）
- collect 不乘 day_fraction → 遠區 2.4 call/day vs 近區 24 call/day（10x 結構差異，未動 — 連動風險見下）
- 遠區村收入 ≈ cap × rate × outpost_mult × pop_mult × 2.4 ≈ 7/day vs pop12 burn 28.8 → 4-5x 短缺
- 無 outpost 流浪團 collect 收入 = 0（`collect_resources` 只在 outpost tile 生效）→ survival 壓力天然保留，不受 rate 影響

### R1（COLLECT_RATE=0.05，90 天）

- game_sim_test team2（pop10 outpost）：22.9 天緩衝 ✓
- warzone 居民團（pop3，mountain pool=7）：income 7.5 vs burn 7.2，緩衝 12-15.5 天 ✓ 目標帶
- 無 outpost 流浪團維持 food 0（窮）✓
- 低 pop 高地利 team（pop1 在 plains pool=206）：囤到 1000+ 天 — P5 生育 cap = pop×0.2 → pop1 cap=0 不生，無負反饋（見待確認）

### R2（同參數，ledger 加 tile 欄位診斷）

釘 0 的村全是「人不在 outpost 上」（迎戰/逃跑/return_home 卡途中）— 行為問題非參數問題，調參無法解。在家的村全部轉正。

## 2 年驗證數據（4 config × 172800 ticks，平行跑，config 已還原 21600）

| 驗證項 | 結果 | 數據 |
|---|---|---|
| coin 守恆 delta=0 | ✅ | 全 4 config delta = 0.00 |
| ALL INVARIANTS PASSED | ✅ | game_sim_test violations=0 |
| 選址 loop 消失 | ✅ | [Site] 選址 print：9/1/7/6 次（原 C 期 4137 次同址 spam） |
| 復工 ping-pong 消失 | ✅ | 復工 print 0 次（原 704 次）；工地逾時取消 2 次（merchant，退料機制運作） |
| 居民村緩衝 7-14 天 | ⚠️ 部分 | 在家的村全轉正（mountain 村 12-15 天 ✓；plains/forest 高地利 + 低 pop → 囤到 100-3000 天，無生育負反饋故不回落）；「人不在 outpost」的村維持 0（行為問題） |
| 流浪團仍窮 | ✅ | 無 outpost 流浪團 food 0 常駐（collect 只在 outpost tile 生效，不受 rate 影響） |
| P5 生育 > 0 | ❌ | 全 config 生育/長大成人 = 0 — **非糧食參數問題**（多 team 緩衝 100+ 天遠超 7 天門檻）。根因：reaction winner-take-all 中 `_score_breed` max 0.5 < P2_produce 0.6 / P1_comply ~1.0 → 永不中選；且 minor cap=int(pop×0.2) → pop≤4 永不生。已記 known_issues W3 |
| 設施建造 > 2 件 | ❌ | 開工 4 次（game_sim_test 1 + merchant 3），完工 2 件 + 2 件逾時取消。根因見派工失敗分布（W4） |

人口曲線：game_sim_test 55 持平、tyrant 36→25（戰損）、merchant 48→42、warzone 53 持平。無生育 → 只減不增。

## 派工失敗原因分布（Task 1 log 揭露的黑箱）

- **資源不足 1.5x（material）壓倒性多數**（merchant 33+ 次、warzone 8 次；diff-dedupe 後仍最多）— leader team material 以 ~+0.2/day 涓滴爬升（18→24→51→66），civilian 門檻 75（50×1.5）要爬數年
- 資源不足 1.5x（tools，military 80+3 tools）次之
- 無 advisor 可派可升：2 次（merchant）
- pop 不足 / subteam dispatch 失敗：0 次
- 結論：建造凍結 = leader 行為性貧窮（常駐外面打仗/乞食，不在 outpost 採集），調 COLLECT_RATE 無法觸及。已記 known_issues W4

## 連動風險

- `resource_system.collect_resources`：近/遠區採集頻率 10x 差異（collect 不乘 day_fraction）。COLLECT_RATE ×5 同步放大此差異 — 玩家附近的村收入可達遠區 10x。主 session 評估是否要 collect 乘 day_fraction 正規化（屬世界模型變更，子 session 未動）
- `material` 採集同走 COLLECT_RATE → 建材收入也 ×5，建造解鎖加速（方向符合本 plan 目標，但價格表若以材料稀缺定價需複查）
- ore_gold/silver 為有限資源，開採速度 ×5（總量不變、coin 守恆不受影響，僅耗竭加快）

## 待主 session 確認

- P5 生育 cap = `population × 0.2` 取整 → pop ≤ 4 的 team 永不生育。低 pop 高地利 team 無人口負反饋 → 糧無限囤。建議後續 task：cap 改 `maxi(1, pop/5)` 或對 pop<5 開放 1 名額
- 釘 0 村屬行為問題（owner 常駐外面打仗/逃跑），參數無法修；若要修需動 task 優先序（世界模型，超出本 plan）
- FoodLedger income 在 food 釘 0 時退化為 = burn（消耗被 clamp）→ 讀數時只信 food > 0 的 team
