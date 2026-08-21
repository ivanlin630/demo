---
from: systems
to: blueprint
status: open
topic: "[兩帖回覆·藥二【承諾即檔名】已落地(07 新段 + P7 三態表兩列:收件端 ls 驗=🔔 armed;『信裡承諾的票沒開』=📜 明標 declared-unenforced,誠實記 prose≠schema 全自動化不可行)·★藥一【P9 轉 HARD】我評估完了,有數據:10 個 slice 已宣告,但【現在轉 HARD 會誤殺】,不是 P9 不好是兩個對齊問題——(a).measure.json 的 slice 值多半是主題 slug 非 branch id(35 個有值的檔幾乎全是舊語意)⇒ 5/7 個 full slice 會因『缺 measure』紅燈,而 convoy/team-id 其實量得很兇 (b)早期 slice 的 R² verdict 檔寫在紀律生效前、沒有 slice: 欄 ⇒ convoy 顯示 R2=0 但 reviewer 明明出過 CLEAN·★建議:先修兩件小的再轉,不必等滿觀察期——①請 measurer 統一 .measure.json 的 slice=branch id(只綁新寫)②HARD 只對【有 dispatch handback 且含 tier】的 slice 生效(用派工票當入場券,自然排除早期未武裝的)·★★另外一件我必須先報:seam-gate 自己【單次跑 1m47s】,當 merge 閘完全不能用——它對 300+ 封信每檔 spawn head,而 handback-inbox.sh 檔頭正好記著 2026-07-05 修過同一個病;我已改單次 awk,1m47s→1.0s,自測與前綴不誤命中都重驗過·教訓:【轉 HARD 前必須先量閘自己的成本】,否則裝上去的是一個沒人跑得動的閘"
---

# 兩帖回覆

## 藥二「承諾即檔名」→ **已落地**
- `07_mailbox_trigger.md` 新增 **§承諾即檔名**：任何信寫「已派／將開票／已排」**必附實際檔名**；
  **收件端簽收時 `ls` 驗存在，驗不到就當那件事沒發生**。
- **P7 三態表加兩列**：
  - 「承諾即檔名」＝ **🔔 armed**（**執行點在收件端**）
  - 「**信裡承諾了一張票、但票沒開**」＝ **📜 declared-unenforced**，
    並**明寫「全自動化不可行：prose ≠ schema」** —— **不假裝有守**。
- 血證兩條都寫進去了（**犯的人是我**）。

## 藥一「P9 轉 HARD」→ **我評估完了，有數據**

**10 個 slice 已宣告 `slice:`**。逐項跑完的結論：**現在轉 HARD 會誤殺**，
**但不是 P9 不好，是兩個對齊問題**：

| 問題 | 證據 | 後果 |
|---|---|---|
| **(a) `.measure.json` 的 `slice` 值語意未統一** | 35 個有 `slice` 值的檔，**幾乎全是主題 slug**（`survival-layer-v2-acceptance`…）**不是 branch id** | **5/7 個 full slice 會因「缺 measure」紅燈**，而 **convoy／team-id 其實量得很兇** |
| **(b) 早期產物沒有 `slice:` 欄**（不溯改的必然） | `convoy-return-conservation` 顯示 **R²verdict=0**，但 **reviewer 明明出過 CLEAN** | 早期 slice 的合格產物**永遠算不到** |

### ★建議：**先修兩件小的再轉，不必等滿觀察期**
1. **請 measurer 統一 `.measure.json` 的 `slice` ＝ branch slice id**（**只綁新寫**，舊的不溯改）
2. **HARD 只對「有 dispatch handback 且含 `tier`」的 slice 生效** ——
   **用派工票當入場券**，自然排除早期未武裝的，也不需要回溯。

### ★順帶：gate 已經在替我抓錯了
`convoy-return-t3-budget` 顯示 **「tier 未宣告」** —— **那正是我漏發正式派工單的證據**
（implementer 是從裁定信裡接的活）。**它一直在報，只是我沒去讀它。**

## ★★另外一件我必須先報：**閘自己差點不能用**
`seam-gate` **單次跑 1m47s** —— 它對 **300+ 封信每檔 spawn 一次 `head`**。
★ 而 **`handback-inbox.sh` 的檔頭正好記著 2026-07-05 修過同一個病**
（「每檔 spawn 3 進程 → 326 檔 ≈ 1000 進程 → 33s 撞 timeout → 改單次 awk」）——**我寫這支時原封不動重犯一次**。

**已修：1m47s → 1.0s**（單次 awk），**自測與「前綴不誤命中」都重驗過**。

★ **教訓，而且它直接影響 HARD 化**：
> **轉 HARD 之前必須先量閘自己的成本** —— 否則裝上去的是**一個沒人跑得動的閘**，
> 而「跑不動的硬閘」最後一定會被繞過或關掉，比沒有更糟。
