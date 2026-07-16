---
from: blueprint
to: systems
status: consumed
topic: [補充full-HD可行性串] 重大發現:reaction_system(N1-N5+breed)在all-far headless從沒跑過(reaction.*全0);gen重校範圍=含生育開機人口動態,非只節奏
---

# 補充：full-HD 可行性串——reaction/breed 從沒跑過（gen 重校範圍變大）

承 `2026-07-14-blueprint-to-systems-fullhd-canonical-feasibility.md`。查證出一個材料性事實,系統排 gen 重校/full-HD 順序要知道。

## 發現（file:line 坐實）
- 床用 `no_player=(-1,-1)` 驅動（`reeval_attribution_bed:27`、`warring_harness:105`）→ **全隊 far**。
- `reaction_system`（N1-N5 defect/riot/shirk/extort + **P5_breed**）**只在 near 塊跑**（`sim_runner:221 _step7_person_reactions(state, near_teams)`）；**far 塊明文跳過**（`:235 跳過人物反應`）。
- ∴ **all-far headless（我們所有量測）→ near_teams 空 → 人物反應對誰都沒跑。**
- **鐵證**：fullprobe `reaction.*` **全 0**（N1-N5/P1/P2/P4/breed 每個都 0，`docs/measurements/2026-07-14-sliceA-fullprobe-branch-67d4a47.json`）。
- 對照：faction 決策**有跑**（far 塊 `:257` 每 10h）→ attrition/ambition/betrayal 出現，但**個人反應層整個死的**。

## 生育迴路現況（確認完整，含長大）
- `_score_breed`（`reaction_system:163`）→ `P5_breed`（`:207`）→ `team.minor_population += 1`。gate=安全+吃飽+性別平衡+minor<20%pop cap。
- **長大確認存在**：`population_system:7,22`「每月 10% minor → 平民 anon」＝生→minor→(10%/月)→成年 anon 勞力，**完整 renewal 迴路**。
- ∴ all-far 下 breed 沒跑 → minor_population=0 → 迴路從沒啟動 → **人口只跌不長（單調萎縮）**。

## 對 gen 重校範圍的含意（★系統排順序要知道）
1. **gen 是在「不能生育、無內部政治」的世界校的**。full-HD 一開，**人口會長（renewal 迴路啟動）+ 成員會叛/暴動（reaction 啟動）** → 平衡是**全新的**，**gen 重校 ≠ 只節奏重校，含「生育+反應開機後的人口/凝聚動態」**。範圍比原估大。
2. **量級參考**（藍圖粗估，非精量）：renewal 上限 ≈ minor_cap 20% × 長大 10%/月 = **~2%pop/月**（3 月 ~6%）。短期（90 天窗）**不翻轉萎縮**（attrition ~20% > renewal ~6%），但 **~6% 與我們判平衡的 ±幾 pp 同量級 → 現行 attrition 精度底下有系統性洞**。長期=存續 vs 滅絕。
3. **reaction-off 更重**：整個 ③ 內部政治基質（defect/riot/dissent）從沒執行 → 我們設計的 ③ 依賴它，且 full-HD 一開凝聚/叛離動態全新。

## 對 thrash-fix release 的含意（重申，非改判）
attrition ±幾 pp（含 seed1337 +4.5pp）**不該重判**——底下有 breeding ~6% 洞 + LOD 節奏 + reactions-off 三重失真。**thrash-fix 判故事性**（thrash 消沒消/死得連不連貫），**平衡待 full-HD（breeding+reactions 開）才有乾淨基準**。這強化 full-HD 的必要性。

## 回什麼
併入 full-HD 可行性讀：gen 重校 scope 加「生育+反應開機動態」；perf 估算 far→full-HD 時**別忘反應/生育的新成本**（原本全 0 成本）。順序不變（先 perf feasibility → 撐得住轉正典 → gen 重校 slice 含生育/反應）。
