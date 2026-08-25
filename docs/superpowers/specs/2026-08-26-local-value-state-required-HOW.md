# `local_value` 的 `state` 改成必填（HOW）

`from: systems`｜`tier: behavior`（改 production 簽名；★但**行為不得變**，見驗收②）
`blocked-by:` 無（`local-value-blind-callsites` 已 merged `f9703eee`）

## 病：**那 17 個 blind 呼叫之所以【存在得起來】，是因為有一個 default**

```gdscript
static func local_value(team: TeamData, res: String, state: WorldState = null) -> float:
```
`_stock(state, team, res)`：`state == null` ⇒ **退回 `team.resources`（私產 only，不含自家糧倉）**
⇒ ★**忘記傳 ＝ 隊在對自己的庫存做決策時讀不到自己的庫存，而且【不會報錯】。**

★★**上一票修掉的是【17 個實例】；這票修的是【讓實例長得出來的那個條件】。**

## ★現況（merge 後實測，這是本票唯一的前提）
```
production（scripts/simulation/，排除註解）不帶 state 的呼叫 = 0
scripts/ 全域（含 debug/test）不帶 state 的呼叫       = 0   ← 9 個 debug caller 也全都帶
```
⇒ ★★★**那個 default 現在【零 users】。**

★**判準（default 三分類，2026-08-25 立）**：
| 類 | 處置 |
|---|---|
| ★**零 users** | ★**純負債 ⇒ 刪** ← **本案** |
| 只有錯的 users | 陷阱 ⇒ 刪 |
| 真收益＋真風險 | **不用 default，改用兩個入口**（`flow_utility` / `stock_utility` 就是這樣做的） |

## ★★scope（2026-08-26 裁定；implementer 窮盡 grep 後提出，我採納）

`state: WorldState = null` 這個 default **不只在 `local_value` 上，共 8 處**：

| # | 函式 | 檔 | 本票 |
|---|---|---|---|
| ① | `local_value` | `trade_valuation.gd:136` | ★**做** |
| ⑧ | `InteractionSystem.local_value`（**包裝層**） | `interaction_system.gd:662` | ★**做** |
| ②–⑦ | `reserve`／`_reserve_factor`／`_reserve_factor_food_only`／`_food_urgency`／`_urgency`／`ask_price` | `trade_valuation.gd:85-127` | ★**不做，另開票** |

★**①⑧ 一起做的理由**：**同一條鏈**。**只刪 `TradeValuation` 那個、留著包裝層的 ⇒ 病往上搬一層**
（包裝層的 caller 忘記傳 ⇒ 包裝層傳 `null` 下去 ⇒ 一樣靜默走 fallback）。
**兩者都已驗證零 users**（⑧ 唯一 caller `headless_test.gd:11631` 有傳 state）。

★★**②–⑦ 不做的理由（這條是本票的安全根據，不是保守）**：
> **「零 users」必須【對每一個函式各自成立】，不能從①推廣到②–⑦。**
> **沒窮盡追過 caller 就刪 default ＝ 把【靜默 fallback】換成【執行期崩潰】—— 那不是同一件事。**

⇒ **另一票的形狀**：**先逐個窮盡 caller，再對每一個套 default 三分類**
（零 users ⇒ 刪／只有錯的 users ⇒ 刪／真收益＋真風險 ⇒ 拆兩個入口）。★**逐個判，不批次刪。**

## 修法（★零數值改動）
1. `local_value(team, res, state)` —— **`state` 必填**（刪 `= null`）。
1b. ★`InteractionSystem.local_value` 包裝層 —— **同樣刪 `= null`**（否則病往上搬一層）。
2. `_stock()` 裡的 `if state != null` fallback —— ★**一併刪**。
   ★**理由**：留著它，就等於留著「傳了 null 也能跑」這條路 —— **簽名擋住的東西，不該被實作放行。**
3. **不新增任何「無世界」入口** —— ★**若日後真的出現「手上沒有 state」的合法呼叫者，
   那時再開一個【具名入口】**（如 `local_value_private_only()`），**不要把 default 加回來。**

> ★★**同族**：`stock-vs-flow` 的「**忘記選 ＝ 沒有函式可呼叫。用【入口】區分，不用【參數值】區分**」。
> **這票是同一條規則用在既有函式上。**

## 驗收
1. ★**結構型**：`grep -rn 'state: WorldState = null' scripts/simulation/trade_valuation.gd` **＝ 零命中**。
2. ★★**`fp` 必須【不變】** —— ★**這票與上一票相反**：所有呼叫者本來就都傳 state，
   ⇒ **刪 default 不改變任何一次呼叫的實際引數** ⇒ **fp 變了就是有人被改到，是紅不是綠。**
   （★**「該不該變」由【這次改動會不會改到任何一次呼叫的引數】決定，不是由 tier 決定。**）
3. **headless 閘**：`bash .claude/hooks/test-ran-floor.sh <實跑輸出>` PASS（baseline 7）。
4. ★**編譯即驗收**：改完若有任何呼叫點少傳 `state`，**GDScript 會直接報錯** ——
   ★★**這正是本票的目的：把「靜默讀錯」換成「根本編不過」。**

## ★誠實限
**本票不會讓任何行為變好** —— 它讓**同一種 bug 以後長不出來**。
★**驗收②要求 `fp` 不變，所以本票【沒有】任何行為證據，也不該有。**
