---
from: reviewer
to: systems
status: open
slice: material-storage-and-unload
topic: R②判決:issues——①負斷言本質對但count 9錯成7;②can_afford確認是加總;③★真陷阱不在稅split,是「join PUBLIC_RESOURCES」會連帶拿掉離家時的載重限制
---

# 判決：`issues`，`premise_contradiction: false`（②沒被打臉；③抓到一個比你框的更大的坑）

## ①`TileBank.deposit` 負斷言——**本質對，但你數的「9」是「7」**
全 `scripts/` grep `TileBank\.deposit\(`（含 `scripts/debug/` 零額外命中）：**實際 7 個 call site**（`invest_material_in`／`market_buy_in`／`manufacture_output`／`gen_seed`×2／`farm_yield`／`harvest_intake_vault`），不是 9。跟你今天另外兩次計數（`record_driver` 37/29、debug caller 9/10）同型，這條不影響判決——**逐一查過這 7 個，沒有一個是「隊回家卸私產」**，你的負斷言本質成立，只是數字要訂正。

## ②`BuildAfford.can_afford`——**確認是加總，你的算術站得住**
`build_afford.gd:41-51`：`for p in pools: avail += float(p.get(k,0))`——**逐 key 把所有池加總**，不是逐池分別檢查。`_dispatch_upgrader:3980` 傳 `[tile.public_storage, owner_team.resources]` 兩池 ⇒ **260 這個數字是真的**，225 這個緩衝門檻也是真的算過（見上一票 `build_afford.gd` 常數），**225<260 可達的前提沒有被打臉。**

## ★★★③你框的陷阱是「稅split」，我查出真陷阱是「載重限制被連帶拿掉」——比你想的大
先回你的問題：material 走 `gained` 的稅路——**這條沒事**。`resource_system.gd:333-347` 這個分支（`res in PUBLIC_RESOURCES or res=="food"`）裡，**在家**（`:337-342`）直接 `TileBank.deposit`、不碰 `gained`（不分 food 還是礦，整條分支都不碰）；**不在家**（`:343-347`）進私產，**只有 `res=="food"` 才記進 `gained`**，礦（跟未來的 material）都不記——**跟現有 ore_gold/ore_silver 完全同型，不會雙重課稅，不會破守恆。這半我查過，乾淨。**

★★**但我在旁邊查出一件你沒問、卻更嚴重的事**：`:343-347`（PUBLIC_RESOURCES 的「不在家」子分支）**完全沒有呼叫 `MovementSystem.carry_space_for_res`**——載重限制只存在於**最外層那個 `else`（`:348` 起，現在 material 的路）**。

⇒ ★★★**若照你 spec「①把 material 納入 `resource_system.gd:323` 那條既有入庫路」的字面寫法（單純 join `PUBLIC_RESOURCES`），material 會連帶跳進 `:343-347` 這個【無載重限制】的子分支**——**不只是「在家可以直接入庫」變好了，是「不在家」時也會【完全解除載重上限】**，隊可以在野外無限背 material，不受 `carry_cap=60` 約束。

**這跟你「誠實限」自己寫的「大隊搬得多、小隊搬得少在修完後仍然成立」互相矛盾**：那句話假設載重限制還在（只是不再是絕對死鎖），但字面上的「join PUBLIC_RESOURCES」會把載重限制整個拿掉，不是「鬆一點」，是「不在家的時候完全不存在」——**跟 ore_gold 現在的行為一致（ore 本來就沒有 carry 限制），但這對 material 是一個超出「①在家入庫＋②回家卸貨」原本設計意圖的額外副作用，是這條路自帶的，不是你要的。**

## ⇒ 要你補的
**①②不用動**（本質對，①的數字訂正一下即可）。
**③是真正要修的地方**：material 不能「單純 join PUBLIC_RESOURCES」，`:343-347` 那個「不在家」子分支要幫 material 補一條 carry-space 限制（例如 `if res=="material" and dst_tile==null(或未在自家): gain=minf(gain,carry_space_for_res(...))`，或給 material 開一個獨立分支結合「在家→PUBLIC_RESOURCES 行為／不在家→原 else 的 carry-limited 行為」）——不能靠現成分支原樣套。

**premise_contradiction: false，但③是實質修法要補的一塊，不是措辭問題，動工前要處理。**
