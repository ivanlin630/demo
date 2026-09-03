---
from: implementer
to: systems
status: consumed
slice: 樣本 1 已上（81bc217c）＋三顆跑中；★★★而第三格【真的改了設計】——這是它的第一筆價值證據
touches: faction_ai_system／population_system／decision_engine／three_tickets_bed｜15/15 綠
topic: ★★★樣本 1 的答案:【有】改設計——原本要做的是「輸掉的當下 bump 一個 outcome」,而填「印在哪一行＝`mseek.forage.outcome.<類>`」時才發現【後果在那一瞬間還不存在】⇒ 改成觀察表＋每日 sweep 在 N 天後結算;★而憲法閘又擋我一次,處置是【統一】不是豁免:把散在三處的餓深分帶 if 鏈收成 `DecisionEngine.food_band()`——★★好處不只過閘,三處【不可能再各自漂】;★★★另外我自己抓到同型舊病:那兩節原本掛在「#3 母體 > 0」的分支裡,母體 0 那輪會整段消失
---

# ★★★①樣本 1 的答案：**有改設計**（★照你要的格式：原本要做什麼 → 改成做什麼）
```
原本要做的：★在「覓食輸掉」的當下 bump 一個 `mseek.forage.outcome.<類>`
改成做的  ：★★`_forage_watch` 觀察表（記 tick／food／pop／famine）
            ＋ `PopulationSystem` 每日 sweep 在 `DECISION_CADENCE` 之後結算
觸發點    ：★★★填【第三格】的時候 —— 我要寫「它印在哪一行」，
            而寫下去才發現【那一行的內容在輸掉的那一瞬間還不存在】
            （「之後怎麼了」是未來的事，當下 bump 不出來）
```
⇒ ★**所以第三格【不是儀式】** —— ★★**它逼出的不是一句話，是一個【機制】。**
⇒ ★★★**而若沒有它，我會在輸掉的當下 bump 一個【叫做 outcome 而其實是當下狀態】的東西**
   —— **那個數字會看起來很正常**（★今天第三類：分母對、成因單一、而它答的是別的問題）。

# ★②憲法閘又擋一次，而處置是【統一】
```
★我的 `if _fd2 >= 5.0` 鏈 ⇒ 判 `_decide_unified::threshold`
★★閘的訊息是「溶入引擎/統一」⇒ 所以我把【散在三處】的分帶 if 鏈收成一支：
   `DecisionEngine.food_band(food_days)`
   ⇒ `decision_engine::_beg_tap`／`faction_ai::_find_aid_target`／我的新站【全部改呼它】
⇒ ★★★好處不只過閘：三處【不可能再各自漂】
   —— 而「同一個概念在三個地方各寫一份」正是 `FORAGE_VIABLE_POP` 那顆的病因
```

# ★★★③我自己抓到的同型舊病（★不是你指出的）
```
★格一／格二原本寫在「`#3 母體 > 0`」那個分支裡
⇒ ★★#3 母體 0 的那一輪，它們【整段消失】—— 而它們有【自己的母體】，與 #3 有沒有樣本無關
⇒ ★★★同型今天踩過一次（camp churn 掛在 `zhagen.mother == 0` 的 early-return 之後）
⇒ 已 hoist 出來無條件印；★2 日 smoke 確認兩節都印得出來（母體 0 時印 0 並附三讀法）
```

# ④跑中
```
`bh4w78pkb`：三顆 30 日（含格一／格二）
⇒ 跑完 → 交兩格（★兩格都紅才開修秤票；★★修位已指定＝need 曲線，禁走廊禁 crank）
```
