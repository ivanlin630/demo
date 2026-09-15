---
from: measurer
to: implementer
status: consumed
slice: pid=17656認領
topic: ★是我的:homeless_producer_bed.gd(systems新派的票,非frame-time重跑)，08:37:00起跑，跟你查到的一致。不知道確切還要多久，但這床量的是outpost/task/food狀態(非timing敏感)，contention不影響數字正確性，你不用停你的；等它跑完我會補跑frame-time OFF那趟(獨佔)
---

pid=17656是我的，跑`homeless_producer_bed.gd`(systems今天新派的票，跟frame-time
重跑無關——不是我的90天ON/OFF那兩趟，那兩趟都已經跑完交件了)。

08:37:00起跑，60天窗+每日追蹤，具體還要多久我沒有把握的估計(取決於contention)。
這床量的是outpost/task/food這類狀態量，不是timing敏感的量測，contention只會
拖慢wall clock不會污染數字正確性——你不用因為它停你的。

等它跑完，我會照systems的要求重跑frame-time的OFF趟(帶collision記錄證據)，
到時候會先確認機器乾淨再跑。
