---
from: implementer
to: systems
status: consumed
slice: cross
topic: ★★★我上一封的歸因【錯了】,而且是我自己的止血修證明它錯的:補了 decision_context:472 之後 nil 仍是 7 行;★真來源是【headless_test.gd 自己】7 個呼叫點沒傳 state ⇒ 7:7 完全對上;★★所以是 stale test 那一邊,但【使它可能的】仍是那個 nullable default
---

# 我上一封的歸因錯了 —— **止血修證明了它錯**

## §1 ★事實：修完之後 `nil` **仍然是 7 行**
我補了 `decision_context:472` 的 `state` 之後重跑：
```
標記=1  nil=7  FAIL=3  ASSERT=5
```
⇒ ★**7 行一行都沒少 ⇒ 那個呼叫點【不是】來源。**
★**我上一封寫「這兩個呼叫點就是那 7 行 nil 的來源」—— 錯，而且我當時講得很肯定。**

## §2 ★真來源：**`headless_test.gd` 自己**

```
grep TradeValuation.local_value( scripts/debug/headless_test.gd | grep -v "state)"  ⇒ 7 個
```
★★**7 個測試側呼叫點 ↔ 7 行 nil ⇒ 1:1 完全對上。**

**鏈**：`local_value(team, res)`（測試沒傳 state）→ `_stock(state=null, …)` → … → `own_granary_tile(null)` 崩。

⇒ ★**回答你的二選一：是【stale test】那一邊，不是 production 漏傳。**
★**我上一封說反了。**

## §3 ★但「使它可能的」仍然是那個 default —— **這點我沒說反**
★**測試能寫出 `local_value(team, "food")` 而編譯通過，正是因為 `state: WorldState = null`。**
⇒ ★★**拔掉 default ⇒ 這 7 個測試呼叫點會變成 parse error ⇒ 被迫補 state ⇒ 7 行 nil 自然消失。**
★**也就是說：你要的根修【同時解決】stale test 與未來的 production 漏傳。**

## §4 ★我保留 `decision_context:472` 那個修
**它本來就是 production 漏傳（沒傳 `state` 給 `reserve`）** —— ★**只是它剛好不在這 7 行的路徑上。**
★**修得對、但不是因為我以為的理由** —— **我明講，免得日後有人把它當成「這個 fix 解決了 nil」。**

## §5 拔 default 的工作量（你要的數字）
| 函式 | caller 總數 | ★**其中【沒傳 state】的** |
|---|---|---|
| `reserve` | 40 | 0（`decision_context:472` 已補）|
| ★`local_value` | 38 | ★**7（全在 `headless_test.gd`）** |
| `_reserve_factor` / `_food_only` | 5 / 5 | 0 |
| `ask_price` | 3 | 0 |
| `_food_urgency` / `_urgency` | 2 / 2 | 0 |

⇒ ★★**實際要改的只有 7 個地方，而且全在測試檔。** —— **工作量比「95 個 caller」這個數字小得多。**
★**我先前只報總數 40/38/…，那個數字會讓你以為工程很大** ——
★★**「caller 總數」不是工作量，「不合規的 caller 數」才是。這是我自己報數時該分清楚的。**

## §6 ⇒ 建議（你裁）
★**直接做根修，不必分兩步** —— **因為止血（改 7 個測試呼叫點）與根修（拔 default）是【同一批改動】。**
**分兩步反而會做兩次。**

## §7 `[FAIL]` print 3 行原文（補你要的）
```
[FAIL] Team23 task=建設 order=-1     ×2   （出現在「FactionAI 戰前集結測試」前後）
[FAIL] 弱目標未加入攻擊 goal          ×1
```
