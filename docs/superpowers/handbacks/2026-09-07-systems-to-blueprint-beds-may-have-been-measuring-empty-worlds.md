---
from: systems
to: blueprint
status: consumed
slice: ★★★要你裁範圍：【設過 population 的床，一直在跑 pop=0 的世界】—— 過去的量測可能有一批無效
topic: ★★★implementer 揭 + 我驗並外擴:`team_data.gd` 有【五個】計算屬性的 setter 是 `set(_value): pass`(靜默吞寫),而直寫處裸掃 scripts/ 合計 107(population 96／wounded 8／anon_tiers 1／anon_combat_skill 2);★後果:床裡寫 `team.population = 5` 【不會報錯,而 pop 就是 0】⇒ ★★凡是「設 pop 然後量 pop 相關行為」的床,量到的是【另一個世界】;★★★而我要你裁的是【範圍】:要不要回頭清查已交付的量測結論,以及清到多深——那不是 HOW,那是【要不要為此花一輪】;★而 HOW 那半我已裁(兩階段:先讓 setter 出聲並跑床量出【runtime 真的執行到幾處】,再移除 setter 讓賦值變 parse error),因為 107 是靜態數不是母體
---

# ★★★一、事實（★我自己驗過，不是轉述）
```
team_data.gd:57 population / :242 wounded / :260 anon_tiers / :269 anon_combat_skill / :277
   ⇒ 五個計算屬性的 setter 都是 `set(_value): pass`
   ⇒ ★getter 是導出值(population = leader + named_members + anon tiers),setter 靜默吞掉
直寫處(裸掃 scripts/,含 production):population 96 ／ wounded 8 ／ anon_tiers 1 ／ anon_combat_skill 2
```
★**後果**：**床裡寫 `team.population = 5` 不會報錯，而 `pop` 就是 0。**

# ★★二、而它為什麼會存在（★不是有人粗心）
```
:238 的既有註解寫明:「唯讀,舊寫入走 AnonTierSystem wound/heal/kill_wounded」
⇒ ★意圖是唯讀、而且合法路徑【有被寫下來】
⇒ ★★`set: pass` 的唯一用途是【讓舊的賦值站繼續編得過】= 遷移鷹架
⇒ ★★★而沒有人回來拆 —— 於是鷹架變成【永久的靜默失敗產生器】
```

# ★★★三、要你裁的：**範圍**
```
★問題:凡是「設 pop 然後量 pop 相關行為」的床,量到的是【另一個世界】
⇒ ★★過去已交付的量測結論裡,可能有一批建立在【pop=0 的世界】上
⇒ ★★★而【要不要回頭清查、清到多深】是【要不要為此花一輪】—— 那是你的格
```
## ★我可以提供的判準（★而我不自己啟動）
```
①★便宜的第一刀:等 implementer 做完 A 階段(setter 出聲 + 跑床)
   ⇒ ★★那會直接給出【哪些床真的踩到】的名單 —— 而不是靠翻舊 handback
②★★★而那份名單才是清查的母體 —— 現在的 107 是【靜態數】,不是【真的被跑到的數】
③若名單很短 ⇒ 逐床重跑即可;若很長 ⇒ 才需要你裁「哪些結論值得重驗」
```
★**而我建議先做 ① 再裁** —— ★★**因為現在裁,是在不知道母體大小的情況下裁。**

# ★四、而它順帶解釋了一類舊謎題
> ★**「床裡明明設了人口，行為卻沒發生」** ——
> ★★**那不是機制不 fire，是那個世界【真的沒有人】。**
