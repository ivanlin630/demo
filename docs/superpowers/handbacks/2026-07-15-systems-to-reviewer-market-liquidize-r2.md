---
from: systems
to: reviewer
status: consumed
topic: "[R²·設計審] 市場成交條件液化(經濟revive①刀)——reserve人格化+降底(willing賣方變多)+ask/bid液化(willing大多成交,摩擦人格質感);★守恆+不賣活命糧;premise file:line坐實免R①"
---

# R²：市場成交條件液化 spec

> **[worker 守則] 卡住/疑義 → handback `to:systems`,禁 `AskUserQuestion` 中斷用戶（用戶明言再犯上 hook 強制擋）。**

spec：`docs/superpowers/specs/2026-07-15-market-liquidize-deal-conditions.md`。
blueprint 願景：`2026-07-15-blueprint-to-systems-market-liquid-friction-sequence.md`（流動為底、摩擦質感、人格化）。
真根定音：coin 紅鯡魚(reconcile)、deal 條件牆(deals=3 vs WOULD_TRADE 560)。

## premise 已 file:line 坐實（免 R①）
`TradeValuation.reserve` 非糧＝`pop×TARGET_PER_POP` **恰等 local_value target**（reserve==target 耦合→需 stock>target 才有 surplus→scarce 世界稀少）；reserve 非糧全 flat（食物已人格化）；commerce 折扣 10% ask 貼 bid（樣本差 2.5%）。

## 審什麼（機制/tuning，流動偏摩擦）
1. **Fix 1 reserve 人格化+降底**：非糧 reserve `×reserve_factor(貪婪/慎重高、急/絕境低)` + `RESERVE_BASE<1.0` 降底。**驗**：鏡射食物 `food_security_target` 已人格化先例一致？**★不賣活命糧**——降底/絕境鬆手會不會讓隊甩光自己需要的貨（reserve 人格 floor 保絕境不甩活命糧）？守恆（surplus 算改不碰 _execute_transfer 守恆）？
2. **Fix 2 ask/bid 液化**：commerce 折扣加寬 or willing-deal 偏置（賣有 surplus+買想要→偏成交），摩擦=貪婪守價談崩(少數有理由)/急鬆手。**驗**：不變「無腦全成交」（貪婪/運力摩擦仍在）？ask≤bid×(1+SPREAD_TOL) 或折扣隨急迫——哪個乾淨？
3. **★守恆**：成交走既有 `_execute_transfer`，CoinAudit=0。**驗**：reserve/ask 改只動「要不要賣/賣多少/價」，不動 coin↔goods 等值搬？
4. **determinism**：reserve/折扣純人格+狀態零 randf → 同 seed 兩跑 bit-identical。

## 特別看
- **流動 vs 摩擦平衡**：blueprint 定「willing 大多成交、摩擦少數質感」——設計是否留得住摩擦（貪婪/運力）而非液化到無摩擦？tune 空間（TEST VALUE）留給 measurer。
- **不誤傷絕境**：reserve 降底 + 絕境鬆手——絕境隊該賣餘貨換活命糧/coin（好），但**別甩光活命糧**（reserve 對 food/活命品仍 floor）。驗這條 gate。
- **序**：本刀＝resident 路成交條件（普世閘）；merchant 路 co-locate＝下刀（不在本刀）。確認 scope 不混。

## 流向
CLEAN → dispatch implementer（feat/market-liquidize）→ measurer 中性 full-HD（deals 大幅回升 + 摩擦質感 + 守恆；systems tune 數字到 willing 大多成交）→ QA → blueprint 批。
premise_contradiction 或守恆漏/失控 → to:systems halt。
