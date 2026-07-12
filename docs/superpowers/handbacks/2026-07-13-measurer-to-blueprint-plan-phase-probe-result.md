---
from: measurer
to: blueprint
status: consumed
topic: plan_phase organic驗——★高度同質化確認(成長phase 70-100%獨大,求糧幾乎不出現)+偏置實效約25-33%(非0但薄)；determinism CLEAN；GROW watch#3信號成立值得查
---

# 量測回報：plan_phase 分布 probe organic 快照（3seed×3mo, default.json）

工單：`2026-07-13-implementer-to-measurer-plan-phase-probe.md`。`.worktrees/plan-phase-probe`（feat/plan-phase-probe @6dd8e46）。determinism CLEAN（1seed×1mo byte-identical，`pp_det1.json`/`pp_det2.json`）。

## ①phase分布——★高度同質化，非implementer冒煙的「2桶」，是「1桶獨大+3桶零星」
月3終局快照（求糧/成長/聚勢/立國）：

| seed | 求糧 | 成長 | 聚勢 | 立國 | 總隊數 | 成長佔比 |
|---|---|---|---|---|---|---|
| 1337 | 2 | 12 | 2 | 1 | 17 | 70.6% |
| 42 | 0 | 7 | 0 | 2 | 9 | 77.8% |
| 7 | 1 | 18 | 2 | 3 | 24 | 75.0% |

**「成長」phase三seed皆獨大(71-78%)**，求糧phase幾乎不出現（月1甚至0/0/0，全隊初期都落成長）。implementer冒煙用1seed×1mo看到「一桶51一桶4」的初步跡象，本輪3seed×3mo正式窗**確認同質化是穩定現象，非單seed噪音**——非implementer原話「≥2種明顯不同phase模式」的健康版本，是「技術上≥2種但比例懸殊」。

## ②偏置實效——非0但薄，約25-33%
`bias_hit/bias_total`：1337=5/15(33%)、42=2/9(22%)、7=7/22(32%)。**有非空phase偏置map的隊裡，約1/4~1/3真的選中對應phase-option**，機制有作用但強度不高（其餘2/3隊雖有phase但選了別的option，被其他term蓋過）。非implementer要求的「求糧隊真偏覓食/買糧」的強訊號，是「偏，但弱」。

## ③同質化判讀——誠實標記，非判本slice失敗
按implementer信§3指示，此為記錄非失敗判定：**「成長」phase獨大**很可能與野心分布窄（前面已知風險，你memory裡`project_desperation_economy`等記錄過類似模式）同源——多數隊落在「食物尚可+人口未達擴張門檻」的中間態，`milestone_met`判定自然歸向成長階。這是**現象記錄**，方向判斷（要不要調`derive_plan_phase`門檻/這是否合理現象）留你裁。

## ④S2附帶watch——GROW紮營信號成立，值得查；貿易util未見異常
- **GROW watch#3成立**：成長phase佔隊數7成以上，若其中多數選「紮營」（`_phase_option_bias`裡GROW→{返家補給,紮營}其中一項）——本probe未拆分option選擇明細，只有bias_hit/total粗算，無法直接判「紮營→collapse定居」細節。若你要細查，需再加一層option-level probe。
- **貿易util watch#4**：本輪未見貿易相關異常probe觸發（`conq.declared`等既有戰略指標與S1/S2輪同量級，非本次重點但無異常尖峰）。

## 產物
`pp_det1.json`/`pp_det2.json`（determinism），`pp_organic_3mo.json`（3seed×3mo organic快照）。

## 待你
- 同質化（成長phase獨大）方向判斷：合理現象 or 需調`derive_plan_phase`門檻——我不代判。
- 若要GROW紮營細節（watch#3深挖），需implementer/systems加option-level phase probe，我再跑。
- S3（survival-bypass）序上按implementer註：organic驗回報後才dispatch，本回報即該觸發點。
