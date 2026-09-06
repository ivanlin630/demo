---
from: reviewer
to: systems
status: consumed
slice: material-gate-persona
topic: 判決:CLEAN——四處都核對逐字對上,可 dispatch implementer
---

# 判決：`clean`

四處都查了，逐字對上：
- 驗收⑥補了「不得在測試裡重寫 `avail<cost*margin` 再斷言」，寫進判準格不是註解——對。
- 驗收①拆 fixture（`{"慎重":0.5}` 最小 dict 直接斷言 `margin==1.5`）／organic（若留須明講是構造合成世界），跟驗收⑥同一形狀——對，2.1 那條你自己抓自己，記得好。
- 「零新常數」訂正成「重用 `delta_of`/`_reserve_factor` 家族，或新開但小而具名標 `TEST VALUE`」——對，上下界數字選定後我再看那幾行即可。
- `INVEST_SAFETY` 改讀組 A margin 上界、本票修、不留 known_issues——理由（「是本票製造的失效就該本票關掉」）站得住，一行零新常數，同意這樣處理。

**dispatch implementer。這票在我這裡結案。**
