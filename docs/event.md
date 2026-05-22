# 事件 (Event)

## 相關文件
- [核心概念](game-design.md)
- [人物](person.md)
- [世界](world.md)
- [訊息](message.md)

---

## 架構：Registry 模式

定義於 `scripts/simulation/event_system.gd`。

EventSystem 只是一個 loop，每個事件類型是獨立腳本，繼承 `scripts/simulation/events/base_event.gd`：

```gdscript
class_name BaseEvent

func check(state: WorldState, team: TeamData) -> bool   # 是否觸發
func execute(state: WorldState, team: TeamData) -> Array # 執行，回傳新 Team（分裂用）
```

新增事件：建立 `scripts/simulation/events/event_XXX.gd`，在 `EventSystem._init()` 注冊一行即可。

---

## 目前事件清單

### event_unrest_split（團體分裂）

檔案：`scripts/simulation/events/event_unrest_split.gd`

觸發條件：
- `team.unrest_turns >= 30`
- 存在異見者（loyalty < 0.35）
- 異見者中有人 `values["義氣"] < 0.4` 且目標與領袖衝突

執行：
- 取一半異見者，建立新 Team（繼承 tile_pos）
- 分裂者的 population 從原 Team 扣除
- 義氣 >= 0.4 的異見者不觸發分裂（即使目標衝突）
- 分裂後 `unrest_turns` 歸零

### event_unrest_replace（領袖替換）

檔案：`scripts/simulation/events/event_unrest_replace.gd`

觸發條件：
- `team.unrest_turns >= 20`
- 存在異見者（loyalty < 0.35）且有人統領技能 >= 0.3

執行：
- 舊領袖降為 advisor
- 統領最高的異見者升為 leader
- `unrest_turns -= 20`

> **優先順序**：分裂事件在 replace 之前跑。分裂觸發後 unrest_turns 歸零，replace 不再觸發。

---

## 外部呼叫介面

### on_leader_death(state, team)

由外部系統（戰鬥等）呼叫，處理領袖死亡後的繼承：
- 找 team 內統領最高的成員
- 統領 >= 0.3 → 升為新 leader，回傳 true
- 無繼承人 → 回傳 false（呼叫方負責解散 Team）

---

## 事件流程（Tick 循環第 5 步）

```
SimRunner._step5_generate_events()
  → EventSystem.process_events(state, team_ids)
    → for each team:
        for each registered event:
          event.check() → true → event.execute()
```

---

## 不動亂的積累來源

`team.unrest_turns` 由 N2_riot 反應累積（每次 +1），由 P4_expand 反應消耗（每次 -1）。

觸發分裂或替換事件後依門檻扣減。

---

## 未來擴充

新增事件範例（不影響現有系統）：
- `event_famine_collapse.gd` — 長期飢荒後 Team 崩潰
- `event_war_declaration.gd` — Teams 間衝突觸發宣戰
- `event_plague.gd` — 人口損失事件
- `event_migration.gd` — Team 自發移動目標改變
