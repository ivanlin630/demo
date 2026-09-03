---
status: R² issues 已吸收（2026-09-03）
owner: systems
slice: commitment-outlives-applicability
what: ★承諾比 applicable 活得久 —— committed 的 option 當下已不 applicable，而承諾還掛著
premise: ★量到的（yes=10／no=0，三 seed，決定性：與上一批逐數相同）
---

# ★①病（★量到的，不是推的）
```
那些「已承諾卻不在 ranked 候選集」的隊 ⇒ ★當下【全部都已經有自己的營地】：yes=10、★★no=0
   1337 紮營1／42 紮營4＋覓食1／7 紮營3＋覓食1
⇒ ★★★而【覓食也有 2 筆】⇒ 這不是紮營專屬，是【承諾比 applicable 活得久】的一般形狀
```
★**成因鏈**：半B 讓「有家的隊」紮營不再 applicable ⇒ **而舊的承諾沒有人去解** ⇒ 它就成了新的 `not_in_ranked`。

# ★★②修法（★通用，不綁在任何一個 option 上）
```
committed 的 option 若【當下不 applicable】⇒ 走【既有】出口 `survival_committed_option = ""`
   （`faction_ai_system.gd:6165／6170` 同款）＋ `Probe.bump("survival.release_not_applicable")`
★禁：新增死旗；★★禁：為紮營寫一支專用解承諾（★★★那會讓覓食那 2 筆繼續掛著）
```

# ★★★③而我在寫這份 spec 時撞到一個【我自己造的】風險（★R² 重點打這裡）
```
★我剛做完的 own-camp 那一刀，靠的正是【紮根在【走路途中】保持 applicable】——
   人不在營地時 applicable 成立（因為 own_camp_pos != (-1,-1)），走到了才 fire
⇒ ★★所以「不 applicable 就立刻解承諾」這條規則，★★★若某個 option 是【到了目的地才 applicable】，
   它會在半路被解掉 —— **那會打斷 means-end，而那正是我今天才修好的東西**
⇒ **必須先查清楚：有沒有 option 的 applicable 是【抵達後才成立】的。**
   ★我沒有查（negative assertion 不猜）—— **這一格交 R² 用 file:line 回答。**
```

# ④次要風險（一併交 R²）
```
①★抖動：applicable 若會來回翻（例：覓食隨資源可見性閃動）⇒ 立刻解可能造成承諾抖動
   ⇒ ★★而我【傾向不加遲滯】：既有 stall 機制已經處理慢的那一端，多一個窗＝多一個要調的常數
②★★兩個解承諾的擁有者：本刀與 `_detect_survival_stall` 都會清同一個欄位
   ⇒ ★★★要確認【誰先誰後不影響結果】，或明訂一個擁有者
```

# ⑤驗收（★判讀表寫在數字之前）
```
①那 10 筆 ⇒ 【0】（同床同 seed 同天數）；★母體與命中同印
②★`not_in_ranked` 應同步下降 —— ★★若沒降，先查【解承諾有沒有 fire】（Probe 桶），不要先怪別的
③★★★陽性對照：把該解承諾停掉 ⇒ 那 10 筆必須回來
④行為改變 ⇒ `fp` 不比（★改用上面三條）
```


---

# ★★★⑥R² 吸收（reviewer 2026-09-03）

## ①我自撞的那個風險 —— **查掉了**
```
★reviewer 逐一核對 11 個 survival-set option ⇒ ★★沒有「抵達後才 applicable」的案例
   唯一有位置門檻的「駐守」（`has_own_outpost`）★沒有 travel leg，不會被打斷
   「紮營」的 reclaim 分支／「覓食」都是【每輪從當下位置重算】，且位置在抵達前不變
   ⇒ ★★★不是「remembered-target 一移動就失效」那個形狀
⇒ 本刀【不需要】豁免條款。★而這一格是我主動標出來的自撞風險，查完是空的 —— 那也是結果。
```

## ★★②③抖動與兩個擁有者 —— **我採【偵測器】而不是【常數】**
```
reviewer 指出：兩個擁有者的差別不是【誰先誰後】而是【side effect 不同】——
   `STALL_STALLED` 分支會設 cooldown，新規則若不設，可能與抖動耦合成真 thrashing
★而我【不加 cooldown】，理由：★★若 option 是真的不 applicable，擋它無害；
   ★★★而它【重新 applicable】時（例：營地衰敗 ⇒ 紮營又該可以了），cooldown 會擋掉一個【正確的】選擇
⇒ 我採兩件：
   ①★執行順序排在 `_detect_survival_stall` 之後（免同 tick 重複處理，零成本）
   ②★★加【偵測器】不加常數：`survival.release_recommit_same`
      ＝ 解承諾後 N tick 內【又承諾同一個 option】的次數
   ⇒ ★★★恆 0 ⇒ 那個病不存在，不必為它加常數；非 0 ⇒ 那時再談 cooldown，而且有數字
★通則：**不要為了一個【沒有量到的病】先加一個【要調的常數】—— 先加偵測器。**
```
