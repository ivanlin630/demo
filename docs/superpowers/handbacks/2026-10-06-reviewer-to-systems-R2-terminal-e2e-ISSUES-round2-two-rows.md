---
from: reviewer
to: systems
status: open
slice: 終端 E2E 床（狀態驅動）＋輕路資格
topic: R② 第二輪（`d1c800250`）＝ **ISSUES，兩列**（(c) 完全沒問題，核對正確）｜(d) 的結構判準字面對但機械檢查有洞：`git grep -L "advance_tick("` 不濾註解，而 `text_ui_main.gd:246` 自己有一句【提及】`advance_tick()` 的註解 ⇒ 這支判準今天會把**輕路最主要的目標檔**永久判失格｜★你多推的那句（belief 要進快照）方向對但差一步：**不必新加欄位**，`player_query_api.gd:51 query_memory_panel()` 已經是現成的唯讀零RNG belief 讀口（「打聽寫進去的東西，玩家要看得見」原話）——E2E 的 diff 接它就夠，不要在 `map_player_snapshot` 開第二個 belief 入口
---

# 0 審了哪棵樹／推送核對

`origin/main` ＝ `d1c800250`；`git log --oneline -3` ＝ `d1c800250`／`9511b7dd4`／`5e14b6565`，沒有夾帶別人未預期的 commit，你的事後核對我重做了一次，結論一致。

# 1 (c) 核對 —— 沒問題

```
§1① 新文字：數字鍵 action_block（text_ui_view.gd:328）／字母鍵 強制事件（text_ui_main.gd:2086-2090）
   兩個引用都對，且明寫「(ii) 正是 §0 血證的鍵位空間」。
P1 新增：分鍵位空間印、字母鍵 ≥1、等不到就佈置 —— 結構完整，陽性對照（佈置）與母體地板（≥1）都有了。
```

# 2 (d) ★結構判準字面對，機械檢查有洞 —— 會把輕路最想覆蓋的那支檔案判死

## 證據

```
原文：「diff 的每一個檔都不含 advance_tick(／advance_ticks( 的非註解呼叫（git grep -L 判）」
★「非註解」是 prose 裡的字，`git grep -L` 這個動作本身不濾註解：
  git grep -l "advance_tick(" -- scripts/ui/text_ui_main.gd   ⇒ 命中
  text_ui_main.gd:246  #     【字面上不成立】：全庫有兩百多支 debug 床直呼 `runner.advance_tick()` …
  ⇒ 這一行是**註解**（在講別的事：反駁一個關於 debug 床的字面主張），
    text_ui_main.gd 本身**沒有**任何一處真的呼叫 `.advance_tick(`（我在上一輪已窮舉過，
    真正呼叫的只有 sim_bridge.gd／observer_bridge.gd／turn_controls.gd 三支，text_ui_main.gd 不在內）
  ⇒ 但 `git grep -L` 判出來的結果是「text_ui_main.gd 含有這個字串」⇒ **永遠不合格**
```

## 為什麼這條特別貴

```
text_ui_main.gd 是終端 UI 的主檔 —— §5 想讓「小 UI 修（文字／排版／鍵位）」走輕路，
而這類小修**幾乎全部**會動到 text_ui_main.gd（它是畫面組裝的地方）
⇒ 只要那句註解留著（它沒有理由被刪，它在記一件真的發生過的事），
  **這張票最想覆蓋的那個檔案，判準字面上永遠判它不合格** ⇒ 輕路對它形同不存在，
  每一次小修都要跑整份電池 —— 跟 §5 開票的目的正好相反
```

## 處置

```
把判準從「plain git grep -L」換成濾過註解的版本，寫成可以直接貼的指令：
  git grep -n "\.advance_tick(\|\.advance_ticks(" -- <file> | grep -vE ':[[:space:]]*#'
  （★GDScript 註解只有 `#` 這一種起首；一行裡 `#` 前面若還有程式碼，那就是真呼叫，不該被濾掉
    —— 今天三支真呼叫點 `sim_bridge.gd:119,141`／`observer_bridge.gd:30`／`turn_controls.gd:73`
    全部整行就是呼叫本身，沒有這個邊界情況，但判準的文字要把這條界線寫清楚）
  ⇒ 無輸出（grep -v 後空）＝ 該檔沒有非註解呼叫 ⇒ 合格
```

# 3 ★你多推的那句（打聽要進快照）—— 方向對，但有現成的答案不必新開欄位

## 核對你的前提（對）

```
confirm_gather_intel（:1324）寫 belief claim —— 上一輪已核；
map_player_snapshot（player_api_mapper.gd:827）／整個 player_api_mapper.gd 掃過
  零一個 belief 相關欄位 ⇒ 若 E2E 的 diff 只比這份快照，打聽的效果確實測不出來，你的憂慮成立
```

## 但不必加新欄位——它已經存在，而且形狀正好符合 §2 的規矩

```
player_query_api.gd:51  func query_memory_panel(state) -> Dictionary:
  註解逐字：「打聽寫進去的東西，玩家要【看得見】」
  實作：讀 BeliefSystem.known_targets() ＋ claims()（★唯讀、零寫、零 RNG —— 註解自己標的）
⇒ 這正是 §2 要的東西：唯讀查詢、不耗 RNG、而且**已經是 bridge 層既有的 API**
  （跟 map_player_snapshot 同一層，只是不同一支函式）
```

## 為什麼不要走「在 map_player_snapshot 加 belief 欄位」那條路

```
那是在**玩家真正會收到的那份快照**裡加一個新欄位 ⇒ 等於悄悄決定「belief 從今天起
也出現在主快照裡」—— 這本身是一個 WHAT 大小的呈現決定（哪些東西出現在主畫面的資料源），
而本票只是要給測試床一個可比對的讀點，不該順手改變正式玩家快照的形狀
⇒ ★而 query_memory_panel() 已經是「給玩家看 belief」的正式入口 ⇒ E2E 的雙世界 diff
  多比對這一支（跟比 map_player_snapshot 一樣，呼叫前後各一次、取 diff）就夠，
  零新生產代碼、零 WHAT 風險，而且跟判準庫那條「兩份會漂，不准另開」同向：
  不要在 E2E 床旁邊再生出第二個「belief 該不該被玩家看到」的入口
```

# 4 判決

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim": "§5 輕路判準用 `git grep -L \"advance_tick(\"` 判定『不含非註解呼叫』",
     "file_line": "text_ui_main.gd:246（純註解，字面含 advance_tick()）",
     "truth": "git grep 不分註解與呼叫；該行是註解但會讓 text_ui_main.gd 被判『含呼叫』⇒ 永遠不合格，而這支恰好是輕路最想覆蓋的主檔"},
    {"claim": "§3 補的『狀態快照必須含附身隊的 belief』該在 map_player_snapshot 加欄位",
     "file_line": "player_query_api.gd:51 query_memory_panel()（唯讀零RNG，已存在，註解逐字『打聽寫進去的東西玩家要看得見』）",
     "truth": "需求是真的，但答案已經存在；加到 map_player_snapshot 是多開一個入口且碰到WHAT（主快照該不該含belief），E2E diff 改接 query_memory_panel() 即可，零新代碼"}
  ],
  "note": "(c) 乾淨無issue。這兩列都不是推翻方向，是『差一步』：(d) 换一行可直接貼的grep指令；belief那句换成接現成函式名。改完敲sha，我只diff這兩處。" }
```
