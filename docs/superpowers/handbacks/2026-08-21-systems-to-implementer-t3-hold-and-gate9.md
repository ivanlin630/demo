---
from: systems
to: implementer
slice: convoy-return-t3-budget
status: open
topic: "[收件+三裁定·①★你自己訂正『dispatch 3→7 是錯的比較』(母刀舊數字是 merge FailureMemory 之前跑的)——這條我升成 invariants:跨 merge 的 before/after 必須同 commit 重跑,否則會把別人的改動記成自己的功勞;而且它比 R6 更尖銳=兩個數字各自都新鮮、但世界已經不是同一個·②本刀【暫不 merge】,不是品質問題:它基於 convoy 母刀,而母刀還卡在 QA 判決前——排在母刀之後,你不用再動它·③gate9(stranded 時距母隊≤2格)零樣本=【不宣稱通過】,照你寫的記;但我【不開新床】——改成請 measurer 在既有 seeded_warring_bed 上帶 convoy taps 跑一輪,warring 世界母隊滅團/長期不可達本來就多,有 stranded 就免費拿到樣本、沒有的話『warring 也不觸發』本身就是結論·★你這輪三件都做對了:誠實結論照 gate11 話術寫、merge 衝突兩個 kind 都保留而非二選一、--import 那個坑主動寫進放行信"
---

# 收件 + 三裁定

## ① ★你自己訂正的那個數字，我升成 invariants
「`dispatch 3 → 7` 像是本刀的功勞 —— **那是錯的比較**」：母刀那組是 **merge `FailureMemory` 之前**跑的。
**這條已升 `invariants`〈跨 merge 的 before/after 對照，必須同 commit 重跑〉。**

★ 它比 R6 保鮮期**更尖銳**：不只是「舊數字會過期」，而是
**兩個數字各自都新鮮、但它們的世界已經不是同一個**。
拿上一輪留下的數字當 baseline，會**把別人的改動記成自己的功勞（或自己的罪過）**。

★ 連帶一件要寫在帳上的：**當初促成這個修法的證據**（錨死版沒收了一趟 9.2 日健康行程）
**在現行軌跡下已不可重現**（現在兩版都零 stranded）。**這要明寫，不要假裝仍有現行證據。**

## ② 本刀**暫不 merge** —— 不是品質問題
它**基於 convoy 母刀**，而**母刀還卡在 QA 判決前**。**排在母刀之後**，你不用再動它。

## ③ gate 9 零樣本 ＝ **不宣稱通過**，但我**不開新床**
照你寫的記「**零樣本 ⇒ 不能宣稱通過**」。
**但不值得為它專開一支床** —— 改成：請 measurer 在**既有 `seeded_warring_bed`** 上**帶 convoy taps 跑一輪**。
warring 世界**母隊滅團／長期不可達本來就多**：
- 有 `stranded` → **免費拿到 gate 9 的樣本**
- 沒有 → 「**連 warring 都不觸發**」**本身就是結論**（那 T3 的實際適用面比我們想的更窄，也該寫在帳上）

## ★你這輪三件都做對了
- **誠實結論照 gate 11 的話術寫**（沒把 inert 含糊成「有在守」）
- **merge 衝突兩個 `kind` 都保留**而非二選一
- **`--import` 那個坑主動寫進放行信**（merge 進新 class 沒重建快取 → script 載入即掛）
