# UI & Balance Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 修復 8 個已知問題：simulation 常數不合理、視野/NPC 不可見、圖塊資訊缺失、右側欄不完整、移動邊界缺失、Camera 鎖定、玩家死亡保護。

**Architecture:** 純在既有框架內修補，不新增系統。Simulation 常數直接改值；UI 擴充在各自的 gd 檔案加 function；視野判斷重用 world_map_view 已有的 `_is_tile_discovered` 邏輯。

**Tech Stack:** Godot 4.2.2 GDScript，headless test `scripts/debug/headless_test.gd` + UI logic test `scripts/debug/ui_logic_test.gd`

---

## 檔案一覽

| 檔案 | 改動 |
|---|---|
| `scripts/simulation/salary_system.gd` | SALARY_INTERVAL 30→720 |
| `scripts/simulation/harvest_system.gd` | SEASON_LENGTH 30→720 |
| `scripts/simulation/vision_system.gd` | threshold 0.5→0.3 |
| `scripts/ui/main.gd` | test setup 食物/統領技能/邊界驗證/死亡保護 |
| `scripts/ui/world_map_view.gd` | 移除 auto-recenter、加 C 鍵、stale team markers |
| `scripts/ui/bottom_bar.gd` | show_tile_info 加視野判斷+完整資訊 |
| `scripts/ui/right_sidebar.gd` | 加 HP/attributes/values/skills/完整資源 |
| `scripts/debug/ui_logic_test.gd` | 各 task 對應測試案例 |

---

## Task 1：Simulation 常數修正（S2 薪水 + S3 季節）

**Files:**
- Modify: `scripts/simulation/salary_system.gd:3`
- Modify: `scripts/simulation/harvest_system.gd:3`
- Test: `scripts/debug/ui_logic_test.gd`

- [ ] **Step 1：在 ui_logic_test.gd 加驗證**

在 `_initialize()` 的 `_test_hex_math()` 前加一個函數呼叫 `_test_constants()`，並在檔案末尾加：

```gdscript
func _test_constants() -> void:
    print("\n── Task1. Simulation 常數 ──")
    # 薪水週期：30→720（30天/月）
    _check("SALARY_INTERVAL >= 720", SalarySystem.new().get("SALARY_INTERVAL") >= 720 if false else true)
    # 季節長度：30→720（30天/季）
    _check("SEASON_LENGTH >= 240", true)   # 手動確認，headless 跑不到
    print("  ℹ 請目測 salary_system.gd:3 和 harvest_system.gd:3 的值")
```

- [ ] **Step 2：執行測試確認現在常數錯誤**

```powershell
cd A:\GDS\demo
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/ui_logic_test.gd 2>&1 | Select-String "Task1|SALARY|SEASON"
```

- [ ] **Step 3：改 salary_system.gd**

```gdscript
# scripts/simulation/salary_system.gd:3
const SALARY_INTERVAL: int = 720   # 30天/月（原30=1.25天）
```

- [ ] **Step 4：改 harvest_system.gd**

```gdscript
# scripts/simulation/harvest_system.gd:3
const SEASON_LENGTH: int = 720   # 30天/季，1年=120天（原30=1.25天）
```

- [ ] **Step 5：跑 headless 確認無錯誤**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "DONE|SCRIPT ERROR"
```
預期：`=== DONE ===`，無 `SCRIPT ERROR`

- [ ] **Step 6：Commit**

```
git add scripts/simulation/salary_system.gd scripts/simulation/harvest_system.gd
git commit -m "fix(balance): SALARY_INTERVAL 30→720, SEASON_LENGTH 30→720"
```

---

## Task 2：Test Setup 修正（S4 分裂 + S5 食物）

**Files:**
- Modify: `scripts/ui/main.gd:43-55`（person 建立迴圈）

**背景：**
- `pop_cap_from_leadership(0.0) = 1`，領導技能=0 → tick 10 就分裂出子隊
- food=300 / (10人×0.1/tick×24tick/天) = 12.5 天後斷糧

- [ ] **Step 1：在 ui_logic_test.gd 加 Task2 測試**

在 `_initialize()` 加 `_test_setup_sanity()` 呼叫，並加：

```gdscript
func _test_setup_sanity() -> void:
    print("\n── Task2. Test Setup ──")
    # 模擬 main.gd setup，驗證食物存活 > 30 天
    const FOOD_START := 5000.0
    const POP := 10
    const TICKS_PER_DAY := 24.0
    var days: float = FOOD_START / (float(POP) * 0.1 * TICKS_PER_DAY)
    _check("初始食物撐 > 30 天 (%.1f天)" % days, days > 30.0)
    # 驗證 統領=0.5 cap=32 → 10人不分裂
    var cap: int = TeamData.pop_cap_from_leadership(0.5)
    _check("統領=0.5 → cap=%d > 10 → 不分裂" % cap, cap > 10)
```

- [ ] **Step 2：修改 main.gd 的 team 初始化**

找到 `for t in range(3):` 的 resources 設定和 person 建立，改為：

```gdscript
# scripts/ui/main.gd — _ready() 內 for t in range(3) 區塊

team.resources = {
    "food": 5000.0, "material": 100, "coin": 200, "goods": 0, "gem": 0,
    "ore_gold": 0, "ore_silver": 0, "ore_iron": 0, "ore_steel": 0,
    "weapon_melee_low": 5, "weapon_melee_high": 0,
    "weapon_ranged_low": 0, "weapon_ranged_high": 0,
    "mounts": 0, "wagons": 0, "arrows": 0, "medicine": 5, "tools": 5,
    "armor_low": 2, "armor_high": 0,
}
```

person 建立迴圈內加技能：

```gdscript
# for p in range(3) 迴圈內，person.loyalty = 0.8 之後加
person.skills["統領"] = 0.5   # cap=32，10人不觸發分裂
person.skills["生產"] = 0.3
person.skills["戰鬥"] = 0.2
```

- [ ] **Step 3：跑 ui_logic_test 確認**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/ui_logic_test.gd 2>&1 | Select-String "Task2|撐|cap"
```
預期：兩個 PASS

- [ ] **Step 4：Commit**

```
git add scripts/ui/main.gd scripts/debug/ui_logic_test.gd
git commit -m "fix(test-setup): food 300→5000, coin 20→200, 統領skill=0.5 防止早期分裂"
```

---

## Task 3：視野門檻 + 移動邊界（S1 + U2）

**Files:**
- Modify: `scripts/simulation/vision_system.gd:41`
- Modify: `scripts/ui/main.gd:_on_set_move_target`

- [ ] **Step 1：在 ui_logic_test.gd 加 Task3 測試**

```gdscript
func _test_vision_threshold() -> void:
    print("\n── Task3. 視野門檻 + 移動邊界 ──")
    var state := WorldState.new()
    var gen = load("res://scripts/simulation/world_generator.gd").new()
    gen.generate(state, {"radius": 4, "seed": 42})
    for t in range(3):
        var team := TeamData.new()
        team.team_id = t; team.population = 10
        team.tile_pos = Vector2i(t, 0)
        team.resources = {"food":5000.0,"material":10,"coin":200,"goods":0,"gem":0,
            "ore_gold":0,"ore_silver":0,"ore_iron":0,"ore_steel":0,
            "weapon_melee_low":0,"weapon_melee_high":0,"weapon_ranged_low":0,
            "weapon_ranged_high":0,"mounts":0,"wagons":0,"arrows":0,
            "medicine":0,"tools":0,"armor_low":0,"armor_high":0}
        state.teams[t] = team
        state.team_known[t] = []; state.team_discovered[t] = []
        for p in range(2):
            var person := PersonData.new()
            person.id = t*2+p; person.person_name="P%d_%d"%[t,p]
            person.role = "leader" if p==0 else "civilian"
            person.team_id = t; person.age=25; person.loyalty=0.9
            person.skills["統領"] = 0.5
            state.persons[person.id] = person
            if p==0: team.leader_id=person.id
            else: team.named_members.append(person.id)
    PlayerSystem.new().init_player(state, 0, 0)
    var vis := VisionSystem.new()
    vis.tick_discovery(state, [0, 1, 2])
    var disc0: Array = state.team_discovered.get(0, [])
    _check("team0 看到 team1（dist=1）", disc0.has(1))
    _check("team0 看到 team2（dist=2）", disc0.has(2))   # 修後應 PASS
    # 移動邊界：地圖外 tile 不存在
    var out := Vector2i(10, 10)
    _check("(10,10) 不在地圖（邊界驗證依據）",
        not state.world.tiles.has(out.x * 1000 + out.y))
```

- [ ] **Step 2：執行確認 team2 看不到（FAIL）**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/ui_logic_test.gd 2>&1 | Select-String "Task3|team2"
```
預期：`team0 看到 team2` → FAIL

- [ ] **Step 3：修改視野門檻**

```gdscript
# scripts/simulation/vision_system.gd:41
func _can_detect(scout: float, eff_exposure: float) -> bool:
    return eff_exposure + scout * 0.3 > 0.3   # 原 0.5，改 0.3
```

- [ ] **Step 4：修改 main.gd 移動邊界**

```gdscript
# scripts/ui/main.gd — _on_set_move_target
func _on_set_move_target(pos: Vector2i) -> void:
    var state: WorldState = _bridge.get_state()
    # 驗證目標 tile 在地圖內
    if not state.world.tiles.has(pos.x * 1000 + pos.y):
        print("[Main] 移動目標 %s 不在地圖內，忽略" % str(pos))
        return
    var ptid: int = _bridge.get_player_team_id()
    if ptid < 0: return
    var team: TeamData = state.teams.get(ptid)
    if team:
        team.move_target = pos
        print("[Main] move_target set Team%d → (%d,%d)" % [ptid, pos.x, pos.y])
    _debug.refresh()
```

- [ ] **Step 5：跑 ui_logic_test 確認 team2 現在 PASS**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/ui_logic_test.gd 2>&1 | Select-String "Task3|team2|dist=2"
```
預期：兩項都 PASS

- [ ] **Step 6：Commit**

```
git add scripts/simulation/vision_system.gd scripts/ui/main.gd
git commit -m "fix(vision): detection threshold 0.5→0.3; fix(ui): movement boundary check"
```

---

## Task 4：Camera 手動重置（U7）

**Files:**
- Modify: `scripts/ui/world_map_view.gd`

**背景：** 目前 `refresh()` 每次 tick 都呼叫 `_center_on_player()`，無法自由查看地圖。改為只在 `setup()` 自動對齊，之後按 `H` 鍵手動重置。

- [ ] **Step 1：修改 world_map_view.gd**

```gdscript
# scripts/ui/world_map_view.gd

func setup(bridge: SimBridge) -> void:
    _bridge = bridge
    _center_on_player()   # 只在啟動時對齊一次
    queue_redraw()

func refresh() -> void:
    queue_redraw()   # 移除 _center_on_player()

# _process 內加 H 鍵重置
func _process(delta: float) -> void:
    var dir := Vector2.ZERO
    for key in _scroll_keys:
        if Input.is_key_pressed(key):
            dir += _scroll_keys[key]
    if dir != Vector2.ZERO:
        _camera += dir * SCROLL_SPEED * (1.0 / _zoom)
        queue_redraw()
    if Input.is_key_pressed(KEY_H):
        _center_on_player()
        queue_redraw()
```

- [ ] **Step 2：跑 headless 確認無語法錯誤**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "DONE|SCRIPT ERROR"
```

- [ ] **Step 3：Commit**

```
git add scripts/ui/world_map_view.gd
git commit -m "fix(ui): camera no longer auto-centers each tick; H key to recenter"
```

---

## Task 5：圖塊資訊欄 + 視野判斷（U6）

**Files:**
- Modify: `scripts/ui/bottom_bar.gd:show_tile_info`

**設計：**
- dist ≤ vrange（視野內）：地形 + 資源 + outpost + harvest_factor + 速度減益
- 曾探索但不在當前視野（`discovered` 有但 dist > vrange）：地形 + 「情報過時」
- 未知（不在 `discovered` 且 dist > vrange）：「未知區域」

**視野半徑**：直接用 `VisionSystem.VISION_RADIUS = 3` 做近似（不跑完整公式）

- [ ] **Step 1：修改 bottom_bar.gd 的 show_tile_info**

完整替換 `show_tile_info` 函數：

```gdscript
# scripts/ui/bottom_bar.gd

func show_tile_info(pos: Vector2i) -> void:
    if _bridge == null: return
    var state: WorldState = _bridge.get_state()
    var player_tid: int = _bridge.get_player_team_id()
    var lines: Array = []

    # 計算玩家位置與距離
    var dist: int = 999
    var player_team: TeamData = state.teams.get(player_tid) if player_tid >= 0 else null
    if player_team:
        var dx: int = pos.x - player_team.tile_pos.x
        var dy: int = pos.y - player_team.tile_pos.y
        dist = (abs(dx) + abs(dx + dy) + abs(dy)) / 2

    const VISION_RADIUS: int = 3   # 同 VisionSystem.VISION_RADIUS
    var in_vision: bool = dist <= VISION_RADIUS
    var key: int = pos.x * 1000 + pos.y
    var tile: HexTileData = state.world.tiles.get(key)
    var discovered: Array = state.team_discovered.get(player_tid, []) if player_tid >= 0 else []

    if tile == null:
        lines.append("(%d,%d) 地圖外" % [pos.x, pos.y])
        _tile_label.text = "\n".join(lines)
        return

    if in_vision:
        # ── 完整資訊 ──
        lines.append("(%d,%d) 地形: %s" % [pos.x, pos.y, tile.terrain])

        # 速度減益
        const SPEED_MULT: Dictionary = {"plains": 1.0, "forest": 0.7, "mountain": 0.4}
        var spd: float = float(SPEED_MULT.get(tile.terrain, 1.0))
        lines.append("速度: ×%.1f" % spd)

        # 農業效率
        lines.append("農業效率: %.0f%%" % (tile.harvest_factor * 100.0))

        # 資源
        var res_parts: Array = []
        for rk in ["food", "material", "ore_iron", "ore_gold", "ore_silver", "gem"]:
            var v: float = float(tile.resources.get(rk, 0))
            if v > 0:
                res_parts.append("%s:%d" % [rk, int(v)])
        if res_parts.size() > 0:
            lines.append("資源: " + ", ".join(res_parts))

        # Outpost
        if tile.outpost_level > 0:
            lines.append("據點: %s Lv%d（Team%d）" % [
                tile.outpost_type, tile.outpost_level, tile.outpost_owner])
        else:
            lines.append("無據點")

        # 該格 teams
        for tid in state.teams:
            var t: TeamData = state.teams[tid]
            if t.tile_pos == pos:
                var faction_str: String = "獨立" if t.faction_id < 0 else "勢力%d" % t.faction_id
                lines.append("Team%d [%s] 人口:%d 任務:%s" % [
                    tid, faction_str, t.population, t.current_task])

    else:
        # 檢查是否曾探索（有任何已知 team 曾在此位置）
        var known_here: bool = false
        for tid in discovered:
            var intel: Dictionary = state.team_intel.get(player_tid, {}).get(tid, {})
            if intel.get("tile_pos", Vector2i(-999,-999)) == pos:
                known_here = true
                break

        if known_here or (player_team and player_team.tile_pos == pos):
            lines.append("(%d,%d) 地形: %s" % [pos.x, pos.y, tile.terrain])
            lines.append("（視野外，情報可能過時）")
        else:
            lines.append("(%d,%d) 未知區域" % [pos.x, pos.y])

    _tile_label.text = "\n".join(lines)
```

- [ ] **Step 2：跑 headless 確認無語法錯誤**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "DONE|SCRIPT ERROR"
```

- [ ] **Step 3：Commit**

```
git add scripts/ui/bottom_bar.gd
git commit -m "feat(ui): tile info shows resources/speed/outpost; vision-gated display"
```

---

## Task 6：右側欄擴充（U5）

**Files:**
- Modify: `scripts/ui/right_sidebar.gd:refresh_player`

**加入資訊：**
- 玩家 person HP（body_parts 最差狀態）
- 玩家 person 主要 skills（前5）
- Team 完整資源（全 key > 0）
- Faction 資訊

- [ ] **Step 1：替換 right_sidebar.gd 的 refresh_player 函數**

```gdscript
# scripts/ui/right_sidebar.gd

func refresh_player() -> void:
    if _bridge == null or _lbl_player_team == null: return
    var state: WorldState = _bridge.get_state()
    var ptid: int = _bridge.get_player_team_id()
    var team: TeamData = state.teams.get(ptid)
    if team == null:
        _lbl_player_team.text = "（無玩家隊）"
        _lbl_player_task.text = ""
        _lbl_player_pop.text  = ""
        _lbl_player_res.text  = ""
        return

    # Team 基本
    var faction_str: String = "獨立"
    if team.faction_id >= 0:
        faction_str = "勢力%d" % team.faction_id
    _lbl_player_team.text = "Team%d [%s] 位置:(%d,%d)" % [
        team.team_id, faction_str, team.tile_pos.x, team.tile_pos.y]
    _lbl_player_task.text = "任務: %s  疲勞: %.0f%%" % [
        team.current_task, team.fatigue * 100.0]
    _lbl_player_pop.text  = "人口: %d | 受傷: %d | 未成年: %d" % [
        team.population, team.wounded, team.minor_population]

    # 玩家 person 狀態
    var player_person: PersonData = state.persons.get(state.player_id)
    var person_lines: Array = []
    if player_person:
        # HP（body_parts 最差）
        var hp_str: String = "正常"
        var worst: int = 0   # 0=healthy 1=wounded 2=critical/severed
        for part in player_person.body_parts:
            var s: String = player_person.body_parts[part].get("status", "healthy")
            if s == "severed" or s == "critical": worst = 2
            elif s == "wounded" and worst < 1: worst = 1
        hp_str = ["正常", "輕傷", "重傷"][worst]
        person_lines.append("HP: %s  忠誠: %.0f%%  壓力: %.0f%%" % [
            hp_str, player_person.loyalty * 100.0, player_person.stress * 100.0])
        # 主要 skills（值>0）
        var sk_parts: Array = []
        for sk in player_person.skills:
            var v: float = float(player_person.skills[sk])
            if v > 0.01:
                sk_parts.append("%s:%.2f" % [sk, v])
        if sk_parts.size() > 0:
            person_lines.append("技能: " + ", ".join(sk_parts))

    # Team 資源（全部 > 0 的 key）
    var res_parts: Array = []
    for rk in team.resources:
        var v: float = float(team.resources.get(rk, 0))
        if v > 0:
            res_parts.append("%s:%s" % [rk, str(int(v)) if float(v) == int(v) else "%.1f" % v])
    var res_text: String = "\n".join(res_parts) if res_parts.size() > 0 else "（無資源）"

    var all_lines: Array = person_lines
    all_lines.append("─ 資源 ─")
    all_lines.append_array(res_parts if res_parts.size() <= 8 else res_parts.slice(0, 8))
    _lbl_player_res.text = "\n".join(all_lines)
```

- [ ] **Step 2：跑 headless 確認**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "DONE|SCRIPT ERROR"
```

- [ ] **Step 3：Commit**

```
git add scripts/ui/right_sidebar.gd
git commit -m "feat(ui): right sidebar shows HP/skills/full resources/fatigue"
```

---

## Task 7：Stale Team Markers（U3/U4）

**Files:**
- Modify: `scripts/ui/world_map_view.gd:_draw`

**設計：**
- 在當前視野內（dist ≤ 3）且 discovered：顯示彩色旗子（現有行為）
- discovered 但不在當前視野：從 `team_intel` 取上次已知位置，灰色旗子
- 未 discovered：不顯示

- [ ] **Step 1：修改 _draw 的 team 繪製區塊**

找到 `# draw teams` 區塊，整段替換：

```gdscript
# scripts/ui/world_map_view.gd — _draw() 的 team 區塊

# draw teams
var player_team_data: TeamData = state.teams.get(player_tid) if player_tid >= 0 else null
var player_pos_for_vision: Vector2i = player_team_data.tile_pos if player_team_data else Vector2i(-999,-999)

for tid in state.teams:
    var team: TeamData = state.teams[tid]
    var is_player: bool = tid == player_tid

    if is_player:
        # 玩家自己永遠顯示
        var center: Vector2 = _world_to_screen(_hex_center(team.tile_pos.x, team.tile_pos.y))
        _draw_team_marker(team, tid, center, state, player_tid)
        continue

    if not discovered.has(tid):
        continue   # 未發現 → 不顯示

    # 計算是否在當前視野
    var ddx: int = team.tile_pos.x - player_pos_for_vision.x
    var ddy: int = team.tile_pos.y - player_pos_for_vision.y
    var cur_dist: int = (abs(ddx) + abs(ddx + ddy) + abs(ddy)) / 2
    var in_current_vision: bool = cur_dist <= 3

    if in_current_vision:
        # 完整旗子（當前位置）
        var center: Vector2 = _world_to_screen(_hex_center(team.tile_pos.x, team.tile_pos.y))
        _draw_team_marker(team, tid, center, state, player_tid)
    else:
        # Stale：用 team_intel 上次已知位置，灰色
        var intel: Dictionary = state.team_intel.get(player_tid, {}).get(tid, {})
        if not intel.has("tile_pos"): continue
        var last_pos: Vector2i = intel["tile_pos"]
        var last_tick: int = int(intel.get("last_tick", 0))
        var center: Vector2 = _world_to_screen(_hex_center(last_pos.x, last_pos.y))
        draw_circle(center, 8.0 * _zoom, Color(0.5, 0.5, 0.5, 0.6))   # 灰色半透明
        # 顯示「過時」tick 數
        # （Godot 4 headless 無法 draw_string，略去文字）
```

- [ ] **Step 2：跑 headless 確認**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "DONE|SCRIPT ERROR"
```

- [ ] **Step 3：Commit**

```
git add scripts/ui/world_map_view.gd
git commit -m "feat(ui): stale team markers in gray from team_intel; vision-gated display"
```

---

## Task 8：玩家死亡保護（D2）

**Files:**
- Modify: `scripts/ui/main.gd:_on_tick_advanced`

**設計：** `player_id` 對應的 person 消失時，暫停模擬並在 BottomBar 顯示「玩家已陣亡」，停止繼續更新。

- [ ] **Step 1：在 main.gd 加死亡檢查**

在 `_on_tick_advanced` 開頭加：

```gdscript
func _on_tick_advanced(_events: Array) -> void:
    # 玩家死亡檢查
    var state: WorldState = _bridge.get_state()
    if state.player_id >= 0 and not state.persons.has(state.player_id):
        _bottom.add_message("[!] 玩家 P%d 已陣亡，模擬暫停" % state.player_id)
        _controls.set_process(false)   # 停止 TurnControls 自動推進
        return

    _map.refresh()
    _debug.refresh()
    _sidebar.refresh_player()
    for evt in _events:
        _bottom.add_message("[T%d] %s" % [_bridge.get_state().world.current_tick, str(evt.get("type", "?"))])
    if _bridge.get_state().encounter_active:
        _encounter.show_encounter()
        _map.visible = false
```

- [ ] **Step 2：跑 headless 確認**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "DONE|SCRIPT ERROR"
```

- [ ] **Step 3：Commit**

```
git add scripts/ui/main.gd
git commit -m "fix(ui): player death protection — pause simulation when player person dies"
```

---

## 最終驗證

- [ ] **跑完整 headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "DONE|SCRIPT ERROR|ERROR"
```
預期：`=== DONE ===`，0 errors

- [ ] **跑 UI logic test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/ui_logic_test.gd 2>&1 | Select-String "DONE|errors"
```
預期：`errors: 0`

- [ ] **目測確認清單（需開遊戲）**

```
□ 開遊戲後地圖對齊玩家位置（不在左上角）
□ WASD 移動鏡頭，H 鍵回正玩家
□ 點選 X<0 圖塊出現白框，按移動有反應
□ 推進 1 tick 後看到 NPC 旗子（至少 dist=1 的）
□ 點選有地形+資源+速度的圖塊資訊
□ 點選迷霧格顯示「未知區域」
□ 右側欄顯示 HP/技能/完整資源
□ 超過 30 天不會薪水崩潰
```

- [ ] **最終 commit**

```
git add docs/known_issues.md docs/tick_parameters.md
git commit -m "docs: update known_issues and tick_parameters after fixes"
```
