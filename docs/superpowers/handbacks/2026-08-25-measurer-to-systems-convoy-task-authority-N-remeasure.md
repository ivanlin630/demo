---
from: measurer
to: systems
slice: convoy-return-task-authority
status: consumed
topic: "★§N兩欄重量(RNG副作用已修,新乾淨基準)：①合法退場185次(clean=67+with_commitment=118)②被hold擋下11次(全construction類)；主指標convoy=RETURN期間task=運輸佔比174/174=100.0%(零preempt)；主指標建設=construction_abandoned=0(與此前多輪普查一致,世界性質非病徵)；latch監測stall_fire=3非長期零觸發,stall_latched_suppressed=7證明防抖有作用"
---

# §N兩欄：新乾淨基準

`.worktrees/convoy-return-task-authority`，`peaceful_economy`，seed 1337，90天。已窮盡grep確認`corvee_site`清除side-effect已被你/implementer移除、我自己新增的觀測碼零`randf`/`randi`——本輪為RNG-safe/中性世界量測。

## 兩欄

①**合法退場總次數**(`release()`呼叫,不該下降) = **185**（clean=67 + with_commitment=118；帶承諾標記細分：corvee=0/convoy=1/order=117）。這是本輪(post-RNG-fix)第一次乾淨量測，沒有舊乾淨基準可比對「有沒有掉」——本次數字即為新基準。

②**被hold擋下總次數**(`commit.hold_blocked`,該上升) = **11**（全在construction類；`persist.hold`母口徑=21）。PASS，機制確實在攔阻。

## 主指標

**convoy**：RETURN期間task=運輸佔比 = **174/174 = 100.0%**——零preempt，滿分，直接行為證據。
**建設**：`construction_abandoned`事件數 = **0**——與此前多輪(64823f30/5cabb3f7)獨立普查一致，peaceful_economy這個世界配置下施工從不被放棄，是世界性質不是病徵。

## latch監測

`commit.stall_fire=3`（非長期零觸發，排除latch已發生而沒人知道的紅燈）／`commit.stall_latched_suppressed=7`（防抖確實壓下重複觸發，在運作）。

## 落地

`.measure.json`：`docs/process/verdicts/convoy-task-authority-N-remeasure.measure.json`
`report`：`docs/measurements/breed-deathcause/convoy-task-authority-N-90d.txt`

## L3聲明

`convoy_return_conservation_bed.gd`的`_report()`加§N兩欄report段(純report，零production code改動)。
