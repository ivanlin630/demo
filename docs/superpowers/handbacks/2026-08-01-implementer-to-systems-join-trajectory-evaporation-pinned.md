---
from: implementer
to: systems
status: consumed
topic: "[done·乙 JOIN trajectory·★蒸發環 pin=dispatch→arrival(mid-travel)非 gate/resolver] feat/scale-join-measure 2ddd7dae。measure(3seed×1mo,非斷言):join.traj_dispatch=33(survival 併入 主路;merge.set_ok=0)→join.traj_arrive_target=1→resolve=1。97% 蒸發在 dispatch→arrival(mid-travel);非 belief-gate(0)/非 resolver reject(0)/非 blocked(0)。dispatch 主路=survival 併入(絕境隊),非 systems 假設的 _try_join_target 1937(該路 0)。驗:headless 3=baseline(0-new)+constitution 74+determinism 三跑 byte-identical(AD0BE812)。純觀測 tap 零行為變。落地 docs/measurements/2026-08-01-warring-join-trajectory-3seed.json。候選(交 systems):argmax cadence 重決換走/絕境隊 mid-travel 餓死/target 移動追不上。"
branch: feat/scale-join-measure
commit: 2ddd7dae
base: 92e93873 (local main HEAD)
measurement: docs/measurements/2026-08-01-warring-join-trajectory-3seed.json
---

# 乙 grounding：JOIN trajectory — ★蒸發環 pin = dispatch→arrival（mid-travel）

measure-first（禁靜態斷言）。純觀測 tap 零行為變零 RNG。

## instrument（JOIN lifecycle trajectory）
- `join.traj_gate_nobelief`（pre-dispatch belief-gate 1936）、`join.traj_gate_tryset_lost`（try_set 被擋）、`join.traj_dispatch`（dispatch 成功：`_try_join_target` 1937 + survival 併入 3797）、`join.traj_arrive_target`（抵達真 target，social_target 對上）。
- reuse：`merge.set_ok`（`_decide_unified` 併入 dispatch）/ `join.arrived_no_handler`（combat-blocked）/ `accept.join_reject`/`accept.join_accept`/`join.resolve`。
- PROBE_KEYS 補 5 key。

## ★★trajectory 定蒸發環（3 seeds×1mo，`docs/measurements/2026-08-01-warring-join-trajectory-3seed.json`）
```
join.traj_dispatch        = 33   ← survival 併入 主路（merge.set_ok=0 = _decide_unified 併入 未用）
join.traj_gate_nobelief   = 0
join.traj_gate_tryset_lost= 0
join.traj_arrive_target   = 1    ← ★只 1 抵達真 target
join.arrived_no_handler   = 0    （非 combat-blocked）
accept.join_reject        = 0    （非 resolver 拒）
accept.join_accept        = 1
join.resolve              = 1
```
**★蒸發環 = dispatch→arrival（mid-travel）**：**33 dispatch → 僅 1 抵達 target = 97% mid-travel 蒸發**。
- **非** pre-dispatch belief-gate（0）。
- **非** resolver reject（accept.join_reject=0；抵達的都被接受）。
- **非** combat-blocked（arrived_no_handler=0）。
- ∴ JOIN 隊 dispatch 後**根本到不了 target**（半路蒸發），resolver/gate 都沒問題。

## ★systems 假設訂正
systems 指 dispatch=`_try_join_target`(faction_ai:1937)——但 measure：**該路 dispatch=0 貢獻**（1mo/3seed traj 全走 **survival 併入**路 3797=絕境隊）。`_decide_unified` 併入路（merge.set_ok）也=0。∴ **JOIN 幾乎全由 survival-desperate 隊發起**（絕境求生併入），非常規 argmax 併入。這改 de-patch 方向（治絕境隊 mid-travel 蒸發）。

## 蒸發候選（未定，交 systems 讀 pin de-patch；別假設）
mid-travel 蒸發 33→1 的 why 候選（需再一層 trace 定，本份只 pin 環）：
- **argmax cadence 重決**：survival 每 cadence 重評 → JOIN 未抵達前被換走（覓食/掠奪等他 survival option）。
- **絕境隊 mid-travel 餓死**：desperate joiner 途中 extinct（絕境發起→走不到）。
- **target 移動追不上**：belief_pos stale，target 移走。

## 驗（全綠）
- headless **3=baseline(0-new)**、constitution **74 removed=0**、determinism 三跑 **byte-identical**（`AD0BE812`）。
- 純觀測 instrument（determinism 保、零行為變）。隔離 branch `feat/scale-join-measure`（未 merge）。

## 待
systems 讀 → 定 mid-travel 蒸發 why（我可加一層 trace：dispatch 後 JOIN 隊逐 tick task/pos/存活，pin argmax-churn vs 餓死 vs target-move）→ 設計乙 de-patch HOW（non build 新整併、治 mid-travel 蒸發，非 resolve 瓶頸[resolve 其實乾淨]）。★只交蒸發環真值，不下 de-patch 結論。卡下一層 trace 需求等 systems。
