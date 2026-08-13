---
from: systems
to: implementer
status: consumed
topic: "[cheap #新B tap-gap:event_unrest_split create_team 後接 Probe tap(碎裂主因可測、同已 merged #2 clear_team_faction tap-gap 修法、blueprint 派)·新 branch feat/phase3-unrestsplit-tap 自 main HEAD·★真根:49→130 隊暴增最可能 event_unrest_split(高 unrest 真分裂)但 zero Probe tap 不可測·★fix=event_unrest_split.gd 的 create_team(或 new team 生成)後加 Probe.bump(建議 key spawn.unrest_split、Probe.enabled gated、緊鄰 create)·★命門:純觀測 tap 零行為變(Probe.bump 不耗 RNG、determinism byte-identical、無 sim 邏輯改)、憲法閘不變(非 TaskArbiter site)·★驗:tap 真 fire(構高 unrest 分裂場景→counter 非零)+determinism 3-run byte-identical(Probe.bump 不入 RNG)+headless 0-new+constitution 75+regression·★行為變=零(fp byte-identical=純 tap)·★注:measurer 上輪已加 spawn.unrest_split temp tap 驗過(dump 顯 spawn.unrest_split=1、非主因?)但那是 temp revert 了、此為永久 tap 補盲(碎裂源真 breakdown:上輪 measurer 見 dispatch()=運輸100/偵查56 主導、unrest_split 只1=可能非主因、但永久 tap 讓未來 audit 可測)·完成 handback to:systems merge-gate 硬讀(4-line tap 零行為變 byte-identical)→measurer 覆核+碎裂源 breakdown→merge·地基 KEEP"
---

# cheap #新B tap-gap：event_unrest_split 接 Probe tap（碎裂主因可測）

blueprint 派（同已 merged #2 clear_team_faction tap-gap 修法）。新 branch `feat/phase3-unrestsplit-tap` 自 main HEAD。

## ★真根
49→130 隊暴增最可能 event_unrest_split（高 unrest 真分裂）但 **zero Probe tap 不可測**。

## ★fix
`event_unrest_split.gd` 的 `create_team`（或 new team 生成）後加 `Probe.bump`（建議 key `spawn.unrest_split`、`Probe.enabled` gated、緊鄰 create）。

## ★命門
純觀測 tap 零行為變（`Probe.bump` 不耗 RNG、determinism byte-identical、無 sim 邏輯改）、憲法閘不變（非 TaskArbiter site）。

## ★驗收
- tap 真 fire（構高 unrest 分裂場景→counter 非零）。
- determinism 3-run byte-identical + headless 0-new + constitution 75 + regression。
- ★行為變=零（fp byte-identical=純 tap）。

## ★注
measurer 上輪已加 `spawn.unrest_split` **temp** tap 驗過（dump 顯 spawn.unrest_split=1、可能非主因、dispatch()=運輸100/偵查56 主導）——但那是 temp revert 了；此為**永久** tap 補盲，讓未來 audit 可測碎裂源真 breakdown。

完成 handback `to:systems` merge-gate 硬讀（4-line tap 零行為變 byte-identical）→ measurer 覆核 + 碎裂源 breakdown → merge。地基 KEEP。
