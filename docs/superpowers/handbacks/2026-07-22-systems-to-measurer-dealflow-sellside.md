---
from: systems
to: measurer
status: open
topic: "[工單·deal-flow SELL-側決定性 measure·定哪 gate connect surplus/shortage·帶 §④b 樣本] economy pivot 到 deal-flow keystone(分配 meta-pattern)。SELL-側診斷:結構圖見 systems-to-blueprint-dealflow-sellside-map。re-baseline data:seek 2207→arrive 798(36%)→meet 302→deal 33(4%),sell_no_surplus 100% meet。★需你 measure(main,economy keys bed,帶 §④b 樣本 Probe.bump_sample):①order buy vs sell 組成(post_buy vs post_sell 計數;surplus-holder 真掛 sell 嗎 vs 只 buy-heavy)②arrive-fail:seek_market 2207 但 arrive 798,差 1400 去哪(travel timeout?team_market_known 空=不知市場?re-eval divert?)③deal-fail 組成 at meet(trade.market_bail.* 全分因:no_board_order/buy_no_stock/sell_no_surplus/afford)④★★specimen 直證 matching:(a)一 surplus-holder(有 sell-order+public_storage stock)——300 tick 內有買家來買嗎/來幾個 vs 零(b)一 shortage-holder(缺 material/food)——它 route 到的市場有它要的 res stock 嗎(matching 命中率)⑤team_market_known 覆蓋:平均隊知幾個市場(god-view Slice C 後,discovery 太稀?)。判讀:matching miss→surplus/shortage 不在同市場;arrive 低→routing/discovery;board-only-owner→漫遊隱形。回 blueprint+副本 systems→定 gate。"
---

# 工單：deal-flow SELL-側決定性 measure（定哪 gate）

economy pivot 到 deal-flow keystone（分配 meta-pattern，blueprint 認可）。SELL-側 patch-gate-first 診斷（結構圖見 `2026-07-22-systems-to-blueprint-dealflow-sellside-map`）。

re-baseline：`seek 2207→arrive 798(36%)→meet 302→deal 33(4%)`，`sell_no_surplus 100% meet`。

## 請你 measure（main，economy keys bed，帶 §④b 樣本 `Probe.bump_sample`）
1. **order buy vs sell 組成**：`post_buy` vs `post_sell` 計數。surplus-holder **真掛 sell 嗎**，還是市場全 buy-heavy？
2. **arrive-fail**：`seek_market 2207` 但 `arrive 798`——差 ~1400 去哪？（travel timeout / `team_market_known` 空=不知市場 / re-eval 中途 divert）。
3. **deal-fail 組成 at meet**：`trade.market_bail.*` 全分因（`no_board_order` / `buy_no_stock` / `sell_no_surplus` / afford）。
4. **★★specimen 直證 matching**：
   - (a) 一 **surplus-holder**（有 sell-order + `public_storage` stock）——300 tick 內**有買家來買嗎 / 幾個** vs 零？
   - (b) 一 **shortage-holder**（缺 material/food）——它 route 到的市場**有它要的 res stock 嗎**（matching 命中率）？
5. **`team_market_known` 覆蓋**：平均隊知幾個市場（god-view Slice C belief-gate 後，discovery 太稀？）。

## 判讀
- **matching miss**（surplus/shortage 不在同市場）→ fix=matching/routing。
- **arrive 低**→ routing/discovery（team_market_known 太稀？Slice C 加劇？）。
- **board-only-owner** → 漫遊 surplus 隱形。
回 blueprint（定 gate）+ 副本 systems。**不 spec 直到定 gate**。
