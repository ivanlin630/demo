# HOW：同格檢查屬於 handler，不屬於畫面

**來源**：藍圖第三輪自核找到（`9b5504bc7`），systems 開檔確認。
**上游鐵律**：`diplomatic_ai_system.gd:138` 那一行的註解逐字寫著——
「**invariant：外交／徵收需同格（嚴禁非同格互動）→ 隔空求貢／提案違規**」

## ★★★§1 事実：這條不變量有兩處執法，而第三條管道沒有

```
執法① NPC 側：diplomatic_ai_system.gd:138  if other.tile_pos != self_team.tile_pos: continue
執法② 玩家畫面側：player_command_system.gd:1024 refresh_colocation_targets 同樣 continue
★無執法 第三條：execute_action(:149-166) 與 handler 本體（例 _action_demand_tribute:309-331）
   **都沒有**同格檢查、也沒有驗 target 在 state.player_pending_targets 裏
   ⇒ 走 JSON／API 通道的 agent 可對**任意隊**隔空索貢／提議／勒索
```

**★★而這不是「畫面守得不夠嚴」，是守在錯的層**：
畫面是一條管道，而不變量是世界的性質 ⇒ 守畫面等於
【只對我們自己走的那條路執法】，而缺陷從來躲在我們不走的管道。

## §2 做什麼

```
①同格檢查搬進 handler 層的**唯一咽喉**：`execute_action` 在派送前檢查
   ★而【哪些動詞需要同格】不得寫成一份手抄清單⇒ 要有單一來源：
     需要 target 的動詞（`execute_action_with_target` 與 target_id != -1 的那些）⊇ 需要同格
     ⇒ 實作先把【不需同格的例外】列出來（自家隊動作、choose_heir、ignore…）
       並在註解裏寫明例外的判準（不是列名單，是【為何不需】）
②拒絕句要是人話：「對方不在你的格上」，不是錯碼
③★畫面側那一處（:1024）**不拆**：它的工作是【選單要列誰】，不是執法
   ⇒ 兩者不同軸；而【選單列了却被 handler 拒絕】是一個床要看的矛皾（見 P3）
```

## §3 驗收

```
P1 直呼 API：execute_action(不同格的隊, "demand_tribute") ⇒ ok=false，訊息是人話
   ｜負對照：拿掉檢查 ⇒ ok=true 且對方 coin 真的減了 ⇒ 必紅
P2 同格的隊 ⇒ 行為完全不變（★這一格守【我沒把功能門死】）
P3 ★★**兩層不得矛皾**：畫面列出來的每一個 target 送進 handler 都必須過
   ⇒ 否則玩家會看到一個按不動的選項（比沒有選項更壞）
   ｜★★★而它的兩邊是【異源】：一邊是 :1024 的過濾、一邊是 handler 的檢查
     ⇒ 它們可以各自改而不影響對方 ⇒ **這是一個真比較，不是同一句話講兩次**
P4 全電池 BATTERY_RC=0
★母體地板：床要印出【需要同格的動詞有几個／例外有几個】，
  而且兩個數相加要等於【需要 target 的動詞總數】—— 否則分類法漏了一格。
```

## §4 不在本票
```
·D1（同格索貢谈成零轉移）—— 已登 defer，另票
·任何「遠程外交該不該存在」的設計問題（用戶／藍圖層）
```

---

## ★★★§5 判準訂正（2026-09-30，取代 §2① 的「例外清單」說法）

實作端提的判準：「若這道動作**指名了一支存在的別隊**，那支隊必須與玩家同格」
（實作上就是 `state.teams.get(target_id) != null`）—— **方向對，錨錯了。**

```
★它看的是【引數的值】，不是【動作的契約】：
  `execute_action(state, target_id, action)` 的 target_id 是一個 int，
  而自家隊動作**只是慣例上**傳 -1 —— 沒有任何東西強制它。
  ⇒ 走程式介面呼 `execute_action(state, 5, "hunt")`：`teams.get(5)` 非 null
    ⇒ **hunt 會被誤判成「對方不在你的格上」**。
★★而誤判的方向是【擋掉合法動作】，症狀是「某些自家隊動作偶爾莫名被拒」
  ⇒ **比原本那個洞更雾查**（洞是「多做了事」，誤判是「少做了事且沒有固定重现條件」）。
```

**訂正後的判準**：

```
閘的條件＝**action ∈ `get_available_actions` 回的團體目標動詞集合**（11 個）
而不是「teams.get(target_id) 非 null」。
★兩者的差別：前者由**動作的契約**導出（單一來源、不會漂），
  後者由**呼叫者傳了什麼**決定（agent 可以乂傳）。
★★實作端那句「例外不是一份會漂的清單，是一個結構事實」**仍然成立**，
  只是那個結構事實是【這個動作的 target 語意是別隊】，
  不是【這次傳進來的數字剛好對得上一支隊】。
★★★而母體地板要因此改：床要印出【隣級檢查的動詞集合】的成員數，
  且那個數要跟 `get_available_actions` 列得出來的數對得上。
```

~~**附：爆炸半徑收窄**：`execute_action_with_target` 吃 Dictionary ⇒ 本閘的爆炸半徑就是 `execute_action` 這一條。~~
★★★**這句是錯的（R² 2026-09-30 抓倒）—— 見 §7。**

## §6 attack 納入（量出來的數字決定）

```
量：走 execute_action(…,"attack") 的既有床 —— **1 支**
  headless_test.gd:4187（它隔空的原因在 :4131：fixture 把 Team1 放進
  player_pending_targets 卻【從沒有真的擺位置】）
  ·game_setup.gd:842 也走這條，但它是**產品碼不是床** ⇒ 不在「要修的床」裡
  ·headless_test.gd:14263 是 registry 覆蓋審計的**名單**不是呼叫 ⇒ 不計入
⇒ 1 ≤ 2 ⇒ **納入本票**，那支床同一顆 commit 改成同格（把 setup 挑成它自己宣稱的樣子）
★★而這裡有一件比結論更值得記：**「attack」這個字住在兩個母體裏**
  （走 `execute_action` 的 1 支 ／ `pending_action {"type":"attack"}` 的遭遇戰單位級 4 支）
  ⇒ 若按字串數會報 5 支並拆票 ⇒ ★**數的是同名的字，不是同一個機制**。
```

---

## ★★★§7 第三個管道：`recruit_named`（R² 抓倒我的負斷言，納入本票同一顆 commit）

**我在 §5 寫「`execute_action_with_target` 不在爆炸半徑內」—— 那是錯的。我開檔重核了**：

```
execute_action_with_target → "recruit_named" → _recruit_named_internal(state, pt, from_team_id, person_id)
  var tgt4: TeamData = state.teams.get(from_team_id)        ← from_team_id 來自 target dict（任意值）
  … ResourceBank.set_amt(pt,"coin", …)                     ← 玩家付錢
      ResourceBank.add(tgt4,"coin", RECRUIT_COST_NAMED, …)  ← 對方收錢
      state.remove_member(tgt4, person_id, false)            ← 人離原隊
      state.add_member(pt, person_id)                        ← 人入玩家隊
★**完全沒有同格檢查** ⇒ 走程式介面可以【隔空向任意隊買走一個記名成員】
  —— 而它**轉移人＋轉移 coin**，比隔空索貢更重。
```

### ★★我的錯法（今天第二次同族，而這一次更結構）

```
我用【哪一個入口】界定爆炸半徑，而不變量的母體是【哪些動作跟別隊發生作用】
⇒ ★**入口不是母體**。而 `execute_action_with_target` 吃 Dictionary 這件事是真的，
  它只是**與那個問題無關** —— 型別不同不代表它不跟別隊發生作用。
★★而今天第一次同族是【好感不在指紋裏】（只查手寫那一套收錄機制）
  ⇒ 兩次都是**我拿一個維度去代替母體**（一次是收錄機制、一次是入口）。
⇒ ★★★**規矩：下「某條路不在爆炸半徑內」前，要先把母體的定義寫出來**，
  而那個定義必須是【被守的性質】（跟別隊發生作用），不是【我審查的路徑】。
```

### §7a 裁：**納入本票**，不登 defer

```
R² 給了兩條路（納入／或至少在 defer 裡指名）⇒ 我裁**納入**。
理由：同一個洞、同一條不變量、同一張票 ⇒ 登 defer 等於
  **把一個已經有名字的活洞寫進表裏然後留著** —— 而表裏的名字不會堵住它。
做法：直接覆用 `_colocation_gate` 的邏輯，掛在 `_recruit_named_internal` 的入口
  （或 `execute_action_with_target` 的 `recruit_named` 那一支，位置由實作端選單一咽喉）
★驗收加一格：P6 【跨隊招募也需同格】
  直呼 API：不同格的隊 ⇒ ok=false 且 **人與 coin 兩邊都沒動**（逐欄印）
  ｜負對照：拿掉那一行 ⇒ 人真的被買走、coin 真的轉移 ⇒ **必紅**
  ★★而它要印【兩邊都沒動】不是只印 ok=false：
    這一條路有**四個寫入**（付錢／收錢／離隊／入隊）⇒ 半途擋下來比沒擋更糟。
```

### ★§7b 口徑統一（R² 發現床裡的「8」與他算的「10」對不上）

```
兩個數其實都對，只是分母不同 ⇒ **两個都要寫上分母**：
  ·需同格的動詞 ＝ **10**（`get_available_actions` 的 11 減掉2 個 early-return 的 `ignore`）
  ·**原本零檢查**的 ＝ **8**（10 減掉2 個已有檢查的 `invite_settle`／`beg`）
⇒ ★床裡那句要寫成「8／10 原本零檢查」而不是光寫 8。
★★而加入 `recruit_named` 之後分母也要动：它不在 `get_available_actions` 的集合裡
  （它走另一個入口）⇒ **閘的母體定義要從「動詞清單」改成「跟別隊發生作用的動作」**，
  並在卷面上把兩個入口各自的數分開印。
```

### §7c R² 提的其餘四件（已收，不需改設計）

```
①錯點確實錨在 `TEAM_TARGET_ACTIONS.has(action)` 第一行；`hunt` 不在清單裡
  ⇒ 連 `teams.get` 都不會執行到 ⇒ 我訂正的那個誤擋不成立（形狀對、結果被錨點擋下來）
②`computed-prop` 實際涵蓋 TeamData **全部 5 個**計算屬性（不只 `population`）
  ⇒ ★我那個「它只盯一個屬性」的擕心已被既有工具涵蓋 ⇒ **又一個我沒查就說的負斷言**
③`CONTROL_FLOOR_FEP` 確實是 10（取大的）
④P3 單向盲區 ＝ 合理範圍邊界（正反兩方向的失效模式本質不同）
```
