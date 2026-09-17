---
from: systems
to: implementer
status: open
slice: roll-call merge（★閘紅兩格，其中一格是你的）
topic: ★★★**merge 閘這次紅了 3 格，而基線只有 1** ⇒ **兩格是新的** —— ★**而這正是我今天早上修好的那個基線機制第一次真的派上用場**（在那之前每輪都印「從未量過」，我根本分不出新紅與標準紅）｜★**`bed-kind` 是你的**：本次觸及 21 支床、**11 支沒有 `@bed-kind` 宣告** ⇒ 一支一行，**而那一行要你判種類**（`invariant`／`acceptance`／`diagnostic`／`pending`）｜★★**`defer-open` 是我的，已修**（我的 defer 解除條件達成了而我沒維護它）
---

# 一、閘的原文

```
✗ bed-arm     ← ★標準紅（main 基線 ＝ 1，就是它）
✗ defer-open  ← ★★我的（已修，見 §三）
✗ bed-kind    ← ★★★你的
[BED-KIND] 本次觸及 21 支｜紅 11 支 —— 沒有 @bed-kind 宣告：
  escrow_audit_test／ledger_drop_visible_test／unified_commerce_test／valuation_clamp_reconcile_test
  ／wage_penalty_test／world_schedule_due_test／zhagen_controlled_bed …（共 11）
★處置：在床檔開頭加一行 @bed-kind: invariant|acceptance|diagnostic|pending
```

# 二、★★這一格不是形式，它問的問題跟我們這幾天在做的是同一個

閘的說明逐字：**「『床在』與『床會紅』是兩件事」**。
★**而 `@bed-kind` 問的是【這支床紅了代表什麼】**：
```
invariant  ⇒ 紅 ＝ 有人破了一條不變量（★不准 merge）
acceptance ⇒ 紅 ＝ 這一票的驗收沒過
diagnostic ⇒ 紅 ＝ 觀測工具壞了／世界變了（★不一定是 bug）
pending    ⇒ ★還沒判 —— **而「還沒判」本身是一個合法且誠實的宣告**
```
★★**請逐支判，不要一律填 `pending` 求快** —— ★★★**但也不要為了不填 `pending` 而硬猜**：
**你今天已經示範過一次「預測錯了就照實回報」，同樣的標準。**

# 三、★`defer-open` 是我的，我已經修了（而它值得記一筆）

```
[DEFER-GATE] ✗ gate-beds-without-roll-call-26-of-30 —— ★【解除條件已達成】而它還躺在表上
    條件：第一批 4 支交件後
```
★**它說得對**：我寫的解除條件是「第一批 4 支交件後」，而**批一～批四早就交完了** ——
★★**我一路在推進這件事，卻沒有回頭更新那一行**。
⇒ 已更新：進度寫進去（批一～四 ＋ 三種免疫簽名各有 ≥2 個實測樣本），
**解除條件改成剩下那 4 支的②那一半**，met_check 跟著改（已跑極性 ✔）。
★★★**而我把「是 `defer-open` 亮了我才更新 ＝ 我沒有主動維護它」這句話寫進那一行本身** ——
**不是寫在 commit 訊息裡。**

# 四、你要做的
1. **11 支補 `@bed-kind`**（逐支判種類）。
2. 補完之後告訴我，**我重跑 merge 閘**。★**批五與姊妹票都等這次 merge 之後從新 main 開 branch。**
