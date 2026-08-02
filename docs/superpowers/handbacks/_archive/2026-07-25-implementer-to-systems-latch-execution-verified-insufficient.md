---
from: implementer
to: systems
status: consumed
topic: "[★execution-verified FAIL·latch 必要但不足·directive leak 永久棄工地+resume 失效→complete=1·需 2nd-layer 決策] feat/construction-commitment-latch 8ffb8ab8 off obs-tap 2a5bb412。latch 照 spec 做完+TDD 6/6(含 execution-end advance_tick outpost level>0)。★但 execution-verified(1mo seed1337 tap)FAIL:latch fires 8332(擋 cadence steal 有效)但 complete=1/stall=3555 未改善=禁 ship。根:任一 leak(leak_directive=439 主/crisis19/force12)即永久棄工地(builder→外交留在格,resume 召回~0 失效→stall 永久累積)。latch 下 last_decision_tick 不更新→faction 每發 directive→building member reeval 漏→棄。spec 延 followup 的 resume 實為完工 load-bearing(任何 leak 永久棄需 resume 救回;latch 減 leak 但無法 0 leak)。需 systems 判 2nd-layer(latch+resume 一起修/directive 對 building 例外/member vs 專屬 subteam builder)。閘:headless 0-new+gate 74 removed=0+determinism 3跑 byte-identical(0ed053f2)。"
branch: feat/construction-commitment-latch
commit: 8ffb8ab8
base: 2a5bb412 (obs-tap，含 taps+A1)
spec: docs/superpowers/specs/2026-07-25-construction-commitment-latch-A1-fix.md
---

# ★execution-verified FAIL：latch 必要但不足（directive leak 永久棄工地 + resume 失效）

照 spec 做完 latch，TDD 全綠，**但 execution-verified（outpost_built>0）不達標**（spec 硬標準：跑起來 outpost>0 才算修好）。誠實回報，不 ship complete=1。

## 做（照 spec §要做，皆綠）
- ①`_should_reeval` build latch（施工中 skip 例行 cadence；`force_reeval` 穿透，威脅 :423 傳 true 繞）。
- ②`check_construction_timeout` → `TaskArbiter.release(ct)` 對稱。
- TDD `construction_latch_test` **6/6**（含 ★★execution-end `advance_tick` 驅真 tick → outpost_level>0 真完工 + ★★威脅 force 繞 latch 能逃 + 深餓 crisis 繞 + 完工釋放）。
- 閘：headless 0-new + gate 74 removed=0 + determinism 3跑 byte-identical `0ed053f2`（latch 核心）。

## ★execution-verified 發現（1mo seed1337 construction tap，硬標準檢查）
| 指標 | 值 | 解讀 |
|---|---|---|
| `reeval.build_latch` | **8332** | latch **真 fire**，擋 cadence argmax steal 有效 |
| `construct.complete` | **1** | ★**未改善**（pre-latch 也 1）= 沒修到完工 |
| `construct.stall` | 3555 | 未消退（pre-latch 3250） |
| `reeval.build_leak_directive` | **439** | ★主漏：building member 被 faction directive 拉去 reeval |
| `reeval.build_leak_crisis` | 19 | 深餓漏（少） |
| `reeval.build_leak_force` | 12 | 威脅漏（少，正當逃命） |

stall samples：施工隊**在工地格**（ct_pos==tile）但 `current_task=外交`（被 directive reeval 拉走，非離場）。

## 根（execution-verified 坐實，spec 單層 latch 未涵蓋）
1. **latch 下 `_decide_unified` 早退（:1523）→ `last_decision_tick`（:1528）不更新** → building member 的 `last_decision_tick` 凍在舊值。
2. faction 發 directive（`directive_change_tick=now > 舊 last_decision_tick`）→ `_directive_fresh` true（在 latch **上方**檢查）→ building member reeval → argmax 選外交 → **棄工地**。
3. **任一 leak = 永久棄**：builder→外交後不回，`_try_resume_construction` 召回 measurer 測 0.5-0.7% ≈失效（owner/resident gate 擋）→ 工地永久 stall。
4. ∴ latch 減 leak（94.6% held）但**無法 0 leak**；只要 1 次 directive leak → 該工地永久棄 → complete≈0。**spec 延 followup 的 resume 實為完工 load-bearing**（非 optional watch）。

## 需 systems 判（2nd-layer，我不逕自決策=第 3 次改 spec 設計）
latch 是對的（必要）但單層不足。完工需補其一/組合：
- **(A) resume 治本**（spec 原延 followup）：`_try_resume_construction` 放寬——優先召回 `construction_team_id` 原隊（它常還在工地格，只是 task 變外交）→ 一起本刀修。
- **(B) directive 對 building 例外**：building member 不被 directive 拉（違 spec「directive 繞 latch」，需 systems 認可 faction 命令 vs 施工承諾優先序）。
- **(C) member vs 專屬 subteam builder**：施工改由 `_evaluate_subteam:1718` 保護的專屬子隊（不受 directive/cadence），infra 就地 member build 退場。架構較大。

我傾向 **(A)**（最小、治本、與 latch 同刀=whole「一次修全部卡點」符 blueprint；latch 減 leak + resume 救回殘 leak = 閉環）。resume 只需優先召原 construction_team_id 隊（在格），繞現 owner/resident gate。

## 待
systems 判 (A)/(B)/(C) → 我續修（execution-verified 重驗 outpost_built>0）→ measurer 重量。latch WIP 已 commit。
