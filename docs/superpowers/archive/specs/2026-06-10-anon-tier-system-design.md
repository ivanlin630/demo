# 匿名人口等級系統（Anon Tier）— Design

> 日期：2026-06-10
> 議題：anon 全 team scalar 同質 → 速度 / 戰鬥力無差異化。引入 4 階梯（平民 / 新兵 / 老兵 / 菁英）+ 升等系統。

## 背景

當前狀態：
- `team.anon_combat_skill / anon_wage / armed_anon_ratio` 全 team-level scalar，tag-derived
- anon speed 統一 1.0（_compute_team_speed 預設）
- 戰鬥 / 升等 / 招募無分層
- = team 之間無經驗差異，老牌軍隊跟新團都一樣強

需求：
1. anon 分 4 階：平民 / 新兵 / 老兵 / 菁英
2. tier 影響戰鬥 + 速度 + wage
3. 升等：tier 內共享 exp 累積 + leader 戰術 skill 控制速率/上限 + 物資消耗
4. 留好接口給：encounter / salary / movement / npc_combat / equipment / interaction / outpost

## 目標

1. 新 class `AnonTierSystem` 集中 tier 邏輯（屬性表、升等、死亡分配、wage 計算）
2. `team.anon_tiers: Dictionary` + `anon_exp: Dictionary` 取代 scalar
3. 公開 API 供其他系統用
4. 既有 `anon_combat_skill / anon_wage / armed_anon_ratio` 改為 computed properties（向後相容）

## 不在範圍

- tag drift（leader/event 改 tag）→ 另 spec
- 外交招募 / 投靠流程 → 另 spec
- 戰俘處置（賣 / 屠 / 招降）→ 另 spec
- UI 呈現（team panel tier 分布）→ 另 spec
- minor_population 長大入 anon tier → 既有 minor 機制保留，但加入時呼叫 `add_anon(team, "平民", n)`
- 雇傭軍 / 直接買高 tier → 屬外交，另 spec

## 資料結構

### team_data.gd 新欄位

```gdscript
# 取代既有 anon_combat_skill / anon_wage / armed_anon_ratio scalar
var anon_tiers: Dictionary = {
    "平民": 0,
    "新兵": 0,
    "老兵": 0,
    "菁英": 0,
}
var anon_exp: Dictionary = {
    "平民": 0.0,   # 累積到門檻 → 抽人升新兵
    "新兵": 0.0,
    "老兵": 0.0,
    # 菁英無 next tier，不存 exp
}
```

`team.population` 仍為總人口（named + sum(anon_tiers)），不破。

### 既有相容

`anon_combat_skill / anon_wage / armed_anon_ratio` 改為 computed（getter）：

```gdscript
# team_data.gd 加 helper（或 AnonTierSystem 提供）
func get_anon_combat_skill() -> float:
    return AnonTierSystem.avg_combat_skill(self)

func get_anon_wage() -> float:
    return AnonTierSystem.total_wage(self)
```

刪舊 `_update_anon_combat_skill / _update_anon_wage`（faction_ai_system 內）。

`armed_anon_ratio` 維持（武器配發率，與 tier 解耦），由 equipment_system 既有邏輯處理。

## 全域屬性表

```gdscript
class_name AnonTierSystem

const TIER_ORDER: Array = ["平民", "新兵", "老兵", "菁英"]

const TIER_STATS: Dictionary = {
    "平民": { "combat": 0.1, "speed": 0.7, "base_wage": 0.5 },
    "新兵": { "combat": 0.3, "speed": 0.8, "base_wage": 1.0 },
    "老兵": { "combat": 0.5, "speed": 0.9, "base_wage": 1.5 },
    "菁英": { "combat": 0.7, "speed": 1.0, "base_wage": 2.5 },
}

# 升等所需 exp（tier 內累積到此值 → 可抽 N 個升下一階）
const PROMOTION_EXP_THRESHOLD: Dictionary = {
    "平民": 50.0,   # 平民 → 新兵
    "新兵": 100.0,  # 新兵 → 老兵
    "老兵": 200.0,  # 老兵 → 菁英
}

# 升等扣物資（per anon 升上來）
const PROMOTION_COST: Dictionary = {
    "平民": { "coin": 5, "food": 10, "material": 2 },
    "新兵": { "coin": 15, "food": 20, "material": 5 },
    "老兵": { "coin": 50, "food": 50, "material": 10 },
}

# 菁英額外條件：team 持有 weapon_melee_high >= 菁英總數
const ELITE_WEAPON_REQ: String = "weapon_melee_high"
```

## 升等規則

### 經驗來源

```gdscript
# 戰鬥存活：encounter end callback 算每 tier 倖存者，加 exp
const EXP_PER_COMBAT_SURVIVED: float = 5.0
const EXP_PER_COMBAT_VICTORY_BONUS: float = 5.0   # 勝方額外加

# 訓練 task：leader 派 "訓練" task，每 tick exp 累積
# 速率 = leader.skills["戰術"] × n（受訓 tier 平民人數）
```

### Leader 戰術 skill 控速率 + 上限

```gdscript
const TRAINING_TIER_CAP: Dictionary = {
    # leader 戰術 skill 上限 → 可訓練到的最高 tier（透過 training task）
    0.0: "新兵",   # skill <= 0.4 只能訓到新兵
    0.4: "老兵",   # 0.4 < skill <= 0.7 訓到老兵
    0.7: "菁英",   # skill > 0.7 可訓到菁英
}

# 但戰場升等不受此 cap 限制（實戰可破上限）
```

### 升等流程（leader 命令觸發）

```gdscript
# 玩家 / NPC leader 主動命令升一波
AnonTierSystem.try_promote(state, team, "平民", count=5) -> int
# 回傳實際升等的人數
# 條件：
#   1. team.anon_tiers["平民"] >= count
#   2. team.anon_exp["平民"] >= PROMOTION_EXP_THRESHOLD["平民"]
#   3. team 物資夠（coin + food + material × count）
#   4. 若升菁英：team.resources["weapon_melee_high"] >= 新菁英總數
#   5. 若透過 training cap：受訓 tier 不超過 leader 戰術 cap
# 副作用：
#   - 扣物資
#   - anon_tiers[from] -= count, anon_tiers[to] += count
#   - anon_exp[from] -= count × THRESHOLD（exp 被 consumed）
```

## 公開 API

```gdscript
class_name AnonTierSystem

# ───── 查詢 ─────
static func total_pop(team: TeamData) -> int
static func total_wage(team: TeamData) -> float          # 給 salary_system
static func avg_speed(team: TeamData) -> float           # 給 movement_system
static func avg_combat_skill(team: TeamData) -> float    # 給 npc_combat_system
static func tier_count(team: TeamData, tier: String) -> int
static func tier_breakdown(team: TeamData) -> Dictionary # 給 UI / log

# ───── 變動（mutation） ─────
static func add_anon(team: TeamData, tier: String, count: int) -> void
static func remove_anon(team: TeamData, tier: String, count: int) -> int
static func add_exp(team: TeamData, tier: String, exp: float) -> void
static func try_promote(state: WorldState, team: TeamData, from_tier: String, count: int) -> int
static func kill_random(team: TeamData, count: int, source: String) -> Dictionary
# kill_random 回 { "平民": N, "新兵": M, ... } 實際各 tier 死亡數
# source 標記用於 log / event tag（"combat" / "famine" / "disease"）

# ───── 整團轉移 ─────
static func transfer_proportional(from: TeamData, to: TeamData, count: int) -> Dictionary
# 按比例從 from 抽 count 人到 to（戰俘 / 投靠用）
# 回各 tier 實際轉移數
```

## 接口給各系統

| 系統 | 既有用法 | 改用 |
|---|---|---|
| `salary_system` | `team.anon_wage × anon_count` | `AnonTierSystem.total_wage(team)` |
| `movement_system._compute_team_speed` | unnamed × 1.0 | unnamed_per_tier × tier_speed |
| `npc_combat_system` | `team.anon_combat_skill` | `AnonTierSystem.avg_combat_skill(team)` |
| `encounter_system` 死亡 | scalar pop -= n | `AnonTierSystem.kill_random(team, n, "combat")` |
| `interaction_system` 投靠/居民化 | `team.population += n` | `AnonTierSystem.add_anon(team, tier, n)` (帶 source tier) |
| `outpost_system` 居民團補 anon | scalar pop ++ | `AnonTierSystem.add_anon(team, "平民", n)` |
| `event_unrest_split` | 拆分 pop | `transfer_proportional` |
| `equipment_system` armed_anon_ratio | 既有保留 | 不變 |
| `faction_ai_system._update_anon_*` | 主動更新 | 廢，改 computed |

## 死亡分配（隨機）

```gdscript
static func kill_random(team: TeamData, count: int, source: String) -> Dictionary:
    var killed: Dictionary = { "平民": 0, "新兵": 0, "老兵": 0, "菁英": 0 }
    var remaining: int = count
    var pool: Array = []
    for tier in TIER_ORDER:
        for i in range(team.anon_tiers.get(tier, 0)):
            pool.append(tier)
    pool.shuffle()
    for i in range(mini(remaining, pool.size())):
        var t: String = pool[i]
        killed[t] += 1
        team.anon_tiers[t] -= 1
    return killed
```

簡單但對大 pop 效率差。優化：用 weighted random（依各 tier count）抽。spec 寫 weighted 版：

```gdscript
static func kill_random(team: TeamData, count: int, source: String) -> Dictionary:
    var killed: Dictionary = {}
    for tier in TIER_ORDER: killed[tier] = 0
    var total: int = total_pop(team) - 1   # 不算 named
    for _i in range(count):
        if total <= 0: break
        var roll: int = randi() % total
        var acc: int = 0
        for tier in TIER_ORDER:
            acc += team.anon_tiers.get(tier, 0)
            if roll < acc:
                team.anon_tiers[tier] -= 1
                killed[tier] += 1
                total -= 1
                break
    return killed
```

`source` 給 log / 後續可加 reaction（如 source=="famine" 觸發 reaction event）。

## 速度計算（改 movement_system）

```gdscript
func _compute_team_speed(state: WorldState, team: TeamData) -> float:
    var total_speed: float = 0.0
    var total_count: int = 0
    # named (NAMED_WEIGHT 來自前 spec)
    var named_ids: Array = team.named_members.duplicate()
    if team.leader_id != -1: named_ids.append(team.leader_id)
    for pid in named_ids:
        var p = state.persons.get(pid)
        if p != null:
            total_speed += p.get_effective_speed() * NAMED_WEIGHT
            total_count += NAMED_WEIGHT
    # anon by tier
    for tier in AnonTierSystem.TIER_ORDER:
        var n: int = team.anon_tiers.get(tier, 0)
        var tier_speed: float = AnonTierSystem.TIER_STATS[tier]["speed"]
        total_speed += float(n) * tier_speed
        total_count += n
    # wounded
    total_speed += float(team.wounded) * 0.5
    total_count += team.wounded
    if total_count == 0: return 1.0
    return total_speed / float(total_count)
```

= named 加權 + 各 tier 自己 speed。

## 配置 / 初始化

config（如 `game_sim_test.json`）team.resources 中加：

```json
"anon_tiers": { "平民": 5, "新兵": 3, "老兵": 2 }
```

`game_setup.gd` 讀取並 set `team.anon_tiers`。未指定時：
- 預設全 population - named_count 算入「平民」
- 兼容舊 config

## 不變量

- `sum(anon_tiers.values()) + named_count + wounded == team.population`
- TIER_STATS 各值 [0, 1]
- PROMOTION_EXP_THRESHOLD / PROMOTION_COST 已定義所有 tier 除「菁英」
- `kill_random` 不減 named pop
- `try_promote` 失敗回 0，不部分扣物資
- 菁英升等需 `team.resources["weapon_melee_high"] >= 新菁英總數`（不消耗，只 check）

## 測試

1. **TIER_STATS 屬性正確**：各 tier combat / speed / base_wage 值
2. **total_wage 公式**：5 平民 + 3 新兵 + 2 菁英 = 5*0.5 + 3*1.0 + 2*2.5 = 10.5（暫不考慮 tag mult）
3. **avg_speed**：純平民 team = 0.7；純菁英 team = 1.0
4. **avg_combat_skill**：純平民 = 0.1；純菁英 = 0.7
5. **add_anon / remove_anon**：count 變化正確
6. **add_exp 不超門檻**
7. **try_promote 成功**：條件滿足 → 物資扣、tier 轉移
8. **try_promote 失敗（exp 不夠）**：不變化
9. **try_promote 失敗（物資不夠）**：不變化
10. **try_promote 菁英 + 無 high weapon**：失敗
11. **try_promote 菁英 + 有 high weapon**：成功，weapon 不消耗
12. **kill_random 比例**：100 人 (50 平民 + 30 新兵 + 20 老兵)，殺 10，平均約 5/3/2
13. **kill_random 不殺 named**
14. **transfer_proportional**：from 100 抽 30 → 各 tier 按比例
15. **migration：舊 anon_combat_skill 透過 getter 回 avg_combat_skill**
16. **movement_system._compute_team_speed 用 tier**：純菁英 team vs 純平民 team 速度差 ~30%

## 風險

- **API 破壞性大**：salary / movement / combat / interaction 全要改 call 點，大改動
- **TIER_STATS / PROMOTION_* 魔法數**：需 playtest tune
- **kill_random 仍是 weighted but 對 pop 1000+ 仍快**：O(count × 4) 可接受
- **try_promote 大宗 count 性能**：N 次同邏輯，可接受
- **config migration**：舊 config 無 anon_tiers 欄位需 fallback 全進「平民」
- **anon_exp Dictionary 序列化**：save/load 要支援（既有 save 是？需確認）
- **菁英 weapon req 判定時點**：try_promote 時 check team 持有量，不消耗。如果之後 equipment_system 分發給別人 → 菁英不會「失去身份」（資料層 tier 不變）
- **named 升 anon 時繼承 tier 屬性**：spec 未指定 named 創建路徑。等 named-from-anon 機制 spec 時補：抽 anon 升 named → named 初始 attribute 用該 tier base + randf 微調

## 解決

- team 之間有質量差異（老牌軍 vs 新團不一樣強）
- leader 戰術 skill 影響團隊養成（高戰術 leader 能訓菁英）
- 戰鬥死亡有意義（精銳死了難補）
- anon 經濟複雜度（不同 tier 不同 wage）

## 後續（另 spec）

- tag drift：leader / event 改 tag
- 外交招募流程（投靠 / 雇傭軍 / 直接買高 tier）
- 戰俘處置（賣 / 屠 / 招降，含 loyalty 規則）
- UI 呈現（team panel tier 分布、升等進度條、combat 死亡分檔）
- named 升階機制（從 anon 抽 → tier 決定 named 初始屬性）
- mounts / wagons 速度 bonus（speed_class）
- minor_population → anon 流程細化
