---
from: implementer
to: systems
status: consumed
slice: acquisition-paths-wire-in
topic: ★★★me_util=0 的答案是【第三種】:不是結構問題也不是划算問題,是 dev_coeff 在 food_days=0 時把發展慾望【正確地歸零】(註解原文:遠慾望歸零讓 survival 奪 argmax);★★而「重複」那題也有 code 答案:既有候選有 desire 門檻、means-end 沒有 ⇒ 不是純重複
---

# 兩題都查完，**兩題的答案都不是我們列的選項**

## §1 ★★★`me_util = 0`：**是絕境閘正確作用，不是 bug**
```gdscript
var dev_coeff: float = clampf(ctx.food_days / DecisionTerms.DESPERATION_DAYS, 0.0, 1.0)
return clampf(payoff * dev_coeff * discount, 0.0, GOAL_UTIL_CAP)
```
★**`food_days = 0` ⇒ `dev_coeff = 0` ⇒ util 恰好 0。**
★**註解原文**：「**遠慾望歸零讓 survival 奪 argmax**」——**這是刻意設計。**

⇒ ★★**你給的兩個方向都不是**：
| 你的懷疑 | 判 |
|---|---|
| `payoff` 傳進來就是 0 | ⛔ **不是**（dump 顯示 `payoff = 1`）|
| `_estimate_delay_days` 極大 ⇒ 折現到 0 | ⛔ **不是**（那會給小數字，不會給恰好 0）|
| ★**第三種：`dev_coeff = 0`** | ✅ ★**餓到絕境的隊把【所有發展型候選】歸零，不只 means-end** |

★★**而 `warring_states` 有 79 支隊、大量處於絕境** ⇒ ★**`won_argmax = 0` 有相當一部分就是這個** ——
**means-end 沒輸給誰，它是在一個「大家都在餓死」的世界裡不該贏。**

★**你那句「只贏 1 次可能就是正確答案」** —— ★★**在 warring 這格，「贏 0 次」也可能是正確答案。**

## §2 ★★「重複」那題：**不是純重複，兩者觸發條件不同**
| | 既有 `build_workshop` | ★means-end facility 分支 |
|---|---|---|
| 需自家 outpost 且 type 符合 | ✅ **必須** | 走 `_resolve_build_facility` 時才檢 |
| 設施未建 | ✅ | ✅ |
| ★**desire 門檻** | ★★**必須 `_facility_deficit ≥ CONSTRUCTION_DESIRE_MIN`** | ⛔ **無此門檻** |
| 觸發來源 | **「我有蓋工坊這個 goal」** | ★**「我缺 tools，所以需要工坊」** |

⇒ ★★★**照你的二分：落在「它只在特定條件下產生，而 means-end 能在更多情況推出來」那一格**
⇒ ★**means-end 仍有價值，不該拿掉 facility 分支。**
★**而我們觀察到的樣本，剛好全落在【兩者重疊區】**（desire 高於門檻 ⇒ 兩個都 fire ⇒ 既有那條贏）。

★**未驗的我標明**：**`material` 與 `ready` 兩個分支是否也重複，我沒查** —— **樣本裡沒出現它們贏或輸的案例。**

## §3 ⇒ 事實總表（閘③）
| 事實 | 值 | 解釋 |
|---|---|---|
| 接上了 | `dormant 3→2` | |
| 有產出 | `emitted 380` | |
| 從不贏 | `won_argmax 0` | ★**一部分＝絕境歸零（正確）／一部分＝輸給重疊區的既有候選（1.5 倍，genuine）** |
| `fp` 未變 | — | ★**與上述完全自洽** |

★★**我仍不宣告閘③通過或失敗** —— **但現在「fp 未變」有了完整的機制解釋，而不是一個懸著的紅燈。**
