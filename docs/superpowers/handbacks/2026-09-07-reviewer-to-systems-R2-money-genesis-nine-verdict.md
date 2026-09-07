---
from: reviewer
to: systems
status: open
slice: money-genesis(⑨) merge-gate
topic: R②判決:issues(小)——①推導鏈讀code確認乾淨:total_pop讀state.teams真population、FOOD_PER_PERSON_PER_DAY/BASE_PRICE[food]/days_per_month全是既有量重用,唯一常數GENESIS_K=2.0是我上次已核可的複合校準常數,且護欄語句(重校k唯一合法理由=volume比對不符)真的逐字寫進code註解(game_setup.gd:98-102)不只留spec;②MG_HANDWRITTEN讀取點確認真在路徑上:money_genesis_bed.gd:49-58真的改寫state.teams[tid].resources[coin]縮放成7000,:63-66驗證也改讀縮放後的真實team.resources而非genesis探針tap,不是只改印出的數字;★額外抓到一個獨立發現(非你要求範圍但讀code時撞見):GENESIS_W_MERCHANT權重靠team.tags.has(TAG_MERCHANT)判斷,但arb_hit_confirm_bed.gd:42-43自己記錄「TAG_MERCHANT本世界全程0隊,真正驅動merchant判定的閘是ambition_archetype==ARCHETYPE_TRADE」——這是對其他(非peaceful_economy explicit-mode)世界講的,對本次量測用的peaceful_economy(explicit模式,team8 config裡tags真的含"商隊")沒有影響、量測結果有效;但若genesis之後套用到random-mode或warring世界,商隊權重會silently退化成跟其他隊一樣的OTHER權重,整個角色加權形同虛設,建議在§6④warring獨立pilot時一併驗證TAG_MERCHANT母體是否非0,不是本票必須現在修但要記下來別遺失
---

# 判決：`issues`（小），`premise_contradiction: false`

## ①推導鏈——讀 code 確認乾淨，沒有手抄物理

讀 `game_setup.gd:123-130`：
```gdscript
var total_pop: float = 0.0
for tid in state.teams: total_pop += float(state.teams[tid].population)
var monthly_food_value: float = total_pop * ResourceSystem.FOOD_PER_PERSON_PER_DAY * days_per_month * food_price
var total_coin: float = monthly_food_value * GENESIS_K
```
`total_pop` 是真的逐隊加總世界當下的 `population`（worldgen 產物，不是常數）；`FOOD_PER_PERSON_PER_DAY`／`BASE_PRICE["food"]`／`days_per_month`（`TICKS_PER_MONTH/TICKS_PER_DAY`）全部是**既有、全域已在用的量**，直接重用不是新填。唯一的常數是 `GENESIS_K=2.0`——這是我上一輪已經核可過的複合校準常數（k 同時吸收「幾個月週轉」與「交易佔消費比例」兩件事），而且我當時要求的護欄**真的逐字寫進了 code 註解**（`game_setup.gd:98-102`：「重新校 k 的理由是封閉的：只能是 volume 比對本身沒對上，不得用下游感覺倒推」）——不是只留在 spec 裡讓人看不到。這條鏈沒有第二個手抄的地方。

## ②`MG_HANDWRITTEN` 讀取點——確認真在決策路徑上，不是只改印出的數字

讀 `money_genesis_bed.gd:49-58`：
```gdscript
if OS.has_environment("MG_HANDWRITTEN") and OS.get_environment("MG_HANDWRITTEN") == "1":
    ...
    var scale: float = HANDWRITTEN_TOTAL / cur
    for _tid2 in state.teams:
        var t2: TeamData = state.teams[_tid2]
        t2.resources["coin"] = float(t2.resources.get("coin", 0)) * scale
```
這**真的改寫了每一隊的 `resources["coin"]`**，不是只改一個要印出來的數字。再讀 `:63-66`：驗收①的「實發」在鑑別力模式下**改讀縮放後的真實 `team.resources`**（`given += float(state.teams[_tid3].resources.get("coin", 0))`），不是繼續讀 genesis 那個探針 tap——這正是「兩個獨立證據」該有的樣子：不是同一份資料換個名字印兩次。今早那次「全庫零 code 讀它」的病，這次真的被治好了。

## ★附帶一個發現（不在你要求的範圍內，讀 code 時順手撞見）

`_apply_money_genesis` 的角色加權（`game_setup.gd:144-145`）靠 `t.tags.has(TeamData.TAG_MERCHANT)` 判斷「這是不是商隊」。但 `arb_hit_confirm_bed.gd:42-43` 自己記錄著：**「TAG_MERCHANT 本世界全程 0 隊……真正驅動 `_merchant_trade_target` 的閘是 `ambition_archetype==ARCHETYPE_TRADE`（`faction_ai_system.gd:2045`），非 `TAG_MERCHANT`」**。

我核對過：這次量測用的 `peaceful_economy.json` 是 **explicit 模式**，team8 的 config 裡 `"tags": ["商隊"]` 是**手寫進去的**，讀 `_build_explicit_team`（`game_setup.gd:739`：`state.set_team_tags(team, t_cfg.get("tags", []).duplicate(), ...)`）確認這個 tag 會原封不動載進 `team.tags`，發生在 `_apply_money_genesis` 之前——**所以這次的量測結果不受影響，商隊權重確實對 team8 生效了**。

**但這揭露了一個範圍外的潛在洞**：`arb_hit_confirm_bed.gd` 那句話講的是「本世界」（隨機生成模式的世界，不是 explicit 模式），意思是**隨機生成的隊伍從來不會被貼上 `TAG_MERCHANT`**——如果 `_apply_money_genesis` 之後被套用到 random-mode 世界或 warring 世界，商隊權重（`GENESIS_W_MERCHANT=2.0`）會**靜默退化成跟其他隊一樣的 `GENESIS_W_OTHER=1.0`**，整個「角色加權」形同虛設，沒有任何錯誤訊息會告訴你這件事——因為 `t.tags.has(TAG_MERCHANT)` 就是單純查不到，程式碼不會抱怨。

這**不影響本次 CLEAN 判決**（測的是 peaceful_economy，沒事），但**這正好落在 spec §6④已經標記的「warring 的初始批要各自跑 pilot（母體不同）」那格裡**——建議 warring 的獨立 pilot 順便量一下「這個世界的 `TAG_MERCHANT` 母體是不是非 0」，不是的話就是這個發現命中了，要嘛在權重判斷加一條 `or team.ambition_archetype == AmbitionLadder.ARCHETYPE_TRADE`（跟 `_merchant_trade_target` 用同一個真正的閘），要嘛明確記錄「random-mode 世界的商隊權重目前不生效」當已知限制，別讓它無聲無息地過去。

## ⇒ 結論
①②都通過，前提沒有問題。附帶發現不擋這次 merge，但請併入 §6④ warring pilot 的檢查清單，避免下次重新發現一次。

**premise_contradiction: false；CLEAN，可 merge。**
