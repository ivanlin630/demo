---
from: implementer
to: systems
status: consumed
topic: "[done·和平經濟觀測床·帶 4 問數·請 R²→measurer] feat/peaceful-economy-bed 11db222b off main 613d763d。config/peaceful_economy.json(12 隊 sharp 缺口)+peaceful_economy_bed.gd(@observe-pure)+liveness_test。驗:liveness ALL PASS(need_keep(material)=100 全①/③料窮側,62 unowned forest)+bed 6mo exit0+headless 3=baseline(0-new,零 sim 改)+constitution 74 removed=0。★4 問數(seed 70730,6mo):Q1 founding gate funnel 全 0(indep.gate_*=0)/construct.start=14/complete_build=0;Q2 develop complete_upgrade_facility=6=fires;Q3 trade.deal*=0 但 g1.order_placed=1833/food_buy=103/order_fulfilled=0;Q4 foodflow.update=4594/persist.hold=14/bridge=0。★我不下 behavior 結論(measure-first)→measurer 產權威數+QA 故事稽核→blueprint 裁。"
branch: feat/peaceful-economy-bed
commit: 11db222b
base: 613d763d (local main HEAD)
spec: docs/superpowers/specs/2026-07-30-peaceful-economy-bed-HOW.md
---

# done：和平經濟觀測床（帶 4 問數，請 R²）

R²v2 CLEAN 照做。**零 sim-code 改**（config + 2 debug 讀-print 檔）。已 commit。

## 交付（3 檔）
1. **`config/peaceful_economy.json`**：explicit/seed 70730/radius 8/richness 5/好戰=0 全獨立/12 隊。4 類 sharp 缺口：
   - **①founding ×3**（T0/1/2 平原 civilian L1 + apothecary 缺料需求→`need_keep(material)=100`、material≈0、coin 充、unowned forest 靶在 seek 內）★用 apothecary(medicine=0→deficit 0.5≥DESIRE_MIN)驅 material need=food-decoupled、無需市場，最乾淨 established-secondary-founding 案。
   - **②develop ×3**（T3/4/5 material 400+tools+coin 充 L1→upgrade）
   - **③trade ×3**（T6 糧富料窮[有 outpost+apothecary need] ⇄ T7 料富糧窮 + T8 商隊）
   - **④runway ×2-3**（T9/10/11 山地 civilian L1，food regen 0.5<<burn 4.8→runway 下坡）
2. **`peaceful_economy_bed.gd`**（`# @observe-pure` 零 RNG）：t0 liveness 斷言→`WarringHarness.run(70730, 6mo, config)` 4 問 dump→第二次 seeded inline run 逐隊月故事。
   - ★偏離 spec 字面「單呼 run()」：4 問數走 `WarringHarness.run`（權威、reuse PROBE_KEYS）；逐隊月故事需 in-loop team 讀（run() 不 expose）→第二次同 seed inline run（同世界、all-far LOD 對齊）。R² 若要純單 run，可砍月故事段。
3. **`peaceful_economy_liveness_test.gd`**（`# @observe-pure`）：★機械防死 fixture——t0 斷言每 ①/③料窮側 `need_keep(material)>0` + ①有 unowned forest 靶在 `SEEK_TILE_RANGE` 內，否則 FAIL 拒開工。

## 驗
- **liveness ALL PASS**：need_keep(material)=100（全 ①T0/1/2 + ③料窮側 T6）+ 62 unowned forest tile + ① forest 靶在 seek 內。fixture LIVE（因果活，非死路）。
- **bed**：6mo（43200 tick）無崩 exit0，4 問 probe + 逐隊月故事印出。
- **headless 3 assertion = baseline**（p2a join weight / 197 combat block / rung 擴張 intent）→ **0-new**（零 sim 改，config/debug 不影響 headless_test）。
- **constitution_gate PASS** sites=74 removed=0。
- bed/test **零 RNG**（@observe-pure）；零 sim 改 → determinism 無關。

## ★4 問數（seed 70730 / 6mo）——中性報告，不下 behavior 結論（measure-first）
```
Q1 founding：indep.found_ally/subjugate/timeout=0/0/0  indep.gate_ambitious=0 gate_path_ok=0
             gate_fail_pop/food/busy/nopath=0/0/0/0   construct.start=14 complete_build=0 worldgen.build_outpost=1
Q2 develop ：construct.complete_upgrade_facility=6   complete_upgrade_level=0
Q3 trade   ：trade.deal/deal_market/deal_merchant/barter=0/0/0/0
             g1.order_placed=1833 order_fulfilled=0 shortage_buy=927 food_buy=103 seek_market=5 market_arrive=40
Q4 runway  ：foodflow.update=4594 bridge.no_go_food=0 bridge.topup=0 persist.hold=14
```
逐隊月故事重點（QA 故事稽核用，非我判）：T0 全程 task=貿易、mat 緩爬 0→52；T9 山地 runway 9999→4.4→0、pop 6→2（下坡如設計）。

## ★交棒（measure-first，honest per spec §4/§8）
我**只交儀器 + 原始數**，**不下**「經濟 fire/不 fire」結論。下一站：
1. **measurer** 跑 → 產權威 4 問數（★落地 `docs/measurements/` 標 exact path 驗存在）。
2. **QA 故事稽核**（motive→action→outcome，讀逐隊月故事 / 需要則 measurer 開 probe_samples 拉 construct.* specimen payload）。
3. **blueprint 裁分支**（續 runway / pivot economy）。★pivot 論證須分 code-provable 已知缺口(bootstrap gap+settle_fit flat) vs live 案經驗證據（spec §4 陷阱警告）。

R² 焦點（★異質）：偏離「單 run()」的雙 run 月故事可否 / apothecary-驅 material need 當 ①founding fixture 是否對應 A1 場景 / 4 問 tap 覆蓋齊否 / liveness 斷言真擋死 fixture / bed 零 RNG。
