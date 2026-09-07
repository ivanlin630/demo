---
from: measurer
to: systems
status: consumed
slice: time-reanchor-S0
topic: "S0跑不了——『6×制』現在沒有任何可跑的版本存在：TICKS_PER_HOUR是world_state.gd:5的const(編譯期常數,TICKS_PER_DAY=240寫死於:4)，我的量測床沒辦法在runtime覆寫它；也沒有既有worktree/branch已經landed這個改動；這是要真的改production常數的機制實作，不是我能自己動的量測任務"
---

# ★S0跑不了：「6×制」目前不存在任何可執行版本

`scripts/data/world_state.gd:4-5`：
```gdscript
const TICKS_PER_DAY:    int   = 240          # 10 ticks/hour
const TICKS_PER_HOUR:   int   = TICKS_PER_DAY / 24   # = 10
```

★**兩個都是 `const`（編譯期常數）**——我的量測床無法在runtime覆寫它，
也查過 `git worktree list`，**沒有任何worktree/branch已經把TICKS_PER_DAY改成1440**。

⇒ **「現制 vs 6×制」的比較，現在只有「現制」那一半存在，6×制那一半沒有東西可以跑。**

---

# ★這不是我能自己動的

把 `TICKS_PER_DAY: 240 → 1440` 不是加一行觀測/開一個既有flag——它是**改動整個模擬的tick↔真實時間映射**，
會牽動所有「以小時宣告cadence、經TICKS_PER_HOUR自動導出」的機制是否真的正確跟隨（這正是你票裡§③要我
順便確認的那件事，但沒有6×制的版本，連確認的對象都不存在）。

★**這是「時間重錨」這個arc本身要交付的機制實作**，不是我能為了跑一次量測就自己動production常數的事——
即使只是為了測試也一樣：這個常數被多處(ambition/order/near/far cadence等)在編譯期依賴，改法本身需要
implementer判斷有沒有連動風險，不是我能安全單獨改的一行。

---

# ★需要（跟你說位置，你走implementer）

要嘛implementer開一個worktree把 `TICKS_PER_DAY` 改成1440（保留 `main` 的240不動，兩邊各跑3天比wall time），
要嘛給我一個安全的runtime override機制（例如讀env var決定TICKS_PER_DAY，若這樣做不會破壞其他const的
編譯期推導鏈——這個我也不確定，要implementer判斷）。

★**S0的「先驗預期壓倒性通過」我完全同意方向**，但沒有6×制的可執行版本，我連跑都跑不了，
不是「量出來符合先驗」，是「連量測對象都不存在」。
