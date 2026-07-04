# Demand Tribute Design

> 日期：2026-06-02 | 依賴：interaction-ui-framework

---

## 目標

「要求納貢」加入：
1. NPC 拒絕邏輯（依義氣/慎重值決定）
2. 拒絕後果（關係惡化、加入 hostile_teams）

---

## 修改範圍

純內部邏輯，無新增 UI。`execute_action("demand_tribute")` 已在框架中路由。

| 檔案 | 改動 |
|---|---|
| `scripts/simulation/player_command_system.gd` | `execute_action("demand_tribute")` 加後果邏輯 |
| `scripts/simulation/diplomatic_ai_system.gd` | `handle_diplomacy_message("demand_tribute")` 加 NPC 判斷公式 |

---

## `diplomatic_ai_system.gd` — demand_tribute NPC 判斷

在 `handle_diplomacy_message` 的 `"demand_tribute"` case，加接受/拒絕評分：

```gdscript
"demand_tribute":
    var leader: PersonData = state.persons.get(tgt.leader_id)
    var pride:   float = float(leader.values.get("義氣", 0.5)) if leader else 0.5
    var caution: float = float(leader.values.get("慎重", 0.5)) if leader else 0.5
    var power_r: float = float(from_t.population) / maxf(float(tgt.population), 1.0)
    # 接受分：強弱差大 + 謹慎 → 傾向接受；義氣高 → 傾向拒絕
    var score: float = (power_r - 1.0) * 0.4 + caution * 0.3 - pride * 0.3
    return "accept" if score > 0.0 else "refuse"
```

（若現有邏輯已有此 case，對齊公式即可；若無此 case，加入 match 分支）

---

## `player_command_system.gd` — execute_action("demand_tribute") 完整替換

```gdscript
"demand_tribute":
    var tgt: TeamData = state.teams.get(target_id)
    if tgt == null:
        return { "ok": false, "msg": "目標不存在" }
    var resp: String = _diplomatic.handle_diplomacy_message(
        state, tgt, pt, "demand_tribute")
    state.player_pending_targets.erase(target_id)

    if resp == "accept":
        var amount: float = float(tgt.resources.get("coin", 0)) * 0.1
        tgt.resources["coin"] = float(tgt.resources.get("coin", 0)) - amount
        pt.resources["coin"]  = float(pt.resources.get("coin", 0)) + amount
        print("[PlayerCmd] 索貢成功 Team%d → 玩家 %.0f coin" % [target_id, amount])
        return { "ok": true, "msg": "索貢成功（獲得%.0f coin）" % amount }
    else:
        # 拒絕 → 關係惡化
        tgt.unrest_turns += 2
        if not state.player_hostile_teams.has(target_id):
            state.player_hostile_teams.append(target_id)
        var leader_p: PersonData = state.persons.get(tgt.leader_id)
        if leader_p:
            leader_p.memory.append({
                "event_id": state.world.current_tick,
                "intensity": "significant",
                "reaction": "tribute_refused"
            })
        print("[PlayerCmd] 索貢遭拒 Team%d → hostile" % target_id)
        return { "ok": false, "msg": "索貢遭拒，關係惡化" }
```

---

## `player_query_api.gd` — available_actions 條件

`demand_tribute` 行動條件（現有）：`pt.population > tgt.population * 1.5`

顯示 disabled 版本（讓玩家知道條件），當條件不足時：
```gdscript
{
    "action_id": "demand_tribute", "label": "索貢",
    "enabled": false,
    "disabled_reason": "人口不足（需超過對方 1.5 倍）",
    ...
}
```

---

## 驗證

| 情境 | 預期 |
|---|---|
| 索貢，NPC 接受 | 玩家 coin 增加，底部顯示金額 |
| 索貢，NPC 拒絕（高義氣） | 底部「索貢遭拒，關係惡化」；target 加入 hostile_teams |
| 拒絕後同格 tick 推進 | target 自動攻擊玩家 |
| 人口條件不足 | 行動在選單顯示但 disabled |
