# 過期位置的目標 → 偵查分池 — HOW spec

status: SPEC（待 R²）｜from: systems
WHAT 來源: blueprint 裁 2026-09-17 —— **過期位置的目標是「情報不足」族的正牌成員，
它的正確去向是【偵查分池】（去看一眼值多少，上秤競爭），不是被靜默丟掉、也不是放寬門直接打。**

---

## §0 前提（★三條路【都】丟掉同一類目標，我逐條核過）

```
`_find_weakest_prey`（`faction_ai_system.gd:7331-7332`）
   第二道門 `has_belief`  ⇒ **只看 claims 非空，不看新鮮度** ⇒ ★**擋不住任何東西（實測 false ＝ 0 筆）**
   第三道門 `reachable`   ⇒ 走 `belief_pos` ⇒ **超過 `BELIEF_STALE_TICKS`（＝3 天）回 (-1,-1)**
`pick_recon_target`（`decision_context.gd:335-336`）
   ⇒ `if _rpos == Vector2i(-1, -1): continue   # ★不知道在哪 ⇒ 連去都去不了`
```
★★★**所以 blueprint 要的「去偵查分池」在今天的 code 上【不可能發生】** ——
**掠奪丟掉它、攻擊丟掉它、而偵查也丟掉它** ⇒ **那 6 筆目標對那支隊而言等於不存在。**

★**而那一行的註解本身就是這個洞的來源**：
> 「**不知道在哪 ⇒ 連去都去不了**」

⇒ ★★**那句話把兩件事寫成了一件**：
```
**「不知道它【現在】在哪」**  ⇒ 真的
**「不知道它在哪」**          ⇒ ★**假的 —— 我知道它三天前在哪，而我可以去那裡看一眼**
```
⇒ ★★★**差一個字，差掉整個偵查動詞。**

## §1 修法：偵查候選的位置來源改成【last-known ＋ 年齡】

```
現況：`_rpos = BeliefSystem.belief_pos(...)`  ⇒ 過期 ⇒ `(-1,-1)` ⇒ `continue`
新：   `_rpos = <last-known 位置>`（**不經新鮮度閘**）＋ `_rage = now − claim.tick`
      ⇒ ★**位置未知【只有在真的沒有任何 claim 時】才 `continue`**
```
★**而年齡要進【價值】不是進【門】**：
```
`_rval = _prior × δ^days × freshness_factor(_rage)`
  ★`freshness_factor` **單調遞減、永不歸零**（★★**歸零＝又變回一道靜默的門**）
  ★★而它的形狀要**物理**：**目標越會跑、情報越舊 ⇒ 撲空機率越高**
     ⇒ **不是「三天後價值 0」，是「三天後那裡有它的機率比較低」**
```
★★★**零新旋鈕**：`freshness_factor` 的分母走**移動能力**，**不是一個新的死常數**。
★**而「誰的移動能力」在 §5④ 被改掉了**：不是目標的（那會讀 god-view），是**不讀任何隊狀態的基準旅行者**
（`MovementSystem.baseline_tiles_per_day()`，由 `BASE_MOVE_TICKS` 導出）。**讀本節請直接跳 §5④。**

## §2 ★為什麼不放寬掠奪／攻擊那兩道門（blueprint 明示，而我同意並補理由）
```
放寬 ⇒ **隊會【直接打】一個它不知道在哪的目標** ⇒ ★**那是隔空作用，違反感知鐵律**
接偵查 ⇒ **隊先去看一眼** ⇒ 位置更新 ⇒ **攻擊／掠奪自然解鎖**
⇒ ★★**而那正是對的戲**：**絕境者「先找到獵物再動手」。**
```

## §3 驗收（★每格能紅）
| # | 格 | 會紅的那一半 |
|---|---|---|
| 1 | ★**過期位置的目標【出現在偵查候選集裡】** | 不出現 ⇒ 還在被 `continue` 掉 |
| 2 | ★**完全沒有 claim 的目標仍然【不在】候選集** | 出現 ⇒ 我們把門拆過頭了 |
| 3 | ★★**年齡越大 ⇒ 偵查價值越低，而【永不為 0】** | 歸零 ⇒ **又變成一道靜默的門** |
| 4 | ★★★**絕境那 6 筆**：偵查成為可行選項（★**不要求它贏，只要求它【上場】**） | 仍不在候選 ⇒ 本票沒打中 |
| 5 | **掠奪／攻擊那兩道門【逐字未改】** | 改了 ⇒ 越界（blueprint 明示不放寬） |
★**母體要報**：每格印「樣本數 ／ 母體」。

## §4 ★不在本票（寫出來讓「沒做」可被看見）
```
**`BELIEF_STALE_TICKS ＝ TICKS_PER_DAY × 3`（`belief_system.gd:10`，標著 TEST VALUE）**
⇒ ★**我裁：它該【物理化】**（有效期由【目標移動能力 × 距離】決定，不是全域死常數）
⇒ ★★**但不在本票** —— **它是 `BeliefSystem` 的全域語意，動它會影響所有讀者**
⇒ **已開票**：`belief-staleness-line-is-a-dead-constant`
```

## §5 ★★★R² 補三點（2026-09-17，都是精度缺口不是方向）

### ① 行號漂移 ⇒ 重錨（★R² 核實過的）
```
`belief_system.gd:106-142`（`has_belief` 與 `belief_pos` 兩分支皆過 staleness gate）
`path_system.gd:246-250`（`estimate_catch_up` 走同一個 `belief_pos` gate）
`decision/decision_context.gd:335-336`（`pick_recon_target` 的 `continue`）
```

### ② ★★**`freshness_factor` 的速度要傳【目標】的 team，不是觀察者的**
```
`GoalResolver._tiles_per_day(state, team)`（`goal_resolver.gd:707`）是**通用函式：吃誰的 team 就算誰的速度**
★**而 `decision_context.gd:326` 現有的呼叫傳的是【觀察者】**（算「我要走幾天」）
⇒ ★★**本票的 `freshness_factor` 要傳【目標的 team】**（算「它三天可以跑多遠」）
⇒ ★★★**不要照抄旁邊那一行** —— **兩個呼叫長得一模一樣而意思相反。**
```
★★★**本節整段作廢，見 §5④。**（留著不刪：它是「這一格被裁過」的證據，刪掉下一輪會有人重挖同一個洞。）

### ③ ★★★格2 拆成兩格（★我原本把兩件事寫成一件）
```
`record_claim` 的註解自承（`belief_system.gd:190-227` → `known_issues:784`）：
  **「有 claim 不代表有位置」** —— **轉述型 claim（`message_system.gd:277` relay）可能不帶 `tile_pos`**
⇒ ★**所以「完全沒有 claim 才 `continue`」擋不住【有 claim 但沒有位置】那一類。**
**拆成兩格**：
  **格2a**：**沒有任何 claim 的目標 ⇒ 不在候選集**
  **格2b**：★★**有 claim 但【從未有過 `tile_pos`】的目標 ⇒ 也不在候選集**
     ⇒ ★★★**而這一類要有名字**（tap：`recon.skip.claim_without_pos`）——
       **因為它與「位置過期」在畫面上長得一模一樣，而兩者的下一站相反**：
       **過期 ⇒ 去看一眼；從未有過 ⇒ 連要去哪裡都不知道。**
```

### ④ ★★★撤回 §5②：它照字面做會讀 god-view（systems 2026-09-17，implementer 抓到）

**我錯在哪（不是打錯字，是查得不夠深）**：§5② 只看了 `_tiles_per_day(state, team)` 的**簽章**
——「吃誰的 team 就算誰的速度」——**而沒有 grep 它內部吃什麼**。內部（`movement_system.gd:216/222/227/232`）
讀目標的 **live `tile_pos`（地形）／`fatigue`／載重／車輛**。
⇒ 撞憲法 §1a，**而 §1a 自己就點名了這個形狀**：「★最會漏的地方是被呼叫出去的小函式：呼叫端那一行看起來乾淨，live 讀藏在裡面。」
★★**更難看的是同一票的 §2 正是用感知鐵律擋住「放寬攻擊門」的** —— 前門擋住、後門讓它爬回來。

**定案（採 implementer 已實作的版本，`5ee159546`）**：
```
DecisionTerms.recon_freshness_factor(age_ticks, target_tiles_per_day, sight_tiles)
  速度 ← MovementSystem.baseline_tiles_per_day()   ★不讀任何一支隊的狀態
  視野 ← VisionSystem.vision_range(state, 觀察者)  ★自知，合法
```
理由：「我不知道它累不累、載了多少」**本來就是真的**；基準旅行者是對這個未知的**誠實預設**，
且它由 `BASE_MOVE_TICKS` 導出 ⇒ 不違反〈估算器禁手抄物理〉。

**★★★誠實標（逐字抄自 implementer，不准只活在信裡）**：
> 「目標跑得快 ⇒ 舊情報更不值錢」在**函式裡成立、在世界裡不成立**（所有目標同一個速度）。

★**衍生的驗收誠實標（systems 補）**：格 3-d（同樣 5 天，慢目標 1.000 vs 快目標 0.029）驗的是**函式**，
**不是世界** —— 世界從來不會餵它兩個不同的速度。⇒ **格 3-d 綠不得被引用成「世界裡的舊情報會因目標而分化」**
（同族：〈工具騙人〉⑤裝好了但沒接電、⑦我造的陽性對照是照著我偵測器的形狀造的）。

**★不在本票、且不是我的格**：要讓它在世界裡分化，得新增一個**移動能力 belief 欄位**（親見時記下它帶不帶車）。
而 §1a 尾巴逐字：「★★★**哪些欄位【能】進 belief 由 WHAT 定**」⇒ implementer 說「是你的格」這半句**不成立**，
**開不開那個欄位是 blueprint 的格**；我的格只有「這一票不做、且誠實標必須留下」。已追蹤：
`defers.tsv` → `target-speed-belief-field-or-flat-forever`，並已去信 blueprint。

---

# §6 ★後續票（不在本票）：錨定性讓情報保鮮 —— blueprint 2026-09-17 裁，systems 補兩條修正

**blueprint 逐字**：「①差異化過期是對的物理…v1 不用新欄位：既有 belief 已能導出【錨定性】——
believed 駐紮（`ACT_SETTLED`，`belief_system:367` 已在）或 belief 裡有它的據點 claim ⇒ 錨定 ⇒
位置過期慢（甚至不過期）；無錨 ⇒ 照快線過期。兩檔就夠，別做連續速度。」
「②真【移動能力】欄…緩開，等第二個真消費者帶清單來議（單一消費者禁開新軸，belief 欄與人格軸同受軸通膨管）。」

★**我同意 ①②，而 ③ 不成立，且 ① 落地時有一個他沒看到的閘。** 逐條：

## §6.1 ★★★他沒看到的閘：錨定性【自己】會在同一條線上過期

`BeliefSystem.appearance()`（`belief_system.gd:394-414`）在回 activity 之前**自己先過 `BELIEF_STALE_TICKS`**：
```
:405  if current_tick - bel.last_tick > BELIEF_STALE_TICKS:
:407      return {"activity": ACT_UNKNOWN, ..., "state": "stale"}
```
⇒ ★**「這則位置情報三天了，它還準嗎？」——而你要拿來判斷的錨定性，在同一個第三天也變成 UNKNOWN。**
**在最需要它的那一刻它剛好不在。**

**修法（★不是特例，是本票已經立好的同一個模式）**：本票對【位置】的作法是
「繞過新鮮度閘取 last-known ＋ 帶年齡回來，年齡進**價值**不進**門**」⇒ **錨定性用同一個模式讀 activity**。

★★★**R② 2026-09-17 修正（reviewer 提、systems 採納，我原本的版本比較差）**：
**不新增姊妹 accessor** —— `appearance()` 整支只是 `best_estimate()` 的 wrapper，而 `best_estimate()`
**本身不過期**（`belief_system.gd:144-161`，回的是 claim 的 `value`，`activity` 與 `last_tick` 都在裡面）
⇒ **呼叫端直接讀 `best_estimate()` 就有原值**，跟本票 §1 讓 `pick_recon_target` 直接讀 `tile_pos`/`last_tick`
**是同一次呼叫、同一個 dict**。
```
呼叫端（decision_context.gd，本票 §1 已經在那裡呼叫 best_estimate 了）:
  var bel := BeliefSystem.best_estimate(state, 觀察者, 目標)
    bel["tile_pos"]   ← 本票 §1 已在用
    bel["last_tick"]  ← 本票 §1 已在用（算年齡）
    bel["activity"]   ← ★本節新增的讀取，**同一次讀、同一個 tick**
★ appearance() 逐字不動 —— 它唯一的生產消費者 faction_ai_system.gd:934-935 有一道
  `if state != "fresh": continue` 的邀請門，靠的正是它現在的過期行為（reviewer 窮舉核實）。
```
★★**這比我原本的版本更符合不變量 #6**：#6 要的是「決定與依據同一次計算」。
新增 `appearance_aged()` 會讓呼叫端對**同一則 claim 讀兩次**（位置一次、活動一次）
⇒ 兩次讀之間在型別上沒有東西保證是同一則 claim。**一次 `best_estimate` 才是 #6 的正解。**
★★★**三態在呼叫端處理**：`bel` 沒有 `activity` 這個 key ＝ **從未觀察到** ⇒ **走快線（無錨）**。
★**不得寫成 `.get("activity", ACT_SETTLED)` 之類的預設** —— 那會讓「沒看過」變成「看過它駐紮」，
是 §1a 明文禁的 default-pass。
★★★**而這整段都不是 fallback 到 live**：讀的仍然是 belief claim，只是**舊的**；
§1a 禁的是退回真值，不是禁止使用舊情報。

## §6.2 ★「甚至不過期」不採 —— 只降斜率，不設無限期

本票 §1 已立：`freshness_factor` **單調遞減、永不歸零**。錨定性**對稱地**只准動**斜率**：
```
錨定（believed ACT_SETTLED 或有據點 claim） ⇒ 慢線衰減
無錨                                        ⇒ 快線衰減
★兩者都仍然單調遞減、都永不歸零、都沒有「不過期」這一檔
```
**三個理由**：
1. ★**錨定的隊會拔營** —— 「不過期」讓一則**已經錯了的** belief 變成**不可證偽**（它永遠不會掉到會被重新偵查的價值）。
2. ★★**它會從後門鬆開攻擊門**：`_find_weakest_prey` 的 reachable 走 `belief_pos`，而 `belief_pos` 吃的就是
   `BELIEF_STALE_TICKS`。若「不過期」是做在 `BeliefSystem` 那條線上 ⇒ **駐紮目標的舊座標會直接通過攻擊門** ⇒
   **正是本票 §2 明文擋下的那件事**（隔空作用）。
3. ★★★**而這正是 ① 的兩個落點不同義**：
   | 落點 | 影響範圍 | 本票立場 |
   |---|---|---|
   | (A) 錨定性餵 `freshness_factor`（偵查目標的**價值折扣**） | 只有偵查選點 | ★**就做這個** |
   | (B) 錨定性改 `BELIEF_STALE_TICKS`（`BeliefSystem` 的**全域閘**） | 所有讀者，含攻擊/掠奪門 | ★**不做** —— 它是 `defers.tsv` → `belief-staleness-line-is-a-dead-constant`，且會違反 §2 |

## §6.3 ★他的 ③ 不成立（時態問題，不是對錯問題）

blueprint ③：「你 §5④ 的誠實標被①解掉」。
★**裁定之後、實作之前，誠實標照留。** 現在世界裡沒有任何一行 code 讀錨定性去調過期速度
⇒ 「快慢只活在函式裡」**此刻仍然是真的**。
★★**解除條件寫成機械的**：`defers.tsv` → `target-speed-belief-field-or-flat-forever` 那一行的 met_check，
待本節落地後改寫成「`freshness_factor` 的呼叫端讀得到錨定性」；
在那之前它就該亮著 —— ★★★**「裁過了」和「接上了」是兩件事**（同族血證：我立的「床要標版本」規矩在立規當天四支 raw 全沒帶）。

## §6.4 驗收（★每格能紅）

| 格 | 內容 | 反向（機制關掉要變紅） |
|---|---|---|
| 6-a | 同齡（5 天）兩個目標：believed `ACT_SETTLED` vs believed `ACT_MOVING` ⇒ 前者 `freshness_factor` **顯著高** | 拔掉錨定分檔 ⇒ 兩者相等 |
| 6-b | 錨定目標的 `freshness_factor` 在 age→大 時**仍單調遞減且 > 0** | 若有人做成「不過期」⇒ 這格紅 |
| 6-c | ★**錨定性本身是舊的也讀得到**：activity claim 已 > `BELIEF_STALE_TICKS` 的錨定目標，仍走慢線 | 若誤用 `appearance()` ⇒ 回 `ACT_UNKNOWN` ⇒ 退回快線 ⇒ 這格紅（★這格就是 §6.1 那個閘的守衛，**修法改成直接讀 `best_estimate` 之後它照樣有效**——它守的是「有沒有走錯那條路」，不是守某一支函式） |
| 6-f | ★★**從未觀察過 activity 的目標走【快線】**（`bel` 無 `activity` key） | 若有人寫了 `.get("activity", <某個錨定值>)` ⇒ 這格紅（default-pass 守衛） |
| 6-d | ★★**兩道門逐字未改**：`_find_weakest_prey` / 攻擊 scan 的 `belief_pos` 判斷 diff **為空** | 若有人走 (B) 落點 ⇒ 這格紅 |
| 6-e | 世界級：錨定目標的舊座標**被沿用**、無錨目標的舊座標**被重新偵查**（各至少 1 例，帶 tap） | 全世界只有一種行為 ⇒ 紅 |

