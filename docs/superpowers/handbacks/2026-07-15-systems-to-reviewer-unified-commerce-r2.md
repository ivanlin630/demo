---
from: systems
to: reviewer
status: open
topic: "[R²·大框結構審·可能升異質] 統一商業框架(market-as-place)——用戶裁整個商業一次進框架(棄hole-by-hole打地鼠);target/resolver/掛單/accessor全收+人格化+de-patch;三對齊大框,你判要不要升異質框外審"
---

# R²：統一商業框架 spec（market-as-place，大架構重構）

> **[worker 守則] 卡住/疑義 → handback `to:systems`,禁 `AskUserQuestion` 中斷用戶（用戶明言再犯上 hook 強制擋）。**

spec：`docs/superpowers/specs/2026-07-15-unified-commerce-framework.md`。
blueprint 願景（用戶裁）：`2026-07-15-blueprint-to-systems-unify-whole-commerce-first.md`（整個商業框架一次做好、所有補釘融入、再量測；骨幹 market-as-place）。
根因鏈（整條經濟調查）：6+ 刀 inert/held（seam/churn/threat/accessor/coin/液化/漫遊），補釘互 confound → 用戶裁整框架一次做。

## ★可能升異質框外審（你判）
這是**大框結構重構**（整個商業子系統 + market 模型從 team-to-team 改 place-based + de-patch 多補釘 + 收斂雙 resolver/三 fallback/5 accessor 縫）。**三對齊**（blueprint 願景 + 用戶裁 + systems HOW）——照兩道閘規則，大框三對齊時你**判要不要升異質框外審**（heterogeneous，防 groupthink 同 Opus 框）。傾向：market-as-place 是 blueprint+用戶明定骨幹（非 systems 自造框），但收斂範圍大、de-patch 多，值得你評異質。

## premise 已 file:line 坐實（整條調查）
`_market_pos` 固定 outpost≠賣方實位(65% measurer)、TAG_MERCHANT=0 真閘 ARCHETYPE_TRADE(:2045)、雙 resolver(:233 board vs :664 到場 + :2078 peer)、accessor 5 縫(order:110/118/252/trade_valuation:86/decision_context:138)、absorb/spill(:724-725)、掛單死常數。

## 審什麼（統一設計）
1. **M1 target 收單一**：`_nearest_market` 選市場 outpost（belief，感知鐵律）收斂三 fallback。**驗**：belief-based 選市場對否（非 god-view 掃全 tile）？固定市場解 65% 漫遊撲空？
2. **M2 resolver 單一（market-as-place）**：`_resolve_market_at_outpost` 買方到 outpost 向 stock 買（免賣方在場），扣 public_storage+coin 給 owner。**驗**：★守恆（扣對 storage、coin 對象）？收斂雙 resolver（旅行目標=成交對象一致）？resident 巧遇次路保留不砍好戲？
3. **M3 掛單人格化 + 廢死常數**：effective_holding+人格門檻、廢 FOOD_SELL_RESERVE_RATIO/FOOD_BUY_DAYS/孤兒 SURPLUS_RESERVE_MULT、reserve 人格化(活命糧 floor)。
4. **M4 accessor 統一 + 去 absorb/spill**：effective_holding 5 縫全收 + spend_holding + local_value 讀它、廢 absorb/spill dance。**驗**：去 absorb 後決策-執行語意對稱守恆？
5. **M5 de-patch 無殘**：held 分支(seam/coin-B/液化)融入 M3/M4、雙 resolver/三 fallback/死常數全拆。**驗**：融入非並存（無殘補釘）？coin 循環降 backlog（先乾淨模型）對否？
6. **觀測/憲法/determinism**：新路徑 specimen tap + 盲點閘、感知鐵律、CoinAudit=0、零 randf。

## 特別看（大框坑）
- **market-as-place 守恆**：貨扣 public_storage、coin 流向 outpost owner——owner team 收 coin（非賣方個人）對否？多買方搶同 stock 的並發（先到先得/board 扣減）？
- **de-patch blast radius**：拆 absorb/spill + 雙 resolver 動既有交易鏈——反向驗（飢荒/戰鬥/既有 trade 測）沒少。
- **範圍**：先有 revive（本刀），後磨（流動 tune/coin/threat）＝revive 後另刀——確認 scope 不膨脹（本刀=統一模型通市場，非一次調到完美）。

## 流向
CLEAN（或升異質後 CLEAN）→ dispatch implementer（feat/unified-commerce）→ measurer 中性 full-HD（★市場 revive + 統一無殘 + 守恆 + 觀測）→ QA → blueprint 批。
premise_contradiction 或守恆漏/de-patch 傷既有 → to:systems halt。
