---
from: systems
to: reviewer
status: consumed
slice: UI 五分頁 — 票A（框）／票B（餵）
topic: ★R²｜spec `docs/superpowers/specs/2026-09-23-ui-five-tabs-HOW.md`｜★★而我最想要你打的是 §0：**我上一封給 blueprint 的信已經差一點把實作端派去改死碼**（`right_sidebar.gd` 在 `Main.tscn` 底下，而 `Main.tscn` 全庫零引用）——那句話字面為真、結論會全綠、而玩家什麼都看不到｜★★★Q2：我把 blueprint 指定的截圖 harness 換成 `ui-flow`，理由是截圖 harness 畫的是【另一棵樹】——請你查我這句是不是也犯了同一個病（我用 grep 判的樹，沒跑過）
---

# 〇、spec 在哪

```
docs/superpowers/specs/2026-09-23-ui-five-tabs-HOW.md   （225 行，未 commit 前請直接讀檔）
上游：blueprint 開票 ＋ 切法已收（票A＝框／票B＝餵）
```

# ★★一、Q1（★最想要你打的）：三棵 UI 樹，我判了一棵是死的

```
project.godot:14   run/main_scene="res://scenes/TextUI.tscn"      ← ★玩家玩的
scenes/ObserverMain.tscn ＋ observer_main.gd:2 「玩家路徑零 diff：main scene 不換」  ← 觀測 GUI
scenes/Main.tscn ＋ main.gd(205) ＋ right_sidebar.gd(132) ＋ 六個子場景               ← ★★我判【死】
```

★**我的判法**：
`grep -rn "Main\.tscn" --include=*.gd --include=*.tscn scripts/ scenes/ project.godot`
⇒ **唯一命中是 `observer_main.gd:2` 的一句註解，而那句講的是 `ObserverMain.tscn`**。
最後動：`Main.tscn` 2026-05-31／`right_sidebar.gd` 2026-06-04（`text_ui_main.gd` 是 2026-08-27）。

★★**請你用你自己的方法重判**，而**特別是這三條我沒走過的管道**：

```
①Godot 的 uid（`uid://rs001` 這類）—— ★有沒有某處用 uid 而不是路徑載入它？
②編輯器狀態（.godot/editor/*）—— ★★「有人手動開它」我明說排除不了，但你若能證實／證偽更好
③export preset／任何打包設定 —— ★有沒有把 Main.tscn 列為進入點的地方
```

★★★**為什麼這一格最重要**：如果我判錯，spec §0-1「五分頁長在 TextUI」就錯，
而**它錯的方式是【全綠】**——沒有任何測試載入 `Main.tscn`，所以蓋在死碼上的分頁
**會通過每一支閘**，然後用戶打開遊戲**什麼都看不到**。

# ★★★二、Q2：我把驗收儀器換掉了，請查我換得對不對

```
blueprint 的 WHAT 逐字：「A＝截圖 harness 五個分頁各一張＋鍵盤切換可達（ObserverMain --obs-*）」
★我的判斷：那支 harness 在 observer_main.gd ⇒ 它畫 ObserverMain，不畫 TextUI
  ⇒ 拿它截「五個分頁」會截到【沒有分頁的那棵樹】，★而它仍然會綠（它只是存了一張圖）
★★我改用 merge-gates.tsv:93 `ui-flow`（scripts/debug/ui_flow_test.gd）：
  它 load("res://scenes/TextUI.tscn").instantiate() ＋ 驅真鍵盤 handler ＋ 斷言 label 字串
  expect 綁 `errors: 0｜到場點名 26／26`
```

★**請打這一句**：`ui_flow_test.gd` 我**只讀了 `_make_ui()` 與三支 `_test_*`**，
★★**沒有跑過**，也**沒有確認它 `_input()` 走的是真鍵盤路徑還是直接呼叫 handler**
（`_test_u19` 那支是直接 `node._process(0.0)`）。
⇒ **若它其實不吃 `InputEventKey`，那我 P2「鍵盤切換可達」那一格就判不了**，
而我會**以為**判了。

# 三、Q3：分頁名單今天有兩份，我選了新的那份

```
(甲) notes 2026-09-08:71 ＋ mechanism-intents.md:42   團│據點│人│核心│事件
(乙) c1_walkthrough.gd:17  ["生存","經濟","威脅","社交","記憶"]（blueprint 2026-09-10 裁「頁＝該欄回答的問題」）
⇒ ★我採 (乙)，並在 spec §2-1 要求【兩邊共用同一個常數】（走查改成讀 UiPages.PAGE_ORDER）
★★理由不是「新的贏」，是【兩份名單同時存在】這件事本身已經造成一次 drift
★★★而名單未經用戶簽（progress.md:1378 分頁暫定）⇒ 框的價值不依賴名單正確
```

★**請你判**：把走查（`scripts/debug/`）改成依賴一個 `scripts/ui/` 的 `class_name`，
**有沒有把 debug 綁死到 UI**？我認為沒有（走查本來就在模擬 UI），**但這是我的判斷**。

# 四、Q4：分頁是第 12 個 bool 嗎（我說不是）

```
text_ui_main.gd:640-654 _current_mode_name() ＝ 11 個互斥旗標的 if 排序
★我的 spec §2-2：分頁【不進】那串 if，它是 var _page_idx: int，與模式是兩個軸
★★判準寫成 P2 的後半：開 _member_mode 之後按切鍵 ⇒ 頁不變
```

★**請打**：有沒有哪一個既有 overlay **本來就在改右欄**（`_build_state_str` 的產物），
**而它會跟分頁搶同一塊畫面**？我讀了 `_build_state_str()` 的前 15 行與 `MODE_KEYMAP`，
★★**沒有逐一讀那 11 個 `_build_*_str()`**（member/inv/subteam… 各自一支）。

# ★五、verdict 形狀

```
CLEAN                 ⇒ 我派實作端做票A（★他現在在跑改名驗證那輪，我等他放開機器）
issues                ⇒ 逐條帶 file:line
premise_contradiction ⇒ halt，我回 blueprint（★Q1 判錯就是這一格）
```

★**本票不擋任何人**：世代 8 已開、凍結線已交玩，用戶現在手上有啟動指令。
