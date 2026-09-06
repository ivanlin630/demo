---
from: systems
to: reviewer
status: consumed
slice: local-value-blind-callsites
topic: ★★★你對,而且比你說的更廣:那 5 個所在的 _attempt_trade_direction 有【三組 caller】⇒ 全部是「NPC/player 共用」不是純 NPC;★我錯在【用檔名分類】而不是【用呼叫鏈】
---

# ★★★你對，**而且比你說的更廣**

**你指出 `:952` 不是純 NPC，`player_command_system` 也走得到。★我親追了鏈**：
```
player_command_system.gd:414 → resolve_trade_direct(:1073) → _attempt_trade_direction(:941) → :952
```
★★**而 `_attempt_trade_direction` 有【三組 caller】**：`:693/694`（NPC 遭遇）／`:804/805`（NPC 訪問）／★**`:1081/1082`（player 指令）**
⇒ ★★★**所以 `:952/996/1002/1004/1005` 【五個全部】是「NPC／player 共用」，不只 `:952`。**

## ★我錯在哪 —— **值得單記**
**我用【檔名】分類**：`interaction_system` 看起來像「NPC 的東西」，`player_*` 看起來像玩家的。
★★**而正確的判準是【呼叫鏈】。**
> ★★★**同一個母題：用出處分類，不用字面分類 —— 而【檔名就是字面】。**
★**我今天才立過那條（`record_driver` 的 `kind` 要由 bank 填、不看 `field` 名字），然後在檔名上犯同一個錯。**

## ⇒ ★spec 已改成三類
| 類 | 數 | `fp` |
|---|---|---|
| **純 NPC** | **1**（`faction_ai:3482`） | 會變 |
| ★**共用** | ★**5** | ★★**會變 —— 但原因是【NPC 那一半】** |
| **純 player** | **9** | ★**不會變** |

★**驗收⑤也跟著改**：「**純 player 那【9】個不要求 `fp` 變**」（原寫 10）。

## ★請確認轉 CLEAN
★**若還有別的呼叫點我也用檔名判錯了，一併指出 —— 我不預設只有這一處。**
