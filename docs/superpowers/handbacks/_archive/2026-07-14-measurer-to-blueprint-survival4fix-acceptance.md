---
from: measurer
to: blueprint
status: consumed
topic: [全維度驗收結果·不建議直接release] 求生層4-fix——thrash只治Team10型(main本身也廣泛有此病非新);★population attrition比main高2-3倍(3seed一致)
measured_at_head: branch=eef534a7 main_baseline=0e34e00e
---

# 求生層4-fix 全維度驗收：不建議直接 release-pass

工單：`2026-07-13-systems-to-measurer-survival-layer-4fix-acceptance.md`。完整數字：`docs/process/verdicts/survival-layer-4fix-acceptance.measure.json`。raw log 全落地 `docs/measurements/2026-07-14-survival4fix-*`。

## ★headline 發現：population attrition 全面惡化（3 seed 一致）

full_probe（`seeded_warring_bed`，warring_states.json，3seed×3mo，branch vs main baseline 同世界對照——起始 pop 幾乎一致，已排除 worldgen 偶然偏差）：

| seed | 起始pop(branch/main) | 終pop attrition% branch | attrition% main | 倍數 |
|---|---|---|---|---|
| 1337 | 436/436 | **50.5%** | 13.5% | 3.7x |
| 42 | 423/424 | **34.7%** | 11.8% | 2.9x |
| 7 | 362/363 | **31.3%** | 16.7% | 1.9x |

**三 seed 方向一致**：branch attrition 是 main baseline 的 1.9-3.7 倍。established 沒回歸（兩邊都是 `[0,0,2]`），determinism MATCH，但這個 population 死亡率惡化是硬指標，我沒能力判是哪個 fix(1-4) 造成，需 systems 定位或 revert-bisect。

## 5 守衛逐項

1. **thrash（headline）＝部分過，非全消**：`reeval_attribution_bed`（乾淨單 run）確認 Team10 本身不再 thrash、存活到 day90。但 `single_team_trace_bed` 跑出的**另一個 seed1337 世界**（這支床跟 reeval_attribution_bed 的 seed 機制不同，兩者非同一世界——見 measure.json caveat）裡，**Team14/Team16 仍出現同型 thrash + famine 死 + 滅團**。★更關鍵：main baseline 的 detach log tail 也大量出現同一 pattern（Team11/16/18/21/27/70...）——**這證實 thrash 是 main HEAD 既有問題，非 branch 引入，但 4-fix 也沒把它治好，只治好 Team10 這條特定路徑**。
2. **頻率＝過**：reeval TOTAL=3092（跟implementer報3239同量級，遠低於基線13997）；Team7型 decision_count 381→113。
3. **升階＝過**（此樣本）：single_team_trace_bed 該 run winner分布 覓食73/建設35/求和4/迎戰1，建設佔31%，非100%底層鎖死。
4. **覓食可達性＝過**（此樣本）：113 筆 candidates 零 ✗ 標記。
5. **不回歸＝★FAIL**：established 沒回歸，determinism MATCH，但 attrition 見上，明確惡化。HOB obey=94.7%，違規4.2%全屬 arbiter_latch（單一T53型，非本輪 fix 範圍，need systems 確認是否 pre-existing）。

## 3 觀察點
A/C 時間考量未細驗。B（well-fed 卡覓食）疑跟 guard1 發現的廣泛 thrash pattern 相關，但沒逐隊拆 esteem/faction signal 因果，交給 systems/你判斷要不要追。

## 建議
**不建議直接 release-pass**。attrition 3-seed 一致惡化是硬指標，建議 merge 前先讓 systems 定位是 fix1-4 哪個造成（或 bisect），或至少讓你知情後裁定是否可接受這個代價換 Team10 型修復。缺 A/C 觀察點，標記 `incomplete`。
