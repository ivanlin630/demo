# Spec：市場成交條件液化（流動偏摩擦，經濟 revive 第①刀）

status: draft（待 R² → dispatch implementer）
owner: systems
premise_verified: ★file:line 坐實——`TradeValuation.reserve` 非糧＝`pop×TARGET_PER_POP[res]` **恰等於 local_value shortage 的 target**（reserve==target 耦合）；ask<bid 嚴 + reserve 平頭死常數（食物已人格化，非糧全 flat）→ willing 賣方稀少；measurer 死法二 deals=3 vs WOULD_TRADE 560、coin 解禁 370 全落 other_bail
blueprint_vision: `2026-07-15-blueprint-to-systems-market-liquid-friction-sequence.md`（流動為底、摩擦為質感、摩擦人格化：急/絕境鬆手、貪婪守價；成交率數字 systems tune）
governing: `invariants.md`（資源守恆 — 成交只搬不生）+ 決策模型（門檻人格化非死常數）

## 根因（成交條件牆，code-verified）
`_attempt_trade_direction` 成交需三關 AND：①**surplus**＝`stock − reserve > 0`（`reserve=TradeValuation.reserve`）②**ask<bid**（`ask=seller_lv×(1−commerce·0.1)`、`bid=buyer_lv`）③buyer coin/carry。
- **reserve 非糧＝`pop×TARGET_PER_POP`＝恰等 local_value 的 target**（耦合）→ 賣方需 stock>target 才有 surplus，scarce 世界 stock≈target → **無 surplus → willing 賣方稀少**（死法二 no_surplus/price 牆）。
- **reserve 非糧全 flat 死常數**（食物 `food_security_target` 已人格化，非糧沒有）→ 不隨人格/急迫調（貪婪該守、絕境該鬆，現全一樣）。
- **commerce 折扣僅 10%** → ask 貼 bid 上緣（T1↔T7 樣本 ask 3.475 vs bid 3.39 差 2.5%）→ 邊際 willing 對常談崩。

## Fix（流動為底 + 摩擦人格化，blueprint 願景）

### Fix 1：reserve 液化 + 人格化（非糧，鏡射食物已人格化先例）
非糧 reserve 從 flat `pop×TARGET_PER_POP` → **人格化 + 降底**：
- `reserve = pop × TARGET_PER_POP[res] × reserve_factor(leader_values, urgency)`。
- **`reserve_factor`**：貪婪/慎重 → 高（守貨守價）；**急迫/絕境**（低 food_days / 缺 coin 壓力）→ 低（鬆手賣換 coin/糧）。baseline `RESERVE_BASE < 1.0`（降底 → 願賣方變多 = 流動為底）。
- ∴ willing 賣方（有 surplus）大增，貪婪囤/絕境甩＝人格戲（blueprint「摩擦人格化」）。

### Fix 2：ask/bid 液化（willing 對大多成交，摩擦=少數有理由）
- **commerce 折扣加寬 or 加 willing-deal 偏置**：當賣方有 surplus + 買方真想要（`bid > seller BASE 或 buyer shortage>0`）→ **偏向成交**（deal zone 放寬，ask≤bid×(1+SPREAD_TOL) 或折扣隨賣方急迫加深）。
- **摩擦=人格質感**：**貪婪賣方守價**（ask 折扣小，貼 bid → 部分談崩＝有理由的摩擦）；**急/絕境賣方鬆手**（折扣深 → 好成交）。價差談崩變少數且有人格因。
- carry/qty 摩擦保留（運力真限，blueprint「運力的少數且有理由」）。

## 平衡（blueprint：流動為底，摩擦質感）
- **流動為底**：willing 夥伴（賣有餘+買想要）**大多成交**（現 560→3 死常數不對齊 → 目標大幅拉高成交率）。
- **摩擦為質感**：價差/餘量/運力摩擦＝**少數 + 有人格理由**（非普遍死牆）。
- 全 TEST VALUE（RESERVE_BASE/reserve_factor 係數/SPREAD_TOL）→ **measurer tune 到「willing 大多成交」**（systems tune 數字，blueprint 定質感）。

## invariant 守
- **資源守恆**：成交走既有 `_execute_transfer`（coin↔goods 等值搬），CoinAudit=0、InvariantAudit=0。
- **determinism**：reserve/ask 純人格+狀態算，零 randf → 同 seed 兩跑 bit-identical。
- **人格驅動**：reserve/折扣掛人格（非 flat 死常數）＝合決策模型。

## 驗收（★中性 full-HD + 守恆）
1. **★deals 真發生**：`trade.deal`（resident 路先，merchant 路待第②刀）從 3 大幅回升；willing 對成交率大幅升（WOULD_TRADE→deal 對齊）。
2. **摩擦質感**：談崩變少數 + 人格可讀（貪婪守價談崩 vs 絕境鬆手成交，specimen 差異）。
3. **★守恆**：CoinAudit=0、InvariantAudit=0。
4. **不失控**：不變成「無腦全成交」（貪婪/運力摩擦仍在）；不誤傷（不賣到自己餓 = reserve 人格 floor 保絕境不甩光活命糧）。
5. **無回歸**：同 seed 兩跑 bit-identical、憲法 sites=29、headless 零新增。
6. **中性世界判**。

## dispatch 註
- 新分支 `feat/market-liquidize`，base 最新 main。
- **R²**（機制/tuning，標準審）：dispatch 前 to:reviewer 審設計（reserve 人格化守恆/不賣活命糧、ask/bid 液化不失控、determinism）。premise file:line 坐實→免 R①。
- 完成判定 = systems + reviewer + measurer（中性 full-HD：deals 大幅回升 + 摩擦質感 + 守恆；systems tune 數字到 blueprint「willing 大多成交」）+ blueprint 批。
- **序**：①本刀（成交條件液化，普世閘 = resident 路先活）→ ②merchant 完成 trade（下刀，merchant 路 co-locate，blueprint 預授）。
- coin/accessor = 框架債 backlog（非本刀）。
