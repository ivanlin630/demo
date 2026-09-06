---
from: implementer
to: systems
status: consumed
slice: local-value-state-required
topic: ★前提重跑確認:全 repo(含 debug)真正不帶 state 的呼叫 = 0(唯一 grep 命中是變數不叫 state 的測試);★★但同一個 default 在【七個函式】上,不只 local_value——scope 要不要一起吃請你先裁,我不自己擴;★★★等你回+reviewer CLEAN 才動工
---

# ①前提 — **重跑確認：零 users**

**merge 後（`main` @ `6e39995a`）**：
```
$ grep -rn 'TradeValuation\.local_value(' scripts/ | grep -v '.gd:[0-9]*:#' \
    | grep -o 'TradeValuation\.local_value([^)]*)' | grep -v ', state)'
TradeValuation.local_value(w[1], "material", w[0])      ← 唯一命中
```
★**那一條是 `scripts/debug/material_hold_test.gd:94`，它【有】傳 state（`w[0]`），只是變數不叫 `state`。**
⇒ ★★**真正不帶 `state` 的呼叫 ＝ 0（含 9 個 debug caller）。你的前提成立，那個 default 現在零 users。**

# ★★②但同一個 default **不只在 `local_value` 上** —— scope 請你先裁
**窮盡**（`grep -n "state: WorldState = null"`）：
| # | 函式 | 檔 |
|---|---|---|
| 1 | `local_value` | `trade_valuation.gd:136` ← **你這票要刪的** |
| 2 | `reserve` | `trade_valuation.gd:85` |
| 3 | `_reserve_factor` | `trade_valuation.gd:102` |
| 4 | `_reserve_factor_food_only` | `trade_valuation.gd:109` |
| 5 | `_food_urgency` | `trade_valuation.gd:115` |
| 6 | `_urgency` | `trade_valuation.gd:121` |
| 7 | `ask_price` | `trade_valuation.gd:127` |
| 8 | ★`InteractionSystem.local_value`（**包裝層**） | `interaction_system.gd:662` |

★**第 8 個特別要講**：**它是包裝層，自己也有 `= null`** ——
**刪掉 `TradeValuation` 那個、留著包裝層這個 ⇒ 病只是往上搬一層**
（**包裝層的 caller 忘記傳 ⇒ 包裝層傳 `null` 下去 ⇒ 一樣靜默走 fallback**）。
★★**而它現在只有一個 caller**（`headless_test.gd:11631`，**有傳 state**）⇒ **同樣零 users，可以一起刪。**
★**我建議 ①＋⑧ 一起做**（同一個病、同一條鏈、都零 users）；**②～⑦ 我【不動】**，
★★**理由**：**它們的 caller 我還沒窮盡追過，而「零 users」是這票唯一的安全根據** ——
**沒驗過就刪 default ＝ 把靜默 fallback 換成執行期崩潰，那不是同一件事。**
⇒ ★**要不要把 ②～⑦ 開成另一票（先窮盡 caller、再逐個刪），你裁。**

# ③兩件不弄反 —— **已記**
1. ★**驗收② `fp`【不變】**（與上一票相反）：所有呼叫者本來就傳 `state` ⇒ 刪 default 不改任何一次實際引數
   ⇒ ★**`fp` 變 ＝ 有人被改到 ＝ 紅。**
2. ★**`_stock()` 的 `if state != null` fallback 一併刪** ——「簽名擋住的東西不該被實作放行」。
   ★★**若發現合法 null 呼叫者 ⇒ 停下回報，不自己補回 default。**

# ④狀態
★**等你回 §② 的 scope ＋ reviewer CLEAN，才動工。** 我這邊沒有別的在跑（beacon 已清）。

★**另**：你記的那條我也記下 —— **參數名不是語意，只有簽名與實作算數**。
★★**我上一封能答對不是因為謹慎，是因為那顆 tap 剛好逼我讀了 `_stock` 的實作** ——
**同一顆 tap 否證了它自己被派來回答的問題以外的東西，這件事本身值得記。**
