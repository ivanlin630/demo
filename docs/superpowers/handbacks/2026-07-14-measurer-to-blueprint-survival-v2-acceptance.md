---
from: measurer
to: blueprint
status: consumed
topic: [v2驗收結果·headline FAIL] attrition沒回落(仍1.9-3.6倍main)+★Team10(flagship修復對象)乾淨跑又餓死滅團,矛盾工單陳述
measured_at_head: branch=2ee09f9b main_baseline=916b0b7d
---

# 求生層 v2 全維度重驗：headline 沒過

工單：`2026-07-14-systems-to-measurer-survival-v2-acceptance.md`。完整數字：`docs/process/verdicts/survival-layer-v2-acceptance.measure.json`。raw log 全落地 `docs/measurements/2026-07-14-survival-v2-*`。

## ★★headline（attrition 回落）：沒過

同世界 full_probe（branch vs main baseline，3seed×3mo，起始 pop 對齊）：

| seed | v2 branch | main baseline | 倍數 | v1(前輪) | 變化 |
|---|---|---|---|---|---|
| 1337 | **45.3%** | 13.5% | 3.4x | 50.5% | 略降但仍3.4倍 |
| 42 | **42.8%** | 11.8% | 3.6x | 34.7% | **★比v1更差** |
| 7 | **31.5%** | 16.7% | 1.9x | 31.3% | 幾無變化 |

工單宣稱「attrition 從惡化 1.9-3.7× 回落到 ≈main baseline 水準」——**實測沒發生**。三 seed 仍是 main baseline 的 1.9-3.6 倍，seed42 甚至比 v1 更差。established 沒回歸（`[0,0,2]` 兩邊一致，這項唯一過）。

## ★意外發現：Team10（flagship 修復對象）乾淨跑又死了

`reeval_attribution_bed`（同 v1 輪同款乾淨單run方法，唯一差異=code版本）：
- **v1 跑**：0筆`[Survival]`、0筆Famine/Extinct，Team10 存活到 day90。
- **v2 跑（本輪）**：57筆`[Survival]`（Team14 為主）；**Team10/Team14/Team12/Team4/Team11/Team3/Team1/Team6/Team8 多隊出現 famine**，Team14/Team12/Team10/Team4/Team1 皆 Extinct。

**這直接矛盾工單陳述「Team10 thrash 仍治好（不 day89 餓滅）」。** `single_team_trace_bed`（v2）複核也選中 Team10 為代表隊：decision_count=965（v1 Team7型是113，暴增）、winner分布覓食57/建設908（建設佔94%——變成新的高頻+高鎖，非 v1 呈現的健康多樣化31%建設）。

## reviewer 3 條件逐項
1. **#2 over-trigger 換皮**：本身過（reeval.crisis=41，implementer報49同量級；TOTAL=3157，v1同法3092，量級相近）。但頻率沒換皮≠attrition解決——見上。
2. **#3 人格化 trap（謹慎升階抽驗）**：**incomplete**——沒有現成工具可篩「慎重trait高leader」做定向抽驗（trait值不在任何log tag），需新加print，超出我界（不改scripts/），標記給implementer/systems。
3. **#1 隱含bisect觸發**：★**已觸發**——依工單條款3，attrition沒回落到baseline±餘裕，此時才要求真bisect（隔離Fix1-4 vs Fix2-v2/Fix3-v2 各自貢獻），非我現在做。

## 建議
**不建議 release-pass**。headline 沒達標，且新發現的 Team10 死亡矛盾了修復宣稱本身——這比單純「attrition數字沒達標」更嚴重，代表 v2 的改動可能連 v1 已修好的部分也動搖了。建議依 reviewer 條款3 走 bisect，隔離 Fix2-v2/Fix3-v2 各自對 attrition 的貢獻（正負皆可能），systems 定位後再議下一輪驗收。

## incomplete
謹慎升階抽驗（缺 caution-trait log tap）、觀察點 A/C（上游 headline 已 FAIL，優先度降，未細驗）。
