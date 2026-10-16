---
from: implementer
to: systems
status: open
slice: 我的掛單與押貨（只讀；spec 2026-10-15-my-orders-and-escrow-readonly-HOW）
topic: 請 merge feat/my-orders-escrow 7293c1894（已併 main 6281ce878）｜全電池釘 7293c1894：138／138 全綠 RC=0（run-id 1427-20261016-170918）｜床 10／10 errors 0；4 刀負對照全紅在該紅的格｜全圖掃描 161 µs／217 格｜world-fp 不換
---

# 結論

- 分支 `feat/my-orders-escrow` tip `7293c1894`：fa6b73217（本體）→ 7412fbbf6（trade_funnel_bed 補 @bed-kind）→ 7293c1894（併 main 6281ce878；merge-gates.tsv 檔尾兩列衝突，兩列都留）。
- 全電池（`.worktrees/mm2neg` 釘 7293c1894）：138 支全部通過、BATTERY_RC=0、run-id `1427-20261016-170918`；跑前跑後同 sha、跑前 porcelain 0；`battery-final-7293c1894-green.txt`。「本地多出 my-orders-panel」＝本支新閘。world-fp 綠、不換基準。
  - 前一輪（釘 fa6b73217）跑到第 76 支時只有 bed-kind 一紅：`trade_funnel_bed.gd` 因 `market_pos` 改名被本票碰到、沒有 `@bed-kind`，補 acceptance＋slice（7412fbbf6）。那一輪我中途停了，因為已經有新 tip 要跑；半截輸出 `battery-partial-fa6b73217-killed.txt` 照留。
  - 床與負對照釘 fa6b73217；之後到 tip 只多 bed-kind 標頭與 docs 合併，不碰產線。
- 新床 `scripts/debug/my_orders_panel_bed.gd`（acceptance，10 格點名），註冊表新列 `my-orders-panel`，expect `=== my_orders_panel DONE === 到場 10／10 errors: 0`。
- 原始輸出：`docs/measurements/2026-10-16-my-orders-escrow/`。

# 改了什麼

| 項 | 位置 |
|---|---|
| `release_order_escrow(state, o, why)`：why 必填、無預設值 | `order_system.gd` |
| 落了一筆待領、而屬主 `== state.get_player_team_id()` ⇒ emit `goods_returned`，info `{res, qty, pos, why}` | 同上，只在 `add_pending_claim` 那一支裡 |
| `_claim_pending_here`：先算 `is_player` 再建 per-res dict（NPC 到場不建），函式尾一則 `goods_claimed`，info `{pos, items}`；沒領到不發 | `interaction_system.gd` |
| 兩個 kind 進 FUNC_KINDS、KIND_LABEL（退貨／領回）、describe；原因字 `GOODS_WHY_WORD` 中性；不進 ADVANCE_STOP_KINDS | `world_events.gd` |
| `OrderSystem._market_pos` → 公開 `market_pos`（產線三處＋trade_funnel_bed 一處同 commit 改） | `order_system.gd` |
| `PlayerQueryApi.my_orders`（static）；`query_memory_panel` 多一欄 `my_orders`；檔頭「零真值」那段註明自知帳＋全圖掃描、迴圈標 gate-ok | `player_query_api.gd` |
| 情報頁第五類「我的掛單與待領」：掛單在前、待領在後，共用 `UiPages.INTEL_ROWS_PER_KIND` 與「另有 M 筆」；`my_order_line`／`my_claim_line` 純函數 | `text_ui_main.gd` |

**三個 `release_order_escrow` 呼叫點各傳什麼**：
- `withdraw_on_possession` → `"possession"`（order_system.gd:243）
- `cancel_order` → `"cancel"`（:260）
- `tick_team_orders` 到期 → `"expire"`（:285）

全庫沒有第四個呼叫點。

# 實跑句子（床原始輸出 `bed-full.txt`）

- P1（走真實 `sync_possession` 邊）：
  - 情報頁「待領 糧食 ×12｜在 (0,8)｜第 1 天 00:00 起」
  - 同格別隊的「木料 ×5」待領不列
  - 事件「你的 糧食 ×12 退回 (0,8) 待領（附身時撤下隊上的單）」恰一則
- P2：「賣 糧食 ×12｜押在 (0,8)｜還有 5 天 0 小時到期」→ 撥鐘一天 →「還有 4 天 0 小時到期」
- P3：
  - 「賣 木料 ×7｜掛在 (0,9) 自家市集｜…」
  - 「賣 糧食 ×4｜沒上板（只靠碰面傳出去）｜…」
- E1：「你的 糧食 ×12 退回 (0,8) 待領（到期）」；待領列出現、糧那張掛單列消失
- E2：「你的 木料 ×3 退回 (0,8) 待領（你撤了單）」
- E3：「在 (0,8) 領回 錢 ×3、糧食 ×12」恰一則；待領列 →「尚無」；糧 +12、錢 +3
- E4：NPC 單到期，退貨落格；當場讀 `pending_rethink`，不含該 NPC 隊
- E5：同勢力 NPC 單到期 ⇒ 匯流排 0 則
- CAP：8 筆 ⇒ 5 列＋「另有 3 筆」

# 全圖掃描時間（只記錄）

- 預設地圖 217 格：
  - `query_memory_panel` 一次 163～208 µs（20 次的最小／最大）
  - 其中 `my_orders`（全圖掃待領）平均 161 µs
- 只在情報頁 render 時算，不是每 tick。

# 負對照（釘 fa6b73217，整床跑，跑完還原、porcelain 空）

| 刀 | 紅（原文） |
|---|---|
| n1 拿掉玩家隊判斷 | `E4 NPC 單到期（退貨落格 true）⇒ 同 tick pending_rethink 不含該 NPC 隊`、`E5 同勢力 NPC 單到期 ⇒ 匯流排零則 goods_returned` |
| n2 release_order_escrow 不發事件 | `P1 事件流一則 goods_returned（why=possession）`、`E1 到期 ⇒ …`、`E2 API 撤單 ⇒ goods_returned(why=cancel)` |
| n3 待領列改讀全部 owner | `P1 情報頁有「待領 糧食 ×12｜在 (0,8)」、不列同格別隊的待領` |
| n4 判斷式改回 `.possessed` | `P1 事件流一則 goods_returned（why=possession）`（只有 P1 紅：E1／E2 是玩家隊平常的單，那時 possessed 已是真） |

- **n1 的實際紅燈**＝上表第一列兩句。
  - E4 讀的是 `st.pending_rethink.has(940)`：在 `pending_rethink.clear()` 之後直接呼 `tick_team_orders(st, x)`，當場讀。
  - n1 下它是 true（NPC 被喚醒）。
- 修前紅（P1／E1／E2）：床呼的 `my_orders`／`release_order_escrow(…, why)` 修前不存在、載不進。負對照 n2 就是修前行為：不發事件，所以 P1 事件格、E1、E2 紅。P1 的面板格修前也是紅：修前情報頁沒有第五類。

# 誠實限
- E3 用 `InteractionSystem.claim_on_arrival`（到場入口）直接呼，沒走整條移動 tick。
- 賣單成交的貨款落格（`add_pending_claim "coin"`）：照 spec，面板有列、**不發事件**。
- 範圍外照 spec：終端沒加掛單／撤單鍵；買單押錢；附身時連玩家先前的單一起撤。

# 消費
GO-my-orders-and-escrow。

下一張：玩家勢力目標（之後結構輪兩探針）。
