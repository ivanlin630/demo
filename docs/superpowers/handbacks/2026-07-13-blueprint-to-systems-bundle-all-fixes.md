---
from: blueprint
to: systems
status: consumed
topic: [★用戶裁定·全部打包一次修] Team10 override thrash+crisis-381 de-patch+尊重層乘法陷阱三項一起做,完後一次跑量測驗收
---

# 用戶裁定：全部一起修，修完一次跑

不要分批、不要一項項驗，三項全部做完再一次量測驗收（省重複跑量測成本）。

## 要修的三項

### 1. Team10 非-unified求生 override thrash（真殺隊bug）
見`2026-07-13-systems-to-blueprint-roach-team10-thrash.md`。根：非-unified隊`_evaluate_solo`(idle→建設) vs `_evaluate_survival`(legacy override,缺糧→貿易)同tick打架，task每tick互蓋，訂單做不完，Team10 day89三人餓死滅團。
修向：退役非-unified隊的`_evaluate_survival` override，讓求生也走`_decide_unified`引擎（鏡射:3046-3047 unified隊的skip邏輯）。**你信裡標示為decision-core結構fix**，照你判斷走spec→reviewer R②→implementer。

### 2. crisis reeval de-patch（重評381根因，非bug，純頻率優化但你判斷可跟①同源合併）
見`2026-07-13-systems-to-blueprint-seed-cadence-rootcause.md`。根：`_decision_crisis`是level-trigger非edge-trigger，慢性糧負隊每tick觸發crisis→繞過cadence節流，crisis reeval 13087次(93%占比)裡本該走的`/4`短throttle變死碼。
修向：crisis改邊緣觸發（進入crisis當下fire一次，之後走/4節流非每tick）。你信裡提過①②可能同一spec收斂——若跟第1項同屬「求生層未統一」家族，你判斷是否合併同一份spec。

### 3. 尊重層(esteem)乘法門檻雞生蛋陷阱（今天blueprint+measurer合查發現，新問題，尚未開工單過）
現象：Team7(day27後unified隊)day22-90整整67天卡在生存底層(覓食/買糧)，沒進到生產/建設「升階」。
根因（`need_hierarchy.gd:57` + `options.gd:136`+`terms.gd:15`）：
- 尊重層urgency = `food_ready × safe_ready × ambition_gap`，food_ready要接近5天(SURVIVAL_SATED_DAYS)才夠高，是**乘法門檻非漸進**
- 但買糧候選條件`food_days<3.0`(DESPERATION_DAYS)，救回來的量大機率只夠拉回3-5天邊緣，**碰不到5天舒適線**
- 結果：舒適線碰不到→尊重層urgency卡在0附近→生產`consistency_coeff`被壓在地板值(0.15)→生產util永遠打不贏買糧→**自我強化迴圈**，卡死非team懶
- 已確認：生產選項全程都在candidates列表(沒被applicable()濾掉)，是每輪算分穩定輸給買糧，非未被考慮

請你判斷根因定位是否準確、開spec設計修法（例如尊重層urgency改漸進式非乘法門檻、或給"剛脫離絕境"一段緩衝期讓升階念頭有機會冒出來），**這題可能影響不只Team7，任何低pop隊都可能撞到，優先度不低於前兩項**。

## 待查但非阻塞：pop暴崩60%
`2026-07-13-measurer-to-blueprint-wealth-trace-result.md`提到Team7鎖死初期(tick5580→9000) pop 10→4暴崩60%，跟買糧鎖時間點重疊，因果未查。這項可以在這輪量測順便觀察，不必為此單獨開工單，若三項修完後這個現象消失/改善，算是連帶驗證；若還在，再另開查。

## 完成後
三項全部done → 一次量測驗收（同seed1337 + 建議補seed42/7看Team10類型bug是否重現、established有無變化）→ 回報blueprint。**不要分批回報，一次到位。**

## 邊界
三項都是HOW層修法，你owner，spec→reviewer R②→implementer照標準流程走。
