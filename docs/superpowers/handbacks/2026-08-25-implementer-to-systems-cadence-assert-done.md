---
from: implementer
to: systems
status: consumed
slice: build-eta-single-source
branch: feat/build-eta-single-source @ aa397695 (pushed；★SHA 變了，measurer 若已對 26b87684 起跑請注意)
topic: cadence 斷言已加(headless 綠、每日推進 24 次);reviewer 那句「偵測≠告知」我照收並記下同族血證;附 SHA 更新
---

# cadence 假設已升成 headless 斷言

**branch**：`feat/build-eta-single-source` @ **`aa397695`**（原 `26b87684` + 這一顆）
★**SHA 變了** —— measurer 若已對 `26b87684` 起跑，那輪仍有效（**這顆只加測試、零 production 改動**），
但 `.measure.json` 請標 `26b87684`，別標成 `aa397695`。

## 加了什麼
`headless_test.gd` 新增 `_test_build_eta_cadence_assumption()`：
- 直接讀 `SimRunner.SYSTEMS`，斷言 `outpost_tick` 的 `lod == LOD_NEAR`
- 再斷言 `OutpostSystem._outpost_tick_runs_in_near_pass()` 與它一致（**兩邊讀法不准漂**）
- 實跑輸出：`build_eta cadence 假設 OK（每日推進 24 次）`

**headless ＝ 8 條 ＝ baseline，0-new**（新斷言綠）。

## reviewer 那句我照收
> 「失效時 `Probe.bump`」只是**偵測**，不是**告知**。

★**他是對的，而且我這輪自己才剛吃過同族的虧**：
A1 那兩顆會說謊的儀器、以及 QA 在 convoy 抓到的 `task_arbiter` 讀錯狀態 ——
**共同形狀都是「有東西在記錄，但沒有人被那個記錄叫醒」。**
`Probe` 是給**回頭查**用的，不是給**當場擋**用的。**能靜態判定的假設就該進會自己跑的閘。**

## 沒動的
⛔ 沒有新建閘、沒有動 `expect-min-gate.sh`（照你寫的：headless 斷言已經是會自己跑的閘）。
⛔ runtime 那顆 `build_eta.cadence_assumption_stale` **保留**當佐證，但不再是主要防線。

## 現況
`build-eta-single-source`：`tier: full`（你自糾的）／R² **CLEAN**／headless・det×3・憲法 **全綠**
⇒ 缺 **measure ＋ QA**，等那兩件。

`camp-construction-duration`：儀器已裝、**第一趟跑中**（base ＝ `build-eta-single-source`，spec §4 寫死的順序）。
★注意它 stack 在 `26b87684` 上（不含這顆斷言）——**純測試差異，不影響量測**；
merge 時我會先 rebase 到 `aa397695`。
