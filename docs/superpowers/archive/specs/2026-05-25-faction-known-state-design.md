# Faction Known State Design (Sub-system 2a)

## Goal

建立 FactionAI 情報介面層：leader 透過 `known_member_states` 快照讀取成員狀態，而非直接讀 `state.teams`。初期 stub 仍直接更新（全知），未來逐步限制為接觸觸發/herald 傳遞。

---

## 架構原則

| 層級 | 現況 | 2a 後 | 未來（IntelSystem） |
|---|---|---|---|
| 友方情報 | 直接讀 state.teams | 讀 known_member_states 快照 | 接觸/herald 才更新快照 |
| 敵方情報 | 直接讀 state.teams | 不變（介面預留） | team_intel 模糊化 |
| 指令傳遞 | 直接寫入 task | 不變（介面預留） | 同格直接/遠距用 herald |

> 2a 只建介面和 AI 接口。傳播限制（接觸觸發、距離模糊、herald 傳令）留給 IntelSystem 討論後實作。

---

## 修改檔案

| 檔案 | 動作 |
|---|---|
| `scripts/data/faction_data.gd` | 加 `known_member_states` |
| `scripts/data/world_state.gd` | 加 `snapshot_faction_member()` stub |
| `scripts/simulation/faction_ai_system.gd` | `_richest_member` 改讀快照；`_assign_member_tasks` 過濾改讀快照；`_declare_established` + `evaluate_all` 初始/刷新快照 |
| `scripts/simulation/interaction_system.gd` | `_try_subjugate`、`_try_diplomacy` 加入 faction 時初始快照（介面預留點） |
| `scripts/debug/headless_test.gd` | 驗證快照 vs 即時讀差異 |
| `docs/progress.md` | 加入完成項目 |

---

## Part 1：資料結構

### faction_data.gd

```gdscript
var known_member_states: Dictionary = {}
# { team_id: int → {
#   "food":         float,    # resources["food"]
#   "weapons":      int,      # sum(melee_low+melee_high+ranged_low+ranged_high)
#   "goods":        float,    # resources["goods"]
#   "population":   int,
#   "tile_pos":     Vector2i,
#   "current_task": String,
#   "last_tick":    int,
# }}
```

### world_state.gd — `snapshot_faction_member`（stub）

初期直接讀 state（全知），介面確立後未來由 IntelSystem 限制觸發時機。

```gdscript
func snapshot_faction_member(team_id: int, tick: int) -> void:
    var t: TeamData = teams.get(team_id)
    if t == null or t.faction_id == -1:
        return
    var f = factions.get(t.faction_id)
    if f == null:
        return
    f.known_member_states[team_id] = {
        "food":         float(t.resources.get("food", 0.0)),
        "weapons":      int(t.resources.get("weapon_melee_low",   0))
                      + int(t.resources.get("weapon_melee_high",  0))
                      + int(t.resources.get("weapon_ranged_low",  0))
                      + int(t.resources.get("weapon_ranged_high", 0)),
        "goods":        float(t.resources.get("goods", 0.0)),
        "population":   t.population,
        "tile_pos":     t.tile_pos,
        "current_task": t.current_task,
        "last_tick":    tick,
    }
```

---

## Part 2：快照更新點（2a 版：stub 直接讀）

| 時機 | 位置 | 說明 |
|---|---|---|
| 立國 | `_declare_established` 末段 | 初始化所有成員快照 |
| AI evaluate 開始 | `evaluate_all` 開頭（per faction） | 每輪 AI 前刷新（stub；未來改為接觸觸發） |
| 臣服加入 | `_try_subjugate` 末段 | 新成員初始快照 |
| 外交加入 | `_try_diplomacy` 末段 | 新成員初始快照 |

> **介面預留**：上述「未來改為接觸觸發」意指 IntelSystem 完成後，移除 `evaluate_all` 內的 stub 刷新，改由接觸事件驅動。

---

## Part 3：FactionAI 改動

### evaluate_all — stub 刷新快照

```gdscript
func evaluate_all(state: WorldState, _team_ids: Array) -> void:
    for fid in state.factions:
        var f = state.factions[fid]
        # stub：每輪刷新（未來由 IntelSystem 限制）
        for mid in f.member_team_ids:
            state.snapshot_faction_member(mid, state.world.current_tick)
        _update_goals(state, f)
        _assign_tasks(state, f)
    # ... 其餘不變
```

### _richest_member — 改讀快照

```gdscript
func _richest_member(state: WorldState, f) -> int:
    var best_tid: int    = -1
    var best_food: float = 0.0
    for mid in f.member_team_ids:
        if mid == f.leader_team_id or not state.teams.has(mid):
            continue
        var snap: Dictionary = f.known_member_states.get(mid, {})
        var food: float = float(snap.get("food", 0.0))
        if food > best_food:
            best_food = food
            best_tid  = mid
    return best_tid
```

### _assign_member_tasks — 任務過濾改讀快照

```gdscript
# 原：if mt == null or mt.combat_target != -1 or mt.current_task != "idle":
var snap: Dictionary = f.known_member_states.get(mid, {})
var known_task: String = snap.get("current_task", "idle")
if mt == null or mt.combat_target != -1 or known_task != "idle":
    continue
```

`mt.combat_target != -1` 仍即時讀（安全閘，不打斷進行中戰鬥）。

### _declare_established — 初始快照

```gdscript
func _declare_established(state: WorldState, f, leader_team: TeamData) -> void:
    f.is_established = true
    f.faction_name   = "勢力%d" % f.faction_id
    f.goals.erase("立國")
    for mid in f.member_team_ids:
        state.snapshot_faction_member(mid, state.world.current_tick)
    SimMessageSystem.new().emit_message(...)
    print(...)
```

---

## Part 4：驗證

### 場景 1：快照架構正確（stub 全知版）

1. 建 faction（leader Team A，成員 Team B food=50）
2. 立國 → 初始快照 → `known_member_states[B]["food"] == 50.0` ✓
3. `_richest_member` 返回 Team B ✓

### 場景 2：快照 current_task 反映叛亂

1. Team C 快照 current_task="攻擊"（已由 _check_deviation 改為 idle，但未接觸）
2. `_assign_member_tasks` 讀快照 known_task="攻擊" → 跳過 Team C（不重新指派）
3. **[OK] 介面行為正確，傳播限制留後實作**

---

## ⚠️ 設計備忘

| 事項 | 說明 |
|---|---|
| Stub 刷新位置 | `evaluate_all` 開頭，未來 IntelSystem 完成後移除 |
| 快照缺失處理 | `known_member_states.get(mid, {})` → 空 dict → food=0/task=idle（視為可指派） |
| 指令傳遞 | 2a 不改，仍直接寫入 task；同格直接/herald 傳令留 IntelSystem |
| 敵方情報 | 2b-intel 負責，不在本 spec |
