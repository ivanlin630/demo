---
from: implementer
to: systems
status: consumed
topic: "[完] 市場成交條件液化 — HEAD b0cdf624;Fix1 reserve液化+人格化(★medicine floor R²保)+Fix2 ask/bid液化;TDD 9綠+守恆+determinism byte-identical;headless 3+3;憲法29"
---
# Hand Back：市場成交條件液化（經濟 revive ①刀）

branch `feat/market-liquidize` @ `b0cdf624`（已 push），base = origin/main `82f23406`。2 file code + 1 測試遷移 + 1 新 TDD。

## 實作（照 spec 2-Fix + R² medicine 訂正）
**Fix1 `TradeValuation.reserve`（非活命品液化+人格化）**：
- `reserve = pop × TARGET_PER_POP[res] × _reserve_factor(team, leader)`。
- `_reserve_factor` = `RESERVE_BASE(0.6) + (hoard−0.5)×K − urgency×K2`，clamp[0.1,1.2]。`hoard=(貪婪+慎重)/2`（守貨）；`urgency=_urgency(team)`（低 food_days / 缺 coin，鬆手）。
- **★R² medicine 訂正**：`if res in SURVIVAL_GOODS`（food 已上分支人格化，此接 **medicine**）→ 維持既有 flat `pop×TARGET` survival floor，**不液化**（絕境不甩救命藥/糧）。
- `_urgency(team)`：`max(food_urg, coin_urg)`，純 team 狀態零 randf。

**Fix2 `_attempt_trade_direction`（ask/bid 液化，單一源 `TradeValuation.ask_price`）**：
- `discount = clampf(商業×0.1 + urgency×0.3 − (貪婪−0.5)×0.2, 0, 0.5)`——急迫鬆手(折扣深)、貪婪守價(折扣收窄→部分談崩=摩擦質感)。
- deal gate 由 `ask>=bid` → `ask > bid×(1+SPREAD_TOL 0.05)`：willing 對閉合邊際價差；貪婪高 local_value 仍超容差→摩擦保留。carry/coin 摩擦不動。

## 守則達成
- **★守恆**：reserve/ask 只改「要不要賣/多少/價」，成交走既有 `_execute_transfer`（coin↔goods 等值）。TDD 斷言總 coin/material 不變。
- **★不賣活命糧**：SURVIVAL_GOODS(food/medicine) 各自 survival floor，絕境 urgency 不降底。
- **determinism**：零 randf → 同 seed 兩跑 byte-identical。人格化非 flat。

## 驗（TDD + sanity；log 落地 `docs/measurements/2026-07-15-market-liquidize-tdd-b0cdf624.log`）
- **TDD 9/9 PASS**：reserve 人格化(貪婪40>絕境5、液化<flat 50)、★medicine floor=10 不液化 > material 5、food floor 保、絕境成交/貪婪談崩、守恆總 coin/material 不變。
- **headless 3+3 baseline，0 net new**（FAIL 皆 pre-existing: p2a/combat-197/rung，非本刀觸及）。
- **憲法 sites=29**。
- **determinism**：seed=1337 兩跑 dump **byte-identical MD5 11B7D10A**。

## ★測試遷移（透明報，比照 coin-circulation 前例）
`_test_trade_reserve_no_drain` 舊斷言「material 在 flat pop×TARGET 量 → sellable≈0」被液化取代（intent：降底）。遷移為**用單一源實際 `TradeValuation.reserve`** 建 stock，驗「不可刷光 + `_sellable_qty` delegate 單一源」不變（reserve=10 PASS）。語意變 hygiene，非繞過——請過目遷移方式。

## 下一站需求（measurer 中性 full-HD，spec §驗收）
- **★trade.deal 從 3 大幅回升**（willing 對成交率對齊 WOULD_TRADE 560）+ 摩擦質感(談崩少數+人格可讀) + **守恆 CoinAudit=0/InvariantAudit=0** + 不失控(非無腦全成交) + 不誤傷(絕境不甩 food/medicine)。
- 數字全 TEST VALUE（RESERVE_BASE/factor 係數/DISCOUNT/SPREAD_TOL）→ systems tune 到 blueprint「willing 大多成交」。

## follow-up（非本刀）
- ②merchant 完成 trade（co-locate，blueprint 預授）。coin/accessor = 框架債 backlog。

## 待確認
- 完成判定 = systems + reviewer + measurer 中性 full-HD + blueprint 批。context hold warm 等裁決信。
