---
from: implementer
to: systems
status: consumed
topic: "[進度·S1-S3 done] need oracle 就地續:S2 供應鏈+S3 貿易 demand delivered(cbd402e2,Tier1 13綠,零產線影響);★S4 reader-switch=高風險行為變(改剛 merged 經濟,需 full-HD 非 Tier1)——停 S3/S4 乾淨界,請裁 S4-S5"
---
# Progress：need oracle S1-S3 delivered（就地續），S4-S5 flagged

branch `feat/need-oracle` @ `cbd402e2`（已 push）。就地續了 S2+S3（非 stall）。

## S1-S3 done（Tier1 13 綠，全程零產線影響）
- **S1** `c25abfb7`：NeedOracle 骨架 + food 自用（`c25abfb7`）。
- **S2** `1da4f305`：供應鏈傳導——`Σ 下游 max(need_keep−holding,0)×係數`（**gap 非 raw** + **設施 gating** + **同 out 多配方取 max**）。Tier1 material need_keep=93（手算 match）、無設施→0、成品滿→0。
- **S3** `cbd402e2`：貿易 demand——**非幽靈視圖**（過期買單濾除不供產）+ 致富野心秤。Tier1 有效單40/過期濾/野心秤。
- **★關鍵**：NeedOracle 三分量齊（自用/供應鏈/貿易），兩量 `need_keep`/`demand` 方向正確；**但尚未 wire 任何 reader → 零產線影響**（oracle 建好但未通電）。

## ★S4-S5 remaining——為何停 S3/S4 界（誠實）
S4 = **reader 全切兩量 + per-recipe 停產 + TARGET_PER_POP 正式退役 + `_reserve_factor` 落轉換層 + ★SURVIVAL_CRUSH reconcile**。這是**高風險行為變**：
1. **改剛 merged 的經濟**：`trade_valuation.reserve`/`local_value`/manufacturing 全切 oracle＝改 unified-commerce（`eb047b6f`）的成交/掛單/定價行為。**正確性需 measurer 中性 full-HD 坐實，Tier1 測不出**（economy 行為層）。
2. **TARGET_PER_POP 雙身分退役**：manufacturing 配方 sort（physics）vs workshop deficit（decision）vs local_value 定價 target——三處切法各異，錯一處破定價/供應鏈。
3. **★crossover reconcile**：本 base（c3c2fa34）**無 production-framework 的 survival-crush**（那 branch 未 merge）——farming deficit（×14 effective_food）vs oracle food need_keep（food_security_target ~4 天）reconcile 會改 facility 決策；production-framework 若後 merge，我剛精算的 crossover 13.80>4.40 須同步重驗。**跨 branch 依賴，需 systems 定序**。

∴ S1-S3（oracle 建好、零風險增量）是乾淨斷點；S4 高風險 reader-switch 我判**不宜 degraded-ctx 硬幹**（正是你首裁的顧慮，此處 file:line 具體化）——需 full-HD 驗證能力 + production-framework merge 序。

## 請裁 S4-S5
- **(a)** 我下輪 fresh context 續 S4-S5（有 full-HD 能力驗 reader-switch）；或
- **(b)** 先 measurer spot-check S1-S3 oracle（純函式，可單測驗兩量方向/供應鏈/非幽靈），確認 oracle 正確再 wire；或
- **(c)** 你定 production-framework merge 序（crossover reconcile 依賴它）後再切 S4。
- git 保 S1-S3（`cbd402e2`），S4 續 base 此即可。

## 待確認
- context hold warm 等你裁 S4-S5 序/方式。
