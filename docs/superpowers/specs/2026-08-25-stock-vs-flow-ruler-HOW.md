# stock vs flow：同一把尺要分得出【流】和【存量】（HOW）

`from: systems` ｜ `blocked-by: means-end-brick`（形狀標記先落地，這票才有東西可接）

## 病
`DiscountedFlow.flow_utility` 假設 `gain_daily` **在整段 `h` 天都持續**（`pv()` ＝ `flow·δ(1−δ^H)/(1−δ)`，`discounted_flow.gd:48-52`）。
★**對再生資源成立；對存量資源不成立** —— `ore_iron`/`gem` **窮盡 grep 零 regen 路徑**，**採完就沒**。

**⇒ 系統性高估，且不對稱**（reviewer 自推 PV 證明）：**只會高估或打平，不會低估。**
★**誤差比值 ＝ `gain_daily × H / S`** —— **`S` 越小越糟**（★**哪個資源最糟需要真實採集率，留給量測，不推理**）。

## 修法（★改接線，不改數值 —— 零新常數）
**存量的真相是：流可以是 `gain_daily`，但【總量上限 `S`】** ⇒ **有效天數多一個上界**：

```
H_stock = min(H_eff, S / maxf(gain_daily, 0.001))
```
★★**epsilon guard 不是新增的謹慎，是【同構的一部分】**（R² 抓到，2026-08-25）：
**`horizon_eff` 自己的分母就有 `maxf(-post_action_net_flow, 0.001)`（`discounted_flow.gd:44`）。**
★**我拿它當同構證據，卻只抄了公式形狀、沒抄它旁邊的護欄。**
> ★★★**同構不該只抄公式，連護欄也要一起抄** —— **少抄的那一半，正好是防止「系統性高估借屍還魂」的那一半**
> （`gain_daily = 0` ⇒ `S/0.0` ＝ `inf` ⇒ `H_stock` 失去上界 ⇒ **病原封不動，只換了個入口**）。

★★**這與既有的 `horizon_eff` 完全同構**（`:41-45`）：
| | 算什麼 | 形狀 |
|---|---|---|
| `horizon_eff` | ★**我還能活多久** | `food_stock / drain` |
| ★`H_stock` | ★**這個礦還能挖多久** | `S / gain_daily` |
⇒ ★**不是新公式，是同一個既有形狀用在另一端。**

## ★★接口：**兩個入口，不是一個 default 參數**
**禁**：`flow_utility(..., source_stock: float = INF)`
★**理由**：**新呼叫端忘記傳 ⇒ 存量被當流 ⇒ 靜默高估。**
（★**對照組**：`reason: String = ""` 的 default **208/208 呼叫點沒人用過** ＝ 純負債；
**但這裡的 `INF` default 會被 4 個現有 caller 真的用到** ⇒ **收益是真的、風險也是真的** ⇒ **兩者都要，就別用 default。**）

★**改用**：
- `flow_utility(...)` —— **再生流**（現有 4 個 caller 不動）
- ★`stock_utility(...)` —— **有限存量**，**`source_stock` 必填**

> ★★★**忘記選 ＝ 沒有函式可呼叫。用【入口】區分，不用【參數值】區分** ——
> **同 `record_driver` 的 `kind`：用出處分類，不用字面分類。**

## 驗收（★集合型優先）
1. ★**`stock_utility` 的呼叫端集合 ＝ 形狀標記為 `stock` 的資源集合**（兩邊互為對方的 falsifier，**任一邊多出成員 ＝ 紅**）
   ★★★**形狀標記側【必須】＝ 靜態 grep `AcquisitionPaths.SHAPE_TABLE` 的內容，★不得改用 runtime 觀測值。**
   ★**理由（R² 要求寫死，2026-08-25）**：`SHAPE_TABLE` 是**寫死在原始碼的靜態表，現有 4 個成員**
   （`ore_iron`／`ore_gold`／`ore_silver`／`gem`）⇒ ★★**它有一個恆為 4 的【非零地板】**
   ⇒ **呼叫端若是 0（又一次「磚落地沒接線」），會立刻對不上（`4 vs 0`）⇒ 紅。**
   ★★★**若改讀 runtime 觀測**（例如接 `driver_ledger`），**一次沒觸發礦物短缺情境的跑 ⇒ 兩邊都空 ⇒「互為 falsifier」形同虛設**
   —— **那正是這輪一路在打的死水／母體塌陷覆轍。**
2. **`flow_utility` 的 4 個既有 caller 行為 byte-identical**（此票不得改再生路徑）
3. **`S / gain_daily ≥ H_eff` 時 `stock_utility ≡ flow_utility`**（★**存量夠撐滿視野就該打平** —— 這是 reviewer「只高估或打平」的直接可測推論）
4. **零新常數**（`estimator-lineage-scan.sh` 綠）
