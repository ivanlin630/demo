---
from: implementer
to: measurer
status: consumed
topic: 統領日常領導成長 實作交付 — loop2外層cadence保底路徑;branch feat/command-tenure-growth已push,待驗收
---
# Hand Back: 統領日常領導成長

branch `feat/command-tenure-growth`（已 push，疊 origin/main base cfa6d92）。spec `docs/superpowers/specs/2026-07-12-command-tenure-growth-technical.md`。

## 實作摘要
- `scripts/simulation/faction_ai_system.gd`：
  - 常數（頂）：`LEADERSHIP_TENURE_INTERVAL = WorldState.TICKS_PER_DAY`、`LEADERSHIP_TENURE_GROWTH = 0.0006`（TEST VALUE）。
  - `_grow_leadership_tenure(state, team)`：守 `leader_id==-1`/null；`growth = LEADERSHIP_TENURE_GROWTH × 魅力 × (0.5+毅力×0.5) × get_skill_mult(統領)` → `SkillSystem.cap_add(leader,"統領",growth)`。復用 `SkillSystem._grow`/`on_reaction` 同款公式（一致，非另發明）。
  - 呼叫落點：`_evaluate_all_body` loop2（`for tid in state.teams`）**三分支（子隊/獨立/faction成員）判斷之前的外層**統一觸發 → 覆蓋所有 leader 型別（含 player leader，被動經驗非 AI 決策）。cadence gate `% LEADERSHIP_TENURE_INTERVAL == 0`。
- `scripts/debug/headless_test.gd`：+1 test `_test_command_tenure_growth`（成長生效 / cap≤1.0 / leader_id==-1 不崩），PASS。

## 我方自驗（非驗收，供參）
- 量測：統領 0.25 → 0.265300 經 50 個 INTERVAL（≈+0.0003/日，對齊 spec §2 推導：12mo≈+0.10 → 約一年爬過門檻 0.35）。cap 守 1.0，無 leader 不崩。
- headless `=== DONE ===`，**新增 0 SCRIPT ERROR**。3 pre-existing assert（p2a join weight / combat_target≠-1 197隊 / rung 展可）在 **origin/main baseline 亦完全相同**（前 slice 已對照坐實）→ 非本 slice 回歸。
- constitution_gate PASS（sites=29，removed=0）。

## 待驗收（spec §驗收法，全你產數字）
1. **B2 解鎖**：default.json 12mo——`gate_fail_b2_command` 從 100% 卡死 → 有通過案例；leader 統領 12mo 爬升軌跡（pre：凍 ~0.25；post：漸升過門檻 0.4）。
2. **established > 0**：對照 pre 恆0。**誠實區分**「B2 解鎖」vs「established 大漲」——established 仍受 A 門（人口 82.7% 卡，第二層）+ B4 readiness 上游制約，B2 解未必立刻大量 established；B2 不再 100% 硬牆即達本 slice 目標。
3. **P4_expand 不回歸**：繁榮隊統領成長路徑仍在（`_score_expand`/REACTION_SKILL_MAP/on_reaction 零改）。
4. **determinism**：同 seed byte-identical（含新成長）。**★baseline 位移標記**（統領→established 行為改動，非 regression，比照 world-gen variety 先例標「command-tenure 位移」重生 baseline）。
5. **融合閘**：coin/framework/sanity 綠（constitution 我已跑綠）。

## 連動風險
- **統領→下游 established/faction 決策位移**：統領數值全面微升 → P4_expand argmax、diplomacy readiness、其他讀統領處軌跡位移。此即 spec §3 baseline 位移，measurer 重生 baseline 標記。
- **combat-197 pre-existing assert**：seeded 全 sim assert，本就在 baseline fail；統領位移或改其計數但仍 pre-existing failure，非本 slice 新增。
- 速率 TEST VALUE：measurer 量實際 12mo 軌跡後，blueprint/systems 校 GROWTH/INTERVAL。
- A 門人口第二層 + B4 readiness 未解（另 slice）——established 完整解需上游。
