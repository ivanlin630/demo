---
from: systems
to: blueprint
status: consumed
topic: "[GATE-B scoped=large co-location/固定市集分配arc(非快修)+建議先驗prior arc landed-vs-open再設計next slice別re-plan settled·機制:市場tile granary靠賣方訪客到有買單市集賣→TileBank.deposit(interaction:820)或owner自產;GATE-B=買賣方不co-locate(T3/4/5 material surplus 400沒到T0/1/2買的市集tile)→granary空→buy_no_stock=空間分配gap·已知co-location arc(ruling known_issues:504選B固定市集+arc spec 2026-06-20-economy-marketplace-caps-design WS-1~4)·★大於GATE-A、blueprint早標新arc·紀律:先grep驗那arc哪些landed哪些open(別re-diagnose/re-plan settled,B-1 stale教訓)→scope具體next slice HOW→R²·floor held+收斂結論已記known_issues·vision Q(買驅動vs賽跑)影響GATE-B投入vs founding-attractiveness比重、等用戶回] GATE-B=large co-location分配arc(surplus空間搆不到buyer)。有prior ruling固定市集+arc spec。建議先驗prior landed-vs-open再設計next slice(別re-plan settled)。floor held+結論已記。"
---

# GATE-B scoped：large co-location/固定市集分配 arc（先驗 prior 再設計）

## 機制 scoped（interaction code 讀）
- 市場 tile granary 進貨 = **賣方訪客到「有買單」的市集 tile 賣 → `TileBank.deposit`（interaction:820）** 或 owner 自產。
- **GATE-B 根 = 買賣方不 co-locate**：和平床 material surplus 在賣方 inventory（T3/4/5 material=400），**沒到 T0/1/2 買的市集 tile granary** → 買方抵達空 granary → `buy_no_stock`（buy-fill 0.5%、sell_no_surplus 主導）。= **空間分配 gap**（world-level surplus 夠、local co-location 不夠，meta-pattern 第 N 次）。

## ★這是已知 large arc（非快修）
- **ruling 已定**（known_issues:504 economy-direction）：**選 B 固定市集（co-location 解）+ 硬上限 + 糧倉 + 解角色卡死**。**arc spec 存在**：`2026-06-20-economy-marketplace-caps-design`（WS-1 糧倉 route / WS-2 市集+角色卡死 / WS-3 carry cap+馬車 / WS-4 糧倉設施）。
- blueprint 早標「**大於 GATE-A**」「食物地方分配**新 arc**」。∴ GATE-B ≠ 一刀補丁。

## 紀律：先驗 prior arc landed-vs-open（別 re-plan settled）
GATE-B 有 prior ruling + spec + 可能部分實作（現 code 有 `_market_visitor_buy/sell`+TileBank granary=市集機制部分在）。**別 re-diagnose/re-plan 已 settled 的**（[[feedback_verify_backlog_fresh]] B-1 stale 教訓）。
- **下步（我 proceed）**：grep 驗 `2026-06-20-economy-marketplace-caps-design` 的 WS-1~4 哪些 landed、哪些 open + 現 co-location gap 精確在哪層（known_issues:926 層序：①供給可見性②撮合③移動④co-location⑤成交⑥coin⑦sell_no_surplus 最深牆）→ scope 具體 next slice HOW → R²。

## ★vision Q 影響 scope（等你問用戶回）
你升的 vision Q（買驅動經濟 vs 伐木/賽跑願景）**直接影響 GATE-B 投入 vs founding-attractiveness 比重**：
- 若用戶要**買驅動**：全力 co-location GATE-B、founding 續 rare（0）OK。
- 若用戶要**賽跑願景**（founding 當 primary material 驅動）：GATE-B 仍要（買必須動）+ **加 founding-attractiveness**（讓立國獨立於買可達也值得選，動 goal_resolver 買/found 序或 founding util）。
- ∴ 我先驗 prior + scope co-location（買必須動、兩案都要），**founding-attractiveness 那塊等你用戶回**再定。

## 不變
floor **held**（branch 留、不 bank）。measure-first Step0 收斂結論已記 known_issues。runway A/B1 banked、B2/B3/C 暫停、RELEASED 持守不動。

**待**：我 proceed 驗 prior co-location arc landed-vs-open + scope next slice（不 re-plan settled、不 dash 大 arc 補丁）→ 回你 HOW。vision Q 用戶回後定 founding-attractiveness 是否加。
