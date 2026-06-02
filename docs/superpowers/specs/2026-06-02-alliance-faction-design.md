# Alliance & Faction Design

> 日期：2026-06-02 | 依賴：interaction-ui-framework | 修正 G3、G5

---

## 目標

1. **建立勢力**（G3）：`execute_action("establish_faction")`
2. **同盟修正**（G5）：玩家發起，雙方獨立 → 玩家為領袖
3. **收編防護**：NPC 發起同盟，雙方獨立時 → `forced_interaction.responses` 含三個選項

---

## G3：establish_faction

### `player_command_system.gd`

```gdscript
func establish_faction(state: WorldState) -> Dictionary:
    var pt: TeamData = _get_player_team(state)
    var pt_id: int   = _get_player_team_id(state)
    if pt == null:
        return { "ok": false, "code": "no_controlled_team",
                 "message": "找不到玩家隊伍", "payload": {} }
    if pt.faction_id != -1:
        return { "ok": false, "code": "action_unavailable",
                 "message": "已屬勢力%d" % pt.faction_id, "payload": {} }
    state.create_faction(pt_id)
    print("[PlayerCmd] 玩家建立勢力%d" % pt.faction_id)
    return { "ok": true, "code": "ok",
             "message": "建立勢力%d" % pt.faction_id,
             "payload": {"action_id": "establish_faction", "refresh_required": true} }
```

### `player_command_api.gd` — 路由

```gdscript
"establish_faction":
    return _cmd_sys.establish_faction(state)
```

### `player_query_api.gd` — available_actions 加入條件

當 `player_team.faction_id == -1`：
```gdscript
{
    "action_id": "establish_faction",
    "label": "建立勢力",
    "enabled": true,
    "disabled_reason": "",
    "target_requirements": {
        "allowed_kinds": ["none"],
        "requires_visible_target": false,
        "requires_forced_interaction": false,
        "allows_self_target": false
    },
    "command_name": "execute_action",
    "command_args": {
        "action_id": "establish_faction",
        "target": {"kind": "none", "team_id": -1, "member_id": -1,
                   "tile_q": -1, "tile_r": -1}
    }
}
```

注意：`establish_faction` 出現在 **team/global context** 層（不需要選擇目標），
在 `get_available_actions({team_id:-1, ...})` 時回傳，不依賴 target team。

---

## G5：玩家發起同盟，雙方獨立

### `player_command_system.gd` — `execute_action("propose_alliance")` 修正

```gdscript
"propose_alliance":
    var tgt: TeamData = state.teams.get(target_id)
    if tgt == null:
        return { "ok": false, "msg": "目標不存在" }
    var resp: String = _diplomatic.handle_diplomacy_message(
        state, tgt, pt, "propose_alliance")
    if resp == "accept":
        if pt.faction_id == -1 and tgt.faction_id == -1:
            state.create_faction(pt_id)   # 玩家為領袖（G5 修正）
        _diplomatic._form_alliance(state, pt, tgt)
        print("[PlayerCmd] 同盟成立，勢力%d" % pt.faction_id)
    state.player_pending_targets.erase(target_id)
    return { "ok": resp == "accept", "msg": "外交結果: %s" % resp }
```

（此為 `player_command_system` 內部邏輯；`player_command_api` 只路由，不改此邏輯）

---

## 收編防護：NPC 發起同盟

### 設計

當 `player_forced_event.action == "diplomacy"` 且雙方 `faction_id == -1`：
- 現狀：`map_forced_interaction` 只給 `["accept", "refuse"]`
- 修正：給三個 responses

### `player_api_mapper.gd` — `map_forced_interaction` 修正

```gdscript
func map_forced_interaction(state: WorldState, fe: Dictionary) -> Dictionary:
    if fe.is_empty():
        return _empty_forced_interaction()
    var iid: String  = state.player_forced_event_id
    var itype: String = fe.get("action", "")
    var from_id: int  = fe.get("from_id", -1)
    var from_team: TeamData = state.teams.get(from_id)
    var from_name: String = "Team%d" % from_id
    if from_team:
        from_name = "Team%d[%s]" % [from_id,
            "勢力%d" % from_team.faction_id if from_team.faction_id >= 0 else "獨立"]

    var msg: String = fe.get("detail", "")
    var responses: Array = []

    # 判斷是否雙方皆獨立（diplomacy 才需特判）
    var player_team: TeamData = _get_player_team(state)
    var both_independent: bool = itype == "diplomacy" \
        and fe.get("proposal", "") in ["alliance", "surrender"] \
        and from_team != null and player_team != null \
        and from_team.faction_id == -1 and player_team.faction_id == -1

    if itype == "diplomacy":
        if both_independent:
            responses = [
                { "response_id": "accept_join",  "label": "加入對方勢力（對方為主）",
                  "command_args": {"interaction_id": iid, "response_id": "accept_join"} },
                { "response_id": "accept_lead",  "label": "自立後接納對方（我為主）",
                  "command_args": {"interaction_id": iid, "response_id": "accept_lead"} },
                { "response_id": "refuse",       "label": "✗ 拒絕",
                  "command_args": {"interaction_id": iid, "response_id": "refuse"} }
            ]
        else:
            responses = [
                { "response_id": "accept", "label": "✓ 接受",
                  "command_args": {"interaction_id": iid, "response_id": "accept"} },
                { "response_id": "refuse", "label": "✗ 拒絕",
                  "command_args": {"interaction_id": iid, "response_id": "refuse"} }
            ]
    elif itype == "extort":
        responses = [
            { "response_id": "pay",    "label": "💰 支付",
              "command_args": {"interaction_id": iid, "response_id": "pay"} },
            { "response_id": "refuse", "label": "✗ 拒絕",
              "command_args": {"interaction_id": iid, "response_id": "refuse"} }
        ]
    elif itype == "trade":
        responses = [
            { "response_id": "accept", "label": "✓ 接受貿易",
              "command_args": {"interaction_id": iid, "response_id": "accept"} },
            { "response_id": "refuse", "label": "✗ 拒絕",
              "command_args": {"interaction_id": iid, "response_id": "refuse"} }
        ]

    return {
        "interaction_id": iid,
        "interaction_type": itype,
        "source": {
            "team_id": from_id, "team_name": from_name,
            "member_id": -1, "member_name": ""
        },
        "message": msg,
        "responses": responses
    }
```

### `player_command_system.gd` — `respond_to_forced` 加新 response_id

在 `respond_to_forced` 的 `"diplomacy"` case 加分支：

```gdscript
"diplomacy":
    match response:
        "accept", "accept_join":
            result = _accept_diplomacy(state,
                fe.get("from_id", -1), fe.get("proposal", "alliance"))
        "accept_lead":
            result = _accept_diplomacy_as_leader(state, fe.get("from_id", -1))
        "refuse":
            result = { "ok": true, "msg": "拒絕外交提案" }
```

**新增 `_accept_diplomacy_as_leader()`：**

```gdscript
func _accept_diplomacy_as_leader(state: WorldState, from_id: int) -> Dictionary:
    var from_team: TeamData = state.teams.get(from_id)
    var pt: TeamData = _get_player_team(state)
    var pt_id: int   = _get_player_team_id(state)
    if from_team == null or pt == null:
        return { "ok": false, "msg": "隊伍不存在" }
    if pt.faction_id == -1:
        state.create_faction(pt_id)
    _diplomatic._form_alliance(state, pt, from_team)
    return { "ok": true, "msg": "自立後接納 Team%d，勢力%d" % [from_id, pt.faction_id] }
```

### `player_command_system.gd` — `get_forced_response_options` 更新

```gdscript
func get_forced_response_options(state: WorldState) -> Array[String]:
    var fe: Dictionary = state.player_forced_event
    match fe.get("action", ""):
        "diplomacy":
            # mapper 負責雙獨立特判；此處給最大集合
            return ["accept", "accept_join", "accept_lead", "refuse"]
        "extort":
            return ["pay", "refuse"]
        "trade":
            return ["accept", "refuse"]
    return []
```

---

## UI 端

收編防護完全由 `forced_interaction.responses` DTO 驅動。
`show_forced_event` popup 直接顯示 3 個按鈕（當雙方獨立時 mapper 生成 3 個 responses）。
**UI 無需硬編任何「雙獨立」判斷**。

---

## 驗證

| 情境 | 預期 |
|---|---|
| 玩家按「建立勢力」（available_actions） | `pt.faction_id` 更新，snapshot 不再含此 action |
| 玩家發起同盟，NPC 接受，雙方獨立 | 玩家為領袖建立勢力，NPC 加入 |
| NPC 發起同盟，雙方獨立 | `forced_interaction.responses` 有 3 個選項 |
| 選「自立後接納」 | `_accept_diplomacy_as_leader` 執行，玩家為主 |
| NPC 發起同盟，玩家已有勢力 | `forced_interaction.responses` 只有 accept/refuse |
