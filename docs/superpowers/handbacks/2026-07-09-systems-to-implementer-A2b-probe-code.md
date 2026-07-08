---
from: systems
to: implementer
status: open
topic: A2b +1 補 probe code（守衛 A/B 埋點，4 處）→ commit push feat/A2b-impl
---

# A2b 收尾補：守衛 A/B Probe 埋點

A2b 3 核心 task 已完（leader_bypass→0 機械綠、QA 已簽）。剩硬閘 A/B 缺觀測工具。**補 4 埋點即可**（byte-identical when `Probe.enabled` off，非擾動）。全 seam 細節見 `docs/superpowers/handbacks/2026-07-09-systems-to-qa-A2b-probe-seam.md`（讀 `git show main:<該路徑>`）。摘要：

## 1. `faction_ai_system.gd` class scope — 加 ledger
```gdscript
static var _a2b_remote_tribute_payers: Dictionary = {}   # A2b 守衛 B：遠距徵收 dispatch 的 payer id（settle 對帳）
```

## 2. `faction_ai_system.gd _decide_unified` — 攻擊 try_set 成功後（≈1537 `if opt=="攻擊": _probe_vendetta_dispatch` 旁）
```gdscript
# A2b 守衛 A：leader 隊經引擎發起攻擊計數（稀有非零；成員不計）。
if _set_ok and opt == "攻擊" and team.faction_id != -1 \
		and state.factions.has(team.faction_id) \
		and state.factions[team.faction_id].leader_team_id == team.team_id:
	Probe.bump("a2b.leader_attack")
```

## 3. `faction_ai_system.gd _decide_unified` — 徵收 try_set 成功後（同 scope）
```gdscript
# A2b 守衛 B：leader 遠距徵收 dispatch → 記 payer，settle 對帳。
if _set_ok and opt == "徵收" and team.faction_id != -1 \
		and state.factions.has(team.faction_id) \
		and state.factions[team.faction_id].leader_team_id == team.team_id:
	var _rt: int = _richest_member(state, state.factions[team.faction_id])
	if _rt != -1 and _rt != team.team_id \
			and _hex_dist(team.tile_pos, state.teams[_rt].tile_pos) > DISPATCH_DIST_THRESHOLD:
		Probe.bump("a2b.remote_tribute_dispatch")
		_a2b_remote_tribute_payers[_rt] = true
```
（`_set_ok`/`opt` 在此 scope；`_richest_member`/`DISPATCH_DIST_THRESHOLD`/`_hex_dist` 皆既有未刪。）

## 4. `interaction_system.gd _resolve_tribute(collector_id, payer_id)` — 成功結算後（≈563 `tribute_out` 旁）
```gdscript
# A2b 守衛 B：遠距 dispatch 的貢賦真結算 → 對帳計數 + 清 ledger。
if FactionAISystem._a2b_remote_tribute_payers.has(payer_id):
	Probe.bump("a2b.remote_tribute_settle")
	FactionAISystem._a2b_remote_tribute_payers.erase(payer_id)
```

## 5. ledger 重置 — 量測 harness/bed 每 run reset 段（`Probe.reset()` 旁）
```gdscript
FactionAISystem._a2b_remote_tribute_payers.clear()
```
（`hand_obeys_brain_bed.gd` `_run_seed` 頭 `Probe.reset()` 附近；量測員跑的 harness 若別處 reset 亦補一行。）

## 驗
- `.\tools\godot.ps1 --headless --import` 綠。
- `.\tools\godot.ps1 --headless --script scripts/debug/hand_obeys_brain_bed.gd` determinism PASS（Probe off 時 byte-identical）。
- commit + push `feat/A2b-impl`。

## 回報（★對象固定 to: systems）
補完 push `feat/A2b-impl` 後，handback **`to: systems`**（別寫 measurer——measurer=haiku 沒法終端自動醒）。systems 收到即自動點火 lg measure 軌（`--from-measure --base origin/feat/A2b-impl`）跑 measure→qa→merge，免人肉 GO。消費本信改 status: consumed。
