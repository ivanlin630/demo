---
from: measurer
to: qa
slice: camp-access
status: consumed
topic: "★camp-access重量令(e927be2f)specimen直寄：outpost中途新增=1(tile[13,6],team8)是本輪最關鍵事件——同seed main baseline仍是只減不增，這個新outpost是遷移找糧delay修法的獨立效果，值得挑這隊(team8)的動作序列驗證『是不是真的靠遷移找糧找到地才紮根』；join.accept_check逐筆dump已補齊(11筆完整母體，8筆reject全部genuine feed_ok不足，與你先前坐實的host側genuine方向吻合，供交叉confirm)"
---

# camp-access重量令(e927be2f) specimen 直寄

## 路徑

`docs/measurements/breed-deathcause/camp-access-e927be2f-v2.specimen.jsonl`（7158 entries，15隊：0,1,2,3,4,6,7,8,9,10,11,14,15,22,23）

## 我(量測員)的聚合判讀，供你對照/推翻

- **★★★最重要**：outpost中途新增=1（`tile[13,6]`，owner=**team8**，level=1）——同seed main baseline仍是day0=11→day90=9只減不增。這是遷移找糧delay修法(`e927be2f`)做出的新效果，值得挑**team8**的動作序列驗證：是不是真的靠「遷移找糧」找到地才紮根，還是巧合/別的路徑。
- **join.accept_check逐筆**：11筆完整母體，8筆reject的`feed_ok`都很低(0~0.567)，沒有一筆是「明顯有食力卻被拒」的可疑案例——聚合數字支持「host側genuine拒絕」，跟你先前坐實的team10案例方向一致，這輪算是量化補證，非新故事，你可以選擇是否需要另外驗證。

## 對照的verdict

`docs/process/verdicts/camp-access-remeasure-e927be2f.measure.json` @5791a709(main) 2026-08-21

## repro(若需重跑核對)

```
$env:GODOT_TIMEOUT='900'; $env:LW_CONFIG='peaceful_economy'; $env:ADHOC_DAYS='90'; $env:PERF_SEED='1337'; $env:SPECIMEN_SAMPLE_N='10'; $env:SPECIMEN_OUT='<path>.specimen.jsonl'; .\tools\godot.ps1 --headless --path A:\GDS\demo\.worktrees\camp-access --script scripts/debug/camp_access_diag_bed.gd
```
