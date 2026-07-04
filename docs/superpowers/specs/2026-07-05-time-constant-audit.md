# 時間常數統一稽核 — 枚舉 + 分組（time-scale wave 步驟1）

> 藍圖 `2026-07-05-time-unification-wave`。wave 步驟1=枚舉全時間常數→分組表→藍圖裁骨架值。
> 枚舉子agent 掃主樹 `scripts/`（忽略 worktree）。~80 常數 / ~21 骨幹檔（+9 rate 檔）=符藍圖 ~84/21。
> **關鍵事實**：(1) 無既有 `TimeScale` 骨架（grep 零命中）。(2) 兩個根字面=`TICKS_PER_DAY`(240,world_state:4) + `BASE_ACTION_TICKS`(10,encounter:13 遭遇戰動作粒度)。(3) 導出半成：`TICKS_PER_*` 家族已導出✓，但大量 cadence/timeout=**裸 tick 字面**（720/360/240/1440…）未走語意天數。(4) **`WORLD_SPEED_MULT=5` 唯一讀取站=`BASE_MOVE_TICKS` 導出式**（movement:5）——它只直接縮移動格耗;food/fatigue 的 ÷24/×24 是**獨立手校痕跡**（補償快移動,非讀 mult）。

## 分組（藍圖裁骨架用）

### 骨架根源（TimeScale 應單源涵蓋）
| 常數 | 值 | 現況 |
|---|---|---|
| `TICKS_PER_DAY` | 240 | 根字面（world_state:4） |
| `TICKS_PER_HOUR/MONTH/SEASON/YEAR` | 10/7200/21600/86400 | 已導出✓ |
| `SECONDS_PER_TICK` | 360 | real-time 橋（觀看用） |
| `BASE_ACTION_TICKS` | 10 | 第二根（遭遇戰粒度,encounter:13）→ 種 BASE_MOVE_TICKS |

### 受污染組（×5 校準痕跡；骨架 ×5→1 後**必重校**）
| 常數 | file | 污染 |
|---|---|---|
| `WORLD_SPEED_MULT` | movement:4 | =5，污染源本體 |
| `BASE_MOVE_TICKS`鏈(+MIN/MAX) | movement:5-7 | =BASE_ACTION×MAP_DIAM/5=48;假設×5→0.2天/hex |
| path ETA | path_system:154/207 | ×BASE_MOVE_TICKS 承污染 |
| founding/trade timeout | faction_ai:1251/1254 註 | 距離估承 BASE_MOVE 污染 |
| `FOOD_PER_PERSON/MOUNT_PER_DAY` | resource:3/8 | ÷24 手校（補快移動不餓死） |
| `FATIGUE_*_PER_DAY` | sim_runner:7-8 | 註「原值×24」校準痕 |

### 連動組（移動-遭遇戰不變量，藍圖 invariant #2）
`BASE_ACTION_TICKS`(10)→`BASE_MOVE_TICKS`(48)→`MAP_RADIUS/DIAMETER`(encounter:174)。**核心 debt**：`move_tick_acc += TICKS_PER_HOUR`（movement:76 硬編）× far 每 `FAR_ZONE_INTERVAL`(100) 才跑 → far 移速稀釋 10×（=詭異感+物流癱根，movement:29-34 已定罪）。LOD cadence（`FAR_ZONE_INTERVAL`/`NEAR_CADENCE`/`LOD_NEAR_RADIUS`）與此交纏。

### 後勤組（×5 真根①「走一格餓死」）
`FOOD_PER_*`、`PROVISION_DAYS`(10)、`FORAGE_FLOOR_DAYS`(1.5)、`FAMINE_GRACE_DAYS`(7)+`*_DEATH_RATE`、`HUNGER_*_PER_DAY`、`FOOD_RESERVE_TICKS`(20,單源 trade_valuation:54)、`AID_RESERVE_DAYS`(14)、`CAPTIVE_FOOD_RATE`、`FOOD_BUY_DAYS`(4)/`_TARGET`(8)、`RESTOCK/DESPERATION/SURPLUS_DAYS`(5/3/7)、`HUNGER_SLIDE_DAYS`(7)、`FOUND_FOOD_SURPLUS_DAYS`(7)、`BOOTSTRAP_DAYS`(50/35)。**多帶「天」語意但硬編 float,可導出。**

### AI cadence/timeout 組（×5 真根②「行軍降頻」餵此；該走語意天數）
- **已導出✓**（=N×TICKS_PER_HOUR）：LADDER_EVAL/GOAL_CHECK/STRATEGIC/ALLIANCE/COLLECT/FACTION_UPDATE/INFRA_INTERVAL、BETRAY_CHECK、REJECT_COOLDOWN、SALARY、SCOUT_TIMEOUT、CAPTIVE_CADENCE、OVERFLOW_CHECK。
- **裸 tick 字面✗（該收編）**：`INDEP_STRATEGY/PROSPERITY_CADENCE`(720)、`_MILITARY`(360)、`THREAT_CADENCE`(240)、`RESIDENCY_CADENCE`(720)/`_COOLDOWN`(1680)、`TRADE_TIMEOUT`(1440)/`_PER_HEX`(120)、`OCCUPY_ETA_MAX`(720)、`FLEE_TIMEOUT`(=5×240)、`CONTACT/OWNER_CHANGE/URGENCY/WARNING/SURVIVAL_RECOVER_DAYS`、政令/使節 `2*TICKS_PER_DAY`、`AI_ETA_LIMIT`(1200)、`OUTPOST_TAKEOVER_DAYS`(3)。

### 觀看組（×5 真根③「圖世界跑快」→ GUI 播放，不碰物理）
`TICKS_PER_SECOND`(4,turn_controls:4)、`_tick_interval`、`TICKS_PER_TURN`(24,sim_bridge:4)、`DUMP_CHUNK_TICKS`(300)、`SECONDS_PER_TICK`(橋)。**已與物理分離,拆 ×5 後這組不動。**

### TTL/衰減/成長/建造/製造組（含時間，該語意單位）
TTL：`MSG_TTL_SHORT/MEDIUM/LONG`(1680/3360/7200)、`MSG_TTL_BY_TYPE`、`CRED_AGE_FULL_DECAY`(30天)、claim 新鮮度(1/3月)、inquiry(10天)、player_trade memory(**裸1000**)。衰減：`TIME_DECAY_PER_HOUR`(0.005)/`_PER_TICK`(導出)。成長/生育：`MATURE_RATE`(0.1/月)、`BREED_BASE_CHANCE`、`STABLE_*_PER_DAY`、`MINT_BASE_RATE`、`manufacturing *_RATE`×13、`SKILL/BASE_GROWTH`。建造：`BUILD_TICKS`、`CONSTRUCTION_TIMEOUT`(30天)、`CAMP_BUILD_TICKS`(240)。健康：`HP/BLOOD_REGEN_PER_TICK`、`HUNGER_BLOOD_DRAIN_PER_TICK`、`FATIGUE_*`。

### 裸字面待收編（無名硬編）
`1000`(player_trade:96 記憶過期)、`800`(observer/encounter STUCK)、`300`(DUMP_CHUNK)、faction_ai 內 `720/360/240/1440/1680/120`、`5*240`(FLEE)、`2*TICKS_PER_DAY`(政令/使節)。

### 測試/歸檔（非模擬 gate）
`debug/*` 跑測窗（`months×TICKS_PER_MONTH`）；`headless_test:3362-3376` 時間不變式 assert（MONTH=DAY×30、`TICKS_PER_DAY % NEAR_CADENCE==0`）——**wave 後這些 assert 要對齊新骨架**；`ui_logic_test:77` 局部 `TICKS_PER_DAY:=24.0`(≠240,陳舊測試,獨立 bug 標記)。

## 藍圖待裁（骨架具體值，HOW 我接）
1. **×1 下「移動 1 world-hex = 幾 tick」**？（現 ×5=48tick=0.2天;×1 連動=BASE_ACTION×MAP_DIAM=240=1天/hex？）→ 定 invariant #2 連動係數。
2. **遭遇戰地圖尺度**（`MAP_RADIUS`=12/`MAP_DIAMETER`）進連動式的值。
3. **AI cadence 語意天數**：裸 720/360/240 等重述為「N 天」的 N（多數=行軍/評估頻率,②行軍降頻餵此）。
4. **後勤①**：走一格糧耗 vs carry vs 沿途補給——哪缺（需 measure「走一格餓死」真帳,可併三平行 measure）。
5. 觀看組確認不動（已分離）。

裁完 → HOW：TimeScale 單源類 + 3 時間不變量入 invariants + 裸 tick→語意導出 + CI 掃 + ×5→1 連動 + 重校。
