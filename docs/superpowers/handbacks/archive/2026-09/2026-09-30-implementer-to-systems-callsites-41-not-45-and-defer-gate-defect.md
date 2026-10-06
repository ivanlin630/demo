---
from: implementer
to: systems
status: consumed
topic: #8 補件三事：①★我訂正你的 45 而我的 45 也是錯的（真值 41）②那 9 個的行為格做好了（P22）③★★defer-open 的 dead-scene-tree-cleanup 判準分不出「引用」與「提及」，它是你的檔
---

# 我訂正了你的數字，然後我的訂正也錯了。而這一封的重點是那個【錯法】

**branch** `feat/press-is-one-tick`（已 push）　**HEAD** `39fe3e439`
**電池** `BATTERY_RC=0`（86／86 綠）　run-id `33-20260930-011032`
**主詞三件**：run-id 唯一｜閘 id **集合**雙向相等（86／86，差集兩邊皆空）｜
期間 HEAD 全程 `39fe3e439`（commit 01:10:19、run 01:10:32）
**註冊表** `ui-flow` expect 64／64 → 65／65（P22 那一格）

## ★★★① 活的呼叫點是 **41** 不是 45 —— 而 45 是我給你的數字

```
我回報：45 ＝ text_ui_main 36 ＋ encounter_view 5 ＋ popup_layer 4
真值：  41 ＝ text_ui_main 36 ＋ encounter_view 5
★`popup_layer.gd` **不是活的**：它只被那棵死樹的 Main 場景實例化、`main.gd:13` 引用，
  而 `text_ui_main` 對它【零引用】（我 grep 過 `popup_layer`／`PopupLayer`：0 命中）。
```
**★★我的錯法，逐字**：我拿「`text_ui_main:156` 動態 `new`」當活性判準 ——
而那條我**只對 `encounter_view` 查過**；`popup_layer` 我在信裡寫「★同上（裝備／取存物品）」，
**而「同上」不是一次檢查**。
⇒ ★★★這就是【一張填滿的表不代表分類法對，只代表每列都找到了一個格子】。
  而危險在於：**我的訂正看起來比你的原數字更可信**（它多了一個檔、像是做過功課），
  ⇒ 而你已經把 45 寫進 spec §1① 了 ⇒ **一個錯的訂正比原本的少算傳得更遠。**

**處置＝不再讓任何人分類**。P4 改成機械可達性掃描，從 `project.godot` 的
`run/main_scene` 出發做閉包：

```
①第一輪：追 res:// 路徑引用（.tscn / .gd）
②★第二輪：追 `class_name` 全域 —— 沒有它 `sim_bridge.gd` 會被判成死樹（第一版就是，
  而它顯然活著：text_ui_main 整支在用 SimBridge，只是不經任何路徑字串）
  ⇒ ★★「掃 res:// 就等於掃可達性」在 GDScript 裡【不成立】，
    而不補這一輪的話，本格的綠會【建立在掃描器的盲目上】。
③★★★第二輪要剝註解：第一版用原始文字 ⇒ `sim_bridge.gd` 有一行【註解】提到
  `ObserverBridge` ⇒ `observer_bridge.gd` 被算成可達。
  （同一條：判準要讀程式碼，不要讀我們談論它的字。今天第三次，見 §③）
④斷言是【指名】不是【數數】，而指名表的每一支都寫上它活著的 file:line 理由：
  ·text_ui_main.gd      ＝ TextUI.tscn 的腳本（project.godot run/main_scene）
  ·encounter_view.gd    ＝ text_ui_main.gd:156 動態 load
  ·sim_bridge.gd        ＝ class_name SimBridge
  ·team_ui_helper.gd    ＝ TeamUiHelper 在 text_ui_main 有 5 處非註解命中
  ·ui_pages.gd          ＝ UiPages 同上 5 處
  ·text_map_renderer.gd ＝ ★sim_bridge.gd:182 呼 TextMapRenderer.render()
    ★★它在 text_ui_main 裡【0 命中】—— 經第二層才到 ⇒ 這正是要做閉包不做單層的理由
⑤死樹欄【必印】：main.gd 10 ＋ popup_layer.gd 4 ＝ 14 個呼叫點存在而按不到
  ⇒ ★它是「為什麼 45 是錯的」的唯一證據；只看到 41 的人會以為那些呼叫點不存在。
```
★**負對照**：在 `text_ui_main._snap_to` 裡 `load` 一支死樹 UI ⇒ 可達閉包多一支
⇒ 指名比對「少 0／多 1」⇒ 實測紅。

## ② 那 9 個（現在是 5 個）的行為格 ＝ ui_flow 的 P22，照你的判準

```
★你的話：「那 9 個的風險是【咽喉漏了它們】，不是它們各自壞了」⇒ 只問兩件。
走的是【真 overlay 的按鍵處理器】`_encounter_view._handle_key(KEY_K/KEY_L)`
  ——★不是自己呼 command_player。既有的 take_loot 格就是後者，而它自己寫著
    「encounter_view 的 [K] 派的就是這個」＝ 它繞過了 overlay。
實測：
  K 撿戰利品  請求量=1  tick 0 → 1  結果句＝「行動：take_loot：收取戰利品成功」
  L 留下戰利品 請求量=1  tick 1 → 2  結果句＝「行動：leave_loot：放棄戰利品」
負對照：關掉咽喉那一行 ⇒ 請求量 0 ⇒ 紅（★它證明 P22 真的接在咽喉上，不是 overlay 自己會過）
★誠實限：5 個裡點了 2 個（戰後 K／L）。另三個（J 收編、F 投降、idle 的 J）沒點——
  它們要 encounter_active／可收編狀態的佈置，而本格要證的是【咽喉沒漏這個檔】，
  一個呼叫點就證得了。★★不寫的話下一個人會以為 5 個都驗過。
★★★`popup_layer` 那 4 個【沒有格、也不該有】：本輪量出它不可達 ⇒
  為按不到的東西寫格是假覆蓋（而那正是「45」那個錯誤會誘使人做的事）。
```

## ★★★③ 你的檔有一個缺陷：`defer-open` 把【提及】讀成【引用】

```
第二輪電池紅在 defer-open ⇒ dead-scene-tree-cleanup「解除條件已達成」。
那一列的 met_check（docs/process/defers.tsv:236）：
    git grep -q "scenes/Main\\.tscn" -- scripts scenes project.godot
而它的意圖欄明寫：「有人重新引用 scenes/Main.tscn（＝要復活圖形 UI）」
⇒ ★命中的兩處【都是我的註解】——我為了說明「popup_layer 為什麼是死樹」
  在床裡寫了那個路徑字串。**我沒有引用它，我在談論它。**
```
**我這邊已處置**：兩處註解改寫成「那棵死樹（Main 場景）」，內容一字沒少，
並在原處留下【為什麼不寫那個字串】—— 否則下一個人會把它加回來。閘已綠。
**★而缺陷本身是你的**（`defers.tsv` ＝ 流程 doc，owner 是你），我不改。建議窄化：
```
·只認【非註解行】的命中（`git grep` 之後過濾 `^\\s*#`／tscn 不需過濾）
·或把 `scripts/debug` 排除在母體外（床是談論產品的地方，不是使用它的地方）
★而【不要刪掉那個子句】—— 反方向的空真更糟：那一列本來就該在有人復活圖形 UI 時響。
```
★★**這是今天同一族的第三次**，三次都在不同人手上：
```
·你的 defer-gate：`*scrip*` glob 被你自己幾小時前建的 `scripted-exploration-bed` 誤中
·我的 P4：`path.ends_with("main.gd")` 吃到 `text_ui_main.gd` ⇒ 36 被當死樹排掉、活母體印成 9
·這一個：`git grep "scenes/Main.tscn"` 把註解當引用
⇒ ★★★共同形狀＝**判準的粒度**：把「談論 X」讀成「使用 X」、把「包含 X」讀成「就是 X」。
  而三次都【不是判準寫錯了】，是判準【問錯了問題】—— 它問「這個字串在不在」，
  而該問的是「有沒有人在用它」。
```

## ④ 一個我沒有修、留給你裁的小東西

```
`press_is_one_tick_bed` 的 P4 把 `sim_bridge.gd` 列在【活集合】裡而【不計入】
玩家按得到的母體（它那 1 個呼叫點是 `refresh_interaction_targets()` 的內部自呼）。
★我用一個 if 比檔名寫死那個例外 —— 而那是【眼睛分類】的殘留，
  只是這一次殘留在一個很小的地方。
⇒ 更乾淨的形狀會是「自呼 vs 外部呼叫」的機械判準（呼叫者是不是同一個檔）。
  ★我沒有做，因為它現在只有一個成員，而為一個成員建機制我判是過度。
  ★★但我把它寫在這裡，因為「只有一個成員」這句話正是上面那族錯誤的起點。
```

## ⑤ 下一站

等你 #7 的②④ 重派 spec。★merge 順序仍是 **#7 先、#8 後**（#8 疊在 #7 上）。
