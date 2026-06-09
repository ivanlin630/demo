# 玩家 Person 死亡保護（D2）— Design

> 日期：2026-06-09
> 議題：H / known_issues D2 — 玩家 person 死亡時 `state.player_id` 仍指向已刪 person，所有 UI 失效

## 背景

當前玩家 person 可在以下情境死亡，但**無對應保護**：
- Encounter 戰死：`encounter_system.resolve_encounter_end` line ~1042 erase 死者 + leader_id = -1
- 事件殺害：`event_unrest_replace` 換 leader
- N3_defect：個別 leader 叛離 → loyalty=0、team_id=-1

死後：
- `state.player_id` 仍 = 已死 person id
- `state.persons.get(player_id)` 回 null
- `sim_bridge`、`right_sidebar`、`encounter_view`、各 UI 取 player 資料 → 全失效
- 玩家黑屏無回饋

S11 既有「auto-promote named member」for NPC team，但玩家 team 也走同邏輯 → 玩家身分莫名其妙跑到別人身上（玩家不知）。

## 目標

1. 玩家 team leader 死亡 → forced event「選繼承人」面板（不自動升）
2. 玩家選 named member → `player_id` 自動跟新 leader
3. 無 named member（玩家絕後）→ `state.game_over = true`，世界凍結
4. 選繼承人期間世界凍結（不超時、不自動選，等玩家決定）
5. 跟 S11 整合（NPC team 仍 auto，玩家 team 走新 path）

## 不在範圍

- Game Over 後重玩 / 主選單 / 存讀檔
- 老化 / 飢餓 / 病死等新死亡來源 → 獨立 spec「Person 自然死亡」
- 玩家被俘虜（未來功能）
- 觀察者 / 旁觀 mode
- UI 繼承人選擇面板細節（本 spec 處理後端 + forced event 寫入；UI 後續 spec）

## 新欄位

```gdscript
# WorldState
var game_over: bool = false
var game_over_reason: String = ""
```

## 核心 helper：`_handle_player_leader_death`

放於 `faction_ai_system`（共用），覆蓋 S11 玩家 team 路徑：

```gdscript
func _handle_player_leader_death(state: WorldState, team: TeamData) -> void:
	# 玩家 team leader 已死，team.leader_id 此時可能仍是死者 id 或 -1
	team.leader_id = -1
	if team.named_members.is_empty():
		state.game_over = true
		state.game_over_reason = "玩家絕後（Team%d 無繼承人）" % team.team_id
		print("[GameOver] %s" % state.game_over_reason)
		return
	# Forced event 給玩家選繼承人
	state.player_forced_event = {
		"action": "choose_heir",
		"team_id": team.team_id,
		"candidates": team.named_members.duplicate(),
	}
	state.player_forced_event_id = "heir_%d" % state.world.current_tick
	print("[Heir] 玩家 leader 死亡，等待選繼承人")
```

## 改 S11 `_promote_successor`

```gdscript
func _promote_successor(state: WorldState, team: TeamData) -> void:
	# H: 玩家 team 走 _handle_player_leader_death
	if state.player_id != -1 \
			and team.team_id == _get_player_team_id(state):
		_handle_player_leader_death(state, team)
		return
	# 既有 NPC auto-promote 邏輯不變
	# ... 原 S11 邏輯
```

`_get_player_team_id` helper：

```gdscript
func _get_player_team_id(state: WorldState) -> int:
	if state.player_id == -1: return -1
	var p: PersonData = state.persons.get(state.player_id)
	if p == null:
		# 玩家已死，但 player_id 還沒清 → 試圖找哪個 team 把它當 named/leader
		for tid in state.teams:
			var t: TeamData = state.teams[tid]
			if t.leader_id == state.player_id or state.player_id in t.named_members:
				return tid
		return -1
	return p.team_id
```

## 玩家 action `choose_heir`

```gdscript
"choose_heir": _action_choose_heir,

func _action_choose_heir(state, _target, pt, pt_id):
	var fe = state.player_forced_event
	if fe.get("action", "") != "choose_heir":
		return { "ok": false, "msg": "無待選繼承人事件" }
	var heir_id: int = int(state.player_state.get("heir_id", -1))
	if heir_id == -1:
		return { "ok": false, "msg": "未選繼承人" }
	if not fe.get("candidates", []).has(heir_id):
		return { "ok": false, "msg": "非合法候選" }
	var team_id: int = int(fe.get("team_id", -1))
	var team: TeamData = state.teams.get(team_id)
	var heir: PersonData = state.persons.get(heir_id)
	if team == null or heir == null:
		return { "ok": false, "msg": "team/person 失效" }
	# 升職
	team.leader_id = heir_id
	team.named_members.erase(heir_id)
	heir.role = "leader"
	state.player_id = heir_id
	state.player_forced_event = {}
	state.player_forced_event_id = ""
	state.player_state.erase("heir_id")
	print("[Heir] %s 繼任玩家 (Team%d)" % [heir.person_name, team_id])
	return { "ok": true, "msg": "%s 繼任" % heir.person_name }
```

## 選繼承人期間世界凍結（不超時）

`sim_runner` 既有 forced_event 超時邏輯加跳過：

```gdscript
# 既有超時清掉邏輯
if not state.player_forced_event.is_empty():
	# choose_heir 不超時，世界凍結等玩家選
	if state.player_forced_event.get("action") == "choose_heir":
		pass   # 不清、不 fallback
	else:
		# 其他 forced event 超時清掉（既有邏輯）
		print("[PlayerCmd] forced_event 超時自動拒絕: %s" % str(state.player_forced_event))
		state.player_forced_event = {}
		state.player_forced_event_id = ""
```

## 世界凍結（Game Over + 選繼承人）

`sim_runner.advance_tick` 開頭加：

```gdscript
func advance_tick(state, player_pos):
	if state.game_over:
		return "game_over"
	# 選繼承人期間世界凍結，等玩家決定
	if state.player_forced_event.get("action") == "choose_heir":
		return "awaiting_heir"
	# ... 原邏輯
```

→ 兩種凍結場景：
- `game_over` = 玩家絕後，完全結束
- `awaiting_heir` = 等玩家選繼承人，凍結直到 `choose_heir` action 觸發

## 觸發點

| 來源 | 既有 code | 改動 |
|---|---|---|
| encounter `resolve_encounter_end` line ~1037-1042 | 死者 erase + leader_id=-1 | 後跑 S11，S11 內 H 邏輯接管 |
| `event_unrest_replace` | 既有 replace 邏輯（不殺玩家，只換 leader）| 若 leader 是玩家 → 也走 H |
| `N3_defect` 個別叛離 | loyalty=0, team_id=-1 | 同上 |
| 其他（未來新死亡來源）| - | 共用 helper |

**核心：** 所有死亡路徑最終走 S11 `_promote_successor`，由 S11 內判斷玩家身分後分流。

## 不變量

- `state.game_over = true` 後 `advance_tick` 不再推進（回 "game_over"）
- `choose_heir` forced event 期間 `advance_tick` 不推進（回 "awaiting_heir"）
- `choose_heir` 必須選 candidates 內的 id
- 無 named member → Game Over，不留 dangling player_id
- 選繼承人 forced event 不超時、不自動 fallback（永遠等玩家決定）

## 測試

`headless_test.gd`：

1. **玩家 leader 死亡 → forced event 寫入**：殺玩家 leader → state.player_forced_event 含 candidates
2. **choose_heir action 升職**：玩家選 heir → team.leader_id = heir, player_id = heir
3. **choose_heir 非候選 reject**：玩家選非 candidates 內 id → ok=false
4. **無 named member → Game Over**：玩家 team 無 named → game_over = true
5. **選繼承人期間世界凍結**：forced event 存在時 advance_tick 回 "awaiting_heir"，state 不變
6. **NPC team leader 死亡走 S11 不受影響**：NPC team 不觸發 forced event
7. **Game Over 後 advance_tick 凍結**：state.game_over 後 runner 不推進
8. **encounter 殺玩家觸發 H**：encounter 戰死 → forced event 出現

## 風險

- `_get_player_team_id` 在玩家剛死時 person 已 null → 需用 team 反查（如 spec 寫的 fallback loop）
- forced_event 超時時若 candidates 為空 → 雙重 fallback
- 玩家收到 forced event 時 sim 可能繼續跑（encounter 結束後其他 tick）→ state.game_over 凍結邏輯需先檢
- UI 不該在 game_over 後 access player_id（無玩家）

## 解決的 known_issues

- D2：玩家 person 死亡無保護 ✅

## 後續延伸

- UI 繼承人選擇面板（spec G/I）
- Game Over 後 重玩 / 主選單
- 老化 / 飢餓 / 病死 死亡來源
- 玩家被俘虜 → 暫時非 leader，獲救後恢復
- 觀察者 mode
