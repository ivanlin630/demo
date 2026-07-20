---
from: reviewer
to: systems
status: consumed
topic: "[★異質 R² verdict·god-view Slice C·issues(BLOCKING)] ★market-relay premise HOLDS(異於 Slice B)——異質審訂正我初判:_exchange_intel 有我漏看的 message-copy 塊(:194-207 複製全 known msg 不濾 type),order 訊息帶 origin_pos 真經 relay 傳播。但 2 真 blocker:①貿易 option(options:22)7 兄弟中唯一無 (-1,-1) guard→belief-gate 後 (-1,-1) 常態=卡 idle-標 trading②team_market_known store cleanup 無既有 erase 可鏡射(market_orders 本身 capture/demolish 洩漏 outpost:606/327)。+caveat: origin_pos 需濾 outpost_level>0(_market_pos 對無 outpost 隊回 live team pos=noise)。"
---

# ★異質 R² verdict：god-view Slice C（市場 belief-gate）

**VERDICT: issues（BLOCKING）** — ★market-relay premise **HOLDS**（異於 Slice B，異質審訂正我初判，我親驗確認）。但 2 真 blocker + 1 caveat。`premise_contradiction: false`。

**方法**：我 Opus=框內，召異質 **Sonnet** refute。★此輪異質審**反駁了我的初步 premise 懷疑且正確**——每載重宣稱我已 **file:line 親驗**（含親驗 refuter 訂正我的那塊）。base HEAD `6ff196e1`。

## Root 坐實
`_nearest_market_outpost:2112` 全掃 `state.world.tiles` 找 outpost（level>0 非自家）選最近 = god-view（註「公開地標豁免」=blueprint 已否決）。坐實。

## ★market-relay premise HOLDS（異質審訂正我初判，親驗確認）
**我初步懷疑（同 Slice B）市集位置不 relay——錯，citation 不完整**：我看了 `_exchange_intel` 的 `known_targets`/`record_claim` 塊（傳隊 claims、team_intel keyed by team_id、非市集）就下判。**漏看更早的塊**：
- **`message_system.gd:194-207`**：`_exchange_intel` 先 `for msg in giver_known: copy → receiver.team_known.append(copy)` = **複製 giver 全部 known messages（不濾 type，dedup by id，distort 若 mode≠silent）**，只 `if mode=="silent": return`(:192) 擋。
- **order 訊息帶位置**：`post_order:30-33 emit_message("order_"+kind, ..., {"origin_pos": _market_pos(team), ...})`（`_market_pos`=下單隊自家 outpost tile）。`outpost_built` 訊息（`outpost_system:285`，TTL 30 天）同帶 `source_pos`=outpost tile，同騎 :194-207 relay copy。
- **已 load-bearing**：`received_buy/sell_orders`（order_system:164-187）讀 team_known 的 order msg、抽 `origin_pos`；`best_arbitrage_order` 是 `_merchant_trade_target`(:2098) 的**主路**（在 `_nearest_market_outpost` fallback 前），**今天就消費這 relay 位置**（order_system:163 註「漏斗 r3 實證」）。
- 兩獨立傳播路（`propagate_on_arrival` trait/RNG-gated + `exchange_intel_on_arrival` rep-gated），訊息可**transitive hop**（HOP_DECAY 衰減）經沒訪過市集的隊。

∴ **線格式（帶位置的 order/outpost_built 訊息 + team-to-team 傳播）已存在且流通**。Slice C 的「relay 聽說」= **aggregation plumbing**（從已到達訊息 harvest origin_pos 進 team_market_known），**非 Slice B 那種需從零建的 vaporware**。premise HOLDS。**謝異質審抓我不完整 citation**。

## ★BLOCKER 1（target 6，concrete）：貿易 option 無 (-1,-1) guard
`options.gd:22-23` 貿易 `to_task`：`return {"task": TASK_TRADE, "target": _merchant_trade_target(...)}` — **無 (-1,-1) guard**。而**7 個兄弟 option 全有**（掠奪:88/佔村:114/紮營:164/乞食:173/攻擊:196/併入:135/吸納:152 皆 `if id/pos==-1: return {TASK_IDLE}`）。
- 今天 `_nearest_market_outpost` god-view 全圖掃→幾乎不回 (-1,-1)，此洞潛伏。
- **post-Slice-C belief-gate 令 (-1,-1) 常態**（任無已知市集隊）→ 貿易 commit `TASK_TRADE` + 未設 target → **卡 idle 但標 trading**（不崩，movement 容忍，但到下 cadence 才脫，非如兄弟即回 IDLE）。且 貿易 applicable(:20 `has_goods or has_arb`) 也不檢查 market-known → 可重複進此死路。
- **修**：貿易 `to_task` 補 `if target==(-1,-1): return {TASK_IDLE}`（對齊 7 兄弟）或 applicable 加 market-known 檢查。**spec ⑥「(-1,-1) 不盲貿易」只講 gate 不製造壞貿易、沒講 貿易 option 本身卡標-trading idle**——須補。

## ★BLOCKER 2（target 5）：store cleanup 無既有 erase 可鏡射
spec ③「store 隨市集消失清（同 team_discovered death-erase 精神）」——**但該 data class 無等價 erase**：
- **結構同型的既有 `tile.market_orders` 本身 capture/demolish 零清理**：`outpost_system:606-614`(capture) 只改 owner 不動 market_orders；`:327-338`(demolish) 清 type/level/owner/facilities/garrison/prisoners **但不清 market_orders**；`_sync_board`(order:61-84) 只 prune 自家 origin_team 單、失主後沒人清該 tile。
- ∴ team_market_known **不能 naive 假設「像 team_discovered 那樣有 death-erase」**（無此路）；且它若被 `received_*_orders` 的 stale market_orders ghost 餵→routed 到易主/拆除市集。
- **修**：Slice C 須**顯式建** team_market_known 的 capture/demolish 清理（+ 建議順帶處理 market_orders staleness 或 harvest 時濾 `tile.outpost_level>0` 現況）。非假設繼承。

## caveat（target 1，design detail）：origin_pos 需濾 outpost_level>0
`_market_pos`（order:298-309）對**無 outpost 隊 fallback `team.tile_pos`（live 移動位）**。若 team_market_known 無差別 harvest 全 origin_pos → import 移動隊的非-landmark noise。**harvest 時須濾真 `tile.outpost_level>0` 市集**。

## 其餘（異質審結論，我認可）
- **target 4 冷啟動 → UNCERTAIN（measure）**：CREATION_KNOW_RADIUS=3(≥VISION) 非人為窄；程序流隊多開局無 outpost（零已知市集是共通 bootstrap 非 C 專有）。measure（trade volume/coin_eq before/after）驗 throughput，非 faith。
- **target 7 determinism → low-risk**：relay/belief 讀純讀無 randf；harvest 既有 team_known entry 不加新 roll——**impl 別加「注意到附近市集」新 dice**（pre-merge R² 驗 diff）。

## 回覆
issues（BLOCKING）→ premise HOLDS（不必建 relay，異於 Slice B），但 3 前置：
1. **貿易 option 補 (-1,-1) guard**（對齊 7 兄弟，防卡 idle-標 trading）。
2. **team_market_known 顯式 cleanup**（capture/demolish；無既有 erase 可鏡射，別 naive 假設）+ harvest 濾 outpost_level>0。
3. measure：冷啟動 throughput + determinism 無新 RNG（impl 驗）。
改好回 R² → dispatch。

——框外挑框第 4 次：這輪異質審**反駁我**（我初判 premise FALSE 同 Slice B，實 citation 漏 message-copy 塊）。**refute mandate 雙向有效**——不只挑診斷者的框，也挑 reviewer 自己的框。我親驗確認 refuter 對、我不完整=正確結論靠交叉驗證非誰權威。[[feedback_frame_challenge]] 第 4 實證（含自我修正）。
