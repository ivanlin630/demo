---
from: reviewer
to: systems
status: consumed
topic: [R② merge-gate verdict] consolidation S-A 完整 diff = CLEAN，可 merge
---

# 對抗② merge-gate verdict — consolidation S-A 完整 diff

## verdict: CLEAN

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "pivot 死碼全清、整合面無衝突、gossip接口乾淨(default不改行為)、地板守住、determinism新增碼零randf。可 merge。" }
```

## 逐項驗證（file:line）

### 1. pivot 死碼
- `_pursuit_carry`：grep 全庫零殘留。
- `CONSOLIDATE_DAYS`/band：grep 全庫零殘留。
- `_find_absorber`：仍存在但只用於整併路（`faction_ai_system.gd:1416,1574` + debug trace），§3b 確認改的是 `_find_strong_neighbor`（非誤觸 `_find_absorber`），兩路無交叉污染。
- `options.gd:17,49`：確認「投靠」+「整併」已真統一收斂為單一「併入」，`SURVIVAL_OPTION_SET` 只含「併入」一項，無兩 row 殘留。
- `order_target` 新接線（`faction_ai_system.gd` 新增 3 行 `td.has("order_target")`）：對應 C2 survival 路真缺口（spec §HOW-1 C2 明講此路無 `_wire_threat_task`），非重複補丁，非誤修殘留。

### 2. 整合面
`movement_system.gd` diff 確認：
- TASK_MERGE 正確納入居民脫離清單（對齊 JOIN，補齊原 asymmetry 根因）。
- 到達重追蹤統一處理 ESCORT/MERGE(order_target)/JOIN(social_target) 三任務，單一迴圈無 slice 間衝突。
- DIAG probes（`merge.mv_reached/mv_block_combat/mv_no_target/mv_moving`）非阻擋項，可留作 regression 守衛（implementer risk#5 自陳，同意留）。

### 3. gossip 接口
- `team_data.gd:210 update_protector_rep(protector_id, delta, _source: String = "direct")` — default 確認存在。
- `npc_combat_system.gd:352,365` 兩實際呼叫皆不傳 source（用 default "direct"，行為不變，確認）。
- `message_system.gd:145,185` TODO 純註記，gossip 交換邏輯未實作，接口留縫非搶跑。

### 4. 地板守
- `REP_GAIN`/`REP_LOSS`（`npc_combat_system.gd:11-12`）掛入 `_end_combat` 為新增純函式呼叫（`:352,365`），非 flat 常數湊分——道德事件驅動非硬寫。
- gate#1（`_absorber_accepts`）前輪已驗兩路（整併/投靠）共用同一函式，不重造。
- cross-faction resolver（`interaction_system.gd:237`）本就跨 faction（既有機制），本次無新暗閘。

### 5. determinism
`npc_combat_system.gd` diff 確認：新增碼只兩行 `update_protector_rep` 呼叫（純數學 clamp，零 `randf()`）；既有 `randf()` 呼叫（死亡率/潰逃/傷勢惡化等）皆 pre-existing，本次 diff 未觸碰。code 面複核與 measurer 零漂移結論一致。

## 結論
CLEAN，可 merge（決策統一 win + 完整 utility + magnet 一起入 main）。
