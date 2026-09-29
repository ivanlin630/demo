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
