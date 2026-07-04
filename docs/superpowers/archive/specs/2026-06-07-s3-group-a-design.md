# S3 Group A — 訊息過期 + Magic Numbers 設計

*Spec written: 2026-06-07*

## Goal

1. 防止 `global_messages` / `team_known` 無限累積 — 加 TTL prune
2. 將 `encounter_system.gd` 和 `faction_ai_system.gd` 的 inline 數字提取為具名常數
3. 修正 `docs/tick_parameters.md` 錯誤（`ticks_per_day = 24` → 240）

---

## Fix 1 — 訊息 TTL Prune

### 背景

`MessageData.origin_tick` 已存在。`global_messages` 和每個 `state.team_known[tid]` 只 append，從不刪除。1000 tick 後每隊 known 可累積數百條。

### TTL 常數（加在 `message_system.gd` 頂部）

```gdscript
const MSG_TTL_SHORT:  int = 1680   # 7天  × 240 ticks/day
const MSG_TTL_MEDIUM: int = 3360   # 14天
const MSG_TTL_LONG:   int = 7200   # 30天 = TICKS_PER_MONTH

const MSG_TTL_BY_TYPE: Dictionary = {
    "combat_start":      MSG_TTL_SHORT,
    "famine_warning":    MSG_TTL_SHORT,
    "diplomacy":         MSG_TTL_SHORT,
    "trade_done":        MSG_TTL_MEDIUM,
    "extortion":         MSG_TTL_MEDIUM,
    "tribute":           MSG_TTL_MEDIUM,
    "order_delivered":   MSG_TTL_MEDIUM,
    "combat_end":        MSG_TTL_LONG,
    "subjugate":         MSG_TTL_LONG,
    "faction_establish": MSG_TTL_LONG,
    "outpost_built":     MSG_TTL_LONG,
}
const MSG_TTL_DEFAULT: int = MSG_TTL_MEDIUM   # 未列出的 type 用此值
```

### 新函式 `prune_old_messages(state, current_tick)`

```gdscript
func prune_old_messages(state: WorldState, current_tick: int) -> void:
    # 1. prune global_messages
    var keep: Array = []
    for msg in state.global_messages:
        var ttl: int = MSG_TTL_BY_TYPE.get(msg.type, MSG_TTL_DEFAULT)
        if current_tick - msg.origin_tick <= ttl:
            keep.append(msg)
    var pruned_global: int = state.global_messages.size() - keep.size()
    state.global_messages = keep

    # 2. prune team_known for each team
    var pruned_known: int = 0
    for tid in state.team_known:
        var fresh: Array = []
        for msg in state.team_known[tid]:
            var ttl: int = MSG_TTL_BY_TYPE.get(msg.type, MSG_TTL_DEFAULT)
            if current_tick - msg.origin_tick <= ttl:
                fresh.append(msg)
        pruned_known += state.team_known[tid].size() - fresh.size()
        state.team_known[tid] = fresh

    if pruned_global + pruned_known > 0:
        print("[MsgPrune] 刪除過期訊息 global=%d known=%d" % [pruned_global, pruned_known])
```

### 呼叫位置

`sim_runner.gd` — 在每日步驟（每 `WorldState.TICKS_PER_DAY` tick）結尾呼叫：

```gdscript
if state.world.current_tick % WorldState.TICKS_PER_DAY == 0:
    _message_system.prune_old_messages(state, state.world.current_tick)
```

---

## Fix 2 — Magic Numbers 提取

### `encounter_system.gd`

在頂部新增 const 區塊，涵蓋現有 inline 數字（傷亡率、逃跑閾值、俘虜機率等）。原則：每個 inline 數字替換為一個具名 const，名稱說明其語義。不改邏輯。

### `faction_ai_system.gd`

同上，提取 inline 數字（信心/合理性閾值、食物警戒值等）為頂部 const。

### 不動的檔案

`interaction_system.gd` 頂部已有完整 const 區塊（lines 32-56）。`reaction_system.gd`、`movement_system.gd` 數字少且已有 const — 跳過。

---

## Fix 3 — tick_parameters.md 修正

將文件中 `ticks_per_day = 24`（data/world_state.gd:24 標注）改為 `240`，並補充 `TICKS_PER_HOUR = 10`。

---

## Files to Modify

| File | Change |
|---|---|
| `scripts/simulation/message_system.gd` | 加 TTL consts + `prune_old_messages()` |
| `scripts/simulation/sim_runner.gd` | 每日呼叫 `prune_old_messages` |
| `scripts/simulation/encounter_system.gd` | inline → const |
| `scripts/simulation/faction_ai_system.gd` | inline → const |
| `docs/tick_parameters.md` | 修正 ticks_per_day 錯誤 |

---

## Testing

在 `headless_test.gd` 加測試（`print("=== DONE ===")` 前）：

```gdscript
# ── message prune test ────────────────────────────────────────────
var _msg_sys := SimMessageSystem.new()
# 注入一條過期 short TTL 訊息（origin_tick = 0，current_tick >> TTL）
var _old_msg := MessageData.new()
_old_msg.type       = "combat_start"
_old_msg.origin_tick = 0
_old_msg.id         = 99990
state.global_messages.append(_old_msg)
var _before_g: int = state.global_messages.size()
_msg_sys.prune_old_messages(state, 9999)
assert(state.global_messages.size() < _before_g,
    "[MsgPruneTest] expired message must be pruned from global_messages")
print("[MsgPruneTest] message TTL prune ok")
# ── end message prune test ────────────────────────────────────────
```
