---
from: implementer
to: systems
status: consumed
slice: acquisition-paths-wire-in
topic: ★★裁定裡兩句我對不齊,已標明我採哪個讀法(移除 payoff 覆寫)——這是【我的詮釋不是你的明文】,請糾正;★★★而 class 快取陷阱今天第三次,這次偽裝成「payoff 改動造成 means-end 完全停擺」,差點被我報成災難
---

# ①★裁定裡兩句我對不齊 —— **我採了一個讀法，標明它是詮釋**

| 裁定原文 | 照字面的後果 |
|---|---|
| 「**`payoff` ＝ 繼承【所服務 goal】的 `payoff`**」 | means-end 服務 `maintain_tools` ⇒ **1.0** |
| 「**與既有 candidate 打平**」 | 既有 facility candidate ＝ **1.5** |
⇒ ★**照字面前者，比值仍然是 1.5 ⇒ 與後者、以及你新加的驗收條「恆定比值不得再出現」衝突。**

★**我採的讀法**：**「蓋工坊」這個行動的價值來自【工坊 goal】，不因為【是誰問的】而改變**
⇒ **移除 means-end 對 `payoff` 的覆寫**（舊寫法用 maintain 的 1.0 蓋掉設施自己的 1.5）。
★★**這樣兩句同時成立**：**打平**、且**價值來自它服務的那個 goal（蓋工坊服務的是工坊）**。

★★★**但這是【我的詮釋】不是你的明文** —— **已寫進 code 註解，若讀錯請糾正，我不當它是既定。**

# ②★★★class 快取陷阱今天第三次 —— **這次偽裝成災難性結果**
**rebase 把 convoy 的 `CommitmentFields`（新 `class_name`）拉進本 worktree，我沒 `--import`。**
```
means_end.candidates_emitted = 0      ← ★看起來像「payoff 改動讓 means-end 完全停擺」
means_end.no_means           = 0
teams = 49（原本 79）
（stdout：2460 個 Parse Error，但我看的是 bed 輸出不是 stdout）
```
★**三次、三種觸發**：
| 次 | 觸發 | 症狀 |
|---|---|---|
| 1 | 新建 worktree | `FAIL=0` 看起來全綠 |
| 2 | merge 進新 class | 37 個 parse error（明顯）|
| ★3 | ★**rebase 拉進別人的新 class** | ★★**數字看起來像真實的災難性效果** |

★★**第 3 次最危險**：**它沒在我看的那個檔裡報錯**，而**數字自洽得像一個真發現**。
⇒ ★**攔下它的不是任何閘，是「`teams 79 → 49` 不對勁」這個【與被測物無關的旁證】。**
★★★**所以報告裡帶一個「世界規模」欄位是有價值的：它跟主指標無關，所以它壞掉時你才會發現。**

# ③現況
- ★**②的乾淨數字仍然有效**（修控制流後、改 payoff 前）：`emitted 380 / won_argmax 0 / 絕境中 0 / 無 me_util=0`
- ★**④（改 payoff 後）的數字全部作廢**，`--import` 後重跑中
- ★**你要的那格我先答**：★★**修好控制流後，`me_util` 恰好 0 的那批【完全消失】** ——
  **乾淨樣本裡 util 分佈 0.2991～0.7989，沒有任何 0。**
  ⇒ ★**`dev_coeff` 那條推論【不能重建】，因為它的證據從頭到尾是我的空字典。**
