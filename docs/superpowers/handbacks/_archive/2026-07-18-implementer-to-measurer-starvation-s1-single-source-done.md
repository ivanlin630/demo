---
from: implementer
to: measurer
status: consumed
topic: "[絕境經濟 S1·survival單一源 done·待 sim measure] ①完成:DecisionOptions.priority_for(opt)單一源(survival-class→PRIO_SURVIVAL/threat→PRIO_THREAT/else→DISPATCH),全5 dispatch路讀(含grep捕第5路_try_join_target)。char bed PASS,gate 64 removed=0,headless 3-baseline(無新失敗)。★行為變:_evaluate_solo/_decide_subteam/_try_join_target survival @50→@80,必走 is_sim=true sim measure(seed1337/42/4201)→.qa.json 故事稽核(dogfood verification-gate)。branch feat/starvation-desperation-fix@1132bf0c off origin/main@5a2d9787。②famine-amplifier=S2 續做中(下一 handback)。"
---

# 絕境經濟 S1 done：survival 保序單一源（待 sim measure）

## 做了什麼
`DecisionOptions.priority_for(opt) -> int` 單一源（option→priority 一處定）：
- survival-class（SURVIVAL_OPTION_SET + "survival"）→ `PRIO_SURVIVAL`(80)
- threat-class（備戰/迎戰/求和）→ `PRIO_THREAT`(70)
- else → `PRIO_DISPATCH`(50)

全 dispatch 路一律讀源（**5 路，含 grep 捕第 5 路**，避 whack-a-mole team19/1774 教訓）：
- `_decide_unified`（threat/survival 收進）
- `_decide_subteam`（子隊，@50 改讀）
- `_try_join_target`（★grep 捕第 5 路，TASK_JOIN=併入 硬指派，改讀 `priority_for("併入")`）
- `_evaluate_solo`（硬 @50 改讀）
- `_trigger_survival`（@80 收進）

## 驗（我側）
- char bed `survival_single_source_test.gd` **ALL PASS**（priority_for 三 class 映射 + 階層 80>70>50）
- `constitution_gate` **PASS**（sites=64, removed=0；priority_for 純新增無 fingerprint 動）
- full headless `=== DONE ===`，**同 3 個 pre-existing baseline 失敗**（[p2a] join weight 0.41 / combat_target≠-1→197 擋 / rung 擴張+武力 intent）— **無新失敗**

## ★需你做（S1 measure，走新 verdict schema）
- **`.measure.json` `is_sim: true`**（organic sim；行為變在 solo/subteam/join 三路 survival preempt @80）
- **含硬 seed1337 + 42 + 4201**
- QA 出 **`.qa.json` verdict**（gate 強制 sim 缺 QA→FAIL；dogfood 剛 merged 的 verification-gate）
- 驗點：
  - solo/subteam/join 隊 survival 現能 preempt 同層 dispatch task（@80）— no_forage「task 切不掉」型應鬆
  - **不 over-preempt**（survival @80 不該壓垮 threat 防禦；threat=70 < survival=80 是 intended，但驗世界不塌）
  - 自限 attrition + 世界 sustain

## 注意：S1 單獨 ≠ no_forage 全歸零
- S1 修「task 切不掉」型（dispatch 路 priority 不一致）。
- 「試了 survival option 但輸掉」型需 **S2 famine-amplifier**（續做中）。
- 全 no_forage 歸零 measure 應等 S1+S2 合體；S1 measure 先驗單一源不誤傷 + 世界不塌。

## 給 systems（不變量）
survival 保序 = 命運不看走哪 dispatch 路；solo/unified/subteam/join commit priority 一致（皆 PRIO_SURVIVAL）。建議入 `invariants.md`。

## 溯源
dispatch `2026-07-18-systems-to-implementer-starvation-fix-impl.md`；[[project_desperation_economy]]。
