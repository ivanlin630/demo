# Extort Design

> 日期：2026-06-02 | 依賴：interaction-ui-framework

---

## 目標

勒索加入 **NPC 拒絕邏輯**（評分公式），拒絕時關係惡化。

---

## 修改範圍

純內部邏輯，無新增 UI。`execute_action("extort")` 已在框架中路由。

| 檔案 | 改動 |
|---|---|
| `scripts/simulation/interaction_system.gd` | `resolve_extortion_direct` 加 NPC 拒絕判斷 |
| `scripts/simulation/player_command_system.gd` | `execute_action("extort")` 加拒絕後果 |

---

## NPC 拒絕評分公式

接受分 > 0.5 → 接受；否則拒絕（TEST VALUE）：

```
score = (from_pop / tgt_pop - 1) × 0.4    # 強弱差
      + caution × 0.2                       # 謹慎 → 接受
      - pride × 0.3                         # 義氣 → 拒絕
      + fear × 0.2                          # 恐懼 → 接受
      + from_readiness × 0.2               # 武裝威懾 → 接受
```

---

## `interaction_system.gd` — `resolve_extortion_direct` 修改

在現有資源轉移**前**加拒絕判斷，返回 Dictionary：

```gdscript
func resolve_extortion_direct(state: WorldState, from_id: int, to_id: int) -> Dictionary:
    var from_t: TeamData = state.teams.get(from_id)
    var to_t:   TeamData = state.teams.get(to_id)
    if from_t == null or to_t == null:
        return { "ok": false, "accepted": false, "msg": "隊伍不存在" }

    var leader: PersonData = state.persons.get(to_t.leader_id)
    var caution: float = float(leader.values.get("慎重", 0.5)) if leader else 0.5
    var pride:   float = float(leader.values.get("義氣", 0.5)) if leader else 0.5
    var fear:    float = leader.fear if leader else 0.3
    var power_r: float = float(from_t.population) / maxf(float(to_t.population), 1.0)
    var score:   float = (power_r - 1.0) * 0.4 + caution * 0.2 \
                       - pride * 0.3 + fear * 0.2 + from_t.readiness * 0.2
    var accepted: bool = score > 0.5   # TEST VALUE

    if not accepted:
        print("[Extort] Team%d 拒絕勒索 (score=%.2f)" % [to_id, score])
        return { "ok": true, "accepted": false, "msg": "對方拒絕勒索" }

    # 原有轉移邏輯（對齊現有實作）
    var coin: float  = float(to_t.resources.get("coin", 0))
    var steal: float = minf(coin * 0.2, coin)   # 20%，TEST VALUE
    to_t.resources["coin"]   = coin - steal
    from_t.resources["coin"] = float(from_t.resources.get("coin", 0)) + steal
    print("[Extort] Team%d 勒索 Team%d %.0f coin" % [from_id, to_id, steal])
    return { "ok": true, "accepted": true,
             "msg": "勒索成功（獲得%.0f coin）" % steal }
```

注意：若現有 `resolve_extortion_direct` 已有回傳值格式，對齊並加入 `"accepted"` key。

---

## `player_command_system.gd` — `execute_action("extort")` 加拒絕後果

```gdscript
"extort":
    var result := _interaction.resolve_extortion_direct(state, pt_id, target_id)
    state.player_pending_targets.erase(target_id)
    if not result.get("accepted", true):
        var tgt2: TeamData = state.teams.get(target_id)
        if tgt2:
            tgt2.unrest_turns += 1
        if not state.player_hostile_teams.has(target_id):
            state.player_hostile_teams.append(target_id)
        print("[PlayerCmd] 勒索遭拒 Team%d → hostile" % target_id)
    return { "ok": result.get("ok", false), "msg": result.get("msg", "") }
```

---

## `player_query_api.gd` — available_actions 條件

`extort` 條件（現有）：`pt.readiness >= 0.7`

顯示 disabled 版本：
```gdscript
{
    "action_id": "extort", "label": "勒索",
    "enabled": false,
    "disabled_reason": "準備值不足（需 ≥ 0.7，現為%.1f）" % pt.readiness,
    ...
}
```

---

## 驗證

| 情境 | 預期 |
|---|---|
| 勒索，低慎重 / 低義氣 / 高恐懼 NPC | 大概率接受，玩家 coin 增加 |
| 勒索，高義氣 NPC | 大概率拒絕，target 加入 hostile_teams |
| 拒絕後同格 tick | target 自動攻擊 |
| readiness < 0.7 | 勒索 action disabled |
