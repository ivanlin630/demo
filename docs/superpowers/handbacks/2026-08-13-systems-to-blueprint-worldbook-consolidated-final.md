---
from: systems
to: blueprint
status: consumed
topic: "[③ audit culmination:世界帳本 consolidated(measurer 五封+systems perf 獨立坐實)=資不抵債根 CONFIRMED、最深根『幾乎無人定居生產』、per-segment genuine-vs-bug 數據坐實禁預設守住·★核心根 CONFIRM:①糧帳生死線 food -75.6% vs pop -1.8%=世界糧崩遠快於死亡=吃老本無盈餘引擎(blueprint 假說最直接證據)②力平衡棘輪 spawn99:merge4≈25:1 單向原子化 CONFIRM·★★最深根=production funnel 四段一根『幾乎無人定居生產』(最乾淨最優先):①佔據率前22天0 resident、月底僅8.6%(9/105)幾乎全員流浪(比60%假說更極端);紮營 candidate 在(camp.tile_found=1132)但 argmax 一次沒選(camp.fire=0、非無地 no_unowned_tile=0)=紮營 util 輸(camp_drive 死常數嫌疑 memory);settle-at-existing convert_to_resident=0 死路;那9 resident 走第三路(疑佔村 combat-adjacent)未 tap②★生產 fire 率 resident_producing_n 恆0(0/9)=即使變 resident 也一天沒 TASK_PRODUCE=最尖銳 bug candidate(變 resident 卻不生產、facility-gate[生產需 manufacturing facility、produce.appl_kill_nofacility A2 主病]or task-assignment gap 待一輪 code-read/measure 定)③④盈餘/流通=生產沒發生的下游必然(sell_no_surplus=768 最大宗村無盈餘可賣+buy_no_stock=353 訪客想買市場空=雙印證)·★零戰死 CONFIRM 三事:①watchdog=0(encounter_active 整月 false=encounter 只 ambush/player 觸發、headless-no-player 結構恆 false=watchdog 徹底排除、我+你先前都誤疑)②攻擊 fire 0(faction_attack_stake=0 全月=faction 從未下攻擊 directive=directive-wiring 更上游根)③掠奪 fire 206 但 9.2% reach combat 判定(執行斷點同 JOIN funnel 型態)、19 次判定 100% extort 屈服零死=genuine(raid=勒索非屠殺);conq.combat_entered=22 另一路(feud?)未查·★prey 瓶頸=reachability 83% unreachable(PathSystem.estimate_catch_up)非 belief-gap(0.0002%)=genuine 世界物理稀疏/移動慢、★別 over-unify 成 migrant belief 根(measurer 明確:瓶頸類型≠migrant、這輪數據支持分開看=呼應我 over-unify 教訓)·★systems perf 獨立坐實:dieoff 1月窗 GODOT_TIMEOUT=600 也 kill(>10min 跑不完)+measurer 也撞執行天花板『規模降到1月窗』=perf genuinely 差 corroborated(per-team-cost)、但 phase 分解 wrapper-kill 丟失待專 perf arc·★★∴生存經濟基座 arc 兩層 plug(你帶用戶):layer1 residency 化(紮營 util 輸[camp_drive]+settle 死路→流浪團進不了 resident)、layer2 production-fire(resident 也不生產=最尖銳、facility-gate/task-assignment 待定)·★1mo-新測 vs 2mo-沿用分清(時鐘比③/JOIN travel=沿用、餘 1mo 新)·★訂單 churn 答不了(需綁 order_id tap、待判)·★禁預設守住全程(genuine:raid 勒索/prey 稀疏/糧崩無盈餘=結構非機械榨乾;bug candidate:resident-不生產最可疑)·序:你 consolidate 帶用戶=生存經濟基座 arc(定居生產鏈=修法核心、先於故事 arc);vitals→invariant HOW 待你 spec+用戶核·地基 KEEP·specimen 在 QA behavior-causal 稽核鎖"
---

# ③ audit culmination：世界帳本 consolidated（資不抵債 CONFIRMED）

measurer 五封 + systems perf 獨立坐實。核心根 CONFIRMED、最深根「**幾乎無人定居生產**」。per-segment genuine-vs-bug 數據坐實、禁預設守住全程。

## ★核心根 CONFIRM
- **①糧帳生死線**：food **-75.6%** vs pop **-1.8%** = 世界糧崩遠快於死亡 = **吃老本、無盈餘引擎**（blueprint 假說最直接證據）。
- **②力平衡棘輪**：spawn 99 : merge 4 ≈ **25:1** 單向原子化 CONFIRM。

## ★★最深根 = production funnel 四段一根「幾乎無人定居生產」（最乾淨最優先）
- **①佔據率**：前 22 天 **0 resident**、月底僅 **8.6%（9/105）**=幾乎全員流浪（比 60% 假說更極端）。
  - 紮營 candidate 在（`camp.tile_found=1132`）但 argmax **一次沒選**（`camp.fire=0`、**非無地** no_unowned_tile=0）= **紮營 util 輸**（camp_drive 死常數嫌疑）。
  - settle-at-existing `convert_to_resident=0` = 死路。
  - 那 9 resident 走**第三路**（疑佔村 combat-adjacent）未 tap。
- **②★生產 fire 率**：`resident_producing_n` 恆 **0（0/9）**= 即使變 resident 也**一天沒 TASK_PRODUCE**=**最尖銳 bug candidate**（變 resident 卻不生產、facility-gate[生產需 manufacturing facility、`produce.appl_kill_nofacility` A2 主病] or task-assignment gap 待一輪 code-read/measure 定）。
- **③④盈餘/流通**：生產沒發生的下游必然（`sell_no_surplus=768` 最大宗村無盈餘可賣 + `buy_no_stock=353` 訪客想買市場空=雙印證）。

## ★零戰死 CONFIRM 三事
1. **watchdog=0**（`encounter_active` 整月 false=encounter 只 ambush/player 觸發、headless-no-player 結構恆 false=**watchdog 徹底排除**、我+你先前都誤疑）。
2. **攻擊 fire 0**（`faction_attack_stake=0` 全月=faction 從未下攻擊 directive=**directive-wiring 更上游根**）。
3. **掠奪 fire 206 但 9.2% reach combat 判定**（執行斷點同 JOIN funnel 型態）、19 次判定 **100% extort 屈服零死=genuine（raid=勒索非屠殺）**。conq.combat_entered=22 另一路（feud?）未查。

## ★prey 瓶頸 = reachability（非 belief、別 over-unify）
`prey.unreachable=83.3%`（PathSystem.estimate_catch_up）非 belief-gap（0.0002%）= **genuine 世界物理稀疏/移動慢**。★measurer 明確：瓶頸類型 ≠ migrant belief 根、這輪數據**支持分開看**（呼應我 over-unify 教訓、別合併）。

## ★systems perf 獨立坐實
dieoff 1 月窗 GODOT_TIMEOUT=600 也被 kill（>10min 跑不完）+ measurer 也撞執行天花板「規模降到 1 月窗」= **perf genuinely 差 corroborated**（per-team-cost）。phase 分解 wrapper-kill 丟失、待專 perf arc。

## ★★∴ 生存經濟基座 arc 兩層 plug（你帶用戶）
- **layer1 residency 化**：紮營 util 輸（camp_drive）+ settle 死路 → 流浪團進不了 resident。
- **layer2 production-fire**：resident 也不生產（最尖銳、facility-gate/task-assignment 待定）。

## ★誠實 caveat（禁預設守住）
- **genuine**：raid 勒索 / prey 稀疏 / 糧崩無盈餘=結構非機械榨乾（用戶規矩 [[feedback_resource_depletion_genuine_vs_blind]] 分野守住）。
- **bug candidate**：resident-不生產最可疑（layer2）。
- **1mo-新測 vs 2mo-沿用分清**（時鐘比③/JOIN travel=沿用、餘 1mo 新）。
- **訂單 churn 答不了**（需綁 order_id tap、待判值不值）。

序：你 consolidate 帶用戶 = **生存經濟基座 arc（定居生產鏈=修法核心、先於故事 arc）**；vitals→invariant HOW 待你 spec+用戶核。specimen 在 QA behavior-causal 稽核鎖。地基 KEEP。
