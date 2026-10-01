---
from: implementer
to: systems
status: consumed
slice: 兩屏各自獨佔鍵空間與頁計數（不變量 #10 那一刀）
topic: ★裁定四件全做、七支床全綠（ui_flow 75／75・available_actions 17／17・colocation 8／8・layout 10／10・press 5／5・unbound_key 8／8・headless HARD-FAILS 3＝baseline 3）｜★★而 Tab 卡過一次：**加一個新鍵要同時加在【宣告】與【handler】兩處**｜★★★兩件我【沒有自己決定】要你裁：UI 的 self 清單是 10 不是 11／藍圖要的第二屏標題與那一屏的內容對不上
---

# 一、★★兩件我沒有自己決定的（這是本信需要你動作的部分）

```
①【UI 的 self 清單是 10 列，而 ACTION_SHAPE 的 `listed` 是 11】
   `scripts/ui/text_ui_main.gd:1841` 逐字：`if aid == "move_to" or aid == "cancel_move": continue`
   ⇒ UI 自己又濾掉 `cancel_move`（`move_to` 是 tile 本來就不在這一類）
   ⇒ ★那兩個數不相等是**既有行為**，本票沒動它
   ⇒ ★★但它正是「同一件事兩個母體」的下一個候選：`listed` 說 11、畫面說 10
     ⇒ 要嘛 `cancel_move` 的 `listed` 改成 false（宣告跟上畫面），
       要嘛 UI 那一行拿掉（畫面跟上宣告）—— 而後者會讓畫面多一列
   ⇒ 我不自己選：它是「玩家那一屏有什麼」⇒ 呈現決定。

②【藍圖要的第二屏標題「對 TeamX（游標）」與那一屏的內容對不上】
   那一屏列的是**多支**可互動目標（`pending_targets`），不是單一游標隊
   ⇒ 印「對 TeamX」需要先有「游標指著誰」這個概念進到那一屏
   ⇒ ★我**沒有**改成他那句（改了會變成一句對不上內容的標題 ＝ 畫面對玩家說謊的另一種）
   ⇒ 現在印的是「── 可互動目標 ◀ 數字鍵在這一側 ──」／「（按 [Tab] 切過來）」
   ⇒ 兩條路：標題保持現狀／那一屏的內容改成「對游標那一隊」（而後者是 (丙-2) 的形狀）
```

# 二、裁定四件（全做）

```
①刪掉偏移：`text_ui_main.gd` 的 `num - self_acts.size()` **已刪**
   ★血證就地留著：那個偏移在 self 長度會漂的世界裡 ＝「鍵意義由一個會變的計數決定」
   ＝ #10 的本體；而第二母體把 self 釘成常數之後，舊的違反消失而同一個算式變成「擠爆」。
②兩屏各自獨佔 1..9 **與各自的頁計數**：新 `_self_page`／`_target_page`
   ★床斷言「兩側的頁沒有被連動」（實測 1／0）
③切換鍵 ＝ `PANE_TOGGLE_KEY`（＝ `KEY_TAB`，宣告在一處；你說的「暫定就是終值」）
④不夠用就翻頁（`,` `.`）；★而「翻頁為什麼不違反 #10」寫進檔頭：
   頁是**玩家自己按的** ⇒ #10 的推論允許它當判別子；字母不得用（被強制回應獨佔）。
```

# 三、★★★Tab 卡過一次 —— 判準

```
我把切換寫在 handler 裡，而 `_handle_interact_mode` 頂端那個守衛
（`if not _interact_mode_binds_key(keycode): _refuse_unbound_key(...); return`）
**先把 Tab 當未綁定鍵吃掉** ⇒ 切換根本到不了我寫的那一段
⇒ ★症狀是「切換鍵沒有反應」而 code 看起來完全正確
⇒ ★★判準：**加一個新鍵要同時加在【宣告】與【handler】兩處**
   —— 只加 handler 那一半會被頂端守衛吃掉，而那個吃掉是**靜默的**（它只印一句話）
⇒ ★★★這是今天那條「一件事被拆成幾個獨立動作而只做了其中幾個」的按鍵版
```

# 四、三條舊斷言的處置（★改過標題的兩版都貼出來）

```
①舊：「距離太近時 camp **不列**（N-3 gate）」
  新：「★★★距離太近時 camp **仍然列出**（舊斷言寫的是它消失 ＝ 把 (乙) 的病當預期）」
     ＋「★★而它 `enabled==false`」＋「★★★★而它的原因**非空**」
  ⇒ ★改標題等於換了它在守什麼：舊的守「它消失」，新的守「它在、它不能、它說得出為什麼」
②目標分頁那一格：標題不變，加兩條母體地板（預設在 self 側／兩側的頁沒有被連動）
③舊：「★KEY_1 做的是自家隊動作（結果句有「行動：」前綴）」
  新：「★KEY_%d 做的是自家隊動作（…）」（%d ＝ 第一個可做的位置，實測 **3**）
  ⇒ 理由：self 清單常駐且排序固定之後，第 1 列不再保證可做
    （實測第一頁 ＝ `camp(不可)／confirm_gather_intel(不可)／establish_faction／…`）
  ⇒ ★不是弱化：它驗的仍是「數字鍵打在自家隊那一側」，只是不再假設「位置 1 一定可做」
```

# 五、數字

```
ui_flow 75／75｜available_actions 17／17｜colocation_gate 8／8｜text_ui_layout 10／10
press_is_one_tick 5／5｜unbound_key 8／8（★異源比對 0 處不一致）
headless HARD-FAILS 3 ＝ baseline 3（無回歸）
commit：b9c80596e（未推）
```

# 六、下一站

退場票（`docs/superpowers/specs/2026-10-01-direct-trade-shortcut-retires-HOW.md`）。
★我會先 `git show origin/main:<spec>` 讀真本對帳；床的常數（54→53／51→50／30→29／第三桶 1→0／expect）**先跑再逐字抄**，不憑預測。
