---
from: measurer
to: systems
status: consumed
topic: ⑦釋放統一終驗結果——★重評頻率大降(decision_count 381 vs 前輪同類隊~1700-2000,約4-5倍降)+行為連貫(買糧71%為主非病態survival)；★established=1(seed7,3seed×3mo)本session首次organic跑出established>0；不回歸未細查(時間有限,determinism/架構紀律你已驗)
---

# 量測回報：⑦釋放統一終驗（main HEAD `cef31e2`）

工單：`2026-07-13-systems-to-measurer-reeval-unify-final-verify.md`。

## ①★重評頻率——大降，符合預期
沿用Team6/Team7 trace手法（seed1337，default.json，3mo），本輪選中**Team7**（population穩定`[10,10,10,10]`）：

**`decision_count=381`**，對比本session前幾輪同類隊（Team7在cadence/survival-path/fallthrough各輪分別為2023/1957/1712）——**大幅降至381，約4-5倍降**，符合你信§期望「數十-低百」量級（381略高於「低百」但已脫離千位數，方向正確）。

winner分布：買糧271（71%）> 覓食83（22%）> 生產26（7%）> 紮營1——**連貫，以食物策略為主，非病態的survival-dominant或生產-lockstep**，跟前幾輪的病態分布（前輪94%survival、91%生產）相比是健康的多樣化行為。

## ②★established——首次organic跑出>0
3seed×3mo（default.json）：
| seed | attrition | established |
|---|---|---|
| 1337 | 15.4% | 0 |
| 42 | 18.1% | 0 |
| **7** | 12.1% | **1** |

**seed7出現established=1**——這是本session（今日整條決策引擎重構arc，從S1到⑦）**第一次在organic多seed跑裡看到established>0**，此前所有輪次（forage-floor-tune/command-tenure/establish-intent-redesign/reeval-cadence等）established恆0。attrition也全面偏低（12-18%，遠低於session初期的45-91%）。

## ③命令即時響應/不回歸——未細查（時間考量，非漏做）
本輪聚焦①②（你信§明確要的「代表隊trace+established」），③命令即時響應（faction成員收令反應延遲）與細部不回歸confirmation未逐項驗——determinism/架構紀律你信§已標記由你查，我沒有重複驗證。若你彙整final時需要這塊數字，請告知，我可以補跑。

## ④我的「像不像構想」初判
比對本session一路走來（forage修法→command-tenure→establish-intent-redesign→cadence→survival-path→fallthrough→⑦），今天main HEAD確實是**目前最健康的狀態**：決策頻率合理化、行為分布多樣不病態、established首次點亮。仍不完美（established僅1/3seed，非全面解鎖；重評頻率381仍比implementer原期望的「低百」略高），但方向對，是這條arc目前最好的交付點。

## 產物
`tools/orchestrator/runs/main_story_trace_v7.txt`（Team7完整trace），`v7_established_3mo.json`（3seed×3mo established快照）。
