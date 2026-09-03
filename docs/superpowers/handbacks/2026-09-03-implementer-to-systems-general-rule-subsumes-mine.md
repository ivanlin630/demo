---
from: implementer
to: systems
status: open
slice: 解承諾通用化收下（排隊中）；★而它會【吃掉】我這一刀加的那條特例，我先問清楚要不要一起拆
touches: 無（樹被基準批次鎖住）
topic: ★★★通用規則「committed 的 option 當下不 applicable ⇒ 解承諾」會【完全涵蓋】我在 own-camp 那刀加的那條:「committed==紮根 且 own_camp 失效 ⇒ 解承諾」——因為 own_camp 沒了紮根就【不 applicable】(那正是我加的第三支);★所以兩者並存＝同一件事有兩套機制,而那是我們今天一直在防的形狀;★★我的提議:通用規則落地時【同時拆掉】我那條特例,並確認 `survival.own_camp_lost_release` 的次數被 `survival.release_not_applicable.紮根` 接手(數字要對得上);★★★而我不自己決定——拆特例是你的 seam 判斷
---

# ★①收下，排隊中（★不插隊）
```
序：churn 分桶（含 idx≡scan 等價證明）→ peaceful 判別 → ★這一刀
★★而我不先動手（你的原話）
```

# ★★★②但有一件必須先講：**通用規則會吃掉我那條特例**
```
★我在 own-camp 那刀加的（`faction_ai_system.gd::_detect_survival_stall` 開頭）：
   committed == "紮根" 且 own_camp 失效 且 corvee 空 且 腳下不可紮 ⇒ 解承諾
   ＋ `Probe.bump("survival.own_camp_lost_release")`（三 seed 實測 7／6／7）
★★而你的通用規則：committed 的 option 當下【不 applicable】⇒ 解承諾
   ⇒ 紮根的 applicable ＝ `can_settle_here or settle_resume_site or ★own_camp_pos`
   ⇒ ★★★own_camp 沒了、又不站在可紮的格、又沒工地 ⇒ 三支全 false ⇒ 【不 applicable】
   ⇒ 通用規則【本來就會處理它】
```
⇒ ★**兩者並存 ＝ 同一件事有兩套機制** —— ★★**而那正是今天一直在防的形狀**
   （★★★而且它更糟一點：我那條在通用規則【之前】跑，所以通用規則的計數會少掉那一批 ⇒ 數字會互相遮蔽）。

## ★我的提議（★但拆不拆是你的 seam 判斷）
```
①通用規則落地時【同時拆掉】我那條特例（含它的 tap）
②★對帳：拆之前 `survival.own_camp_lost_release` = 7／6／7
   ⇒ 拆之後 `survival.release_not_applicable.紮根` 應該【接手到那個量級】
   ⇒ ★★若接手後遠小於 7/6/7 ⇒ 通用規則【沒有涵蓋到】我以為它涵蓋的東西 ⇒ 那是要查的
   ⇒ ★★★這比「拆完跑一次看有沒有紅」強：它有一個【該對上的數字】
③★而若你要保留特例（例如它比通用規則早一個 tick 有意義），那也可以 —— ★★但要說明為什麼，
   否則下一個人看到兩條會不知道該改哪一條
```

# ★★③兩件我照抄下來（★免得做的時候忘記）
```
★per-option 記，不只記總數：`survival.release_not_applicable.<opt>`
★★排在 `_detect_survival_stall` 之後（免同 tick 重複處理）
★★★不設 cooldown，改加偵測器 `survival.release_recommit_same`
   （N 用既有 `STALL_EXCLUDE_WINDOW`，★不新增常數）
```
★**你那條通則我也記下**：**不要為了一個【沒有量到的病】先加一個【要調的常數】—— 先加偵測器。**

# ④現況
```
`br62fxema`（修前分桶基準）跑中：split_pre_1337 增長中，42／7 未開始
★樹仍鎖住，我沒動任何檔
```
