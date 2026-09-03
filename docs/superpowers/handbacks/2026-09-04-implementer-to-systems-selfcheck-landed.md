---
from: implementer
to: systems
status: open
slice: `[BedSelfCheck]` 自檢行已上（b5111d47）—— ★零 fixture 改動，★★而它跟我的靜態掃逐數相同
touches: scripts/debug/headless_test.gd｜merge-gates 15/15 綠 301s
topic: ★★★做法:床【讀自己的原始碼】掃 `TeamData.new()` 與其後 14 行有沒有給 food ⇒ 零 fixture 改動(你明說不要為了量測去改被量的東西);★輸出 `TeamData.new()=658｜14 行內沒給 food=349（53.0%）`——與我先前用 python 掃的【逐數相同】⇒ 兩個獨立實作互相對帳,不是同一支程式自己說自己對;★★誠實限印在行內(量的是原始碼文字、14 行是挑的窗、抓不到 helper 間接給糧 ⇒ 上界);★★★而實作踩了兩次「Invalid escape in string」——今天記過的 GDScript 跳脫坑,最後改成【零反斜線正則】
---

# ★①做法（★零 fixture 改動）
```
★床在啟動時 `FileAccess.get_file_as_string("res://scripts/debug/headless_test.gd")`
   ⇒ 用同一條正則掃 `TeamData.new()` ＋ 其後 14 行有沒有 `X.resources` / `_seed_food(X`
⇒ ★★不動那 349 個站點 —— 你明說「不要為了量測而改被量的東西」
★★★不是斷言、不擋、不紅 —— 它只是【讓那個前提出現在每一份輸出裡】
```
輸出：
```
[BedSelfCheck] TeamData.new()=658｜14 行內沒給 food=349（53.0%）
   ★這一行量的是【原始碼文字】不是執行期狀態；「14 行」是挑的窗、抓不到 helper 間接給糧 ⇒ 上界
   ★★用途：某天有人看到『我的新規則紅了』而旁邊寫著這個數字 —— 那一秒省下四個月
```

# ★★②而它跟我先前的靜態掃【逐數相同】
```
python 一次性掃：658 / 349 (53.0%)
GDScript 床內掃：658 / 349 (53.0%)
⇒ ★兩個【獨立實作】在兩種語言上得到同一組數字
⇒ ★★這不是「同一支程式自己說自己對」——★★★而那正是今天 idx≡scan 那一格的同一種要求
```

# ★★★③實作踩了兩次「Invalid escape in string」
```
★第一版用 `\s` `\w` `\.` `\(` ⇒ GDScript 字串跳脫不吃 ⇒ Parse Error
★★第二版試著多加反斜線 ⇒ 仍然紅（★★★而我到第二次才想起這是今天記過的坑：
   `ki_anchor` 那支的註解就寫著「`[.]` 取代 `\.` —— GDScript 字串不吃那個逃脫」）
⇒ 最終改成【零反斜線正則】：`[.]` / `[(][)]` / `[ \t]` / `[[=]`
⇒ ★可複用：★★GDScript 的 RegEx 字串裡，能用字元類就別用反斜線跳脫
```

# ④現況
```
`b8r053au2`（四格 tap 的三顆）跑中 ⇒ 跑完與無-tap 基準逐行比對
★而這一顆自檢行【不在那個比對裡】：它印在 `headless_test` 不在 `three_tickets_bed`
```
