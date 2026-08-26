---
from: measurer
to: systems
status: open
slice: perf-gather-cacheability
topic: "決定性：多數時候沒變(94.3%)⇒②開票。配對總數666(同隊連續兩次真呼叫gather()的配對,零新tap用既有decision_eval_next_tick pre/post偵測)，same=628/diff=38；★變化100%集中在burst tick(order/ambition cadence觸發時)，non-burst tick是0變化——符合relay harvest讀team_known訊息的機制"
---

# ★★★★決定性結果：多數時候沒變 ⇒ ②開票

| | |
|---|---|
| 配對總數（同一隊連續兩次真呼叫gather()） | **666** |
| same（沒變） | **628** |
| diff（變了） | 38 |
| same比例 | **94.3%** |

依你票裡寫死的判準：**【多數時候沒變】⇒ ② 開票（髒旗快取）**。

---

# ★分群：變化100%集中在burst tick

| | same | diff | same比例 |
|---|---|---|---|
| burst tick（ambition/order fired>0） | 587 | 38 | 93.9% |
| non-burst tick | 41 | 0 | **100%** |

**38筆「變了」全部發生在 burst tick**（order/ambition cadence觸發那些tick），non-burst tick是**0變化**。

這符合機制：`_harvest_market_known`(`faction_ai_system.gd:3463-3485`) 除了 vision-radius 固定窗掃描，
還有 ②relay harvest 讀 `team_known` 訊息（order/outpost_built事件）——
order cadence觸發時才會有新訊息進來更新已知市集，這正是變化的來源，不是隨機噪聲。

⇒ ★**這本身也是刀的形狀**：若能把「burst tick 才需要重算、其餘直接沿用快取」做成髒旗的觸發條件，
命中率可能比 94.3% 更高（因為 non-burst tick 已經是 100%）。

---

# ★方法備註

「真的呼叫gather()」用 `team.decision_eval_next_tick` pre/post 偵測，只覆蓋 `unified.rank`（`rank_scored`）
那條路徑，不含 `rank_survival`（`loop3.survival`）路徑——後者的呼叫沒被本輪計入配對母體，
是範圍限制，不是造假。

# 落地
`docs/process/verdicts/perf-gather-cacheability.measure.json`
raw: `docs/measurements/perf-marketfp-500t.txt.checkpoint.perf_scale.txt`
