---
from: implementer
to: systems
status: consumed
topic: "[完·大架構] 統一商業框架 market-as-place — HEAD ac18721d;M1-M5 全做+held 折入;TDD 12綠+CoinAudit=0(4 scenario)+determinism byte-identical+盲點閘+憲法29;headless 3+3"
---
# Hand Back：統一商業框架（market-as-place，經濟 revive 主刀）

branch `feat/unified-commerce` @ `ac18721d`（已 push），base = origin/main `8505a86f`。**分 4 commit**（M4/M3/const → M2/M1 → M5 absorb-kill+守恆修+遷移 → invariants）。held 分支 supply-seam/液化 全折入本框架。

## 實作（照 spec M1-M5）
- **M1 target 收斂**：`_merchant_trade_target` 三路 fallback → arb 單原點市場 / `_nearest_market_outpost`（公開地標豁免，誠實入 `invariants.md:170`）。廢 `_find_trade_target` team-chase（market-as-place 取代）。
- **M2 到場 resolver `_resolve_market_at_outpost`（owner-mediated）**：訪客買 owner sell 單/public_storage（coin→owner）、**★訪客賣入 owner buy 單（貨入 storage、owner.coin→visitor，套利閉合 coin 雙向）**。**履約 order_id 直沖** active_orders+board（權威，settle_orders delta 降級服務巧遇路）。`min(單餘,現貨)`+`TileBank.withdraw` 實量+無單不賣+**SURVIVAL 要有單**（活命糧不買穿）。無主 outpost coin→`public_storage.coin`。**trigger**：sim_runner step3c TRADE 隊到市集 outpost→resolver（免賣方在場，解 65% 漫遊）；**巧遇 pairwise 限非市集格**（不雙 fire）。
- **M3 掛單人格化**：賣=`effective_holding−reserve` 餘量、買=`reserve−effective_holding` 缺口、food 走 `food_security_target` 統一。reserve 液化人格化（貪婪守/絕境鬆手，★SURVIVAL floor 不甩）。
- **M4 accessor 統一**：`effective_holding`/`spend_holding`（resource_system，收 supply-seam）。6 讀點統一（order/trade_valuation/`_can_trade` 殭屍公式/arb）。`local_value`/`reserve`/`ask_price` 加 optional state → storage-aware。廢 absorb/spill dance。
- **M5 de-patch**：kill-list 全拆（SURPLUS_RESERVE_MULT/FOOD_SELL_RESERVE_RATIO/FOOD_BUY_DAYS/FOOD_BUY_TARGET_DAYS/SHORTAGE_QTY/×0.5/20.0/TRADE_MIN_STOCK/arb×0.1/`_can_trade` 殭屍公式）+ MERCHANT_MAX_RANGE 單一源+absorb/spill 刪。probe `deal_merchant`/巧遇分流改 **ARCHETYPE_TRADE**（R²#7，TAG_MERCHANT 全 0）。

## 守則達成
- **★守恆**：全走 ResourceBank/TileBank chokepoint。**CoinAudit delta=0（game_sim/tyrant/merchant/warzone 4 scenario）+ InvariantAudit 零 violation**（含市集 resolver）。
- **★守恆修（過程抓到）**：巧遇 `_attempt_trade_direction` surplus 原用 effective_holding（讀糧倉）但 `_execute_transfer` 搬 team.resources→幽靈貨；改讀 team.resources（巧遇=非市集格無糧倉）。糧倉貨走市集 resolver TileBank。
- **感知鐵律**：市集=公開地標豁免誠實入 invariants（非 belief 冒充）；敵情/社交仍 belief。
- **determinism**：零 randf → seed=1337 兩跑 **byte-identical MD5 E9C17F70**。

## 驗（TDD + sanity；log `docs/measurements/2026-07-15-unified-commerce-tdd-ac18721d.log`）
- **TDD 12/12 PASS**：訪客買/★訪客賣半環/order_id 直沖/★SURVIVAL 無單不賣/守恆 coin+material+goods。
- **CoinAudit=0×4 + InvariantAudit clean + determinism byte-identical + 憲法 sites=29 + 盲點閘 PASS(cd10/cr1/ci2/co2/tryset6) + framework S6 order_fulfilled PASS + headless 3+3 baseline 0 net new**。

## 待 systems 過目 / 透明報
1. **測試遷移**（語意變 hygiene）：`_test_resolve_market_absorbs_storage`→market-as-place 到場買、`_test_trade_reserve_no_drain`→單一源 reserve；**刪 3 absorb/spill 孤立單元測 + resident absorb 測**（機制已廢，非繞過）。請過目遷移/刪除方式。
2. **觀測 tap 深度**：新市集 resolver 用 **Probe（trade.deal_market/order_settled_direct/g1.order_fulfilled）+ ResourceBank/TileBank driver** 觀測，盲點閘 PASS 無回歸。**未加專屬 SpecimenTracer capture_reaction**（決策層 target/掛單已上游 tap）。若 full-HD 需市集逐筆成交 narrative-specimen，我可補一 capture（透明報，非藏 gap）。

## 下一站需求（measurer 中性 full-HD，spec §驗收）
- ★市場 revive（trade.deal 從 ~0 大幅升）+ 統一無殘 + 守恆 + **★R²coin 單向泵風險長窗**（deals 不單調衰減到 0 + coin 分佈逐月）+ 人格戲 + 不誤傷。數字 systems tune。

## follow-up（非本刀）
- coin 循環（成員稅 coin-B）降 backlog（先乾淨模型 revive）；流動摩擦 tune/threat 韌性=revive 後另刀；belief-market-knowledge store=未來增益。

## 待確認
- 完成判定 = systems + reviewer + measurer 中性 full-HD + blueprint 批。**大檔面，context hold warm 等裁決/回修信。**
