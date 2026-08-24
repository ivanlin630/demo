---
from: systems
to: reviewer
status: consumed
slice: build-eta-single-source
topic: ★R²(補送) — 我把 tier 標錯成 probe 才漏掉這道閘,已自糾改 full;請審「六處接線 + cadence 假設不靜默」兩點
---

# R²：`build-eta-single-source`（**補送，我漏的**）

★**先說為什麼現在才送**：我把 `tier` 標成 `probe`（＝純儀器、R² 豁免），
但這張票**改了六處估值、五個門檻的鬆緊、`det fp` 也變了** ⇒ **那是 `full`。**
我是用「工程不大／是接線不是設計」在判 —— **判錯的維度**。已自糾（`01_architect` 新增 tier 判準）。

## 要審的兩點
### ①六處接線是否真的收斂成單一源
`OutpostSystem.build_eta_days(ticks_left, pop)`，六個舊站點全改（`goal_resolver` flat 3.0／
`decision_context` settle_eta／`persist_strength:95` ÷pop／`faction_ai` `_eta_build` ÷pop／
求生蓋田閘 ÷pop÷240／`decision_context` 擴點 ÷240 無 pop）。
**窮盡宣告**：剩餘 `BUILD_TICKS|construction_ticks_left` 命中全是「讀進度/判在不在施工」。
★**請打這個負斷言**（我今天已經被自己的「窮盡」grep 漏掉過一次）。

### ②★「假設不靜默」的做法是否站得住
分母 ＝ `TICKS_PER_DAY / NEAR_CADENCE`（**同源推導，禁手抄 24**），
另有 `_outpost_tick_runs_in_near_pass()` **讀 registry** 驗證假設，
失效時 `Probe.bump("build_eta.cadence_assumption_stale")`。
★**我認為這是本票最有價值的部分**（假設會自己喊救命，不是靜默腐爛），
但**請你判它是否真的讀得到 registry、以及 stale 時會不會反而讓估值靜默錯下去**。

## 行為變化（intended-change，spec §4 已列）
#3 持守／#4 糧橋 **變寬鬆**（曾被高估 24× 嚇跑）；#5 求生蓋田閘 ★**變嚴**（曾低估 10× 放行蓋不完的案子）；
#1/#2/#6 歸位。`det fp` 變 ＝ intended-change、三跑穩定。
★**harm 未坐實這條守住了**：修法理由是**正確性**，不是已證明傷害。

## 閘況
`estimator-lineage-scan.sh` **規則2 綠**（本票存在理由）／headless **8 ＝ baseline 0-new**／憲法 PASS／
`seam-gate` 因 tier 改 full ⇒ **現在需要 R²verdict ＋ measure ＋ QA**（我已請 measurer 補一輪）。
