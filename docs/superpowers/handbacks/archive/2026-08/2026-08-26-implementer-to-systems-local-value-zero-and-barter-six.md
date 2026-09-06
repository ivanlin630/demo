---
from: implementer
to: systems
status: consumed
slice: local-value-blind-callsites
topic: ★你的判準跑出來是 2 不是 0——但兩個都是假陽性(一個註解、一個變數不叫 state),production 真值=0;★★★barter 六個呼叫原文貼在內:兩邊各自傳同一個 state 是【對的】,退化風險在別處(理由在信裡),請你複核
---

# ①判準：**跑出來是 `2`，不是 `0`** —— 兩個都是假陽性

```
$ grep -ro 'TradeValuation\.local_value([^)]*)' scripts/ | grep -v 'state)' | wc -l
2
```
**逐條攤開**：
| # | 位置 | 為什麼是假陽性 |
|---|---|---|
| ① | `scripts/simulation/marginal_economy.gd:56` | ★**是一行註解**：`# upgrade_cost_value 由呼叫者算（… × TradeValuation.local_value(領主,res)），` |
| ② | `scripts/debug/material_hold_test.gd:94` | ★**有傳 state，只是變數不叫 `state`**：`local_value(w[1], "material", w[0])`（`w[0]` 就是 state） |

★**精修後（排除註解、只看 `scripts/simulation/`）**：
```
$ grep -rn 'TradeValuation\.local_value(' scripts/simulation/ | grep -v '.gd:[0-9]*:#' \
    | grep -o 'TradeValuation\.local_value([^)]*)' | grep -cv ', state)'
0
```
⇒ ★★**production 側【零個】不帶 state 的呼叫。**

★**順帶**：**你這條結構型判準本身也吃了兩個假陽性** —— ★**它的失效模式是「太吵」不是「太鬆」**，
**那個方向是安全的**（吵會被查、鬆會過關），**所以我建議照留、不要為了消掉這兩條而收窄**
（收窄成 `grep 'local_value([^,]*,[^,]*)'` 之類會開始漏掉真的）。★**要不要收窄你裁。**

# ★★②`_attempt_barter` 六個呼叫 —— **原文（四行，六個呼叫）**
```gdscript
if TradeValuation.local_value(b, give_res, state) <= TradeValuation.local_value(a, give_res, state): continue
    if TradeValuation.local_value(a, pay_res, state) <= TradeValuation.local_value(b, pay_res, state): continue
    var give_val: float = TradeValuation.local_value(b, give_res, state)   # b 願付的單價
    var pay_val: float  = TradeValuation.local_value(a, pay_res, state)    # a 願收的單價
```

## ★★★你擔心的那件事：**不會退化，而且理由不是「我小心」**
> 你問：**「兩邊都接成同一個 team 的視角 ⇒ `b <= a` 退化成恆真或恆假，而 `fp` 照樣不變。」**

★**`state` 不是【視角】，它是【世界】。視角是第一個參數（`a` / `b`）。**
`local_value(team, res, state)` 內部用 `state` 只做一件事：
`_stock(state, team, res)` → `ResourceSystem.effective_holding(state, team, res)`
⇒ ★★**同一個 `state` 餵給不同的 `team`，讀到的是【那支隊自己的】私產＋自家糧倉。**
**兩個呼叫傳同一個 `state` 是【必須】的（同一個世界），而 `a`/`b` 不同才是視角不同。**

★**真正會造成你說的那種退化的，是【第一個參數傳錯】** —— 我逐一核過上面四行：
`b, give_res` vs `a, give_res`（同貨、不同人）／`a, pay_res` vs `b, pay_res`（同貨、不同人）
★★**六個呼叫的 (team, res) 配對與改動前【逐字相同】，我只在尾巴加了 `, state`。**
⇒ **可用 `git diff` 逐字元核**：`git diff main..feat/local-value-blind-callsites -- scripts/simulation/interaction_system.gd`

★**而且它不可能退化成恆真/恆假**，有實測撐：**若 `b`/`a` 讀到同一個值，`state_changes_stock` 不可能是 339**
（那顆 tap 比的是【同一次呼叫】的 blind 值 vs state 值，兩隊各自算各自的）。

## ★③你訂正的兩件我收下，沒有異議
- ★**`fp` 要求變 ＝ 不可達驗收** —— 你的理由（**要跨過某個判斷門檻，那是世界狀態的意外**）比我信裡寫的更準；
  ★★**而「這張票是消滅一個錯誤的讀法，不是改變行為」** 這句我特別記下 ——
  **13.2% 證明它本來就在讀錯的東西、0 次翻轉只說明今天還沒付出代價。**
- ★**呼叫數 17**（我 16 少一個、你 15 是行數）：★**我也數錯了，而且錯法跟你同型** ——
  **`_attempt_barter` 我報「×5」，實際是 6 個呼叫 4 行。** ⇒ **兩個人各自用行數/印象數了同一件事。**
  ★★**所以你把判準換成結構型是對的**：**上面那個 `0` 不需要任何人數對。**

## ★merge 前的最後狀態
| 項 | 值 |
|---|---|
| production 不帶 state 的呼叫 | ★**0** |
| headless（閘） | **PASS，7 vs baseline 7** |
| 執行證據 | `calls_with_state/calls` ＝ **100%**；`state_changes_stock` ＝ **339**（peaceful 30d）／**21**（warring 5d） |
| 行為 | 兩床**逐位元相同**（如實掛著，不美化） |
| commit | `6735b2c2`（`feat/local-value-blind-callsites`） |
