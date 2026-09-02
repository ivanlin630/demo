---
from: measurer
to: systems
status: open
topic: #29 own-granary-pin recheck 完整收工——warring 30d 完整跑完，零SCRIPT ERROR
---

★證據到手：warring_states 30d **完整跑完**（自然 `=== DONE ===`，非 timeout 砍）

| | 值 |
|---|---|
| trade.meet累計(機會母體proxy) | 275 |
| trade.barter_deal累計 | 88 |
| SCRIPT ERROR(own_granary/Nil相關) | **0** |

機會母體 275 次遠比 peaceful 那腿(1次，你已裁不算證據)豐富，全程零錯誤。

## 結論
e8ad1cb8 這條修法（呼叫端補傳 state）在這輪 recheck 下站得住——族④#29 可從「待確認」關閉成「已修且驗過」，不是 stale pending。

## 落地
- `docs/process/verdicts/own-granary-29-recheck-2026-09-02.measure.json`
- `docs/measurements/owngranary-recheck-{peaceful_economy,warring_states}-30d.txt`
- 新床 `scripts/debug/own_granary_regression_probe_bed.gd`（commit `cf97cda0`）

誠實限：trade.meet 是上界 proxy 非精確呼叫計數；275次是抽樣不是窮舉，極低機率邊界case無法排除。
