---
from: reviewer
to: systems
status: consumed
slice: 攻擊幣別票 ｜ tier0/1 estimate 空缺
topic: ★①窮盡成立(只兩條值路徑+一條0.0 null fallback,無第三種單位)｜★★②號抓到一個你沒講的東西：**(a)在現在這條加總式子裡跟「richness=0」數值上完全等價**——「不參與」跟「算成0」在這支 sum 公式裡印出同一個數字，標籤不同、行為不同不了｜★★★(b)你舉的例子(同tier真值中位數)確實是死路(god-view)，但有個非god-view的變體我沒看你提過；(c)在現有公式形狀下沒有跟(b)不同的接法，要動就是擴大範圍
---

file:line 都查過，②是分析題不是純 factcheck，我把推論鏈攤開，裁決還是你的。

# ① 窮盡確認：CONFIRMED，沒有第三條路

`faction_ai_system.gd:379-384`：

```gdscript
static func _belief_richness(bel: Dictionary) -> float:
	if bel.has("coin_est") or bel.has("food_est") or bel.has("material_est"):
		return (float(bel.get("coin_est", 0.0)) + float(bel.get("food_est", 0.0)) + float(bel.get("material_est", 0.0))) / 100.0
	if bel.has("resource_scale"):
		return float(bel.get("resource_scale", 0))
	return 0.0
```

三個 `return`，你講的兩條值路徑各一，第三條（:384 `return 0.0`）是「皆無資料」的中性 fallback，
不是第三種單位計算——跟 :378 的函式頭註解「皆無 → 0」對得上。全函式只有這三個 return，
沒有藏第四條。窮盡成立。

# ② 設計選擇三問

先把 `richness` 怎麼進 argmax 的攤開（`:366`）：

```gdscript
var score: float = (richness * greed + weakness * cruelty + border * ambition) / eta_days * logistics
```

`greed` 預設 0.5（`:260` 等多處 `leader.values.get("貪婪", 0.5)`）——幾乎每個領袖這個係數都 >0，
不是邊角情境。

## 2-1. (a) 會不會結構上把 tier0/1 判死？

**不是「絕對」判死，是「比較」判死，而且比較判死這件事，在這支公式裡，
跟你想排除的「假值」數值上長得一模一樣。**

- 絕對意義上：不會恆虧損——少了 `richness*greed` 這一項後，`score` 還剩
  `(weakness*cruelty + border*ambition)/eta_days*logistics` 兩項，如果 tier0/1 目標的 weakness
  或 border 夠高，它仍然可能贏過一個 tier2 目標。所以不是「永遠不划算」。
- ★★但比較意義上：這是一個**加總公式**，「這一項不參與」跟「這一項算出來是 0」——
  在 `A = X + Y`（X 缺席）跟 `A = 0 + Y`（X=0）之間，**印出來的 `score` 數字逐位元相同**。
  ⇒ 你標的「(a) 承認估不出，不是給假值」是**語意上**的區分，不是**數值行為上**的區分——
  對 argmax 而言，tier0/1 目標跟一個「真的被估成 0 分財富」的目標**完全無法分辨**。
  ⇒ 兩個同 weakness/同 border 的目標，一個 tier2（真有 richness）一個 tier0/1（(a) 後＝0），
  只要 greed>0，tier2 目標**必贏**——這正是你自己在 coin 票（今天稍早那票）抓到的**同一個病**：
  「這張表沒有這一格」被當成「這一格是 0」。只是這次病灶從 `TARGET_PER_POP`／`BASE_PRICE`
  搬到 `_belief_richness` 的返回值，形狀沒變。

⇒ **若要 (a) 真的做到「誠實地不算」而不是「悄悄判死」，這支 `score` 公式本身要跟著改**——
單純把 richness 項拿掉、公式其餘不動，達不到你要的效果，只是換了個說法的「=0」。
真正誠實的做法二選一：
  - 把 tier0/1 目標**移出跟 tier2 目標的同一個 argmax**（分池：有 pricing 情報的目標先比，
    沒有的另外歸一池，用不同判準——例如優先派出偵查而非直接開打）；
  - 或者把 `score` 從「三項加總」改成能反映「這一項未知」的形狀（例如按實際參與項數重新
    正規化），但這已經在動 §③範圍你明講「不動壓縮」的那塊——所以這條路現在不該選。

## 2-2. (b) 的代表值有沒有非 god-view 的路？

你舉的例子（「同 tier 已知目標的實際資產中位數」）——**確認是死路**，你判對了：
要算「已知目標的真值」中位數，得讀那些目標的 ground-truth 資源量，而我方對它們也只有 belief，
不是真值,一樣是 god-view,沒有例外。

★但有一個你沒提過、不是 god-view 的變體：**用本隊自己已經升級到 tier2 的其他目標的 belief
richness，取中位數/平均，當作「這個世界一般而言長什麼樣」的自估基準**——
這完全**不讀任何隱藏真值**，只用「本隊自己手上已經有的 belief 資料」做自我參照的 base rate，
跟這個 codebase 別處用「真實母體量」導出估值（而非手填常數）的精神一致（`TARGET_PER_POP`
用真實人口、不是這個意思，但方向類似：用自己已有的真實資料而非虛構常數）。

查過 `belief_system.gd`（`best_estimate:144`／`estimate_armed:53`／`belief_pos:123`）——
**目前沒有「跨目標聚合自己已知 belief」的函式**，這是新機制,不是「接現成的線」，
工程量比純粹「richness=0/排除」大一截。指出這條路存在,但不是「免費」的路，這點要老實告訴你。

## 2-3. (c) tier 當 confidence 而非 value 可行嗎？

概念上合理，但**在現在這支 `score` 公式的形狀下，(c) 跟 (b) 沒有可觀察的差異**——
`richness*greed` 是一個單點值相乘，不是一個「值×信賴度」的兩參數結構。
要讓 (c) 真的跟 (b) 不同（例如信賴度低時該去做的是「先偵查」而非「直接照代表值出手」），
`score` 本身要從單點值變成某種風險調整形狀——這已經超出這張票（你明講「不動壓縮」）該動的範圍。

⇒ (c) 是一個值得記下來的**後續架構想法**（tier 語意本來就可能該是 confidence，這解釋了
為什麼原始設計把它跟 value 混在同一個欄位是根源性錯誤），但**這張票裡沒有跟 (b) 不同的接法**，
不建議現在選它——選了等於是選 (b) 又多包一層說法。

# 小結

| 問 | 判 |
|---|---|
| ① `_belief_richness` 窮盡 | ✅ CONFIRMED，只兩條值路徑+一條 null fallback，無第三種單位 |
| ②-1 (a) 是否偷偷判死 | ⚠ 在**比較**意義上是——且跟「richness=0」在這支加總公式裡數值全同，若選 (a) 必須連 score 公式的比較範圍/形狀一起改，否則是換皮的同一個 bug |
| ②-2 (b) 舉的例子 | ✅ 確認死路(god-view)；但有個本隊自估 base-rate 的非god-view變體，是新機制不是接現成線 |
| ②-3 (c) | 現形狀下跟 (b) 無法區分，超出本票範圍，記錄為後續架構題 |

這張票我沒法給 CLEAN/非CLEAN——③說這是設計選擇要你打，我打完了，裁決在你（或呈藍圖）。
