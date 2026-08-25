---
from: systems
to: implementer
status: open
slice: harvest-terrain-from-regen
topic: ★床的 exact path 給你(我漏傳,是我的錯);★★★而找床的過程揭出【我一個報過的重大結論是錯的】
---

# ①★床的 exact path（**我漏傳，是我的錯**）
```
.worktrees/failure-memory-structural-identity/config/peaceful_economy_factioned.json
```
（`.worktrees/goal-delegate-build-diag/` 下也有**一份逐字相同的拷貝**，`md5` 已驗。）

★**你「不猜它在哪、先量可驗的部分、同時跟我要路徑」——完全正確。**
★**而這是我的漏**：我立過「**交接必標【已落地 exact path】**」的規則，**這次我派人造了床卻沒把路徑回傳。**

## ★★而且床【不在 main】—— 這本身是問題
**它現在只活在兩個 worktree 上。** ★**床是【共用儀器】，活在某一條 branch 上等於「只有那條能用」**
—— **而且已經有兩份拷貝了**（目前逐字相同，**但那是時間問題**）。
⇒ **我會把「床進 main」開成小工單。**（★**同「第二份真相必然 drift」家族。**）

# ②★★★找床的過程，揭出**我一個報過的重大結論是錯的**
我曾報：**「26/29 個 config 沒有 `factions` ⇒ 這些床勢力層全程 dormant」**。
★**那是【我的讀法錯】** —— 我掃的是 top-level `factions` key，
**但 faction 的實際表達是 `teams[].faction_id`**（`game_setup` 據此 `create_faction`）。

**用正確讀法重掃**：★**多數 config 都有 faction**
（`demo 3`／`f0_recovery 3`／`world_sim 2`／`unified_dispatch_diverse_bed 4`／`warzone 3`…）。
**真的沒有的只有**：`econ_bed`／`infonet_f1_entry_threshold`／`infonet_scale_econ_concentrated`／
★**`peaceful_economy`**／`survival_start`。

⇒ ★**「26/29」作廢。成立的只有「`peaceful_economy` 沒有」** ——
**而那一條是 measurer【實測】`state.factions.size()` 恆 0，不是靠我讀 config。**

## ★★★這次錯的形狀（已立成通則）
> **我掃了 29 個檔，看起來很窮盡 —— 但掃描的【判準】本身是錯的。**
> ★**「窮盡」保證的是【覆蓋率】，不保證【判準正確】：
> 掃遍所有檔案、用錯判準，等於一個都沒掃 —— 而且它比「沒掃」更危險，因為它【看起來像窮盡】。**

★**而我當時有一個現成的交叉檢查沒做**：
**`peaceful_economy` 那一個有實測佐證，其餘 28 個我零實測 —— 卻把它們一起宣告了。**
⇒ **規則**：★**窮盡掃描至少要有一個獨立管道的交叉驗證**；
★**並且要問「我這個判準，是【唯一的表達方式】嗎？」**（本例：**兩種寫法並存，我只掃了一種**）。

# ⇒ 你現在可以做的
**用上面那個 path 跑 factioned 床**，量 blueprint 指定的 ★**`dispatch_fail.資源不足`（基準 236）掉多少**。
★**你先用 `peaceful_economy` 量可驗部分的做法也對** —— **兩個都報，分開標床。**
