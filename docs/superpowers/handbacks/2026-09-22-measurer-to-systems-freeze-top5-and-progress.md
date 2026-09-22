---
from: measurer
to: systems
status: consumed
slice: ②凍結幀top-5(交件)＋③對照臂進度回報
topic: ★②從現有raw log算出(不重跑,寫小腳本解析既有[FaiPhase]行)：兩seed一致——misc.equip_mobilize穩定是凍結當下拿下最多幀top1的相位(37/70、20/40)，且100%出現在所有凍結幀｜①分位數其實已經在我上一輪就加進床本身了(commit d2f594387，同一次跑同時出>2s幀數與percentile,不是兩支床)｜③兩個背景跑法都還在進行中,現況行數已附
---

# ②凍結幀top-5（落地 `docs/measurements/freeze-top5-seed{1337,42}.txt`）

方法：不重跑。既有的 `[FaiPhase] tick=N` 行是 production 每小時(60 tick)無條件印的相位快照，
而凍結幀的 tick 恰好全是 60 的倍數（AI評估本身就是整點cadence）⇒ 每個凍結幀在 raw log 裡都找得到對應那一行的完整 self_us 明細，寫小 python 腳本直接解析、不用重跑。

```
seed1337(母體70)：
  misc.equip_mobilize          拿下 top1 幀數=37/70  出現於70/70幀  平均self=0.468s
  unified.rank.from_solo_body  拿下 top1 幀數=26/70  出現於70/70幀  平均self=0.438s
  loop2.solo_engine            拿下 top1 幀數= 7/70  出現於70/70幀  平均self=0.397s

seed42(母體40)：
  misc.equip_mobilize          拿下 top1 幀數=20/40  出現於40/40幀  平均self=0.408s
  unified.rank.from_leader     拿下 top1 幀數=20/40  出現於40/40幀  平均self=0.383s
```
（跟床自己印的加總排行交叉驗證一致，見同一份 txt 檔第二段）

★兩seed一致訊號：`misc.equip_mobilize` 穩定是凍結當下最常吃最多時間的相位，且**兩seed都100%出現在每一個凍結幀裡**——不是偶發，是每次凍結它都在場。

# ①分位數——上一輪已經做了

我上次交件就已經把 median/p90/p99/max 加進 `freeze_sample_bed.gd` 本身（commit `d2f594387`），同一次跑同時印 `>2s幀數` 與 `[perf-nothreshold]` 那行，不是兩支床各跑。你這封信的①應該是在我交件之前寫的，這格已經滿足。

# ③對照臂進度（截至目前，未跑完）

```
gen6/HW-2 seed1337(含percentile,v2perf)：目前 8039 行（跑法：main dir 直接跑，非worktree）
gen5/HW-2 seed1337（世代5 code，.worktrees/gen5-freeze-recheck）：目前 5799 行
兩者都持續在長，尚未到達完成標記（gen6舊版同款seed1337跑完是10477行，供你比對量級用）
```
跑完會用 wrapper 層 `exited with code`／`[godot.ps1] child exit=` 標記驗證真結束才回報，不會再誤報。
