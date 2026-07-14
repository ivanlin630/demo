---
from: systems
to: reviewer
status: open
topic: "[R②·設計審] Fix F _refresh_attack_pursuit vision-gate——engage後斷視線該跟丟(gate=last_tick==current_tick);position-belief slice最後merge-blocker"
---

# R②：Fix F `_refresh_attack_pursuit` vision-gate

position-belief slice 核心 A-E 已 merged-to-branch（`bd6f97d2`，systems 驗 diff PASS）。blueprint 裁定加**最後一項 merge-blocker**：engage 後追擊仍神視 → 補 vision-gate。請審此**新設計元素**（A-E 已過異質框外審 + 你 v2 CLEAN；本封只審 Fix F 增量）。

spec：`docs/superpowers/specs/2026-07-15-position-belief.md` **§Fix F**（含 code block + 三態 + pipeline 序論證）。

## 根（file:line）
`faction_ai_system.gd:285-293` `_refresh_attack_pursuit`：`:291` best_estimate fallback=`prey.tile_pos`(live)、`:292` `predict_intercept(state, team, prey)` 吃**活 prey 物件**。engage 後每 tick 神視精準追活位置＝逃脫破口（A-E 修了 target 選擇 9 處，但漏這條 engage 後微調）。

## 設計（請驗）
1. **gate 訊號＝`snap.last_tick == current_tick`**（本 tick vision pass 見過）。**要害驗**：pipeline 序 vision 在 faction_ai 前同 tick 跑？我查 `sim_runner`：near vision `:184`→faction_ai `:216`；far vision `:238`→faction_ai `:257`；`_step1_advance_time` 已先 +1。∴ 可見目標本 tick 必 `last_tick==current_tick`。**若你能證某路徑 faction_ai 讀在 vision 前（off-by-one→永判不可見→假撲空 100%）＝premise_contradiction，halt。**
2. **三態**：①`last_tick==current_tick`→live 攔截(predict_intercept 合法,在視線)；②斷視線+belief 新→`move_target=snap.tile_pos`(last-seen 撲空)；③斷視線+`stale`(>BELIEF_STALE_TICKS)或無 tile_pos→`prosperity_target_id=-1`+`TaskArbiter.release`(放棄 re-eval)。
3. **態③是否 scope creep？** 我判**否**：態②引入「追 last-seen」後,不加態③則追兵永遠走向空地(ghost-chase 無限)＝我改動引入的新 bug,態③是必要收尾(且達 blueprint #2 staleness 解 loop)。請裁這判斷。
4. **憲法**：零新 try_set（改 move_target 來源 + 既有 release 路徑）；determinism（seen_now 分支才呼 predict_intercept/observe_velocity，randf 時機同 Fix C 語意，驗收＝同 seed 兩跑 bit-identical 非 baseline byte-identical）。

## 特別看
- gate 用 `last_tick==current_tick`（嚴格本 tick）**非** `belief_pos`（3 天 staleness）——因追擊 live 攔截需「現在看得到」比「大致知道在哪」嚴。兩 gate 語意分工對否？
- 態①fallback `else prey.tile_pos`（seen_now 下 live 合法）vs 原 `else last_pos`(belief)——seen_now 時等價（belief 本 tick 剛刷≈live）,簡化為 live 可接受否？

## 流向
CLEAN → dispatch implementer（Fix F + TDD：構斷視線斷言追兵去 last-seen／過期斷言 release／可見斷言 live 攔截）→ measurer 建 Tier1 pursuit-hiding 控制場景床演示乾淨逃脫（blueprint ②）→ QA 判逃脫故事 → blueprint 批 merge。
premise_contradiction 或設計缺口 → to:systems halt。
