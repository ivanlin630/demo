# Hand Back: LoyaltyBank 單一 owner（Pattern B 第二池）

## 實作摘要

`loyalty` 設單一 owner = `LoyaltyBank`（承 `UnrestBank` 模式）。scripts/simulation/** 全部 loyalty 寫者路由經 banker，禁裸 `p.loyalty =/+=/-=`。

### LoyaltyBank API（`scripts/simulation/loyalty_bank.gd`，static class_name）
```gdscript
static func adjust(p: PersonData, delta: float, reason := "", cap := 1.0) -> void
    p.loyalty = clampf(p.loyalty + delta, 0.0, cap)   # delta 寫者，cap 保各 site 上限

static func set_baseline(p: PersonData, value: float, reason := "") -> void
    p.loyalty = clampf(value, 0.0, 1.0)               # lifecycle 基線（蓄意絕對 set）
```
- `adjust`：所有相對變化（`+=`/`-=`/`clampf(+d)`/`minf`/`maxf`）。`cap` 預設 1.0；唯一非 1.0 = salary overpay（`cap=MAX_LOYALTY=0.95`）。
- `set_baseline`：lifecycle 絕對賦值（split/defect/recruit/init/creation）。clamp [0,1]。
- `reason` 目前僅供審計語義（未落 log，與 UnrestBank 一致）。

### 改檔（每檔一行）
- `scripts/simulation/loyalty_bank.gd` — 新建 banker。
- `scripts/debug/headless_test.gd` — 加 `_test_loyalty_bank` 並註冊（adjust/cap/clamp/set_baseline 驗）。
- 其餘 13 檔 = 寫者路由（見下）。

## 路由清單（25 site / 13 檔；adjust 19 + set_baseline 6 + overpay 1 含於 adjust）

### adjust()（相對變化，19 處）
| 檔案 | 原數學 | reason | 備註 |
|---|---|---|---|
| salary_system.gd:68 | `minf(+ (ratio-1)*OVERPAY_BONUS, MAX_LOYALTY)` | `"overpay"` | **cap=MAX_LOYALTY(0.95)** |
| salary_system.gd:73 | `-= (1-ratio)*SALARY_LOYALTY_PENALTY` | `"underpay"` | **無 clamp→clamp**（見下） |
| reaction_system.gd:26 | `clampf(+ alignment)` | `"goal_alignment"` | |
| reaction_system.gd:76 | `clampf(+ loyalty_delta)` | `"attack_defeat"` | |
| reaction_system.gd:254 | `minf(+0.01)` | `"comply"` | |
| resource_system.gd:333 | `maxf(-0.02)` | `"hunger"` | |
| faction_ai_system.gd:1399 | `maxf(- loyalty_pen)` | `"faction_strain"` | |
| interaction_system.gd:410 | `maxf(- loyalty_loss)` | `"extort"` | |
| interaction_system.gd:735 | `-= yi_qi*0.08` | `"atrocity"` | **無 clamp→clamp** |
| interaction_system.gd:982 | `minf(+0.02)` | `"pacify"` | |
| npc_combat_system.gd:266 | `-= (1-yi_qi)*0.05` | `"betrayal"` | **無 clamp→clamp** |
| sim_runner.gd:299 | `-= FATIGUE_LOYALTY_PENALTY` | `"fatigue"` | **無 clamp→clamp** |
| player_command_system.gd:618 | `maxf(-0.15)` | `"faction_leave"` | |
| player_command_system.gd:662 | `maxf(-0.3)` | `"faction_disband"` | |

### set_baseline()（lifecycle 絕對，6 邏輯 site → 含 split 6 分支共 11 物理行）
| 檔案 | 值 | reason |
|---|---|---|
| event_unrest_split.gd:122-127 | 0.5/0.65/1.0/0.25/0.5/0.9 | split_hard/split_soft/split_leader/conquered/voluntary/master |
| reaction_system.gd:276 | 0.0 | `"defect"`（N3_defect） |
| player_command_system.gd:1317 | 0.5 | `"recruit"` |
| game_setup.gd:208 | 1.0 | `"init"`（leader creation） |
| game_setup.gd:485 | `p_cfg.loyalty` (def 0.8) | `"init"`（config person） |
| person_generator.gd:54 | 1.0 / randf(0.5,1.0) | `"init"` |
| recruit_tutorial.gd:20 | 0.9 | `"init"` |

**排除**：`headless_test.gd` 內 `p.loyalty = N` test fixture（測試 setup，不路由）。

## 無 clamp→clamp 行為影響

4 處原本無下界、可推 loyalty 負值；路由後 clamp 至 0.0：
- `salary_system.gd:73`（underpay）
- `interaction_system.gd:735`（atrocity）
- `npc_combat_system.gd:266`（betrayal）
- `sim_runner.gd:299`（fatigue）

**影響評估 = 正確化，無 red 測試**：既有 loyalty/defect/salary/義氣/split 測全綠（無測依賴負 loyalty）。loyalty ∈ [0,1] 本就是語義約束（其他 99% 寫者皆 clamp），這 4 處是漏網裸寫，clamp 是修正而非破壞。defect 門檻讀 loyalty 比較，floor 在 0 與負值在 defect 判定上等效（皆 < 任何正門檻）。2 年 world_sim 無 mass-defect 異常 → 確認無行為退化。

## grep 驗證

`Grep \.loyalty\s*(=|\+=|-=)` over `scripts/simulation/**` → 僅 `loyalty_bank.gd` 兩行（owner 本體）。無殘留裸寫。

## 2 年 world_sim 結果

`world_sim.gd`（max_ticks=172800 = 2 年，純 NPC）：
- 跑滿 月24 / tick 172800，`=== world_sim DONE ===`。
- **0 InvariantViolation、0 SCRIPT ERROR、無世界全滅**，存活隊 5（月12→月24 穩定）。
- loyalty 分佈健康且分歧（0.0–0.9）：高義氣信義隊 loy0.8–0.9，中性 0.5–0.7，受壓 leader（str1.0/fear1.0）落 0.0 = 累積懲罰正常收斂，非 clamp 異常。
- defect/split 事件 5 起（紀律失效脫離 + 1 faction 脫離），跨 2 年量級正常，無 clamp 觸發的批量叛離。

## 回歸

headless_test：SCRIPT ERROR=0、`=== DONE ===` ×1、`loyalty bank OK`、InvariantAudit OK ×3（population/faction/subteam）。coin_eq 守恆 assert 過（無 assertion 失敗）。

## 連動風險 / 待主 session

- **無已知行為連動風險**：純 plumbing 重構，數學保留，clamp 正確化已驗。
- **Pattern B 剩餘 banker（未在本 arc 範圍）**：
  - `resources` / `anon_treasury`：守恆敏感（coin_eq/InvariantAudit 管），需與守恆路由協調，不可純 clamp 化。
  - `outpost_owner`：所有權欄位，屬 ownership graph，另案。
- `reason` 參數目前不落 log（與 UnrestBank 對齊）；若日後要 loyalty 審計流，可在 banker 內加 Probe.bump，集中一處。
