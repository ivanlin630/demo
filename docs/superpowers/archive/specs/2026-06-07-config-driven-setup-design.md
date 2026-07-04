# Config-Driven 場景設定統一架構 — Design

> 日期：2026-06-07
> 議題：所有入口（主遊戲 / 測試 / playtest）的世界初始化參數散落於 GDScript hardcode，難以調整、複用、實驗

## 背景

目前 4 個入口各自硬編碼世界初始化：

| 入口 | 用 config? | 怎麼建世界 |
|---|---|---|
| `playtest_minimal.gd` | ✓ | `GameSetup.load_config("res://config/default.json") + GameSetup.setup(state, config)` |
| `main.gd` | ✗ | 手寫 3 teams + 9 persons + 資源 + 標籤 + 玩家初始化 |
| `game_sim_test.gd` | ✗ | 手寫 5 teams + 15 persons + 5 outposts + 玩家指令時程 |
| `headless_test.gd` | ✗ | 多場景手寫，每個 `_test_*` 函數各自建 team/person |

**問題：**
- 調食物/coin/pop 要改 code、recompile
- 多場景實驗（短長期、多寡兵、高低 leader 技能）要 fork code
- 參數不可重現（每次 run 都從 code 反推實際值）
- 玩家指令時程寫死，難以測新指令組合

**現有基礎：**
- `config/default.json` 已存在
- `GameSetup.load_config(path) -> Dictionary` 已實作
- `GameSetup.setup(state, config)` 已負責「世界生成 + outpost 規劃 + faction 建立 + team 填充」

## 目標

統一全部入口走 `GameSetup.load_config + GameSetup.setup` 模式。每個入口讀對應 JSON config，世界結構由 `GameSetup` 統一處理。

## 不在範圍

- UI 編輯 config 工具（未來可加）
- 即時熱重載（測試重啟才生效）
- 把 `cadence` / `NEAR_CADENCE` 等系統常數搬到 config（這些是程式碼層的設計值，非場景參數）

## 架構

### Config 檔結構

```
config/
  default.json          # 完整隨機世界 — playtest_minimal 用
  demo.json             # ✚ 簡單 demo 場景 — main.gd 改用
  game_sim_test.json    # ✚ 5 team 整合測試 — game_sim_test.gd 用
  stress_test.json      # ✚ 壓力測試（可選）
```

### Config Schema 擴充

當前 `default.json` 覆蓋：world 生成 + outpost + faction + team 範圍 + 玩家。

需要擴充以支援「明確指定 teams」（測試/demo 場景）：

```json
{
  "seed": 42,
  "map": { "radius": 4, "resource_richness": 5 },
  "mode": "explicit",     // ← 新增：explicit (明確指定) | random (現有，隨機生成)

  // explicit 模式：直接列 teams（取代 random faction 生成）
  "teams": [
    {
      "id": 0,
      "name": "玩家隊",
      "tile_pos": [4, 4],
      "population": 8,
      "tags": ["統領"],
      "faction_id": 0,
      "is_faction_leader": true,
      "resources": {
        "food": 96,    // 5 天 × 2.4 × 8
        "coin": 600,
        "weapon_melee_low": 5,
        "armor_low": 4,
        "medicine": 10
      },
      "leader": {
        "name": "玩家",
        "skills": { "統領": 0.7, "戰鬥": 0.4 },
        "values": { "義氣": 0.7, "信義": 0.7 }
      },
      "named_members": [
        { "name": "副官", "skills": { "戰鬥": 0.3 }, "loyalty": 0.7 }
      ],
      "outpost": { "type": "military", "level": 1, "tile_food_init": 2000 }
    }
    // ... 重複每個 team
  ],

  "player": {
    "team_id": 0,
    "is_leader": true
  },

  // 測試用：玩家指令注入時程（game_sim_test.gd 用，main.gd 可省略）
  "command_schedule": [
    { "tick": 240, "action": "set_move_target", "args": { "x": 5, "y": 4 } },
    { "tick": 720, "action": "propose_alliance", "args": { "team_id": 3 } },
    { "tick": 2400, "action": "attack", "args": { "team_id": 2 } }
  ],

  "max_ticks": 7200    // 測試用，main.gd 無上限
}
```

### `GameSetup.setup` 行為分支

```gdscript
static func setup(state: WorldState, config: Dictionary) -> void:
    var mode: String = config.get("mode", "random")
    var rng := RandomNumberGenerator.new()
    rng.seed = int(config.get("seed", 42))
    _generate_map(state, config, rng)
    if mode == "explicit":
        _setup_explicit_teams(state, config)
    else:  # random
        var plan := _plan_outposts(state, config, rng)
        _generate_factions(state, plan, config, rng)
        _generate_independents(state, plan, config, rng)
    _setup_player(state, config)
```

新增 `_setup_explicit_teams(state, config)` 處理明確列表模式。

### 入口改造

#### `main.gd`

```gdscript
func _ready() -> void:
    _runner = SimRunner.new()
    _state  = WorldState.new()
    var config := GameSetup.load_config("res://config/demo.json")
    GameSetup.setup(_state, config)
    # ... bridge / UI setup 不動
```

70 行 setup → 4 行。

#### `game_sim_test.gd`

```gdscript
func _run_game_sim_test() -> void:
    var state := WorldState.new()
    var config := GameSetup.load_config("res://config/game_sim_test.json")
    GameSetup.setup(state, config)
    var max_ticks: int = int(config.get("max_ticks", 7200))
    var schedule: Array = config.get("command_schedule", [])
    # 主迴圈用 max_ticks，指令注入 read schedule
```

500 行 setup → 載入 config + 跑 loop。指令時程從 JSON 讀。

#### `playtest_minimal.gd`

維持不變（已是這個模式）。

#### `headless_test.gd`

各 `_test_*` 函數仍可手寫 setup（單元測試需要精確控制），**不強制改**。但若要走 explicit config 模式也支援。

## Config 檔內容定義（本 spec 範圍交付）

### `config/demo.json`

簡單玩家展示：3 teams、玩家統領、撐 3 個月（玩家慢慢推進）。

### `config/game_sim_test.json`

複雜整合測試：5 teams、2 factions、含玩家指令時程、跑 1 月。

替換現有 game_sim_test.gd 內所有 hardcoded：
- teams 數量 / pop / pos / tags / faction
- 各 team 資源（包含 5 天份食物 = 12/人 × pop）
- 玩家指令時程（day 1 move、day 3 alliance、day 10 attack 等）
- max_ticks=7200

## 不變量

- `default.json` 維持 `mode=random`（向後相容，playtest_minimal 不動）
- `setup()` 若無 `mode` 欄位 → 走 random（預設）
- `explicit` 模式必須有 `teams` 陣列，否則 push_error
- `player.team_id` 必須對應 existing team

## 測試

`headless_test.gd` 新增測試：

1. **load_config 失敗**：路徑不存在 → 回 `{}`，無 crash
2. **explicit mode**：load `config/game_sim_test.json` → 跑 setup → 確認 `state.teams.size() == 5`，`state.player_id` 對應 leader
3. **demo mode**：load `config/demo.json` → 跑 setup → 確認玩家 team 建立
4. **random mode 不破**：`default.json` 跑 setup 結果與舊版相同（regression）
5. **command_schedule 解析**：載入 → 確認 schedule 陣列正確

## 風險

- **API 變更影響**：`GameSetup.setup` 新增 `mode` 分支，原 random 路徑必須維持完全行為（regression risk）
- **資料驅動隱性 bug**：JSON 打字錯誤難測 → schema 驗證或 push_error 提示
- **headless_test.gd 不強制改**：可能造成兩種 setup pattern 並存

## 後續延伸（不在本 spec）

- Config schema validation（缺欄位提示）
- UI 編輯器（直接在遊戲內調 config）
- 多 config 比較工具（同 seed 不同 config 結果對照）
- `game_sim_test.gd` 改為跑多個 config 連續測試
