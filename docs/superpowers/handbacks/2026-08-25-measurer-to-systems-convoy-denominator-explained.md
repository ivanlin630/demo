---
from: measurer
to: systems
slice: convoy-return-task-authority
status: consumed
topic: "★母體差47%確認是(a)真效果非(b)床/tap不同——tap插入點兩側逐字相同已排除(b)；連convoy dispatch總數本身都不同(main=4/branch=3)，代表hold邏輯cascade進所有task決策，同seed下world從dispatch這步就分岔，是code change的因果後果非量測bug；★distinct商隊維度：main=1/3(33.3%)被preempt過，branch=0/2(0%)，方向與tick-sample一致但n極小(2~3)不宜當獨立判準，補充對照用"
---

# 母體差解釋：(a)確認，非(b)

## 排除(b)

`convoy.return_tick`/`convoy.return_distinct`/`convoy.return_task_other`三個tap的插入點——`faction_ai_system.gd:_evaluate_subteam`入口，早於所有`current_task`早退——兩側**逐字相同**（已對照），不是位置差異造成的。

## (a)成立，而且比「branch縮短RETURN階段」更根本

★連convoy的**dispatch總數本身**都不同：`main dispatch=4/return=4`，`branch dispatch=3/return=3`。這不只是「同一批convoy跑更快」——是**從dispatch這一步世界就已經走向不同軌跡**。`task_arbiter.gd`的hold邏輯改動會cascade進所有task決策（不只convoy），同seed同config下，程式碼一改，世界從很早期就分岔。這是code change的因果後果，不是量測bug或兩張床不可比。

## distinct商隊維度

- **main**：1/3 = 33.3%（distinct隊id=[12,14,22]，被preempt過的隊=[14]）
- **branch**：0/2 = 0%（distinct隊id=[12,13]，被preempt過的隊=[]）

★**誠實邊界**：n=2~3，population太小，不宜把33.3%/0%當有統計意義的比率——這是「這90天窗口main有1支商隊被打斷過、branch的2支都沒有」的**完整普查**（非推導非抽樣），不是可推廣的比率。方向上與tick-sample結果(93.3%→100%)一致，互相印證，但都基於極小n，任何單一數字都不足以獨立扛起「效果成立」——你自己算的絕對數（22次preempt vs期望11.6次）仍是目前最站得住的判準，這份distinct數據是補充對照，非替代。

branch的distinct population(2)比main(3)少1，與dispatch總數少1(3 vs 4)方向一致：可能是同一支消失的convoy（branch第3支dispatch的convoy可能仍在OUTBOUND/DELIVER或90天內未抵達RETURN階段），本輪未深究是否為同一因，供你裁要不要追。

## 落地

`.measure.json`：`docs/process/verdicts/convoy-denominator-explained.measure.json`
`reports`：`docs/measurements/breed-deathcause/convoy-task-authority-N-v2-90d.txt` + `convoy-task-authority-N-main-baseline-v2-90d.txt`

## L3聲明

兩側加`convoy.return_distinct`(team id去重樣本)+main端補`convoy.return_task_other`的team id樣本(原本沒存)。插入點兩側byte-identical已核對。
