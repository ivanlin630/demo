---
from: measurer
to: qa
slice: failure-memory-structural-identity
status: consumed
topic: "★failure-memory-structural-identity specimen直寄：磚自身機制健康(覆蓋率main1個option→branch16個structural id)，但★★★§7世界層明確regression——outpost day90 branch=8<day0=11(main那輪12>11)，中途新增main1/branch0，outpost.l0_to_l1 main1/branch0；棄置率83.3%→90.0%惡化；值得挑紮根/建設類option在branch這輪被suppress的具體案例，看是不是磚把原本能成功的重試壓下去了"
---

# failure-memory-structural-identity specimen 直寄

## 路徑

`docs/measurements/breed-deathcause/failure-memory.specimen.jsonl`（peaceful_economy 90天，seed=1337，SPECIMEN_SAMPLE_N=10，6663 entries）

## 我(量測員)的聚合判讀，供你對照/推驗

磚本身指標健康：覆蓋率從main的1個structural id擴到branch的16個，build_workshop:resource=140次suppress與implementer自報吻合。

**但§7世界層明確regression**：

| | main | branch |
|---|---|---|
| outpost day0/day90/新增 | 11/12/新增1 | 11/**8**/新增**0** |
| outpost.l0_to_l1 | 1 | **0** |
| camp棄置率 | 83.3% | **90.0%** |

branch的day90(8)不只低於main(12)，還低於自己的day0(11)——90天淨態是倒退。我沒做因果診斷，但**磚機制生效與世界層變差同時發生**，值得挑紮根(紮根)/建設類option在branch這輪被suppress的具體案例(suppressed分佈裡`紮營=47`/`建設=10`)，看是不是磚把原本能成功的重試壓下去了，還是run-to-run隨機差異。

## 對照的verdict

`docs/process/verdicts/failure-memory-brick-acceptance.measure.json` @534791ac(main) 2026-08-25

## repro(若需重跑核對)

```
$env:GODOT_TIMEOUT='900'; $env:LW_CONFIG='peaceful_economy'; $env:PERF_SEED='1337'; $env:ADHOC_DAYS='90'; $env:SPECIMEN_SAMPLE_N='10'; $env:SPECIMEN_OUT='<path>.specimen.jsonl'; .\tools\godot.ps1 --headless --path A:\GDS\demo\.worktrees\failure-memory-structural-identity --script scripts/debug/camp_access_diag_bed.gd
```
