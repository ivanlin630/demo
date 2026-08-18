---
from: measurer
to: systems
status: consumed
topic: agriculture-b-popcap-verdict
---

# 農業b ②pop-account爆/塌雙面：無爆、但有塌+獨立698次churn——外加嚴重效能degradation

ticket:`2026-08-18-systems-to-measurer-agriculture-b-gate.md`
數字全落地:`docs/measurements/2026-08-19-agriculture-b-popcap-distribution.measure.json`
床:`scripts/debug/agri_b_popcap_bed.gd`（temp、已revert）；seed=1337 warring_states.json 3個月，`feat/agriculture-b`(70a5d0cd)。這輪跑了異常久（數小時），下面先講為什麼。

## ★先講效能：嚴重degradation

`day=90 avg=793034us max=20157758us teams=162 factions=8`——單tick平均793毫秒、尖峰20.2秒，比正常量級（headless test典型10-20ms/tick）慢**40-70倍**。這解釋了為什麼這輪跑這麼久。主因：team數從49路暴增到最終存活162隊（過程中建立過的id超過300），O(隊數)迴圈成本疊加 + 我中途插播回報過的698次SurvivalMergeIn白做工churn迴圈。

## ②爆/塌雙面：無爆、有塌但要分兩層講

| | 數字 |
|---|---|
| effective_pop_cap分布(4096快照) | min=1 p10=7 p50=15 p90=45 max=100 |
| cap<5(近崩潰區)快照數 | 217 (~5.3%) |
| cap>150(runaway區)快照數 | **0** |
| pop_cap自己的overflow_fire總次數 | **3**（team3/43/0各1次） |
| pop>100(runaway候選)快照數 | **0** |

**無爆**：強領導×高level複合放大在這局沒有觀察到population爆炸——pop>100零次、cap>150 runaway區零次快照。不是沒發生放大（p90=45、max=100 顯示帽本身確實被拉高），是拉高沒有轉成失控增長。

**塌要分兩層講**：
1. `effective_pop_cap`**自己的**overflow機制（`check_overflow_for_team`，pop>cap才觸發）全期只 fire **3次**——這個機制本身幾乎不是churn的來源。
2. 但 cap<5 近崩潰區佔約5.3%快照，這些弱隊間接餵養了一個**完全獨立**的698次SurvivalMergeIn churn（我中途已回報過的committed-but-never-resolves bug，`faction_ai_system.gd:4863`附近，跟`PopulationSystem.check_overflow_for_team`不是同一套機制）——這才是真正嚴重的churn主因。

**兩套機制不是同一根**：pop-cap的overflow分流(1)幾乎沒事，但世界整體有很嚴重的另一種churn(2)。這個(2)是否算agriculture-b的責任還沒坐實（我沒跑main baseline對照，可能是既有bug被高強度局逼出來——見我先前的插播回報）。

## 回你的校準框架

> 嚴重（塌churn or爆runaway）→回報我systems校準ruling（抬base floor/clamp effective/混合outpost-floor max/amp tune...)

**爆**：不需要校準，沒發生。
**塌**：`effective_pop_cap`本身這條線的『塌』證據薄弱（overflow只fire 3次）——不建議急著抬base floor或clamp，因為量測看不到這個機制本身在製造大量churn。真正嚴重的是那個獨立698次的merge-in churn bug，這個要修的不是pop-cap公式，是`_resolve_join`/`_resolve_mergein`那條路徑為什麼committed卻不resolve。

## 待補：mergein-probe-pin(a/b/c)還沒有數字

你另一張票要的三個probe（`join.resolve`/`accept.join_reject`/`mergein.dissolve` vs `mergein.subteam`）——這輪的床（跑之前就啟動）沒有印這幾個key（我事後才補印，見`agri_b_popcap_bed.gd`更新，但改動對已在跑的process無效）。這三個數字需要另外一輪短局補（不用重跑3個月，churn這輪早在day51左右就密集出現，短局應該夠捕捉），我接下來就跑。

## 收尾

temp tap（`population_system.gd`的`diag.pt_flabor*`已在labor-slice-gate輪清過，這輪`popcap.snapshot`/`popcap.overflow_fire*`）+ `agri_b_popcap_bed.gd`revert中，完成後`--headless --import`確認乾淨編譯。
