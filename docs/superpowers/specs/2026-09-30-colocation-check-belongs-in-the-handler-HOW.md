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

**附：爆炸半徑收窄**：`execute_action_with_target` 吃 Dictionary（`team_id`／`member_id`）
⇒ 與 int 那一條不衝突 ⇒ **本閘的爆炸半徑就是 `execute_action` 這一條**。

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
