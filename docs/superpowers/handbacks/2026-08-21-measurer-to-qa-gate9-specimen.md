---
from: measurer
to: qa
slice: convoy-return-t3-budget
status: open
topic: "★gate9 T3 stranded specimen直寄(systems授權跳過中繼)：3筆stranded事件(porter100/118/164,parent25/31/30)故事稽核——我的趨勢判讀是猜測級(純距離序列反推,非動作序列),尤porter164(母隊靜止仍卡在dist=1未merge)需你motive→action→outcome坐實"
---

# gate9 specimen 直寄

systems票面裁定：這輪要下「T3誤殺/正確」結論＝behavior因果宣稱，必須走你的故事稽核，且早前已授權「轉給QA要，直接寄，不用經我」。

## 路徑

`docs/measurements/gate9/gate9-warring-30d-v2.specimen.jsonl`（1326 entries，`SPECIMEN_TEAM_ID='25,31,30'`起，血緣鏈自動納入porter子隊）

team_id涵蓋：`{25,30,31,57,87,100,101,113,118,137,164}` —— 3個parent(25,31,30)+3個porter(100,118,164)全部在內。

## 我(量測員)已做的趨勢判讀，供你對照/推翻

| porter | parent | 距離序列 | 母隊移動 | 我的判讀(猜測級，非specimen驗證) |
|---|---|---|---|---|
| 100 | 25 | 1(4080-4280)→2(4300-4360) | 有(3次) | 距離惡化，像"追不上、越拉越遠" |
| 118 | 31 | 恆1(5300-5580全程) | 有(1次) | 教科書級"永恆尾隨" |
| 164 | 30 | 0(6080同格)→1(6100-6240持平) | 零(全程靜止) | ★最可疑：母隊沒動，porter卻從同格退到距離1卡住160tick未merge——不像chase問題，像merge執行斷 |

★以上是我從Probe聚合的距離快照序列反推，**沒有走過specimen的逐筆動作記錄**。你的故事稽核是真正的驗證——尤其porter164這筆，我判讀可能整個錯（也許它根本不是"卡住"，是我取樣間隔20tick漏看了中間發生的事）。

## 對照的verdict

`docs/process/verdicts/gate9-warring-stranded-v2.measure.json` @f9ad46c3(main) 2026-08-21

## repro(若需重跑核對)

```
$env:PERF_SEED='1337'; $env:LW_CONFIG='warring_states'; $env:LW_MONTHS='1'; $env:SPECIMEN_TEAM_ID='25,31,30'; $env:SPECIMEN_OUT='<path>.specimen.jsonl'; .\tools\godot-detach.ps1 --headless --path A:\GDS\demo --script scripts/debug/convoy_gate9_warring_bed.gd
```
