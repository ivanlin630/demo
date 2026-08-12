---
from: implementer
to: systems
status: consumed
topic: "[tap-gap fix DONE·feat/phase3-tapgap-fix commit 124ce5f8]faction-leave 4 出口接 Probe tap(全量暫態可觀測性補盲、純觀測零行為變)·4 出口各加 Probe.bump(Probe.enabled gated)緊鄰 clear_team_faction:uprising.secede(起義自立)/uprising.exile(起義流亡)/defection.surrender_fail(投降強鄰 fail)/defection.independent(defection 獨立)·★驗:tapgap_fire_test ALL PASS(構 4 場景各 counter 非零 fire)+★byte-identical 硬證(warring seed1337 2400t baseline[無 tap]FP=39908829 == branch[有 tap]FP=39908829=Probe.bump 不入 RNG 不改 state→零行為變+determinism 一併坐實)+headless 0-new+constitution 75·命門守 純觀測零行為變/感知鐵律無涉/憲法閘不變·請 merge-gate 硬讀(核 4 tap 加、零行為變 byte-identical、determinism)→measurer 覆核 tap fire→merge→un-blind long-game audit"
branch: feat/phase3-tapgap-fix
commit: 124ce5f8
---

# tap-gap fix DONE：faction-leave 4 出口接 Probe tap（純觀測、零行為變）

feat/phase3-tapgap-fix commit `124ce5f8`（off main HEAD 34fb8890；已 push）。

## fix（4 出口各加 `Probe.bump`、`Probe.enabled` gated、緊鄰 `clear_team_faction`）
| 出口 | tap key |
|---|---|
| 起義自立脫離 | `uprising.secede` |
| 起義流亡脫離 | `uprising.exile` |
| defection path B 投降強鄰 fail→clear | `defection.surrender_fail` |
| defection path C 獨立 | `defection.independent` |

## 命門守
純觀測 tap、`Probe.bump` **不耗 RNG、不改 state** → 零行為變。感知鐵律無涉、憲法閘不變（非 TaskArbiter site）。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| `tapgap_fire_test` | **ALL PASS**：構 4 場景 → 各 counter 非零 fire（defection path C 獨立→`independent`、path B 投降 fail(無強鄰)→`surrender_fail`、起義守城自立→`secede`、起義流亡→`exile`） |
| ★**byte-identical**（零行為變硬證） | warring seed1337 2400t baseline[無 tap] FP=`39908829` **==** branch[有 tap] FP=`39908829`（Probe.bump 不入 RNG 流/不改 state → fp 純同）= determinism + 零行為變一併坐實 |
| headless | **0-new** |
| constitution_gate | **PASS sites=75** |

## 路
1. **你 merge-gate 硬讀**（核 4 tap 加、**零行為變 byte-identical**、determinism）。
2. → measurer 覆核 tap fire（realistic bed 4 出口 counter）→ merge → **un-blind long-game audit**（③story-audit #2 CONFIRMED tap-gap 補全）。地基 KEEP。

（perf/F2 disk flag 續。）
