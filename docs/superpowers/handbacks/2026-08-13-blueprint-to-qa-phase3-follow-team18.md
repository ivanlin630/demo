---
from: blueprint
to: qa
status: open
topic: "[用戶要跟一個指標團看到底在幹嘛=單團逐tick play-by-play·★數據=同specimen檔docs/measurements/2026-08-12-phase3-story-audit-seed1337-2mo.specimen.jsonl(逐tick trace、4174筆、8指標團strided 0/6/12/18/24/30/36/42)·★欄位mojibake但positional:key[0]=team_id key[1]=tick key[2]=決策{result/target/task/winner_opt} key[3]=想{beliefs/candidates[{opt,util,nd}]/intent/threat{threat_id,threat_pos,threat_react}} key[4]=狀態{coin/effective_food/consume_per_day/food_private/food_granary/faction_id/at_market/active_buy_food_qty/leader_traits}·★首選team18(1183筆最豐、food 250→0完整餓死死亡弧、intent致富trade/日常、task見建設/巡邏/外交/談判/移動/歸巢/採集)=跟它逐tick講完整故事『到底在幹嘛』:每段時間選什麼task(winner_opt)+為何選(candidates util排序)+food怎麼一路掉到0+沿途有無遇敵(threat_id!=-1?)有無開打有無戰鬥task+餓死前最後在做什麼·★次選team6(595筆、f1→-1=faction蒸發defect、food 250→34存活)對照:它做對了什麼/defect那tick前後在幹嘛(呼應你昨天T6 food0.7回彈distress-defect發現)·★核心問題回答用戶:①這團整天在幹嘛(task時間分配)②有征服/防守意圖時遇到敵人會怎樣、為何從不轉戰鬥(threat欄位有無敵?candidates有無攻擊option?)③為何餓死(買糧有沒有fire?at_market?買不到還是不買?consume vs food收支)·★這直接餵零戰死+饑荒兩診斷=個體視角佐證·對抗禁預設·output=team18完整逐tick敘事(關鍵tick節點)+team6對照+三問答案→回我帶用戶·地基KEEP"
---

# 跟指標團 team 18 逐 tick 看「到底在幹嘛」（用戶點名）

用戶要 QA **跟一個指標團、逐 tick 看它到底在幹嘛**。

## 數據（你留 main dir 直讀）
`docs/measurements/2026-08-12-phase3-story-audit-seed1337-2mo.specimen.jsonl`（逐 tick trace、4174 筆、8 指標團 strided 0/6/12/18/24/30/36/42）。
★欄位 mojibake、按 **positional** 讀：
- key[0]=`team_id` key[1]=`tick`
- key[2]=決策 `{result, target, task, winner_opt}`
- key[3]=想 `{beliefs, candidates:[{opt,util,nd}], intent, threat:{threat_id,threat_pos,threat_react}}`
- key[4]=狀態 `{coin, effective_food, consume_per_day, food_private, food_granary, faction_id, at_market, active_buy_food_qty, leader_traits}`

## ★首選 team 18（1183 筆最豐、food 250→0 完整餓死弧）
逐 tick 講完整故事「到底在幹嘛」：
- 每段時間選什麼 task（`winner_opt`）+ 為何選（`candidates` util 排序）
- food 怎麼一路掉到 0（收支：`consume_per_day` vs 進帳）
- 沿途**有無遇敵**（`threat_id != -1`?）、有無開打、candidates 有無攻擊/戰鬥 option
- 餓死前最後在做什麼

## 次選 team 6（595 筆、f1→-1 faction 蒸發 defect、food 250→34 存活）對照
它做對了什麼 / defect 那 tick 前後在幹嘛（呼應你 T6 food 0.7 回彈 distress-defect 發現）。

## ★核心三問（回答用戶）
1. 這團**整天在幹嘛**（task 時間分配）?
2. 有征服/防守意圖時、遇到敵人會怎樣、**為何從不轉戰鬥**（threat 欄位有無敵?candidates 有無攻擊 option?）?
3. **為何餓死**（買糧有沒有 fire?at_market?買不到還是不買?consume vs food 收支）?

→ 直接餵零戰死 + 饑荒兩診斷（個體視角佐證）。對抗禁預設。
output = team18 完整逐 tick 敘事（關鍵 tick 節點）+ team6 對照 + 三問答案 → 回我帶用戶。地基 KEEP。
