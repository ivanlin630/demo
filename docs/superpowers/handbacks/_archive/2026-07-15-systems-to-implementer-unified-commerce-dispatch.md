---
from: systems
to: implementer
status: consumed
topic: "[DISPATCH·大架構] 統一商業框架(market-as-place)——R²過(異質框外審+round2,9項全補+矛盾訂正);target/resolver/掛單/accessor全收+de-patch+人格化;新分支feat/unified-commerce worktree;TDD守恆"
---

# Dispatch：統一商業框架（market-as-place，大架構重構）

> **[worker 守則] 卡住/授權不明/做不到 → handback `to:systems`,禁 `AskUserQuestion` 中斷用戶（用戶明言再犯上 hook 強制擋）。**

spec：`docs/superpowers/specs/2026-07-15-unified-commerce-framework.md`（★完整讀，M1-M5 + kill-list + 驗收，含 R² 異質框外審 3 缺口 + 6 項 + 矛盾訂正全補）。
R² 判決：異質框外審 `2026-07-15-reviewer-to-systems-unified-commerce-r2-issues` + round2 CLEAN `2026-07-15-reviewer-to-systems-unified-commerce-round2-issues`（9 項核對全補齊，一行矛盾訂正已修）。

## 這是經濟 revive 主刀（用戶裁整框架一次做，非 hole-by-hole）
6+ 刀 hole-by-hole 全 inert（打地鼠+互 confound）→ 用戶裁整個商業框架一次做好+補釘融入+人格化+再量測。骨幹＝market-as-place（貨在 outpost、買方到市場買/賣、免賣方 team 在場，解 65% 漫遊）。

## 在哪：新分支 worktree（大檔面）
`feat/unified-commerce`，base 最新 main（`bbf098ca`+）。**大檔面**：order_system/interaction_system/trade_valuation/faction_ai/decision_context + accessor + invariants。worktree。

## 做什麼（照 spec M1-M5，重點）
- **M1 target 單一**：`_nearest_market` 選市場 outpost（保 `_nearest_market_outpost` 公開地標豁免，**寫進 invariants 豁免清單**）；收斂三 fallback。
- **M2 resolver 單一 market-as-place**：`_resolve_market_at_outpost`（owner-mediated 雙側：訪客買向 stock/sell 單、★訪客賣向 owner buy 單→coin 雙向）；**履約按 order_id 權威側直沖 active_orders+board**（settle_orders 降級巧遇路）；min(單餘,現貨)+無單不賣+SURVIVAL 要有單；withdraw 實量計價；無主 coin→public_storage.coin；巧遇/市場交界明文（outpost tile=market 專屬）。
- **M3 掛單人格化**：effective_holding+人格門檻、reserve 人格化（活命糧 floor）。
- **M4 accessor 統一 6 縫**（含 `_can_trade:2031` 殭屍公式）+ spend_holding + local_value 讀它 + 廢 absorb/spill。
- **M5 de-patch kill-list**（spec 列全：SURPLUS_RESERVE_MULT/FOOD_SELL_RESERVE_RATIO/FOOD_BUY_DAYS/FOOD_BUY_TARGET_DAYS/SHORTAGE_QTY/×0.5/20.0/TRADE_MIN_STOCK/arb×0.1/MERCHANT_MAX_RANGE 兩處收單一）；held 分支(seam/液化)融入 M2/M3/M4；coin-B 降 backlog。
- **probe**：deal_merchant/merchant_inventory 改按 ARCHETYPE_TRADE（TAG_MERCHANT 全 0）。

## 守則
- **★資源守恆**：全走 ResourceBank/TileBank chokepoint，coin/goods 只搬。**CoinAudit=0、InvariantAudit=0**（硬驗）。
- **感知鐵律**：市集=公開地標豁免（誠實入 invariants）；敵情/社交仍 belief（god-view 不回退）。
- **觀測**：新 resolver/target/掛單接 specimen tap + 盲點閘綠 + on/off byte-identical。
- **determinism** 零 randf → 同 seed 兩跑 bit-identical。
- **de-patch 反向驗**：拆 absorb/雙 resolver 動既有交易鏈 → 飢荒/戰鬥/既有 trade 測沒少。

## TDD（★守恆 + 半環 + 履約）
1. 買方到市場 outpost → 向 stock 買（deal fire，扣 public_storage，coin→owner，守恆）。
2. **★訪客賣**→向 owner buy 單賣（貨入 storage，owner.coin→visitor，套利閉合）。
3. 履約 order_id 直沖（sell/buy 單成交即沖不掛幽靈）。
4. SURVIVAL_GOODS 無單不賣（活命糧不買穿）。
5. 巧遇/市場路不雙沖。
6. CoinAudit=0/InvariantAudit=0；同 seed 兩跑 bit-identical；headless 零新增；憲法 sites 稽核。

## 完成後
→ handback `to:systems` → measurer 中性 full-HD（★市場 revive + 統一無殘 + 守恆 + 觀測 + coin 單向泵風險長窗觀測）→ QA → blueprint 批。**大檔面，scope 疑義隨時 to:systems（大框寧可多轉）。** coin 循環/流動摩擦 tune/threat 韌性＝revive 後另刀。
