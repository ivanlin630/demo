# Player Commands & Interaction Design Spec

**Date:** 2026-05-31
**Status:** Approved → Awaiting Plan

---

## 目標

讓玩家 team 能主動發起互動（貿易/外交/攻擊/掠奪/納貢要求），並能回應 NPC 強制互動（被攻擊/被外交/被勒索）。

**核心限制：玩家 team 永無 `current_task`。** 所有互動必須由玩家明確觸發，不走 NPC AI 自動路徑。

---

## 設計決策

### 觸發時機
同格判斷仍由 `interaction_system._try_interact()` 負責，但玩家涉及時**不自動解決**——改寫入 WorldState 的 pending 欄位，UI 負責呈現並等玩家決策。

### 阻塞 vs 非阻塞

| 情況 | 行為 |
|---|---|
| 玩家主動（NPC 無敵意 task） | **非阻塞**：pending 存入 targets，推 tick 繼續，玩家可忽略 |
| NPC 強制攻擊（combat_target = 玩家） | **阻塞**：等同 encounter_active，推 tick 不繼續，直到玩家選戰/逃 |
| NPC 強制外交/勒索 | **非阻塞**：pending 存入 forced_event，超時（下次推 tick 前未回應）自動拒絕 |

---

## 1. WorldState 新增欄位

```gdscript
# scripts/data/world_state.gd

var player_pending_targets: Array = []
# Array[int] — 同格、無敵意、等玩家選擇的 team_ids
# 玩家移開格子時清除；玩家執行任意行動後對應 id 移除

var player_forced_event: Dictionary = {}
# NPC 強制互動，格式：
# { "from_id": int, "action": String }
# action = "attack"    → 阻塞，玩家必須選 fight / flee
# action = "diplomacy" → 非阻塞，{ ..., "proposal": String }
# action = "extort"    → 非阻塞
# 空 Dict = 無待處理強制事件
```

---

## 2. InteractionSystem 修改

### `_try_interact(state, id_a, id_b)` 修改邏輯

原本：player 涉及 → 直接呼叫 EncounterSystem

新邏輯（在現有 player 判斷處替換）：

```gdscript
# 判斷哪個是玩家 team
var player_tid: int = state.player_id  # person id，需透過 persons 取 team_id
# 取 player_team_id
var player_person: PersonData = state.persons.get(state.player_id)
if player_person == null: return
var player_team_id: int = player_person.team_id
var is_a_player: bool = (id_a == player_team_id)
var is_b_player: bool = (id_b == player_team_id)
if not (is_a_player or is_b_player): return  # 走原有非玩家路徑

var npc_id: int = id_b if is_a_player else id_a
var npc: TeamData = state.teams.get(npc_id)

# 判斷 NPC 是否有以玩家為目標的敵意 task
if npc.combat_target == player_team_id:
    # NPC 強制攻擊 → 阻塞
    state.player_forced_event = { "from_id": npc_id, "action": "attack" }
    return  # sim_runner 偵測 player_forced_event.action=="attack" 時停推 tick

elif npc.current_task == TeamData.TASK_DIPLOMACY and npc.order_target_id == player_team_id:
    # NPC 強制外交（提案）
    state.player_forced_event = {
        "from_id": npc_id, "action": "diplomacy",
        "proposal": npc.order_task  # "alliance" / "tribute" / "surrender"
    }
    return  # 非阻塞，下次推 tick 若未回應 → 自動拒絕

elif npc.current_task == TeamData.TASK_LOOT:
    # NPC 強制勒索（TASK_LOOT 同格即為目標，不需 combat_target）
    state.player_forced_event = { "from_id": npc_id, "action": "extort" }
    return  # 非阻塞

else:
    # NPC 無敵意 → 玩家可主動選擇互動
    if not state.player_pending_targets.has(npc_id):
        state.player_pending_targets.append(npc_id)
    return  # 不自動解決
```

### `InteractionSystem` 新增公開函式

```gdscript
# 供 PlayerCommandSystem 呼叫，跳過 task 檢查直接執行貿易
func resolve_trade_direct(state: WorldState, buyer_id: int, seller_id: int) -> Dictionary:
    # 複用 _resolve_trade 的資源轉移邏輯，但不檢查 current_task
    # 返回 { "ok": bool, "msg": String, "food": int, "coin": int }
    pass

# 供 PlayerCommandSystem 呼叫，跳過 task 檢查直接執行掠奪
func resolve_extortion_direct(state: WorldState, aggressor_id: int, target_id: int) -> Dictionary:
    # 複用 _resolve_extortion 邏輯
    # 返回 { "ok": bool, "msg": String }
    pass
```

---

## 3. PlayerCommandSystem（新建）

**檔案：** `scripts/simulation/player_command_system.gd`

```gdscript
class_name PlayerCommandSystem

# ── 主動互動 ────────────────────────────────────────

# 查詢對 target_id 可用的行動清單
func get_available_actions(state: WorldState, target_id: int) -> Array[String]:
    # 返回可選行動 subset，根據條件過濾
    # 永遠包含 "ignore"
    # "trade"           → target 有可賣資源 OR 玩家有 coin
    # "propose_alliance" → target 非同勢力
    # "demand_tribute"  → 玩家 pop > target.pop × 1.5
    # "attack"          → 永遠可選
    # "extort"          → 玩家 readiness >= 0.7

# 執行行動（玩家主動）
func execute_action(state: WorldState, target_id: int, action: String) -> Dictionary:
    # 返回 { "ok": bool, "msg": String }
    match action:
        "trade":
            return _interaction.resolve_trade_direct(state, player_team_id, target_id)
        "propose_alliance":
            var resp: String = _diplomatic.handle_diplomacy_message(
                state, state.teams[target_id], player_team, "alliance")
            return { "ok": true, "msg": resp }
        "demand_tribute":
            var resp: String = _diplomatic.handle_diplomacy_message(
                state, state.teams[target_id], player_team, "tribute")
            return { "ok": true, "msg": resp }
        "attack":
            player_team.combat_target = target_id
            # 直接呼叫 EncounterSystem.setup_encounter(state, player_team_id, target_id)
            # encounter_active = true → sim_runner 下一 tick 走遭遇戰路徑
            # （不依賴 arrived 條件，因兩 team 已在同格）
            state.player_pending_targets.erase(target_id)
            return { "ok": true, "msg": "發起攻擊" }
        "extort":
            return _interaction.resolve_extortion_direct(state, player_team_id, target_id)
        "ignore":
            state.player_pending_targets.erase(target_id)
            return { "ok": true, "msg": "忽略" }

# ── 被動回應（NPC 強制）─────────────────────────────

# 查詢 forced_event 的回應選項
func get_forced_response_options(state: WorldState) -> Array[String]:
    match state.player_forced_event.get("action", ""):
        "attack":    return ["fight", "flee"]
        "diplomacy": return ["accept", "refuse"]
        "extort":    return ["pay", "fight", "refuse"]
    return []

# 回應強制互動
func respond_to_forced(state: WorldState, response: String) -> Dictionary:
    var fe: Dictionary = state.player_forced_event
    if fe.is_empty(): return { "ok": false, "msg": "無待處理事件" }
    var result: Dictionary = _handle_forced_response(state, fe, response)
    state.player_forced_event = {}
    return result

# ── 清除 pending ─────────────────────────────────────

# 玩家 team 離開格子時呼叫
func clear_pending_targets(state: WorldState) -> void:
    state.player_pending_targets.clear()
    # player_forced_event 不清除（被攻擊不能靠移動取消）

# ── 內部 helper ──────────────────────────────────────

func _handle_forced_response(state: WorldState, fe: Dictionary, response: String) -> Dictionary:
    var from_id: int = fe.get("from_id", -1)
    match fe.get("action", ""):
        "attack":
            if response == "fight":
                # 觸發遭遇戰
                player_team.combat_target = from_id
                # EncounterSystem 設置（同現有邏輯）
                return { "ok": true, "msg": "迎戰" }
            else:  # "flee"
                # 玩家 team 設移動目標為相反方向（簡單實作：清除 combat_target，讓移動系統帶走）
                player_team.move_target = _flee_target(state)
                return { "ok": true, "msg": "逃跑" }
        "diplomacy":
            if response == "accept":
                # 依 proposal 類型：加入勢力 or 給 tribute
                return _accept_diplomacy(state, from_id, fe.get("proposal", ""))
            else:
                return { "ok": true, "msg": "拒絕提案" }
        "extort":
            if response == "pay":
                # 轉移資源
                return _pay_extortion(state, from_id)
            elif response == "fight":
                player_team.combat_target = from_id
                return { "ok": true, "msg": "拒絕並迎戰" }
            else:  # "refuse"
                return { "ok": true, "msg": "拒絕勒索" }
    return { "ok": false, "msg": "未知回應" }

func _get_player_team(state: WorldState) -> TeamData:
    var p: PersonData = state.persons.get(state.player_id)
    if p == null: return null
    return state.teams.get(p.team_id)

func _get_player_team_id(state: WorldState) -> int:
    var p: PersonData = state.persons.get(state.player_id)
    if p == null: return -1
    return p.team_id
```

---

## 4. SimRunner 修改

### 阻塞檢查（attack forced event）

在 `advance_tick()` 頂部加入：

```gdscript
# 若有 NPC 強制攻擊玩家待回應，阻塞 tick 推進
if state.player_forced_event.get("action", "") == "attack":
    return []  # 不推進，等 UI 呼叫 respond_to_forced
```

### 非阻塞 forced_event 自動超時

在 near 區邏輯末尾加（非阻塞 forced_event 下一 tick 若未清除 → 自動拒絕）：

```gdscript
var fe: Dictionary = state.player_forced_event
if not fe.is_empty() and fe.get("action", "") != "attack":
    # 玩家未在上一 tick 回應非阻塞事件 → 自動拒絕
    state.player_forced_event = {}
```

### pending_targets 清除

在 `_step2_move_teams()` 中，若玩家 team 移動（tile_pos 改變）→ 呼叫 `player_cmd.clear_pending_targets(state)`

---

## 5. 修改檔案清單

| 檔案 | 動作 |
|---|---|
| `scripts/data/world_state.gd` | 加 `player_pending_targets`、`player_forced_event` |
| `scripts/simulation/interaction_system.gd` | 修改 `_try_interact()` 玩家分支；新增 `resolve_trade_direct()`、`resolve_extortion_direct()` |
| `scripts/simulation/player_command_system.gd` | **新建**：PlayerCommandSystem |
| `scripts/simulation/sim_runner.gd` | 加阻塞檢查 + 超時清除 + pending 清除 |
| `scripts/debug/headless_test.gd` | 加 PlayerCommandSystem 測試案例 |

---

## 6. headless_test 驗證

```gdscript
# 測試：玩家主動貿易
var cmd := PlayerCommandSystem.new()
# 手動將 Team1 移到玩家格
state.teams[1].tile_pos = state.teams[0].tile_pos
state.player_pending_targets.append(1)
var actions := cmd.get_available_actions(state, 1)
assert(actions.has("trade"), "trade 應可選")
var result := cmd.execute_action(state, 1, "trade")
print("貿易結果: %s" % result.get("msg", ""))

# 測試：NPC 強制攻擊 → 阻塞
state.teams[2].combat_target = state.teams[0].team_id
state.player_forced_event = { "from_id": 2, "action": "attack" }
assert(state.player_forced_event.get("action") == "attack")
var opts := cmd.get_forced_response_options(state)
assert(opts.has("fight") and opts.has("flee"))
var resp := cmd.respond_to_forced(state, "flee")
assert(state.player_forced_event.is_empty(), "forced_event 應清除")
print("逃跑結果: %s" % resp.get("msg", ""))

print("=== PlayerCommandSystem Tests PASSED ===")
```

---

## 7. 注意事項

- **`_resolve_trade()` private 問題**：GDScript 不強制 private，PlayerCommandSystem 持有 InteractionSystem 實例可直接呼叫 `_resolve_trade()`；但更乾淨的方式是新增 `resolve_trade_direct()` 公開函式
- **逃跑方向**：`_flee_target()` 簡單實作為玩家來的方向的相反格，或隨機相鄰空格，細節留實作決定
- **`order_target_id` 欄位**：NPC 外交 task 對玩家的目標記錄方式需確認（目前 TeamData 有 `order_target_id: int`）
- **EncounterSystem 觸發**：`execute_action("attack")` 設 combat_target 後，EncounterSystem 在 sim_runner 的 `_step4_resolve_interactions` 中由 `process_on_arrival` 觸發（需確認 arrived 條件）

---

## 與 spec 接口一致性

| 系統 | 讀取 | 寫入 |
|---|---|---|
| interaction_system | teams, player_id, persons | player_pending_targets, player_forced_event |
| player_command_system | player_pending_targets, player_forced_event, teams, persons | teams.resources, factions, player_forced_event, player_pending_targets |
| sim_runner | player_forced_event | player_forced_event（超時清除）|
| UI (text_ui_main) | player_pending_targets, player_forced_event | — |
