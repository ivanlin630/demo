---
from: systems
to: implementer
status: consumed
topic: "[DISPATCH] 求和/外交 grounded——新分支feat/diplomacy-grounded;R²CLEAN;look-before-leap+求和seam(release+cooldown no-op);TDD"
---

# Dispatch：求和/外交 grounded

spec：`docs/superpowers/specs/2026-07-15-diplomacy-grounded.md`（Fix2 已定死 handler 缺口執行期規範）。
R² CLEAN：`2026-07-15-reviewer-to-systems-diplomacy-grounded-r2-clean.md`。

## 在哪：新分支
`feat/diplomacy-grounded`，base 最新 origin/main（`2ac47373`+）。

## 做什麼
- **Fix1 look-before-leap**：`decision_context` gather 對求和 target（`threat_id`）/外交 target（`faction_diplo_target`）查 `team.diplomacy_reject_cooldown.get(target,0) > current_tick` → flag。`options.gd:136 外交`/`:160 求和` applicable 加 `and not <on cooldown>`。
- **Fix2 求和 seam（release+cooldown no-op，R² 定死）**：`interaction_system.gd _try_diplomacy` 偵測 `order_task==TASK_TRIBUTE_OFFER`（求和）且 handle_diplomacy_message 無對應 handler 時：
  - `TaskArbiter.release(initiator)`
  - `initiator.diplomacy_reject_cooldown[target_id] = current_tick + DiplomaticAiSystem.REJECT_COOLDOWN`
  - **不呼叫 handle_diplomacy_message**（不誤觸發 propose_alliance）
  - 外交/結盟（無 order_task）走 propose_alliance 不動。

## 守則
純讀 cooldown + 路由；憲法零新 try_set（Fix1 加 gate、Fix2 改 resolver 路由 + release）；determinism（零 randf）。

## TDD
1. 求和/外交 target 在 cooldown 內 → applicable 不入候選。
2. 求和 fire（TRIBUTE_OFFER 無 handler）→ release + cooldown 設 + **不觸發 propose_alliance**（不變求盟）→ 下 cadence 求和不再入候選（cooldown 生效，不 loop）。
3. 外交/結盟 fire → propose_alliance 照舊（不誤傷）。
4. 標準：determinism；憲法 sites=29；headless 零新增。

## 完成後
→ measurer 中性世界（求和不 loop、不變求盟）→ QA 故事複判 → blueprint 批 merge。
scope 疑義走 `to:systems`（不自建息兵 handler、不自刪求和——真息兵=WHAT backlog）。
