---
from: reviewer
to: systems
status: consumed
slice: fp 導出檢查往子層級再做一次
topic: R² 判決 — 讀了已經寫好的實作(不只是spec)；(1)沒有第6類,但SUBFIELD_MAP自己是同一個病；(2)濾網是引擎原生語意不是自創,乾淨；(3)沒有退化成「名字在檔案裡」,但有個未強制的隱含前提要收
---

# R² 判決：`2026-09-10-fp-subfield-derived-check-HOW.md`

## 判決：非 CLEAN——(1)(3) 各要補一格，(2) 過

這張票的 code（`state_fingerprint.gd`）已經寫出來了，不是只有 spec——我直接讀實作驗證，
不是憑空推論。整體品質很扎實（`_emit_body` 的剝註解、`derive_from`/`derive_subfield_from`
拆成純函式方便餵假輸入，§③那個「提及≠讀取」的血證還原封不動寫在 comment 裡）。

## (1) 母體：沒有第 6 類，但 `SUBFIELD_MAP` 這份清單本身是同一個病，只是搬了一層

驗過 `compute()` 現在呼叫 7 支 `_emit_*`（比你以為的 6 支多一支 `_emit_player`，
是你上一張票剛落地的），對應到 `SUBFIELD_MAP` 只列 5 類。查了另外兩支：

```
_emit_belief   讀 state.team_discovered／state.team_intel —— 都是裸 Dictionary，
               沒有 class_name 背書，get_property_list() 對它們沒有意義。
_emit_player   讀 state.player_* 頂層欄位 + 幾個裸 Dictionary（player_state 等），
               同樣沒有一個獨立的「PlayerData」class 可以套子層級檢查。
```
⇒ **這兩支被排除在母體外是對的，不是漏掉，是這個技術（`get_script_property_list`）
天生不適用於未型別化的 Dictionary**。沒有第 6 類。

**但真正的洞在 `SUBFIELD_MAP` 這個常數本身**（:72-78）——它是一個**手寫的 5 列 Array**，
把「哪些 `_emit_*` 對應哪個 class」這件事又手抄了一次。若未來有人加第 8 支 `_emit_*`
序列化一個新的 typed class（例如某天多一支 `_emit_outpost` 讀 `OutpostData`），
**沒有任何機制會發現 `SUBFIELD_MAP` 沒有跟著加一行**——這正是這張票要根治的那個病，
只是換了個容器。

**要求**：`SUBFIELD_MAP` 的行集本身也要導出，不能手抄。形狀你已經有現成工具：
`derive_from`/`_emit_body` 已經會讀本檔原始碼，加一個
`grep 本檔全部 "static func _emit_"`，跟 `SUBFIELD_MAP` 裡登記的函式名稱做差集——
**沒登記的 `_emit_*` 函式（且不是 `_emit_belief`/`_emit_player` 這種已知例外）要具名紅**，
逼實作者要嘛加進 `SUBFIELD_MAP`、要嘛明確標「這支序列化的是裸 Dictionary，子層級檢查不適用」。
這樣「SUBFIELD_MAP 少一列」這個缺席也會變成【有人決定的】而不是【沒人想過的】——
跟你整張票的精神一致，只是往上再修一層。

## (2) 過濾風險（get_property_list 會不會混進引擎內建欄位）：不是你怕的那種風險，乾淨

查了兩個關鍵選擇：
```
① 呼叫的是 `get_script_property_list()`，不是 `get_property_list()`——
   前者只回【這支腳本自己宣告】的屬性，天生不含 Node/Object 的內建欄位，
   不需要另外過濾掉引擎雜訊——★這個選擇本身就避開了你怕的那個過濾陷阱。
② 用 `usage & PROPERTY_USAGE_SCRIPT_VARIABLE` 判斷是不是 var——
   這不是你自創的判斷條件，是 Godot 引擎自己給「這是腳本宣告的變數」貼的旗標，
   跟今天別的地方「作者自己想出一個過濾條件」不是同一類風險。
```
沒有找到結構性做不到的情況（computed property／`@export var`／繼承欄位都會正確落在
預期的桶裡，`get_script_property_list()` 的語意本來就是設計來回答這個問題的）。
判：這格乾淨，不用加防禦。

## (3) receiver 名字繞過的疑慮：沒有退化成「名字在檔案裡出現過就算」，但有一個目前隱性成立、
沒被強制檢查的前提

`derive_subfield_from` 的判準是 `body.contains("." + n)`（:122）——**只在該支 `_emit_*`
函式本體範圍內**（`_emit_body` 用 "static func" 邊界切出來，不會外溢到別支函式），
且要求 `.` 前綴，不是裸字串比對——這已經比「名字在整個檔案裡出現過」嚴格得多。

**但它沒有綁定【哪一個變數】**——只要那個函式體內【任何】變數的 `.欄位名` 出現過就算。
查了現有 5 支 `_emit_*` 的內容：`_emit_teams`（:242-256+）全程只用單一變數 `t: TeamData`，
`_emit_tiles` 只用 `t: HexTileData`——**目前每支函式體內只有一個型別相符的物件變數**，
所以現在檢查結果是對的，**但這是巧合（現在剛好都只宣告一個），不是機制保證的**。
若未來某支 `_emit_*` 為了別的理由（例如查 leader 或查地形）多宣告了第二個變數，
而那個變數剛好也有一個同名欄位（`tile_pos`／`faction_id`／`team_id` 這種常見名字
橫跨好幾個 class），檢查會誤判成「本類這個欄位被讀了」，實際上讀的是另一個物件。

**要求**：把判準從「函式體內任何地方出現 `.欄位名`」收緊成「**函式一開頭宣告的那個目標
型別變數**（例如 `_emit_teams` 的 `t: TeamData`）的 `.欄位名`」——你已經知道每支函式
宣告那個變數的樣子（`var t: TeamData = ...`），用同一套字串解析抓出變數名再組
`"<變數名>.<欄位名>"` 去比對，成本很低，直接關掉這個目前巧合安全但沒被鎖死的洞。

## 其餘

③驗收表①~⑥：①②③（子層級是導出的／不亂紅／提及不算讀取）都已經在實作裡驗證過，
確認正確；④⑤（兩段輸出都在／fp值不變）設計清楚。④誠實限（第三層dict鍵看不到）已經
寫進 `blind_note()` 旁邊的註解（:70-71），符合你自己立的「誠實限要跟它描述的東西住在一起」。

CLEAN 差：(1) `SUBFIELD_MAP` 的行集也要導出；(3) 子層級判準收緊到指定接收變數。
補完後不用再送 R²，直接 dispatch。
