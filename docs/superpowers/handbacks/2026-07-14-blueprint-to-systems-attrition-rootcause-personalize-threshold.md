---
from: blueprint
to: systems
status: consumed
topic: [★attrition惡化根因+用戶裁定修向] Fix2漸進觸發照補(安全網)+Fix3不用3改5了事→安全門檻人格化(接領袖謹慎/野心);死常數人格化=照妖鏡同款病
---

# attrition 惡化根因已抓 + 用戶裁定修向

## 根因（讀死亡故事線抓到，非統計bisect）
求生層4-fix 驗收 attrition 惡化 1.9-3.7x（3seed一致，見`2026-07-14-measurer-to-blueprint-survival4fix-acceptance.md`）。讀 branch team7trace log 死亡故事線（Team14 seed1337）直接定位，**兇手＝Fix3為主 + Fix2補刀**：

- **Fix3（升階門檻）**：`need_hierarchy.gd` `ESTEEM_FOOD_REF_DAYS` 從 SATED(5) 降到 DESPERATION(3)（commit自承「偏離spec、TEST VALUE」）。食物剛脫離絕境線(≥3天)，esteem/升階 urgency 就衝高，引擎判「該去採購武器/生產」分數高過「買糧」。但3天緩衝太薄，正常消耗很快跌破，team 已卡在採購 task。
- **Fix2（crisis edge-trigger）補刀**：crisis 改邊緣觸發，只在「暴跌」當下 fire 一次。但**慢性漸進糧損不算暴跌**→不 latch、不提前重評→team 停在採購決策吃節流間隔一路到餓死。舊版 level-trigger 雖吵(93%重評)，但每 tick 重看食物＝誤打誤撞的安全網，被 de-patch 犧牲掉。
- Team14 故事：脫離絕境→切回買武器/囤礦→famine 7→14天連續餓死、期間無任何求生介入→滅團。Fix1/Fix4 此案例無直接參與。

## ★用戶裁定修向（拉高一層，非調常數了事）
用戶連續兩問把問題拉到根：①「調回5天一樣會5天後沒看庫存餓死」→ 治標不治本，**Fix2漸進觸發才是主藥（安全網）**。②「這一樣是常數問題，沒納入個性」→ **真根＝安全門檻是全域死常數，沒人格化**。

∴ 修向定調兩條：

### 1. Fix2 漸進觸發照補（安全網不能省，主藥）
crisis 判定納入「連續N天 food_days 下降」的漸進型觸發，非僅暴跌型。目的：不管 team 鬆懈去做什麼，糧食開始滑坡就一定被拉回確認/補糧。**不 revert 整個 edge-trigger 機制**，是補上漸進偵測這一塊。

### 2. Fix3 不用「3改5」了事 → 安全門檻人格化
`ESTEEM_FOOD_REF_DAYS`（及同類求生/升階門檻）**不該是全域常數**，改成 f(領袖人格)：
- 謹慎/膽小係數高 → 存久一點才敢鬆懈去發展（門檻高）
- 野心高/冒進 → 容忍薄庫存去搏發展（門檻低）
- 效果：Team14 餓死變成「因為領袖是好高騖遠的賭徒，剩3天就敢去買武器，賭輸餓死」＝角色缺陷致死，有故事性，非全體共用一個數字的系統性 bug。

這是**照妖鏡「死常數人格化」同款病**（memory `feedback-patch-gate-first` / 潰退門檻#1 已人格化過，此安全門檻是同型缺口沒治到）。診斷通則命中：死常數 pre-empt 人格＝變相補丁。

## 請做
1. 判斷根因定位是否準確（你可自查 code/diff 覆核 Fix2/Fix3 實際改動）。
2. 開 spec：Fix2 漸進觸發 + Fix3 門檻人格化（接領袖謹慎/野心 trait，具體 trait 欄位/映射公式你定，屬 HOW）。
3. spec → reviewer R②（這是 decision-core 結構改 + 人格化，建議過對抗閘）→ implementer。
4. 修完連同原4-fix一起重驗（同 seed1337+42+7，看 attrition 回落 + Team10 thrash 仍治好 + established 不退）。

## 邊界
人格化的「哪個 trait、映射曲線」是 HOW，你 owner 定。若你判斷牽動願景層（例如「求生該不該是可競爭的 util 選項，還是硬中斷」這個更根本問題——我跟用戶討論時浮出但未拍板），回報 blueprint 裁。本輪先照「Fix2漸進+Fix3人格化」推，那個更大問題留議。
