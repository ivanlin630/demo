# HOW：玩家介面 ＝ 終端 REPL（骨架：開場／推進／互動）

- **WHAT 權威**：用戶裁（2026-10-01 第三輪玩測）＋`docs/mechanism-intents.md`「玩家 UI 形式」那一列
  ｜方向票 `docs/superpowers/handbacks/2026-10-01-blueprint-to-systems-DIRECTION-player-ui-becomes-a-terminal-repl.md`（`97c9f5ebb`）
- **用戶逐字**：「新版UI更爛 爛到沒救 改用終端形式的文字UI 你們自己抓排版 重複選項等問題」
- **HOW owner**：systems｜**序**：優先於票 #2 步驟 1 與第二母體剩餘
- **基準樹**：`b097ac2ac`（★以下每個 `file:line` 都在這棵樹上開檔讀過）

---

## §1 ★三件「先查」已經查完了，而答案讓這張票比它聽起來便宜

```
①**Windows 的 stdin：不必再查，既有 code 已經答過** ——
   `scripts/debug/agent_repl.gd:5-7` 逐字「TCP fallback state (Windows — pipe://stdin unavailable)」
   `:13` 先試 `FileAccess.open("pipe://stdin")`、`:41-45` 失敗就起 `TCPServer`
   ⇒ ★**同一個探測-退路形狀直接沿用**（不要重新發明，也不要重新調查）。
②**畫面產生器已經是「回一個字串」的形狀** ——
   `scripts/ui/text_ui_view.gd:269` `static func compose(regions: Dictionary) -> String`
   而 `scripts/ui/text_ui_main.gd:812` 就是 `_screen_label.text = TextUiView.compose({...})`
   ⇒ ★★所以「可搬的只有區塊產生器那層」**已經成立**：REPL 只要湊出那個 `regions` 字典、
     `print(compose(...))` 就是整個畫面 ⇒ **Label／.tscn 那層不必搬，直接不碰**。
③**寬度與全形**：`compose` 的各 block 函式自己排版 ⇒ 寬度上限要**進那一層**，
   而中文全形算 2 欄（★既有 `text_ui_layout_bed` 有手抄物理那一道 P9 的教訓 ⇒ 寬度計算
   **不要在床裡手抄一份**，要呼產品那支）。
```

## §2 做什麼（骨架三件，照序）

```
①`scripts/debug/player_repl.gd`（新，債務最小的位置：它是一支可執行腳本不是場景）
   ·transport ＝ ①的探測-退路（stdin 不可用 ⇒ TCP）
   ·迴圈：讀一行 → 轉成一個「鍵」→ 呼既有的 `sim_bridge`／`text_ui_main` 那條指令路徑
     → **重印整個畫面**（`print(TextUiView.compose(regions))`）
   ·★**逐行輸入**（按 Enter），逐鍵（raw mode）列待辦不做
②`regions` 的來源：**不要新寫一份** —— `text_ui_main.gd:812` 那個字典就是權威
   ⇒ ★把它抽成一支**可被兩邊呼的函式**（UI 節點與 REPL 各呼一次）
   ⇒ ★★判準：**抽完之後那個字典只准有一處組裝**（否則兩個畫面會漂開，而那是今天這張票的病因之一）
   ⇒ ★★★**而 Label 那一層已經是可以繞過的**（我開檔核過，這是本票最便宜的那一刀）：
     那三個 Label 的內容**全都來自回字串的 builder** ——
     `:740 _state_label.text = _build_state_str()`／
     `:744-756 _event_label.text = _build_*_str()`（十二個子模式面板各一支）
     ⇒ **Label 只是載體**（與今天「六個 Label ＝ 內容載體」那件事同一個形狀）
     ⇒ 所以 `regions.map`／`regions.pages`／`regions.panel` 可以**直接吃 builder 的回傳值**，
       ★**不必實例化任何 Label、不必起場景樹** ⇒ REPL 與床都能呼同一條。
③指令表：數字選項／`x` 一小時／空白一天／`t` 互動／`1`-`5` 分頁／`q` 離開
   ⇒ ★**印出的鍵與接受的鍵同源**：鍵表與 dispatch 必須讀**同一份宣告**
     （形狀沿用已核過 CLEAN 的 `ACTION_DIGITS`／`PANE_TOGGLE_KEY`：宣告在一處 ＋ 反向掃）
```

## §3 自驗（★用戶那六條，逐條落成機械斷言；任一紅 ＝ 不可交玩）

```
a 區塊齊全且順序固定      ⇒ 斷言 compose 的輸出含那幾個區塊標記、且**索引遞增**
b ★**無重複選項標籤**      ⇒ 同一畫面同一標籤只准出現一次（見 §4 的陽性對照）
c 印出的鍵 ＝ 接受的鍵    ⇒ **雙向**：印出的每個鍵都被接受／被接受的每個鍵都印得出來
d 無英文識別字            ⇒ 沿用既有 (d) 規則（`scripted_exploration_bed` 那一條）
e 每行 ≤ 寬度上限、無空白區塊 ⇒ 寬度用**產品那支**算（不要手抄全形表）
f 同一狀態重印兩次逐字相同 ⇒ 確定性（★它也是「畫面第一次可被 diff」的那一半）
★★而這六條要跑在**一組腳本化走法**上（開場／`t` 互動／招募展開／強制事件到達／遭遇戰／分頁切換）
⇒ **輸出落檔成人可讀卷面**，交玩時附給用戶（★他要看什麼，我們先看過）。
```

## §4 ★★★第一個陽性對照：用戶說的「重複選項」—— 我在 code 裡找到一個**具名假設**

```
`text_ui_main.gd:812` 那個字典的註解**自己就寫著這個危險**（逐字）：
  「★而它只在【子模式中】非空：主畫面時 `_event_label` 載的是事件 log，
    而那一份已經有替代品（`feed` 區吃 `_feed_rows`）⇒ **主畫面不傳（否則印兩份）**」
而 `compose`（`text_ui_view.gd:272`）的結構是：
  `panel` 非空 ⇒ **取代** map+pages 那一框；而 `action_block(regions.action)` **照樣印**
而 `:807-808`：`if _interact_mode and _interact_target >= 0: rows = _interact_action_split()["team"]`
⇒ ★**假設（未經量測，要被證實或推翻）**：在互動子模式裡，**同一批選項被印兩次** ——
  一次在 `panel`（`_event_label` 載的那 12 個子模式面板之一），一次在 `action_block`。
⇒ ★★處置：**先重現再寫斷言**（用戶那句話是現象，不是診斷）
  ⇒ 已把這個**具名假設**交給量測員（含 file:line），要他**證實或推翻**，並把那一屏的**原文貼回來**。
⇒ ★★★而不管假設對不對，(b) 那條斷言都要做 —— 它守的是**類別**，不是這一個實例。

★★★★而我後來又找到**結構上的第二條線**（同一個假設更硬的版本）：
`:748 _event_label.text = _build_interact_str()`（panel 那一側）
與 `:807-808 rows = _interact_action_split()["team"]`（action 那一側）
**兩者都從同一份互動動作清單導出** ⇒ ★結構上它們**本來就會印同一批東西**
⇒ 量測員要確認的只剩「**印出來的字是否真的逐字重複**」（而不是「有沒有這個可能」）。
```

## §5 不在本票

```
✘ 逐鍵（raw mode）輸入 —— 列待辦
✘ 資料層任何改動（五分頁內容／指令佇列／按鍵三態／地圖記憶／事件流／強制事件生命週期）
✘ `TextUI.tscn`／六個 Label 的整理 —— ★**停止投資 ≠ 現在拆**（拆它會動到床的母體）
✘ 票 #2 步驟 1（拿掉 game_over 的 early return）—— 但★票 #2 **步驟 0**（印「故事已結束」）
  併進終端畫面的狀態列（方向票明文允許）
```
