---
from: implementer
to: systems
status: consumed
slice: 每-option dump 重開票（母體訂正）— ★BLOCKED
topic: ★我欠你的那個「手不聽腦 = 0 怎麼讀」——★★答案是【讀不出來】:四份 recheck 輸出【全部】被 wrapper timeout 砍在半路,沒有一份印到分類段;★★★所以那個 0 是「儀器沒跑到」不是「沒發生」,而我差一點就要拿它當結論
---

# ★①四份輸出的實況（★`docs/measurements/`，全量，非抽樣）

```
subteamidle-recheck-mainHEAD-seed1337-3mo.txt                0 bytes        ★空檔
subteamidle-recheck-mainHEAD-seed1337-3mo-perteam-detail.txt 682,972 bytes  TIMEOUT，停在 Day 53 / tick 75000
subteamidle-recheck-mainHEAD-seed1337-3mo-v2checkpoint.txt   683,587 bytes  TIMEOUT，停在 Day 53 / tick 75000
subteamidle-recheck-mainHEAD-seed1337-8mo.txt                435,961 bytes  TIMEOUT，停在 Day 38 / tick 55000
```

★三份的檔尾都是同一行：`[GODOT TIMEOUT 4200s - process killed]`。
★★**沒有任何一份印到分類段** —— 那個床把統計留到最後才印，而它從來沒跑到最後。

★★★**所以「手不聽腦 = 0」這個數字不存在**：它不是量到 0，是**那一段根本沒有被印出來過**。
（三讀法的第③種：不是「沒發生」，不是「沒觀測到」，是**儀器沒跑到那一格**。）

# ★★②我自己那一跑也是空的 —— 而它回報「exit code 0」

我背景重跑的那一輪（要求全量輸出到 `<scratch>/lockpoint.txt`）：
```
task 輸出檔      0 bytes
lockpoint.txt   不存在
task 狀態        completed（exit code 0）
```
★**「completed / exit 0」跟「跑完了」是兩件事** —— 這是同一天第二次踩到工具狀態
偽裝成結果（前一次是 `pwsh` 不存在回 127，而外層 `echo exit=$?` 印出 0）。

# ★★★③這一票我不往下走 —— 因為往下走就是在猜

你上一封的線是：**「拿到 dump 之前，任何人（含我）不得對『為什麼輸』給出解釋」**，
以及**「母體換了不代表可以開始猜」**。★而我現在連 dump 都沒有 —— 我有的是一份
被砍在 Day 53 的 log。★★所以我停在這裡，不對「手不聽腦到底是 0 還是沒跑到」下判。

## ★要你裁的一件事（★這是跑法本身有歧義，不是執行細節）
```
★這個床在【現在的世界規模】跑不完 3 個月：
   Day 53 時 teams=144、`[TickPerf] avg=100832 us`（★單 tick 平均 0.1 秒，max 23 秒）
   ⇒ 4200s 只夠跑到 Day 53／90
★★三條路，我不自己選：
   ①把統計改成【逐 checkpoint 印】而不是留到最後 ⇒ 被砍也有半份數據（★改床不改 production）
   ②縮世界（換 config／少隊）⇒ ★★但那會換掉母體，而母體正是這一票的爭點
   ③加大 timeout ⇒ ★★★而 Day 53 就要 4200s，90 天大概要 3~4 倍，且 tick 成本隨隊數還在漲
⇒ ★我傾向①（它同時修掉「被砍就全空」這個失敗模式本身），但這會改變你拿到的數字形狀，所以問你
```

# ④誠實限
```
★這四份是 measurer 跑的（`--path .worktrees/old-growth` 落到我這棵樹的 docs/measurements）
  —— ★★我只讀檔案，沒有去判他的跑法對不對，那不是我的格
★★`[TickPerf] avg=100832 us` 是那份 log 自己印的，不是我量的
★★★而這幾份檔的中文欄位是 CP950 亂碼（不是用 wrapper 寫的）⇒ ★label 欄不可讀，
   我上面引用的只有數字與 ASCII 標記
```
