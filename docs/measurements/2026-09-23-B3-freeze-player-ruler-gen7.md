# B3 玩家絕對尺——凍結頻率（世代 7）

派工：`docs/superpowers/handbacks/2026-09-23-systems-to-measurer-B3-absolute-player-ruler-on-generation-7.md`
規格：`docs/superpowers/handbacks/2026-09-23-systems-to-measurer-B3-exact-sheet-path-and-verdict-line.md`

床：`scripts/debug/freeze_sample_bed.gd`｜窗：12 天（17280 tick）｜config：warring_states
樹：main @ `1da21961d`（≥ `22ac1b096`，世代 7；世代 7 指紋 `763e9ee9…`）
命中判準：`dt > SimRunner.FRAME_BUDGET_US`（2.0 秒）｜PASS 判準：over2s 發生天數 ≤ 1／日 且 p99 < 1000ms

## 判決行

```
[B3-FREEZE] gen=7 seed=1337 days=12/12 over2s_days=7/12 p99_ms=1161 verdict=FAIL
[B3-FREEZE] gen=7 seed=42   days=12/12 over2s_days=5/12 p99_ms=1052 verdict=FAIL
```

## 硬體戳 / 開跑前 FreeMB（wrapper 印，逐字照抄）

```
seed1337: [HW] cpu=AMD Ryzen 7 5800X3D 8-Core Processor cores=8 threads=16 mem_free=15.9GB/31.9GB
seed42  : [HW] cpu=AMD Ryzen 7 5800X3D 8-Core Processor cores=8 threads=16 mem_free=14.5GB/31.9GB
```

## 兩顆種子細節

| seed | 跑滿天數 | 總幀數 | >2s 事件總數 | 發生天數 | median | p90 | p99 | max |
|---|---|---|---|---|---|---|---|---|
| 1337 | 12/12 | 17280/17280 | 107 | 7/12（day 6-12） | 250us | 420us | 1161329us | 3970811us |
| 42   | 12/12 | 17280/17280 | 59  | 5/12（day 8-12） | 250us | 431us | 1051815us | 4151333us |

raw logs：
`docs/measurements/freeze-sample-12days-gen7-seed1337.log`
`docs/measurements/freeze-sample-12days-gen7-seed42.log`

## ★誠實限（先寫，非事後補）

```
・兩顆種子只能答【方向】：兩者都落在後半窗(day6+／day8+)才開始出現>2s事件、且都遠超p99<1s門檻
  ⇒ 兩顆方向一致(都FAIL、都在遊戲進行到中後段開始出現)，不是洗牌，是訊號
・時間量跨機不可比：本輪只在同一台HW-2上跑，不做跨機/跨代比較，[HW]戳已附
・母體非0(兩顆都有>0事件)，不是「沒事件」也不是「沒跑到」——17280/17280全部跑完
```

## >2s 事件原始清單（不達標，逐筆列出——不是「再跑一次才知道」）

seed1337（107 筆，逐筆列於）：`docs/measurements/B3-freeze-list-seed1337.txt`
seed42（59 筆，逐筆列於）：`docs/measurements/B3-freeze-list-seed42.txt`

摘錄（seed1337 前 10 筆／後 5 筆，完整見上方檔案）：
```
tick=8400  day=6  dt=2.139s
tick=8940  day=7  dt=2.582s
tick=9540  day=7  dt=2.253s
tick=9600  day=7  dt=2.309s
tick=9660  day=7  dt=2.415s
...
tick=17040 day=12 dt=2.161s
tick=17100 day=12 dt=2.515s
tick=17160 day=12 dt=2.419s
tick=17220 day=12 dt=2.516s
tick=17280 day=12 dt=3.523s
```

## 結論

```
两颗种子皆 verdict=FAIL（p99 遠超 1000ms 門檻，且 >2s 事件發生天數皆超過「≤1／日」的絕對尺）
⇒ 那張延後票（defer token 待 blueprint/systems 對照 defers.tsv）依此結果開成真票，不刪除
```
