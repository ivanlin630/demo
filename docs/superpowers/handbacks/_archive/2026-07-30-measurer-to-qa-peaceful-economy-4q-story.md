---
from: measurer
to: qa
status: consumed
topic: "[和平經濟床權威4問數+逐隊月故事·已驗3跑byte-identical(除TickPerf timing外)·落地path已驗存在] main(7fdb6439)seed70730 6mo。★★Q1讀法(別誤讀):indep.gate_*全0是因為那是建國ally/subjugate外交機制(跟①forest founding是兩條路,人格野心不夠格根本不會進那個gate,gate=0不代表①沒卡);①真訊號=construct.start=14(dispatch真的發生14次) vs construct.complete_build=0(完工掛零)=動機層有fire,卡在執行/完工層。Q3同款:g1.order_placed=1833(狂下單)vs order_fulfilled=0/trade.deal=0(零成交)=同款execution-layer completion塌陷嫌疑。Q2develop:complete_upgrade_facility=6(有,非0)/upgrade_level=0。Q4runway:foodflow.update=4594(規律fire)/persist.hold=14(剛好=construct.start數,可能每次dispatch都立刻被hold)/bridge.no_go_food=0/topup=0。逐隊月故事驗到兩個具體案例:T9(mountain)runway 9999→4.4→0.0+pop 6崩到2(月2)後food=0/runway=0.0卡死到月6結束(task在idle/治理/覓食間擺盪但沒回穩);T0(plains)mat緩慢爬升0→49→52(6個月)但need_mat=138從未達標,task=貿易但看不到真成交(對應Q3零成交發現)。→你讀motive→action→outcome逐隊故事,判economy有無真fire→回blueprint裁分支(續runway或pivot)。"
measured_at_head: "main 7fdb6439（和平經濟床，零 sim 改，三閘綠）"
seeds: "70730（bed 內建 seed，6mo，三跑 determinism 已驗）"
---

# 和平經濟床權威 4 問數 + 逐隊月故事 → QA（故事稽核）

工單：`2026-07-30-systems-to-measurer-peaceful-economy-bed-authoritative-4q.md`（已消費）。bed 已 merge main（`7fdb6439`），純跑既有 `peaceful_economy_bed.gd`，零 production code 改動。

## 落地檔案（已驗證存在，三跑 determinism 確認）
- `docs/measurements/2026-07-30-peaceful-economy-bed-run{1,2,3}.txt`（各 260KB 左右）
- **determinism**：三跑逐行 diff，**除 `[TickPerf]` 純計時行外完全 byte-identical**（`TickPerf` 是 wall-clock 效能量測，非 sim state，本就預期跑跑不同）。

## ★★Q1/Q3 讀法（照工單標註，避免誤讀）
- **`indep.gate_*` 全 0 不代表①（forest founding）沒被卡**——那組 tap 量的是「建國 ally/subjugate」外交 gate（跟①機制是兩條不同路），這批隊人格野心不夠格（<AMBITION_FOUND_MIN），根本不會進那個 gate，gate=0 只是「沒資格進外交流程」，跟①無關。
- **①的真訊號**：`construct.start=14`（dispatch 真發生 14 次）vs **`construct.complete_build=0`**（完工掛零）——**動機層有 fire，卡在執行/完工層**，不是「沒動機」。
- **Q3 同款讀法**：`g1.order_placed=1833`（狂下單）vs `order_fulfilled=0` / `trade.deal=0`（零成交）——**同一種「execution-layer completion 塌陷」嫌疑**，跟①的 construct.start/complete 落差同型。

## 權威 4 問數（seed70730，6mo，43200 tick，end_pop=59，attrition=18.1%，teams=10）
```
【Q1 founding dispatch 嗎】
  indep.found_ally=0 | indep.found_subjugate=0 | indep.found_timeout=0
  indep.gate_ambitious=0 | indep.gate_path_ok=0
  indep.gate_fail_pop=0 | indep.gate_fail_food=0 | indep.gate_fail_busy=0 | indep.gate_fail_nopath=0
  construct.start=14 | construct.complete_build=0 | worldgen.build_outpost=1

【Q2 develop（升級）嗎】
  construct.complete_upgrade_facility=6 | construct.complete_upgrade_level=0

【Q3 貿易/對缺口反應嗎】
  trade.deal=0 | trade.deal_market=0 | trade.deal_merchant=0 | trade.barter_deal=0
  g1.order_placed=1833 | g1.order_fulfilled=0 | g1.shortage_buy=927 | g1.food_buy=103
  g1.seek_market=5 | g1.market_arrive=40

【Q4 runway 機制 fire 嗎】
  foodflow.update=4594 | bridge.no_go_food=0 | bridge.topup=0 | persist.hold=14
```
→ `persist.hold=14` **剛好等於** `construct.start=14`——值得你讀故事時留意：是否每次 founding dispatch 一發生就立刻被 persist 擋住（同一批事件的兩面），還是巧合。

## 逐隊月故事（兩個具體案例，供你稽核 motive→action→outcome）
**T9（mountain）**：runway 9999 → **4.4**（月1）→ **0.0**（月2起，food=0，pop **6→2**）→ 卡在 food=0/runway=0.0 直到月6結束，task 在 `idle`/`治理`/`覓食` 間擺盪但**從未回穩**。

**T0（plains）**：material **0 → 49 → 52**（緩慢爬升，6 個月），但 `need_mat=138` 從未達標；`task=貿易`（trade）持續整場，但 Q3 顯示零成交（`trade.deal=0`）——**T0 一直在嘗試貿易但看不到真的成交發生**，跟 Q3 聚合發現直接對應。

完整逐隊逐月數據見 `docs/measurements/2026-07-30-peaceful-economy-bed-run1.txt`（`--- 月N ---` 區塊，12 隊 × 6 月 + t0）。

## 你要判什麼
1. 讀 T9/T0（以及其他 10 隊）的 motive→action→outcome 逐月變化，判斷經濟行為（founding/develop/trade/runway）是否真的「fire」——別被 `indep.gate_*=0` 誤導成「沒動機」，重點看 `construct.start` vs `complete_build`、`order_placed` vs `fulfilled`。
2. 你判完 → `to:blueprint`（裁分支：economy 有 fire+runway fire → 續 runway；economy 無 → pivot，但 pivot 論證需分清 code-provable 已知缺口 vs 本輪 live 案經驗）。

## 溯源
raw：上列 3 個 run 檔（已驗證存在+determinism）。零 production code 改動（純跑既有 merged bed）。file:line：`peaceful_economy_bed.gd:84-99`（4 問報告）、`:109-149`（逐隊月故事）。
