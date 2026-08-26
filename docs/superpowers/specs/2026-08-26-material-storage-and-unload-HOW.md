# material 進得了家門：採集入庫 ＋ 回家卸貨（HOW）

`from: systems`｜`tier: behavior`｜**WHAT**：★**既有法延伸適用，非新機制**——
`resource_system.gd:323` 那條「採集所得進腳下 outpost 公庫」的路**已經在跑**（礦＋主糧），**material 被漏在白名單外**。

## ★★★病（★純讀 code＋config＋實測，無推論）
```
movement_system.gd:16  BASE_CARRY = 10.0
  carry_cap = pop×10 + mounts×15 + wagons×40        ⇒ ★pop 6、無馬無車 = 60
  _resource_weight("material") = 1.0                 ⇒ ★★material 每單位重是 food(0.1) 的 10 倍
resource_system.gd:323 if res in PUBLIC_RESOURCES or res == "food":   ← ★material 不在裡面
  PUBLIC_RESOURCES = ["ore_gold","ore_silver","ore_iron","ore_steel","mounts","horses"]
```
⇒ ★**material 一律進私產 ⇒ 一律受載重限制 ⇒ 這也正是「公庫 material 全程 0」的機制原因**（不是隊窮）。

**實測**（`docs/measurements/2026-08-26-material-income-zero-30d.txt`，四出口互斥窮盡、分母 `matin.call`）：
```
Team3/4/5/7  call 72 → ★carry_full 72（100%）、pool_empty 0、gained 0     載重 194~350 / 上限 60
Team0/1/2/11 stuck at 59/60，44~49 次被擋   ⇒ ★那個 +0.5/日 不是慢慢攢，是【貼著天花板來回】
```
★★**不是沒料可採，是【裝不下】。** ★★★**而它自我維持**：裝不下 ⇒ 採不到 ⇒ 永遠零收入。

## ★★兩條線都沒接（★第二條才是解鎖那一半）
| # | 缺的 | 為什麼缺了就死 |
|---|---|---|
| ① | **採集所得的 material 不入公庫** | 只能背在身上 ⇒ 撞載重 |
| ★② | **不存在「回家卸貨」** | ★★**已超載的隊【永遠】解不開** —— 只修①，那 400 還是卡在私產，`carry_full` 仍 72/72 |

★**②的負斷言已窮盡坐實**：`TileBank.deposit` 全 codebase **7 個 caller，逐條看過**（★**原寫 9 是我數錯，R² 訂正；`grep -c` 實測 7**）（`invest_material_in`／`gen_seed`×2／`market_buy_in`／`manufacture_output`／`farm_yield`／`harvest_intake_vault`…）
—— ★★**沒有任何一個是「隊回到自家據點把私產卸進公庫」。無 head、無 glob。**

★**而 `invest_material_in`（faction_ai:2839）證明 material 進公庫在機制上完全 OK** —— **只是採集那條路把它排除了。**

## 修法
### ★★★①【訂正版】material 走**自己的分支**，★**不得 join `PUBLIC_RESOURCES`**（R② 揭，2026-08-26）
★**我原本寫「納入 :323 那條既有入庫路」——那個字面寫法會連帶造成一個我沒要的副作用。**
`:343-347`（白名單的「不在家」子分支）★**完全沒有呼叫 `carry_space_for_res`** ——
**載重限制只存在於最外層那個 `else`（`:348` 起，＝ material 現在走的路）。**
⇒ ★★**單純 join 白名單 ＝ material 在野外【完全不受載重上限】**，
★★★**那不是「鬆一點」，是「不在家的時候載重限制不存在」** —— **與我自己誠實限寫的「小隊搬得少仍然成立」直接矛盾。**

**⇒ 要的形狀（在不在家決定走哪條，不是在不在白名單）**：
```
material：
  ★在【自家】據點上  → TileBank.deposit(dst_tile, "material", gain, ...)
                       （★不受載重是【對的】——人就站在自己倉庫上，東西不用背）
  ★否則（含站在【別人】據點上）→ ★★走原 else 的 carry-limited 私產路，一行不改
                       （★含既有「兩種零分開」的 tap：載重滿 vs 算出來本來就是 0）
```
★★**「自家」這個條件是我加的，R² 沒提，理由**：現成分支的判斷是 `dst_tile.outpost_level > 0` ——
★**任何據點，不分是誰的** ⇒ **照抄會變成「在別人據點上採 material ＝ 送給對方」。**
★★★**ore 現在就是這個行為（既有、不在本票範圍）；但對 material 那會是一條新的漏，不得順手套進來。**

★**沿用 `TileBank.deposit` 的 cap／溢出語意，不新造**
② ★**隊在自家據點時，超出載重的私產 material 卸進公庫**（★**同一條 `TileBank.deposit`，溢出照既有 sink 語意**）

★★★**禁止**：**改 `MARGIN_NEUTRAL`／改 `OUTPOST_COST`／改床 config／給 mounts-wagons 當解法** ——
**那四個都是把「一條沒接的線」paper over 成數字好看。**

## ★★★算術先講死（★防止「修完數字動了、但驗收又不可達」）
```
L1 civilian 公庫 cap（TileBank:17）= 200
pop 6 載重                          =  60
★BuildAfford 讀【兩個池加總】(_dispatch_upgrader:3980 傳 [tile.public_storage, owner_team.resources])
   ⇒ 可用上限 = 260
升級 L1→L2 物理 150｜含 1.5× 緩衝 = 225
```
⇒ ★**225 < 260 ⇒ 可達。** ★★**但餘裕只有 35，且要求私產接近滿載。**
⇒ ★★★**所以驗收寫「`upgd.dispatched > 0`」，不預測數量。**
★**若修完仍為 0：第一個要查的是【私產是否同時被別的支出佔走】，不是回頭調緩衝。**

## 驗收（★對象＝那 4 支超載隊，它們是最乾淨的陽性對照）
1. ★**`matin.carry_full` 在 Team3/4/5/7 從 `72/72` 下降**、★`gained > 0`（現況 0.0）
2. ★**公庫 material > 0**（現況全程 0）—— ★★**這一格直接證明線接上了**
3. `upgd.dispatched > 0`（★**方向不是數值**；為 0 照原樣回報，見上一段）
4. **對帳仍平**：四出口合計 == `matin.call`；八類 == `upg.call`
5. ★**`warring_states` 回歸**：這是 behavior 改動，`fp` **會變**（兩張床都會）——
   ⇒ ★★**回歸防線改成【守恆帳】**：`TileBank` 守恆稽核不新增不平；`harvest.vault_overflow_drop` 溢出可觀測。
6. headless（baseline 7）＋憲法閘 PASS

## ★誠實限
- ★**床 config 塞 material 400 給 Team3/4/5/7 ＝ 失真設定，但【這輪不要改】** ——
  ★★**它現在是「超載鎖」最乾淨的陽性對照，而正確的修法會自動解掉它。**（已記 `known_issues`，免得日後被當成正常。）
- ★**「大隊搬得多、小隊搬得少」在修完後【仍然成立】，而那正是我們要的規模經濟** ——
  ★★**入庫把「絕對不可能」變成「小隊比較慢」。** ★★★**現在的狀態不是「小隊弱」，是「小隊完全靜止」。**
