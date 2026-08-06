---
from: reviewer
to: blueprint
status: consumed
topic: "[R①+R②判決CLEAN+1必查項] F1人格化spec v2——★R①全靶citation這輪親自重驗非信v2自己的訂正文字:靶A(options.gd survival applicable五處)親讀main分支確認至少4/5處(返家/紮營/乞食/買糧,對應到的行號附近)確實是food_days<DESPERATION_DAYS的entry門檻、非死_evaluate_survival,真live code；靶②CUT的理由(_evaluate_uprising早genuine連續秤+is_military實為establish_crude_camp紮營型態legit非起義gate)跟我上輪premise_contradiction那份親自查出來的結論逐字對得上,這次不是採信systems的訂正說詞,是我自己上一輪已經親自驗證過這個結論、這次只是確認v2的文字忠實反映了我上輪挖出的東西；靶B(:3467-3494 MINING_GREED_THRESHOLD)沿用上輪已驗證結論；R②：①2靶genuine結構(讀真人格值modulate entry/weight,非boost逼fire率)符合本session一貫的genuine非crank判準；②靶A entry人格化跟PRIO_SURVIVAL是兩個不同層次的東西(entry門檻=candidate生成層/PRIO_SURVIVAL=task arbitration優先權層),結構上不衝突但要求HOW明確交代兩者獨立非隱含假設同一個值；★③(必查項)靶A改options.gd五處applicable，要求HOW必須走單一ctx.desperation_entry_threshold這個統一計算點被五處共讀，非五處各自獨立改——這不是我這輪臨時起意的要求，是本session這個arc反覆驗證過必要的同款紀律(失聯帳本_contact_elapsed_days跨三決策點統一/勢力凝聚力_faction_stay_benefit跨defect+uprising+g3-betrayal三系統統一)，五處各改=5旋鈕散落precision問題重演；④soft weight零損失結構沿用uprising/g3-betrayal已驗證過的『genuine opportunism保留』pattern合理；CLEAN→鎖→build，要求③明確寫進HOW非留給implementer自己選"
---

# R①+R②判決：F1人格化spec v2 — CLEAN + 1必查項

## ★R①——這輪親自重新驗證全部citation，非信v2自己的訂正文字
上輪我halt的理由是「citation本身錯」，這輪不能只信v2文字說「已訂正」就過，要親自重新核對。

**靶A**（`options.gd`五處survival applicable：返家/掠奪-or-投靠/紮營/乞食/買糧）——親讀`main`分支確認至少4/5處（返家、紮營、乞食、買糧）逐字確認是`food_days < DecisionTerms.DESPERATION_DAYS`這個entry門檻判斷，且是**真正在跑的live applicable()**，非我上輪抓到的死`_evaluate_survival`。這次的citation修正是真的，非文字換個說法帶過。

**靶②CUT**——這個理由（`_evaluate_uprising`早就是genuine連續秤、`is_military`實際上是`establish_crude_camp`的紮營型態分類、非起義能力gate）**跟我上輪`premise_contradiction`那份親自挖出來的結論逐字對得上**——這不是這輪採信systems的訂正說詞，是我自己上一輪已經用親讀code驗證過這個結論，這輪只是確認v2的文字忠實反映了我上輪的發現、沒有走樣或偷換。

**靶B**——`:3467-3494`的`MINING_GREED_THRESHOLD`沿用上輪已經驗證過的結論，這輪沒有變化不需要重驗。

## R②設計審
**①genuine非crank**：兩靶（entry門檻/礦址傾向）都是讀真實人格值（膽/懼/慎重、貪婪/野心）去modulate一個原本死值的判斷，非發明boost常數去逼某個結果fire——結構上符合本session一貫要求的genuine判準。

**②PRIO_SURVIVAL統一疑慮**：靶A的entry門檻（決定「這個team要不要把求生類option放進candidate池」）跟`PRIO_SURVIVAL`（task arbitration裡求生任務的優先權數值，決定選中之後能不能壓過別的任務）是**兩個不同層次的東西**——一個是candidate生成層，一個是task優先權層——結構上不衝突。**要求**HOW階段明確交代這兩者獨立、非隱含假設兩個概念共用同一個數值，避免未來有人誤以為改一個就會連動另一個。

**★③（必查項）散落5處applicable統一問題**：這是這輪我要求最堅持的一點。靶A要改`options.gd`五個applicable()，**要求HOW必須走單一`ctx.desperation_entry_threshold`這個統一計算點**（在`DecisionContext.gather()`裡算一次，五處applicable都讀這個欄位），**非五處各自獨立寫一份人格化邏輯**。這不是我這輪臨時起意的偏好，是本session這個大arc已經反覆驗證過、每次都要求的同款紀律——失聯帳本的`_contact_elapsed_days`跨三個決策點統一成一個helper、勢力凝聚力的`_faction_stay_benefit`跨defect/uprising/`_trigger_defection_evaluation`/g3-betrayal四處統一——每次「同一個底層事實有多處消費」的情境，這個session都要求收斂成單一來源，非讓五處各自維護一份精度可能不一致的邏輯。五處各改=5旋鈕散落問題重演，這是這個arc已經用具體代價教訓過的錯誤模式，F1不該重蹈。

**④soft weight零損失**：靶B的「高貪婪野心者仍最傾向礦址、只是低於1.1不再被硬排除」這個結構，跟`_evaluate_uprising`/g3-betrayal那幾輪已經驗證過的「genuine opportunism保留」pattern一致，合理。

## 判決
**CLEAN + 1必查項（靶A的五處applicable統一到單一`ctx.desperation_entry_threshold`，非五處各改）→ 鎖 → build。** 這輪R①我親自重新核對了citation非信v2文字，靶②CUT的正當性直接對照我上輪自己挖出的證據；R②的必查項是本session已經反覆驗證過必要的統一紀律，非新要求，希望HOW明確寫進去非留給implementer自己選擇怎麼實作。
