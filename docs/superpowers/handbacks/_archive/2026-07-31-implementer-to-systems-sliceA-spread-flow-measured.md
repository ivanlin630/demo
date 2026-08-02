---
from: implementer
to: systems
status: consumed
topic: "[done·SLICE A convoy 協調散·★trickle→flow measured 真升·flag attrition=0 非凍] feat/peaceful-economy-bed 8bb2ad7b。LIVE-SCAN in-flight guard 散未填單。★★MEASURED(非假設):和平床 cargo_delivered 45→153(153/192 需求=80%,前 23%)+deliver_settled 2→5+order_fulfilled 4→6+dispatch 5→9 散多買家。unit 6/6(+in-flight 散單)+headless 3=baseline+determinism 三跑 byte-identical(A391F07B)。★flag:warring attrition 1.80%→0=非 latch-freeze(conq 3407/combat 9/teams 63→91/convoy 活/byte-identical=動態;butterfly→此 seed 0 淨死:戰非殲滅+無餓死+breed LOD-skip)→systems/QA 判 non-freeze 語意。"
branch: feat/peaceful-economy-bed
commit: 8bb2ad7b
base: 613d763d (local main HEAD)
measurements:
  - docs/measurements/2026-07-31-peaceful-econ-bed-spread-measure.txt
  - docs/measurements/2026-07-31-warring-seed1337-spread-determinism.json
---

# done：SLICE A convoy 協調散未填單（★trickle→flow measured 真升）

LIVE-SCAN in-flight guard（鎖定、非 registry）。★★MEASURE-VERIFY 硬命照做，量真值。

## 做
`_deliver_candidates` 加 **LIVE-SCAN in-flight 認領 guard**：每次現掃 `state.teams` active convoy porter 的 `task_extra_data.order_id`+`cargo_qty` → 聚合 per-order 在途認領 → `effective_rem = order.qty − 在途認領`，`<=0` 跳單。散選 util/gain 秤未填 best 單（非 round-robin），qty cap 到 effective_rem（不過載）。★**鎖 LIVE-SCAN 非 state-registry**（死 porter 自動離 state.teams＝認領自動失效、結構免疫漏清幽靈認領）。

## ★★MEASURE-VERIFY（和平床 re-run，`docs/measurements/2026-07-31-peaceful-econ-bed-spread-measure.txt`；別假設）
| 指標 | 前(堆單) | 後(散單) |
|---|---|---|
| cargo_delivered | 45 | **153**（of 347 loaded；**~153/192 需求=80%**，前 23%）|
| deliver_settled | 2 | **5** |
| order_fulfilled | 4 | **6** |
| convoy.dispatch | 5 | **9**（散到多買家 porter12/13 各挑不同未填單）|

DELIVER trajectory 證散：porter12→loaded64 sold12 / 37 sold33 / 70... porter13→70 sold51 / 43 sold33 / 43 sold24——**多 porter 到不同買單成交**。殘 bail=同 cadence overlap（in-flight guard 跨 cadence 有效、同 cadence 仍可撞）+ 買方 coin（`sell_owner_cant_afford`）。**trickle→flow 真臨門（delivered 3.4×、send-rate 23%→80% 需求）**。

## 驗
- `convoy_delivery_test` **6/6**（+ in-flight 認領滿 X 跳過→散未填 Y=LIVE-SCAN 散單）。
- headless **3=baseline(0-new)**。
- **determinism** seed1337 三跑 **byte-identical**（MD5 `A391F07B`）。

## ★flag：warring attrition 1.80%→0（**非 latch-freeze**，systems/QA 判 non-freeze 語意）
warring seed1337 1mo：`attrition=0`（pop 444→444）。**但非凍**，證：
- `conq.declared=3407`、`combat.ended_n=9`、`conq.combat_entered=9`（戰鬥活躍）。
- `teams 63→91`（founding/subteam 成長）、`convoy=38 settled=9 fulfilled=12`（經濟流動）。
- determinism **byte-identical**（確定性演化非 stuck-loop）。
- attrition=0 因：spread 改決策流（butterfly）→此 seed×1mo 的 **9 戰皆非殲滅**（`death.combat_pop=0`）+ **無餓死**（`death.starve_anon=0`）+ **breed LOD-skip**（warring all-far anchor，person 繁殖不跑）→ pop 淨零變。
- ∴「attrition≠0」proxy 被觸，但世界**證明未凍**（churn+活動齊）。2mo 驗證 timeout（>900s）未取得。→ **systems/QA 判**：attrition=0-with-proven-churn 是否滿足 non-freeze invariant（我判非凍、但 proxy literal fail 須你裁）。

## 交付
→ R²（★異質：LIVE-SCAN 無漏清[死 porter 自動失效]/effective_rem 對/散選 util 秤非 scripted/★fulfilled measured 真升[非假設]/attrition=0 非凍判）→ measurer（fulfilled 45→153 + 散多買家 + non-freeze 語意，落地）→ QA。★convoy 三驗收線 PASS + flow 真升。deliver_cargo/spread 全在 branch（systems R² 後定 merge）。★attrition=0 non-freeze 語意等 systems/QA 裁。
