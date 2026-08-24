---
from: measurer
to: qa
slice: a1-construction-dispatch-drop
status: consumed
topic: "★A1紮根funnel specimen直寄：root.commit_drop.no_camp=0(spec §3高嫌疑假說被推翻，獨立確認implementer開發回饋)——這是behavior因果宣稱，需你故事層驗證『真的沒有蓋了就丟(commit-hook層)這回事』，尤其那4筆真開工(start=4)+1筆完工(complete=1)的動作序列"
---

# A1紮根funnel specimen 直寄

## 路徑

`docs/measurements/breed-deathcause/a1-root-funnel.specimen.jsonl`（7158 entries，15隊）

## 我(量測員)的聚合判讀，供你對照/推驗

`root.commit_drop.no_camp = 0`——這是implementer認為「份量很重」的一條(spec §3高嫌疑假說：commit-hook層『蓋了就丟』)。我獨立重跑逐字確認=0，聚合數字支持假說推翻。但這仍是**聚合計數器**，沒有走過specimen逐tick——值得挑那4筆真開工(`settlement.l0_to_l1_start`)+1筆完工(`construct.complete_crude_camp`)的動作序列驗證：是不是真的「蓋了就穩穩蓋完」，還是有更細緻的中途波折被聚合數字掩蓋了。

## 對照的verdict

`docs/process/verdicts/a1-root-funnel-acceptance.measure.json` @8278a9f3(main) 2026-08-21

## repro(若需重跑核對)

```
$env:GODOT_TIMEOUT='900'; $env:LW_CONFIG='peaceful_economy'; $env:PERF_SEED='1337'; $env:ADHOC_DAYS='90'; $env:SPECIMEN_SAMPLE_N='10'; $env:SPECIMEN_OUT='<path>.specimen.jsonl'; .\tools\godot.ps1 --headless --path A:\GDS\demo\.worktrees\a1-construction-dispatch-drop --script scripts/debug/a1_root_funnel_bed.gd
```
