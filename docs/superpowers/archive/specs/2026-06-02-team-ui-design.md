# 設計規格：玩家 Team 屬性 UI (選項 C)

**日期**：2026-06-02  
**目標**：Debug 玩家成員脫隊原因，實現快速掌握 + 逐人檢查的平衡 UI

---

## 1. 需求背景

### 問題陳述

- 玩家 team 成員忠誠度快速下降，成員脫隊原因不明
- 目前 member_mode 只顯示一行快速卡片（裝備 + HP），無法看到壓力、個性、忠誠、屬性詳情
- 需要詳細 UI 顯示：屬性、技能、健康、裝備、個性值、忠誠/壓力/恐懼指標

### 目標

- 一個 member_mode 面板，支援快速瀏覽全部成員 + 逐人深鑽詳情
- 呈現脫隊風險警示（loyalty < 0.7 或 stress > 0.5 的成員計數）
- 不破壞現有 game loop 和 UI 互動流程
- headless test 通過（1000+ Tick 無崩潰）

---

## 2. 設計方案：簡化快卡 + 暫存聚合（C 方案）

### 2.1 模式概述

新 **member_mode** 是一個完整面板，分三欄：

```
【成員列表】(L/HP/壓力)    【選中者詳情】          【聚合統計】
 ◎ 27(隊長)  L:0.95 ...    名字/屬性/忠誠/壓力...  人口/平均忠誠/脫隊數...
►◎ 28(成員)  L:0.87 ...    [↑/↓] 上下選擇
 ◎ 29(成員)  L:0.99 ...    [D] 詳細健康檢視
 ...                        [E] 裝備檢視
                            [T] 切換聚合統計
                            [M] 返回主 UI
```

### 2.2 三欄設計詳解

#### 左欄：成員列表

**內容**：
- 所有 named members（leader + `named_members[]`）
- 每行格式：`[角色] [名字] L:[忠誠] HP:[%] S:[壓力]`
- `►` 標記當前選中，`✗` 標記脫隊風險（loyalty < 0.7）

**範例**：
```
◎ 27(隊長)  L:0.95 HP:95% S:0.10
►◎ 28(成員)  L:0.87 HP:88% S:0.25
◎ 29(成員)  L:0.99 HP:92% S:0.08
✗ 30(成員)  L:0.69 HP:60% S:0.62
```

#### 中欄：選中者快速卡片

**核心資訊**：
```
名字: [person_name]
角色: [role] / 隊伍: T[team_id]
忠誠: [loyalty] (↑/↓趨勢指示)
壓力: [stress]
恐懼: [fear]

屬性值 (0.0–1.0):
├ 體力: [physique]
├ 智力: [intellect]
├ 魅力: [charisma]
└ 毅力: [willpower]

個性值 (0.0–1.0):
├ 野心: [ambition]
├ 求生欲: [survival]
├ 義氣: [loyalty_value]
├ 貪婪: [greed]
├ 慎重: [caution]
├ 好戰: [martial]
├ 殘忍: [cruelty]
└ 信義: [honor]

當前技能 (最高 3 項):
├ [top_skill_1]: [value]
├ [top_skill_2]: [value]
└ [top_skill_3]: [value]

健康狀態: [overall_status]
[D] 查詳細部位
[E] 檢視裝備
[M] 返回主 UI
```

**動態內容**：
- loyalty 指示：顯示 ↑(> 0.75) / → (0.4–0.75) / ↓(< 0.4)
- stress/fear 警示：顯示 ⚠ 當 > 0.5

#### 右欄：聚合統計 + 環境情報

**聚合統計** (預設，§2.2 更新)：
```
─ 團隊聚合統計 ─

人口: [population] (含 [named_count] 命名)
無名武裝: [armed_count] / [unarmed_count]

忠誠統計:
├ 平均: [avg_loyalty]
├ 最低: [min_loyalty] (誰)
└ 風險計數: [count < 0.7] ⚠

壓力統計:
├ 平均: [avg_stress]
├ 最高: [max_stress] (誰)
└ 高壓計數: [count > 0.5] ⚠

健康統計:
├ 平均 HP: [avg_hp%]
├ 重傷計數: [count < 25%]
└ 死傷計數: [count == 0]

裝備統計:
├ 刀: [count]
├ 盾: [count]
└ ...

資源狀態:
├ 超載: [weight]/[capacity]kg (狀態: 正常/超載 ⚠)
├ 食物: [qty] (消耗: [per_day]/day, 可用: [days_left] 天)
└ 藥: [qty]

─ 按 [T] 切換其他檢視 ─
```

**環境情報** ([T] 切換)：
```
─ 環境情報 ─

當前位置: ([x], [y]) 地形:[terrain]
移動成本: [move_ticks] ticks/hex

【未來擴展】
此欄留作未來功能（視野系統、已發現勢力等）。
目前功能暫時保留空間，只顯示位置和移動成本。

按 [T] 返回聚合統計
```

### 2.3 互動流程

**進入 member_mode**：
- 按 [M]（從正常模式）
- 初始化 `_member_selection = 0`（第一個 named member）
- 快取目前 team 的所有成員資訊

**在 member_mode 中**：
1. `[↑]` / `[↓]`：移動 `_member_selection`（0 至 named_count-1）
   - 中欄即時更新為選中者詳情
2. `[D]`：展開選中者的**健康詳細檢視**
   ```
   ─ 健康詳情：Person 28 ─
   
   部位           HP        狀態       出血  骨折
   ─────────────────────────────────────────
   頭部          20/20     健康       無    否
   軀幹          40/50     受傷       無    否
   右臂          20/25     受傷       輕度  否
   左臂          20/25     受傷       無    是 ⚠
   右腿          25/30     健康       無    否
   左腿          20/30     受傷       無    否
   ─────────────────────────────────────────
   總體 HP: 165/200 (82%)
   
   [S] 自動休養建議  [M] 返回
   ```
3. `[E]`：展開選中者的**裝備檢視**
   ```
   ─ 裝備：Person 28 ─
   
   已穿戴:
   ├ 手 1: 刀 (好狀態, 攻+2)
   ├ 手 2: 盾 (磨損)
   └ 軀幹: 皮甲 (好狀態)
   
   背包 (4/8 格):
   ├ 食物: 2
   ├ 藥: 1
   ├ 工具: 1
   └ 空閒: 4 格
   
   [M] 返回
   ```
4. `[T]`：切換右欄**聚合統計** ↔ **環境情報**
5. `[M]`：返回正常模式

### 2.4 資料需求

**來源**：
- `_state.teams[_player_tid]` — team 層級
- `_state.persons[person_id]` — 逐人屬性
- `_state.player_state` — 玩家庫存

**需要從 SimBridge.query_player() 新增欄位**：
- `members[].stress` — 人物壓力
- `members[].fear` — 人物恐懼  
- `members[].loyalty` — 人物忠誠
- `members[].attributes` — 屬性字典 {體力, 智力, 魅力, 毅力}
- `members[].values` — 個性值字典 {野心, 求生欲, ...}
- `members[].body_parts` — 健康部位詳情
- `members[].equipped` — 穿戴裝備
- `members[].inventory` — 背包物品
- `team.avg_loyalty`, `team.avg_stress`, `team.risk_count` — 聚合統計（或現場計算）

---

## 3. 技術架構

### 3.1 修改檔案

#### `scripts/ui/text_ui_main.gd`

**新欄位**：
```gdscript
var _member_mode: bool = false           # 新
var _member_selection: int = 0           # 新：選中 member 索引
var _member_detail_submode: String = ""  # 新："" = 快卡, "health" = 健康詳情, "equip" = 裝備
var _member_snapshot: Dictionary = {}    # 新：快取最後一次 query_player() 結果（進入 member_mode 時初始化）
var _member_team_members: Array = []     # 新：快取 snapshot 中的 members[] (person_id list)
```

**快取策略**：
- 進入 member_mode 時（按 [M]）：呼叫 `_bridge.query_player({})` 並快取至 `_member_snapshot`
- 在 member_mode 期間：使用快取資料，不重複查詢（以保持 UI 穩定）
- 返回主模式時（按 [M]）：清除快取
- **邊界條件**：若成員在 member_mode 期間被殺死或脫隊，下一次 advance 後返回主模式（member_mode 自動禁用）

**關鍵函式**（新增或改寫）：
1. `_build_member_str() -> String`
   - 改寫成 3 欄佈局函式
   - 分別呼叫 `_build_member_left_col()`, `_build_member_center()`, `_build_member_right_col()`

2. `_build_member_left_col() -> String`
   - 成員列表（忠誠/HP/壓力 一行一人）

3. `_build_member_center() -> String`
   - 選中者快速卡片（屬性/個性/技能）
   - 或者詳細健康/裝備（根據 `_member_detail_submode`）

4. `_build_member_right_col() -> String`
   - 聚合統計或環境情報（根據按鍵選擇）

5. `_handle_member_mode_input(action: String) -> void`
   - ↑/↓：`_member_selection += 1/-1`
   - D/E/T/M：切換 submode 或返回

**主迴圈改動**：
```gdscript
if _member_mode:
    _event_label.text = _build_member_str()
    _handle_member_mode_input(...)
    # 不執行其他 mode 的邏輯
```

#### `scripts/ui/sim_bridge.gd`

**query_player() 回傳值擴充**：

_bridge 呼叫的是 SimBridge 中 `query_player()` 函式，該函式內呼叫 `_runner.get_player_snapshot()`（位於 SimRunner）。需要 SimRunner 擴充其回傳欄位。

**SimRunner.get_player_snapshot() 新增回傳結構**：
```gdscript
{
    "controlled_team": {
        ...既有欄位（name, population, resources, position, ...）...
        
        # 新增 members 詳細陣列
        "members": [
            {
                "id": person_id,
                "name": person_name,
                "role": role,                    # "leader" / "member"
                "loyalty": loyalty,              # 0.0–1.0
                "stress": stress,                # 0.0–1.0
                "fear": fear,                    # 0.0–1.0
                "attributes": {                  # from PersonData.attributes
                    "體力": float,
                    "智力": float,
                    "魅力": float,
                    "毅力": float
                },
                "values": {                      # from PersonData.values
                    "野心": float,
                    "求生欲": float,
                    "義氣": float,
                    "貪婪": float,
                    "慎重": float,
                    "好戰": float,
                    "殘忍": float,
                    "信義": float
                },
                "skills": {                      # top 3 skills (sorted by value DESC)
                    "skill_name_1": value,
                    "skill_name_2": value,
                    "skill_name_3": value
                },
                "body_parts": {                  # from PersonData.body_parts (detail mode)
                    "head": { "hp": float, "max_hp": float, "status": string, "bleeding": string, "fracture": bool },
                    ...other parts...
                },
                "equipped": {                    # equipped items
                    "hand_1": item_grade,        # 例："weapon_melee_low"
                    "hand_2": item_grade,
                    "torso": item_grade
                },
                "inventory": [                   # 背包物品陣列
                    { "grade": item_grade, "qty": int },
                    ...
                ]
            },
            ...
        ],
        
        # 新增聚合統計
        "team_stats": {
            "avg_loyalty": float,
            "min_loyalty": float,
            "risk_count_loyalty": int,           # count with loyalty < 0.7
            "avg_stress": float,
            "max_stress": float,
            "risk_count_stress": int,            # count with stress > 0.5
            "avg_fear": float,
            "avg_hp": float,
            "wounded_count": int,                # count with HP < 75%
            "critical_count": int,               # count with HP < 25%
            "total_weight": float,
            "carry_capacity": float,
            "food_qty": float,
            "food_consumption_per_day": float    # team.population * FOOD_PER_PERSON_PER_DAY
        }
    }
}
```

**技能選擇邏輯**：
- 取 person.skills{} 中 value 最高的前 3 個技能（按字典鍵排序作為穩定二級排序）

### 3.3 聚合統計計算邏輯

**食物消耗速率與可用天數**：
```gdscript
var consumption_per_day = team.population * FOOD_PER_PERSON_PER_DAY  # 約 2.4
var days_left = food_qty / consumption_per_day if consumption_per_day > 0 else 9999
```

**脫隊風險計數**：
- `risk_count_loyalty`: `members` 中 loyalty < 0.7 的人數
- `risk_count_stress`: `members` 中 stress > 0.5 的人數

### 3.4 邊界條件處理

**進入 member_mode 時**：
- 若 team 人口 ≤ 0 或無任何 named members，提示「無成員」並禁止進入
- 若玩家已死或脫隊，成員列表自動移除，若列表為空則返回主 UI

**在 member_mode 中選擇成員**：
- 若選中的成員被殺死或脫隊，自動移動選擇到下一個存活成員
- 若無任何成員存活，member_mode 自動返回主 UI

**返回主模式時**：
- 清除 `_member_snapshot` 快取
- 重置 `_member_selection = 0`
- 重置 `_member_detail_submode = ""`

### 3.2 測試標準

**單元測試**（在 headless_test.gd 中）：
```gdscript
# 直接設定進入 member_mode (UI 層直接設定，無需 command_player)
_text_ui_main._member_mode = true
_text_ui_main.refresh()

# 查看快照
var snap = _bridge.query_player({})
assert snap["controlled_team"]["members"].size() > 0, "成員列表應不為空"
assert "loyalty" in snap["controlled_team"]["members"][0], "成員應包含 loyalty"
assert "stress" in snap["controlled_team"]["members"][0], "成員應包含 stress"
assert "body_parts" in snap["controlled_team"]["members"][0], "成員應包含 body_parts"

# 檢查聚合統計
assert "team_stats" in snap["controlled_team"], "應包含聚合統計"
assert snap["controlled_team"]["team_stats"]["risk_count_loyalty"] >= 0, "脫隊風險計數應 >= 0"
assert snap["controlled_team"]["team_stats"]["risk_count_stress"] >= 0, "高壓計數應 >= 0"

# 驗證邊界：人口為 0 時無法進入
var empty_team_test = false  # TODO: 創建無人口 team 測試
```

**集成測試**：
- headless 跑 1000+ Tick，進/出 member_mode 切換，無崩潰
- member_mode 時畫面無遮擋、文字對齊
- 切換成員時，詳情欄及時更新

---

## 4. 驗收標準

### 功能驗收

- [x] 進入 member_mode 看到三欄佈局（成員列表 + 詳情 + 聚合統計）
- [x] ↑/↓ 切換成員，中欄即時更新
- [x] [D] 展開健康部位詳情（HP/status/出血/骨折）
- [x] [E] 展開裝備檢視（穿戴 + 背包）
- [x] [T] 切換右欄「聚合統計」↔「環境情報」
- [x] 聚合欄顯示脫隊風險計數（loyalty < 0.7 的人數）
- [x] [M] 返回正常模式，member_mode 無殘留狀態

### UI 驗收

- [x] 三欄寬度合理（總寬度 120–140 字符內，避免折行）
- [x] 文字對齐，無雜亂排版
- [x] 重要資訊使用 ⚠ / ✗ / ◎ 視覺標記，易讀

### 效能 / 穩定性

- [x] headless test 1000+ Tick，member_mode 進出無崩潰
- [x] 快取機制：進入 member_mode 時呼叫 query_player()，之後不重複查詢
- [x] 記憶體無洩漏：返回正常模式時清除快取
- [x] **邊界條件**：
  - team 無人口時，禁止進入 member_mode
  - 選中成員被殺時，自動移動選擇到下一個存活成員
  - 全部成員都死亡時，member_mode 自動返回主 UI

### 文件

- [x] 更新 `docs/progress.md` 記錄此功能
- [x] 程式碼註解清楚（尤其是三欄佈局邏輯）

---

## 5. 後續擴展（out of scope）

- **升級 B 方案**：全詳細檢視頁面（如有需要）
- **人物記憶檢視**：顯示成員的過往事件記錄
- **忠誠度圖表**：歷史趨勢曲線
- **自動建議**：系統提示「此成員壓力高，建議休養」

---

## 6. 相關文件

- [`docs/person.md`](../person.md) — 人物屬性詳細定義
- [`docs/team.md`](../team.md) — 團體結構
- [`scripts/ui/text_ui_main.gd`](../../scripts/ui/text_ui_main.gd) — UI 主檔
- [`scripts/ui/sim_bridge.gd`](../../scripts/ui/sim_bridge.gd) — 模擬層橋接
