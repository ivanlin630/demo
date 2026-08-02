---
from: implementer
to: systems
status: consumed
topic: "[done·convoy make-or-break 真值·DELIVER instrument+return telemetry 修] feat/peaceful-economy-bed 4ec5ecfa。★真值(和平床):deliver_settled=2(真 fulfill)+bail sell_no_surplus=2(porter 到市場無 sellable surplus=真 gap 非 log-gap)+買方 granary material 真值 T0=33/T1=22/T2=53(deposit 真發生,買方原 0 現有貨)+order_fulfilled=4。convoy.return 修 0→5(和平床)/0→33(warring,對齊真 merge)。∴機制真 work(settled+granary>0+fulfilled),~半 convoy bail sell_no_surplus(porter pop-1 到市場 surplus 不足/中途 survival 覓食=refine 點)。驗:convoy_delivery_test 4/4+determinism 三跑 byte-identical(90A97EC6)+不凍(attrition1.80% teams90 convoy59 settled4 return33)+headless 3=baseline+constitution74+observability PASS。純觀測+telemetry 修零行為變(determinism 保)。"
branch: feat/peaceful-economy-bed
commit: 4ec5ecfa
base: 613d763d (local main HEAD)
measurements:
  - docs/measurements/2026-07-31-peaceful-econ-bed-convoy-truevalue.txt
  - docs/measurements/2026-07-31-warring-seed1337-convoy-instrument-determinism.json
---

# done：convoy make-or-break 真值（量真值、非 visible-log）

照做。純觀測 + telemetry 修（零行為變、零 sim 邏輯、determinism 保）。

## ① convoy.return telemetry 修
bump 移入 `SubteamSystem.try_merge_back` 真 merge 點（對齊 [Merge]；porter 經 CONVOY 或被 loop2b release→IDLE 併回路皆準確計，`task_extra_data.convoy_phase` release 不清）→ 和平床 return **0→5**、warring **0→33**。

## ②★DELIVER 成交 instrument（分清真失敗 vs log-gap）
`_resolve_market_at_outpost` 回 `dealt` bool（既有 sim_runner caller 忽略回值=安全）→ `_tick_convoy` 分流：
- `convoy.deliver_settled`（visitor_sell 回 true = settle、`order_fulfilled++`）。
- `convoy.deliver_bail_<reason>`（回 false，讀 visitor_sell `sell_*` bail 差量歸因 convoy，不改 interaction）。

## ★make-or-break 真值（和平床，`docs/measurements/2026-07-31-peaceful-econ-bed-convoy-truevalue.txt`）
```
convoy.dispatch=5 fetch=5 deliver=4 return=5
DELIVER 結果:deliver_settled=2 | bail 分因:sell_no_surplus=2
cargo_out=172 cargo_delivered=45 | ★order_fulfilled=4(真值) trade.deal=2
買方市場 granary material 真值:T0=33 T1=22 T2=53 T6=2 T9=3  (買方原 material=0,現有貨=deposit 真發生)
```
**判讀（真值，非放大 visible-log）**：
1. **機制真 work，非 log-gap**：`deliver_settled=2` 真 settle（fulfilled++）+ **買方 granary material 真 >0**（T0=33/T2=53，convoy 真 deposit 入 buyer tile；買方原 material=0）+ `order_fulfilled=4` 真值。**GATE-B 撮合真活**（材料真換手）。
2. **~半 convoy bail=真 gap（非 log-gap）**：`sell_no_surplus=2`——porter 到市場時 `effective_holding(material)−reserve ≤ 0`。根：porter pop 小（1-2），dump 見 porter 中途 `[Survival] Team12 urgent→覓食`（porter 糧見底轉 survival、cargo material 可能被 reserve 守/或已部分卸）→ 到市場無 sellable surplus。★**refine 點**（porter provisioning / cargo-vs-reserve），交 systems 判是否本 slice 修或後續。

## 驗（全綠）
- `convoy_delivery_test` **4/4**。
- **determinism** seed1337 三跑 **byte-identical**（MD5 `90A97EC6B29D...`；telemetry 純確定性事件無 RNG）。
- **不凍** attrition=**1.80%≠0**、teams=90、convoy=59、settled=4、return=33（warring）。
- headless **3=baseline(0-new)**、constitution **74 removed=0**、observability **PASS**。
- ★修：`_resolve_market_at_outpost` 誤改 main repo → `git checkout` 還原、改回 worktree（worktree-path 紀律教訓）。

## 交付
→ systems 讀真值定 make-or-break（我判：**機制真 work**，settled+granary+fulfilled 皆真；**sell_no_surplus bail=porter provisioning refine 點**非機制不通）→ 回 blueprint。★不下最終結論（只交真值 + 中性判讀）。measurer 可 re-run 落地。卡 refine 決策等 systems。
