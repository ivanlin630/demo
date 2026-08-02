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
# blood = 0   → 死亡（check_starvation_deaths 日邊界判定，通用死因）
# blood < 30  → 昏迷失能（BLOOD_COMA_THRESHOLD，is_combat_capable false → 戰場可被俘）
# 影響 get_effective_speed() × (blood / 100.0)

var hunger: float = 0.0    # 個人飢餓 [0,1]（2026-06-13 famine-death）；跟人走不跟團
# satisfaction<0.3 → hunger 累積(0.05/日×缺糧比)；吃飽 → -0.1/日恢復
# hunger ≥ 0.7 → tick_natural_regen blood 流失取代再生（餓傷）→ 衰弱(blood→speed)→ 昏迷 → 死
# 中途加入者 hunger=0 不繼承團時鐘；饑荒叛逃者帶餓垮身體入新團

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

**遭遇戰結束自動結算（雙方所有進入遭遇戰的成員）：**
1. 各方用自己 team 資源結算（medicine/tools）
2. 有資源 → 消耗資源清除 flag（`bleeding_major` 優先）
3. 資源不足 → 最高醫療技能者技能判定 → 機率清除
4. 剩餘出血/中毒 → 一次性扣值後清除（**底線：blood ≥ 1、hp ≥ 1，不因結算死亡**）
5. 骨折無資源 → 保留帶入大地圖

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

### 傷勢機制（HP-based，`HealthSystem`）

**部位 HP 制**（`health_system.gd`、2026 重構、取代舊 `_tick_critical_npcs` 機率死亡——**該 subsystem 已不存在**）：
- 每部位有 `hp/max_hp`，命中扣 HP（`bp[part].hp = maxf(hp − dmg, 0)`，:34）。
- `_calc_status(hp,max_hp)`(:23-28) 映射 HP→status；**`HP=0 → "severed" = fatal wound（所有部位、含 head/torso）**（:28）。
- **HP 再生**：`HP_REGEN_PER_TICK=0.5`（骨折 `HP_REGEN_FRACTURE=0.05`）；毒 `POISON_HP_DRAIN=5.0`。

### 戰鬥命中分配

| 部位 | 機率 |
|---|---|
| head | 10% |
| torso | 40% |
| right_arm / left_arm | 各 10% |
| right_leg / left_leg | 各 15% |

每次命中扣該部位 HP。**任何部位 HP=0→severed=致命**（含 head/torso、非「四肢才致命」）。

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

反應分兩層（2026-06-13 W3 生育分層）：

**行動反應**（winner-take-all，這 tick 做一件事）— `_evaluate_person` 輸出分數最高者：

| 代號 | 名稱 | 主要觸發條件 | 效果 |
|---|---|---|---|
| P1_comply | 服從 | 高忠誠、低壓力 | loyalty +0.01 |
| P2_produce | 生產 | 食物充足、低壓力、team 有生產標籤 | 無直接效果；計入 work_morale 統計 |
| P4_expand | 擴張 | 食物充裕、低壓力 | unrest_turns -1 |
| N1_flee | 逃離 | 高壓力、低忠誠 | pop -1；solo leader 不動（stress 不洩壓）；named 離團組/入流亡 team |
| N2_riot | 暴動 | 高壓力、高恐懼 | unrest_turns +1 |
| N3_defect | 叛逃 | 高壓力、低忠誠、高恐懼 | 同 N1 結構，loyalty=0 |
| N4_shirk | 怠工 | 高壓力、低忠誠 | food -1；計入 work_morale 負項 |
| N5_extort | 勒索 | 高壓力、低恐懼、低忠誠 | team coin → person.coin（守恆，上限 5/次） |

**生命事件**（獨立 roll，可與行動並行 — 人邊工作邊生育）— `_evaluate_life_events`：

| 代號 | 名稱 | 觸發 | 效果 |
|---|---|---|---|
| P5_breed | 繁殖 | 安全+溫飽+食物盈餘(>pop×2.4×7)+minor<cap | 機率 BREED_BASE_CHANCE(0.15)+醫療×0.1 → minor +1。cap=maxi(1,int(pop×0.25)) |

> W3 修（2026-06-13）：P5 原在 winner-take-all 永遠輸 P1/P2（max 0.5 vs ~1.0）→ 0 生育。移到生命事件層獨立 roll 後 2 年 multi 長大成人 0→39。生命事件層可擴展（未來生病/衰老）。
> P3_recruit 已刪除（2026-06-11）：reaction 不再直接生人口。

### work_morale（工作態度係數）

`team.work_morale` ∈ [0.5, 1.5]，預設 1.0。`evaluate_all` 每輪統計：P2 +1、N4 -1、其他反應中性計入，
目標值 `1.0 + mean×0.5`，lerp 0.1 漸進。`resource_system._collect_from_tile` 採集 gain 乘此係數。

"none"（無反應）固定分數 0.2，作為基準競爭。

每個效用函數加入 skills + values + goals 加成：
- 技能高 → 對應反應分數上升
- 價值觀（野心/求生欲/義氣/貪婪）直接加權
- **慎重**：跨系統關鍵字，壓低所有風險行為（N2/N3/N5 等）
- **好戰**：`_should_attack` 加權（+0.3）；FactionAI 攻擊 goal 加權
- **殘忍**：`_score_riot` / `_score_extort` +0.15；戰勝後 loot rate ×(1 + cruelty×0.7)；cruelty > 0.6 → 敵方傷兵 wounded → critical 機率
- **信義**：`_try_diplomacy` 接受公式加入 trust×0.3（義氣降至×0.5）；`_resolve_tribute` 低信義少繳/高信義多繳；`event_faction_defect` 低信義 OR 低義氣 → 叛離

### 逃跑橋接（ReactionBridge）

每 Tick 結算後：若 team 內 N1_flee 人數 ≥ 30% 人口，且 `ThreatAssessment` 在 team_discovered 中找到
score > 門檻的真威脅，才設 `team.current_task = "逃跑"`，move_target = 威脅反方向 3 hex（in-map check）。
無真威脅 → 不劫持 task（內心恐慌但無處可逃）。護衛/已逃跑任務不受影響。

已知問題：bridge 與 survival 鏈（乞食/return_home）互搶 task（仲裁未定，見 known_issues task仲裁）。

### Goals 加分（`_goal_bonus`，goal 是 **typed dict**、讀 `goal.type`，reaction_system:133-142）

| goal.type | 加分的反應 | 加分量 |
|---|---|---|
| `escape_war` / `wealth` | N1_flee | +0.2 |
| `domination` | P4_expand | +0.35 |
| `revenge` | N2_riot, N3_defect | +0.2 |

（★2026 重構：goal 從舊字串（"求生"/"發財"…）改 typed dict `{type, ...}`；舊字串表已作廢。）

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
| P4_expand | 統領 | 魅力 |
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
