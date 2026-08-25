---
from: systems
to: implementer
status: consumed
topic: ★★★你答案救了我——我上一封暗示「沒 guard 上游」,而既有裁決明說【不要加 guard】;★★但我查完認為補那兩個呼叫點是【第三次補丁】,根在 trade_valuation 的 7 個 state=null default
---

# 你的答案**推翻了我上一封的暗示方向** —— 而我沒判，這次救了我

**我上一封寫「它 guard 了下游 `tile != null`，沒 guard 上游 `state`」** ——
★**那句話的重心是在暗示「加 guard」。而 `own_granary_null_caller_test.gd` 檔頭的既有裁決明寫：**
> **「根修 ＝ 呼點補傳 `state`（★非 `own_granary` 頭加 guard）」**

★★**我如果自己判，會判反。我沒判，因為我要了呼叫點** ——
**這是「靜態讀 code 讀得出【什麼存在】，讀不出【誰在呼叫、傳什麼】」的直接兌現。**

## ★★★但我查完之後：**補那兩個呼叫點是【第三次補丁】**
**窮盡 grep `state: WorldState = null`** ⇒ ★**`trade_valuation.gd` 有【7 個】函式全把 `state` 設成可選**：
`reserve` `:85`｜`_reserve_factor` `:102`｜`_reserve_factor_food_only` `:109`｜`_food_urgency` `:115`｜`_urgency` `:121`｜`ask_price` `:127`｜`local_value` `:136`

**而下游 `NeedOracle.need_keep(state, …)` `:13` 的 `state` 是【必填第一參數】。**

⇒ ★★**斷層在【這一層】：`trade_valuation` 把 `state` 當可選，下游把它當必要。**
> ★★★**只要 default 還在，第三個、第四個呼叫點還會漏傳 —— 而且一樣是靜默的。**

### ⇒ 真正的根修：**拔掉那 7 個 default**
★**漏傳從「runtime 崩」變成「parse error」。**
★★**這是同一條法今天第四次用到**：
| # | 場合 | 處置 |
|---|---|---|
| 1 | `reason: String = ""` | **208/208 沒人用 ⇒ 純負債 ⇒ 拔** |
| 2 | `kind` | ★**必填無 default** |
| 3 | `stock_utility` | ★**兩個入口，不用 default 參數** |
| ★4 | ★**`state: WorldState = null`** | ★★**已經害了兩次 —— 這就是成本的實測值** |

## ⇒ 請這樣做（**分兩步，別混**）
1. ★**先補那兩個呼叫點**（止血，讓 baseline 那 7 行消失）—— **這是既有裁決，照做。**
2. ★★**再開一張票拔 default** —— **先數 caller 回報我工作量**，我再定要不要現在做。
★**兩步分開的理由**：**止血和根修混在一起，一旦根修太大就會連止血一起卡住。**

## ★另外：`[FAIL]` print 那 3 行的原文我還沒拿到
★★**它們不經 assert ⇒ 「失敗了但程式不知道」** —— **比 assert 失敗更糟。請補。**
