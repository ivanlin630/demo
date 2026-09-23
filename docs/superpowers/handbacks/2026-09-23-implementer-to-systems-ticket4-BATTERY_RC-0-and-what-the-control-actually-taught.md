---
from: implementer
to: systems
status: consumed
topic: ★★★票4 全綠：`BATTERY_RC=0`、77／77、零紅、ui-flow 42／42｜★★而這一輪真正的產出是兩個【用跑才會知道】的東西：`chr()` 不存在（我自己的處方反咬）＋ P3 對照證明 P1 看不見這張票的性質｜★一件交接事項：`.construction-duration-source-gate.txt` 每跑一次就被閘重寫
---

# ★一、票4 判決（`a4e773f69`，rebase 到 `0e347a32f` 之上）

```
①[TREE]  HEAD=a4e773f69  branch=feat/render-no-write
         ★rebase【無衝突】（票4 本來就疊在票3 上，線性延續）
         ★★指名核（不數數）：value-key-selfcheck【在】✓
                             command-replay【不在】✓（票4 本來就不該有）
                             77 列
         ★★★expect 是【算的】不是沿用：樹上實際格數 42 ＝ 註冊表 expect 42／42 ✓
②母體數字：P1「這一輪真的有資源行」✓｜P1b「查詢面真的有資源（11 個欄位）」✓
③顏色  ：errors: 0｜到場點名 42／42，SCRIPT ERROR 0
④判決  ：★★★[MERGE-GATES] BATTERY_RC=0 ｜ ✓ 77 ｜ ✗ 0
         ui-flow ✓（9s）、value-key-selfcheck ✓（1s）—— 兩支都真的跑過
```

★**票4 可以 merge。**

# ★★二、這一輪真正的產出是兩個「不跑就不會知道」的東西

**(1) `chr()` 在 GDScript 4 不存在 —— 而處方是我自己採用的**
```
第一次 A 輪：rc=1、SCRIPT ERROR=2、【沒有 DONE 行】
  Parse Error: Function "chr()" not found in base self（:1408/:1409）
★根因：我今天立過「不要寫需要反斜線的形狀」，然後用 chr(10) 取代跳脫
  —— 而 chr() 是 Godot 3 的全域函式，Godot 4 是 String.chr()
★★而我當時「確認」它可用的方式是【它在 Python 裡 work】—— 那是另一個環境
⇒ 你補的那句我記成可操作的形狀：
   **為了避開 A 而採用 B 時，要先確認 B 在【這個】環境裡存在，而確認方法是讓它跑一次。**
影響：票3（已 merge）無 ｜ ★票5 五處（command_replay_bed 4、ui_flow_test 1）⇒ rebase 時一起修
```

**(2) P3 陽性對照：P1b 紅了，P1 沒紅**
```
P1b：3 紅 ✓ ⇒ reviewer 的疑慮【定案】，v3 真的有鑑別力
P1 ：★【沒有紅】—— 而 spec §4 寫「P1 與 P1b 都必須紅」
原因＝我用來證明 P1b v2 恆真的那套推理，原封不動適用於 P1：
  連續兩次呼叫 ⇒ 第一次寫定基準、第二次 `day == _res_baseline_day` 直接跳過 ⇒ 輸出相同
⇒ ★★這是【spec 的預測被實驗推翻】，不是實作沒做到
```
★你裁 (乙)：改預測、不改 P1，**而必須同時重標 P1** ——
我把理由記成：★★★**否則下一個人會把它讀成「這張票被兩格守著」**，
而實際上守這個性質的只有一格。

# ★三、一件交接事項（不是缺陷，但你 merge 時會看到）

```
`docs/measurements/.construction-duration-source-gate.txt` ★每跑一次電池就被閘重寫
（裡面記的是 `construction_ticks_left` 真寫入點的【行號】，而行號隨 code 位移）
⇒ 票3 那輪我 rebase 前把它丟棄過一次；這一輪跑完它又變成 modified
⇒ ★我【沒有】把它 commit —— 它是產生物不是編輯，而閘會自己重寫
⇒ ★★你 merge 時工作區會是 dirty 的，那一檔是預期內的
```

# 四、下一站

```
①你：merge 票4 ＋ 改 spec §4 的預測 ＋ 重標 P1
②我：rebase 票5 到新 main ⇒ ★先修 chr() 五處 ⇒ 跑 ⇒ 回報
★★而「第一次編譯」那次豁免【已經用掉】：票5 若再出 Parse Error，就是真缺陷
```
