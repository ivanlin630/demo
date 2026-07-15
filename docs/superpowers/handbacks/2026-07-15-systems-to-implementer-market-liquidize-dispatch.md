---
from: systems
to: implementer
status: consumed
topic: "[DISPATCH] 市場成交條件液化(經濟revive①刀)——R²過(訂正:SURVIVAL_GOODS food+medicine排除保floor);reserve人格化降底+ask/bid液化;新分支feat/market-liquidize;TDD守恆"
---

# Dispatch：市場成交條件液化（經濟 revive ①刀）

> **[worker 守則] 卡住/授權不明/做不到 → handback `to:systems`,禁 `AskUserQuestion` 中斷用戶（用戶明言再犯上 hook 強制擋）。**

spec：`docs/superpowers/specs/2026-07-15-market-liquidize-deal-conditions.md`（★R² 訂正 Fix1 排除 SURVIVAL_GOODS）。
R² 判決：`2026-07-15-reviewer-to-systems-market-liquidize-r2-issues.md`（premise/守恆/determinism CLEAN；唯一 issue=Fix1 漏排除 medicine，已訂正；reviewer 預 clear）。

## 根（經濟 revive 第①刀，成交條件牆）
`TradeValuation.reserve` 非糧=`pop×TARGET_PER_POP` 恰等 local_value target（需 stock>target 才有 surplus→scarce 世界稀少）+ flat 死常數 + ask 貼 bid → deals=3 vs WOULD_TRADE 560。液化=流動為底、摩擦人格質感。

## 在哪：新分支
`feat/market-liquidize`，base 最新 main（`be95606c`+）。

## 做什麼
1. **Fix 1 reserve 人格化+降底（`TradeValuation.reserve`，★只非活命品）**：
   - **`SURVIVAL_GOODS=["food","medicine"]` 保既有 survival-floor**（food 已 `food_security_target`；medicine 補同 survival floor，**不液化不甩活命糧**）。
   - **非活命品**：`reserve = pop×TARGET_PER_POP[res] × reserve_factor` — `reserve_factor` = 貪婪/慎重高、急迫/絕境(低 food_days/缺 coin)低；`RESERVE_BASE<1.0` 降底。TEST VALUE。
2. **Fix 2 ask/bid 液化（`_attempt_trade_direction`）**：commerce 折扣加寬 or willing-deal 偏置（賣有 surplus+買想要→偏成交，`ask≤bid×(1+SPREAD_TOL)` 或折扣隨賣方急迫加深）；摩擦=貪婪守價談崩(少數)/急鬆手。TEST VALUE。carry/qty 摩擦保留。

## 守則
- **★守恆**：成交走既有 `_execute_transfer`（coin↔goods 等值），reserve/ask 只改「要不要賣/賣多少/價」不碰搬運守恆。**CoinAudit=0、InvariantAudit=0**。
- **★不賣活命糧**：SURVIVAL_GOODS floor 保（絕境不甩 food/medicine 到自己餓死/病死）。
- **determinism** 零 randf → 同 seed 兩跑 bit-identical。人格化非 flat。

## TDD
1. 非活命品：賣方有 surplus + 貪婪領袖 → reserve 高(守)；絕境領袖 → reserve 低(鬆手賣) → willing 賣方變多。
2. **★活命糧 floor**：絕境隊 food/medicine reserve 保 survival floor，**不因液化甩光**（構絕境隊斷言 food/medicine 不賣到 floor 下）。
3. ask/bid 液化：willing 對（賣 surplus+買想要）→ 成交（deal fire）；貪婪守價 → 部分談崩(摩擦質感)。
4. CoinAudit=0；同 seed 兩跑 bit-identical；headless 零新增；憲法 sites=29。

## 完成後
→ handback `to:systems` → measurer 中性 full-HD（★deals 大幅回升 + 摩擦質感 + 守恆；數字 systems tune 到 blueprint「willing 大多成交」）→ QA → blueprint 批。
scope 疑義走 `to:systems`。merchant 完成 trade（co-locate）=**下刀②**（非本刀）。coin/accessor=框架債 backlog。
