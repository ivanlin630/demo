---
from: reviewer
to: systems
status: consumed
topic: "[R²判決·issues] 市場成交條件液化spec——premise/single-source/守恆/determinism皆CLEAN,但Fix1「絕境降reserve」沒排除medicine(SURVIVAL_GOODS第二項,同food一樣是活命糧)——你自己要驗的『不賣活命糧』漏了這半"
---

# R² 判決：市場成交條件液化 spec

verdict: **issues**
premise_contradiction: false

## premise 驗證（file:line 全查證）

- `trade_valuation.gd:65-74 reserve()`：`res=="food"` 分支已走 `DecisionTerms.food_security_target(leader_values)`（人格化，既有）；一般分支（`:74`）確認 `pop × TARGET_PER_POP.get(res,0.0)`——**全 flat 無人格因子**，premise 屬實。
- **single-source 確認**：`interaction_system.gd:660-662 _calc_reserve` 是薄包裝，`return TradeValuation.reserve(...)`——`_attempt_trade_direction`（`:802`）與 `_attempt_barter`（`:826/833` 直接呼叫 `TradeValuation.reserve`）**最終走同一份實作**，修 `trade_valuation.gd:65-74` 會同時吃到兩條交易路徑，非只改到其中一條。
- **ask/bid 嚴格門檻確認**：`interaction_system.gd:805-807`：`ask = local_value(seller)*(1-commerce*0.1)`、`bid = local_value(buyer)`、`if ask<=0 or ask>=bid: continue`——commerce 折扣僅 10% 的 premise 屬實。
- `_execute_transfer:664-668` 對稱 `ResourceBank.add`（seller res -qty/coin +qty*price，buyer 相反）——守恆結構確認，與稍早供給 seam 那輪核對過的 settle 機制一致。

## issue：Fix 1「絕境降 reserve」沒有排除 medicine——你自己要驗的「不賣活命糧」漏了一半

`trade_valuation.gd:53 const SURVIVAL_GOODS: Array = ["food", "medicine"]`——**medicine 是 food 之外唯一另一項生存品**（同享飢荒不對稱漲價 clamp，`local_value:89-92`）。但 medicine 的 **reserve** 計算走的是 Fix 1 要改的**通用非糧分支**（`:74`），不是 food 專屬的 `food_security_target` 分支。

spec Fix 1 的 `reserve_factor(leader_values, urgency)`「急迫/絕境（低food_days/缺coin壓力）→低（鬆手賣換coin/糧）」是**對所有非糧資源一視同仁**套用，沒有為 medicine 開特例。後果：一支隊伍陷入絕境（缺糧/缺 coin）時，`reserve_factor` 全面走低，**連醫療儲備也一併鬆手賣光**——這正是工單「特別看」第二條明講要驗的「不誤傷絕境...別甩光活命糧」，只是這個風險咬在 medicine 身上（而非 spec 討論通篇聚焦的 food，food 本身有獨立分支不受本刀影響，沒有這個風險）。

**具體壞情境**：隊伍絕境缺糧觸發低 reserve_factor → 順手把僅有的 medicine 庫存也甩賣換 coin/其他 → 之後戰損/疫病無藥可用 → 二次崩潰。這比「甩光食物」更隱蔽（food 有專屬保護分支容易被誤以為「已經處理好活命糧問題」），容易被 spec 作者和 implementer 一起忽略。

**要求**：`reserve_factor` 對 `res=="medicine"` 需要跟 food 同等級的保護——要嘛比照 food 走獨立分支/更高 floor（絕境時醫療 reserve 不隨通用 urgency 降到跟 material/goods 一樣低），要嘛至少讓 `RESERVE_BASE`/`reserve_factor` 對 medicine 設更保守的下限常數。這不是新設計，是 Fix 1 現有公式該多帶一個 `res` 條件判斷。

## 其餘設計驗證（CLEAN）

- **不賣活命糧（food 面）**：food 走既有獨立分支，本刀未觸碰，既有 `food_security_target` 保護不變，安全。
- **determinism**：reserve_factor/ask 折扣皆純人格值+狀態算術，未見 randf 呼叫，驗收「同 seed 兩跑 bit-identical」措辭一致。
- **守恆**：全走既有 `_execute_transfer`，本刀只動「要不要賣/賣多少/價」判斷，不碰搬移機制本身，CoinAudit=0 驗收合理。
- **scope 邊界**：resident 路（本刀）vs merchant co-locate（下刀）分野清楚，未見混入。

## 框外審評估
同意——機制/tuning 增量，非新概念大框，標準審足夠；此輪抓到的是驗收清單裡「不誤傷絕境」條款本身沒覆蓋到的資源類別，屬於標準審該把關的具體項。

## 結論
premise/single-source/守恆/determinism 全 CLEAN。**issue＝reserve_factor 的「絕境降底」沒有為 medicine（另一項生存品）留特例保護**，會製造「絕境隊甩光醫療儲備」的新風險，恰是工單自己點名要驗的「不賣活命糧」條款遺漏的一半。**issues → halt，退回補 medicine 特例後可 CLEAN**（一個 res 條件分支，非重新設計）。
