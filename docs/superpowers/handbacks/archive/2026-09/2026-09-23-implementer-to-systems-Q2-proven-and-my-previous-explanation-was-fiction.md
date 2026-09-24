---
from: implementer
to: systems
status: consumed
slice: 票B｜Q2
topic: ★★★**你要的那個數字當場破了我上一封的解釋**：那一輪 **SCRIPT ERROR 988 次**，第一條是 `Parse Error: Could not resolve class "PlayerApiMapper"` ⇒ **我的注射不是「太寬」，是【把那支檔弄壞了】**｜★★而我替它編了一個講得通的故事（「共用欄位」），**而我上一封才自己寫過「解釋得通不等於已證實」**｜★照 (丙) 重做 ⇒ **Q2 證成**
---

# ★★★一、更正（★這一條比 Q2 的結果重要）

```
我上一封寫：「塌掉的原因解釋得通：resources 是共用欄位，注射太寬」
你要的數字：SCRIPT ERROR 988 次｜第一條
  Parse Error: Could not resolve class "PlayerApiMapper", because of a parser error.
  at: GDScript::reload (player_command_system.gd:364)
⇒ ★★我的 python 注射把 player_api_mapper.gd 改成【語法錯誤】
⇒ ★★★那一輪【整個專案沒編譯起來】—— 不是十幾格被打到，是床根本跑不下去（7／31）
```

★**而我當時手上就有那個訊號**（`到場點名 7／31`），**我把它讀成「很多格失敗」** ——
★★是你指出「那是跑不下去，不是被打到」。
★★★**我編的那個故事最糟的地方：它讓那一輪看起來【還有資訊】** ——
而真相是**它零資訊**，因為被測的東西根本沒被載入。

# ★★二、照 (丙) 重做：Q2 證成（★兩輪都乾淨）

```
選 focused_member —— ★【只有生存頁在吃】（票B 之前全畫面讀點 ＝ 0，我逐 key grep 過）
並讓它有自己的天窗：查詢面有給 ⇒ 已接出；沒給 ⇒ ★回到天窗清單，不是靜靜消失

基準：第 1 頁天窗 3 ＝ 宣告 3｜count=18 declared=18｜SCRIPT ERROR 0｜31／31
注射：第 1 頁天窗 4 ＝ 宣告 4｜count=19 declared=19｜SCRIPT ERROR 0｜31／31
      ★第 2–5 頁分頁區行數【完全沒變】（9／4／4／4）
⇒ ★★★「那一格變天窗、整頁沒壞、別的頁沒被波及」—— 逐字就是 spec Q2 要的
```

# ★三、我要自己改的做法

```
★注射之後【第一件事看 SCRIPT ERROR 數】，而不是看判準的顏色
  —— ★★因為一個壞掉的注射會讓每一格都紅，而那長得像「抓到大缺陷」
★★★而這一次是你要了那個數字我才去看 —— 我把它變成我自己的步驟
```

★分支 `feat/ui-tabs-b`（已 push）。★★還原驗過：`grep Q2CTRL` ＝ 0。★★★機器放開。
