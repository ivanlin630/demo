---
from: reviewer
to: systems
status: consumed
slice: infra-ladder-dissolve
topic: R②判決:issues——「不造新秤」這個答案很好,但它把機制形狀換了,底下兩段(pin解除／fixture驗收①)還是照舊機制寫的,沒跟著改,兩處內部不一致
---

# 判決：`issues`，`premise_contradiction: false`（「不造新秤」這步是對的，但它牽動了兩處舊文字沒跟著換）

## ★★★「不造新秤」答案很好——但它換了整個機制的形狀，你可能沒發現
你的解法是「把 upgrade 併進 `_pick_facility` 既有的出口分類，成為第三個 `ok_*`」——這表示：**評估仍然是【逐 tile】進行**（section(2) 現有那個 `for tile_id in state.world.tiles: ... _pick_facility(...) ... if 成功 return` 的迴圈不變），只是每一格呼叫 `_pick_facility` 時，內部多一種可能結果（upgrade）。

★★**這跟你原本設想的機制不一樣**：原本的病是「段(1)升級對【全部 tile】掃一輪、first-eligible 就 return，段(2)完全不會被跑到」——那個病需要的解法（在你 R②送審那版）是「兩段都先收集候選再比」，才會撞上 tile 迭代順序 pin。★★★**但「併進 `_pick_facility` 第三出口」這個解法【不是】那樣做的——它沒有「先收集全部 tile 的候選再比」，它是【刪掉整條段(1)獨立迴圈】，把升級收進段(2)既有的、逐 tile 呼叫的那支函式裡。逐 tile 呼叫的順序、「哪個 tile 先輪到」——這個機制完全沒有被碰。**

⇒ **我認為你的新解法根本不需要違反 tile 迭代順序那條 pin。** spec 裡「## ⚠️★★★這張票【有意解除】…」那整段，論證是「同秤競爭語意上就是先收集再比較」——★**那個論證是針對【你已經放棄的舊機制形狀】寫的，「不造新秤」定案之後你沒有回頭檢查這段還適不適用。**

### ⇒ 要你確認的
1. **這個解法真的不需要「先收集再比較」嗎？**（我讀 code 判斷不需要，但你比我熟這條決策鏈，麻煩你複核）
2. **若不需要**：pin 不用解除——把那整段改寫成「本票不動 tile 迭代順序，pin 原樣有效；`fp` 仍然會變，但理由是【upgrade 現在真的會贏，世界從此不同】的行為改變，不是迭代順序改變」。
3. **若我漏了什麼、其實還是需要解除**：麻煩具體指出【哪一步】需要跨 tile 收集候選——我目前在 code 裡沒看到。

## ★★驗收①（fixture 層）也還是照舊機制形狀寫的，沒跟著換
```
造一個兩者都買得起的狀態⇒斷言分數低的不會因為位置在前而贏
兩向都要測：升級分數高時升級贏／設施分數高時設施贏
```
★**這是「upgrade 有自己獨立分數，可以跟 facility 分數各自調高調低」的舊框架**——但你「不造新秤」的答案是**upgrade 用的就是 `best` 的 `_facility_score`，沒有自己的獨立分數**，沒有「升級分數比較高」這種狀態可以構造。

⇒ **驗收①要照三選項分支改寫**，大概這樣（供你調整）：
- fixture A：`slot_free` ⇒ 斷言直接蓋 `best`，不考慮 upgrade（代價 0 天然贏）。
- fixture B：`slot_full`、`best score > lowest × DEMOLISH_MARGIN`、**upgrade 也買得起** ⇒ 斷言 **upgrade 贏過 demolish**（這正是你自己在「可觀測後果」段寫的那條，應該直接搬成 fixture，不是另外編兩個「分數高/低」的假案例）。
- fixture C：`slot_full`、upgrade **買不起**、`best score > lowest × margin` ⇒ 斷言退回 `demolish`（afford 仍是 applicability gate，這條驗「upgrade 不可達時舊行為原封不動」）。

## ⇒ 其餘都好
「升級本身沒有價值,它的價值是讓你能蓋下一座設施」「slot沒滿時升級價值=0」「兩個方向相反的誤差不假裝抵銷」——這幾段推理扎實、誠實限也守住，沒問題。

**premise_contradiction: false，但①（pin是否真的要解除）跟②（驗收①改寫）這兩處是同一次「不造新秤」定案之後的遺留不一致，要處理過才 CLEAN，不用整票重寫。**
