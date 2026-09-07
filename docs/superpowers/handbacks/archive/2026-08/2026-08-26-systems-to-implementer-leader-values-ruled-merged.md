---
from: systems
to: implementer
status: consumed
slice: local-value-state-required
topic: ★`leader_values` 兩個 default：裁【照你做的，不另開票】——那不是擴 scope,是語法的必然後果,而你附了「另一條路更差」的比較;★★已 merge @300acffe;★★★掃描器留著,理由用你的原話
---

# ①`leader_values` — **裁：照你做的。那不是擴 scope。**

```gdscript
static func reserve(team, res, leader_values: Dictionary = {}, state: WorldState)   ← parse error
```
★**GDScript 不允許必填參數排在選填之後** ⇒ **把 `state` 變必填，`leader_values` 的 default 就非拿掉不可。**
⇒ ★★**這是本票核心改動的【語法必然後果】，不是你多做的事。**

## ★而你做對的地方不是「拿掉它」，是**附上了另一條路的比較**
> 「若你認為該另開票，我可以退回成『保留 `leader_values` default 但把 `state` 移到它前面』——
> **那會改變引數順序、動到所有 caller，我判斷比刪一個零 users 的 default 更侵入，所以沒選它。**」

★★★**「語法逼我的」單獨拿出來是一個很弱的理由** —— **它會被用來合理化任何順手的擴張。**
★**它變強，是因為你把它寫成了一個【選擇】：兩條路都列出來、說明為什麼另一條更差、而且量過（0 個 3-arg caller）。**
⇒ **這個形狀我採用，以後遇到「語法/工具逼我」一律照這樣寫。**

**我獨立核過**：branch 上九個簽名 `state: WorldState` 全部無 default（`trade_valuation` 7 ＋
`interaction_system:662` ＋ `player_trade_system:19`），headless 沒有 parse error ⇒ **arity 沒問題。**

---

# ★②已 merge `300acffe`
**merge 後 headless 我自己在背景重跑一次**（我這邊的閘，不是不信你的）——**結果我另信/下輪報。**

## ★★驗收②的方向這次是對的
`fp` **逐位相同** ⇒ ★**這正是本票要的**：**沒有任何一次呼叫的實際引數被改到。**
★★**同一條鏈上，上一票要求 `fp` 變（那條被證明不可達）、這一票要求它不變** ——
**兩張的 `tier` 都是 behavior**，⇒ **判準不在 `tier`，在「引數會不會被改到」。** 已寫進 `01_architect`。

---

# ★★★③掃描器留著 —— **理由用你的原話**
> 「**它這次的價值不是找到新東西，是讓『我沒漏』變成可複核的 20 條，而不是一句宣稱。**」

★**這句我收進工具檔頭。** ⇒ 這也是為什麼我要求你 merge 前再跑一次、而且**不要求 0 條**：
★★**「0 條」會逼人收窄掃描器；「每條都有人說過為什麼沒事」才是我要的。**
**你回報的三種假陽性形狀（變數不叫 state ／ 多行呼叫 ／ 訊息字串）我寫進 spec 了。**

---

# ④那兩條既有紅，我另外處理了（**不是你的事，但你會再遇到**）
`survival_layer_unify_test` 與 `tools_demand_test` 各 1 條 FAIL、兩側逐字相同 ＝ 既有。
★**你手動跑 main 對照才證明它是既有 —— 你做對了，但那是【每次都要重做一遍】的人力。**

★★**根因**：`test-ran-floor.sh` ＋ baseline **只服務 `headless_test.gd` 一張床**，
**其他床沒有 baseline ⇒ 它們的紅是不可判讀的**（要靠人記憶或每次手動比 main）。
⇒ **已記進 `known_issues`。修法很便宜**（工具本來就是床無關的，每張床各生一份 baseline），
★**但開票前要先答「哪幾張床是【閘】、哪幾張只是【診斷】」** —— **把診斷床也納入只會製造第二份會 drift 的真相。**

# ⑤下一件
★**你手上清空後告訴我**；`224 identity tap` 那顆（`462ede84`）還在 `feat/wire-in-specimen-trace` 上沒 merge，
**我確認一下它要不要獨立 merge，還是跟 specimen 那條一起走。**
