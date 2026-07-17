---
from: systems
to: implementer
status: consumed
topic: "[dispatch·低優先] mark batch2 apply:7 terminal-legit inline gate-ok(comment-only 零行為)。R② CLEAN 無 collision。同 bucketB 法:inline # gate-ok 於每 fingerprint 全 detector-hit 行(含 reviewer 補查 _facility_deficit 的 :3092/:3118)。跑 gate 確認掉出待清單。baseline_v2 re-freeze 我 post-merge 管(你報 sites 前後數)。worktree off origin/main@37350f06。"
---

# mark batch2 apply：7 terminal-legit inline gate-ok（comment-only）

## 標（每 fingerprint 全 detector-hit 行 inline `# gate-ok: <理由>`，同 [[reference_constitution_gate_marking]] 機制）
- `diplomatic_ai_system.gd::_send_diplomacy_message::rng`（:174 `str(randi())`=event-ID 非決策骰）
- `diplomatic_ai_system.gd::try_proactive_diplomacy::rng`（:130 `randf()<慎重³`=人格加權且陡,案③ blueprint 裁）
- `faction_ai_system.gd::_facility_deficit::early_return`（全 guard 行,含 :3086）
- `faction_ai_system.gd::_facility_deficit::threshold`（全 hit 行:含 :3104 + **reviewer 補查 :3092/:3118**,皆 world-mechanic/guard）
- `faction_ai_system.gd::_facility_terrain_fit::threshold`（:3050 等 resource-presence geography）
- `faction_ai_system.gd::_pick_facility::early_return`（:2973 等 guard）
- `faction_ai_system.gd::_pick_facility::threshold`（:2968 等 selection/guard）

## ★不碰（R② 排除，STAY）
`_evaluate_new_outpost_location::threshold`（collision:藏 MIN_BUILD/MINING_GREED）、`_consider_extraction::threshold`（extract_score>0.4 死常數序5）、`_evaluate_independent_strategy::threshold`（AMBITION 序5）、全 24 CONVERGENCE-TRACKER。

## 驗收
跑 `.\tools\godot.ps1 --headless --script scripts/debug/constitution_gate.gd`：上列 7 fingerprint 掉出待清單（sites 72→65），STAY 項續在。**若某 fingerprint 沒掉=漏標行**（回報）。handback 報 sites 前後 + 哪些清了。**comment-only 零行為,免行為測**（跑 import 確認 parse clean）。

## 溯源
R² CLEAN `2026-07-17-reviewer-to-systems-bucketb2-r2-verdict.md`；`54-triage.md`；[[reference_constitution_gate_marking]]。
