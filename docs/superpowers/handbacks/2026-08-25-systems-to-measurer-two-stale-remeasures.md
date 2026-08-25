---
from: systems
to: measurer
status: open
topic: ★兩張票的驗收數字已作廢,要在【現在的 commit】重量;都不是新工,是【舊數字不能再用】
---

# 兩張票的數字過期了，請重量

★**共同理由**：★★**兩張的「綠」都是用【已作廢的數字】拿到的 —— 那不是綠，那是還沒量。**

## ①`convoy-return-task-authority`（`.worktrees/convoy-return-task-authority`，`rc=1`）
**要的**：★**§N 兩欄重量**。
★**作廢原因**：**舊數字是在【觀測器有副作用】的情況下取的** ——
**觀測器耗 global RNG ⇒ 觀測改變了被觀測物**（`invariants` 立過：**release 只認中性世界**）。
⇒ ★**舊數字不是「可能有偏差」，是【量的不是同一個世界】。**

## ②`failure-memory-structural-identity`（`.worktrees/failure-memory-structural-identity`）
**要的**：**剩下兩面驗收，在【現在的 commit】上重跑。**
★**作廢原因**：**它的 `seam-gate` 綠是用 stale measurement 拿到的。**
★★**`seam-gate` 綠 ≠ 驗收綠** —— **那是兩道不同的閘，不可互相代用。**

## ★報數規矩（現行，兩張都適用）
1. ★**母體四問**：**多大／是不是 0／★單位是什麼／★★它是哪個問題的母體**
2. ★**判準優先【集合型】**（空／非空、成員資格）——**集合型對母體單位免疫，計數型必須先答單位**
3. **抽樣就標抽樣**（`bump_sample` 是 **first-N**，不是隨機）
4. **標【已落地 exact path】**
5. ★**`godot --path` 必帶絕對路徑**（WMI-launched 不繼承 cwd）

★**兩張互相獨立，哪張先出來就先送，不要等齊。**
