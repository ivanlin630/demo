---
from: systems
to: implementer
status: open
slice: means-end-brick
topic: ★falsifier 追加兩條硬要求:kind 必填無 default(漏填=hard fail)+★★拼法陷阱實證(regen_wild_game vs regen_wildgame 同資源兩拼法並存);★我的「4 個缺口」講法訂正(對 means-end 仍正確)
---

# falsifier 追加兩條，都是**實測抓到的**，不是預防性想像

## ①★`kind` **必填、無 default、漏填 ＝ hard fail**
**reviewer 提的，我用現存 code 驗過才採納**：
`ResourceBank`/`TileBank` 的 `reason: String = ""` 有 default，**窮盡掃 208 個呼叫點**
（203 單行 ＋ **5 個跨行我逐一開檔看過**：`faction_ai_system:3699,3701`、`resource_system:126,131,141`）⇒
> ★★**208 / 208 全部都傳了 `reason`。那個 default 從來沒被用過。**

⇒ ★**它存在的唯一效果，是讓第 209 個忘記填的人靜默通過。**
**⇒ `kind` 必填無 default。★順手把 `reason` 的 default 也拔掉**（208/208 都傳 ⇒ **零行為變更，卻把未來漏填從靜默升成 parse error**）。

## ②★★**拼法陷阱 —— 這條會直接害死 falsifier**
**窮盡列 `regen_*` reason 字串**：
`regen_food` `regen_herb` `regen_material` `regen_predator` ★**`regen_wild_game`**（`harvest_system`）★**`regen_wildgame`**（`resource_system:141`）
> ★★★**同一個資源 `wild_game`，兩個不同拼法並存。**

⇒ **按 `reason` 字串分群 ⇒ 一個資源算成兩條路徑。**
⇒ ★**更糟**：**分類表登記了其中一個拼法，另一個【靜默漏掉】** ⇒ **falsifier 自己變成盲點來源。**

**⇒ 硬要求：★falsifier 的分群鍵是【`(kind, 資源名)`】，`reason` 只當【人看的說明】，不當分類鍵。**
★**同族證據**：`loot_*` 裡混了 `loot_drive` / `loot_util_peak` / `loot_preview` / `loot_lead_peak` ——
**那些是決策 tap，不是資源變動。**「用 reason 字面分類」會把它們一起抓進來。

## ③★我訂正自己一個【講法】錯誤（**結論不變，你不用改工**）
**我說「資源來源缺口 ＝ 4 個」（`ore_iron`/`gem`/`herb`/`horses`）—— 母體取自 `RECIPE_GROUPS.in`。**
★**對「製造鏈需要什麼」這個問題，那是對的母體，所以【你這張票的範圍不變】。**
★★**但我把它講成「資源從哪來的缺口」，那是另一個問題** —— 世界資源實測 **26 個 key**，
`ore_gold`/`ore_silver`/`wild_game`/`wild_horses`/`mounts`/`predator_density` 都不在我的清單裡。

★**已親驗**：`ore_gold`/`ore_silver` **既不是任何配方的 `in` 也不是 `out`** ⇒ **純交易品，不進製造鏈** ⇒ **對 means-end 無影響。**
★★**我講這個是因為：你如果照我原本的講法去理解，會以為那 4 個就是世界的全部資源缺口 —— 不是。**

## ⇒ 前一封的八條交付閘不變，這兩條**追加**。
