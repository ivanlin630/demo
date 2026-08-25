# `local_value` 的 blind 呼叫點：估值讀不到自己的糧倉（HOW）

`from: systems` ｜ `slice: local-value-blind-callsites` ｜ `tier: full`（改決策數值）

## §1 病（★既有裁定的延伸，不是新設計）
**`TradeValuation.local_value(team, res, state = null)`** —— **傳 `state` 才看得到自家糧倉／公庫。**
★**窮盡 grep：`scripts/simulation/` 有 ★15 個呼叫點【沒傳 `state`】。**
（★**我先前在 `known_issues` 記成「~12 個」—— 訂正為 15，數字用清單對不用印象對。**）

★**同族既有裁定**：**`granary blind-view` 那票已修 `reserve` 側**，理由是
> ★★**`invariants`：★決策不得【讀不到自己的狀態】（`god-view` 的鏡像 ＝ `blind-view`）。**

## §2 ★★★分類（**第三版 —— 我連錯兩次，兩次都是【字面分類】**）
| 類 | 呼叫點 | ★**`fp` 會變嗎** |
|---|---|---|
| ★**純 NPC（5）** | `faction_ai_system:3482` ＋ `interaction_system:996,1002,1004,1005`（★**`_attempt_barter`，caller 只有 `:695`／`:806`，零 player**） | ★**會** |
| ★★**NPC／player 共用（1）** | ★**`interaction_system:952`**（`_attempt_trade_direction`，caller 含 `:1081/1082` ← `resolve_trade_direct` ← `player_command_system:414`） | ★★**會（原因含 NPC 那一半）** |
| **純 player（9）** | `player_trade_system:46,85,88,137,139`／`player_api_mapper:864,866,876,879` | ★**不會**（a4 無玩家） |

### ★★★訂正紀錄：**同一個病，兩種化身**
| 次 | 我用什麼分類 | 錯在哪 |
|---|---|---|
| ★① | **檔名**（`interaction_system` ＝ NPC 的東西） | ★**檔名是字面** |
| ★★② | ★**行號鄰近**（`:952` 在 `_attempt_trade_direction` ⇒ 假設 `:996` 等也在同一支） | ★★★**行號鄰近也是字面** —— **實測 `:996` 起在 `:989` 的 `_attempt_barter`，是【不同函式】** |

★**②發生在【我剛被①糾正之後】** ⇒ ★★**被指出錯誤後把範圍放大過頭，本身是另一種錯。**
> ★★★**唯一有效的判準是【呼叫鏈】：函式邊界 ＋ 該函式的 caller 窮盡。**

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
