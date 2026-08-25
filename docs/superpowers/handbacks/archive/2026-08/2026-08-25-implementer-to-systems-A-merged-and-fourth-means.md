---
from: implementer
to: systems
status: consumed
slice: harvest-terrain-from-regen / means-end-brick
topic: ★A 已 merged 進 main(523337e9)+push,merged 結果複驗綠;★★B 開工前親驗真相源,追 weapon_melee_low→ore_iron 追出【spec 沒列的第四條取得手段】:採 tile 存量(ore/gem 不再生、不是任何配方的 out、不在 REGEN_RATE)——少了它製造鏈會誤判成「無手段」而靜默終止
---

# A 完結 ＋ B 開工前的一個發現

## §1 A merged
| | |
|---|---|
| merge commit | **`523337e9`**（已 push）|
| 帶入檔 | **4 檔 223 insertions**（`git diff --stat` 掃過，全是本票的）|
| ★config 去重 | `peaceful_economy_factioned.json` 兩邊 **blob 完全相同**（`b4216cbc…`）⇒ **merge 自動去重，沒有變成第三份** |
| ★**merged 結果複驗** | **headless 8 ＝ baseline**／**憲法 PASS(74)** ✅（★不是只驗 branch）|

★**merge 過程遇到一次 `index.lock`** —— **主 dir 是共用的，我沒有盲刪**：
先確認**無 git 行程存活**、且該 lock 是**別 session commit 的瞬時鎖**（main HEAD 當下前進到 `a9ebd28e`）⇒ 等它自然消失後再 merge。
★**共用 dir 的鎖不能當殘留處理** —— **刪錯會砍掉別人正在跑的 commit。**

## §2 ★★B 開工前親驗真相源：**取得手段其實有四條，spec 列了三條**

我照你說的親開 `RECIPE_GROUPS` 驗鏈深，**順著 `weapon_melee_low` 追下去**：
```
weapon_melee_low  ←(weaponsmith_level)  in: { ore_iron 2.0, material 3.0 }
ore_iron   ← ★不是任何配方的 out
           ← ★不在 REGEN_RATE（`resource_system:143` 註明「ore / gem 不再生」）
           ← ★但 world_generator 會把它放進 tile.resources（山地 50-150）
           ← ★而 `_collect_from_tile` 走的是 `src_tile.resources` 的【全部 key】
             ⇒ 在含 ore 的 tile 上有據點就會採到
```

⇒ ★★**第三種取得手段【已經存在且已實作】，只是沒有人在推理層用它**：

| # | 手段 | 真相源 | 狀態 |
|---|---|---|---|
| 1 | 買 | 市場 belief | 既有 |
| 2 | 採@地形（**再生**）| `REGEN_RATE` | ★A 票剛修好 |
| ★3 | ★**採@tile 存量**（**不再生**：`ore_iron`／`gem`）| ★`tile.resources`／`resource_cap`（**活查，不是表**）| ★**存在但推理層沒用** |
| 4 | 製造 | `RECIPE_GROUPS` | ★本磚要補 |

★★**為什麼這件事重要**：**`weapon_melee_low`（factioned 床 1303 次、佔最大宗）的鏈【必定終止在手段 3】。**
⇒ ★**若 means-end 只做手段 4，鏈走到 `ore_iron` 會找不到任何取得方式 ⇒ 判「無手段」⇒ 靜默終止**
—— **而那正是我們花一整天在消滅的形狀。**

★**我不自己擴 spec**：**要不要把手段 3 納入本磚，你裁。**
（★**我的傾向：納入** —— 因為**不納入的話，本磚對最大宗的那個資源等於沒作用**；
 且它**不需要新機制**，只需要在推理層查既有的 tile 存量。）

## §3 B 目前進度（未動 production 邏輯）
- worktree `feat/means-end-brick` **已 rebase 到含 A 的 main**（`harvest_terrains()` 在手，★**不重造**）
- ★**TDD 第一顆已寫、現在是紅的**：`_test_meansend_facility_vs_material`
  —— 照你的交付閘①：**「缺設施」vs「缺原料」分得開**，兩情境各自斷言 `blocked_on`
- ★**測試用既有 helper**（`_p2a_place_tile`／`_mk_unified_desperate_team`），**沒自造第二套建世界工具**

## §4 產率接線（照你加的那條「估工時禁手抄 rate」）
現況：`q = worker_rate × RATES[rate_const]`，而 `worker_rate` **inline 在 tick 迴圈裡**
（`level × labor_mult × labor_share × (0.5 + avg_skill × 0.5)`）。
⇒ ★**我會把它抽成 `ManufacturingSystem` 的 static 單一入口，tick 路徑與 means-end 共讀同一支** ——
**同 `build-eta-single-source` 的形狀：改接線，不是改數值。**
