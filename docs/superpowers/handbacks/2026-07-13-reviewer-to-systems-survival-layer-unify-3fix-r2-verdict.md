---
from: reviewer
to: systems
status: consumed
topic: "[R②判決] 求生層統一3-fix：issues——Fix1 子隊(subteam)求生路徑缺口需 spec 階段解，非 implementer 驗"
---

# R② 判決：issues（非 CLEAN）

verdict: issues
premise_contradiction: false（三根本身皆坐實，未被 code 打臉；但 Fix1 設計覆蓋面有缺口）

## 核心發現：Fix1 退役 override 對「子隊」(subteam) 是硬斷崖，非「famine grace 退化」

spec §Fix1-2.2 把子隊風險框成「礦村 famine grace 退役安全性未定」，**範圍框小了**。實查：

1. `faction_ai_system.gd:1658-1660`（`_evaluate_subteam`）：子隊只在 `current_task == TASK_IDLE` 才呼 `_decide_subteam`（引擎路徑）。`TASK_BUILD`(:1625-1626)、`TASK_CONSTRUCT/UPGRADE/EXPAND`(:1629-1637) 全部**提前 return，不進引擎**。
2. `faction_ai_system.gd:3046-3047`：spec 要求把 `uses_unified(team): return` 擴及**所有**非-unified 隊——包含子隊。子隊多半不掛 MERCHANT/PRODUCE tag（uses_unified 判 tag 非隊型），會被此 gate 一併擋掉。
3. 兩者疊加：**在途建造子隊（TASK_BUILD/CONSTRUCT/UPGRADE/EXPAND）retire 後拿不到任何求生評估**——不只是 spec 講的「礦山 famine grace 沒了」，是 `:3048-3098` 整段（含 :3095 一般餓死觸發 `_trigger_survival`）連著 `:3046` gate 一起被跳過。**非礦山的一般建造子隊現在會餓死觸發（:3061 只豁免礦山，但 :3095 一般觸發對所有非-unified 隊都跑）；spec 版本連這條也没了。**
4. 結論：這不是「grace 退化風險」，是**建造中子隊求生反應從「有（含一般觸發+礦山額外豁免）」變「無」**——比 spec 自己列的風險更大。

## 對 systems 5 個 refute 點的回應

1. **非-unified 隊是否有路徑不常跑 _evaluate_solo** → **部分屬實但範圍不同**：faction 成員（leader/member）不呼 `_evaluate_solo`，但呼 `_decide_unified`（`:1387`/`:1409/1412`，**不受 uses_unified tag 閘**，見 `:1405` comment「不動全域 uses_unified→成員仍走引擎」）→ 這條路徑安全，rank_scored 求生 option 仍在。**真缺口在子隊**（見上），非 faction 成員。
2. **Fix1 依賴 Fix2 單點風險** → crisis_latched 邊界抖動風險**低**：`_decision_crisis`（:1766-1772）判準是 `food_flow_avg`（EMA，`resource_system.gd:208 alpha` 平滑）+ `rung_pop_last` 驟降比——EMA 不會 tick-to-tick 抖動，edge-trigger 卡死/狂 fire 機率低。此點不擋。
3. **Fix3 esteem 漸進復餓風險** → spec 已列驗收法③守，桿 A 數字待量測校，設計方向合理，非 spec 階段能定死，非阻塞項。
4. **礦村 famine grace 退役安全性 premise gap** → **同意，且範圍比 spec 框的更大（見上）。必須 spec 階段解，不能丟 implementer「驗完再說」**——這是 decision-core 結構改，子隊完全無求生路徑是可預期的 regression（餓死 zombie 子隊），非邊緣案例才會踩到的機率風險。
5. **三項是否該綁一份** → 同意 systems 論證（同源咬合），維持一份，但 dispatch 前先補子隊缺口。

## 要求（CLEAN 前必解，任一）

- **A（建議）**：`:3046` gate 擴及非-unified 時，**排除子隊**（`parent_team_id != -1`）——子隊求生仍走現有 `_evaluate_survival` legacy body（含一般觸發+礦山豁免），只退役「非子隊、非-unified」的 override。理由：子隊本就無 `_decide_subteam` 之外的引擎路徑（IDLE-only），不像獨立隊/faction 成員有 `_evaluate_solo`/`_decide_unified` 兜底。
- **B（替代）**：`_evaluate_subteam` 對 `TASK_BUILD/CONSTRUCT/UPGRADE/EXPAND` 分支加求生檢查（複製 :3065-3098 邏輯或呼共用函式），確保子隊 override 退役後仍有等價反應。

A 較省（子隊本就特例多，維持現狀反而降 blast radius；跟 systems「同源咬合」論證不衝突——子隊求生本來就走不同路徑，非同一條「求生→esteem」路，可切開不影響 Fix2/Fix3）。

## 回報
- 選 A 或 B（或第三案）補 spec → 改完再 to:reviewer 一次（輕量複審即可，非重跑全流程）。
- 其餘（Fix2 edge-trigger、Fix3 esteem 漸進、三項綁一份）**CLEAN**，不需再審。

（寄件永遠 open，你讀後改 consumed。）
