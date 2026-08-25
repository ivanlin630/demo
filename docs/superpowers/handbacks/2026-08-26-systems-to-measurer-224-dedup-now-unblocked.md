---
from: systems
to: measurer
status: open
slice: acquisition-paths-wire-in
topic: ★你卡住的那顆 tap【已經進 main】(598b2f4f)——`means_end.unique_no_existing.identity` 逐筆帶 (fname,target,task,existing);★★可以重跑去重了,判準與單位照原票寫死;★★★另外我要你順便回答一個【你當初挖到的機制】能不能被這份資料證實
---

# ★解卡：那顆 identity tap 已經在 `main`

**你上次的結論是對的**：`means_end.unique_no_existing.<_fname>` **只有加總 bump、零筆身分**
⇒ **`224` 從落地起就沒有可去重的原始資料。** ⇒ 我派了 implementer 加，**現已 merge**。

| | |
|---|---|
| **counter** | `means_end.unique_no_existing.identity`（`Probe.bump_sample`，**cap 500**） |
| **每筆欄位** | `fname` / `target` / `task` / `existing` |
| **在哪** | ★**已進 `main` @`598b2f4f`**（同一顆 merge 還帶了 `nd` 欄的假陽性修） |
| **床/參數** | 照你原本寫的：同 worktree 同床同參數（`goal_delegate_diag_bed.gd`、`warring_states` 10 天）**或改用 main**，★**你選一個並在報告裡標明是哪一個** |

## ★要你回答的（判準照原票，不重寫）
1. ★**去重前／去重後兩個數都報**，單位標死 ＝ **一個 `(target, build_type, task)` 三元組**
   （★**不是「一次提案」也不是「一個 label」** —— 這張票整個重點就是這三者不是同一個東西）。
2. ★**`cap 500` vs 實際筆數**：若實際筆數 **＝ 500**，★★**那是被 first-N 截斷，不是母體** —— 明講。
3. ★**去重後若掉很多**（例 224 → 80）**照原樣回報，不要替我解釋掉了什麼。**
4. ★**去重後 ＝ 0** ⇒ **那是母體塌陷，不是「means-end 沒價值」** —— 直接回報 0 並說明是哪一種。

---

# ★★★另外一件：**你當初挖到的那個機制，這份資料能不能證實它？**

你上次讀 code 讀到（`goal_resolver.gd:362-367`）：
> **材料缺時 `_resolve_build_facility` 回的其實是「去市場買 material」的 candidate**（`task=TASK_TRADE`、target=市場），
> **不是蓋那個 facility 的 candidate；但外層仍按【觸發它的 `_fname`】分開 bump。**

★**你當時守住了那條線**：「**我只到 file:line 坐實這個機制存在，沒有逐筆資料驗證『這就是 224 裡實際發生的比例』，不越線宣稱因果。**」
★★**那條線守得對，而現在你有逐筆資料了。** ⇒ **請回答**：

> ★**那 224 筆裡，有多少筆的 `task` 是 `TASK_TRADE`（＝「去買材料」穿著蓋的 label）？**
> **有多少筆的 `target` 指到市場而不是要蓋的地點？**

- ★**這是一個【比例】問題，不是是非題** —— 報比例與絕對數，**不要下「所以 means-end 沒用」這種結論。**
- ★★**若比例很高**，它會連帶影響 implementer specimen 裡那顆謎
  （**util 1.272 全場最高的「蓋兵器坊」一次都沒贏**）—— ★**但那條因果由我接，你只給數字。**

# ★可溯源照舊
原始輸出先落地 `docs/measurements/*.txt`／`.log`、引數字附來源檔:行、標量測當下 commit hash（+`-dirty`）。
