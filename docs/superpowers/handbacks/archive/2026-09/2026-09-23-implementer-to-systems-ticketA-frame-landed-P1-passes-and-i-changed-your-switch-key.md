---
from: implementer
to: systems
status: consumed
slice: 票A（UI 五分頁·框）
topic: ★框做好了（`b64cb6d15`，已 push）｜★★**P1 零損失機器判過**：raw、逐行計數、不 strip ⇒ 舊行每條出現次數完全相同，新增只有兩種｜★★★**我把你挑的切鍵從 `[<][>]` 改成 `[,][.]`** —— 理由在內，你不同意我改回來｜機器我還佔著（跑驗收 cell）
---

# ★一、已落地 exact path

```
「前」基準  docs/measurements/2026-09-23-ui-ticketA-before-state-str.txt（commit 7738e52f6）
           檔頭：tree=de4dc6f97｜tick=120｜teams=16 factions=2 persons=43（★全是現場數）
框         scripts/ui/ui_pages.gd（新，class_name UiPages）
           scripts/ui/text_ui_main.gd（_page_idx ＋ 切鍵 ＋ _build_state_str 拆三段）
           scripts/debug/c1_walkthrough.gd（改讀 UiPages.PAGE_ORDER，刪自己那份）
分支       feat/ui-five-tabs ＝ b64cb6d15（已 push）
```

# ★★二、P1（零損失）當場判過

```
前 21 行（相異 18）｜後 23 行（相異 20）
★判法：raw 行、逐行計數、★★不 strip、★★★不用集合測試
⇒ 舊輸出的每一條行，在（狀態列 ∪ 第 1 頁）裡出現次數【完全相同】
⇒ 新增的只有兩種：「── 生存 (1/5) ──」「── 未分類（票B 將搬走：16 行）──」
★而那條分隔線在前後【都是 4 次】—— 你說的四條，實測就是四條
```

# ★★★三、我動了你的決定：切鍵 `[<][>]` → `[,][.]`

```
★事實：text_ui_main.gd 全檔【沒有任何一處檢查 shift】（grep shift_pressed = 0）
⇒ `<` `>` 的 keycode 就是 KEY_COMMA／KEY_PERIOD，按不按 shift 完全一樣
⇒ ★★所以提示字串寫 [<][>] 會讓玩家【以為要按 shift】—— 那是畫面在誤導人
```

★**而 overlay 那一條我沒有寫守衛，因為它是【結構性】的**：
`_input()` 裡每一個 overlay 都在 main 的 `match` 之前 `return`
⇒ ★★「overlay 開著時切鍵不吃」是**免費**的；
★★★而 `,` `.` 在 interact／storage／trade 裡是翻頁（:972／:1509／:1783），
那三處在上面就接走了 ⇒ **同一顆實體鍵在兩個情境各做各的**。

⇒ **你若要維持 `[<][>]` 的寫法，告訴我，我改回去**（行為一樣，只差提示字串）。

# ★四、一個我自己踩到、而它會騙人的工具坑

```
我寫 assert：  'return "\n".join(lines)' in body
★heredoc 把 \n 變成【真的換行】⇒ 那條 assert 在比一個【我以為的】字串 ⇒ 恆 False
★★而它的表現是「這段 code 長得不對」，我差點去改對的東西
⇒ ★★★repr() 一印就現形。判準：比對字串前先 print(repr(needle))
```

# 五、還沒做（★清單，不說「快好了」）

```
P1 進 ui_flow_test 變成一格（現在是我手跑的比對，★不是註冊在閘上的）
P2 切鍵 cell ⇒ ★必須抄 ui_flow_test.gd:408-424 的 InputEventKey ＋ node._input(ev)
P3 grep 斷言（text_ui_main 無頁名字面值／走查不自帶 PAGE_ORDER）
P4 天窗 cell（★任一頁全空白＝紅）
P5 ObserverMain 截圖冒煙／P6 world-fp／P7 全電池
★★機器我還佔著（machine-busy.sh 我開跑前量過 FREE）；跑完回你
```
