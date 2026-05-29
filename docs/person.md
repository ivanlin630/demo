# 人物 (Person)

## 相關文件
- [核心概念](game-design.md)
- [事件](event.md)
- [世界](world.md)
- [訊息](message.md)

---

## 資料結構

定義於 `scripts/data/person_data.gd`：

```gdscript
var id: int
var person_name: String
var role: String        # "leader" / "advisor" / "civilian" / "guard"
var team_id: int        # 所屬團體
var age: int

# 狀態（每 Tick 獨立更新）
var needs: Dictionary   # { "food": float, "safety": float, "belonging": float }
var stress: float       # 0.0–1.0
var fear: float         # 0.0–1.0
var loyalty: float      # 0.0–1.0

# 決策輸入
var goals: Array        # 長期目標字串，效用函數輸入

# 先天屬性（固定或極慢變動）
var attributes: Dictionary
# { "體力": float, "智力": float, "魅力": float, "毅力": float }

# 技能（14 項，從反應/系統中成長）
var skills: Dictionary
# { "統領", "戰鬥", "弓箭", "求生", "生產", "製造",
#   "工程", "醫療", "戰術", "計謀", "交涉", "商業",
#   "偵查", "潛行" }
# 戰鬥：體力；melee 武裝者每回合成長（InteractionSystem._resolve_combat_round）
# 弓箭：智力+體力；ranged 武裝者 Round 0 齊射時成長（InteractionSystem._resolve_volley）
# 戰術：智力；戰鬥結束時 leader 成長（InteractionSystem._end_combat / _force_retreat）
# 偵查：智力+體力；影響視野半徑和能否看穿潛行；由 VisionSystem 成長
# 潛行：體力+毅力；降低暴露值，讓 team 難被偵測；由 VisionSystem 成長

# 價值觀（半永久人格）
var values: Dictionary
# { "野心", "求生欲", "義氣", "貪婪", "慎重",
#   "好戰",  # 高 → 主動尋求戰鬥；_should_attack 加權
#   "殘忍",  # 高 → loot rate 提升、傷兵惡化、暴動/勒索傾向
#   "信義",  # 高 → 外交接受率、徵收率；低 → 叛離條件觸發
# }

var memory: Array       # [{ event_id: int, intensity: String, reaction: String }]

# 部位健康
var body_parts: Dictionary
# 完整格式（玩家 + 遭遇戰 named NPC）：
# {
#   "head":      { "hp": 20.0, "max_hp": 20.0, "status": "healthy",
#                  "poisoned": false, "bleeding": "none", "fracture": false },
#   "torso":     { "hp": 50.0, "max_hp": 50.0, ... },
#   "right_arm": { "hp": 25.0, "max_hp": 25.0, ... },
#   "left_arm":  { "hp": 25.0, "max_hp": 25.0, ... },
#   "right_leg": { "hp": 30.0, "max_hp": 30.0, ... },
#   "left_leg":  { "hp": 30.0, "max_hp": 30.0, ... },
# }
# status 由 hp 門檻自動計算（不手動設定）：
#   hp > 75%  → "healthy"
#   25–75%    → "wounded"
#   1–24%     → "critical"
#   0         → "severed"（四肢）/ 死亡（head/torso）
# bleeding: "none" / "minor" / "major"
# fracture: 骨折 flag，不自動清除，需 tools ×1 治療
#
# 大地圖 NPC（簡化）：只有 {"status": "healthy"} 無 hp/flags

var blood: float = 100.0   # TEST VALUE — 全身血液值
# blood = 0   → 死亡
# blood < 30  → 昏迷（無法行動）（TEST VALUE）
# 影響 get_effective_speed() × (blood / 100.0)

const STATUS_MULT: Dictionary = {
    "healthy": 1.0, "wounded": 0.7, "critical": 0.3, "severed": 0.0
}

# 裝備（8 槽位）
var equipment: Dictionary = {}
# {
#   "head":      { "type": "pool", "grade": "armor_low" }   # 或 {"type":"none"}
#   "torso":     ...
#   "right_arm": ...  "left_arm": ...
#   "right_leg": ...  "left_leg": ...
#   "hand_1":    { "type": "pool", "grade": "weapon_melee_low" }  # 主手（無左右區分）
#   "hand_2":    { "type": "pool", "grade": "armor_low" }         # 副手 / 盾牌
# }
# hand_1/hand_2：無左右邏輯，任一可持武器或盾牌
# 2h 武器（weapon_ranged_*）裝備時同時佔 hand_1 + hand_2（is_2h = true）
# armor_* 裝在 hand 槽 → 作為盾牌（提供 block_chance），裝在護甲槽 → 減傷
# 由 EquipmentSystem 依 team.equip_order 分配；NPC 死亡時自動歸還武器庫
```

---

## 部位健康系統

### Status 等級

| status | multiplier | 說明 |
|---|---|---|
| `healthy` | ×1.0 | 無懲罰 |
| `wounded` | ×0.7 | 30% 下降 |
| `critical` | ×0.3 | 70% 下降（head/torso：瀕死狀態） |
| `severed` | ×0.0 | 功能全失（四肢限定） |

**負面 flags（遭遇戰中產生，部分帶入大地圖）：**

| flag | 遭遇戰效果 | 結算後 | 大地圖 |
|---|---|---|---|
| `bleeding: "minor"` | 每 round 扣少量 blood | 一次扣 blood ×小 → 清除 | 無 |
| `bleeding: "major"` | 每 round 扣大量 blood | 一次扣 blood ×大 → 清除 | 無 |
| `poisoned: true` | 每 round 扣各部位 HP | 一次扣全部位 HP → 清除 | 無 |
| `fracture: true` | 見骨折效果表 | **保留** | ✅ 持續，tools ×1 治療 |

**骨折效果（依部位）：**

| 部位 | 效果 |
|---|---|
| head | 每 round 機率跳過行動；智力 ×0.5 |
| torso | 疲勞消耗 ×2；速度 −20% |
| arm（其一）| 該手槽裝備自動掉落；hand slot 無法使用 |
| leg（其一）| 速度 −50%；無法衝刺 |
| leg（兩隻）| 速度 −90%；無法主動移動 |

**遭遇戰結束自動結算（治療優先順序）：**
1. 掃描玩家 team 所有人的 flags
2. 有資源 → 消耗資源清除 flag（`bleeding_major` 優先）
3. 資源不足 → 最高醫療技能者技能判定 → 機率清除
4. 剩餘出血/中毒 → 一次性扣值後清除；骨折保留帶入大地圖

**治療物品對照：**
| 動作 | 消耗 | 效果 |
|---|---|---|
| 草藥 | medicine ×1 | 清除 bleeding_minor |
| 繃帶 | medicine ×2 | 清除 bleeding_major |
| 解毒劑 | medicine ×3 | 清除 poisoned |
| 夾板 | tools ×1 | 清除 fracture（大地圖可用）|

### 部位 → 影響

| 部位 | 影響 |
|---|---|
| `head` | 智力、魅力屬性 × mult（`get_attribute_mult`） |
| `torso` | 體力、毅力屬性 × mult |
| `right_arm` / `left_arm` | 戰鬥/弓箭/製造/工程/醫療 技能 × 雙臂均值（`get_skill_mult`） |
| `right_leg` / `left_leg` | 個人移動速度 × 雙腿均值（`get_effective_speed`） |

### Critical 瀕死機制（head/torso）

每 Tick 雙重判定（`_tick_critical_npcs`）：

1. **死亡機率**：`death_chance = 0.10 × (1 - medicine × 0.5)`
2. **治療恢復**：若未死亡，`recover_chance = 0.40 × medicine`（critical → wounded）

無醫療：~10%/Tick 死亡；醫療=1.0：5%/Tick 死亡 + 40% 恢復機會。

### 戰鬥命中分配

| 部位 | 機率 |
|---|---|
| head | 10% |
| torso | 40% |
| right_arm / left_arm | 各 10% |
| right_leg / left_leg | 各 15% |

每次命中：status 降一級（healthy → wounded → critical → severed）。
四肢 severed 時：NPC 死亡。head/torso severed 不發生（critical = 瀕死上限）。

### 大地圖 vs 遭遇戰分層

| 層級 | 欄位 | 受傷機制 |
|---|---|---|
| 大地圖 NPC | `status` only | 直接改 status |
| 玩家/遭遇戰 | `status` + `hp` + `max_hp` | 扣 HP，歸零改 status |

---

## 四層決策模型

```
屬性（Attributes）→ 技能成長速率
技能（Skills）     → 效用函數加分
價值觀（Values）   → 目標傾向 + 反應偏好
目標（Goals）      → 效用函數輸入
```

---

## 反應系統

定義於 `scripts/simulation/reaction_system.gd`。

每 Tick 對每個 NPC 跑效用函數，輸出分數最高的反應：

| 代號 | 名稱 | 主要觸發條件 |
|---|---|---|
| P1_comply | 服從 | 高忠誠、低壓力 |
| P2_produce | 生產 | 食物充足、低壓力、team 有生產標籤 |
| P3_recruit | 招募 | 低壓力、高忠誠、team 人口 < 40 |
| P4_expand | 擴張 | 食物充裕、低壓力 |
| P5_breed | 繁殖 | 安全感高、food 需求滿足、未成年上限未滿 |
| N1_flee | 逃離 | 高壓力、低忠誠 |
| N2_riot | 暴動 | 高壓力、高恐懼 |
| N3_defect | 叛逃 | 高壓力、低忠誠、高恐懼 |
| N4_shirk | 怠工 | 高壓力、低忠誠 |
| N5_extort | 勒索 | 高壓力、低恐懼、低忠誠 |

"none"（無反應）固定分數 0.2，作為基準競爭。

每個效用函數加入 skills + values + goals 加成：
- 技能高 → 對應反應分數上升
- 價值觀（野心/求生欲/義氣/貪婪）直接加權
- **慎重**：跨系統關鍵字，壓低所有風險行為（N2/N3/N5 等）
- **好戰**：`_should_attack` 加權（+0.3）；FactionAI 攻擊 goal 加權
- **殘忍**：`_score_riot` / `_score_extort` +0.15；戰勝後 loot rate ×(1 + cruelty×0.7)；cruelty > 0.6 → 敵方傷兵 wounded → critical 機率
- **信義**：`_try_diplomacy` 接受公式加入 trust×0.3（義氣降至×0.5）；`_resolve_tribute` 低信義少繳/高信義多繳；`event_faction_defect` 低信義 OR 低義氣 → 叛離

### 逃跑橋接（ReactionBridge）

每 Tick 結算後：若 team 內 N1_flee 人數 ≥ 30% 人口，自動設 `team.current_task = "逃跑"`，清除 move_target。護衛任務不受影響。

### Goals 加分（_goal_bonus）

| 目標字串 | 加分的反應 | 加分量 |
|---|---|---|
| "求生" / "逃離" | N1_flee | +0.2 |
| "擴張" / "繁榮" | P4_expand, P3_recruit | +0.15 |
| "發財" | N5_extort, P2_produce | +0.15 |
| "復仇" | N2_riot, N3_defect | +0.2 |
| "建立勢力" | P3_recruit, P4_expand | +0.2 |

### 目標自動生成（每 10 Tick）

| 條件 | 新增目標 |
|---|---|
| values["野心"] > 0.7 | "建立勢力" |
| values["求生欲"] > 0.7 AND stress > 0.5 | "求生" |
| values["貪婪"] > 0.7 | "發財" |
| values["義氣"] > 0.7 | 移除 "逃離" / "復仇" |

---

## 技能成長

定義於 `scripts/simulation/skill_system.gd`。

每次 NPC 執行反應後觸發：

```
growth = BASE_GROWTH(0.005) × (attr_val × attr_mult) × (0.5 + (毅力 × torso_mult) × 0.5) × skill_part_mult
person.skills[skill] = min(current + growth, 1.0)
```

部位受傷會壓低屬性效益（`get_attribute_mult`）及臂技能成長（`get_skill_mult`）。

反應對應技能與屬性：

| 反應 | 成長技能 | 依賴屬性 |
|---|---|---|
| P2_produce | 生產 | 智力 |
| P3_recruit / P4_expand | 統領 | 魅力 |
| P5_breed | 醫療 | 智力 |
| N1_flee / N4_shirk | 求生 | 體力 |
| N2_riot | 戰鬥 | 體力 |
| N3_defect | 計謀 | 智力 |
| N5_extort | 商業 | 魅力 |

戰術、工程、弓箭、製造、交涉：來源保留給戰鬥系統。

---

## 需求與壓力更新

定義於 `scripts/simulation/resource_system.gd`。

- 食物不足時：`needs["food"] = satisfaction`（0.0–1.0）
- `stress += (0.5 - satisfaction) × 0.2`（食物 < 0.5 才上升）
- `needs["food"] < 0.3`：`fear += 0.05`、`loyalty -= 0.02`

---

## 記憶

- 執行 P1_comply / P2_produce 以外的反應 → 寫入 memory
- intensity: "minor" / "significant"（riot, defect）/ "traumatic"（flee）

---

## 慎重：跨系統設計契約

`values["慎重"]` 影響所有未來涉及風險決策的系統：
- 交涉系統（談判激進度）
- 戰術系統（進攻 vs. 固守）
- 戰略系統（擴張 vs. 鞏固）
- 戰鬥決策（衝鋒 vs. 撤退）
- 訊息失真（是否主動扭曲情報）

規則：高慎重 → 壓低激進選項；低慎重 → 壓低保守選項。

---

## PersonGenerator（預留，待玩家系統實裝）

定義於 `scripts/simulation/person_generator.gd`（尚未建立）。

從非記名人口生成完整 PersonData，供：
1. 玩家吸收 team 時，匿名人口自動晉升一名 leader 帶領跟隨子隊
2. 玩家主動招募（付費/花時間）
3. 事件觸發（天賦人物出現）

```gdscript
# generate(state: WorldState, source_team: TeamData) -> PersonData
# - 從 source_team.population 取 1 人（population -= 1）
# - name:       "NPC_{next_id}"（佔位）
# - attributes: 隨機 0.2–0.8，依 source_team.tags 偏差
#     軍隊 → 體力/毅力偏高；生產 → 智力偏高；商隊 → 魅力偏高
# - skills:     全 0（從反應中成長）
# - values:     隨機 0.2–0.8
# - loyalty:    0.3（陌生人，需培養）
# - role:       "civilian"
```
