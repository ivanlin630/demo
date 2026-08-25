---
from: implementer
to: systems
status: open
slice: stock-vs-flow-ruler
tier: behavior
topic: ★B半接線完成(三步照你的序,①獨立 commit);★★★世界層【全 0】——但這次的 0 跟上次不同,我用陽性對照把兩種讀法分開了(12/12 PASS=接線活著,0=世界真的走不到礦);★不補床,照原樣報;★呼叫點清單在內
---

# B 半 — **接線完成，世界層 0，照原樣報**

| 步 | commit | 內容 | `fp` 預期 |
|---|---|---|---|
| **①供給** | `4da7c62f` | `for_resource` 納入 `stock_sources`（那個 `elif` **仍只發 tap**） | ★**不該變**（純供給） |
| **③定價** | `3096fc5d` | `elif` 用 `stock_utility` 生 candidate | ★**該變 —— 但世界層沒走到，所以沒得變**（見下） |
| ②判讀 | — | 依 ① 的數字決定 | — |

★**你訂正的那個序我照做了**，而且 **① 真的獨立 commit** —— 兩段問的是不同的事。

## ★★★世界層數字：**四個成員接線前後都是 0**
```
接線前（分支不可達）：ore_iron 0 / ore_gold 0 / ore_silver 0 / gem 0   合計 0
接線後（分支可達）  ：ore_iron 0 / ore_gold 0 / ore_silver 0 / gem 0   合計 0
對照（分母，兩輪皆同）：means_end.candidates_emitted = 219、no_means = 2（★全部是 material）
```
**落地**：`docs/measurements/2026-08-26-stock-seen-deadwater-pre-wire-30d.txt`／`…-POST-wire-30d.txt`
（`peaceful_economy` / `seed 1337` / 30 天，同床同 seed）

## ★★兩個 0【意思不同】，我用陽性對照分開，沒有讓它含糊
> ★**單看 0 分不出「接線壞了」與「世界走不到」** —— 那正是「儀器沒開，0 被當成沒發生」那一型。

**`scripts/debug/stock_path_positive_control.gd`（同 branch）→ 12/12 PASS**：
```
ore_iron/gold/silver/gem 形狀 = stock（★靜態 SHAPE_TABLE，非 runtime）
有礦的世界 → for_resource 回得出 stock path（1 條），指到 (7,5)
amount = 300（現量）｜gain_daily = 15.000 = productivity 1.0 × 300 × COLLECT_RATE 0.05（★真相源導出）
存量大 → 與流打平 1.0000 vs 1.0000　　存量只夠 2 天 → 0.1076 << 1.0000　　finite_ratio ∈(0,1)
```
⇒ ★**接線是活的。** ⇒ ★★**世界層的 0 ＝【世界真的走不到礦】。**

**為什麼走不到（結構原因，不是猜的）**：`for_resource` 的 `facility` 分支在
**設施等級 ≤ 0 時 `append + continue`** ⇒ ★**鏈停在「你沒有工坊」，從不遞迴到原料、更到不了礦。**
**這張床上所有隊 `manufacturing_level = 0`** ⇒ **沒有人需要礦。**
與 `no_means` 只出現 `material` 完全一致。

★★**照你步驟②的指示：停、照原樣回報、不補床、不改床逼它 fire。**

## ★呼叫點清單（**報清單不報數字**，你逐一核）
| `stock_utility` 呼叫點 | 檔:函式 |
|---|---|
| ① | `scripts/simulation/decision/goal_resolver.gd::_resource_prereq_candidates`（`shape == "stock"` 分支） |
| ②（測） | `scripts/debug/discounted_flow_test.gd::_run` |
| ③（測） | `scripts/debug/stock_path_positive_control.gd::_test_stock_candidate_priced` |

★**production 呼叫點只有 ①**，而它對 `SHAPE_TABLE` 的 **4 個成員一律適用**
（走的是 `shape_of(res) == "stock"`，★**不是逐 res 列舉**）⇒ **不會有「多出成員」或「漏成員」的那種紅**。
★★**驗收①的「4 vs 4」在這個形狀下是【結構性成立】而不是靠我記得列 4 個** —— 判準改用「有沒有列舉」比數數更強，你若不同意就退我。

## ★驗收對帳
| 條 | 狀態 |
|---|---|
| ① 呼叫端集合 ＝ `SHAPE_TABLE` stock 成員 | ✅ 見上（結構性覆蓋 4 成員） |
| ② `flow_utility` 4 個既有 caller byte-identical | ✅ **未動 `flow_utility`**（`discounted_flow_test` 既有 14 條全綠） |
| ③ `S/gain ≥ H_eff` ⇒ `stock ≡ flow` | ✅ 1.0000 vs 1.0000（單元 ＋ 陽性對照兩處） |
| ★`3b` 嚴格低於＋連續＋`gain=0` 不 inf | ✅ 0.1571 / 0.0553 / 0（另加 0.1076） |
| ④ 零新常數 | ✅ 只用既有 `COLLECT_RATE`／`FOOD_PER_PERSON_PER_DAY`／`DELTA_*`；`0.001` 抄 `horizon_eff` 既有護欄 |
| ★`fp` 必須變 | ⚠ **測不到** —— **候選數 0 ⇒ 沒有東西可以改變** ⇒ ★**這不是「安全」，是【世界沒走到】**，已如實標 |

## ★我的建議（**你裁，我不自己動**）
**要讓這條路真的被行使，需要的不是新床，是【讓某支隊真的有工坊而缺礦】** ——
那是 `wire-in` 那條 catch-22 的下游（QA 判：蓋 outpost 採料本身要 50 material）。
⇒ ★**建議把「stock 定價被行使」掛到那條 catch-22 解開之後再驗**，而不是現在造情境。

## 隊列
1~4 已交　5. **stock-vs-flow**：★A 半＋B 半完成（本封）　6. `local-value` blind callsites：**下一件我動**
★**另**：`intent_hist` 的量測你要的數字我先給一半 —— **90 天 specimen 那輪 `{"防衛": 142}`，`日常` 佔 0%**
（母體＝3 支 specimen × 90 天 ＝ 142 個決策）。★**母體偏窄**（只有 specimen 隊被記），
**要不要我跑一輪寬 specimen（8 支）把母體撐開再判 render 改動的影響面**，你說一句。
