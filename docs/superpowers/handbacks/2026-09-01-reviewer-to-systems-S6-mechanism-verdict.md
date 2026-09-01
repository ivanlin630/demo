---
from: reviewer
to: systems
status: open
slice: S6-build-duration
topic: R②判決:clean——①單位鏈查過,code本身已有runtime自我檢查(不是只有你的靜態推導)+唯一呼叫路徑確認;②pop凍結風險真實但不是新卡死,是舊flat-30天timeout本來就有的同類風險,不用現在解;③驗收②非恆真,是標準回歸測試形狀(防未來手抄)
---

# 判決：`clean`

## ①單位推導鏈——**查過，比你的靜態推導更硬：code 自己在跑時驗**
`outpost_system.gd:111-123`——`build_ticks_per_day()` 不是只靠你手動推導的假設，它**自己在 runtime 呼叫 `_outpost_tick_runs_in_near_pass()`**（讀 `SimRunner.SYSTEMS` 這個活的 registry，不是手抄），假設一旦失效就 `Probe.bump("build_eta.cadence_assumption_stale")`——這正是「假設要能自己舉手說我可能不成立了」的形狀，比純靜態推導更硬。

我複驗了兩件：**(a)** `SimRunner.SYSTEMS` 裡 `outpost_tick` 的登記確實是 `"lod": LOD_NEAR`（`sim_runner.gd:159`），跟假設一致；**(b)** `_tick_construction` 全庫只有【一個】呼叫點（`outpost_system.gd:195`），在同一支迴圈裡，往上追就是 `_step4b_outpost_tick`——沒有第二條路徑繞過這個假設進來。**沒有你沒走到的分支，而且這條鏈已經內建了偵測「假設失效」的機制，不用你另外補。**

## ②pop 凍結——**風險是真的，但不是新卡死，是舊制本來就有的同類風險**
你舉的例子（動工時 pop 高⇒timeout 短⇒後來 pop 掉了⇒還沒蓋完就被取消）成立。★**但這不是本票新引入的問題**：舊制 `CONSTRUCTION_TIMEOUT = 30 * TICKS_PER_DAY` 是**跟 pop 完全無關的死常數**，一個低人力、進度天生慢的工地在舊制下**本來就一樣可能撞上固定 30 天期限提前被取消**——「固定期限跟不上後續變化」是【任何固定 deadline 機制】的共同屬性，不是「凍結 pop」這個修法自己發明出來的新洞。新制甚至比舊制更貼合實際（deadline 隨初始工程量縮放，不是齊頭 30 天）。

⇒ **不用現在解**：這屬於 `FLOOR`/`CEIL`／`k` 這些參數怎麼選才會讓「合理範圍內的人力波動」不誤殺工地——是表值/參數調校階段的事，不是機制設計的結構缺陷，跟這票自己的定位（「表值留參數位,等實測」）一致，不用機制段解決。

## ③驗收②「改錨全表等比例跟」——**不是恆真式，是標準回歸測試形狀**
「現在寫下去當然會通過」不等於「恆真沒有偵測力」——★**這條測的不是『現在對不對』,是『未來會不會被人手抄破壞』**：某天有人為了單獨調某一項（例如「工坊感覺該貴一點」）直接把 `FARM_PH := 36` 硬寫死，不再用 `SETTLE_PERSON_HOURS * 0.5`，這條驗收會在下次改錨時抓到那一項沒跟——**這正是它存在的理由，跟`fp`逐位元不變（驗收①）『現在也是必然通過』但沒人說它恆真沒用是同一個道理**。回歸測試的價值在防未來，不在今天的不確定性。

**premise_contradiction: false，三點都不用改，implementer 可以照機制段動工，等實測票把表值填回來。**
