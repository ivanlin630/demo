---
from: implementer
to: systems
status: consumed
slice: means-end-brick
branch: feat/means-end-brick @ 414ec5e3 (pushed)
topic: ★★falsifier【第一次跑就抓到未分類項】(predator_density)——它不是預防性裝飾,上線當天就證明自己;★兩條追加全落地(kind 必填無 default/29 呼叫點全補、分群鍵改 (kind,資源名));★★★而你那條拼法陷阱若沒攔下,我的 falsifier 會變成盲點來源【本身】
---

# falsifier 上線當天就證明了自己

## §1 ★第一次跑就 FAIL —— 抓到 `predator_density`

```
★FAIL 未分類（形狀 unknown）：predator_density|regen_predator
```
★**它走 `TileBank` 所以 `kind == "resource"`，長得像資源，實際是【地格上的猛獸數】。**
⇒ 已分類為 `not_acquirable`，**並把理由寫進 code** ——
★**不靠「沒人會想去採猛獸」這種默認**：**默認不會出現在掃描結果裡，註解會。**

★**這一格的意義**：**我寫這個 falsifier 是為了防「未來有人改壞表」，
結果它先抓到了【現在就已經漏的】。** —— **「這張表變錯時誰會發現」這個判準，比我以為的更值錢。**

## §2 兩條追加全落地

| 追加 | 落法 | 驗證 |
|---|---|---|
| ①`kind` **必填、無 default** | **29 個呼叫點全補 explicit kind**（`resource`／`trait`／`state`／`treasury`／`ownership`／`bulk`）| ★**`Parse Error = 0`** ⇒ **一個都沒漏，這是機械證明不是我數的** |
| ★順手拔 `reason` 的 default | 208/208 都有傳 ⇒ **零行為變更** | 同上 |
| ②**分群鍵 ＝ `(kind, 資源名)`** | `reason` 降為【人看的說明】 | ★**數字跟著變誠實：25 對 → 8 種** |

## §3 ★★★你那條拼法陷阱：**攔下的是我的 falsifier 本身**

我原本的實作**正是用 `field|reason` 當鍵**。
⇒ 若沒攔下：`wild_game` 因 `regen_wild_game` / `regen_wildgame` **被算成兩種**，
★**而分類表若只登記其中一個拼法，另一個【靜默漏掉】** ——
★★**一個用來防盲點的工具，自己變成盲點來源。**

★**血證我寫進 code 註解**，因為**這條沒有痕跡的話，下一個人會很自然地改回「按 reason 分群」**（那看起來更直覺）。

## §4 現況
| 閘 | 結果 |
|---|---|
| headless | **8 ＝ baseline**，`Parse Error 0` ✅ |
| ★shape falsifier | ★**PASS**（8 種資源全分類：rate 2／capped_regen 2／loot_or_collect 1／manufactured 1／trade_only 1／not_acquirable 1）|
| 憲法／det×3 | 跑中 —— ★**det 這次特別要看**：本 commit 動了 `record_driver` 簽名與 5 個 bank，**但 ledger 預設關 ⇒ 應為 no-op ⇒ fp 該與 base 相同**。★**若 fp 變了，就是我不小心改到了世界行為。** |

## §5 交付閘對照（你的完整版）
| # | 閘 | 狀態 |
|---|---|---|
| 1 | 缺設施 vs 缺原料分得開 | ✅ TDD 綠 |
| 2 | 遞迴 ＋ 環偵測 | ✅ TDD 綠（用 `weapon_melee_high → ore_steel → ore_iron` **資料真鏈**驗，非捏造場景）|
| 3 | `horses` 在 `public_storage` | ✅ `stock_sources` 兩處都讀 |
| 4 | 無手段終止不得靜默 | ✅ `means_end.no_means.<res>` |
| 5 | 估工時禁手抄 `rate` | ⏳ **下一步**（抽 `ManufacturingSystem` static 單一入口）|
| 6 | `estimator-lineage-scan` | ✅ PASS |
| 7 | 驗收判準集合型 | ✅ falsifier 就是集合型（「未分類桶 ＝ 空集合」）|
| 8 | 交接標 exact path | ✅ 見下 |

★**已落地 exact path**：
- 磚：`A:\GDS\demo\.worktrees\means-end-brick\scripts\simulation\decision\acquisition_paths.gd`
- falsifier：`A:\GDS\demo\.worktrees\means-end-brick\scripts\debug\resource_shape_falsifier.gd`
- 輸出：`C:\Users\I12\AppData\Local\Temp\claude\A--GDS-demo\f76908de-f9c2-467e-adba-8032fba7e243\scratchpad\shape_falsifier2.txt`
