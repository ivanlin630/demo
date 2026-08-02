---
from: systems
to: implementer
status: consumed
topic: "[實作·A1 stall 根修·construction commitment latch·R²v2 CLEAN·spec=2026-07-25-construction-commitment-latch-A1-fix.md·★execution-verified(outpost_built>0)才算修好非只跑綠] A1 stall 根=construction commitment(TASK_BUILD)在 unified 決策層無 latch,施工隊每 cadence 被 _decide_unified argmax 搶去外交(measurer 6mo:stall 95.6-96%,ct_reason=unified/ct_task=外交)。修①_should_reeval 施工中 skip 例行 cadence reeval(★force_reeval 參數繞:威脅:401-423 傳 true 繞 latch 能逃,別悶死逃命)②check_construction_timeout release 對稱(防 latch 永卡)。★TDD execution-end 驅真 tick(FactionAI.process+Movement.process+construction tick)非 teleport,outpost_built>0 真完工才算。威脅繞 latch 測必補(與深餓分開,不同 gate)。閘:headless 0-new+gate 74 removed=0+determinism 3跑 byte-identical。→handback to:measurer execution-verified 重量(outpost_built>0)。"
branch: feat/construction-commitment-latch
---

# 實作：construction commitment latch（A1 stall 根修）

R²v2 CLEAN（reviewer 審憲抓威脅悶死洞已訂正 + 自排查無第二同款漏洞）。

## spec
`docs/superpowers/specs/2026-07-25-construction-commitment-latch-A1-fix.md`（完整根定案 + 修①② + 憲法論證 + TDD，讀它）。

## 根（measurer 6mo tap 坐實）
construction commitment（TASK_BUILD）在 unified 決策層無 latch：外交/build 同 `PRIO_DISPATCH(50)` raw 覆蓋 + `_should_reeval` cadence 分支漏豁免 TASK_BUILD → 施工隊每 cadence 被 `_decide_unified` argmax 搶外交（stall 95.6-96%）。

## 修（spec §要做）
- **①`_should_reeval` construction commitment latch**：`current_task==TASK_BUILD` → `return false`（skip 例行 cadence argmax）。**★force_reeval 參數穿透**：`_decide_unified(state,team,force_reeval:=false)` + `_should_reeval(...,force_reeval:=false)`，`_should_reeval` 開頭 `if force_reeval: return true`（繞 latch+cadence）。**威脅段 `:423` → `_decide_unified(state,team,true)`**（威脅 force 繞 latch，施工隊能逃）。其他呼叫（1463/1485/1488/1920）預設 false。
  - ★實作細節（哪些呼叫傳 force、unified:1523 vs solo:1923 兩 `_should_reeval` 穿透）你判——**硬約束：威脅 force 路徑（:401-423）必繞 latch，純例行 cadence 被擋**。
- **②`check_construction_timeout`**：取消時 `TaskArbiter.release(ct)`（對稱 `_complete_construction:393`，防 latch 永卡邊角）。

## ★TDD（execution-end，禁 teleport；spec §TDD）
- `_test_construction_commitment_latch`：派子隊建 → start_build → **驅真 tick 迴圈**（FactionAI.process+Movement.process+construction，非 teleport）→ 施工隊 TASK_BUILD 不被外交蓋、**最終 outpost_level>0 真完工**。對照無 latch baseline（被搶、不完工）。
- **★★威脅繞 latch 測（R² 必補）**：施工中 + `threat_react≥threat_threshold+PREEMPT_MARGIN(2.0)` → `:401-423` force reeval → 繞 latch 能逃。**與深餓測兩回事**（深餓走 `_decision_crisis`、威脅走 `:401-423`），分開測。
- 完工釋放驗（完工後 current_task 釋放非卡 TASK_BUILD）。

## ★★execution-verified 硬標準（上輪教訓）
- fix 驗收 = **跑起來 outpost_built>0**（非只 headless 綠 / R² CLEAN）。TDD 真完工 + measurer 重量坐實。
- ★報 TDD 數字前實際跑讀 `=== DONE ===`（流程項）。

## 閘 + 交付
- headless 0-new SCRIPT ERROR + `constitution_gate` sites=74 removed=0（latch 是新 gate-ok 嗎？——`_should_reeval` build latch 是 commitment 執行 latch 非決策閘，若 gate 偵測命中需 inline `# gate-ok` 註 legit 理由並確認 sites 計數，見 memory `reference_constitution_gate_marking`）+ determinism 3跑 byte-identical。
- handback `to:measurer`：重跑 A1 focused（seed1337/42，6mo）→ **outpost_built>0**（forest founding+facility 真完工，對照 stall 95.6% baseline）+ stall 消退 + construct.complete 上升 + reeval.build_latch fire。→ 數字 to:blueprint（release-pass）+ specimen to:QA。
