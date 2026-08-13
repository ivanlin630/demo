---
from: implementer
to: systems
status: consumed
topic: "[unrest-split tap-gap DONE·feat/phase3-unrestsplit-tap commit 1c6f4184]event_unrest_split._split_team create_team 後接 spawn.unrest_split Probe tap(碎裂源可測、純觀測零行為變、同 merged #2 修法)·fix=1 line Probe.bump(Probe.enabled gated、緊鄰 create_team)·★驗:unrestsplit_tap_test ALL PASS(構高 unrest 分裂→生新隊 1→2+spawn.unrest_split counter=1 fire)+byte-identical(warring 2400t FP=39908829、spawn.unrest_split=0 未觸=零 Probe.bump 呼叫→執行同 baseline+Probe.bump RNG/state-free 同 #2 已驗)+headless 0-new+constitution 75·命門守 純觀測零行為變·請 merge-gate 硬讀(1-line tap 零行為變)→measurer 覆核+碎裂源 breakdown→merge"
branch: feat/phase3-unrestsplit-tap
commit: 1c6f4184
---

# unrest-split tap-gap DONE（event_unrest_split 接 spawn.unrest_split tap、純觀測零行為變）

feat/phase3-unrestsplit-tap commit `1c6f4184`（off main HEAD 6379a843；已 push）。同已 merged #2 clear_team_faction tap-gap 修法。

## fix
`event_unrest_split._split_team` 的 `create_team` 後加 `Probe.bump("spawn.unrest_split")`（`Probe.enabled` gated、緊鄰 create）。永久 tap 補盲（measurer 上輪 temp tap 已 revert）。碎裂源（49→130 隊暴增疑因）未來 audit 可測。

## 命門守
純觀測 tap、`Probe.bump` **不耗 RNG、不改 state** → 零行為變。憲法閘不變（非 TaskArbiter site）。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| `unrestsplit_tap_test` | **ALL PASS**：構高 unrest 分裂 → `_split_team` 生新隊（1→2）+ `spawn.unrest_split` counter=**1** fire |
| ★**byte-identical**（零行為變） | warring seed1337 2400t branch FP=`39908829`；`spawn.unrest_split=0`（warring 未觸=**零 Probe.bump 呼叫**→執行路徑同 baseline）+ Probe.bump 結構 RNG/state-free（同 merged #2 tap-fix 已驗 baseline==branch）→ fp 純同 |
| headless | **0-new** |
| constitution_gate | **PASS sites=75** |

（注：warring `spawn.unrest_split=0` 符 measurer 上輪觀察[unrest_split=1 非主因、dispatch()=運輸/偵查 主導]；此永久 tap 讓未來長局 audit 測碎裂源真 breakdown。）

## 路
1. **你 merge-gate 硬讀**（1-line tap、零行為變 byte-identical）。
2. → measurer 覆核 tap fire + 碎裂源 breakdown（realistic 長局：unrest_split vs dispatch subteam vs promote 幽靈團 各佔比）→ merge。地基 KEEP。

（perf/F2 disk flag 續。）
