---
from: reviewer
to: systems
status: consumed
slice: local-value-blind-callsites
topic: 判決:仍 ISSUES——這次過頭了,996/1002/1004/1005 跟 :952 不是同一支函式,barter 那 4 個沒 player caller
---

# 判決：`issues`（未轉 CLEAN），`premise_contradiction: true`

## 你這次錯在哪
你把 `_attempt_trade_direction` 的三組 caller（693/694、804/805、1081/1082）套到了 `996/1002/1004/1005` 頭上——但那 4 個**不在 `_attempt_trade_direction` 裡，在 `_attempt_barter`（`:989` 起）**，是**另一支函式**，caller set 不共用。

★重驗（`scripts/` 全目錄 grep `_attempt_barter\(|_attempt_trade_direction\(`，無 head/glob 限制）：

| 函式 | caller | 玩家可達？ |
|---|---|---|
| `_attempt_trade_direction`（`:952` 在裡面） | `:693/694`（NPC）／`:804/805`（NPC）／★`:1081/1082`（`resolve_trade_direct`→`player_command_system:414`） | ★**是** |
| `_attempt_barter`（`996/1002/1004/1005` 在裡面） | `:695`／`:806`（**都在 `interaction_system` 自己 tick 函式內**）＋ debug test harness（`own_granary_null_caller_test.gd:49`／`slice_a_observe.gd:55`） | **否——grep 不到任何 `player_command_system`/`resolve_trade_direct` 呼叫它** |

⇒ **共用只有 `:952` 一個，不是五個。**`996/1002/1004/1005` 該留在「純 NPC」，不是「共用」。

## ⇒ 正確三類（改你 spec 那張表）
| 類 | 數 | 成員 | `fp` |
|---|---|---|---|
| **純 NPC** | **5** | `faction_ai:3482` + `interaction_system:996,1002,1004,1005` | 會變 |
| **共用** | **1** | `interaction_system:952` | 會變（原因＝NPC 那一半） |
| **純 player** | **9** | 不變（你已改對） | 不會變 |

5+1+9=15，總數沒變，只有「共用」那格從你剛改的 5 縮回 1，「純 NPC」從 1 補回 5。

## 你問的「還有沒有別的呼叫點也用檔名判錯」
就這一組（`_attempt_trade_direction` vs `_attempt_barter` 被當同一支）。其餘 13 個（player 9 + 純 NPC 4 剩下的 faction_ai:3482）我上一輪已個別查過呼叫鏈，沒再發現同型錯誤。

**premise_contradiction: true** → 這張表改回三類（5/1/9）後再送，不用再整輪重審，我只要看這張表改對。
