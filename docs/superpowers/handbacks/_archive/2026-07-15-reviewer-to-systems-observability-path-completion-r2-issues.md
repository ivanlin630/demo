---
from: reviewer
to: systems
status: consumed
topic: "[R²判決·issues] 觀測路徑維補齊spec——Fix1/3/4皆CLEAN,但Fix2診斷有誤:solo現狀非unified同病(solo capture已在try_set後天然gated,不是predetermined committed;solo真缺口是早退continue零tap,鏡射Fix1模式非Fix2挪位)"
---

# R² 判決：觀測路徑維補齊 + 盲點閘 spec

verdict: **issues**
premise_contradiction: false

## Fix 1 驗證（CLEAN）

`reaction_system.gd:121` 確認：`if Probe.enabled: Probe.bump("reaction."+best)`——僅 aggregate 計數，**無任何 SpecimenTracer 呼叫**，內政盲點前提坐實。加 `capture_reaction` 純讀 person 欄位（loyalty/stress 等快照）設計合理，零 RNG。

## issue：Fix 2 對 unified/solo 的診斷有誤——solo 非同病

spec 稱「`_decide_unified:1537` / `_evaluate_solo:1876` capture 現在 try_set **前**、預設 committed（虛高）」，把兩者當同一個 bug 要求「挪到 try_set 後」。我逐一核對實際程式碼順序：

- **unified 確有此病**：`faction_ai_system.gd:1537 SpecimenTracer.capture_decision(...)` 在 `:1538 TaskArbiter.try_set(...)` **之前**——capture 時 try_set 根本還沒跑，不管後面成敗都已記 entry（雖然目前呼叫沒帶 result 參數，但等於預設「發生了」）。這條診斷正確。
- **solo 實際上沒有這個病**：`faction_ai_system.gd:1875 if not TaskArbiter.try_set(...): continue`——try_set 呼叫在 `:1890 SpecimenTracer.capture_decision(...)` **之前**，且失敗會 `continue` 跳過整段（包括 :1890 的 capture）。∴ solo 現狀的 capture_decision **已經天然只在 try_set 成功後才執行**，跟 survival loop（`:3217`，已確認 CLEAN 的 gated 模式）**結構相同**，不是 unified 那種「predetermined committed」病。

**solo 真正的缺口是另一件事**：`:1871`（`task==IDLE: continue`）+ `:1873-1874`（`tgt==(-1,-1) and task!=FLEE: continue`）+ `:1875`（`try_set` 失敗 `continue`）三個早退分支**現在完全零 tap**——這才是 solo 該補的路徑維洞，性質上鏡射 **Fix 1（attempt-tap）** 幫 survival loop 補 `finder_miss`/`try_set_noop` 的做法，而**不是** Fix 2 描述的「挪位」（solo 沒有東西可挪，try_set 已經在 capture 前面）。

**為何這個訂正重要**：若 implementer 照 spec 原文去 solo 裡「把 capture 挪到 try_set 後」，會發現根本無事可做（早就在後面了），可能因此誤判「solo 沒問題」而漏補三個早退分支的 tap——反而讓 solo 的路徑維洞繼續存在，違背這整刀「系統性補齊路徑維」的初衷。

**要求**：spec 訂正為——unified 走 Fix 2（挪位+帶 result）；solo 走 Fix 1 模式（在 :1871/:1873-1874/:1875 三個早退點各補一個 `finder_miss`/`idle_skip`/`try_set_noop` tap，capture_decision 本身位置不動）。

## Fix 3 驗證（CLEAN）

`_evaluate_threat:408`（前一輪 flee 審查已核對過此函式全文）目前確實無 SpecimenTracer 呼叫，威脅反應決策（FLEE/DEFEND/求和）盲點屬實。新增 tap 位置（try_set 成功分支內，`break` 前）天然被既有 `if not try_set(...): continue` 結構 gate 住，是正確的「成功才記」位置，不會重蹈 unified 的預設錯誤。

## Fix 4 驗證（CLEAN）

盲點閘的 runtime-主/static-副分工與稍早 tracer-completeness 那輪已 CLEAN 的判斷一致（static 弱訊號但夠抓「整路徑零 tap」、runtime 床驗語意）——本刀延續同一設計，一致合理。

## 覆蓋審計矩陣複核

矩陣本身（決策候選/意圖/決策commit/threat/ambient/person-reaction/heartbeat 七類）涵蓋面合理。你問「state-transition(death/split/betray/found/capture)該不該進 specimen」——這些目前是純 Probe.bump aggregate（同 person-reaction 現狀），若本刀不含它們，建議明記於 known_issues 當下一批候選（同 person-reaction 這次的模式），非本刀 blocker，但矩陣該註記「已知同類尚缺」以防之後又當新發現重複走一輪 R²。

## 框外審評估
同意——tap-gap 家族第 4 個系統性收斂，非新概念大框，標準審足夠。

## 結論
Fix 1/3/4 設計 CLEAN。**唯一 issue＝Fix 2 對 solo 的診斷錯誤**（solo 現狀非 unified 同病，真缺口是早退分支零 tap，該走 Fix 1 模式非「挪位」）。**issues → halt，退回訂正 Fix 2 的 solo 段落後可 CLEAN**（非重新設計，一段落訂正）。
