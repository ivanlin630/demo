---
from: systems
to: blueprint
status: open
topic: "[patch-gate-first 結果·供給鏈真根] 產了但賣行為查錯storage:manufacture產出→public_storage,非糧賣單讀team.resources=0→永不掛賣單→市場無貨(同WS-2c food accessor家族seam);food已修非糧漏修;回你定願景"
---

# 供給鏈真根：產了但「賣行為」查錯 storage（code-verified）

patch-gate-first 挖到底。**供給空非「沒生產」非「沒賣行為」——是產成品進 public_storage、非糧賣單卻查 team.resources=0 → 永不掛賣單**。同 WS-2c food accessor 家族（資源搬了位置、讀者沒跟＝framework seam）。

## 供給鏈 + 斷點（file:line 坐實）
1. **生產有**：`manufacturing_system` RECIPE_GROUPS：material→goods(3:1)/tools/arrows、ore_iron+material→weapon/armor、ore_iron+material→ore_steel。material 從 forest tile 採（12/day，regen-bound）。**產能存在。**
2. **★產出進 public_storage**（`_add_output:117-118`）：outpost 隊（有設施＝定居隊，正是會製造的隊）manufacture 產出 → `TileBank.deposit(tile, res, public_storage)`，**非 `team.resources`**。
3. **★賣行為查錯地方**（`order_system:110`）：非糧賣單 `qty = team.resources.get(res, 0); if qty < 20: continue`——**只讀 `team.resources`，不讀 public_storage** → 定居隊製造的 goods/weapon/ore_steel 全在糧倉、賣單查私產=0 → **非糧賣單永不 fire** → 市場無貨 → 你見的 arb_kill_nostock 數千/月。
4. **對照 food 已修**：`_tick_food_granary_sell:138+` 讀 `tile.public_storage.food` 賣（WS-1，227 筆/年 fire）。**food 賣單走糧倉對了，非糧賣單漏了同款修**。

## ∴ 真根＝framework seam（非設計缺、非機制壞）
資源存放位置（public_storage）與賣決策讀取位置（team.resources）不一致——**同 WS-2c 教訓**（食物搬糧倉、10+ 決策讀者沒跟 → 全誤判餓）。這次是「製造成品搬糧倉、非糧賣單沒跟 → 全誤判無 surplus」。[[project_framework_seams]] 又一格。

## 修向（供你定願景，非我拍板）
- **非糧賣單讀 effective 持有**（team.resources + 自家 outpost public_storage），鏡射 food granary sell + `ResourceSystem.effective_food` 的單源 accessor 模式 → 定居隊製造 surplus 觸發賣單 → 供給流動。
- **連帶**：成交/履約時從正確 storage 扣貨（貨在 public_storage→從那扣，非 team.resources），守恆。
- **可能的下一層**（seam 修後若供給仍薄）：material 產能（forest regen/採集頻率）vs 製造消耗——但**先修 seam**（產了的貨先讓它能賣），再看產能夠不夠（measure-first，別預修）。

## 連經濟/發展 arc（你說的經濟維核心）
seam 修 → 定居隊製造 surplus 能賣 → 市場有貨 → 買單成交 → coin 流動 → 財富累積 → **經濟維開始運轉**。這是經濟/發展 arc 統一框架的第一刀（生產→surplus→貿易→財富鏈接通）。

## 下一站
**你出願景意圖定方向**（seam 修範圍：只非糧賣單？連買方履約 storage？發展維怎麼掛？）→ systems spec → R² → impl → measurer（中性 full-HD：order_fulfilled>0 + arb_kill_nostock 大降 + coin 流動）。
已記 known_issues。溯源 `manufacturing_system:117` + `order_system:110` + `_tick_food_granary_sell:138`（food 對照）。
