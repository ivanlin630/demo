---
from: systems
to: reviewer
status: consumed
topic: "[R②·低優先於 threat-oracle] mark batch2:7 terminal-legit gate-ok inline 標(2 rng + facility guards/world-mechanic)。investigator 分類 35 待閘=24 tracker STAY/9 terminal/2 death-constant STAY。★已排除 _evaluate_new_outpost_location::threshold(collision:同 fingerprint 藏 MIN_BUILD/MINING_GREED)。對抗雙向查 over-mark(collision/藏 tracker/藏 death-constant)。CLEAN→implementer inline 標+re-freeze。"
---

# R②：mark batch2 — 7 terminal-legit gate-ok（對抗雙向查 over-mark）

## 背景
零殘留尾。investigator 逐 code 分類 72 baseline 的 35 未標待閘：**24 CONVERGENCE-TRACKER**（真統一 tracker，STAY）/**9 TERMINAL-LEGIT**/**2 DEATH-CONSTANT**（序5，STAY）。本批只審 9 terminal-legit 中的 **7 乾淨**（排除 1 collision）。

## 提案標 gate-ok（7 fingerprint）
- `diplomatic_ai_system.gd::_send_diplomacy_message::rng`（:174 `str(randi())`=event-ID 生成，同已標 `_maybe_request_join_player::rng` false-positive 族）
- `diplomatic_ai_system.gd::try_proactive_diplomacy::rng`（:130 `randf()<慎重³`=人格加權且陡，同已標 `consider_betrayal::rng` 案③ blueprint 裁）
- `faction_ai_system.gd::_facility_deficit::early_return`（:3086 `if entry.is_empty(): return 0.0` 等 guard）
- `faction_ai_system.gd::_facility_deficit::threshold`（:3104 `if tgt<=0.001` 等 world-mechanic/guard）
- `faction_ai_system.gd::_facility_terrain_fit::threshold`（:3050 resource-presence geography `>0.0`）
- `faction_ai_system.gd::_pick_facility::early_return`（:2973 `if best=="": return {}` guard）
- `faction_ai_system.gd::_pick_facility::threshold`（:2968 `if level>0: continue` 已滿跳過 guard + 選址評分）

## ★已排除（collision，STAY）
- `_evaluate_new_outpost_location::threshold`：investigator 標 :2727（outpost_level>0 guard）TERMINAL，**但同 fingerprint 藏 MIN_BUILD_SCORE/MINING_GREED_THRESHOLD**（B-facility 選址/照妖鏡），bucketB reviewer 已判 STAY。整把標會靜默豁免那些=藏殘留。→ 不標。

## ★對抗雙向查（[[reference_constitution_gate_marking]] fingerprint 粒度 collision 陷阱）
每個 7 fingerprint 請確認：**同 func::type 下所有 detector-hit 行是否全 terminal-legit**（無混 tracker/death-constant/照妖鏡）？特別：
- `_pick_facility::threshold`：:2968 是 guard，但該函式有無 DEMOLISH_MARGIN/min-score 的 threshold hit 混入？（RHS 小寫可能非 THRESHOLD_RE 命中，但請驗）
- `_facility_deficit::threshold`：0.6 armed-ratio/10.0 ore 等 world-mechanic const 全 legit 否，有無藏人格決策硬閾？

## 判準
- CLEAN（含「7 個各無 collision」）→ dispatch implementer inline `# gate-ok` 標 + 跑 gate + re-freeze（72→~65）。
- 揪 collision/over-mark → 該項移出，STAY。

## 溯源
investigator 分類；[[reference_constitution_gate_marking]] collision 陷阱；bucketB R² collision 血證；`54-triage.md`。
