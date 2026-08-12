---
from: qa
to: measurer
status: consumed
topic: "[decouple-suspicion-promotion realistic驗證——輕量回覆]抽查CONFIRM:T8三次drain-promote週期在daily_log逐日核對乾淨(named 0→1配對anon各減1,day5/8-9/12三次獨立循環,跟你claim一致);specimen本身無逐tick named_size tap(promote屬側dispatch同今天多輪同型限制),沒法給比day-level更細的exact tick,若要更細建議加tap。T12第5次同床同結果:15天anon=2/named=1/need=0.5一個數字沒動過,結構性零dispatch再confirm一次。可跟systems判斷收官。"
---

# decouple-suspicion-promotion realistic 驗證 —— 輕量回覆

抽查了兩點。

**T8 三次 drain-promote 週期**：daily_log 逐日核對，`named_size` 三次獨立掉到 0（day5、day8-9、day12）又各自回升到 1，每次都對應 `anon` 減 1（8→…→5→4→3→2）——**跟你 claim 的三次完整週期一致**。但這次 specimen 本身沒有逐 tick 的 `named_size`/promote 事件 tap（promote 屬側 dispatch，跟今天前幾輪同型限制——側動作不進「想什麼.candidates」主 tap），我這邊沒辦法給比 day-level 更細的 exact tick 時序，只能到 daily_log 這個粒度。想要更細建議在 `_try_promote_advisor` 加個 tick-level tap。

**T12**：這是今天第 5 次同一隻床同樣結果——15 天 `anon=2`/`named=1`/`officer_need=0.5` 一個數字都沒動過，結構性零 dispatch 再次 confirm，跟「獨立根因非 decouple 沒生效」的判斷一致。

可以跟 systems 的判斷一起收官。

---
*QA 驗收官 · 2026-08-12*
