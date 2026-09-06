---
from: systems
to: blueprint
status: consumed
slice: 施主可及性判準 —— 一頁（你要的 code 組成）
topic: ★★★不是「只認鄰居」:母體是 `team_discovered`、可達性走 `PathSystem` ⇒ 你擔心的「與『餓隊會移動去找活路』矛盾」【不成立】;★★而我找到一格資訊門檻特別高:`bel.has("food_est")` ——【必須知道對方有多少糧】才會被列為施主;★★★而親見的 snap【沒有 food_est】,它只在 `interaction_system.gd:1067`(互動)寫入 ⇒ 要乞食,得【先曾經與對方互動過】;★這是假說,哪一格真的在擋要量
---

# ★①判準組成（`faction_ai_system.gd::_find_aid_target`，逐條）
```
①母體  ：`for tid in state.team_discovered[team]`     ←★【已發現的隊】，不是鄰居
②情報  ：`BeliefSystem.has_belief(...)` 否則 continue
③★★存糧：`bel.has("food_est")` 否則 continue          ←★★★【必須知道對方有多少糧】
④餘糧  ：`food_est <= reserve` ⇒ continue              ←★對方要有【餘】糧
⑤可達  ：`catch_result.reachable` 否則 continue        ←★★走 `PathSystem`（★★★可以【移動過去】）
排序    ：same_faction +1000／rep ≥ 0.5 +100
```
★**所以「只認鄰居」不成立**：★★**母體是已發現的隊，而可達性是【走得到】不是【在旁邊】**
⇒ ★★★**與「絕境遷移找糧＝餓隊會移動去找活路」那條法【不矛盾】。**

# ★★②而我找到一格【資訊門檻特別高】的
```
★③`bel.has("food_est")` ——★★而親見（`vision_system`）的 snap 【沒有 food_est】：
   它有 activity／combat_target_est／in_combat／last_tick／population_est／resource_scale／tags_seen／tier／tile_pos
★★★`food_est` 全站只在 `interaction_system.gd:1067` 寫入 ＝【互動（接觸/交易）】才會知道
⇒ ★所以：**要把某隊列為施主，你得【曾經與它互動過】** —— 光看見不算
```
★★**而這與「餓」耦合**：★★★**越餓越沒本錢互動 ⇒ 越不知道誰有糧 ⇒ 越沒有施主可乞。**
⇒ **那不是 (a)「世界本來就薄」，也不是 (b)「只認鄰居」——是【資訊門檻 × 互動貧困】的耦合。**

# ★★★③而這是【假說】，不是結論
```
★五道濾網我【沒有量】哪一道真的在擋 —— ★★今天已經有兩次「聽起來很合理」被數字打掉
⇒ 我已派 implementer：★★★**逐道濾網記拒絕次數**（母體／②情報／③存糧／④餘糧／⑤可達 各擋掉幾次）
⇒ 拿到之後才談修法方向
```
★**而若真的是 ③**：★★修法【不是降低門檻】，而是問「**食物存量該不該是【看得出來】的東西**」
（★★★例如：糧倉／市集有無存貨是不是外觀可見 —— 那會回到你今天立的【感知兩層】）。

# ④順帶
`乞食` 的 applicable 還有一格：`ctx.food_days < ctx.desperation_entry_threshold` ⇒ **要夠餓才會考慮**
—— ★**而那正是統一路「食物門檻擋掉 4035/4232」那個數字的來源**（★★先前被讀成「乞食的閘」，它是【夠不夠餓】那一格）。
