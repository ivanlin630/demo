---
from: measurer
to: qa
slice: breed-anon-eligible
status: open
topic: "★死因/崩潰隊specimen直寄(behavior因果宣稱慣例):3隊(5/10/11)結構性掉人到pop=1軌跡,共同特徵famine_days單調不歸零+food_flow_avg全程負(縮小只因少人少吃)+task正常輪替非凍結+minor全程0；我的判讀是團層聚合快照(daily snapshot)反推,未走過specimen逐tick決策記錄，尤其『food_flow_avg為何從未轉正』需你story audit坐實"
---

# 死因/崩潰隊 specimen 直寄

systems票面②要死因分佈+崩潰軌跡，behavior因果宣稱慣例照routing給你故事稽核。

## 路徑

`docs/measurements/breed-deathcause/branch-90d.specimen.jsonl`（1839 entries）

`SPECIMEN_TEAM_ID='10,5,11'`起，血緣鏈自動納入子隊12/13。tick覆蓋10~21600(全90天seed1337 peaceful_economy)。

## 我(量測員)已做的判讀，供你對照/推翻

3隊(team10/5/11)從pop 5-6一路掉到1，共同特徵：
- famine_days單調爬升、從未歸零（沒有一次成功止血）
- food_flow_avg**全程為負**，數值變小只因人少了少吃，非流入轉正
- task正常輪替（覓食/貿易/治理/建設/return_home），team11 day45甚至嘗試「投靠」——非凍結/手不聽腦
- minor全程=0（連生育(a)上線後也沒生，因為food窗口從沒轉正過）

★以上是我從**daily聚合快照**（team.population/famine_days/food_flow_avg/task 每日一筆）反推的，**沒有走過specimen逐tick的決策/reaction記錄**。你的故事稽核是真正驗證——尤其：
1. `food_flow_avg`持續為負的**根因**（生產跟不上消耗？規模經濟？資源可得性？）——我沒查。
2. team11「投靠」那次嘗試發生了什麼（util算出來多少、為何沒成功脫險）。
3. 這4隊是否有共同的決策模式（例如都選了同一個task但production跟不上）。

## 對照的verdict

`docs/process/verdicts/breed-verify-and-deathcause.measure.json` @289d6f06(main) 2026-08-21

## repro(若需重跑核對)

```
$env:LW_CONFIG='peaceful_economy'; $env:ADHOC_DAYS='90'; $env:PERF_SEED='1337'; $env:SPECIMEN_TEAM_ID='10,5,11'; $env:SPECIMEN_OUT='<path>.specimen.jsonl'; .\tools\godot.ps1 --headless --path A:\GDS\demo\.worktrees\breed-anon --script scripts/debug/breed_deathcause_bed.gd
```
