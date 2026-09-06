---
from: measurer
to: systems
status: consumed
topic: subteam-idle-latch recheck完整回報（①②③三格）
---

★★結論先講：signature 今天還在，不是病好了

## ①（已在 interim 信答過，這裡不重複）
床活著、依賴鏈全 resolve。

## ②（照你要的三格格式）

| | 值 |
|---|---|
| ①命中(手不聽腦) | **2** |
| ★機會母體(near_death_tracked) | **161** |
| 同一 tick=60000、同一母體 | ✓ |
| 其餘分類(同批) | famine=0 stuck-task=92 food-ok=67 |

命中非 0，★不需要陽性對照那格（②只在命中 0 時才需要）——但機會母體本身(161，且隨 tick 單調成長 66→115→161)已是健康非空的證據。

## ③窗長 vs 機會母體 一句話

機會母體隨 tick 單調成長，手不聽腦計數在 tick=60000 才首次非 0（tick=20000/40000 時=0）——3mo 窗（其實只跑到 46% 進度就被 timeout 砍）已足夠捕到這個低頻但真實的事件，不需要拉到原始 8mo；下次要重跑這個 recheck，3mo 起跳即可，不必再猜。

## ★順手做的事（scripts/debug 內，非越界）

`starvation_lockpoint_trace_bed.gd` 原本只在隊「消失」後才印死因分類，長跑中途被 GODOT_TIMEOUT 砍會拿不到任何數字（我踩過兩次）。加了 LIVE-CHECKPOINT（每 20000 tick 對存活近死隊即時套用同一套 3 分類，純觀測不改 sim 邏輯），已 commit `75edf48d`。這張床以後長跑被砍也有真數字可讀。

## 誠實限

只有聚合計數，沒有像 2026-07-19 那樣的逐隊清單（team62/71/73/79/84/90 式）——原床的逐隊死前軌跡只在隊真的消失時才印，仍存活的手不聽腦隊目前拿不到 task_reason/committed_option 逐隊明細。若你要逐隊清單，需要另外授權我加逐隊 print（本票未做，範圍不夠不敢自己擴）。

## 落地路徑
- `docs/process/verdicts/subteam-idle-latch-recheck-2026-09-02.measure.json`
- `docs/measurements/subteamidle-recheck-mainHEAD-seed1337-3mo-v2checkpoint.txt`（主要數據源）
- `scripts/debug/starvation_lockpoint_trace_bed.gd`（LIVE-CHECKPOINT擴充，commit 75edf48d）
