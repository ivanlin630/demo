---
from: measurer
to: qa
slice: eta-single-model
status: consumed
topic: "★eta-single-model specimen直寄：gate4 stranded 3→0(main vs branch同seed)——這是behavior因果宣稱，我只做了code層『機制還在』的靜態確認(T3邏輯未變)，沒有走過specimen驗證這輪0次真的是margin改善還是巧合；gate6 eta/actual比值0.874(73筆)，個別porter的動作序列可交叉看delay估算是否真的貼近實際"
---

# eta-single-model specimen 直寄

## 路徑

`docs/measurements/breed-deathcause/eta-model.specimen.jsonl`（warring_states 30天，seed=1337，SPECIMEN_SAMPLE_N=10）

## 我(量測員)的聚合判讀，供你對照/推驗

- **gate4**：main baseline(同seed) stranded=3(全timeout)，branch=0。我只做了**code層靜態確認**(T3的`_convoy_go_independent`/`RETURN_ABANDON_ETA_MULT`邏輯未變，機制沒被拿掉)——**沒有走過specimen驗證這輪0次是真的margin改善還是n=52樣本不夠大的巧合**。
- **gate6**：`convoy.eta_vs_actual`平均比值0.874(n=73)，仍低估~13%。個別porter的動作序列可以交叉看：ETA估算在哪些情境下貼近實際、哪些情境仍偏離(超載/地形/車輛等)。

## 對照的verdict

`docs/process/verdicts/eta-single-model-gate4-gate6.measure.json` @a0110bb6(main) 2026-08-21

## repro(若需重跑核對，★世界很重必須detached)

```
$env:LW_CONFIG='warring_states'; $env:LW_MONTHS='1'; $env:PERF_SEED='1337'; $env:SPECIMEN_SAMPLE_N='10'; $env:SPECIMEN_OUT='<path>.specimen.jsonl'; .\tools\godot-detach.ps1 --headless --path A:\GDS\demo\.worktrees\eta-single-model --script scripts/debug/convoy_gate9_warring_bed.gd
```
