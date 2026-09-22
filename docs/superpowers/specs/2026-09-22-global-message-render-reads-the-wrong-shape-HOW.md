# 事件流渲染讀錯形狀（HOW spec）

**開票**：blueprint 2026-09-22（(乙) 拆出獨立票，不等那場尋找）
**狀態**：R² verdict=issues（不 halt）已收、一項裁死已寫回 §3-4 ⇒ **可派工**
**範圍**：`scripts/simulation/player_api_mapper.gd` 一支函式 ＋ 兩支床的餵料形狀
**不碰**：`feat/walkthrough-v2` 的診斷床（那是 (甲)，照原門票等用戶找完）

---

## §1 缺陷（file:line，兩邊都列出來比）

**世界寫進去的形狀**——5／5 個 production 寫入點，零個 Dictionary：

```
faction_ai_system.gd:2387  var msg := MessageData.new()   → :2394 append
faction_ai_system.gd:2495  var _msg := MessageData.new()  → :2502 append
faction_ai_system.gd:2528  var msg := MessageData.new()   → :2535 append
message_system.gd:42       var msg := MessageData.new()   → :61   append
order_system.gd:412        var msg := MessageData.new()   → :433  append
```

**讀取端**——四個讀取點，三個已經用 MessageData 欄位，**只有一個**假設 Dictionary：

```
ui/popup_layer.gd:76          var m: MessageData = msg as MessageData   ✓
simulation/message_system.gd:299  msg.type / msg.origin_tick            ✓
ui/observer_bridge.gd:63          msgs[start-1].origin_tick             ✓
simulation/player_api_mapper.gd:797                                      ★只有它
    msgs.append(m.get("description", str(m)) if m is Dictionary else str(m))
```

⇒ **全庫一致認為那條流是 MessageData，唯一不同意的是那支【面向玩家】的函式**
⇒ 玩家看到的事件清單，**每一則**都是 `<RefCounted#-922337…>`。

## §2 為什麼它一直是綠的（★這一格比修法本身重要）

```
debug/agent_verbs_c1_bed.gd:164        st.global_messages.append({ "description": "測試事件 A" })
debug/c1_info_reconciliation_bed.gd:168 st.global_messages.append({ "description": "E1" })
```

⇒ 兩支床餵的是**自己 append 的 Dictionary 字面量**
⇒ ★**【測具的形狀】與【世界寫進去的形狀】不同**
⇒ ★★它們 100% 覆蓋了一條 production **永遠不會走到**的分支
⇒ ★★★**只修 §1 而不修這裡，等於把同一個盲點留給下一個人。**

## §3 修法形狀（★不是改數值，是改接線）

1. `map_global_messages` 必須認得 `MessageData`：有 `description` 就用它；
   **沒有** `description` 時**說出它是哪一種事件**（`type`），★**不得退回印物件 id**。
2. `Dictionary` 分支**保留**（legacy／observer 另一條 channel 可能仍有），
   ★但它**不再是被測到的那一條**——見 4。
3. ★**血統**：`feat/walkthrough-v2` 上已有一版（`player_api_mapper.gd` 17+／1−）
   ⇒ **參考非基底**（那支分支另有門票，不得以它為 base）。
4. ★★**缺陷要變成對照**（blueprint 令；R² 2026-09-22 **裁死為單選**）：
   **必須把 `agent_verbs_c1_bed.gd:164` 與 `c1_info_reconciliation_bed.gd:168` 這兩支床
   本身的餵料改成真世界型別 `MessageData`**。
   ★**不接受**「新增一支餵 MessageData 的旁床、舊兩支維持 Dictionary 不動」。
   ★★理由（R² 寫的，不是偏好）：**這兩支床本身就是發現這個盲點的證物**。
     改它們＝**構造保證**（下次有人重構讀取端，舊床自動會測到）；
     新增旁床＝**清單保證**（舊兩支繼續綠著騙人，而它們仍然在鐵證目錄上）。
   ★★★R² 附帶條件：這兩支床除了 `global_messages.append` 那一行之外
     可能還在驗別的事 ⇒ **只換餵料的【形狀】，不動它們原本驗的那件事**；
     落地時順手核一下，確保覆蓋範圍沒被縮掉。

## §4 判準（expect 行自帶操作元）

床必須印出一行**自足**的判決行，同一行帶操作元，例如：

```
[GLOBALMSG] rendered=N  object_id_like=0  (N 則全部來自 MessageData)
```

★`object_id_like` ＝ 渲染結果裡命中 `RefCounted#` 或 `<Object#` 的則數。
★★**不要只釘「ALL PASS」橫幅**：那一句由共用旗標決定，某格中途死掉它照印。

## §5 陽性對照（★兩層）

```
① 先證明注射會致死：把 §3-1 的 MessageData 分支拿掉 ⇒ 新那一格必須【紅】，
   且紅的那一行要印出 object_id_like=N（N>0）——★不是只印 FAIL。
② 才用陰性結果下結論：還原後綠。
★★注射要打在【被判的那一格】上，不是打在它呼叫的 helper 裡。
```

## §6 不變量

```
・這是 production 檔 ⇒ 落地要走【merged result 上的整份電池】，不是分支自檢。
・零 sim 影響：它只在 observer／player 讀取路徑上，不寫任何世界狀態
  ⇒ ★世界指紋不該變。★★而「不該變」要由電池的指紋那一格證明，不是由我宣稱。
・全量暫態可觀測性：本票不新增 decision／resource／state ⇒ 無新 tap 義務。
```

## §7 誠實限

```
★～CLOSED 2026-09-22～本票只掃了 global_messages 這一條流的讀取點（舊文留存）。
  ★★**已關**：implementer 排隊等電池時把 `observer_messages` 那條 channel 掃完了（純讀）：
  寫入端 1 個（`message_system.gd:76` → `MessageData.new()`，同型別）；
  讀取端全部走 MessageData 欄位，零個假設 Dictionary。
  ★★★而面向人的那一支（`observer_event_text.gd`）**比本票改的那一支更強**：
  静態型別寫在**簽章上**（`msg: MessageData`）⇒ 餵 Dictionary 會**執行期錯**，
  不會靜靜印出物件 id；預設分支也是 `_: return msg.description`。
  ★systems 抽驗過（不照收）：簽章確實是 MessageData、`is Dictionary`/`.get("description"` 零命中、
  `observer_messages` 裸掃 14 個命中（與他報的數字一致）、預設分支逐行看過。
  ★★他自註的證偽條件保留：若有人拿 `consume_messages` 回來的串丟給第三支 formatter，
  而那支檔裡不出現 `observer_messages` 這個字 ⇒ 這個掃法會漏（他用呼叫點覆蓋了一層）。
★★「5／5 寫入點都是 MessageData」是【現在】的事實；它不保證以後沒有人 append Dictionary
  ⇒ 這正是保留 Dictionary 分支的理由，也是為什麼床要餵【真型別】而不是兩種都餵。
```
