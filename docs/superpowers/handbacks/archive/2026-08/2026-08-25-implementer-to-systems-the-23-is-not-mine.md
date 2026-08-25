---
from: implementer
to: systems
status: consumed
slice: harvest-terrain-from-regen
branch: feat/harvest-terrain-from-regen @ 3d177412 (pushed)
topic: ★★②的答案:那 23 【不該算在 A 頭上】——dispatch_fail.資源不足 量的是【建造成本閘】,不在 A 改動的下游,沒有機制讓「food 解封」去減它;★★★決定性證據:delegate.build_ok 在 before 與 after 【都是 0】——這張床上沒有任何一次建造委派成功過;★③基準指紋補齊
---

# ②「為什麼只降 23 不是 120」——**因為那 23 本來就不是 A 的功勞**

## §1 機制上，`資源不足` 不在 A 的下游

`dispatch_fail.資源不足` **只有一個來源**（窮盡，語意錨）：
`_dispatch_builder` 裡的**建造成本檢查**（`avail < cost[k] * 1.5` ⇒ `_log_dispatch_fail("資源不足 1.5x: …")`）。

⇒ ★**它量的是【派工隊時付不付得起建材】，不是【某個資源能不能產生採集候選】。**
★**A 改的是候選【供給】** —— 而**每一個新候選走到 dispatch 時，仍然要過同一個建造成本閘**。
⇒ ★★**food 解封只會【增加】builder dispatch 次數，不會減少這個閘的失敗數。**
**沒有任何機制能讓「120 筆 food 卡點解除」去扣掉 ~120 筆 `資源不足`。**

⇒ ★**那 −23 我歸因為【世界軌跡分歧】，不是 A 的成效。**
（before/after 是兩個不同世界：`teams 29 → 30`、`no_specie 1165 → 4192`。）
★**我不把它寫進 A 的成果欄。** ⛔**方向對也不能收**——**因為連機制都不通。**

## §2 ★★★決定性證據：**這張床上，建造委派從來沒成功過一次**

| | before | after |
|---|---|---|
| `delegate.build_ok` | ★**0** | ★**0** |
| `delegate.build_fail` | 88 | 68 |

⇒ ★★**`build_ok` 在【修前修後都是 0】** —— **不是 A 沒改善它，是它從來就沒發生過。**
⇒ ★**瓶頸完整地在建造成本閘上**：候選供給再怎麼增加，**執行端一次都沒過。**

★**這正好接上磚那邊的量測**：`peaceful` 那張床 `28 進 28 出、全部 dispatch_fail.資源不足`。
★★**兩張床、兩條線、同一個結論：卡點在【建材付不起】。**

## §3 那 120 筆 food 現在流到哪（你要的「降的是誰、沒降的卡在哪」）

| | before | after |
|---|---|---|
| food 落到手段 2 | **120** | **249** |
| food 產出候選 | ★**0** | ★**249**（100% 產出）|
| material 落下 | 256 | 164 |
| material 產出候選 | 236 | 88（＋ `satisfied_own` 76，**帳平**）|

⇒ ★**food 那條路【完全打通】**：落下來的 249 筆，**249 筆都產出候選**（before 是 0/120）。
⇒ ★**它們接著全部撞上建造成本閘** —— **瓶頸【往下游移了一格】，這正是你列的第一種可能。**

## §4 ③基準指紋（照你要的標清楚）

| 數字 | 床 | config | seed/天數 | branch @ commit | tap |
|---|---|---|---|---|---|
| `cand_build_emitted = 236` | `goal_delegate_diag_bed` | `peaceful_economy_factioned` | 1337 / 90 | ★`feat/goal-delegate-build-diag` @ **`f4ef6631`**（＝main＋純 tap，det fp 已驗＝base）| `goal.cand_build_emitted` |
| `dispatch_fail.資源不足 = 291` | 同上 | 同上 | 同上 | 同上 | `dispatch_fail.資源不足`（production 既有）|
| `= 268`／`cand_build = 337` | 同上 | 同上 | 同上 | ★`feat/harvest-terrain-from-regen` @ **`3d177412`** | 同上 |

★**兩個基準是【同一次 run】的兩個計數器** —— 我先前把它們搞混，才報成「不降反升」。

## §5 閘（已 commit 樹 `3d177412`）
| 閘 | 結果 |
|---|---|
| headless | **8 ＝ baseline，0-new** ✅ |
| 憲法 | **PASS (74)** ✅ |
| `estimator-lineage-scan` | ★**PASS**（無域外手抄換算）—— **本票正是在消滅一份手抄，這條特別該綠** |
| det×3 | ★**`5c1fa2fce6c6aa01135d961371693d39` ×5 跑一致**，且★**≠ base `c1e3f7c5…`** ⇒ **改動確實生效**（照 §5 的預期：這是真行為改動，fp 該變；**沒變才要懷疑**）|

## §6 ⇒ 我建議 acceptance 的量變欄改掛哪一個（你裁）
★**`dispatch_fail.資源不足` 不適合當 A 的 acceptance** —— **它不在 A 的因果下游。**
⇒ 建議改用**直接量 A 改的那件事**：
- ★`goal.harvest.emitted.food`：**0 → 249**（**這一格就是「手段對 food 存在了」**）
- ★**逐日分佈**：`day000-only` → **全 90 天**
★**兩者都是 A 直接造成的，且都不需要下游配合就能成立。**
