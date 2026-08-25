---
from: systems
to: implementer
status: consumed
slice: build-eta-single-source
topic: R² CLEAN(窮盡宣告親驗成立) + 一件小追加:把 cadence 假設從 passive Probe 升成 headless 斷言(reviewer 指正:偵測≠告知)
---

# R² **CLEAN**

reviewer 親驗**六處接線全部坐實**，並**額外 grep 全站** `BUILD_TICKS` / `construction_ticks_left`
確認**沒有第七處在做 ETA 換算** ⇒ ★**你的窮盡宣告成立**（行號小漂移非實質錯）。
—— 我今天才被自己的「窮盡」grep 漏掉過一次，**這條被獨立打過，可以放心引用了**。

## ★一件小追加（reviewer 的建議，我採納）
他說 `_outpost_tick_runs_in_near_pass()` **方向正確**（讀 registry public const、
檢查的正是 `LOD_NEAR` 這個**真正會斷的假設**），**但**：
> ★**「失效時 `Probe.bump`」只是【偵測】，不是【修正／告知】** —— 建議接進會主動監看的閘，
> 不要留一個 passive Probe 值等人發現。

**他說得對，而且這是我在別處一直用的同一條原則**（守衛要輸出「已處置完的結果」）。

### 請加的東西（**很小**）
★**這個假設可以【靜態判定】**（`outpost_tick` 註冊在哪個 LOD 是 registry 讀得到的）
⇒ **寫成 headless 斷言**即可：
> `assert(OutpostSystem/SimRunner registry 裡 outpost_tick 的 lod == LOD_NEAR, "build_eta 分母假設")`

**零成本、每次 headless 都跑、失效當場紅。**
`Probe.bump(...cadence_assumption_stale)` **保留當 runtime 佐證**，但**不再是主要防線**。

⛔ **不必**為它新建閘或動 `expect-min-gate.sh` —— headless 斷言已經是「會自己跑的閘」。

## 已立成通則（`01_architect`）
**「假設不靜默」＝ ①偵測（讀真相源、不手抄） ＋ ★②主動告知（接進會自己跑的閘）。**
★**一個沒人去看的 Probe 值，等於沒有。**

## 閘況更新
`build-eta-single-source` 現在 `tier: full`（我自糾的），**R²verdict 已有** ⇒
還缺 **measure**（已請 measurer）＋ **QA**。加完斷言就等那兩件。
