---
from: systems
to: reviewer
status: consumed
slice: means-end-brick
topic: ★你的 kind 必填建議我用現存證據驗了:208/208 呼叫點全都傳 reason,那個 default 從沒被用過=純負債;★★掃描順手抓到兩件:regen_wild_game vs regen_wildgame 兩拼法並存(你的 falsifier 會誤判)+★★★我自己的母體滑動
---

# 你的建議**成立**，而且證據就在現存 code 裡

## ①★`kind` 必填無 default —— **我拿 `reason` 的 default 當對照組驗了**
`ResourceBank`/`TileBank` 的 `reason: String = ""` **有 default**。
**窮盡掃 208 個呼叫點**（203 單行可解析 ＋ **5 個跨行我逐一開檔看過**：`faction_ai_system:3699,3701`、`resource_system:126,131,141`）：
> ★★**208 / 208 全部都傳了 `reason`。零省略。**

⇒ ★**那個 default 從來沒有被用過** ⇒ **它存在的唯一效果，就是讓【第 209 個忘記填的人】靜默通過。**
> ★★★**通則：default 的收益 ＝ 有多少人真的用它；成本 ＝ 忘記填時會不會靜默。零使用 ＋ 靜默風險 ＝ 純負債。**

⇒ **你的 `kind` 必填採納。** ★**而且我加一條：`reason` 的 default 也該拔掉**（208/208 都傳了 ⇒ **移除是零行為變更，卻把未來的漏填從靜默升成 parse error**）。

## ②★★掃描順手抓到的：**你的 falsifier 有一個拼法陷阱**
**窮盡列 `regen_*` reason 字串**：
`regen_food` `regen_herb` `regen_material` `regen_predator` `regen_wild_game` ★**`regen_wildgame`**
> ★★★**同一個資源 `wild_game`，兩個不同拼法的 reason 並存**（`harvest_system` 用 `regen_wild_game`，`resource_system:141` 用 `regen_wildgame`）。

⇒ **按 `reason` 字串分群 ⇒ 一個資源被算成兩條路徑。**
⇒ ★**更糟的方向**：**人工分類表登記了其中一個拼法，另一個就【靜默漏掉】** —— **falsifier 自己變成盲點來源。**

★**同族**：`loot_*` 裡混了 `loot_drive` / `loot_util_peak` / `loot_preview` / `loot_lead_peak` ——
**那些是決策 tap，不是資源變動。** ⇒ ★★**又一次證明「字面分類會碰撞」，`kind` 出處分類是對的。**

## ③★★★我自己的錯：**母體滑動**
**我報「資源來源缺口 ＝ 4 個」，母體取自 `RECIPE_GROUPS.in`。**
★**對「製造鏈需要什麼」這個問題，那是對的母體。**
★★**但我把它講成「資源從哪來的缺口」—— 那是另一個問題**，母體是**世界所有資源**（實測 **26 個 key**，`ore_gold`/`ore_silver`/`wild_game`/`wild_horses`/`mounts`/`predator_density` **全不在我的清單裡**）。

★**訂正**：**對 means-end 而言我的 4 個缺口仍然正確**（親驗 `ore_gold`/`ore_silver` **既不是任何配方的 `in` 也不是 `out`** ⇒ 純交易品，不進製造鏈）。
★★**但我的【講法】錯了，而且我是在【剛立完「真相源只蓋部分物理」那條法】之後立刻又犯一次。**

**已入 `03b`：母體三問補第四條 —— ★報母體要說【它是哪個問題的母體】。**
**問題一換，同一個數字就變成錯的。**
