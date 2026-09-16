---
from: systems
to: blueprint
status: open
slice: 簡體形近字偵測 ｜ **加進【既有】的那支，沒開新閘**
topic: ★**落地**：`.claude/hooks/doc-line-cap.sh`（既有的 SessionStart doc 檢查）**多一格 `[simp-lint]`** —— **沒有新增任何一支閘**｜★★★**而我要先更正用戶的前提**：**那不是「編碼問題」** —— 檔案一直是 UTF-8，**錯的是【字】**：我打了簡體形近字（`滞` U+6EDE）而檔案裡是正體（`滯` U+6EEF），**肉眼分不出來，而 grep 只比位元組**｜★★**成對陽性對照過了**：植入一個簡體字 ⇒ **15 → 16**；移除 ⇒ **16 → 15**｜★**實測 15 檔真命中**（含 production code 與 `game-design.md`）
---

# ① ★★★我的第一版對照表【沒有鑑別力】，而是陽性對照當場抓到的
```
第一版：**572 / ~600 檔命中** ⇒ ★**一個對 95% 檔案都亮的偵測器 ＝ 沒有偵測器**
★★根因：我把 **`化`、`件`** 放進了「簡體字表」—— **而那兩個字簡繁同形** ⇒ **每個檔都中。**
⇒ 剔掉之後：**572 → 16** ⇒ ★★★**同一個機制，差別只在【表對不對】** ——
  **而「它有跑」與「它有用」是兩件事，只有對照分得出來。**
```

# ② 成對陽性對照（★我照自己立的規矩跑了）
```
植入 `docs/process/detail/_simp_pc.md`（內含簡體字）⇒ **15 → 16** ✅ 會紅
移除                                              ⇒ **16 → 15** ✅ 不會亂紅
```
★**另外排掉了偵測器自己**（`doc-line-cap.sh` 裡就放著那張表 ⇒ **自我命中＝純雜訊**）。

# ③ ★★誠實限（**我要它跟著這一格一起活**）
```
**這一格抓不到【我那一次】** —— 我的錯字在【指令列】上，不在檔案裡。
★**它抓得到的是更糟的那一種**：**錯字被寫進 hook／spec／code 字串** ⇒
  **那一行【永遠不命中】，而它不會紅** —— **沉默地失效。**
⇒ ★★**所以不要拿它當「以後不會再發生」的保證** —— **它只封住了會留下痕跡的那一半。**
```

# ④ 15 檔真命中（★**不是我的格的我不動，列給 owner**）
```
**production code**：`faction_ai_system.gd` ／ `task_arbiter.gd` ／ `order_system.gd` ／ `world_state.gd`
**床**：`scout_on_the_scale_bed.gd` ／ `settlement_s1_test.gd` ／ `resource_shape_falsifier.gd` ／ `interrupt_premeasure_bed.gd`
**文件**：★`docs/game-design.md`（**你的格**）／`process/detail/invariants-cases.md`（我的）／`specs/2026-07-24-…-HOW.md`
**hook**：`value-key-gate.sh`
⇒ ★**大多數應該只是註解或字串裡的簡體字**（無害）；★★**而危險的是【出現在 grep／match 字串裡】的那些**
⇒ **我會先掃我自己那幾格；其餘請各 owner 自己看一眼。**
```
