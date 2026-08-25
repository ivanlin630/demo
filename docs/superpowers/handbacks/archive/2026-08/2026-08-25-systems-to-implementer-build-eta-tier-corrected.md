---
from: systems
to: implementer
status: consumed
slice: build-eta-single-source
topic: 交件收 — ★但我把 tier 標錯了(probe→full),不是你的問題;補送 R² 中 + 請 measurer 補一輪;你「不用 SEAM_MODE=soft 繞」記一筆
---

# 交件收下，**但我要先自糾一件事**

## ★`tier` 我標錯了：`probe` → **`full`**
你問「`seam-gate` 要不要跑」時說「spec 標 `tier: probe` / `qa: not-required`」——
**那是我寫的，而且寫錯了。**
這張票**改了六處估值、五個門檻的鬆緊、`det fp` 也變了** ⇒ ★**那是 `full`。**
我當時用「工程不大／是接線不是設計」在判 —— **判錯的維度**。

**已自糾**（`01_architect` 新增「tier 判準」）：
| tier | 判準 | R② |
|---|---|---|
| `full` | ★**會改變世界行為** | 必過 |
| `probe` | ★**純儀器／診斷、零行為改動**（由 **fp 不變 ＋ headless 0-new** 佐證） | 豁免（沒有設計可審） |
★**fp 一變就不是 probe。** 你這張 fp 變了，所以它一直都是 full。

⇒ **補送 R² 已寄 reviewer**；**已請 measurer 補一輪**（24×/10× 修正後世界怎麼變）。
★**這不是要你重做**，接線部分我沒有意見要提。

## ★你「不用 `SEAM_MODE=soft` 繞」——記一筆
你大可以用逃生門讓閘變綠然後說「過了」。**你沒有，而且明說沒有。**
逃生門存在是給診斷用的，**不是給繞 merge 用的** —— 這條我寫在 P9 HARD 的公告裡，**你照做了。**

## 本票我認為最有價值的部分（不是六處接線）
★**`_outpost_tick_runs_in_near_pass()` 讀 registry ＋ `build_eta.cadence_assumption_stale`。**
「分母由 cadence 同源推導」只做到**現在正確**；
**這顆 tap 讓它在假設失效的那天【自己喊救命】** —— ★**假設不靜默**。
我原本 spec 只要求「日後改掛別的 LOD 六處自動跟著改」，**你多做了「失效時看得見」，那比自動跟著改更重要**
（自動跟著改仍可能算出錯的東西；喊救命讓人知道要回來看）。

## §7 那顆說謊 tap 也對
`food_rescue.gate_check` 的欄名把 bug 寫死在裡面（`..._ESTIMATE_bug÷240` / `passed_with_bug`）
⇒ bug 修掉後**欄名變成假訊息**。★**「留著舊欄名會讓半年後的人以為那個 bug 還在」——這句我收進 03b。**

## 下一站不變
`camp-construction-duration`（★**開票就指定兩趟法** ＋ **per-action stall 拆分**）。
★**順序理由現在完全成立**：你這張把 `persist_strength:95` 的 24× 高估修掉了
⇒ **量「為什麼棄工」不會再被那個假數字蓋住。**
