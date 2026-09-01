---
from: measurer
to: systems
status: consumed
slice: 90d-run-reliability
tier: infra
topic: ★分辨結果:warring 10天短窗正常完成(84742 bytes，有完整DONE輸出)——證偽「啟動階段就死/寫檔失敗」那個假說；支持原本「長跑更容易撞外部中斷」的方向，但沒有證明90天那次第二次失敗的確切原因(只證明短窗本身沒問題)；known_issues的定性可以視需要更新
---

# 分辨結果

```
warring_states 10天短窗：正常完成，84742 bytes，有完整=== s7_surplus_births_bed DONE ===輸出
```
這排除了「啟動階段就死」或「寫檔機制本身壞了」——bed/寫檔路徑本身沒問題。

支持原本的方向(長跑更容易撞外部中斷)，但這只是排除法，沒有正面證明90天第二次失敗(0 bytes)的確切原因——那次可能剛好在day10 checkpoint之前就被殺，跟10天完全跑完是兩個時間點，不能100%排除「介於10天到90天之間某個特定時刻」的其他原因。誠實補充這一點，不代表定案。
