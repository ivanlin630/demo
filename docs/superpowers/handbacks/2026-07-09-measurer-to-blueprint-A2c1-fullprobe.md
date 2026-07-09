---
from: measurer
to: blueprint
status: open
topic: A2c1 survival-value 標準 full_probe 3-way 量測結果——硬閘技術PASS但spec驗收線①③FAIL
---

# A2c1 survival-value 3-way full_probe 結果

seed=1337, 3月(2400 tick)。baseline(a3db7c9 main pre-fold) / fold(423924c 純fold) / upgrade(4e57ea9 survival-value+can_reach guard)。
數字檔：`docs/process/verdicts/A2c1.fullprobe.json`（完整並排全維度）。

## 一句話
**硬閘6/7技術PASS，但spec自己的驗收線①③明確FAIL**——survival-value 這版在此 seed 下比純fold更差，不是更好。

## 關鍵數字（決策面，本slice核心）
| 指標 | baseline | fold | upgrade |
|---|---|---|---|
| merge.consolidate_dispatch | 978 | 154 | **320（反彈）** |
| merge_appl.chose_整併 | 0 | 154 | **320** |
| merge_appl.chose_other | 0 | 166 (51.9%) | **0 (0.0%)** |

upgrade 讓「所有」merge-applicable 隊 100% 選整併，0 隊選 other——比 fold 更逼近「再逼近100%併」的反面極端，直接撞驗收線③紅線（「非再逼近100%併」）。

## 生存面（驗收線①）——零改善
| 指標 | baseline | fold | upgrade | 目標(回升/回落) |
|---|---|---|---|---|
| extinct.starve | 16 | 19 | 19 | ≲16(回落)——持平未回落 |
| avg team-size | 7.03 | 5.64 | 5.64 | 回升(>5.6)——持平未回升 |
| join.resolve | 24 | 14 | 13 | 回升(>14)——**倒退** |

final teams/pop/attrition 三項與 fold **逐位元相同**（36/203/46.7%）——survival boost 在此 seed 下對最終世界結構無可觀測正面影響，只讓決策路徑更集中整併。

## 硬閘（技術數字，判斷交你）
- 閘6 merge<800：320 PASS（遠低於閘值，famine-window caveat 不適用）
- 閘7 extinct.starve≤19：19 PASS（踩線持平，非改善）

## 誠實揭露
- baseline(main) log 有 ~10+ 次 `SCRIPT ERROR Out of bounds index 50 (on Dictionary)`，fold/upgrade 皆無重現——判讀為 main pre-existing quirk，與本 slice 無關，未深追（非本工單範圍）。
- team-size 直方圖未產（加會動 scripts/，鐵律5禁）——用 final pop/teams 算 avg 代替。
- 標準床(HOB/constitution/sanity/TeamTrace) 本工單未獨立重跑，沿用 implementer 自報告(全綠)。

## 你判
數字全齊(4條驗收線+2硬閘)。①③FAIL、②④觀察通過。硬閘技術PASS但不代表spec意圖達成——survival-value 這版看起來讓問題往另一個方向走偏(從「不夠併」的978，越過健康的154，彈到「又太併」的320+0% other)，不是收斂到期望的「回健康+仍有other選項」。是否算「這版不算過、要調參重跑」還是「先收再說」，判準在你。
