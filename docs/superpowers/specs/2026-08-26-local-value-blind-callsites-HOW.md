# `local_value` 的 blind 呼叫點：估值讀不到自己的糧倉（HOW）

`from: systems` ｜ `slice: local-value-blind-callsites` ｜ `tier: full`（改決策數值）

## §1 病（★既有裁定的延伸，不是新設計）
**`TradeValuation.local_value(team, res, state = null)`** —— **傳 `state` 才看得到自家糧倉／公庫。**
★**窮盡 grep：`scripts/simulation/` 有 ★15 個呼叫點【沒傳 `state`】。**
（★**我先前在 `known_issues` 記成「~12 個」—— 訂正為 15，數字用清單對不用印象對。**）

★**同族既有裁定**：**`granary blind-view` 那票已修 `reserve` 側**，理由是
> ★★**`invariants`：★決策不得【讀不到自己的狀態】（`god-view` 的鏡像 ＝ `blind-view`）。**

## §2 ★★★分【三】類 —— **原本我寫兩類，R² 抓到錯誤（`premise_contradiction`）**
| 類 | 呼叫點 | ★**`fp` 會變嗎** |
|---|---|---|
| ★**純 NPC（1）** | `faction_ai_system:3482`（商隊自評值） | ★**會** |
| ★★**NPC／player【共用】（5）** | `interaction_system:952,996,1002,1004,1005` | ★★**會 —— 但原因是【NPC 那一半】** |
| ★**純 player（9）** | `player_trade_system:46,85,88,137,139`／`player_api_mapper:864,866,876,879` | ★★★**不會**（a4 無玩家） |

### ★★★訂正紀錄（**我錯在哪**）
**我原本寫「NPC 路徑 5 ＝ `interaction` 那 5 個」。**
★**reviewer 親追呼叫鏈打掉**：`player_command_system.gd:414` → `resolve_trade_direct`（`:1073`）→ `_attempt_trade_direction`（`:941`）→ ★**`:952`**
⇒ ★★**那 5 個所在的 `_attempt_trade_direction` 有【三組 caller】**：`:693/694`（NPC 遭遇）／`:804/805`（NPC 訪問）／★**`:1081/1082`（player 指令）**
⇒ ★★★**「純 NPC」這個標籤本身是錯的 —— 它們是【共用】。**

★**我當初的判準錯在哪**：**我用「檔名」分類**（`interaction_system` 看起來像 NPC 的東西）——
★★**而正確的判準是【呼叫鏈】。** ★★★**同一個母題：用出處分類，不用字面分類；而檔名就是字面。**

## §3 修法（★純接線，同 `granary blind-view`）
**呼叫端把手上已有的 `state` 傳下去。**
★**先驗每個呼叫點【手上是否真的有 `state`】** —— **若沒有，那是包裝層缺參數（同 `_sellable_qty` 那次），要往上一層開口。**
★★**禁**：**為了讓它有 `state` 而去掃世界**（那會變 god-view）。

## §4 驗收
| # | 判準 | ★**它會變紅的場景** |
|---|---|---|
| ★① | **窮盡 grep：`scripts/simulation/` 的 `local_value(` 呼叫點【全部帶 `state`】** | **還有漏網 ⇒ 清單對得出來** |
| ★★② | **NPC 路徑改動後 `fp` 改變** | ★**`fp` 不變 ⇒ 那 5 個沒接上（★不是「判準不可達」——它們在 NPC 主路徑上）** |
| ★③ | **定向 fixture：站自家糧倉、私產 0 的隊，估值高於修前** | **不變 ⇒ 沒讀到糧倉** |
| ④ | **反向：無糧倉的隊估值不變** | 也變了 ⇒ 改過頭 |
| ★⑤ | ★**純 player 那 9 個【不要求 `fp` 變】** | ★★**若有人拿 `fp` 不變說 player 側沒接上 ⇒ 那是判準誤用** |

★**②③要成對**（同 `granary blind-view`）：**只驗②分不出「修好了」和「全部一律變高」。**
