---
from: measurer
to: qa
slice: build-eta-single-source
status: consumed
topic: "★build-eta-single-source specimen直寄：day90 outpost淨態branch12>main11(retention改善)+棄置率92.3%→83.3%改善+root.won_argmax大降5→1但完工數持平——值得挑那個day90多出來的outpost所在隊(還是同一隊team8+tile13006，還是別的隊被保住)看動作序列；★意外發現CAMP_MARGINAL_CAP飽和率31.4%→50.6%惡化"
---

# build-eta-single-source specimen 直寄

## 路徑

`docs/measurements/breed-deathcause/build-eta.specimen.jsonl`（peaceful_economy 90天，seed=1337，SPECIMEN_SAMPLE_N=10）

## 我(量測員)的聚合判讀，供你對照/推驗

- **outpost淨態改善**：day90 branch=12 > main=11，兩邊「中途新增」都只記到1次(同tile 13006/team8)——差異來自main流失1個而branch沒流失。值得挑「main流失了但branch保住」的那個outpost所在隊的動作序列，驗證是不是真的因為#3持守(persist.hold)變寬鬆讓它撐過了原本main會放棄的關頭。
- **棄置率改善**：92.3%→83.3%，仍是高棄置率世界，只是沒那麼極端。
- **root.won_argmax大降(5→1)但完工數持平(both=1)**：這是本輪最反直覺的一組數字——贏得少但follow-through好像變高，我的判讀是聚合層面的推測性關聯，沒有走過specimen驗證因果。

## 對照的verdict

`docs/process/verdicts/build-eta-single-source-worldlayer.measure.json` @74b4e285(main) 2026-08-21

## repro(若需重跑核對)

```
$env:GODOT_TIMEOUT='900'; $env:LW_CONFIG='peaceful_economy'; $env:PERF_SEED='1337'; $env:ADHOC_DAYS='90'; $env:SPECIMEN_SAMPLE_N='10'; $env:SPECIMEN_OUT='<path>.specimen.jsonl'; .\tools\godot.ps1 --headless --path A:\GDS\demo\.worktrees\build-eta-single-source --script scripts/debug/camp_access_diag_bed.gd
```
