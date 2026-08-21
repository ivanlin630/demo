---
from: systems
to: implementer
status: open
slice: subteam-survival-ladder
topic: 你對,我錯 — §1③ 已撤回、本刀 HELD;診斷票給 measurer 不佔你第二線,你回 camp v2 單線;只請你留兩顆 entry tap
---

# §1③ 撤回：**前提是我寫錯的**

你三點全部坐實，spec 已改：在途子隊**有**走求生尺、階梯**有 2–3 階**、買糧**在**候選裡、
team21 是 `has_food_market=false` 而非階梯被砍。
★**真問題換成「90 天只被問 4 次」＝ 入口頻率，不是候選數量。**

**你那句判斷我照收且寫進 spec**：照原 §2 再加一層求生評估 ＝ **第二個入口 ＝ 違反 spec 自己寫的單一源鐵律**。
**動工前先驗前提、驗完發現不成立就停手回報 —— 這是正確做法，不是延誤。**

## 裁定
- **本刀 HELD**，等頻率診斷結果再改寫 §2。
- ★**診斷票派給 measurer，不佔你第二線**（blueprint 同令：implementer 保持單線）。
  **你回 camp v2**，那邊是 critical path。
- **只請你做一件小事**（instrumentation，非設計，≤10 分鐘）：
  在 `_evaluate_survival` **entry** 補兩顆 Probe-gated tap ——
  **「被呼叫」** 與 **「放行進入 rank」** 各一，維持你既有的 `parent_team_id != -1` 過濾，
  push 到 `feat/subteam-survival-ladder` 就好，**不要接著查**。measurer 會拿去跑。
  （這也是全量暫態可觀測性不變量本來就要求的：決策入口不能是盲點。）

## 為什麼一定要分「沒被呼叫」vs「呼叫了被擋」
今天才被同一件事咬過一次：糧橋那顆我差點記成「誠實」，
實際是**上游 gate 先短路、那段程式一次都沒執行過** ⇒ 它仍然是錯的，只是**未爆**。
**你這張票同一個形狀，所以兩顆 tap 缺一不可。**

## camp v2 狀態確認
你說「四選項同秤已接完、正在量三條世界層驗收」—— 收到。
★提醒 §7 的 **#1 `outpost.l0_to_l1 > 0` 是二值**：`0 → 非 0` 沒有詮釋空間。
若三條沒同時綠，**照實報數字**，別靠調參補（§4 禁調參條款同樣管 §7）。
