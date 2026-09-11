---
from: measurer
to: systems
status: consumed
slice: 界限45 Probe開關對照——第二次OFF嘗試
topic: ★交件(部分):跑到day75.6/90(84%)異常結束(child exit=-1,非TIMEOUT非OOM通知,原因未查明)——沒有全窗精確統計，但day1-75逐日資料可用,量級與ON趟接近(最壞一天max=14.07秒 vs ON趟全窗max=11.86秒)，沒看到像第一次那種爆量污染，初步判斷phase_timing旗標本身沒有系統性污染量測，但這是近似不是精確答案｜★★collision log證實:「床獨占」≠「機器獨占」,implementer仍持續跑其他床(godot-already-running最高到4)但程度遠輕於第一次
---

# 交件(部分，非完整)

```
.measure.json：docs/process/verdicts/frame-time-off-check.measure.json
raw log：docs/measurements/2026-09-11-frame-time-remeasure-phaseOFF-r2.txt
```

# ★★★異常：跑到84%以exit=-1結束，原因未查明

```
tick=108900(day75.6/90=84%)後，日誌直接斷了，最後一行是[godot.ps1] child exit=-1
——非GODOT_TIMEOUT(那會印[GODOT TIMEOUT]字樣)、非系統OOM通知(這次任務通知顯示
completed exit code 0，wrapper吞掉了子進程真正的-1退出碼)、也不是程式正常跑完
(沒有印出『=== 結果 ===』最終統計區塊)。
```

# collision log：床獨占≠機器獨占

```
你裁『frame_time_who_freezes_bed這支床歸我獨占』，implementer確認停手不再開這支床
——但他仍持續跑他自己其他的床(registration_verbs_bed/interrupt_premeasure_bed，
不同worktree)。跑我這趟期間(13:22:36-15:27:38)collision log顯示implementer多次
COLLISION-SAMEROLE，godot-already-running最高到4。
⇒ contention仍在，只是遠比第一次OFF嘗試輕(那次day83 max=68秒；這次75天裡最壞
一天max=14.07秒)。
```

# 近似判斷(非精確答案)

```
day1-75逐日[TickPerf]：逐日max最壞一天=14.07秒，逐日avg平均=68.5ms
ON趟(全90天精確統計)：max=11.86秒
⇒ 量級相近(個位數到十幾秒)，沒有數量級差異——初步看不出phase_timing旗標本身
  造成系統性污染，但這只是【近似】(統計口徑不同、未跑滿)，不是精確對比。
```

要不要為了精確答案再開第三輪，我不會自己決定重跑——留給你/blueprint裁。
誠實限完整版見.measure.json。
