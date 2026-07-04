# Recruit Design

> 日期：2026-06-02 | 依賴：interaction-ui-framework | 修正 G4

---

## 目標

招募從 STUB 實裝：
- **Tier 1（匿名）**：花費 coin，從目標 team 匿名人口轉移 1 人
- **Tier 2（Named）**：低忠誠 named member 可投誠（玩家額外付費）

---

## 資料流

```
玩家點「招募」
  → command_player("execute_action", {action_id:"recruit", target:{kind:"team", team_id:tid}})
  → result.payload.has_willing_named = false
      → Tier 1 直接執行，顯示結果訊息
  → result.payload.has_willing_named = true
      → main._on_interact_execute 偵測到需面板
      → popups.show_recruit_panel(payload.willing_members, tid, named_fn, anon_fn)
          → 選 named → execute_action(recruit_named, target:{kind:"member", team_id, member_id})
          → 選匿名  → execute_action(recruit_anon, target:{kind:"team", team_id})
```

---

## 常數

```gdscript
# player_command_system.gd 頂層
const RECRUIT_COST_ANON:  float = 50.0   # TEST VALUE
const RECRUIT_COST_NAMED: float = 150.0  # TEST VALUE
```

---

## 修改檔案

| 檔案 | 改動 |
|---|---|
| `scripts/simulation/player_command_system.gd` | 加常數；`execute_action("recruit")` 實裝；加 `recruit_anon`、`recruit_named` |
| `scripts/simulation/player_command_api.gd` | 路由 `recruit_anon`、`recruit_named` |
| `scripts/simulation/player_api_mapper.gd` | 加 `map_willing_members` helper |
| `scripts/ui/popup_layer.gd` | 加 `show_recruit_panel()` |

---

## A. `player_command_system.gd`

### `get_available_actions` — 改條件

```gdscript
# 原：actions.append("recruit")  # STUB
# 改：
var coin: float = float(pt.resources.get("coin", 0))
if coin >= RECRUIT_COST_ANON:
    actions.append("recruit")
```

### `execute_action("recruit")` — 完整替換

```gdscript
"recruit":
    var tgt: TeamData = state.teams.get(target_id)
    if tgt == null:
        state.player_pending_targets.erase(target_id)
        return { "ok": false, "msg": "目標不存在" }

    # 找低忠誠 named member（排除 leader）
    var willing: Array = []
    for pid in tgt.named_members:
        if pid == tgt.leader_id: continue
        var p: PersonData = state.persons.get(pid)
        if p and p.loyalty < 0.4:
            willing.append(pid)

    if not willing.is_empty():
        # Tier 2 路徑：回傳 DTO，讓 UI 開面板
        var willing_dto: Array = _mapper.map_willing_members(state, willing)
        # 不 erase pending_target，讓後續招募操作仍可執行
        return { "ok": true, "msg": "有成員考慮投誠",
                 "payload": {
                     "has_willing_named": true,
                     "willing_members": willing_dto,
                     "target_team_id": target_id
                 }}

    # Tier 1：直接匿名招募
    return _recruit_anon_internal(state, pt, tgt, target_id)

func _recruit_anon_internal(state: WorldState, pt: TeamData,
        tgt: TeamData, target_id: int) -> Dictionary:
    var coin: float = float(pt.resources.get("coin", 0))
    if coin < RECRUIT_COST_ANON:
        state.player_pending_targets.erase(target_id)
        return { "ok": false, "msg": "金幣不足（需%d）" % int(RECRUIT_COST_ANON) }
    if tgt.population <= 1:
        state.player_pending_targets.erase(target_id)
        return { "ok": false, "msg": "目標人口不足" }
    pt.resources["coin"] = coin - RECRUIT_COST_ANON
    tgt.population = maxi(tgt.population - 1, 1)
    pt.population += 1
    state.player_pending_targets.erase(target_id)
    print("[Recruit] 匿名 Team%d←%d, 花%.0f coin, 新人口=%d" % [
        pt.team_id, target_id, RECRUIT_COST_ANON, pt.population])
    return { "ok": true, "msg": "招募成功（花費%d coin，新人口%d）" % [
        int(RECRUIT_COST_ANON), pt.population],
        "payload": {"has_willing_named": false, "refresh_required": true} }
```

### 加 `recruit_anon` action_id（fallback from panel）

```gdscript
"recruit_anon":
    var tgt3: TeamData = state.teams.get(target_id)
    if tgt3 == null:
        return { "ok": false, "msg": "目標不存在" }
    return _recruit_anon_internal(state, pt, tgt3, target_id)
```

### 加 `recruit_named` action_id

```gdscript
"recruit_named":
    # target.kind = "member"，target.team_id + target.member_id
    var from_team_id: int = request.get("target", {}).get("team_id", -1)
    var person_id: int    = request.get("target", {}).get("member_id", -1)
    return _recruit_named_internal(state, pt, from_team_id, person_id)

func _recruit_named_internal(state: WorldState, pt: TeamData,
        from_team_id: int, person_id: int) -> Dictionary:
    var tgt4: TeamData    = state.teams.get(from_team_id)
    var p: PersonData     = state.persons.get(person_id)
    if tgt4 == null or p == null or p.team_id != from_team_id:
        return { "ok": false, "msg": "成員不存在或已離隊" }
    var coin: float = float(pt.resources.get("coin", 0))
    if coin < RECRUIT_COST_NAMED:
        return { "ok": false, "msg": "金幣不足（named 需%d）" % int(RECRUIT_COST_NAMED) }
    # 轉移
    pt.resources["coin"] = coin - RECRUIT_COST_NAMED
    tgt4.named_members.erase(person_id)
    tgt4.population = maxi(tgt4.population - 1, 1)
    p.team_id = pt.team_id
    p.loyalty  = 0.5
    pt.named_members.append(person_id)
    pt.population += 1
    state.player_pending_targets.erase(from_team_id)
    print("[Recruit] Named P%d (%s) Team%d→%d" % [
        person_id, p.person_name, from_team_id, pt.team_id])
    return { "ok": true, "msg": "招募 %s 成功（花費%d coin）" % [
        p.person_name, int(RECRUIT_COST_NAMED)],
        "payload": {"refresh_required": true} }
```

---

## B. `player_command_api.gd` — 路由

```gdscript
# execute_action 內加這幾個 action_id 的路由，對應到 _cmd_sys 的方法
"recruit_anon":
    # target.kind = "team"
    return _cmd_sys.execute_action(state, request)   # 已在 player_command_system 處理
"recruit_named":
    # target.kind = "member"
    return _cmd_sys.execute_action(state, request)
```

（若 `player_command_api` 統一由 `_cmd_sys.execute_action(state, request)` 處理所有 action_id，無需個別路由）

---

## C. `player_api_mapper.gd` — 加 `map_willing_members()`

```gdscript
func map_willing_members(state: WorldState, person_ids: Array) -> Array:
    var result: Array = []
    for pid in person_ids:
        var p: PersonData = state.persons.get(pid)
        if p == null: continue
        var best_sk: String = "—"; var best_v: float = 0.0
        for sk in p.skills:
            var v: float = float(p.skills[sk])
            if v > best_v: best_v = v; best_sk = "%s:%.2f" % [sk, v]
        result.append({
            "person_id": pid,
            "name": p.person_name if p.person_name != "" else "P%d" % pid,
            "team_id": p.team_id,
            "loyalty": p.loyalty,
            "top_skill": best_sk,
            "recruit_cost": PlayerCommandSystem.RECRUIT_COST_NAMED
        })
    return result
```

---

## D. `player_query_api.gd` — available_actions 條件

```gdscript
# 招募條件：coin >= RECRUIT_COST_ANON
var coin: float = float(pt.resources.get("coin", 0))
var recruit_ok: bool = coin >= PlayerCommandSystem.RECRUIT_COST_ANON
{
    "action_id": "recruit", "label": "招募",
    "enabled": recruit_ok,
    "disabled_reason": "" if recruit_ok else \
        "金幣不足（需%d，現%d）" % [int(PlayerCommandSystem.RECRUIT_COST_ANON), int(coin)],
    "command_name": "execute_action",
    "command_args": {
        "action_id": "recruit",
        "target": {"kind":"team", "team_id": target_team_id,
                   "member_id": -1, "tile_q": -1, "tile_r": -1}
    }
}
```

---

## E. `popup_layer.gd` — `show_recruit_panel()`

接收 `willing_members: Array`（mapper DTO）、`target_team_id: int`、
`named_fn: Callable(person_id: int)`、`anon_fn: Callable()`：

```gdscript
func show_recruit_panel(willing_members: Array, target_team_id: int,
        named_fn: Callable, anon_fn: Callable) -> void:
    _close_current()
    var popup := _make_base_popup("招募")
    var vbox: VBoxContainer = popup.get_node("VBox/Scroll/Content")

    var hdr := Label.new()
    hdr.text = "Team%d 中有成員考慮投誠：" % target_team_id
    vbox.add_child(hdr)

    for m in willing_members:
        var row := HBoxContainer.new(); vbox.add_child(row)
        var lbl := Label.new()
        lbl.text = "%s  忠誠:%.0f%%  %s" % [
            m.get("name", "?"),
            float(m.get("loyalty", 0)) * 100.0,
            m.get("top_skill", "—")]
        lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        row.add_child(lbl)
        var btn := Button.new()
        btn.text = "招募（%d coin）" % int(m.get("recruit_cost", 150))
        var cp: int = m.get("person_id", -1)
        btn.pressed.connect(func():
            _close_current()
            named_fn.call(cp))
        row.add_child(btn)

    vbox.add_child(HSeparator.new())

    var anon_btn := Button.new()
    anon_btn.text = "改招匿名人口（%d coin）" % int(PlayerCommandSystem.RECRUIT_COST_ANON)
    anon_btn.pressed.connect(func(): _close_current(); anon_fn.call())
    vbox.add_child(anon_btn)

    var cancel_btn := Button.new(); cancel_btn.text = "取消"
    cancel_btn.pressed.connect(_close_current)
    vbox.add_child(cancel_btn)

    _current_popup = popup; add_child(popup)
```

---

## F. `main.gd` — `_on_interact_execute` 招募分支（補全）

```gdscript
if action_id == "recruit" and result.get("ok"):
    var payload: Dictionary = result.get("payload", {})
    if payload.get("has_willing_named", false):
        var tid_r: int = payload.get("target_team_id", -1)
        _popups.show_recruit_panel(
            payload.get("willing_members", []),
            tid_r,
            func(person_id: int) -> void:
                var r2 = _bridge.command_player("execute_action", {
                    "action_id": "recruit_named",
                    "target": {"kind":"member", "team_id": tid_r,
                               "member_id": person_id, "tile_q":-1, "tile_r":-1}
                })
                _bottom.add_message("[招募] %s" % r2.get("message", ""))
                _sidebar.refresh_player(); _debug.refresh(),
            func() -> void:
                var r3 = _bridge.command_player("execute_action", {
                    "action_id": "recruit_anon",
                    "target": {"kind":"team", "team_id": tid_r,
                               "member_id":-1, "tile_q":-1, "tile_r":-1}
                })
                _bottom.add_message("[招募] %s" % r3.get("message", ""))
                _sidebar.refresh_player(); _debug.refresh())
        return
    # Tier 1 已自動完成，只顯示訊息
    _bottom.add_message("[招募] %s" % result.get("message", ""))
    _sidebar.refresh_player(); _debug.refresh()
    return
```

---

## 驗證

| 情境 | 預期 |
|---|---|
| coin < 50 | 招募 action disabled，顯示原因 |
| 目標無低忠誠成員，coin ≥ 50 | Tier 1：匿名轉移，coin 減少 |
| 目標有低忠誠成員，coin ≥ 50 | 彈出面板列出候選人 |
| 選 Named 招募，coin ≥ 150 | `recruit_named` 執行，person 轉移，loyalty 重置 0.5 |
| 選「改招匿名」 | `recruit_anon` 執行 |
| 取消 | 無變化 |
