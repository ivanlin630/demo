---
from: systems
to: reviewer
status: open
topic: "[R²·和平經濟床實作·feat/peaceful-economy-bed 11db222b·零sim-code改(config+2讀-print debug檔)·liveness ALL PASS(need_keep material=100全①/③料窮側+62 unowned forest)+bed 6mo exit0+headless 0-new+constitution 74·★4問數(seed70730/6mo):Q1 complete_build=0/gate*=0/construct.start=14 Q2 upgrade_facility=6 fires Q3 trade.deal=0但order_placed=1833/fulfilled=0 Q4 foodflow=4594/persist=14/bridge=0·審:雙run determinism(月故事第二inline run:110 seed+:126 advance重現同世界?)+apothecary驅material need當①founding fixture對應A1否+4問tap齊+liveness真擋死fixture+零RNG] 和平經濟床impl。審雙run determinism+fixture對應+tap齊。4問數初看completion塌(founding/trade完成0)非純動機缺但measurer/QA/blueprint判。"
---

# R²：和平經濟床實作（measure-first Step0）

branch `feat/peaceful-economy-bed` 11db222b。零 sim-code 改（config + 2 讀-print debug 檔）。R²v2 CLEAN spec 照做。

## 做（3 檔）
- `config/peaceful_economy.json`（seed 70730/radius8/好戰=0/12 隊 4 類 sharp 缺口；①用 **apothecary(medicine=0→deficit≥DESIRE_MIN) 驅 material need=100**、food-decoupled、無需市場=最乾淨 established-secondary-founding 案）。
- `peaceful_economy_bed.gd`（@observe-pure）：t0 liveness→`WarringHarness.run(70730,6mo)` 4 問 dump→**第二 inline seeded run**（:110 seed+:126 all-far advance）逐隊月故事。
- `peaceful_economy_liveness_test.gd`（@observe-pure）：t0 斷言 need_keep(material)>0 + forest 靶否則 FAIL 拒開工。

## 驗（implementer）
liveness ALL PASS（need_keep(material)=100 全①/③料窮側 + 62 unowned forest）+ bed 6mo exit0 + headless 0-new + constitution 74 removed=0 + 零 RNG（@observe-pure）。

## ★reviewer focus（異質 refute）
1. **★雙 run determinism**：月故事走**第二 inline run**（bed:110 `seed(SEED)` + :126 `advance_tick(no_player)`）——它**真重現 WarringHarness.run 的同一世界**否（config["seed"]/GameSetup.setup/all-far LOD 對齊 → 月故事與 4 問 probe run byte-identical world）？兩 run 岔開＝月故事誤導。
2. **apothecary 驅 material need 當 ①founding fixture 對應 A1 否**：apothecary build-cost 含 material→need_keep(material)=100→goal_resolver:206-219 該生 founding delegate candidate（found forest）。這對應 A1「缺料→立國 forest」場景否，還是測了別的東西（medicine need 而非 wood/material 本身）？
3. **4 問 tap 覆蓋齊否**（Q1 gate funnel indep.gate_* 全 0——但 goal_resolver secondary-founding 走 delegate/_dispatch_builder 非 indep-strategy funnel，這是否 tap 錯層＝該看 construct.start/delegate dispatch 非 indep.gate_*？若 tap 錯層則 Q1 數要重解讀）？
4. **liveness 斷言真擋死 fixture**（need_keep=100 確認活）+ **bed 零 RNG**（@observe-pure→observability_gate ③ 掃過）？

## ★4 問數初看（★不下結論、measurer/QA/blueprint 判）
Q1 complete_build=0/gate*=0/construct.start=14；Q2 upgrade_facility=6 fires；Q3 trade.deal=0 但 order_placed=1833/fulfilled=0；Q4 foodflow=4594/persist=14/bridge=0。**初看非「economy 完全不發生」（develop fire/order 狂下/runway 感官活）但 completion 塌（founding/trade 完成 0）＝疑 execution-layer 非純動機缺——但這是下游判。** ★特別要 reviewer 判 focus 3（Q1 tap 是否錯層＝數字可能被誤讀）。

## 交付
CLEAN → merge（零 sim 改低風險）→ **measurer 獨立跑產權威 4 問數（★落地 docs/measurements 標 path）→ QA 故事稽核（motive→action→outcome 逐隊月故事）→ blueprint 裁分支**。有洞（尤其 1 determinism / 3 tap 錯層）→ 回 `to:systems`。
