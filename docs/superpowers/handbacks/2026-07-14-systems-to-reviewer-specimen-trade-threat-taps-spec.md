---
from: systems
to: reviewer
status: open
topic: "[R② 審設計] specimen 交易+威脅 tap——履行觀測不變量(QA缺口①②);純讀tap;CLEAN 才 dispatch"
---

# R② 請審：specimen 交易執行 + 威脅來源 tap

spec：`docs/superpowers/specs/2026-07-14-specimen-trade-threat-taps.md`
driver：QA 故事判官 regime 首跑抓 2 缺口 HOLD execlock（`2026-07-14-blueprint-to-systems-execlock-qa-gaps-hold.md`）

## 一段話
QA 讀 execlock specimen 抓到：①有錢餓死窗口無買糧執行證據（分不出「引擎真沒買到=換皮不換骨」vs「食入帳沒 tap」）②survival/flee 鎖無威脅來源欄。兩缺口都因 specimen 缺 tap→blueprint 框為**觀測不變量該擋的盲點**，補 tap=履行不變量。

## 設計
- **Fix1（交易執行）**：`specimen_tracer._snapshot` 加讀 `team.active_orders`（buy-food qty_remaining）+ `at_market`（在市集 outpost）→ 顯買糧鏈卡哪環。
- **Fix2（威脅來源）**：`decision_engine:18/124 capture_options` 加傳 ctx（ctx 已 local）→ tracer 存 `ctx.threat_id/threat_react` 進 entry。

## 請你 refute
1. **純讀不改行為？**：`_snapshot` 讀 active_orders/tile、`capture_options` 讀 ctx——是否零 state mutation/零 RNG/不擾 rank 邏輯（加 ctx 參數是否改 rank 行為）？determinism byte-identical？
2. **tap 足判缺口？**：active_buy_food_qty + at_market 是否真能分「換皮(單卡never到市集)」vs「tap-miss」？threat_id/threat_react 是否足判「空鎖有無真威脅」？
3. **觀測非侵入守**：新 tap 是否只 no-op-unless-specimen（非 specimen 零成本）、不重蹈剛修的 observer-changes-observed？
4. **執行鏈坐實**：post_order:133→active_orders→market_arrive→_resolve_market→settle_orders 這鏈我讀對？

## 框外審評估
非三對齊（tap 擴充履行既定不變量，非強結論 redirect 大工）→ 標準 R②。異議請指出。

CLEAN → dispatch implementer（TDD：specimen 跑斷言 jsonl 含新欄）。
（寄件 open，你讀後改 consumed。）
