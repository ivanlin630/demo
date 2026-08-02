# 團體 (Team)

## 相關文件
- [核心概念](game-design.md)
- [人物](person.md)
- [世界](world.md)
- [事件](event.md)

---

## 定義

地圖上的棋子單位。由記名 NPC（leader + advisors）帶領，代表一群人的集體行動。

---

## 資料結構

定義於 `scripts/data/team_data.gd`：

```gdscript
var team_id: int
var leader_id: int          # 記名 NPC id
var named_members: Array    # 記名 NPC id[]（取代舊 advisors + members）

var population: int         # 成人人口，上限 50，最小 1
var minor_population: int   # 未成年人口，上限 = population × 20%，不計入上限

# anon 4 tier（取代舊 anon_combat_skill / anon_wage scalar）
var anon_tiers: Dictionary = { "平民": 0, "新兵": 0, "老兵": 0, "菁英": 0 }
var anon_exp: Dictionary   = { "平民": 0.0, "新兵": 0.0, "老兵": 0.0 }
# anon_combat_skill / anon_wage 為 computed getter，delegate AnonTierSystem
var armed_anon_ratio: float = 0.0      # 匿名人口中武裝比例（0.0–1.0）
var anon_treasury: float = 0.0          # 匿名薪資沉澱（待轉具名 / 戰利品分配）

var resources: Dictionary
# {
#   "food": float, "material": int, "coin": int, "goods": int, "gem": int,
#   "ore_gold": int, "ore_silver": int, "ore_iron": int, "ore_steel": int,
#   "weapon_melee_low": int, "weapon_melee_high": int,
#   "weapon_ranged_low": int, "weapon_ranged_high": int,
# }
# ore_iron：世界資源（mountain 30% / plains 5% 機率生成）；採集後製造
# ore_steel：只能由製造系統冶煉（ore_iron → ore_steel）
# weapon_*：每單位代表 UNITS_PER_EQUIP(2) 件裝備；由 EquipmentSystem 分配給記名 NPC

var equip_order: Dictionary = {        # 指揮官武裝指令
    "melee_low": 0, "melee_high": 0,
    "ranged_low": 0, "ranged_high": 0,
}

var move_target: Vector2i   # 目標格，(-1,-1) = 不移動
var move_tick_acc: int      # 累積 Tick，達移動成本門檻才走一格
var last_tile_pos: Vector2i # 上一 tick 位置（observe_velocity 用）

var tags: Array             # 職責標籤：["統領", "軍隊", "商隊", "生產", "宗教", "流亡", "子團"]
var current_task: String    # "idle" / "徵收" / "偵查" / "信使" / "攻擊" / "掠奪" / "外交" / "護衛" / "逃跑"
                            # "貿易" / "訓練" / "合併" / "安頓" / "安撫" / "return_home" / "投靠" / "乞食"
                            # "起義" / "遷徙"
var task_priority: int      # 現任 task 優先權（TaskArbiter 管理）；idle 時 0

var unrest_turns: int       # 不滿積累值
var famine_days: float      # 連續斷糧天數（satisfaction<0.3 累積）；>7 天 grace 後 minor/anon 餓死
var task_reason: String     # 最近 task 設定來源（TaskArbiter _source；遙測用）
var task_start_tick: int    # 最近 task 設定 tick（逃跑/survival timeout 用）
var faction_id: int         # 所屬勢力，-1 = 獨立
var tile_pos: Vector2i      # 當前大地圖格座標

var combat_target: int      # 接觸戰鬥的目標 team_id（-1 = 無，戰鬥中才設）
var prosperity_target_id: int  # 攻擊意圖目標 team_id（-1 = 無，AI 派 attack 用）
var readiness: float        # 戰鬥準備度 0.0–1.0；morale cascade 時加速消耗
var wounded: int            # 當前 Tick 累計受傷人數
var prosperity_eval_next_tick: int  # 下次 prosperity 評估 tick（cadence 控制）
var strategic_assignments: Dictionary  # StrategicAI 派的座標目標（key: target_id 或 -1, value: Vector2i）
```

### Anon Tier 系統

4 階梯（取代舊 scalar）：

| tier | combat | speed | base_wage |
|---|---|---|---|
| 平民 | 0.1 | 0.7 | 0.5 |
| 新兵 | 0.3 | 0.8 | 1.0 |
| 老兵 | 0.5 | 0.9 | 1.5 |
| 菁英 | 0.7 | 1.0 | 2.5 |

升等規則（`AnonTierSystem.try_promote`）：
- 需 exp ≥ threshold × count（個體成本，threshold 50/100/200）
- 扣 coin + food + material × count
- leader 戰術 skill 控訓練上限（≤0.4 新兵 / ≤0.7 老兵 / >0.7 菁英）；戰場 exp 不受限
- 升菁英需 team 持有 `weapon_melee_high ≥ 新菁英總數`（check 不消耗）
- 經驗來源：訓練 task（leader 戰術 × n / tick）+ 戰鬥存活（+5，勝方 +5）
- **觸發者**（2026-06-17）：NPC 經 `training_system`（TASK_TRAIN 隊每 tick add_exp **+ try_promote**，W4 層1 修前缺 promote caller→永不升階）；玩家經 `_action_train`（一次性 coin 30 → add_exp + try_promote，self-action）。遺留 W4 層2：NPC AI 鮮少選 TASK_TRAIN。

死亡分配（weighted random by tier count），不殺 named。

---

## 人口規則

- 成人上限：50
- 成人最小：1（不會因消耗或逃跑歸零）
- 未成年人口：上限為 `population × 0.2`，不計入 50 人上限
- 未成年轉成人：由年齡系統驅動（未來實作）

---

## 不滿（unrest_turns）

| 來源 | 變化 |
|---|---|
| N2_riot（暴動反應） | +1 |
| P4_expand（擴張反應） | -1 |
| 事件：替換領袖 | -20 |
| 事件：Team 分裂 | 歸零 |

門檻：
- `>= 20`：觸發領袖替換事件（若有統領 >= 0.3 的異見者）
- `>= 30`：觸發分裂事件（若異見者 義氣 < 0.4 且目標衝突）

---

## 標籤（tags）

### 對個人反應的影響

| 標籤 | 影響 |
|---|---|
| "生產" | P2_produce 基礎分數啟用（0.6 vs 0.1） |
| "統領" | P4_expand 基礎分數啟用（0.55 vs 0.05） |

### 對 task 的權限（_tag_weight）

| 標籤 | 高權限 task（×1.0）| 有 tag 但無匹配（×0.0）| 無任何 tag（×0.5）|
|---|---|---|---|
| 統領 | 全部 | — | — |
| 軍隊 | 攻擊/掠奪/護衛/偵查/信使/徵收/巡邏 | 其餘 | — |
| 商隊 | 外交/信使/護衛/偵查/貿易 | 其餘 | — |
| 生產 | 信使/生產/製造 | 其餘 | — |
| 宗教 | 外交/信使 | 其餘 | — |
| 流亡 | idle/逃跑（硬封其餘） | 全部其餘 ×0.0 | — |
| 子團 | 全部（跟指令，不過濾） | — | — |

### tag 增減機制（EventTagShift）

| 條件 | 變化 |
|---|---|
| leader 好戰 > 0.7 且 野心 > 0.6 | +軍隊、-生產 |
| wounded / population > 0.5 | +流亡、-軍隊 |
| food/人 > 5 且 wounded=0 且 unrest < 5 | -流亡（恢復）|

---

## 資源收集 + 公庫稅制（2026-06-13 封建財政）

### 採集（resource_system）
- 條件：所在格 `outpost_level > 0`
- 每次收取：`productivity × tile.resources[res] × COLLECT_RATE(0.05) × outpost_mult × labor_mult × work_morale`（food 另乘 farming_level/季節）
  - ★`labor_mult` = `LaborSystem` 統一勞力池分配（2026-08-03、取代舊 `pop_mult=sqrt(pop/5)`）：per-tile 勞力池（共址 PRODUCE pop 總和）按 need_oracle 加權比例分各工位、`labor_mult = fill × LABOR_SCALE`。**need-gated full-stop**（該資源 need=0→fill=0→不採）；size 靠餵多/大 facility（breadth）。詳 [[docs/superpowers/specs/2026-08-03-unified-labor-pool-HOW.md]]。**tile 承載（`current`/COLLECT_RATE/regen）獨立不碰**。
- food/material → 採集團 `team.resources`（私產）；ore/mounts/製造成品 → tile `public_storage`（公庫）

### 財產兩層（永不混淆）
| 錢包 | 屬於 | 進法 |
|---|---|---|
| `team.resources` | 居民私產 | 自採稅後留下 |
| tile `public_storage`（公庫）| 據點 owner 統治者稅金 | 依 tax_rate 自動扣居民產出 |

### 兩種稅
- **一般稅**（自動）：居民 outpost 採集 → `tax_rate × 產出` 自動撥腳下 tile owner 公庫，無需 task。慢性 unrest（rate 超容忍閾值才累積）
- **特別稅**（徵收 task）：leader 主動額外加徵 `tax_rate × SPECIAL_TAX_MULT(1.5)`，進 leader 口袋（戰時/缺糧）。尖峰 unrest（搜刮量×0.3 + annoyance 疊加）

### 建造扣公庫（本地）
- 建造/升級付款先扣**腳下 tile** public_storage，不足補施工團 resources（嚴格本地，非隔空）
- 派建造子隊：owner 站自家 outpost → caravan-load 從公庫提建材裝子隊背包

---

## 飢餓致死 + 滅團（2026-06-13 famine-death）

- `satisfaction = food / (pop × FOOD_PER_PERSON_PER_DAY(0.8) × day_fraction)`；< 0.3（FAMINE_SATISFACTION_THRESHOLD）→ `famine_days` 累積，>7 天 grace 後：minor 先死（10%/日）→ anon（5%/日，kill_random）
- named/leader：個人 `person.hunger` 累積 → ≥0.7 → blood 流失 → blood<30 戰場昏迷失能（可俘）→ blood=0 死亡
- 滅團（pop≤0）：`_on_team_extinct` 標記 → tick 末 `cleanup_extinct_teams` 路由遺財（公庫/abandoned/地面，守恆）+ erase

---

## 與勢力關係

- 有 `"統領"` 標籤的 Team 可成為勢力核心
- `faction_id == -1` → 獨立 Team
- 勢力支配需外交或武力（未來實作）

---

## 移動系統

定義於 `scripts/simulation/movement_system.gd`。

- 每 Tick 累積 `move_tick_acc`，達 `move_tick_cost` 才走一格
- 移動成本：`clamp(round(BASE_MOVE_TICKS / _compute_team_speed), MIN_MOVE_TICKS, MAX_MOVE_TICKS)`
- `_compute_team_speed`：記名 NPC `get_effective_speed()` + 匿名健康=1.0 + 傷者=0.5 的加權均值
- 路徑：greedy step（選最接近 move_target 的鄰格）
- 抵達：更新 `occupied_by`，**不**自動建立據點

## 子團自主 AI

整合於 FactionAI step6b（`faction_ai_system.gd`）。`evaluate_all` 中 `parent_team_id != -1` → 子團模式，優先執行，跳過 faction/solo 策略。

### 護衛跟隨（task == "護衛"）

- 每 tick：`move_target = order_target` 的 `tile_pos`
- `order_target` 消失 → `task → idle`，`order_target_id = -1`

### 任務完成回歸

| 狀態 | 行為 |
|---|---|
| 到達 `move_target`，parent 同格 | `try_merge_back` |
| 到達 `move_target`，parent 不同格 | `task → idle`，`move_target → parent` |
| `task == idle`，parent 同格 | `try_merge_back` |
| `task == idle`，parent 不同格 | `move_target → parent` |

### 紀律失效

`fail_chance = (1 - sub_leader.loyalty) × sub_leader.stress × 0.15`

失效 → `parent_team_id = -1`，tag 子團移除，`task → idle`。下一 tick 由 SoloAI 接管。

> 未來擴充：若子團含多個記名 NPC（advisors），改為 loyalty/stress 均值計算。

---

## Task 優先權仲裁（TaskArbiter）

所有 `current_task` 寫入走 `TaskArbiter`（`scripts/simulation/task_arbiter.gd`）；
直接賦值僅允許於新 team 建立點（reaction 流亡 / population overflow / subteam dispatch，須同時設 `task_priority`）。

| 優先 | 常數 | 來源 |
|---|---|---|
| 100 | PRIO_COMBAT | `combat_target != -1` 戰鬥鎖（絕對）|
| 80 | PRIO_SURVIVAL | survival（return_home / 乞食 / 投靠 / 飢餓掠奪）|
| 70 | PRIO_THREAT | threat response + bridge 恐慌逃跑 + 起義/守城 |
| 60 | PRIO_PLAYER | 玩家命令（player_commanded_task / player herald / order_subteam）|
| 50 | PRIO_DISPATCH | AI 派遣（貿易/安頓/建設/prosperity/偵查/信使/徵收/外交/護衛/合併）|
| 30 | PRIO_FACTION | faction goal 攻擊傾向 |
| 10 | PRIO_AMBIENT | 閒置填充（居民「生產」常駐 / 等待新領主）|
| 0 | — | idle |

- API：`try_set`（嚴格大於現任才搶得動；同層先到先得；回 false 呼叫端不得做配套副作用）/ `release`（完成/取消 → idle + priority 0 + move_target 清）/ `transition`（就地轉換，如 安頓→生產）
- 抗命窗口（軟 60）：NPC 慾望 (50) 挑戰玩家命令 (60) → leader 個性確定性判定（`_defiance_check`，無 RNG）；抗命成功印 `[抗命]`，被壓抑 → leader stress +0.05、team unrest +1（stress 進 desire 公式 → 憋多了爆）
- 不變量：`current_task == idle` ⟺ `task_priority == 0`；戰鬥鎖期間一切 try_set false
- **task latch 釋放（2026-06-13 W5，核心）**：高優先 task 必須有釋放條件，否則凍結世界（曾 92% team-time 卡死）：
  - survival：`_evaluate_survival` 糧恢復 ≥ SURVIVAL_RECOVER_DAYS(7) → release（hysteresis）
  - threat/逃跑：威脅消失（ThreatAssessment dist_factor floor 0→ 脫離）或 FLEE_TIMEOUT(5天) → release
  - 乞食：無施主 → 不空轉 latch，release 回 idle
- 詳見 `docs/superpowers/specs/2026-06-11-task-arbiter-design.md`

## 未來擴充

- 移動 AI（自動設定 move_target，依目標/資源/威脅評估）
- A* 路徑（有障礙地形時替換 `_step_team` 內部）
- 移動速度受地形、負重、疲勞修正
- Team 間外交（結盟、臣服、宣戰）
- 任務系統（current_task 實際影響行為）
