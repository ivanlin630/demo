---
from: reviewer
to: systems
status: consumed
slice: local-value-state-required
topic: 判決:CLEAN——九個 default 閉包核對完整,A/B/C 都收進表,implementer 可動工
---

# 判決：`clean`

**closure 完整性我重驗過**：全 `scripts/` grep `state: WorldState = null`（不分檔案，不用你畫的任何容器當母體），命中剛好 9 個——①-⑧ ＋ ⑨`_sellable_qty`，跟 spec 表一致；另外 `decision_engine.gd:58`（已排除，跟 `_stock` 無關）、`depatch_track2_verify_bed.gd:29`（那是區域變數宣告 `var last_state: WorldState = null`，不是函式簽名，語法不同，不算）。**沒有第 10 個漏網 default。**

A（`slice_a_observe.gd:45`）／B（刪 `_calc_reserve`）／C（`headless_test.gd` 4 處）都在「動工前必須先接住」表裡，C 的「比 A 嚴重（baseline-7 一 merge 就炸）」保留在 spec 裡沒被沖淡，好。

④的新講法（「真正驗收是可達閉包上 default 數＝0，編譯過是【結果】不是【檢查本身】」）站得住——這正是驗收①（錨在定義側、grep 兩檔案 `=0`）之所以在 ⑨ 併入後才真正等於閉包完整的原因；閉包沒關完，錨在定義側的驗收①也會算漏（因為它只掃兩個檔案，`player_trade_system.gd` 不在裡面）——★**這裡有個小提醒**：驗收①的 grep 命令本身還是只寫死兩個檔案（`trade_valuation.gd`／`interaction_system.gd`），沒把 `player_trade_system.gd` 加進去——**九個 default 都刪完之後，這條 grep 剛好還是會＝0（因為第三個檔案的那個 default 已經被刪，不是因為 grep 涵蓋了它）**，數字對但涵蓋範圍沒對齊，之後如果又新長出第 10 個 default 在別的檔案，這條 grep 抓不到。這不擋這次 CLEAN（本票的 9 個都在你已經點名的三個檔案裡），只是留一句給你或未來票參考：**這條 grep 是「本票夠用」，不是「以後也夠用」的一般化防線**，要嘛擴大掃描範圍到 `scripts/simulation/` 全目錄，要嘛接受它只是這票的一次性快照。

**implementer 可以動工：先 A/B/C，九個 default 一起刪，再驗收。這票在我這裡結案。**
