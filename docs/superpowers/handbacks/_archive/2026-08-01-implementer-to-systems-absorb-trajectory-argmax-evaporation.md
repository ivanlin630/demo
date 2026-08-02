---
from: implementer
to: systems
status: consumed
topic: "[done·乙 吸納 trajectory·★蒸發環=argmax loss(非 finder/mid-travel)·pull-side 比 JOIN 更早死] feat/scale-absorb-measure f19dc62b。measure(3seed×1mo):absorb.target_found=4794(finder 大量找到弱鄰)+util_n=4794(util 皆算)→absorb.dispatch=0(★吸納從不贏 argmax)→arrive=0/merge=0。蒸發環=決策層 argmax loss(util 太弱),非 finder(找到 4794)/非 mid-travel(沒 dispatch)/非 resolver。★對比:JOIN(push)dispatch33→arrive1(mid-travel);ABSORB(pull)target4794→dispatch0(argmax)。兩整併路蒸發環不同,pull-side 更早死。驗:headless 3=baseline+constitution 74+determinism 三跑 byte-identical(F1A33414)。純觀測零行為變。落地 docs/measurements/2026-08-01-warring-absorb-trajectory-3seed.json。"
branch: feat/scale-absorb-measure
commit: f19dc62b
base: 92e93873 (local main HEAD)
measurement: docs/measurements/2026-08-01-warring-absorb-trajectory-3seed.json
---

# 乙 補全貌：吸納(pull-side 整併) trajectory — ★蒸發環 = argmax loss

measure-first。純觀測 tap 零行為變零 RNG。

## instrument
- reuse `absorb.dispatch`(1604 opt=吸納)、`absorb.target_found`(decision_context:388 finder 非空)、`absorb.util_n`(util 算)。
- 新 `absorb.traj_arrive`(TASK_MERGE order_target 抵達弱鄰，marker task_extra_data.absorb_pull 認 pull-side)、`absorb.traj_merge`(`_try_merge` success)。PROBE_KEYS 補。

## ★★trajectory 定蒸發環（3 seeds×1mo，`docs/measurements/2026-08-01-warring-absorb-trajectory-3seed.json`）
```
absorb.target_found = 4794   ← finder 找到 capacity-bound 弱鄰（大量機會）
absorb.util_n       = 4794   ← 吸納 util 皆算
absorb.dispatch     = 0      ← ★吸納從不贏 argmax
absorb.traj_arrive  = 0
absorb.traj_merge   = 0
```
**★蒸發環 = argmax loss（決策層）**：4794 機會 finder **全找到**、util **全算**，但吸納 option **從不贏 argmax**（dispatch=0）→ 完全不派、談不上 arrive/merge。
- **非** finder-no-target（找到 4794）。
- **非** mid-travel（根本沒 dispatch）。
- **非** resolver（沒到 resolver）。

## ★對比 JOIN（push-side）——兩整併路蒸發環不同
| 整併路 | 蒸發環 | 數 |
|---|---|---|
| **JOIN（push，弱投強）** | **mid-travel**（絕境隊 dispatch 後半路死/churn） | dispatch 33 → arrive 1（97%）|
| **ABSORB（pull，強吸弱）** | **argmax loss（決策層）**（util 太弱從不贏） | target 4794 → dispatch **0**（100%）|

∴ 世界塌全小（併小成大不運作）**兩根**：push 死在 mid-travel、pull 死在 argmax（吸納 util 競不過覓食/攻擊/建設等）。pull-side **比 JOIN 更早死**（決策層就 0，比 JOIN 至少 dispatch 33 更前）。「強隊有糧撐旅程」假說**無從驗**（強隊根本沒 dispatch 吸納）。

## 驗（全綠）
- headless **3=baseline(0-new)**、constitution **74 removed=0**、determinism 三跑 **byte-identical**（F1A33414）。
- 純觀測 instrument（marker task_extra_data.absorb_pull 僅 dispatch 時寫、本 run dispatch=0 從未寫=零行為變）。隔離 branch 未 merge。

## 待
systems 讀 → 定乙 de-patch HOW。真值指向兩根：
- **pull-side（吸納）**：argmax loss → 吸納 util weigh 太弱（4794 機會全輸）→ de-patch 方向=提吸納 util（擴張慾人格 weigh）。
- **push-side（JOIN）**：mid-travel 蒸發（前份 pin）→ 治絕境隊到不了 host。
★只交蒸發環真值，不下 de-patch 結論。整併全貌已量齊（push+pull 兩根）→ systems+blueprint 定 HOW。
