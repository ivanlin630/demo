# 資料結構更新 Design

## Goal

為後續所有新系統（薪水、記憶、外交AI、遭遇戰、日夜循環等）補齊 PersonData、TeamData、WorldState 的欄位基礎。所有新系統 spec 均依賴本 spec 定義的欄位。

---

## PersonData 新增欄位

```gdscript
# scripts/data/person_data.gd

# 薪水
var salary: float = 0.0          # 每結算週期期望薪水；0 = 死士/主人記憶者
var coin: float = 0.0            # 個人存款（從薪水累積）

# 記憶與關係
var memory: Array = []           # Array[Dictionary] 記憶事件快照（原為 stub）
var relations: Dictionary = {}   # {person_id: float}  正=好感 負=敵意

# 個人目標
var goals: Array = []            # Array[Dictionary] 個人目標清單
```

### memory 事件記錄格式

```gdscript
{
    "type": String,       # 見下方事件類型清單
    "subject_id": int,    # 對象 person_id（-1 = 無特定對象）
    "tick": int,          # 發生 tick
    "intensity": float,   # 強度 0.0–1.0
}
```

事件類型：`"betrayal"` / `"kindness"` / `"master"` / `"witnessed_atrocity"` / `"looted"` / `"extorted"` / `"aided_in_battle"`

### goals 目標記錄格式

```gdscript
{
    "type": String,       # 目標類型（見下方）
    "target_id": int,     # 對象 person_id（-1 = 無特定對象）
    "active": bool,       # false = 初始禁用（等記憶觸發）
}
```

目標類型：
- 出生依 values 生成（active=true）：`"wealth"` / `"escape_war"` / `"domination"` / `"merit"` / `"peace"`
- 記憶觸發（active=false→true）：`"revenge"` / `"gratitude"` / `"protect"`

---

## TeamData 新增欄位

```gdscript
# scripts/data/team_data.gd

# 成員結構重構
# 移除: var advisors: Array = []
# 移除: var members: Array = []
var named_members: Array = []    # Array[int] 合併 advisors+members，所有具名NPC

# 薪水與經濟
var anon_wage: float = 1.0       # 每結算週期匿名成員固定薪水（TEST VALUE）

# 裝備配置
var armor_config: Dictionary = {
    "head":       "none",        # "none" / "low" / "high"
    "torso":      "low",
    "right_arm":  "none",
    "left_arm":   "none",
    "right_leg":  "none",
    "left_leg":   "none",
}

# 外交
var known_reputations: Dictionary = {}   # {team_id: float} 各 team 信譽認知（本 team 視角）

# 負重
# 注意：mounts 與 wagons 加入現有 resources Dictionary
# resources["mounts"] = 0    # 馱獸數量
# resources["wagons"] = 0    # 車輛數量
# resources["arrows"] = 0    # 箭矢數量
# resources["medicine"] = 0  # 藥品（統一不細分）
# resources["tools"] = 0     # 工具

# 疲勞
var fatigue: float = 0.0         # 0.0（完全休息）→ 1.0（極度疲勞）

# 戰略指派（FactionAI 包圍/突圍用）
var strategic_assignments: Dictionary = {}  # {team_id: Vector2i} 目標坐標

# 守夜
var guard_ratio: float = 0.2     # 紮營時守夜人數比例（TEST VALUE）
```

### resources 更新

現有 resources 保留原有 key，新增以下 key：

| Key | 類型 | 說明 |
|---|---|---|
| `"mounts"` | int | 馱獸（騎乘用/負重用）|
| `"wagons"` | int | 車輛（大量負重，平地加速/山地減速）|
| `"arrows"` | int | 箭矢（弓手消耗）|
| `"medicine"` | int | 藥品（治療+解毒，統一）|
| `"tools"` | int | 工具（採集加成/遭遇戰用）|
| `"armor_low"` | int | 低級護甲件數（按 armor_config 分配到部位）|
| `"armor_high"` | int | 高級護甲件數 |

---

## WorldState 新增欄位

```gdscript
# scripts/data/world_state.gd

# 玩家
var player_id: int = -1          # -1 = 無玩家（純模擬模式）
var player_state: Dictionary = {} # 玩家個人狀態（物品欄等，後續 spec 定義）

# 時間
var ticks_per_day: int = 24      # TEST VALUE：一天有幾個 tick
# time_of_day 為衍生值，不儲存，由 current_tick 計算：
# func get_time_of_day() -> float:
#     return float(current_tick % ticks_per_day) / float(ticks_per_day)
# 0.0–0.1 = 黎明  0.1–0.75 = 白天  0.75–0.9 = 黃昏  0.9–1.0 = 夜晚
```

---

## PersonData equipment 結構更新

```gdscript
# 原有
var equipment: Dictionary = { "weapon": "" }

# 更新為 8 格裝備欄，每格存 pool 或 unique item
var equipment: Dictionary = {
    "head":       { "type": "none", "grade": "" },
    "torso":      { "type": "none", "grade": "" },
    "right_arm":  { "type": "none", "grade": "" },
    "left_arm":   { "type": "none", "grade": "" },
    "right_leg":  { "type": "none", "grade": "" },
    "left_leg":   { "type": "none", "grade": "" },
    "right_hand": { "type": "none", "grade": "" },  # 主武器
    "left_hand":  { "type": "none", "grade": "" },  # 副武器/盾/火把
}
# type: "none" / "pool" / "unique"
# grade（pool）: "weapon_melee_low" / "weapon_melee_high" / "weapon_ranged_low" / "weapon_ranged_high" / "armor_low" / "armor_high"
# unique item 結構後續 spec 定義
```

死亡時：
- `type: "pool"` → 裝備歸還 `team.resources[grade]`
- `type: "unique"` → 掉落（後續 spec 定義拾取機制）

---

## 移植相容性注意

- `advisors` 與 `members` 欄位廢棄，全部改為 `named_members`
- 所有讀取 `team.advisors` / `team.members` 的程式碼需更新：
  - `faction_ai_system.gd`
  - `subteam_system.gd`
  - `population_system.gd`
  - `event_unrest_split.gd`（`_split_team` 函數）
  - `headless_test.gd`
- `equipment["weapon"]` 舊格式需遷移到 `equipment["right_hand"]`

---

## 驗證標準

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：
- 無 SCRIPT ERROR，`=== DONE ===`
- `team.named_members` 非空
- `team.resources` 包含 `"mounts"`, `"arrows"`, `"medicine"` 等新 key
- `person.salary`, `person.relations`, `person.goals` 存在且型別正確
- `state.ticks_per_day` = 24
