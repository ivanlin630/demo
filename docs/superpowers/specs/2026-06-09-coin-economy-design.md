# Coin 經濟（Mining + Salary Flow）— Design

> 日期：2026-06-09
> 議題：1 + 2 — coin 憑空生（無真實來源）+ 匿名薪水憑空消失（破壞守恆）

## 背景

當前 coin 流動有兩端缺失：

### Source 端

- 無 coin 來源系統。faction 初始 coin、玩家命令直接給、戰勝 loot — 全是憑空或 redistribution
- 既有 `tile.resources["ore_gold/ore_silver"]` 採集後堆在 team.resources，**無轉換為 coin 的機制**
- mint / 造幣 設施不存在

### Sink 端

- `salary_system._pay_salary` line ~45: `team.resources["coin"] -= anon_wage × anon_count` → coin 消失到 anon 身上但 anon 無儲蓄
- Named NPC salary 進 `person.coin`（既有），不消失
- **匿名薪水 = 憑空 sink**

## 目標

1. **Coin source：mining → mint → coin**
   - `mint` 設施加進 `FACILITY_DEF`（civilian L2+）
   - 居民團 採 ore_gold/ore_silver → 居民團 resources
   - mint facility 每 tick 把 ore 轉 coin → 居民團 resources["coin"]
   - Owner 派人 task=徵收 → 既有 `_resolve_tribute` 拿 coin

2. **Coin sink：anon wage → anon_treasury**（非消失）
   - `TeamData.anon_treasury: float` 新欄位
   - `salary_system._pay_salary` 把 anon_wage × anon_count 沉澱進 treasury（非扣消失）
   - Treasury 隨 pop 比例分配（split / recruit / merge）

3. **升 named 帶 treasury share ×3**
   - 既有 `PersonGenerator.generate_for_team` 升匿名 → named 時
   - 帶走 `treasury / anon_count × 3`（人才出眾加成）
   - 自然產生 named NPC + person.coin 累積

4. **徵用機制（leader 主動 / 自動）**
   - 平時徵用：NPC 依 leader values（貪婪 - 慎重）自動觸發；玩家用 action `extract_treasury`
   - 飢餓徵用：food < 1 天份 → 自動觸發（罰較輕）
   - 罰：stress + loyalty - + unrest（平時重、飢餓輕）

5. **戰敗 loot 按損失比例**
   - `treasury × (戰死 + 俘虜) / total_anon` → winner
   - 全滅 → 100% 給 winner

6. **滅團（非戰鬥）遺財**
   - team.population = 0 → treasury → tile.abandoned_coin
   - 任何 team 抵達 tile → 撿走

## 不在範圍

- **Outpost 公庫獨立結構**（B 方案後續 spec）：特殊資源 + 設施產出歸公庫、居民團只持基本物資
- 慶典 / 賑災事件 sink → 後續 spec
- 賭博、賄賂、奢侈品消費等 person.coin 用途 → 後續 spec
- 商隊跑商劫掠 treasury（A spec 商隊 inventory 已涵蓋）

## 新欄位

```gdscript
# TeamData
var anon_treasury: float = 0.0   # 匿名兵 wage 累積（軍隊類為主）

# HexTileData
var abandoned_coin: float = 0.0   # 滅團遺財，下一訪客撿
```

## FACILITY_DEF 加 mint

```gdscript
# outpost_system.gd FACILITY_DEF 加 entry
"mint": {
    "cost":             { "material": 100, "coin": 50, "ticks": 200 },
    "cap_by_outpost":   { "civilian": [0, 1, 2], "military": [0, 0, 0] },
    "category":         "經濟",
    "trigger_check":    "_check_ore_surplus",
    "leader_pref":      { "貪婪": 0.4, "野心": 0.2 },
    "current_level_key": "mint_level",
}
```

→ civilian L2 可蓋 1 個 mint，L3 可蓋 2 個。
→ AI 評估 `_check_ore_surplus`：有 ore stockpile → 高 priority。

新 tile field：

```gdscript
# HexTileData
var mint_level: int = 0
```

### Mint 轉換邏輯

每 hour 對有 mint 的 tile 跑：

```gdscript
# outpost_system._tick_mint
func _tick_mint(state, tile, team):
    if tile.mint_level == 0: return
    var rate = tile.mint_level × MINT_BASE_RATE   # e.g. 10 coin/hour
    # 用 ore_gold 優先
    var gold_qty = float(team.resources.get("ore_gold", 0))
    if gold_qty > 0:
        var convert = minf(gold_qty, rate / GOLD_TO_COIN_RATIO)
        team.resources["ore_gold"] -= convert
        team.resources["coin"] = float(team.resources.get("coin", 0)) + convert × GOLD_TO_COIN_RATIO
        return
    var silver_qty = float(team.resources.get("ore_silver", 0))
    if silver_qty > 0:
        var convert = minf(silver_qty, rate / SILVER_TO_COIN_RATIO)
        team.resources["ore_silver"] -= convert
        team.resources["coin"] = float(team.resources.get("coin", 0)) + convert × SILVER_TO_COIN_RATIO
```

常數：
```gdscript
const MINT_BASE_RATE: float = 10.0   # coin/hour per mint_level
const GOLD_TO_COIN_RATIO: float = 20.0   # 1 ore_gold → 20 coin
const SILVER_TO_COIN_RATIO: float = 5.0   # 1 ore_silver → 5 coin
```

`_check_ore_surplus` for FACILITY_DEF：

```gdscript
func _check_ore_surplus(state, faction):
    var total: float = 0
    for tid in faction.member_team_ids:
        var t = state.teams.get(tid)
        if t == null: continue
        total += float(t.resources.get("ore_gold", 0)) * 5
        total += float(t.resources.get("ore_silver", 0))
    if total > 50: return 80.0   # 有 ore 庫存
    return 0.0
```

## Salary refactor

`salary_system._pay_salary` 改：

```gdscript
# 既有 anon_wage × anon_count 消失改：
var anon_count: int = team.population - team.named_members.size() - 1
var anon_total: float = team.anon_wage * maxf(anon_count, 0)
team.resources["coin"] = float(team.resources.get("coin", 0)) - anon_total
team.anon_treasury += anon_total   # 沉澱（非消失）
```

## PersonGenerator 升 anon 帶 share

```gdscript
# scripts/simulation/person_generator.gd  generate_for_team 內
# 既有：產生新 named NPC
# 加：算 anon_treasury share
var anon_count: int = team.population - team.named_members.size() - 1
var per_share: float = team.anon_treasury / maxf(anon_count, 1)
new_person.coin = per_share * 3.0   # 升階 × 3 帶
team.anon_treasury -= new_person.coin
```

注意：team.population 不變（同一人從 anon 變 named）。

## 徵用機制

### NPC 自動徵用

```gdscript
# faction_ai_system 加（每 month, salary 同 cadence）
func _consider_extraction(state, team):
    if team.anon_treasury <= 0: return
    var leader = state.persons.get(team.leader_id)
    if leader == null: return
    var greed = float(leader.values.get("貪婪", 0.5))
    var prudence = float(leader.values.get("慎重", 0.5))
    var extract_score = greed - prudence * 0.5
    if extract_score > 0.4:
        var ratio = greed * 0.3   # max 30%
        _extract_treasury(state, team, ratio, "貪婪驅動")
```

### 飢餓自動

```gdscript
# resource_system 或 sim_runner
if food < pop * 2.4 * 1.0:   # 1 天份
    if team.anon_treasury > 0:
        _extract_treasury(state, team, 0.3, "飢餓緊急")
```

### 共用 `_extract_treasury`

```gdscript
func _extract_treasury(state, team, ratio, reason):
    var amt = team.anon_treasury * ratio
    team.anon_treasury -= amt
    team.resources["coin"] = float(team.resources.get("coin", 0)) + amt
    var is_emergency = (reason == "飢餓緊急")
    var stress_pen = (0.05 if is_emergency else 0.15) * ratio
    var loyalty_pen = (0.02 if is_emergency else 0.08) * ratio
    for pid in ([team.leader_id] as Array) + team.named_members:
        var p = state.persons.get(pid)
        if p:
            p.stress = minf(p.stress + stress_pen, 1.0)
            p.loyalty = maxf(p.loyalty - loyalty_pen, 0.0)
    if not is_emergency:
        team.unrest_turns += 1
    print("[Extract] Team%d 徵用 %.0f coin (%s)" % [team.team_id, amt, reason])
```

### Player action

```gdscript
"extract_treasury": _action_extract_treasury,

func _action_extract_treasury(state, _target, pt, _pt_id):
    var ratio = float(state.player_state.get("extract_ratio", 0.0))
    if ratio <= 0 or ratio > 1.0:
        return { "ok": false, "msg": "extract_ratio 必須 0-1" }
    var fai = FactionAISystem.new()
    fai._extract_treasury(state, pt, ratio, "玩家主動")
    return { "ok": true, "msg": "徵用 %.0f%%" % (ratio * 100) }
```

## Encounter 戰敗 loot

`encounter_system.resolve_encounter_end` 加：

```gdscript
# 計算戰損
var anon_lost: int = anon_killed + anon_captured
var total_anon: int = anon_lost + loser.surviving_anon
if total_anon > 0:
    var loot_ratio: float = float(anon_lost) / float(total_anon)
    var loot_amt: float = loser.anon_treasury * loot_ratio
    loser.anon_treasury -= loot_amt
    winner.anon_treasury += loot_amt
# 全滅
if loser.population == 0:
    winner.anon_treasury += loser.anon_treasury
    loser.anon_treasury = 0.0
```

注意：需 encounter resolve 算 `anon_killed` 和 `anon_captured`（既有應該有 tracking）。

## 滅團（非戰鬥）

`sim_runner` 或 `population_system` 偵測 team.population == 0：

```gdscript
func _on_team_extinct(state, team):
    if team.anon_treasury <= 0: return
    var tile = state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)
    if tile != null:
        tile.abandoned_coin += team.anon_treasury
    team.anon_treasury = 0.0
```

撿走：

```gdscript
# movement_system 或 sim_runner 抵達 callback
if tile.abandoned_coin > 0:
    # 若 tile 有 outpost_owner → 只 owner 撿
    if tile.outpost_owner != -1 and tile.outpost_owner != team.team_id:
        return   # 非 owner 不撿
    team.anon_treasury += tile.abandoned_coin
    print("[Coin] Team%d 撿 %.0f 遺財" % [team.team_id, tile.abandoned_coin])
    tile.abandoned_coin = 0.0
```

## Pop 變動時 treasury 分配

### subteam_system.dispatch

子隊離開時帶走 treasury 比例：

```gdscript
# subteam.gd dispatch 既有 frac (pop 比例) 已有
sub.anon_treasury = parent.anon_treasury * frac
parent.anon_treasury -= sub.anon_treasury
```

### subteam_system.merge_teams

合併時加和：

```gdscript
absorber.anon_treasury += absorbed.anon_treasury * frac
absorbed.anon_treasury -= absorbed.anon_treasury * frac
```

### population_system._create_overflow_team

```gdscript
ot.anon_treasury = origin.anon_treasury * frac
origin.anon_treasury -= ot.anon_treasury
```

### player_command_system.recruit_anon

從 source team 拉 N anon 過來：

```gdscript
var source_anon = source.population - source.named_members.size() - 1
var per_share = source.anon_treasury / maxf(source_anon, 1)
var transferred = per_share * recruited_count
source.anon_treasury -= transferred
player_team.anon_treasury += transferred
```

## 不變量

- `anon_treasury >= 0` 永遠成立
- 全 sim treasury + abandoned_coin 守恆（除非 NPC 不存在或 sim 重置）
- mining → coin 是真實 source（守恆守不住此處外，但這是設計）
- 戰敗 loot 按比例，不超出 loser treasury
- 升 named ×3 share 不超出 treasury / anon_count

## 測試

`headless_test.gd`：

1. **anon_treasury 欄位**：預設 0
2. **abandoned_coin 欄位**：預設 0
3. **salary wage → treasury**：付 wage → treasury 累積
4. **PersonGenerator 升 anon 帶 ×3**：treasury=100, anon=10 → 升 anon → person.coin = 30, treasury=70
5. **NPC 自動徵用（貪婪 leader）**：貪婪 0.8 → 自動 _consider_extraction → 徵用發生
6. **NPC 不徵用（慎重 leader）**：慎重 0.9 → extract_score < 0.4 → 不徵用
7. **飢餓徵用**：food < 1 天份 → 自動 0.3 ratio 徵
8. **Player extract_treasury**：玩家 set ratio=0.5 → treasury 抽 50%
9. **Encounter 戰敗 loot 比例**：戰前 anon=20, lost=5 → ratio=0.25, winner 拿 25%
10. **Encounter 全滅 → 100% loot**：loser.population = 0 → winner 拿全 treasury
11. **滅團遺財 → abandoned_coin**：team.population=0 → tile.abandoned_coin = treasury
12. **撿遺財**：team 抵達 tile.abandoned_coin > 0 → 自己 treasury 收
13. **撿遺財限 outpost owner**：tile 有 outpost_owner，非 owner 不撿
14. **Mint facility 註冊**：FACILITY_DEF.has("mint")
15. **Mint 轉 ore → coin**：tick 後 ore_gold 減、coin 增
16. **Subteam dispatch 帶 treasury 比例**：parent treasury=100, sub 取 30%
17. **Recruit anon 帶 share**：從 source 拉 5 anon → 帶相應 treasury

## 風險

- **既有 person.coin 用途模糊**：升 named 帶 share 後 person.coin 累積，但無用處（後續 spec 賭博/賄賂等）
- **Mint coin → 居民團 resources，owner 收稅才拿** → 居民團持續累 coin。本 spec 不處理（後續 公庫 spec）
- **encounter resolve 算 anon_killed / anon_captured 既有資料**：需確認
- **Subteam dispatch / merge / recruit 多個 site 修改 treasury 分配**：易遺漏，spec 內列清楚
- **Abandoned_coin 撿走規則「outpost owner 優先」** 需在 movement / arrival callback 實作

## 解決的 known_issues

- Coin 憑空消失（匿名 wage sink） → 沉澱 treasury
- Coin 憑空生（無 source） → mining + mint 真實來源
- 戰敗物資不分配 anon coin → 按比例
- 滅團物資憑空消失 → 留 tile abandoned_coin
- NPC team coin 累積無消耗 → 升 named 帶 share 自然 drain

## 後續延伸

- **Outpost 公庫獨立 spec**（B 方案）：特殊資源 + 設施產出歸公庫、居民團只持基本物資
- **慶典 / 賑災事件** sink
- **賭博、賄賂、奢侈品** person.coin 用途
- **商隊 inventory 劫掠 treasury**（A spec 已涵蓋部分）
- **Mint 自動 trigger conditions** 細化
