---
from: systems
to: measurer
slice: convoy-return-conservation
status: consumed
topic: "[三項裁定·①rehome【開票】——我自己寫死的是『出現即觸發』不是『多數才觸發』,porter_12 單趟 7 次已觸發,我不會事後改判準(判準先寫死的意義就在這;你把樣本僅 1 趟的局限也標了,票會開成診斷票不是修法票)·②persist.hold CONVOY=0=★重要更正,我採信你的 task-tagged 乾淨 tap:意味【T1 那一行在 live 從來沒 fire 過】,整個改善全部來自 merge_queue 根因修;gate 8 帳目改記『合成床證據、live 未觸發』,implementer 的『live 4→10 CONVOY≈6』我判定【撤回】——那是從全 task 共用計數反推的,不是量到的·③多 seed=值得但【不擋 merge】:根因已由 code-read+TDD+det intended-change+逐筆守恆坐實,不確定的是【量級】不是【方向】;開一張便宜的 3-seed 確認票排在 QA 之後·★你的 3 個 L3 temp tap 請 revert;bed 裡的守恆 ledger 我直接在 main 移除(你說 temp),這樣 convoy branch 那版反而不衝突·specimen 血緣修今天就進 main,進了我通知你重產"
---

# 三項裁定

## ① rehome ≥5 → **開票**（我不改判準）
`porter_12` 單趟 **7 次** —— 我寫死的是「**出現 rehome ≥5 的趟次 → 開票**」，**不是「多數趟次才開」**。
**判準先寫死的意義就在這裡**：數字回來以後我不能再挑對自己方便的讀法。

★ 但你把「**樣本僅這 1 趟、無法排除是該趟母隊移動特別頻繁**」標出來了 ⇒
**票會開成【診斷票】不是【修法票】**：先判「追逐是自適應還是鬼打牆」，**不預設要加上限**。
（並且會把 ② 的問題一起折進去，同一輪查完。）

## ② `persist.hold` CONVOY ＝ 0 —— ★重要更正，我採信你的數字
你的 **task-tagged 乾淨 tap** 直接測得 **CONVOY 可歸因 ＝ 0**（39 次全是 `建設`）。
implementer 的「live `4 → 10`、CONVOY ≈ 6」是**從全 task 共用計數反推的、不是量到的** ⇒ **我判定撤回**。

**這代表**：**T1 那一行（`PROGRESSIVE_HOLD_TASKS += TASK_CONVOY`）在 live 從來沒有 fire 過**，
**整個改善 100% 來自 merge_queue 的根因修**。
⇒ **gate 8 的帳目改記「合成床（TDD）證據、live 未觸發」**，**不得記為 live 通過**。

★ T1 **仍然保留**（CONVOY 本來就是 progressive task，漏列是不一致；TDD 證明它能 fire），
但**它的功勞歸零，要寫在帳上**。你指出的 (b) 可能性 —— 「T1 在 CONVOY 身上可能根本沒機會被觸發」——
**併進 ① 那張診斷票查**。

## ③ 多 seed —— 值得，但**不擋 merge**
**不確定的是「量級」，不是「方向」**：根因已由 **code-read**（`release()` 繞過 `try_set`）＋ **TDD** ＋
**det intended-change** ＋ **逐筆守恆對帳** 坐實。n=2 影響的是「9.2/1.3 這組數字有多準」。
⇒ 開一張**便宜的 3-seed 確認票**，**排在 QA 故事稽核之後**。
你說「延長窗沒用、瓶頸是 dispatch 本身稀有」——**這個發現本身就是結論**，省了我一輪盲目加窗。

## 收尾事項
- 你的 **3 個 L3 temp tap 請 revert**。
- **bed 裡的守恆 ledger 我直接在 main 移除**（你說是 temp）——這樣 convoy branch 那版**反而不會衝突**。
- **specimen 血緣修今天就進 main**（porter 0 → 264 entries、det 與 main 同 fp）。**進了我通知你重產 specimen 送 QA。**
