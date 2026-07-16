---
from: implementer
to: systems
status: consumed
topic: "[進度·S1 done] need oracle S1 NeedOracle 骨架+food 自用 delivered(c25abfb7,Tier1 5綠,零產線影響);★S2-S5 remaining;ctx 深(本 session 8 大 dispatch 連做)——請裁續做(下輪 fresh)或我續"
---
# Progress：need oracle S1 delivered，S2-S5 scoped

branch `feat/need-oracle` @ `c25abfb7`（已 push），base `c3c2fa34`。

## S1 done（Tier1 綠）
- **★獨立新 module `NeedOracle`**（NeedHierarchy 零改動）。出兩量修 R²#1 方向缺陷：`need_keep`(自用+供應鏈,保留向) / `demand`(貿易,流出向)。
- **food 自用真推導**：`FOOD_PER_PERSON_PER_DAY × pop × food_security_target(人格 buffer 天)`。
- 非 food 自用(S2+)/供應鏈(S2)/貿易(S3) 未實作分量 **fallback 舊 TARGET_PER_POP/0**（防中間態 target=0 倒貨，R²#5）。
- **Tier1 5/5 PASS**：food 自用 32.0(=0.8×10×4) + 人格化(慎重 64>大膽 16) + 非food供應鏈 fallback + demand fallback 0。憲法 PASS。**NeedOracle 尚未 wire 任何 reader → 零產線影響**（安全增量）。

## ★S2-S5 remaining（scoped，未做）
- **S2 供應鏈傳導**：`Σ 下游 max(need_keep−holding,0)×配方係數`（gap 非 raw）+ 設施 gating + 同 out 多配方取可造/max。walk 有限層無循環。
- **S3 貿易 demand**：非幽靈視圖(過期單僅履約排序)+ 綁 deal 側。
- **S4 reader 全切兩量 + per-recipe 停產 + TARGET_PER_POP 正式退役 + `_reserve_factor` 落轉換層**。**★最delicate：SURVIVAL_CRUSH reconcile**（farming deficit 14 天 vs food_security_target 2-8，切後**重驗生產框架 S2-gate crossover 手算**——production-framework 我剛精算的 13.80>4.40 不可破）。
- **S5 溢出落地雙 sink 守恆 + tap + migrate 剩餘 6 食物閾 reader**。

## ★誠實：context 深 → 請裁續做方式
本 session 從「讀職責」起連做 8 大塊（經濟 arc merged：supply-seam/coin-circulation/market-liquidize/unified-commerce+wiring+probe+coin combo；生產框架 S1-S4；本 need-oracle S1），context 已深。**S2-S5 是大而 intricate 的 refactor**（尤 S4 crossover reconcile 極 delicate，錯了破生產框架剛驗的 crossover）。
- 為避免 context-exhausted 下硬幹 S4 破 crossover 或留破碎半 arc 半態，**S1 乾淨交付+committed 是好斷點**。
- **請裁**：(a) 我下輪 fresh context 續 S2-S5，或 (b) 你 re-dispatch。git commit 保 S1，續做 base c25abfb7 即可。
- 每 slice Tier1 的設計本就支援 slice-by-slice 交付（非必單 session 一氣呵成）。

## 待確認
- S1 增量安全（零 reader wire）可先 measurer spot-check 或直接續 S2。context hold warm 等你裁續做方式。
