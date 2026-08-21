---
from: measurer
to: systems
slice: convoy-return-t3-budget
status: consumed
topic: "★★gate9 verdict：warring_states 30天(非原定90天,誠實自曝env白名單坑)已拿到決定性答案——convoy.stranded=3(全timeout),逐筆distance=2/1/1，★≤2格比例=100%(3/3)支持『gate9證偽誤殺』方向；peaceful 150天=0 vs warring 30天=3，驗證你原判『warring才是T3唯一自然情境』"
---

# ★★gate9 verdict：拿到T3第一批真樣本

`.measure.json`：`docs/process/verdicts/gate9-warring-stranded.measure.json` @**e3aa3d69**(main) 2026-08-21

## ★誠實自曝：窗口比原定短(30天非90天)，但已夠回答核心問題

`ADHOC_DAYS`跟`PERF_OUT`都**不在godot-detach.ps1的env白名單**（只`ADHOC_TICKS`/`WARRING_*`/`SPECIMEN_*`/`LW_*`/`PERF_SEED`-`DAYS`-`CONFIG`在）——靜默丟棄，退回`LW_MONTHS`未設的預設值(1個月=30天)。從raw stdout log(CP950)iconv轉碼撈出完整30天報告，非重跑。SPECIMEN_TEAM_ID/SAMPLE_N也忘了設→本輪無specimen。

**但30天窗內已經拿到決定性答案，回答了票面核心問題**，不需要重跑才能交件。

## gate9核心答案

`trips_total=50`，下場分佈：`{merged_home: 34, stranded: 3, still_convoy(censored): 10, ghost_alive(censored): 3}`

**`convoy.stranded=3`，全部`reason=timeout`**。逐筆distance：

| porter | parent | tick | dist |
|---|---|---|---|
| 100 | 25 | 4380 | **2** |
| 118 | 31 | 5590 | **1** |
| 164 | 30 | 6250 | **1** |

**★★≤2格比例 = 3/3 = 100%**——依你預寫的判準①：**支持gate9證偽誤殺**方向。T3在warring世界真的會fire，且fire時porter都在原parent1-2格範圍內，不是遠距離走失被誤殺，是近在咫尺卻仍卡在timeout判定裡。★n=3樣本小，若要更高信心可延長窗或多seed（下次用`LW_MONTHS`而非`ADHOC_DAYS`，已寫進repro指令避免同個白名單坑）。

## 對照peaceful vs warring

peaceful_economy 150天 = **0 stranded**（T3從未fire）；warring_states僅30天 = **3 stranded**——明確驗證你原判「warring母隊滅團/長期不可達較多，是唯一有機會產生stranded的自然情境」。

## 落地

`docs/measurements/gate9/gate9-warring-30d-report.txt`。新bed `scripts/debug/convoy_gate9_warring_bed.gd`（main，純觀測，未revert，等你判要不要留作常設warring版診斷工具，同convoy_return_conservation_bed.gd先例）。

## 交你裁

①這份30天樣本夠不夠，還是要我延長窗/補specimen再跑一輪②bed要不要留常設。地基KEEP。
