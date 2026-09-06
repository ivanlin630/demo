---
from: systems
to: implementer
status: consumed
slice: local-value-blind-callsites
tier: full
topic: ★R² v3 CLEAN → dispatch(排你隊尾第五件,不急);★★三類驗收要求不同,別混;★★★而分類本身我錯了兩次,教訓寫在裡面——判準只有【函式邊界+caller 窮盡】
---

# ★dispatch：`docs/superpowers/specs/2026-08-26-local-value-blind-callsites-HOW.md`
**R² v3 CLEAN**（`5/1/9` 表 reviewer 核對過）。★**排你隊尾第五件，不急。**

## ★病
`TradeValuation.local_value(team, res, state = null)` —— ★**15 個呼叫點沒傳 `state` ⇒ 估值讀不到自家糧倉／公庫。**
★★**既有裁定的延伸**：`granary blind-view` 已修 `reserve` 側，依據是 `invariants`「**決策不得讀不到自己的狀態**」。

## ★★三類，驗收要求【不同】，別混
| 類 | 呼叫點 | ★**`fp`** |
|---|---|---|
| **純 NPC（5）** | `faction_ai:3482` ＋ `interaction:996,1002,1004,1005`（`_attempt_barter`） | ★**要求變** |
| ★**共用（1）** | `interaction:952`（`_attempt_trade_direction`，player 也走得到） | ★**要求變** |
| **純 player（9）** | `player_trade_system` 5 ／ `player_api_mapper` 4 | ★★★**【不要求】變** —— **a4 無玩家** |

★**若有人拿「`fp` 不變」說 player 那 9 個沒接上 ⇒ 那是判準誤用**（★**我上次就是這樣寫錯的**）。

## ★★★而分類本身我錯了兩次，教訓給你（**做的時候會用到**）
| 次 | 我用什麼分類 | 錯在哪 |
|---|---|---|
| ① | **檔名** | **檔名是字面** |
| ★② | ★**行號鄰近** | ★★**行號鄰近也是字面**（`:952` 與 `:996` 根本不同函式） |

> ★★★**判準只有一個：【函式邊界 ＋ 該函式 caller 的窮盡】。**
★**你動手時若發現某個呼叫點的類別跟 spec 不符，以【你追出來的鏈】為準，回報我改 spec。**

## ★做法（純接線，但先驗）
**呼叫端把手上已有的 `state` 傳下去。**
★★**先驗每個呼叫點【手上是否真的有 `state`】** —— ★**沒有的話那是包裝層缺參數**（同 `_sellable_qty` 那次），**要往上一層開口，不是硬湊。**
★**禁**：**為了讓它有 `state` 而去掃世界（那會變 god-view）。**
