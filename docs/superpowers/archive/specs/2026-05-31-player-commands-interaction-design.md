# Player Commands & Interaction Design Spec

**Date:** 2026-05-31
**Status:** Approved → Awaiting Plan

---

## 目標

讓玩家 team 能主動發起互動（貿易/外交/攻擊/掠奪/納貢要求），並能回應 NPC 強制互動（被外交提案/被勒索）。

**核心限制：玩家 team 永無 `current_task`。** 所有互動必須由玩家明確觸發，不走 NPC AI 自動路徑。

---

## 設計決策

### 觸發時機
同格判斷仍由 `interaction_system._try_interact()` 負責，玩家涉及時根據 NPC 狀態分三路處理。

### 三路處理表

| 情況 | 行為 |
|---|---|
| NPC `combat_target` = 玩家 | **直接 EncounterSystem**（維持現有邏輯不動）—— 同格被攻擊無法逃跑 |
| NPC 外交/勒索 targeting 玩家 | **非阻塞**：寫入 `player_forced_event`，玩家下次推 tick 前可回應，超時自動拒絕 |
| NPC 無敵意 task | **非阻塞**：寫入 `player_pending_targets`，玩家主動選擇互動類型或忽略 |

---

## 1. WorldState 新增欄位

```gdscript
# scripts/data/world_state.gd

var player_pending_targets: Array = []
# Array[int] — 同格、無敵意、等玩家選擇的 team_ids
# 玩家移開格子時清除；玩家執行任意行動後對應 id 移除

var player_forced_event: Dictionary = {}
# NPC 強制非戰互動，格式：
# { "from_id": int, "action": String, ... }
# action = "diplomacy" → { ..., "proposal": String }  非阻塞，超時自動拒絕
# action = "extort"    → { ..., "from_id": int }       非阻塞，超時自動拒絕
# 空 Dict = 無待處理強制事件
```

---

## 2. InteractionSystem 修改

### `_try_interact(state, id_a, id_b)` 玩家分支替換

原本：player 涉及 → 直接呼叫 EncounterSystem

新邏輯（替換現有 player 判斷區塊）：

```gdscript
var player_person: PersonData = state.persons.get(state.player_id)
if player_person == null: return
var player_team_id: int = player_person.team_id
var is_a_player: bool = (id_a == player_team_id)
var is_b_player: bool = (id_b == player_team_id)
if not (is_a_player or is_b_player):
    return  # 非玩家涉及，走原有 NPC 路徑（不動）

var npc_id: int = id_b if is_a_player else id_a
var npc: TeamData = state.teams.get(npc_id)

# 路徑 1：NPC 攻擊玩家 → 維持原有 EncounterSystem 觸發（不動）
if npc.combat_target == player_team_id:
    _vision.reveal_encounter(state, player_team_id, npc_id)
    EncounterSystem.setup_encounter(state, npc_id, player_team_id)
    return

# 路徑 2：NPC 強制外交提案
elif npc.current_task == TeamData.TASK_DIPLOMACY and npc.order_target_id == player_team_id:
    state.player_forced_event = {
        "from_id": npc_id,
        "action":  "diplomacy",
        "proposal": npc.order_task   # "alliance" / "tribute" / "surrender"
    }
    return  # 非阻塞

# 路徑 3：NPC 勒索
elif npc.current_task == TeamData.TASK_LOOT:
    state.player_forced_event = { "from_id": npc_id, "action": "extort" }
    return  # 非阻塞

# 路徑 4：NPC 無敵意 → 玩家可主動選擇
else:
    if not state.player_pending_targets.has(npc_id):
        state.player_pending_targets.append(npc_id)
    return
```

### InteractionSystem 新增公開函式

```gdscript
# 跳過 task 檢查，直接執行貿易（供 PlayerCommandSystem 呼叫）
func resolve_trade_direct(state: WorldState, initiator_id: int, target_id: int) -> Dictionary:
    # 複用 _resolve_trade() 的資源轉移邏輯，移除 current_task 檢查
    # 返回 { "ok": bool, "msg": String }

# 跳過 task 檢查，直接執行勒索（供 PlayerCommandSystem 呼叫）
func resolve_extortion_direct(state: WorldState, aggressor_id: int, target_id: int) -> Dictionary:
    # 複用 _resolve_extortion() 邏輯，移除 current_task 檢查
    # 返回 { "ok": bool, "msg": String }
```

---

## 3. PlayerCommandSystem（新建）

**檔案：** `scripts/simulation/player_command_system.gd`

```gdscript
class_name PlayerCommandSystem

var _interaction: InteractionSystem = InteractionSystem.new()
var _diplomatic:  DiplomaticAiSystem = DiplomaticAiSystem.new()

# ── 主動互動 ────────────────────────────────────────────

# 查詢對 target_id 可用的行動（已過濾條件）
# 返回 Array[String]，子集合自：
#   "trade"            → target 有可賣資源 OR 玩家有 coin
#   "propose_alliance" → target 非同勢力
#   "demand_tribute"   → 玩家 pop > target.pop × 1.5
#   "attack"           → 永遠可選
#   "extort"           → 玩家 readiness >= 0.7
#   "recruit"          → 永遠可選（STUB — 招募邏輯尚未實裝）
#   "ignore"           → 永遠可選
func get_available_actions(state: WorldState, target_id: int) -> Array[String]:
    var actions: Array[String] = ["ignore", "attack"]
    var pt: TeamData = _get_player_team(state)
    var tgt: TeamData = state.teams.get(target_id)
    if pt == null or tgt == null: return actions
    if _can_trade(state, pt, tgt):
        actions.append("trade")
    if tgt.faction_id != pt.faction_id:
        actions.append("propose_alliance")
    if pt.population > int(tgt.population * 1.5):
        actions.append("demand_tribute")
    if pt.readiness >= 0.7:
        actions.append("extort")
    actions.append("recruit")   # STUB
    return actions

# 執行玩家主動行動
# 返回 { "ok": bool, "msg": String }
func execute_action(state: WorldState, target_id: int, action: String) -> Dictionary:
    var pt: TeamData = _get_player_team(state)
    var pt_id: int   = _get_player_team_id(state)
    match action:
        "trade":
            var result := _interaction.resolve_trade_direct(state, pt_id, target_id)
            state.player_pending_targets.erase(target_id)
            return result
        "propose_alliance":
            var tgt: TeamData = state.teams[target_id]
            var resp: String = _diplomatic.handle_diplomacy_message(state, tgt, pt, "alliance")
            state.player_pending_targets.erase(target_id)
            return { "ok": true, "msg": resp }
        "demand_tribute":
            var tgt: TeamData = state.teams[target_id]
            var resp: String = _diplomatic.handle_diplomacy_message(state, tgt, pt, "tribute")
            state.player_pending_targets.erase(target_id)
            return { "ok": true, "msg": resp }
        "attack":
            pt.combat_target = target_id
            # 直接呼叫 EncounterSystem.setup_encounter(state, pt_id, target_id)
            state.player_pending_targets.erase(target_id)
            return { "ok": true, "msg": "發起攻擊" }
        "extort":
            var result := _interaction.resolve_extortion_direct(state, pt_id, target_id)
            state.player_pending_targets.erase(target_id)
            return result
        "extort":
            var result := _interaction.resolve_extortion_direct(state, pt_id, target_id)
            state.player_pending_targets.erase(target_id)
            return result
        "recruit":
            # STUB — 招募邏輯尚未實裝（說服/付費/目標成員選擇）
            state.player_pending_targets.erase(target_id)
            return { "ok": false, "msg": "招募功能尚未實裝" }
        "ignore":
            state.player_pending_targets.erase(target_id)
            return { "ok": true, "msg": "忽略" }
    return { "ok": false, "msg": "未知行動" }

# ── 被動回應（NPC 強制非戰互動）──────────────────────────

# 查詢 forced_event 的回應選項
# "diplomacy" → ["accept", "refuse"]
# "extort"    → ["pay", "refuse"]
func get_forced_response_options(state: WorldState) -> Array[String]:
    match state.player_forced_event.get("action", ""):
        "diplomacy": return ["accept", "refuse"]
        "extort":    return ["pay", "refuse"]
    return []

# 回應強制互動，清除 forced_event
# 返回 { "ok": bool, "msg": String }
func respond_to_forced(state: WorldState, response: String) -> Dictionary:
    var fe: Dictionary = state.player_forced_event
    if fe.is_empty(): return { "ok": false, "msg": "無待處理事件" }
    var result: Dictionary
    match fe.get("action", ""):
        "diplomacy":
            if response == "accept":
                result = _accept_diplomacy(state, fe.get("from_id", -1), fe.get("proposal", ""))
            else:
                result = { "ok": true, "msg": "拒絕提案" }
        "extort":
            if response == "pay":
                result = _pay_extortion(state, fe.get("from_id", -1))
            else:
                result = { "ok": true, "msg": "拒絕勒索" }
        _:
            result = { "ok": false, "msg": "未知強制事件" }
    state.player_forced_event = {}
    return result

# ── 清除 pending ──────────────────────────────────────────

# 玩家 team 格子改變時呼叫
func clear_pending_targets(state: WorldState) -> void:
    state.player_pending_targets.clear()
    # player_forced_event 不清除（NPC 外交/勒索不因移動取消）

# ── 內部 helper ───────────────────────────────────────────

func _get_player_team(state: WorldState) -> TeamData:
    var p: PersonData = state.persons.get(state.player_id)
    if p == null: return null
    return state.teams.get(p.team_id)

func _get_player_team_id(state: WorldState) -> int:
    var p: PersonData = state.persons.get(state.player_id)
    return p.team_id if p != null else -1

func _can_trade(state: WorldState, pt: TeamData, tgt: TeamData) -> bool:
    # 簡單判斷：雙方有可交換資源（細節留實作）
    return float(pt.resources.get("coin", 0)) > 0 or float(tgt.resources.get("coin", 0)) > 0

func _accept_diplomacy(state: WorldState, from_id: int, proposal: String) -> Dictionary:
    # 根據 proposal 類型執行：加入勢力 / 提供 tribute / 投降
    # 細節複用 DiplomaticAiSystem 現有邏輯
    return { "ok": true, "msg": "接受：%s" % proposal }

func _pay_extortion(state: WorldState, from_id: int) -> Dictionary:
    # 轉移資源給 from_id team（金額由現有 _resolve_extortion 邏輯決定）
    return { "ok": true, "msg": "支付勒索" }
```

---

## 4. SimRunner 修改

### 非阻塞 forced_event 超時自動拒絕

在 near 區邏輯末尾加入（每 tick 執行，但 forced_event 是上一 tick 寫入的）：

```gdscript
# 玩家未在本 tick 回應非阻塞 forced_event → 自動拒絕並清除
if not state.player_forced_event.is_empty():
    print("[PlayerCmd] forced_event 超時自動拒絕: %s" % str(state.player_forced_event))
    state.player_forced_event = {}
```

### pending_targets 清除

在 `_step2_move_teams()` 中，若偵測到玩家 team tile_pos 改變 → 呼叫 `_player_cmd.clear_pending_targets(state)`

新增 member：
```gdscript
var _player_cmd: PlayerCommandSystem = PlayerCommandSystem.new()
```

---

## 5. 修改檔案清單

| 檔案 | 動作 |
|---|---|
| `scripts/data/world_state.gd` | 加 `player_pending_targets`、`player_forced_event` |
| `scripts/simulation/interaction_system.gd` | 替換玩家分支邏輯；新增 `resolve_trade_direct()`、`resolve_extortion_direct()` |
| `scripts/simulation/player_command_system.gd` | **新建** |
| `scripts/simulation/sim_runner.gd` | 加 `_player_cmd` member；超時清除；移動時清 pending |
| `scripts/debug/headless_test.gd` | 加 PlayerCommandSystem 測試 |

---

## 6. headless_test 驗證

```gdscript
print("--- PlayerCommandSystem Tests ---")
var cmd := PlayerCommandSystem.new()
var pt_id: int = state.persons.get(state.player_id).team_id

# 測試：主動貿易
state.teams[1].tile_pos = state.teams[pt_id].tile_pos
state.player_pending_targets.append(1)
var actions := cmd.get_available_actions(state, 1)
assert(actions.has("ignore"), "ignore 永遠可選")
assert(actions.has("attack"), "attack 永遠可選")
var result := cmd.execute_action(state, 1, "ignore")
assert(result.get("ok"), "ignore 應成功")
assert(not state.player_pending_targets.has(1), "ignore 後 pending 清除")

# 測試：NPC 外交提案 → 回應
state.player_forced_event = { "from_id": 2, "action": "diplomacy", "proposal": "alliance" }
var opts := cmd.get_forced_response_options(state)
assert(opts.has("accept") and opts.has("refuse"), "外交選項應有 accept/refuse")
var resp := cmd.respond_to_forced(state, "refuse")
assert(resp.get("ok"), "refuse 應成功")
assert(state.player_forced_event.is_empty(), "回應後 forced_event 清除")

print("--- PlayerCommandSystem Tests PASSED ---")
```

---

## 7. 注意事項

- **EncounterSystem.setup_encounter()** 需確認函式名稱（現有 encounter_system.gd 的進場函式簽名）
- **NPC 外交 task 的 order_target_id**：需確認 NPC 外交 task 是否用 `order_target_id` 記錄目標（interaction_system 現有邏輯）
- **forced_event 超時 1 tick**：設計為「上一 tick 寫入，本 tick 若未回應即清除」。UI 必須在同 tick 內讀取並讓玩家回應，否則會消失。若需要更長的回應視窗，改為 N tick 計數器（留實作決定）
- **勒索金額**：`_pay_extortion()` 的具體金額邏輯複用 `InteractionSystem._resolve_extortion()` 中的計算
