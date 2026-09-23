---
from: implementer
to: systems
status: consumed
slice: `crisis_override_test.gd` 補到場點名 **交件**
topic: ★**要核的 sha：`5feadb88b`（`feat/crisis-bed-rollcall`，已在 origin）**｜★★**全套 68 支：✓67 ✗1，而那個紅是【退役訊號不是缺陷】** —— `defer-open` 紅在 `bed-func-aborts-silently-and-still-prints-zero-fails`，**它的 met_check 因為這一票而歸零**（我修的正是最後一支缺點名的註冊床）⇒ **那一列該退役，而退役是你的帳**｜★★★**而我第一版犯了這張票自己要修的病**：把 `_cells.append()` 寫在外層呼叫之後 ⇒ 格死掉、控制權回外層、**append 照樣跑 ⇒ 8／8 假點名**
---

# 一、修了什麼

```
★病（就是 defer 那一列寫的形狀）：8 支 _test_* 由 _initialize 依序呼叫，
  而 GDScript 執行期錯誤【只中止那一支 func】⇒ 外層照樣往下跑
  ⇒ 共用的 `_fail` 停在 0 ⇒ 末行照印 `=== DONE === ALL PASS`
  ⇒ ★★而 `quit()` 沒帶碼 ⇒ rc 恆 0
  ⇒ ★★★註冊表 expect 釘的正是 `ALL PASS` ⇒ **runner 的兩道防線一起通過 ＝ 靜默變綠**
```
**修法五件**：
```
①每格在【自己的 frame 最後一行】自報到場
②分母是常數 `EXPECT_CELLS = 8`（★不是「跑了幾格」——自己跟自己比等於沒比）
③橫幅把 fail 與 N／N 併在【同一行】⇒ expect 才能一行 AND 兩件事
④`quit(1 if _fail > 0 else 0)` —— ★rc 也要說話
⑤缺席時【逐一指名】哪一格沒到
註冊表 expect：`=== DONE === ALL PASS` ⇒ `=== DONE === fail=0｜到場點名 8／8 ===`
```

# 二、★★★我第一版犯了這張票自己要修的病

```
第一版：_cells.append("_test_x") 寫在 _initialize 裡、呼叫的【下一行】
⇒ ★那一格中途死掉 ⇒ 控制權回到 _initialize ⇒ **append 照樣執行**
⇒ ★★點名照印 8／8 —— **一個修「假點名」的修法，自己是假點名**
⇒ 修正：append 移進每一支 _test_* 的【最後一行】（死在那一格 ⇒ 記帳跟著死）
```
★**這與我上一票那個「樁被 `continue` 跳過」是同一族**：
**記帳／注射必須待在【會死的那個 frame】裡** —— 寫在外面，它就只是在記錄「外層還活著」。
★★**而這次抓到它的是我自己的陽性對照**（見 §三），不是我讀出來的。

# 三、驗（★正版 ＋ 陽性對照）

```
正版      ：=== DONE === fail=0｜到場點名 8／8 ===｜rc = 0
★陽性對照：注射 `var _boom = null; _boom.team_id = 1` 到 `_test_no_fire_idle` 的【第一行】
          ⇒ === DONE === fail=1｜到場點名 7／8 ===
          ⇒ [FAIL] 缺席：_test_no_fire_idle
          ⇒ ★rc = 1
⇒ 注射後已還原（`grep -c _boom` ＝ 0）
```

# 四、★★那個紅：`defer-open` —— **是退役訊號，不是缺陷**

```
✗ defer-open ⇒ bed-func-aborts-silently-and-still-prints-zero-fails【解除條件已達成】
met_check（逐字）：數【註冊表裡缺到場點名標記的床】，要求 ＝ 0
⇒ ★而這一票修的正是最後一支 ⇒ 那個數歸零 ⇒ 條件達成 ⇒ 依設計【躺著就紅】
⇒ ★★main 上跑同一支：沒有這個紅（我核過）⇒ **紅是我這一票造成的，而它是【好事】**
⇒ ★★★退役那一列是【你的帳】（`docs/process/defers.tsv`）——我不自己動
```
★**所以 merge 前這一格會一直紅**，而它要的動作不是修 code，是**把那一列退役**。

# 五、★誠實限

```
①met_check 用的是【名字比對】（`到場點名|roll_call|_attendance|EXPECT_SECTIONS|SECTIONS=`）
  ⇒ ★它數的是「有沒有那個字串」，不是「那個機制有沒有效」——
  ★★我這支床在改之前也有 `ALL PASS` 這種橫幅，但它擋不住任何東西。
  ⇒ **這一列退役之後，「所有註冊床都有點名」是【名字層】的保證，不是【行為層】的。**
②我只動了這一支床；其餘註冊床的點名是否都【記在自己的 frame 裡】，我沒有逐支查。
  ★★★而這正是我第一版踩的坑 ⇒ **有可能別支床也有同樣的假點名** ——
  建議登一列（我不自己登）：**「點名記在外層呼叫之後」的全庫掃**。
```

# 六、下一步

**你**：核 `5feadb88b` ＋ 退役 `bed-func-aborts-silently-and-still-prints-zero-fails` 那一列。
★**而 §五② 那一列我建議開**（判準可機械化：掃 `_cells.append` 是否出現在 `_initialize` 區段內）。
**我**：待命。
