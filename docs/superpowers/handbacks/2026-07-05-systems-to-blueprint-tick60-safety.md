---
from: systems
to: blueprint
status: consumed
topic: tick60運算頻率安全證(硬前置PASS)——唯1個O(N)真違規(_get_near/far每tick無gate需cadence化,順帶餵A-arc);10裸cadence/timeout常數導出+eta/240+FLEE硬編240=時間閘該抓;★PRISONER_CHECK藍圖誤判(凍結遭遇戰框不爆,measure翻);取整全除盡唯eta/240漂移;空間維度散落點=game_setup/encounter;建議切60=3機械修後安全
---

# tick-60 運算頻率安全證（硬前置）+ 空間維度散落 + 取整驗

實掃碼證（別信初掃，measure-first）。**硬前置=運算頻率安全 → PASS（60 不爆頻，1 個 O(N) 修點）。**

## ① 運算頻率 = per-tick 有界閘（你釘清：非維度，是既有不變量檢查）
**每 tick 無條件跑僅 5 項**（sim_runner `_advance_tick_body`）：
| 項 | O() | 判 |
|---|---|---|
| `_step1_advance_time`/`get_speed_mult`/`get_vision_mult` | O(1) | 廉價安全（後二浪費=結果只 gate 內用） |
| **`_get_near_teams`+`_get_far_teams`(sim_runner:152-153)** | **O(N_teams)×2** | **★唯一真風險：每 tick 無 gate 全掃 teams,結果只 gate 內消費（60 下 60:1 純浪費）→ 需 cadence 化** |
| `_step_captives`/`_step_cleanup_extinct` | O(1) early-out | 安全（內部 gate/早退） |

- **near/far 全 pipeline**（vision/move/faction_ai/…）= **cadence-gate 內**（`%NEAR_CADENCE`/`%FAR_ZONE_INTERVAL`，隨 TICKS_PER_HOUR 縮放）→ **60 下同真實頻率、運算量不變**。你初掃「多數安全」= 對。
- **唯一修**：`_get_near/far_teams` 搬進各自 gate = 零行為變 + 消滅 ×6 浪費 + **順帶餵 A-arc**（O(N) per-tick 正是 O(N²) 幫兇之一）。
- **附帶注意**（非爆頻，perf 面）：60 下 movement 多格迴圈 `max_steps=TICKS_PER_HOUR/MIN_MOVE_TICKS`：A1(MIN=16)→3、A2(MIN=80)→1。A1 下每 near-move ×3 A* 呼叫（gate 內同頻但單次貴）；A2 反無此放大。

## ② 時間量必導出閘（你釘清：裸 tick 常數=閘該抓的違規）
**10 個裸 cadence/timeout 常數**（不動則 60 下爆頻/時長漂）→ 全導出 `N×TICKS_PER_HOUR` 或 `N×TICKS_PER_DAY`：
- 爆頻×6（cadence 間隔）：`INDEP_STRATEGY/PROSPERITY_CADENCE`(720)、`_MILITARY`(360)、`THREAT_CADENCE`(240)、`RESIDENCY_CADENCE`(720)。
- 時長÷6（timeout/cooldown）：`RESIDENCY_COOLDOWN`(1680)、`TRADE_TIMEOUT`(1440)/`_PER_HEX`(120)、`FLEE_TIMEOUT`(5×**240 硬編**)、`OCCUPY_ETA_MAX`(720)。
- **`FLEE_TIMEOUT` 額外 bug**：`5*240` 用硬編 240 非 `TICKS_PER_DAY`→改根也不跟。
- **★`PRISONER_CHECK_INTERVAL=5` 非違規**（你點名的雷）：measure 翻——它 gate `encounter_tick`（遭遇戰內部回合，錨凍結 `BASE_ACTION_TICKS`），**活在凍結遭遇戰 time-frame，與世界時鐘無關 → 60 下不爆**。你「0.5h→5min」是 encounter-tick 誤映 world-clock 的類別錯（同 PRISONER 這類遭遇戰粒度常數全免動）。

## ③ 取整驗（60 下 TICKS_PER_DAY=1440）
- 整數除法全除盡：`/24`=60✓、`/4`=360✓、`TICKS_PER_*` 乘法✓、float `day_fraction` 自動縮放✓。
- **唯一漂移**：`faction_ai:190 eta/240.0`（硬編 240）→ 60 下天數 ×6 高估。改 `/TICKS_PER_DAY`。
- headless time assert（MOVE=48/OVERFLOW=DAY/MONTH 導出）動根後對齊。

## ④ 空間尺度維度（你升格=矩陣新維度，散落點）
- **時間-空間橋**：`MOVE_TICKS_PER_HEX = BASE_ACTION(10)×MAP_DIAMETER(24)/mult` 錨遭遇戰根（無 TICKS_PER_HOUR 項）→ 一格真實時長 = `MOVE/TICKS_PER_HOUR` = 60 下 240/60=**4h/格**（你要的據點密度合理化;「1天/hex」語意隨解析度變=預期效果非 bug）。
- **空間常數散落**（world-hex，與時間正交、各自硬編）：`game_setup:66/73/74`（config `map.radius`/`outposts.total_count`/`min_spacing`）、`encounter:174/175`（MAP_RADIUS/DIAMETER）、`SPAWN_RADIUS`。
- **統一方向**（你的維度原則）：據點密度/min_spacing/radius 從遭遇戰錨+一格真實距離連動導出，非各自硬編。**強制閘掃裸空間常數**。已把「空間尺度骨架」不變量+此散落清單入 `invariants.md`（新維度 family，enforce 起步）。

## 建議：切 60 = 3 機械修後安全
```
修1 _get_near/far_teams 搬進 gate（per-tick有界閘,零行為,順餵A-arc）
修2 10 裸 cadence/timeout 導出 TimeScale.days/hours（時間閘）+ FLEE 硬編240 修
修3 faction_ai:190 eta/240.0 → /TICKS_PER_DAY（取整漂移）
   + headless time assert 對齊新根（1440/60）
→ 動根 TICKS_PER_DAY 240→1440（=TICKS_PER_HOUR 10→60）
```
- 這 3 修 = 你框架的「時間量必導出閘 + per-tick 有界閘」直接應用，非新工程。多為零/小行為變（修1零、修2/3 校正）。
- **切 60 本身改世界移速真實時間×6（旅行時長÷6）= 你要的據點密度效果**——但這與 A2（×5→1）疊乘：**建議 60 切換併入 A2 landing**（都動移動時間尺度,一起重校 gen/承載力,免二次餓死潮/二次 gen 重校）。或先做 3 機械修（安全,可獨立 slice）、60 根值切換綁 A2。你裁序。

## 待你
- 全 tick 表已擴進 `time-constant-audit` doc（導出✓/裸⚠/取整）+ 頻率安全分類。
- 裁：3 機械修 = 獨立 slice 先做？60 根切換併 A2 還是獨立？空間維度統一 = 本 arc 落地到哪（just radius 反推 vs 全連動導出）？
- A2/carrier/QA 物流驗不擋、平行。
