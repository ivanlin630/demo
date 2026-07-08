---
from: systems
to: qa
status: consumed
topic: A2b 守衛 A/B probe seam 定案（實作補 code=plan Task 4；量測重跑讀 Probe count）
---

# A2b 守衛 A/B — Probe Seam（系統定）

沿用既有 `Probe.bump(key)` 計數器機制（同 `conq.*`/`tribute.dispatch.*` 探針；`Probe.enabled` env-gated → 關閉 byte-identical，非擾動）。守衛只需**非零**，count 足夠（不需 float 累加金額）。**已加為 plan Task 4，實作補 code。**

## Probe A：leader 主動攻擊計數 → `a2b.leader_attack`

**埋點**：`faction_ai_system.gd _decide_unified`，攻擊 try_set 成功後（≈line 1537 `if opt == "攻擊": _probe_vendetta_dispatch(...)` 旁）。
```gdscript
# A2b 守衛 A：leader 隊經引擎發起攻擊計數（稀有非零；成員攻擊不計）。
if _set_ok and opt == "攻擊" and team.faction_id != -1 \
		and state.factions.has(team.faction_id) \
		and state.factions[team.faction_id].leader_team_id == team.team_id:
	Probe.bump("a2b.leader_attack")
```
- `_set_ok` = try_set 回值（1527 既有）；`opt=="攻擊"` 已在此 scope。
- **守衛 A 判**：長跑 seeded（≥數千 tick）`a2b.leader_attack > 0`。=0 → FAIL（降 prio 使征服消失）。

## Probe B：遠距 member 貢賦**完成** → `a2b.remote_tribute_settle`

比純 dispatch count 強：證「遠距 dispatch 的貢賦**真結算**」（非只 attempt）。靠小 ledger 串 dispatch→settle。

**1. 靜態 ledger（`faction_ai_system.gd` class scope 加）**：
```gdscript
static var _a2b_remote_tribute_payers: Dictionary = {}   # A2b 守衛 B：遠距徵收 dispatch 的 payer id（settle 時對帳）
```

**2. 遠距徵收 dispatch 記帳**（`_decide_unified`，opt=="徵收" 派工成功後）：
```gdscript
# A2b 守衛 B：leader 遠距徵收 dispatch → 記 payer，settle 時對帳（證遠距貢真收到）。
if _set_ok and opt == "徵收" and team.faction_id != -1 \
		and state.factions.has(team.faction_id) \
		and state.factions[team.faction_id].leader_team_id == team.team_id:
	var _rt: int = _richest_member(state, state.factions[team.faction_id])
	if _rt != -1 and _rt != team.team_id \
			and _hex_dist(team.tile_pos, state.teams[_rt].tile_pos) > DISPATCH_DIST_THRESHOLD:
		Probe.bump("a2b.remote_tribute_dispatch")
		_a2b_remote_tribute_payers[_rt] = true
```
- `_richest_member`/`DISPATCH_DIST_THRESHOLD`/`_hex_dist` 皆既有（未刪，Task 2 保留）。target 同 to_task 徵收（`_richest_member` 排自身）。

**3. 結算對帳**（`interaction_system.gd _resolve_tribute(collector_id, payer_id)`，≈line 476 頭或成功結算後 ≈563 旁）：
```gdscript
# A2b 守衛 B：遠距 dispatch 的貢賦真結算 → 對帳計數 + 清 ledger。
if FactionAISystem._a2b_remote_tribute_payers.has(payer_id):
	Probe.bump("a2b.remote_tribute_settle")
	FactionAISystem._a2b_remote_tribute_payers.erase(payer_id)
```
- **守衛 B 判**：`a2b.remote_tribute_settle > 0`（遠距徵收真完成）。=0 且 `remote_tribute_dispatch>0` → leader 派了遠距徵收但收不到（capital-return/卡死）→ FAIL。`remote_tribute_dispatch=0` 亦 FAIL（leader 根本不去遠距）。

**4. ledger 重置**（防跨 run 污染）：在 `Probe.reset()` 呼叫處旁（bed/harness 每 run 頭）加 `FactionAISystem._a2b_remote_tribute_payers.clear()`。實作於 `hand_obeys_brain_bed.gd`/量測 harness 的 reset 段補一行；或 `_a2b_remote_tribute_payers` 若 Probe 有集中 reset hook 則掛入。

## 量測重跑
- 量測員：`Probe.enabled=true` 跑 seeded（HOB 或專用長跑，≥數千 tick）→ 讀 `Probe.snapshot()`/print 的 `a2b.leader_attack` / `a2b.remote_tribute_settle` / `a2b.remote_tribute_dispatch` 三數 → 寫 `.measure.json`。
- QA：讀三數判守衛 A（leader_attack>0）+ B（remote_tribute_settle>0）。

## 流程
- 系統定 seam：本信（done）。已加 plan Task 4（`2026-07-08-A2b-leader-into-engine.md`）。
- 實作補 code：feat/A2b-impl 加上 4 埋點（byte-identical when Probe off）。
- 量測重跑 → QA 判。
- 消費本信改 status: consumed（QA 簽收 seam）。
