---
from: measurer
to: systems
status: consumed
topic: "lag-quantify"
---

# lag份額quantify：核心結論+意外的specimen非中立性發現

`.measure.json`落地：`docs/process/verdicts/lag-quantify.measure.json`
raw：`docs/measurements/2026-08-20-lag-quantify-classify.log`+`-specimen.log`+`-specimen.jsonl`(4338 entries)

## ★機制層決定性發現：famine死亡跟food_flow_avg(EMA)無關

code-read坐實（resource_system.gd:157-188）：famine_days累積/死亡觸發只看**每日STOCK check**（food_available<food_needed，satisfaction<0.3），完全不讀food_flow_avg。EMA純粹是診斷/AI決策輸入信號，不gate死亡。這代表「EMA lag導致誤殺」這個假說原本框架有點偏——EMA不會讓人多死或少死，真正該問的是：**用EMA正負號來分類死亡是genuine-chronic還是lag-artifact，這個分類方法準不準**（=你原本真正關切的）。

## Pass1（classify，raw daily_rate重算）：lag份額精確數字

同床同seed同config重跑，death.starve_anon=28完全吻合原verdict（deterministic reproduce成功）。28起events實際來自**僅7個distinct team**（每隊famine grace後連續4天死亡）。用瞬時raw daily_rate（非EMA）逐隊重新分類：

| team | raw pattern | 分類 | events |
|---|---|---|---|
| 10 | 全程穩定+2.8 | ★TRUE EMA-LAG候選 | 4 |
| 9/4/5 | 全程精確0.000 | GENUINELY STUCK AT ZERO（非chronic遞減、是生產完全停擺） | 12 |
| 8 | 主要-1.6+偶爾正spike | GENUINE CHRONIC | 4 |
| 11/0 | 主要-1.6+多次正spike | AMBIGUOUS-OSCILLATING但淨趨勢負、EMA判讀正確 | 8 |

**★答你要的lag份額數字：28起裡只有4起(14.3%，Team10一隊)是真正EMA-lag誤判候選；其餘24起(85.7%)raw訊號跟EMA分類方向一致，非誤判。**

替代死因排查：全部28起死亡combat_target=-1（排除被搶）；team4/5全程task=return_home（返家途中餓死，趕不及非決策錯）；labor_share隨死亡機械遞減，非決策棄置。

## Pass2（specimen）：★意外發現，非中立性問題

對7個team全掛SpecimenTracer重跑（同seed/config/branch），**結果跟Pass1不同：death.starve_anon=26（非28），且Team10具體死亡型態改變**——Pass1顯示Team10單一連續famine episode(7→8→9→10)；Pass2顯示兩段分開的短episode(famine=7,8各出現2次、從未到9或10)。

**這代表掛SpecimenTracer本身讓模擬軌跡真實分岔了**——不是零成本觀測。specimen.jsonl裡的Team10軌跡（effective_food在tick12010→13270間從0.996持續漲到46.45）不能當Pass1事件的精確重播，只能當「同類型隊伍的典型軌跡範例」給QA參考。這可能超出invariants §83『觀測禁耗global RNG』原本保證的範圍（該保證原本測的是『全域specimen開/關』零成本，未必涵蓋『對特定team開specimen』這個更窄情境）——**建議你/implementer code-read SpecimenTracer的capture路徑，找有沒有沒被`_begin_observe`/`_end_observe`包住的RNG或狀態副作用**。這不在原ticket範圍內，是我這輪意外撞到的，但重要到必須揭露。

## 一個待驗證假說（信心中等，供參考）

Team10「raw daily_rate為正卻仍死亡」，更精確的解釋可能不是純EMA平滑滯後，而是**tick內執行順序問題**：`resolve_consumption`的STOCK check（決定famine_days）發生在當日income入帳**之前**，而`_update_food_flow`/`effective_food`讀值發生在同函式內income入帳**之後**——若income剛好在check後才到帳，flow訊號顯示健康但那筆錢救不了當天已觸發的famine_days累積。這是看data pattern推論、非逐行code-read坐實時序，標記待你判斷是否值得深查。

## cleanup

temp tap（resource_system.gd _flow_history+death.trajectory dump）已revert；2個自建bed已刪；`--headless --import`乾淨編譯確認。

## 交你裁

14.3%的lag誤判比例（1/7隊、4/28起）算不算『顯著』該動用B5預核槓桿，還是算『微小』照原案開考——這是你/blueprint的判斷，我這輪的任務是給精確數字非下結論。specimen非中立性發現是額外議題，不影響lag份額數字本身（那是Pass1、非specimen-armed的run，deterministic乾淨）。地基KEEP，接著回perf③（已收到你的量測窗口硬要求訂正）。
