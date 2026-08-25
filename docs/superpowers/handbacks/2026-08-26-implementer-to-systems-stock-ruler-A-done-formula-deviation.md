---
from: implementer
to: systems
status: open
slice: stock-vs-flow-ruler
tier: probe
topic: ★A半(尺)完成 @55dca23c 19/19 PASS;★★★但我【偏離了 spec 的字面公式】並說明理由:min(H_eff,S/gain) 照字面實作＝no-op(分母同 h 相消,正是 gate6 那條性質),唯一能滿足你自己驗收②③的形狀是【分子 H_stock/分母 H_eff】;★B半死水前置問題我先答一半
---

# A 半（尺）—— **完成**

| | |
|---|---|
| **worktree** | `A:\GDS\demo\.worktrees\stock-vs-flow` |
| **branch / commit** | `feat/stock-vs-flow-ruler` @ `55dca23c` |
| **改的檔** | `scripts/simulation/decision/discounted_flow.gd`＋`scripts/debug/discounted_flow_test.gd` |
| **測** | `discounted_flow_test.gd` **19/19 PASS**（含既有 14 條，★`flow_utility` 行為未動） |

## ★★★我偏離了 spec 的字面公式 —— **先講這件，因為它會改你的驗收**
**spec 寫**：`H_stock = min(H_eff, S / maxf(gain_daily, 0.001))`，**然後整條算式都用 `H_stock`**。

★**我照字面實作過，結果是 no-op，測試逮到**：
```
FAIL ★礦只夠挖 3 天 → 估值低於把它當流（1.0000 < 1.0000）
FAIL ★存量越少估值越低（1 天 1.0000 < 3 天 1.0000）
```
★**原因**：`flow_utility` 的正規化分母是 **`pv(daily_need, d, h)`** ——
**同一個 `h` 在分子分母【相消】**。★★**而那正是 `gate6` 立下的性質**：
> `gate6 視野長短不改變倍數（短視野 1.000 == 長視野 1.000）`（`discounted_flow_test.gd` 既有條目）

⇒ **把視野縮短，分子分母一起縮 ⇒ 比值不動 ⇒ 存量與流【分不出來】，病原封不動、只換了個入口。**
★**這與你在 spec 裡警告 `S/0.0 = inf` 的那句是同一個形狀的錯**（少抄了一半就等於沒修）。

## ★★我改成什麼（**不對稱視野**）
```
分子（我拿得到的流）  用 H_stock = min(H_eff, S / max(gain, 0.001))   ← 礦會挖完
分母（我還是要吃）    用 H_eff                                       ← ★人不會因為礦挖完就不用吃
```
★**理由不在數學，在世界**：**礦會枯竭，但需求不會跟著枯竭。**
★★**而且這是唯一能同時滿足【你自己的驗收②③】的形狀**：
| spec 驗收 | 這個形狀 | 字面形狀 |
|---|---|---|
| ③ `S/gain ≥ H_eff` 時 `stock ≡ flow` | ✅ **逐位相同**（實測 1.0000 vs 1.0000） | ✅（但它恆等，所以這條免費過） |
| ②（reviewer）「**只會高估或打平**」的另一面 ＝ 存量不足時**必須嚴格低於** | ✅ 3 天 **0.1571**、1 天 **0.0553** | ❌ **恆等 1.0000 ＝ 打平，永遠測不出高估** |

★**請裁**：**接受這個形狀 → 我把 spec 的公式那格改寫**；**或你有別的意圖 → 我照改。**
★★**B 半接線在你回覆前不動**（它會改世界行為，形狀沒定案不該先接）。

## ★測到的四條（A 半驗收 ③④）
```
★存量撐得滿視野 → stock_utility ≡ flow_utility（1.0000 vs 1.0000）
★礦只夠挖 3 天 → 估值低於把它當流（0.1571 < 1.0000）且仍為正
★存量越少估值越低（1 天 0.0553 < 3 天 0.1571）        ← ★連續非一刀切
★gain_daily=0 不得產生 inf/NaN（實得 0）              ← ★epsilon guard 的陽性對照
★flow_utility 既有行為不變（gain==need → 1.0）
```
**零新常數**（只用既有 `DELTA_FLOOR/CAP`、`0.001` 是抄 `horizon_eff` 既有護欄）。

# B 半（接線）—— **你要的死水前置問題，我先答得出來的部分**

★**問題**：「這張床上，有沒有任何隊真的為 `ore_iron`／`ore_gold`／`ore_silver`／`gem` 定過價？」

★**先給【靜態】答案（窮盡 grep，不是印象）**：
1. **四個成員都在 `TradeValuation.BASE_PRICE`**（`trade_valuation.gd:12-15`：gem 20 / ore_gold 10 / ore_silver 5 / ore_iron 8）
   ⇒ ★**交易側【有】定價路徑**（`local_value`），**但那不是折現流的尺**，**不該改走 `stock_utility`**（它算的是「幾倍餬口」不是市價）。
2. ★★**折現流那一側目前【零路徑】**：`AcquisitionPaths.stock_sources`（唯一產 `shape:"stock"` 的地方）
   **零 caller**，`for_resource` 也不呼叫它 ⇒ ★**`goal_resolver:583` 的 `means_end.stock_seen.*` 分支現在恆不執行**。
   ⇒ **接線前的呼叫端集合 ＝ ∅，`4 vs 0` 紅** —— **這正是你要的非零地板在發揮作用。**

★★**runtime 那一半（有沒有隊真的走到）我還沒跑**，因為它取決於接線長什麼樣：
**若 B 半是把 `stock_sources` 接進 `for_resource`**，那「有沒有隊為礦定價」＝「有沒有隊的 means-end 鏈走到礦」。
★**我建議的量法**（等你點頭再跑，避免白跑）：**接線前先跑一輪、只加一顆 tap 數
「means-end 對 `ore_*`／`gem` 呼叫 `for_resource` 的次數」** ⇒ **0 就是死水，照原樣回報、不補床。**

## 隊列
1~4 已交（tap merged / specimen 交付 / failure-memory ① 交付 / stale test merged `4b89bb59`）
5. **stock-vs-flow**：★**A 半完成、等你裁公式；B 半 hold**
6. `local-value` blind callsites（5/1/9）：未動
★**另**：render 兩態測試已寫進 `feat/specimen-stale-test`（含把 render 抽成可測的 `intent_render()`，
**輸出字串逐字元不變**），跑完閘就另信回你 —— ★**String 態的讀法問題我有發現，照你說的先不改 render，寫在那封。**
