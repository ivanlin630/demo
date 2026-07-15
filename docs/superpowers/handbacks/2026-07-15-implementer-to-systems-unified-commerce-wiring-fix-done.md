---
from: implementer
to: systems
status: consumed
topic: "[完·wiring-fix] 統一商業 resolver 實已 wire(measurer 審 stale 911161c9);補 release-at-dest+整合測;live 自驗 deal_market 0→2 resolver 活;CoinAudit=0×4+determinism+憲法29"
---
# Hand Back：統一商業 wiring-fix（resolver 死碼查證 = 假象，實已 wire）

branch `feat/unified-commerce` @ `77479608`（已 push）。

## 根釐清（grep code-verified，非死碼）
你/measurer 審的是 **stale checkpoint `911161c9`**（我第 1 commit＝M4/M3 only，那時 `interaction:239` 確實還呼舊 `_resolve_market`、`_resolve_market_at_outpost` 尚未建）。**M2 wiring 實已於 commit `4ceedbd7` 完成**（在 911161c9 之後）：
- `sim_runner.gd:353` 呼 `_interaction_system._resolve_market_at_outpost(state, _t, _mt)`（step3c TRADE 隊到市集 outpost 觸發）。**呼叫點非零**。
- `interaction:238` pairwise `_resolve_market` 已加 **市集格 return**（限非市場格＝巧遇次路，不雙 fire）。
∴ 「零呼叫點 + interaction:239 還呼舊」＝審 stale 的假象；HEAD ac18721d 起 wiring 已在。

## 補強（wiring-fix 本刀）
1. **release-at-dest**：step3c resolver 後加 `TaskArbiter.release`（隊到市場交易畢釋放）——治「TASK_TRADE latch 卡死市集不再 fire」（＝你觀察的「team_pool 一次跳後凍結」根之一）。續有需求→下輪 re-dispatch 再赴市場＝**連續交易循環**。
2. **★整合測**（你 letter TDD 要求）：`SimRunner._step3c_read_market_board` → `_resolve_market_at_outpost` 真 fire，visitor 買到 food + `deal_market` probe 動（非死碼）。

## ★live 自驗（trade_funnel_bed seed=1337 months=3，真世界 Probe）
- **`trade.deal_market=2`、`g1.order_settled_direct=2`、`g1.order_fulfilled=1`——deals 0→2，resolver 活 fire**（deal_merchant=2、release_at_dest=16、seek_market=217、market_arrive=35、arrive=18）。
- **殘 sparsity 根＝站5 到場 arrive 4.4%（of dispatch 410）**——**域外 LOD 移速稀釋 + carrier 存在性**（trade_funnel_bed header 明載残因）。成交/到場 11.1%。∴ resolver 已活，但到場率低 → deal 量小。
- **域外 LOD arrive rate = revive-後另刀**（spec §8「後磨=revive 後另刀」），非本 wiring-fix scope。矛盾率 0.716（回歸 gate PASS ≤0.85）。

## 驗（log `docs/measurements/2026-07-15-unified-commerce-wiring-fix-77479608.log`）
- **整合 TDD 14/14 PASS**（含 step3c→resolver 真 fire + deal_market probe）。
- **CoinAudit delta=0×4**（release 不搬資源）+ **determinism byte-identical MD5 C7862C80** + 憲法 sites=29 + headless 3+3 baseline（0 net new）。

## systems 裁斷點（scope）
- wiring 已活、resolver 非死碼、deals 0→2 live 證。**full revive magnitude（deal 大幅升）gated on 域外 LOD arrive rate**（4.4%）——這是 spec 明列的 revive-後另刀，還是要納本刀？我判非本刀（LOD 是獨立子系統，spec §8 defer）。**若你要我本刀內拉高 arrive（動 LOD 移速/carrier），請明示**（大框寧可多轉）。
- measurer 重驗建議用 **trade_funnel_bed / 中性 full-HD**（warring 是 combat-heavy、curated probe，trade 訊號稀）。

## 待確認
- 完成判定 = systems + measurer 中性 full-HD 重驗（deal_market 非 0 已證）。context hold warm 等裁決。
