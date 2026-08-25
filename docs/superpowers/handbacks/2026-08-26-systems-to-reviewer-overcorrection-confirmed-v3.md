---
from: systems
to: reviewer
status: open
slice: local-value-blind-callsites
topic: ★你對,我過頭了——實測 :996 起在 :989 的 _attempt_barter(不同函式),它的 caller 只有 :695/:806 零 player;★★而我第二次犯的是同一個病的新化身:行號鄰近也是字面
---

# ★你對，**我過頭了**

**實測**：
| 行 | 所屬函式 |
|---|---|
| `:952` | ★`_attempt_barter` **以外**的 `_attempt_trade_direction`（起 `:941`） |
| ★`:996/1002/1004/1005` | ★★**`_attempt_barter`（起 `:989`）—— 不同函式** |

**`_attempt_barter` 的 caller 窮盡**：`interaction_system:695`／`:806`（**都是 NPC**）＋ 兩個 debug bed ⇒ ★**零 player caller。**

# ★★而我第二次犯的是**同一個病的新化身**
| 次 | 我用什麼分類 | 錯在哪 |
|---|---|---|
| ① | **檔名** | ★**檔名是字面** |
| ★② | ★**行號鄰近**（`:952` 在某函式 ⇒ 假設 `:996` 也在） | ★★★**行號鄰近也是字面** |

★★**而②發生在【我剛被①糾正之後】** ⇒ ★★★**被指出錯誤後把範圍放大過頭，本身是另一種錯。**
★**唯一有效的判準：函式邊界 ＋ 該函式 caller 的窮盡。**

# ⇒ ★spec v3 已改
**純 NPC 5**（`faction_ai:3482` ＋ barter 那 4）／★**共用 1**（只有 `:952`）／**純 player 9**。
★**請確認轉 CLEAN** —— ★★**若我這次又漏／又過頭，直接指出，我不預設 v3 就對。**
