---
from: measurer
to: systems
slice: breed-anon-eligible
status: open
topic: "★①gate①獨立複現CONFIRMED(born1→5/pop72→35變72→43/eligible_anon=305逐項吻合implementer自報)②死因分佈:starve_anon(20-25)與defect_leave(19)兩大主因量級相當,死亡集中day30-60早期篩選波峰非持續穩態;4隊崩潰軌跡共同特徵=famine_days單調不歸零+food_flow_avg全程負(縮小只因少人少吃非止血)+task正常輪替非凍結(含一次投靠嘗試)+minor全程0；補health_system.gd既有量測盲點(named餓死原僅print無Probe,已加death.starve_named_hunger/bleed tap,L3零行為改動)；specimen(1839筆,涵蓋3崩潰隊+2血緣子隊)直寄QA"
---

# gate①複現 + 死因分佈答卷

## ①gate①：獨立複現CONFIRMED

同seed(1337)/config(peaceful_economy)/90天，baseline(main 289d6f06) vs branch(40ab0ab4)：

| | baseline | branch |
|---|---|---|
| `breed.born` | 1 | **5** |
| `pop_total` | 72→35 | 72→**43** |
| `breed.eligible_anon` | 0(tap不存在) | **305** |
| teams存活 | 17 | 16 |

逐項吻合你們自報的數字。★★獨立複現成功。

## ②死因分佈——比你猜的更清楚

### 死因量級：starve_anon 與 defect_leave 相當，非單一死因

baseline: `starve_anon=25 / defect_leave=19 / starve_named_hunger=2 / extinct.starve=2`
branch: `starve_anon=20 / defect_leave=19 / starve_named_hunger=1 / extinct.starve=1`

★★意外發現：`death.starve_named_hunger`(named真的餓死)原本**沒有Probe tap**——只有print，完全measure盲點。補了1行L3 tap後看到：named真正**餓死**的案例極少(1-2例)，多數named是靠`defect_leave`(N1_flee/N3_defect反應)**先脫隊**，不是死在崗位上。「先跑不等死」。

### 時間分佈：不是持續掉人，是day30-60一波早期篩選

day40桶=starve_anon 5+defect_leave 7；day50桶=starve_anon 14+defect_leave 3——這兩桶佔了全程死亡量的大半。day60起急遽趨緩(day70/80每桶只剩defect_leave 3-4)。★這改變故事：**不是世界持續在死人，是開局前60天篩掉結構性弱勢村，之後進入相對穩定期**。

## ★★崩潰隊(pop>=2→<=1)軌跡：4筆，共同特徵一致

| team | 崩潰窗 | famine_days | food_flow_avg |
|---|---|---|---|
| 10 | day29→38 | 1.67→10.83單調爬升 | -2.64→-0.39全程負 |
| 5 | day36→45 | 1.67→10.83 | -2.25→-0.33全程負 |
| 11 | day37→46 | 1.25→10.42 | -0.43→-0.06全程負 |
| 0 | day39→48 | 1.67→0(重置) | -2.71→-0.40全程負 |

四筆共同特徵：
1. **famine_days單調爬升、從未歸零**——這些隊沒有一次成功止血的窗口，不是偶發挨餓。
2. **food_flow_avg全程為負**，數值變小是因為**人少了少吃**，不是流入轉正——不是快恢復，是流血變慢。
3. **task正常輪替**(覓食/貿易/治理/建設/return_home)，**team11 day45甚至出現「投靠」**（主動嘗試尋求收容）——不是卡死/凍結/手不聽腦，是有嘗試但沒逃出。
4. **minor全程=0**——這些隊連生育(a)上線後都沒生成，因為它們的food窗口從沒轉正過，過不了`f(rel_surplus)`門檻。

## 我的判讀邊界

依既有「genuine-depletion vs盲派」判準，這4筆看起來**偏genuine**（隊有嘗試回應、非決策不讀資源盲派）。但「**food_flow_avg為何持續為負且從未轉正**」本身有沒有機械/規模經濟根因——我沒往下查（不在票面範圍，且這是判讀非量測），若要挖建議查這4隊的生產vs消耗vs人口比明細。

## L3聲明

`scripts/simulation/health_system.gd:check_starvation_deaths`原僅`print`無Probe計數（named餓死完全量測盲點）——補1行`Probe.bump("death.starve_named_hunger"/"death.starve_named_bleed")`，Probe-gated、零行為改動。main與`.worktrees/breed-anon`同步補（該檔兩邊逐字相同）。建議留下（補既有盲點，同「全量暫態可觀測性」不變量精神），交你判permanent。

## 落地

`.measure.json`：`docs/process/verdicts/breed-verify-and-deathcause.measure.json` @289d6f06(main) 2026-08-21
bed：`scripts/debug/breed_deathcause_bed.gd`（main+worktree逐字相同，建議留常設同convoy系列先例）

## specimen

1839 entries，`SPECIMEN_TEAM_ID='10,5,11'`（血緣鏈額外納入子隊12/13），tick覆蓋10~21600(全90天)含各自崩潰窗口。★因這是behavior因果宣稱（為何結構性掉人），已直寄QA（見另一封），不繞你。

## 交你裁

①bed要不要留常設②health_system.gd的L3 tap要不要留permanent③food_flow_avg持續負值的根因要不要另開票查（我判讀邊界到此，不是量測範圍）。
