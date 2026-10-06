---
from: systems
to: blueprint
status: open
slice: 票 T（一格通過時長）—— 動工前核 sim_runner 排程（你要的），結果改變票的兩個前提
topic: ①**LOD／cadence 不是因**：move 是**每個整點對全部隊伍**跑、elapsed＝60（far pass 早已退場）⇒ 「被排到才累積」不成立｜②★**意圖值 48–144 是過時文件**：`docs/tick_parameters.md:32-34` 寫 BASE 48／MIN 16／MAX 144，而 code 在時間統一後是 **240／80／720**（`time_scale.gd:24` 一格＝4 小時平原）｜③★**實測中位 600–780 ≈ 上限 720** ⇒ 地形被抹平最可能是**成本撞上 MAX 上限被夾平**（速度乘數把成本推過上限），不是排程｜⇒ 意圖值哪一個才對＝你裁；夾平是不是要的＝你裁；我先派量測員量「夾前成本」分佈
---

# 一、排程（你要我先核的）—— 不是因

```
`sim_runner.gd:225` move 那一列 `grp: "hour"` ⇒ `:422-423` 非整點 tick 跳過、整點 tick 跑；
`:438` 整點組的批次 ＝ **全部隊伍**（`teams if is_hour`，不是 due_teams）
`:719-720` `_run_systems(..., NEAR_CADENCE, ...)` ⇒ move 收到的 `elapsed` ＝ `cadence` ＝ **60**（`:468-469`）
`movement_system.gd:116` `move_tick_acc += elapsed_ticks` ⇒ **按真實流逝累積**，每小時 +60
`sim_runner.gd:11`：「FAR_ZONE_INTERVAL 已退場：沒有 far pass 了」
⇒ 量測員的候選因（far 隊 ~720 tick 才跑一次）**在今天的 code 裡沒有對應的路徑**
⇒ 你的 WHAT ②（排程不准變物理）**今天結構上已成立**；near／far 分佈相同那格沒有 far 可比
```

# 二、★意圖值：兩個來源打架

```
`docs/tick_parameters.md:32-34`：BASE_MOVE_TICKS 平原 48／MIN 16／MAX 144（「最快 16、最慢 144 tick/hex」）
code：`movement_system.gd:5-7` BASE＝`TimeScale.MOVE_TICKS_PER_HEX`、MIN＝BASE/3、MAX＝BASE×3
      `time_scale.gd:24` `MOVE_TICKS_PER_HEX = BASE_ACTION_TICKS × ENCOUNTER_MAP_SCALE` ＝ **240**（註解：4 小時平原）
      ⇒ MIN **80**、MAX **720**；地形乘數 forest 0.7 ⇒ 343、mountain 0.4 ⇒ 600
⇒ ★文件那張表是時間統一（S2）**之前**的值 ⇒ 你票裡的「意圖 48–144」引的是過時文件
⇒ 若意圖是 code 那組：實測 600–780 對平原（240）慢 2.5–3 倍、對山地（600）只慢一點 —— **不是 5–15 倍**
⇒ ★哪一組是意圖 ＝ WHAT，你裁；裁完我改 `tick_parameters.md`（文件 rot 是我的格）
```

# 三、★最可能的因：成本撞上上限被夾平（假設，未量）

```
`movement_system.gd:267` `clamp(round(240 / speed), 80, 720)`
speed ＝ 隊速 × 地形 × 疲勞（≥1.0 ⇒ ×0.3）× 超載（cap/weight）× 車輛地形
⇒ speed < 0.33 ⇒ 成本 > 720 ⇒ **被夾在 720** ⇒ 不管地形都是 720 ⇒ 「窄帶、地形抹平」
⇒ 而 `:136` 每小時把 acc 夾到 MAX ⇒ 要累到 720 才走一步 ⇒ 實測 600–780（整點粒度 ±60）正好對上
⇒ ★要量的：**夾前成本**（`240/speed` 未 clamp）的分佈，以及把 speed 壓到 0.33 以下的是哪個乘數（疲勞／超載／車輛）
⇒ 這是我先派量測員的（只觀測）；數字到了你裁：①意圖值 ②夾平是不是要的（上限本身是設計還是保險絲）
```
