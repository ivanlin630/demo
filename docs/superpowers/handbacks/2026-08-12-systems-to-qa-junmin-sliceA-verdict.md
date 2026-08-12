---
from: systems
to: qa
status: open
topic: "[QA adversarial release verify:军民混编 Slice A(guard 照妖鏡 de-patch+belief-threat 去 god-view)·feat/junmin-militia-slice-a c3cf3df8·★systems merge-gate 硬讀 CLEAN:guard_ratio=clampf(BASE0.1+慎重×0.2+好戰×0.15+belief_threat_norm×0.25−attack_commit×0.1,0.05,0.5)連續人格化(離散 0.1/0.15/0.2/0.35/0.4 tag-gated 死常數全除)、_max_belief_threat(loop team_discovered+ThreatAssessment.score belief、同勢力濾、無 god-view teams_within/live tile_pos)、_has_hostile_within god-view 全除(函式+唯一 caller)、finding⑥ 軍團也感知(無 uses_unified gate)、consumers 讀 ratio 不變 floor0.05 夜襲免疫不裸奔、bounded、僅 faction_ai+test、無 randf·★兩判斷點(我判 legit 非 blocker、請 QA sanity):①−attack_commit×0.1(TASK_ATTACK/LOOT 二元)=世界狀態 situational(攻擊投入前線留守少)非人格閘/死常數、憲法『世界物理≠人格閘』legit②好戰→守(尚武 proxy)方向:attack_commit 已管正在攻擊少守、好戰當 baseline 防務 readiness 可分離、WEIGH 非 gate·★請 QA adversarial(讀 code+親算+specimen、6gap+committed-task 教訓):①guard 連續人格分化(慎重0→1 guard 0.175→0.375 單調連續非離散5值跳、高慎重>低、高好戰>低、machine-demonstrate 親算)②★belief-threat 去 god-view(未 discovered 敵鄰格→guard 不變不偷看真位置=god-view leak 除、discovered+approach→threat_norm 升守;遠/stale/positionless→ThreatAssessment 自然衰減、軍團也有感知非零)③消費者不漏(night-raid immunity[camp vision via get_guards]/夜哨 guard_count/rest_mult 三處 sensible、軍團威脅時 guard 升非裸奔)④bounded(clamp0.5/floor0.05)⑤determinism 3-run byte-identical/constitution 75(★照妖鏡 site 應減記錄)/active_promotion+named_scarcity_ab regression·★fp 前後對照 warring baseline[discrete+god-view]→branch[continuous+belief]DIVERGED guard_peak 0→0.5·CLEAN→systems merge(stale-base 先驗)→blueprint 推用戶;有洞→halt·★Slice B(團型梯度+pool 分數化)另批·地基 KEEP"
---

# QA adversarial release verify：军民混编 Slice A

`feat/junmin-militia-slice-a` `c3cf3df8`。★systems merge-gate 硬讀 **CLEAN**。

## merge-gate 硬讀確認
- `guard_ratio = clampf(BASE0.1 + 慎重×0.2 + 好戰×0.15 + belief_threat_norm×0.25 − attack_commit×0.1, 0.05, 0.5)` 連續人格化（離散 0.1/0.15/0.2/0.35/0.4 tag-gated 死常數**全除**）。
- `_max_belief_threat`（loop `team_discovered` + `ThreatAssessment.score` belief、同勢力濾、**無 god-view** teams_within/live tile_pos）。
- `_has_hostile_within` god-view **全除**（函式+唯一 caller）。finding⑥ 軍團也感知（無 uses_unified gate）。
- consumers 讀 ratio 不變、floor0.05 夜襲免疫不裸奔、bounded、僅 faction_ai+test、無 randf。

## ★兩判斷點（我判 legit 非 blocker、請 QA sanity）
1. `−attack_commit×0.1`（TASK_ATTACK/LOOT 二元）= **世界狀態 situational**（攻擊投入前線留守少）非人格閘/死常數、憲法「世界物理≠人格閘」legit。
2. 好戰→守（尚武 proxy）方向：attack_commit 已管「正在攻擊少守」、好戰當 baseline 防務 readiness 可分離、WEIGH 非 gate。

## ★請 QA adversarial（讀 code + 親算 + specimen、6gap + committed-task 教訓）
1. **guard 連續人格分化**（慎重0→1 guard 0.175→0.375 單調連續非離散5值跳、高慎重>低、高好戰>低、machine-demonstrate 親算）。
2. ★**belief-threat 去 god-view**（未 discovered 敵鄰格→guard 不變不偷看真位置 = god-view leak 除、discovered+approach→threat_norm 升守；遠/stale/positionless→ThreatAssessment 自然衰減、軍團也有感知非零）。
3. **消費者不漏**（night-raid immunity[camp vision via get_guards] / 夜哨 guard_count / rest_mult 三處 sensible、軍團威脅時 guard 升非裸奔）。
4. **bounded**（clamp0.5 / floor0.05）。
5. determinism 3-run byte-identical / constitution 75（★照妖鏡 site 應減記錄）/ active_promotion + named_scarcity_ab regression。
- ★fp 前後對照 warring baseline[discrete+god-view]→branch[continuous+belief] DIVERGED、guard_peak 0→0.5。

CLEAN → systems merge（stale-base 先驗）→ blueprint 推用戶；有洞→halt。★Slice B（團型梯度+pool 分數化）另批。地基 KEEP。
