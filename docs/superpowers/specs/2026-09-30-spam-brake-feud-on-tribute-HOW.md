# HOW：濫按索貢的煞車＝被索方結怨（而真因是一道補丁閘）

**上游 WHAT**：`docs/superpowers/handbacks/2026-09-30-blueprint-to-systems-RULING-permanent-feud-now-decay-is-its-own-ticket.md`
（藍圖 (c) 先行：只加寫入 —— 索貢成功 ⇒ `add_edge(對方領袖, "feud", 玩家領袖, intensity, tick)`，
`intensity ＝ amount ／ 對方 coin_before`；讀那半已在 `tribute_accept`；衰減＝另票；(b) 否決；P3b 兩向。）

**★★★本 spec 與那份裁定有一處實體衝突，而衝突是算出來的不是讀出來的**：
**照字面落地，玩家濫按那一向的效果是【零】。** §2 是那道算術，§3 是真因，§4 是修法。

---

## ★★★§1 前提（逐字 file:line，全部我開檔核過）

```
①讀那一端【真的已經存在】：
   diplomatic_ai_system.gd:42 tribute_accept()
     feud_i = _edge_intensity_to(leader.relation_edges, "feud", aggressor.leader_id)
     score -= feud_i * TRIBUTE_W_FEUD            (:27  = 0.3)
     return score > TRIBUTE_ACCEPT_THRESHOLD     (:29  = 0.1)
②索貢／勒索共有【三條管道、兩個公式】：
   (甲) 遠程索貢（玩家專用動詞）player_command_system.gd:313-318
        handle_diplomacy_message(state, tgt, pt, "demand_tribute")
        → accept ⇒ amount = float(tgt.resources["coin"]) * 0.1   # TEST VALUE
                   ResourceBank.add(tgt,"coin",-amount,"demand_tribute_out")
                   ResourceBank.add(pt ,"coin", amount,"demand_tribute_in")
   (乙) 同格勒索（玩家發起）interaction_system.gd:1489 判定 → :1494 _resolve_extortion
   (丙) 同格勒索（NPC↔NPC）interaction_system.gd:447/:456 判定 → :449/:458 同一個 _resolve_extortion
        ⇒ (乙)(丙) 共用 interaction_system.gd:488 _resolve_extortion：
           四資源各 × TRIBUTE_RATE (:10 = 0.25)
③NPC 也會寄遠程索貢：diplomatic_ai_system.gd:161 _send_diplomacy_message(...,"demand_tribute")
   ★對玩家時寫 forced_event 並【已經設冷卻】(:176-178)，註解逐字：
     「設冷卻：玩家拒/超時後不立刻重發（原玩家路徑漏設 → 隔空 spam）」
   ⇒ ★★**NPC→玩家那一向的煞車已經存在**。本票缺的是【玩家→NPC】那一向。
④feud 的【唯一形成點】＝ npc_ai_system.gd:36 form_feud()
   而 write_memory 的 :117-119 _write_relation_edge 只對四個名字委派它：
     "betrayal","looted","special_taxed","rejected_aid"
     → form_feud(p, subject_id, FEUD_SEVERITY.get(type, intensity), tick)
   ★★★注意 `.get(type, intensity)`：**名字若在表裡，傳進來的 intensity 就被丟掉**。
   FEUD_SEVERITY (:29-33) = massacre 1.0 / betrayal 0.8 / subjugated 0.5 /
                            looted 0.35 / special_taxed 0.30 / rejected_aid 0.325
⑤form_feud 的閘（:39-46）：
   factor = FEUD_BASE_FACTOR(0.2) + 義氣*FEUD_HONOR_W(0.7) + 好戰*FEUD_BELLIGERENCE_W(0.4)
   intensity = clampf(severity * factor, 0, 1)
   ★if intensity < FEUD_MIN(0.30): return false      ← **在 add_edge 之前**
   之後才：RelationGraph.add_edge(...) ／ _activate_goal(victim,"revenge") ／ Probe.bump
⑥飽和疊加在 relation_graph.gd:7 add_edge 之【內】：1−(1−a)(1−b)，檔頭逐字寫
   「小怨會累積／單次大怨直接高／永不破 1／順序無關」
```

---

## ★★★§2 算術：藍圖的字面落地＝零效果（三個形狀都算一遍）

### (乙) 新名字 ＋ severity ＝ 拿走比例（＝裁定的字面語意）

```
factor 的上界 = 0.2 + 0.7 + 0.4 = 1.3（義氣＝好戰＝1.0 的極端領袖）
遠程索貢 severity = amount/coin_before = 0.1（就是 (甲) 那一行的 0.1）
  ⇒ intensity ≤ 0.1 × 1.3 = 0.13  <  FEUD_MIN 0.30
  ⇒ ★**不管對方是什麼人格，一律被閘擋掉 ⇒ 永遠不結怨 ⇒ 煞車不存在。**
同格勒索 severity = TRIBUTE_RATE = 0.25
  ⇒ intensity ≤ 0.325，要過 0.30 需 factor ≥ 1.2 ⇒ 義氣*0.7 + 好戰*0.4 ≥ 1.0
  ⇒ 幾乎只有兩項都 ≈ 1.0 的領袖 ⇒ 實務上也是零。
★★★而用戶濫按的那一向就是遠程索貢 ⇒ **裁定的字面在那一向恆零。**
```

### (甲) 借用既有名字 `special_taxed`（severity 固定 0.30）

```
要過閘需 factor ≥ 1.0 ⇒ 義氣*0.7 + 好戰*0.4 ≥ 0.8
  （例：義氣 .8 好戰 .6 ⇒ 剛好 1.0 ⇒ intensity 0.30 ＝ FEUD_MIN，過）
  平均領袖 .5/.5 ⇒ factor 0.75 ⇒ 0.225 ⇒ **被擋**
⇒ 只有義氣＋好戰都偏高的領袖會結怨。
★★而它還把藍圖裁的「拿走幾成」**靜默丟掉**（§1④ 那個 `.get(type, intensity)`）
  ⇒ 十次小索貢與一次大索貢的 severity 完全相同。
  ★★★這是最危險的一個形狀：**卷面會綠**（怨確實會累積），
    而【大小 matter】那一半消失得沒有任何紅燈。
```

### (丙) 直接 `add_edge`（裁定的字面寫法）—— ★我否決

```
·繞過 form_feud ⇒ 繞過人格 factor ⇒ 違反「人格 MODULATE 真值」（憲法）
·★邊沒有記憶 ⇒ 一個人怨你，而他的記憶裡沒有為什麼
·★★grudge_ledger_bed.gd:163-180 格7 的【名字→邊】表就不再是完整母體：
   世界上會出現一條沒有名字的 feud 邊，而那一格的存在目的正是「名字有沒有接上」
⇒ 否決理由不是風格，是它會製造一個**這個專案已經修過一次**的病
  （`extorted` 那個「沒有人叫的名字」，npc_ai_system.gd:133 註解逐字留著）
```

### ★★而【讀那一端】也要算，否則寫進去了也可能翻不動

```
動詞開放條件：player_command_system.gd:47  pt.population > int(tgt.population * 1.5)
  ⇒ 玩家用得出這個動詞時 power_r ≈ 1.5 ⇒ (1.5−1)*TRIBUTE_W_POWER(0.4) = +0.20
典型分數：+0.20(power) + 慎重.5*0.3(+.15) + 求生.5*0.2(+.10)
          − 義氣.5*0.3(−.15) + fear 0 + threat 0（遠程＝0）  ≈ 0.30
門檻 0.1 ⇒ 餘裕 0.20 ⇒ 要翻成拒絕需 feud_i * 0.3 > 0.20 ⇒ **feud_i > 0.667**
飽和疊加（每次 0.30）：0.300 → 0.510 → 0.657 → 0.760
  ⇒ ★**第 4 次左右開始被拒** —— 這正是煞車該有的形狀（第一次成功、濫按才有代價）。
⇒ ★★★所以煞車在數字上是可行的，**但只有在「小怨存得進去」時才可行。**
```

---

## ★★★§3 真因：`FEUD_MIN` 是一道補丁閘，它 pre-empt 了飽和疊加引擎

```
add_edge 的檔頭逐字寫「小怨會累積」（用戶 2026-09-16 裁的四個性質之一），
而 form_feud 的 FEUD_MIN 閘在 add_edge 【之前】
⇒ 小於門檻的怨【一次都進不去】⇒ ★累積永遠不會開始。
⇒ 「小怨會累積」對 severity < 0.30/factor 的事件是【假的】，
   而它假得很安靜：沒有邊、沒有 print，Probe 也不 bump（bump 也在閘之後）。
★★這是「補丁閘優先查」的教科書形狀：行為缺失（濫按沒有代價）的根不是 tuning，
  是一道硬門檻站在引擎前面。⇒ 修法是 de-patch（把仲裁交給決策層），不是加補償補丁。
```

---

## §4 做什麼

```
①★de-patch form_feud（npc_ai_system.gd:36-52）：
   把 RelationGraph.add_edge(...) 移到 FEUD_MIN 判斷【之前】（無條件寫，仍乘人格 factor）；
   FEUD_MIN 之後只留 _activate_goal(victim,"revenge") 與兩個 Probe.bump
   ⇒ ★寫入層不仲裁、決策層仲裁。★★既有 revenge 行為【完全不變】（goal 仍受門檻管）。
   ★★★回傳值語意改變：`form_feud` 原本 return true = 「已結仇」。
     現在要分成兩件事 ⇒ **回傳值繼續代表「有沒有到 revenge 那一級」**（呼叫端不用改），
     並在函式頭寫明「回 false ≠ 沒有寫邊」。★掃過所有讀回傳值的呼叫端，確認沒有人
     把它當「有沒有邊」用（若有，那個呼叫端改讀 intensity_to）。
②★新名字 `tributed`（不是復活 `extorted`）：
   ·_write_relation_edge (:117) 的 feud 那一組加 "tributed"
   ·★**不進 FEUD_SEVERITY 表** ⇒ `.get(type, intensity)` 落到 default ⇒ 傳入的 intensity 生效
   ·_update_relations (:135 附近) 加一列 "tributed": delta = -intensity * 0.5（同 special_taxed 語意）
   ★★兩處都要加。只加一處＝「讀者還在寫者沒了」的鏡像：邊有了而 relations 數值不動。
③★寫入點兩個，都在【執行端】不在【秤裡】：
   ·player_command_system.gd:316 accept 分支：
     coin_before ＝ 那一行自己讀的 float(tgt.resources.get("coin",0))
     ⇒ intensity = amount / coin_before（＝那一行的 0.1，同源推導，零新常數）
     ⇒ write_memory(state.persons[tgt.leader_id], "tributed", pt.leader_id, tick, intensity)
   ·interaction_system.gd:488 _resolve_extortion：coin 那一項
     coin_before ＝ 迴圈裡 res=="coin" 那一次的 float(def.resources.get("coin",0))
     ⇒ intensity = tribute / coin_before（＝TRIBUTE_RATE，同源）
     ⇒ 對 def.leader_id 寫，subject ＝ atk.leader_id
     ★★這一個同時涵蓋 NPC↔NPC（:449/:458）⇒ **玩家零特殊物理**
   ★coin_before <= 0 ⇒ amount 也是 0 ⇒ **不寫**（同時避免除零）
   ★★coin 完全沒被拿走而其他資源被拿走的情況：本票**不寫邊**，並在 code 註解寫明
     「intensity 的母體只有 coin，因為裁定的推導錨在 coin×比例」⇒ 那是已知窄處，不是漏。
④★不要寫在 tribute_accept 裡：它是【秤】，且有 4 個床呼叫端
   （headless_test:1166/1169、depatch_track2_test:49/59、depatch_track2_verify_bed:92）
   ⇒ 在秤裡寫世界＝觀測改變被觀測物。
⑤NPC 寄件側冷卻設 0 是【床的設定】不是產品改動（見 §5 P2）。
```

---

## ★★★§5 驗收（★負對照全部要實測紅，不是預言紅）

```
P1 [寫得進去] 遠程索貢成功一次 ⇒ 被索方領袖的 memory 有一筆 type=="tributed"、
   feud 邊 > 0，且印出 factor 與義氣／好戰兩個值（★讓「為什麼是這個數」看得見）
   ｜負對照：拿掉 ③ 那一行 write_memory ⇒ 邊 0、memory 無此筆 ⇒ 必紅

P2 ★★★[煞車真的在] 對同一隊連索 20 次，逐次印：accept／refuse、當時 feud_i、coin_before
   斷言四件：①第 1 次 accept ②feud_i 單調不減 ③**至少出現一次 refuse**
            ④第一次 refuse 之後再索【仍然 refuse】
   ★母體地板：印出 coin_before 每一次都 > 0
     —— 否則後面的 refuse 是「沒錢可拿」而不是「結怨」，而那兩件事的處置完全相反
   ★★NPC 寄件冷卻在床裡設 0 ⇒ 同一支腳本同一個形狀
     ⇒ **證明煞車在【收方決策】而不是在【寄件節流】**
   ★★★負對照：拿掉邊的寫入 ⇒ 20／20 全 accept ⇒ 必紅

P3b [兩向：現在是永久] 第一次 refuse 之後【推三天】再索 ⇒ **仍然 refuse**
   ★這一格就是藍圖 (a)（衰減）落地那天要翻的那一格 ⇒ 註解裡寫明它是【兩向格】，
     翻的時候要改斷言而不是刪格

P4 ★[玩家零特殊物理] NPC↔NPC 同格勒索（玩家不在場）也結怨
   ｜負對照：把寫入只掛在玩家那一支 ⇒ P4 紅

P5 ★★[我移的是閘的位置，不是拿掉閘] 造一次 severity 0.1 的 feud 事件 ⇒
   邊 > 0 **而** victim.goals 裡**沒有** revenge
   ｜負對照：把 _activate_goal 也移到閘前 ⇒ 出現 revenge ⇒ 必紅
   ★這一格守住「既有 revenge 行為不變」這句話 —— 沒有它，那句話只是一句宣稱

P6 grudge_ledger_bed.gd:163 格7 的名字表加一列 ["tributed","feud","<寫入點 file:line>"]
   ★★而格7-b（`extorted` 是死名字 ⇒ 什麼都不做）**不動**：
     `tributed` 是新名字，不是復活舊的 ⇒ 那一格必須維持綠

P7 ★[分佈可見] 印 Probe 的 grudge.form.feud.sev* 分佈
   ★★但 bump 現在在閘之後 ⇒ ①之後要確認：sev 分佈要不要跟著移到閘前？
     **移**（否則新加的小怨在量測上不存在＝違反全量暫態可觀測性）
   ⇒ 移完會多出 sev0.100／sev0.250 兩格；床把它們印出來

P8 headless ≥1000 tick 無崩潰；ui-flow 綠；全電池 BATTERY_RC=0
   ★★★而 ①改的是全世界 feud 的形成 ⇒ 它會動 fingerprint。
     **先量再換基準**（預測不是授權）：量出來變了 ⇒ 換基準與改動同一顆 commit；
     量出來沒變 ⇒ **不要動基準**，並把「為什麼沒變」寫進卷面。
```

---

## §6 不在本票

```
·feud 衰減（藍圖已裁：另一張 WHAT 票，先量各 type 的邊齡分佈）
·NPC 寄件側 diplomacy_reject_cooldown 的補丁債（已在 defers）
·★NPC↔NPC 的【遠程】索貢 accept 之後**沒有任何資源轉移**
   （_send_diplomacy_message:183-186 只印回應；只有 refuse 那一支寫記憶／名聲）
   ⇒ 既有缺陷，不在本票，§7 呈報
·★★玩家的 demand_tribute 是【隔空即時】：player_command_system.gd:313 直接呼
   handle_diplomacy_message，而 NPC 那一側走 _send_diplomacy_message（訊息管道）
   ⇒ 這與感知鐵律「跨距 action 需 proximity/envoy」對不上 ⇒ §7 呈報，不在本票
   ★而它與本票相關：若日後改成走信使，intensity 的推導點會從 :316 搬走
```

## ★§7 呈報藍圖（★★世界既有行為會變，他要知道）

```
①§4① 移閘 ⇒ 平均／膽小領袖被搶、被重徵稅、求救被拒之後**也會有小怨**（之前是 0）。
   方向與他 2026-09-16「小怨會累積」的裁定一致，但**那次裁的是疊加公式、不是閘的位置**
   ⇒ 這是他沒裁過的一格。
②他 (c) 的字面寫法（直接 add_edge）我否決，理由 §2(丙)。
③他裁的 intensity 語意（拿走幾成）**只有在 ① 做了之後才有效果**；
   不做 ① 而照字面做，遠程那一向恆零 —— ★而卷面會綠。
④兩個既有缺陷呈報（§6 後兩條）：NPC↔NPC 遠程索貢不轉移資源；玩家 demand_tribute 隔空即時。
```

---

## ~~§8 蘇裁（藍圖裁 (A)）~~ ★★★**已作廃，留著留理由**

> **(A) 被用戶的兩層制裁定取代**（見 §9）。本節不刪，因為它記著
> 【我把門檦讀成複道門】而用戶把它讀成【什麼算記得住的事】—— ★同一道門檦、兩個語意，
> 而我的診斷（§3）在【症狀】上是對的、在【病名】上是錯的。**下面這一段仍適用於 §9**：
> ④「拿走幾成」禁被嚴重度表静默覆蓋、⑤「第 N 次」不釣、§8c 的 D1／D2。

## ★★★§8 （原文，已作廃）蘇裁 2026-09-30（藍圖裁 (A)）

信：`docs/superpowers/handbacks/2026-09-30-blueprint-to-systems-RULING-A-write-edges-before-the-threshold.md`

```
①(A) 裁准 ⇒ §4① 照做。強度公式不動（嚴重度 × 人格乘子），
   門檦 0.30 【只】保留給「啟動復仇目標」。
   ★判準句（藍圖逐字）：**寫入層不仲裁，決策層仲裁**。
   ★★同族歸納（藍圖指出）：**一件事發生了卻沒進任何帳，就是静默丟棄**。
②世界行為會變那一格裁准：平均／膽小領袖被搶／被重徵稅／求救不應 ⇒ 有小怨。
   藍圖逐字：「怨的大小由人格乘子決定，膽小的小、義氣好戰的大，**沒有人是零**」。
   fp 變 ⇒ 基準同 commit；P5 先量再換。
③(B)（只對索貢繞門檦）、(C)（不做煞車）均否決。
   ★(C) 的否決理由是事実而不是偏好：**用戶已經看到 20／20 那個數字**。
```

### ★★★§8a【拿走幾成】禁被嚴重度表的固定值静默覆蓋（藍圖④）

```
§4② 選新名字 `tributed` 而【不進 FEUD_SEVERITY 表】⇒ 這條已經滿足。
★但「現在滿足」不等於「下一個人不會把它加進表裏」⇒ 要一格守它：
P1b 【進公式的嚴重度要印出來】床印出 `form_feud` 實際收到的 severity，
    並斷言它等於 amount／coin_before（遠程⁐0.1、同格⁐0.25）
    ｜★★負對照：把 `"tributed": 0.30` 加進 FEUD_SEVERITY ⇒ 印出的 severity 變 0.30
      ⇒ **必紅**。★★★這一格守的不是數值，是【誰的值被讀】——
        `.get(type, intensity)` 讓【把名字加進表】這個看起來很無害的動作
        静默抽換該票的核心語意，而卷面上沒有任何其他差別。
```

### ★★§8b「第 4 次」不釣（藍圖⑤）—— §2 那句結論降級

```
§2 最後一段的「要 feud_i > 0.667 ⇒ 第 4 次左右開始被拒」
★其中的 0.30（典型屈服分數）是我拿人格中位 0.5 湊的，**不是量的**。
⇒ 它從【spec 的斷言】降級成【床要印出來的東西】：
   ·P2 印完整序列（每一次的 accept／refuse、feud_i、coin_before）
   ·★★**不斷言第幾次**；只斷言【至少出現一次 refuse】與【refuse 之後仍 refuse】
   ·★★★而序列本身要進卷面：它是下一張票（衰減）的基線，
     而不是一個驗完就丟的中間物。
⇒ §2 原句的認識地位：它是【瀏覽式估算】，用來回答「煞車在數字上有沒有可能」，
   **不用來定驗收**。審查優先打它（我已寫進 R² 信）。
```

### §8c 两個呈报的落處（藍圖裁：登 defer，不在本票）

```
D1 `npc-remote-tribute-accepted-but-zero-transfer`：NPC↔NPC 遠程索貢谈成後零轉移
   ★藍圖定調：**真 bug——谈成的東西沒發生**。排濫按之後。
D2 `player-tribute-bypasses-courier`：玩家索貢隔空即時（直呼對方判定）
   ⇒ 玩家的索貢／提議應走同一條訊息管道（**延遲＝距離**），與資訊網零特例一致。
   ★藍圖要先跟用戶講（玩家手感會變：提議不再是即時回）⇒ **本票不碰**。
```

---

## ★★★§9 第四裁：用戶裁【兩層關係帳】—— 本節是本票的現行設計（取代 §4①與 §8）

**上游** `docs/superpowers/handbacks/2026-09-30-blueprint-to-systems-RULING-two-tier-relations-affinity-for-small-memory-for-big.md`
**用戶逐字**：「小恩小怨的直接在好感做加減 不入記憶 大恩大怨才入記憶」

```
【好感】人對人的有號標量：小事直接加減、**不記原因**、會回中（衰減另票）
【記憶】typed 邊（feud／gratitude／protect…）：**只有過門檦的大事**才寫、帶原因、可被復仇／報恩消費
門檦＝既有的 FEUD_MIN 0.30（嚴重度×人格乘子）
  ⇒ ★它不是被移除，是**被重新定義**：從「誰可以進帳」改成「什麼算記得住的事」
  ⇒ 門檦下**不再静默丟棄**，改進好感
決策讀【兩項】，權重各自獨立可改
```

### §9a ★標量欄位的決定（藍圖授權我定）：**用既有的 `p.relations`，不新開**

```
事實（我開檔核過）：
  ·欄位已存在：person_data.gd:69  var relations: Dictionary = {}
  ·**唯一寫入點**：npc_ai_system.gd:146
      p.relations[subject_id] = clampf(cur + delta, -1.0, 1.0)
    ⇒ 已經是【有號、[-1,1]、人對人、不記原因】—— **就是好感的形狀**
  ·而它在 `_update_relations` 裏，**在門檦之前、無條件執行**
    ⇒ ★★「門檦下零丟棄」對那 8 個名字**今天已經成立** —— 不是要新做的事
⇒ 新開一個欄位＝兩份並存（藍圖明文禁）。**定案：用 `p.relations`。**
```

**★★★而這一定案把本票從「加機制」改成「接上已經在寫的帳」，而缺口正好是三個**：

```
缺口① ★**寫者在、讀者幾乎不在**：`p.relations` 全庫只有一個讀者 ——
       diplomatic_ai_system.gd:103 `_calc_diplomacy_score` 的 relation 項。
       而 `tribute_accept`（屈不屈服）**完全沒讀它** ⇒ 煞車的載體目前沒接電。
       ⇒ ★★這正是我自己那一格記憶的鏡像：**讀者還在寫者沒了** 的反面。
缺口② ★**`p.relations` 不在 fingerprint 裏**：state_fingerprint.gd 只對 **faction** 的
       `relations` 有 tap（:429-431），對 **person** 的沒有
       ⇒ 好感就是藍圖說的「新 state」（對卷面而言它本來就不存在）
       ⇒ **tap 必接**（全量暫態可觀測性，不變量）。
缺口③ 「會回中」沒做（藍圖裁：衰減另票先量）⇒ 本票**不做**，但要在 code 註解寫明。
★而現行的 clamp 線性加（非飽和）**不動**：小事線性累積是對的，
  飽和留給 typed 邊（那是 09-16 裁的）⇒ **兩層的累積法本來就不同，不要統一它們**。
```

### §9b 做什麼（取代 §4①）

```
①~~把 add_edge 移到門檦之前~~ ★**不做**（(A) 撕回）。`form_feud` 一行不動。
②新名字 `tributed`：照 §4② 做，且**兩層同時接**：
   ·_write_relation_edge 的 feud 那一組加 "tributed" ⇒ 過門檦的大索貢才寫邊
     （遠程 severity 0.1、同格 0.25 ⇒ 實務上都不過門檦 ⇒ **不寫邊是正確行為**）
   ·_update_relations 加 "tributed": delta = -intensity * 0.5（同 special_taxed 的係數，零新常數）
     ⇒ ★**這一行才是煞車的本體**
③寫入點兩個：照 §4③ 不變（執行端、非秤裏；coin_before<=0 不寫）
④★**`tribute_accept` 加好感項**（缺口①）：
   score += affinity * TRIBUTE_W_AFFINITY
   ★★權重新常數一個，而它**不得手抄**：取 `_calc_diplomacy_score:103` 那個讀好感的
   項所用的同一個權重（若那裡是 inline 數字，先把它提成常數再共用）
   ⇒ **一份真相只存一份**；若兩處語意真的不同，那就寫成兩個常數**並在註解裏講清差別**。
   ★★★藍圖裁「決策讀兩項，權重可各自獨立改」⇒ feud 項與好感項**不得共用同一個常數**。
⑤★**person.relations 接 fingerprint**（缺口②）：照 faction 那一行的形狀
   （`_dict_canon`）接到 person 的區塊 ⇒ ★fp 會變，**先量再換基準、同 commit**。
```

### §9c 驗收修訂（取代 P1／P2／P5／P7）

```
P1′ 遠程索貢成功一次 ⇒ 印【實際進公式的 severity】、人格兩值、factor、
    【好感前後】與【feud 邊前後】
    ★斷言：**好感下降** 且 **feud 邊仍然是 0**（小事不入記憶＝用戶逐字）
    ｜負對照 a：拿掉 _update_relations 那一列 ⇒ 好感不動 ⇒ 必紅
    ｜★★負對照 b（守兩層的分界）：把 `"tributed": 0.30` 加進 FEUD_SEVERITY
      ⇒ 小索貢突然寫起 feud 邊 ⇒ **必紅**。★★★它守的是【誰的值被讀】：
        `.get(type, intensity)` 讓「把名字加進表」這個看起來無害的動作
        同時打破**拿走幾成**與**兩層分界**，而卷面上沒有其他差別。

P2′ 連索 20 次，逐次印：accept／refuse、**好感**、feud_i、coin_before、**score_no_edge**
    斷言：①第 1 次 accept ②好感單調不增 ③至少出現一次 refuse ④refuse 之後仍 refuse
    ★★**不釣第幾次**（藍圖⑤）—— 序列進卷面，它是衰減那張票的基線
    ★★★**母體地板三道**（審查 P2③ 的裁定：它在賭，而賭得比我想的兇）：
      (a) coin_before 每一次都 > 0（否則 refuse 是「沒錢可拿」不是「結怨」）
      (b) 印 score_no_edge：★**若它太高，20 次內一次 refuse 也不會出現**
      (c) ★★**領袖人格必頡死**（不允許用預設／「典型」值），
          且床要算出並印出【理誖上第幾次翻】，再跟實測序列對一次
          ⇒ ★★★兩行自相矛皾就是紅燈（這是我【門檦比累計不比單位量】那一格的形狀）
    ｜負對照：拿掉 ④ 的好感項 ⇒ 20／20 全 accept ⇒ 必紅

P5′ ~~邊 > 0 而 goals 沒有 revenge~~ ★**作廃**（(A) 撕回，沒有移門就沒有這一格）
    ★★改成守【兩層不串】：造一次 severity 0.9 的大事 ⇒ **邊有了且好感也動了**；
    造一次 severity 0.1 的小事 ⇒ **只有好感動、邊仍然 0**
    ｜負對照：把 _update_relations 搬到門檦後面 ⇒ 小事好感不動 ⇒ 必紅
      （★這就是「門檦下零丟棄」的守衛）

P7′ Probe：~~把 sev 分佈搬到門檦前~~ ★**不搬**（邊沒寫就不該算在 feud 分佈裏）
    ★★改成：**好感層自己要有母體**—— 新增 `affinity.delta.<type>` 計數
    ⇒ 否則【改進好感的那些事】在量測上完全不存在（全量暫態可觀測性）
    ⇒ ★★★而這一項是新的：舊設計裏好感從來沒有任何 tap，而它一直有人在寫。
```

### ★★§9d 審查的四條怎麼落（verdict=issues，信：`2026-09-30-reviewer-to-systems-spam-brake-feud-verdict-issues.md`）

```
①★★★「飽和疊加（每次 0.30）⇒ 第 4 次」**我用錯了 severity 的來源** ——
  0.30 是 (甲) 那個【我沒選】的分支（special_taxed）的值，
  而我選定的遠程索貢 per-event intensity 是 0.1×factor≈0.075（審查重算：第 14-15 次）
  ⇒ ★量級差 3-4 倍，而我把那句寫進了給藍圖的呼報 ⇒ **已訂正，並在 §9e 指名錯法**。
  ⇒ ★★而在新設計下主詞又改了一次：煞車不再走 feud 累積，走**好感累積**
    （每次 -intensity×0.5 ≈ -0.0375 線性）⇒ **三個量級都不同，而三個都不釣** ⇒ 床印序列。
②`interaction_system.gd:1821 _views_as_foe` 用 `intensity > 0.0`（任何非零）不是門檦比較
  ⇒ ★**這個風險隨 (A) 撕回一起消失**（沒有新的小邊了）。
  ⇒ ★★**但不該默默不提**：它現在是一個已知的【隨時會被下一張票弄爆的讀法】
    ⇒ 登 defer：`views-as-foe-reads-any-nonzero-feud`（解除＝有人要寫門檦下的小邊時）
③grudge_ledger_bed 格7 那條理由**降級成補充說明**（它是理由②的偵測手段，不是獨立理由）—— 已收。
④P2③ 在賭 ⇒ 已改：P2′ 的母體地板 (b)(c)（印 score_no_edge＋頡死人格＋印理誖次數對照）。
```

### ★§9e 我在本票裡錯的兩件（留卷面，不清）

```
①**病名錯了**：我把 FEUD_MIN 讀成【複道門】，而用戶把同一道門讀成
  【什麼算記得住的事】。★我的症狀診斷是對的（小事被静默丟棄），
  而**我推出的修法把兩層壓成一層** ⇒ 小事會寫進【帶原因、可被復仇消費】的帳。
  ⇒ ★★判準：**看到一道「擋住了東西」的門檦，先問它擋的那些東西【本來該去哪裡】**，
    而不是預設「它們本來該進同一個帳」。一個門檦可以是【分流器】而不是【損失】。
②**量級錯了 3-4 倍**：§2 的序列用了我沒選那一支的 severity。
  ★錯法：我在同一節裡算了三個分支，而結論句抽錯了其中一個的數 ——
  **三個分支各自的數字長得一模一樣，而只有一個是本票的。**
  ⇒ ★★處置：多分支對比的節裡，每一個數字旁邊要寫【它屬於哪一支】，
    且結論句要再寫一次它的來源。
```

---

## ★★★§10 訂正：§6 的兩條呈報有一條是我讀錯（D2 作廃），而真正的洞在第三條管道

```
~~D2 玩家的 demand_tribute 是隔空即時，而 NPC 那一側走訊息管道~~
★**兩半都錯。我自己開檔重核過：**
  ·NPC 側 diplomatic_ai_system.gd:138 `if other.tile_pos != self_team.tile_pos: continue`
    且那一行的註解逐字寫著「**invariant：外交／徵收需同格（嚴禁非同格互動）**」
    ⇒ **NPC 遠程外交不存在**；`_send_diplomacy_message` 也不是管道，它 :184 直呼即時解算。
  ·玩家側畫面路徑 player_command_system.gd:1024 `refresh_colocation_targets`
    對 `other.tile_pos != pt.tile_pos` 直接 continue ⇒ **畫面上也只能對同格**。
★★**我的錯法（兩條都是我 owner 的規則）**：
  ①我讀了被呼叫的那支（`_send_diplomacy_message`），用**函式名**推出「訊息管道」
    ⇒ 「綱要與签章都會說謊，只有函式體不會」—— 而我連函式體都沒讀到底。
  ②我沒去讀**呼叫端的候選過濾**（sender 迴圈）⇒ 「掛機制前先 grep 目標動作的呼叫點」。
  ⇒ ★★★**而它的危驗形狀是：我拿一條【鐵律被違反】的呈報去推一張票，
    而那條鐵律其實正被一行帶註解的 continue 執行著。**

★D1 成立，但主詞要改：它不是「遠程」索貢，是**同格**索貢谈成後零轉移
  （`handle_diplomacy_message` 的 demand_tribute 只回 accept／refuse（:218-222），
   而 `_send_diplomacy_message` accept 那一支（:186-200）**沒有任何 ResourceBank.add**）
  ⇒ 登 defer `npc-tribute-accepted-zero-transfer`。

★★★**而真正的洞在第三條管道（藍圖第三輪找到、我開檔確認）**：
  `execute_action`（:149-166）與 `_action_demand_tribute`（:309-331）**都沒有同格檢查**
  ⇒ 走 JSON／API 通道的 agent 可以對**任意隊**隔空索貢／提議。
  ⇒ ★一條不變量有兩處執法（NPC 側、玩家畫面側）而**第三条管道沒有**
    ⇒ 「缺陷躲在我們不走的管道」的教科書形狀。
  ⇒ 已開票：`docs/superpowers/specs/2026-09-30-colocation-check-belongs-in-the-handler-HOW.md`
    （**不在本票**；但它與本票同一條管道 ⇒ 先做它再做本票的 P2′，
     否則煞車床要在一個【能隔空索貢】的世界量數字）
```

---

## ★★★§11 訂正（R² 二輪抓到）：缺口② 是錯的 —— **好感已經在尺裏**，§9b⑤ 作廃

**審查質疑後我自己追到底，而追出來的是一條【正面】証據鍰（不再是負斷言）**：

```
state_fingerprint.gd:75  SUBFIELD_MAP 含 ["PersonData", "res://scripts/data/person_data.gd", "_emit_persons", ""]
state_fingerprint.gd:412 buf.append(_derived_line(p, "PD", "PersonData"))
state_fingerprint.gd:349 _derived_line() 迴圈 `for n in FpCoverage.fields_for(cls)`
fp_coverage.gd:119      fields_for() 回 d[cls]["in_ruler"]
fp_coverage.gd:99       in_ruler 的判準：`elif src.contains("." + n)` —— 模擬層非輸出行讀到就算
而 `relations` 在 npc_ai_system.gd:145 與 diplomatic_ai_system.gd:103 被讀（都不是輸出行）
⇒ ★**person.relations 已經進尺**。
```

```
⇒ §9b⑤「把 person.relations 接進 fingerprint」**作廃，不要做**。
★★而不做的理由不是「多餘」，是它會**弄壞尺**：
  手寫那一行用 `_dict_canon`、自動導出那一行用 `_canon_deep`
  ⇒ 同一個欄位在 fp 字串裏出現兩次、而且兩次格式不同 ⇒ **新風險，不是修復**。
⇒ §9a 缺口② 改寫：好感**不是新 state（就尺而言）**，它已經被盯著；
  ★但【fp 會變】仍然成立（值變了）⇒ P8 的「先量再換基準、同 commit」不變。
★★★而對實作端的指令：**動工前先印一次 `FpCoverage.fields_for("PersonData")`**，
  把 `relations` 在不在清單裏印到卷面上（一行輸出坐實一條推理鍰）。
  ★若它不在（推理鍰裡有我沒看到的一環）→ 回報，不要自己改回去加 tap。

## ★★§11b 我的錯法（第三件，與 §9e 同族）
【一個欄位有兩條進尺路徑】：每一支 `_emit_*` 的**手寫那一行**（給人讀的骸架）
＋`_derived_line` 的**機器維護全集**。★**我只查了手寫那一條**（grep `relations` 在
`state_fingerprint.gd` 裏只命中 :431 的 faction 那一行）就下了負斷言。
⇒ ★★**規矩：下【X 沒被收錄】的斷言之前，先數【這一類收錄有几套機制】**——
  而這個專案的習慣正好是【手寫骸架＋機器全集】雙跟並行（骸架的註解自己寫著這件事）。
⇒ ★★★而審查抓倒它的方法值得記：**他沒有再 grep 一次**（同方向的工具不會產生訊號），
  他去讀【分類器本體】。而我接手後把它從「很可能」推到【一條呼叫鍰】。

## ★★§11c §11 那條鍰的【誠實限】—— 撑結論的是直接讀取點，不是那條子字串規則

```
in_ruler 的判準是 `src.contains("." + n)` —— **子字串比對**
⇒ 欄位 `foo` 會因為某處寫 `.foo_cache` 而被算成進尺 ⇒ **它會多報**
⇒ ★同族（判準的粒度：「名字出現」≠「這個欄位被讀」）—— implementer 2026-09-30 指出
★★而對 `relations` 這一格【不影響結論】，因為我們有兩個**直接**的決策層讀取點：
  npc_ai_system.gd:145        float(p.relations.get(subject_id, 0.0))
  diplomatic_ai_system.gd:103 float(self_leader.relations.get(other_leader_id, 0.0))
⇒ ★★★**而這兩句要分開講**：「它在清單裏」與「它在清單裏的理由是直接讀取點」
  —— 否則下一個人會以為【子字串規則】本身可以當証據用。
★而這一點 `fp_coverage.gd` 的檔頭**自己已經宣告了**（誠實限①：
  「代理是【超集】：某欄可能被讀了卻對行為無影響 ⇒ 多守，不是錯守」）
  ⇒ ★★**這不是新缺陷，是工具已登記的特性** ⇒ 引用它方向安全時要連它的認証限一起引。
⇒ 動工時那一行 print 的卷面要同時寫兩句：
  【relations 在清單裏】＋【它在清單裏的理由是直接讀取點，不是子字串規則】
```
