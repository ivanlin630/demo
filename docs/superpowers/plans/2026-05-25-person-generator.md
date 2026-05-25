# PersonGenerator Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 實作 PersonGenerator，當 team leader 死亡且無合格記名繼承人時，從匿名人口晉升新 leader。

**Architecture:** PersonGenerator 為獨立 class（`person_generator.gd`），`generate(team, state)` 檢查匿名人口後建立帶 tag 偏移的 PersonData 並加入 `state.persons`，回傳 PersonData 或 null。`event_system.on_leader_death` else 分支呼叫 PersonGenerator 作為 fallback；caller（`_kill_named_npc`）不需修改，現有流程自然處理後續。

**Tech Stack:** Godot 4.2.2 GDScript，無外部依賴。

---

## 檔案結構

| 檔案 | 動作 | 說明 |
|---|---|---|
| `scripts/simulation/person_generator.gd` | 新建 | PersonGenerator class |
| `scripts/simulation/event_system.gd` | 修改 line 37–68 | on_leader_death else 分支加 fallback |
| `scripts/debug/headless_test.gd` | 修改 | Team10 驗證場景 + 結果輸出 |
| `docs/progress.md` | 修改 | 加入完成項目 |

---

## 背景知識（implementer 必讀）

### 人口計算

`anon_pop = team.population - named_count`
`named_count = (1 if team.leader_id != -1 else 0) + advisors.size() + members.size()`

`team.population` 包含記名+匿名。匿名晉升後 population 不變（人還在）；dying leader 死後 `_kill_named_npc` 會把 population-1。

### on_leader_death 呼叫時序

`_kill_named_npc` (interaction_system.gd:586) 呼叫順序：
1. `event_system.on_leader_death(state, team)` ← 此時 dying leader **仍在** state.persons
2. `team.members.erase(p.id)` / `team.advisors.erase(p.id)`
3. `if team.leader_id == p.id: team.leader_id = -1` ← PersonGenerator 若更新 leader_id，此行不執行
4. `team.population -= 1`
5. `state.persons.erase(p.id)`

PersonGenerator 在 step 1 執行；若成功設定 `team.leader_id = new_id`，step 3 的 guard 不觸發，舊 leader 由 step 5 清除。**不需修改 _kill_named_npc。**

### on_leader_death else 觸發條件

- 無記名 NPC（best_successor == null），**或**
- 最佳記名 NPC 的統領 < COMMAND_SKILL_MIN（0.3）

兩種情況都呼叫 PersonGenerator。

### tag 偏移設計

| tag | 屬性偏移（+0.1，clamp 0.2–0.8） | 技能偏移（+0.05，clamp 0.0–0.2） |
|---|---|---|
| 軍隊 | 體力 | 戰鬥、弓箭 |
| 生產 | 智力 | 生產、製造 |
| 商隊 | 魅力 | 交涉、商業 |
| 宗教 | 魅力 | 交涉 |
| 統領 | 體力+0.05、魅力+0.05 | 統領 |
| 流亡 | 毅力 | 求生 |

---

## Task A：PersonGenerator class

**Files:**
- Create: `scripts/simulation/person_generator.gd`

- [ ] **Step 1: 建立檔案，寫 class 骨架並確認 import**

```gdscript
# scripts/simulation/person_generator.gd
class_name PersonGenerator

const TAG_ATTR_BIAS: Dictionary = {
    "軍隊": { "體力": 0.1 },
    "生產": { "智力": 0.1 },
    "商隊": { "魅力": 0.1 },
    "宗教": { "魅力": 0.1 },
    "統領": { "體力": 0.05, "魅力": 0.05 },
    "流亡": { "毅力": 0.1 },
}

const TAG_SKILL_BIAS: Dictionary = {
    "軍隊": { "戰鬥": 0.05, "弓箭": 0.05 },
    "生產": { "生產": 0.05, "製造": 0.05 },
    "商隊": { "交涉": 0.05, "商業": 0.05 },
    "宗教": { "交涉": 0.05 },
    "統領": { "統領": 0.05 },
    "流亡": { "求生": 0.05 },
}

func generate(team: TeamData, state: WorldState) -> PersonData:
    var named_count: int = (1 if team.leader_id != -1 else 0) \
        + team.advisors.size() + team.members.size()
    var anon_pop: int = team.population - named_count
    if anon_pop <= 0:
        return null

    var p := PersonData.new()
    p.id          = _next_id(state)
    p.person_name = "NPC_%d" % p.id
    p.role        = "civilian"
    p.team_id     = team.team_id
    p.age         = randi_range(18, 40)
    p.loyalty     = 0.5
    p.stress      = 0.0

    for attr in p.attributes:
        p.attributes[attr] = randf_range(0.2, 0.8)
    for v in p.values:
        p.values[v] = randf_range(0.2, 0.8)
    for skill in p.skills:
        p.skills[skill] = randf_range(0.0, 0.2)

    for tag in team.tags:
        if TAG_ATTR_BIAS.has(tag):
            for attr in TAG_ATTR_BIAS[tag]:
                p.attributes[attr] = clampf(
                    p.attributes[attr] + float(TAG_ATTR_BIAS[tag][attr]), 0.2, 0.8)
        if TAG_SKILL_BIAS.has(tag):
            for skill in TAG_SKILL_BIAS[tag]:
                p.skills[skill] = clampf(
                    p.skills[skill] + float(TAG_SKILL_BIAS[tag][skill]), 0.0, 0.2)

    state.persons[p.id] = p
    return p

func _next_id(state: WorldState) -> int:
    if state.persons.is_empty():
        return 0
    return state.persons.keys().max() + 1
```

- [ ] **Step 2: 重建 class 快取**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

預期：無 error，exit 0。

- [ ] **Step 3: Commit**

```powershell
git add scripts/simulation/person_generator.gd
git commit -m "feat(sim): add PersonGenerator for anon-to-named promotion"
```

---

## Task B：整合進 event_system.on_leader_death

**Files:**
- Modify: `scripts/simulation/event_system.gd` lines 36–68

- [ ] **Step 1: 找到 else 分支，替換**

目前 lines 36–68（`on_leader_death` 函數末段）：

```gdscript
    if best_successor != null and best_command >= COMMAND_SKILL_MIN:
        print("[Event] Team %d 新領袖：Person %d（統領=%.2f）" % [
            team.team_id, best_successor.id, best_command
        ])
        team.leader_id = best_successor.id
        best_successor.role = "leader"
        # 新 leader 統領不足時，溢出人口強制分團
        var new_cap: int  = TeamData.pop_cap_from_leadership(best_command)
        var overflow: int = team.population - new_cap
        if overflow > 0:
            var spare_id: int = -1
            for aid in team.advisors:
                if aid != team.leader_id:
                    spare_id = aid
                    break
            if spare_id == -1:
                for mid in team.members:
                    if mid != team.leader_id:
                        spare_id = mid
                        break
            if spare_id != -1:
                var sub_id: int = SubteamSystem.new().dispatch(
                    state, team.team_id, spare_id, overflow, "idle", team.tile_pos)
                if sub_id != -1:
                    print("[Split] Leader 死亡，統領不足，溢出 %d 人分團 Team%d" % [overflow, sub_id])
            else:
                team.population = new_cap
                print("[Split] Leader 死亡，無 advisor，溢出 %d 人視為逃亡" % overflow)
        return true
    else:
        print("[Event] Team %d 無繼承人，崩潰中（統領不足）" % team.team_id)
        return false
```

替換為（**只改 else 分支**，if 分支不動）：

```gdscript
    if best_successor != null and best_command >= COMMAND_SKILL_MIN:
        print("[Event] Team %d 新領袖：Person %d（統領=%.2f）" % [
            team.team_id, best_successor.id, best_command
        ])
        team.leader_id = best_successor.id
        best_successor.role = "leader"
        # 新 leader 統領不足時，溢出人口強制分團
        var new_cap: int  = TeamData.pop_cap_from_leadership(best_command)
        var overflow: int = team.population - new_cap
        if overflow > 0:
            var spare_id: int = -1
            for aid in team.advisors:
                if aid != team.leader_id:
                    spare_id = aid
                    break
            if spare_id == -1:
                for mid in team.members:
                    if mid != team.leader_id:
                        spare_id = mid
                        break
            if spare_id != -1:
                var sub_id: int = SubteamSystem.new().dispatch(
                    state, team.team_id, spare_id, overflow, "idle", team.tile_pos)
                if sub_id != -1:
                    print("[Split] Leader 死亡，統領不足，溢出 %d 人分團 Team%d" % [overflow, sub_id])
            else:
                team.population = new_cap
                print("[Split] Leader 死亡，無 advisor，溢出 %d 人視為逃亡" % overflow)
        return true
    else:
        var gen    := PersonGenerator.new()
        var promoted := gen.generate(team, state)
        if promoted != null:
            team.leader_id  = promoted.id
            promoted.role   = "leader"
            print("[Event] Team%d 從匿名晉升新領袖 Person%d（統領=%.2f）" % [
                team.team_id, promoted.id, float(promoted.skills.get("統領", 0.0))])
            return true
        print("[Event] Team %d 無繼承人，崩潰中（無匿名人口）" % team.team_id)
        return false
```

- [ ] **Step 2: 重建快取確認無 parse error**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

預期：無 error，exit 0。

- [ ] **Step 3: Commit**

```powershell
git add scripts/simulation/event_system.gd
git commit -m "feat(event): PersonGenerator fallback in on_leader_death"
```

---

## Task C：headless_test.gd 驗證場景

**Files:**
- Modify: `scripts/debug/headless_test.gd`

驗證方法：在主 tick 迴圈**之前**手動呼叫 `on_leader_death`，確認 PersonGenerator 回傳非 null 且 leader_id 更新。

- [ ] **Step 1: 找插入位置**

在 headless_test.gd 中找到這一行：
```gdscript
print("=== Sim Test: 200 Ticks ===")
```

在該行**之前**插入以下 Team10 測試區塊：

```gdscript
	# ── PersonGenerator 驗證 ──
	var gen_team := TeamData.new()
	gen_team.team_id    = 10
	gen_team.population = 5     # anon_pop = 5-1(leader) = 4
	gen_team.tags       = ["軍隊"]
	gen_team.tile_pos   = Vector2i(0, -3)
	state.teams[10]     = gen_team
	state.team_known[10]      = []
	state.team_discovered[10] = []
	var p10_0 := PersonData.new()
	p10_0.id          = 30
	p10_0.person_name = "P10_leader"
	p10_0.role        = "leader"
	p10_0.team_id     = 10
	state.persons[30]   = p10_0
	gen_team.leader_id  = 30
	var _es_gen   := EventSystem.new()
	var _gen_ok   : bool = _es_gen.on_leader_death(state, gen_team)
	print("=== PersonGenerator 測試 ===")
	print("  gen_ok=%s  new_leader_id=%d" % [str(_gen_ok), gen_team.leader_id])
	if _gen_ok and gen_team.leader_id != 30:
		var _np: PersonData = state.persons.get(gen_team.leader_id)
		if _np:
			print("  [OK] 匿名晉升 Person%d 體力=%.2f 智力=%.2f 戰鬥=%.2f 統領=%.2f" % [
				_np.id,
				float(_np.attributes.get("體力", 0)),
				float(_np.attributes.get("智力", 0)),
				float(_np.skills.get("戰鬥", 0)),
				float(_np.skills.get("統領", 0))])
		else:
			print("  [FAIL] new_leader 不在 state.persons")
	else:
		print("  [FAIL] gen_ok=false or leader_id unchanged")
	state.persons.erase(30)   # 清理「假死」leader（模擬 _kill_named_npc 後段）
```

- [ ] **Step 2: 跑 headless**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期輸出（含以下片段）：
```
=== PersonGenerator 測試 ===
  gen_ok=true  new_leader_id=<id != 30>
  [OK] 匿名晉升 Person<id> 體力=<0.2~0.8+軍隊偏移> 智力=... 戰鬥=<有輕微偏移> 統領=...
=== DONE ===
```

- 軍隊 tag → 體力應比 0.5 略高（隨機有偏，不保證但統計上成立）
- 戰鬥 skill 應 >= 0.05（base 0.0–0.2 + 0.05 bias）
- 無 SCRIPT ERROR

- [ ] **Step 3: Commit**

```powershell
git add scripts/debug/headless_test.gd
git commit -m "test: add PersonGenerator headless validation (Team10)"
```

---

## Task D：docs/progress.md 更新

**Files:**
- Modify: `docs/progress.md`

- [ ] **Step 1: 在已完成項目清單加入 PersonGenerator**

找到 progress.md 中已完成的系統清單，加入：

```
- **PersonGenerator**：leader 死亡且無合格記名繼承人時，從匿名人口晉升新 leader（tag 屬性/技能偏移）
```

同時在「未來擴充」區塊確認以下項目仍存在（若已有則不重複加）：
```
- 超額人口強制離開（pop_cap enforcement）：pop 超過 pop_cap_from_leadership 時強制分團
- PersonGenerator 其他 call site：玩家招募、天賦事件
```

- [ ] **Step 2: Commit**

```powershell
git add docs/progress.md
git commit -m "docs(progress): add PersonGenerator to completed"
```

---

## 驗證 Checklist

```
[ ] headless 跑 200 Tick 無 SCRIPT ERROR
[ ] "=== DONE ===" 出現
[ ] PersonGenerator 測試輸出 [OK]（gen_ok=true，new_leader_id != 30）
[ ] 新 leader 在 state.persons 中（p.id 可查）
[ ] 軍隊 tag：戰鬥 skill >= 0.05
[ ] 原有所有輸出仍正常（[Trade], [SubAI], faction 等）
```
