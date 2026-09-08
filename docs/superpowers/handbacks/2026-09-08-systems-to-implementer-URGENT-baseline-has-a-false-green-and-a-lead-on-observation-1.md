---
from: systems
to: implementer
status: consumed
slice: 全掃 baseline
topic: ★★★用戶剛被一個 Godot 對話框攔住:「data_test.gd 沒有繼承 SceneTree 或 MainLoop」——而那支床在你剛跑完的結果裡是【green 184s】｜★連載入都失敗卻判綠 ＝ 假綠進了第一份 baseline,蓋戳前請先處置｜★★而它可能是【觀察①】的機制:一個等人按「確定」的 modal,在 headless 裡就長成「Godot 活著、沒輸出、燒到逾時」
---

# 一、★事實（都可自己重跑）

```
scripts/debug/data_test.gd:1   extends Node        ← ★不是 SceneTree/MainLoop,是【場景腳本】
git log 該檔最後改動           2026-05-28          ← ★★今天沒有人動過它,不是新壞的
docs/measurements/bed-sweep-list.txt:18            ← 它在全掃母體裡
   （母體是 `scripts/debug/*_test.gd` 的檔名 glob ⇒ 它剛好符合）
.bed-sweep-inprogress.tsv:18
   scripts/debug/data_test.gd  ★green  184  CONTENDED(collisions=2)
★★★全 137 支母體裡,不是 SceneTree/MainLoop 的【只有這一支】。
```

# 二、★★這是【假綠】，而且它正要進第一份 baseline

```
腳本連載入都失敗 ⇒ 床一行都沒跑 ⇒ 輸出裡沒有 FAIL ⇒ 分類器判 green
⇒ ★而 baseline 的用途是【下一次拿來比對綠→紅】
⇒ ★★這一列會讓「data_test 永遠是綠的」變成基準,而它【永遠不會紅】——
   因為它永遠不會執行。
⇒ ★★★一支永遠不會紅的床進了 baseline,比它不在裡面更糟:
   它佔著一格,而那格什麼都沒守。
```
**處置（兩件，我裁）**：
```
①把 `data_test.gd` 移出全掃母體 —— 它不是床。
   ★做法用你剛做好的機制:標 `# @bed-kind: diagnostic`? ★★不,它連 diagnostic 都不是,
     它是【場景腳本】⇒ 我建議改名 `data_scene_probe.gd`（脫離 *_test.gd 母體）,
     或在 sweep 的母體條件加「檔頭必須 extends SceneTree/MainLoop」。
   ⇒ ★★★我傾向後者:那是【母體自己驗證自己】,而改名只治這一支。
②那一列從 baseline 拿掉（或標成 not-a-bed），不要讓它以 green 進去。
```

# 三、★★★而它可能是觀察①的機制 —— 我標成候選，不是結論

```
用戶看到的是一個【對話框】:「無法載入腳本…確定」
⇒ ★一個等人按確定的 modal,在無人值守的跑裡 ＝ 進程活著、沒有輸出、燒到逾時
⇒ ★★而那正好是觀察①的形狀:**godot 活著燒滿 604s**（我當時實查過 godot 行程數 > 0）
⇒ ★★★而 data_test 這次只花 184s 不是 604s ⇒ 條件不同（可能是這次有人按了確定,
   或 CONTENDED 那兩次碰撞改變了時序）。
```
★**我不下結論**（今天我已經把共現講成因果一次了）。**可證偽的檢查**：
```
①在 headless 下單獨跑 data_test.gd,不要按任何鍵 ⇒ 看它是不是燒到 GODOT_TIMEOUT
②若是 ⇒ 去看觀察①那四支 timeout 的診斷檔（`.sweep-timeout-*.txt`）,
   ★★裡面【最後印的那一行】是不是也是載入/腳本層的錯誤,而不是床的正常輸出。
   —— 那批診斷檔就是為了這一刻做的。
⇒ 兩個都成立 ⇒ 觀察①有機制;任一不成立 ⇒ 它仍然沒有解釋,不要硬套。
```

# 四、★而這一格對「床標記票」是一個真實樣本

```
你那支閘問的是「新增/改動的床有沒有宣告種類」。
★而 data_test.gd 揭的是更前面一層:**它根本不是床,卻在床的母體裡**。
⇒ ★★母體是靠【檔名 glob】決定的,而檔名不知道 extends 什麼。
⇒ ★★★這跟今天那條同族:**閘的母體必須是它的主詞所指的東西**——
   全掃的主詞是「可以 headless 跑的床」,而 `*_test.gd` 不是那個東西。
```
