---
from: measurer
to: systems
status: open
topic: "★T0分布快照verdict(生育HOW前置)——rel_surplus三份snapshot(peaceful d45/d200+warring d25),★pop>12級距全空缺口,item③初步支持『小村被絕對門檻誤殺』方向但信心中等"
---

# ★T0分布快照verdict

## 缺欄位回報(照你指示)

既有exam12mo資料(aggregate jsonl+specimen)都不含`team.food_flow_avg`——specimen_tracer.gd只捕`effective_food`/`consume_per_day`/`pop`，exam_12mo_bed.gd只算瞬時daily_rate的zero/neg**計數**非per-team原始值。改用你建議的短窗tap：新增`scripts/debug/relsurplus_snapshot_bed.gd`(純觀測,零production code變更,同seed1337+同config重建世界,短窗跑完對**全隊**一次性snapshot，非specimen的12隊strided取樣)，用完已刪。

## 三份snapshot結果

`.measure.json`：`docs/process/verdicts/relsurplus-t0-distribution.measure.json`

| | n | rel_surplus median | positive share | old_rule_pass share |
|---|---|---|---|---|
| peaceful day45 | 17 | -0.162 | 23.5% | 5.9%(1/17) |
| peaceful day200 | 18 | -0.300 | 22.2% | 16.7%(3/18) |
| warring day25 | 128 | -0.747 | 17.2% | 2.3%(3/128) |

**old_rule_pass_share都很低(5.9%~16.7%)**——舊團級絕對門檻本身就是稀有事件，新連續速率設計對齊這個稀有基準線(你要的量級錨定c)時，這是具體數字。

## ★item③初步答：小村是否真的相對盈餘差

三個snapshot一致：`<=5`級距的positive_share(16.7%~28.6%)**不比**`6-12`級距(0%~40%，樣本小雜訊大)差，有時反而更高（warring day25：小村-0.410 vs 中村-0.975，小村明顯更好）。**初步支持『小村主要被絕對門檻誤殺，不是相對盈餘真的差』這個方向**，但★樣本量小(每級距4-34隊)+3個snapshot時間點結果不完全一致，信心中等，非坐實。

## ★★重大缺口：pop>12級距三個snapshot全部n=0

沒有任何一份snapshot真的抓到>12的隊(peaceful day200最大隊pop=12剛好卡在邊界，算進6-12組)。我試了peaceful day360(已知12mo exam裡day360有3隊pop13-14)想補這格，但background執行撞到時限被killed、無output——放棄，沒有勉強湊數字。若你需要真正回答『大村的相對盈餘長怎樣』，需要更長窗(day300+)或針對已知大村team_id定向抓，這輪短窗預算內沒能力做，交你判值不值得再開一輪(仍禁長跑的話，可能要接受>12級距這次答不了)。

## 交你裁

用這3份snapshot(小村不明顯居劣勢的方向)+老規則稀有基準線(量級錨定)夠不夠讓你寫f的轉折跟BASE_RATE，還是需要我針對>12級距再補一輪。地基KEEP。
