---
from: blueprint
to: reviewer
status: consumed
topic: [R②設計審] tune苟活地板placeholder常數——FORAGE_FLOOR_DAYS+PASSIVE_BASE_CHANCE+wild_game枯竭refill；用戶已點頭，非新機制純調常數
---

# tune苟活地板常數 —— 設計送審（R②）

## 背景（真根鏈，measurer+systems已交叉坐實）
急性崩(月1-3吃~45%人口) → 現有「求生覓食」苟活地板已存在(非缺機制，反冗餘擋掉一次重複建設) → measurer定位死隊forage斷點：**88.5%死於「有覓食仍死」**（地板本身撐不住，非entry沒觸發）→ 死亡96.9%集中在non-owner隊 → systems查常數來源：`FORAGE_FLOOR_DAYS=1.5`與`PASSIVE_BASE_CHANCE=0.08`皆comment明寫`TEST VALUE`，feature引入commit後從未balance調校。

## 用戶裁定（已點頭）
**tune現有常數，非新建機制**。三處一起改（互為疊加脆點，單改一處效果有限）：
1. **FORAGE_FLOOR_DAYS 1.5→5-7天**（`resource_system:388`）——給覓食隊韌性margin，吸收hunt roll連續失敗的波動，不一中斷就見底。
2. **PASSIVE_BASE_CHANCE 0.08→更高**（`hunt_system:20-22`）——直接降低連續失敗發生率，而非只靠加厚緩衝去扛。
3. **wild_game枯竭refill**——防止獵物採乾後前兩項修好也失效（地板本身失能）。

## 為何三處一起（非只改一處）
- 只抬厚度、不提命中率：延後死期非解決，長期連敗仍會打穿加厚後的地板。
- 只提命中率、不抬厚度：單次連續倒楣運仍可能把隊打死（沒有margin吸收波動）。
- 不處理枯竭：前兩項修好，若獵物採乾導致覓食永遠找不到目標，等於地板失效，白修。

## 具體數值
**留給systems定**（比照量測校準，非我拍）——建議systems/measurer先跑A/B對照抓數值（例如FORAGE_FLOOR_DAYS試5天/7天兩檔看效果差異），非憑感覺一次定案。

## 審查重點（factcheck/skeptical）
1. 確認`FORAGE_FLOOR_DAYS`/`PASSIVE_BASE_CHANCE`調校範圍不影響其他既有機制（例如owner隊有800緩衝，這兩個常數抬高後owner隊是否意外被影響——owner隊本來就少進forage流程，理論上影響小，但需查有沒有其他呼叫點共用同一常數）。
2. wild_game枯竭refill機制設計是否有既有pattern可循（例如其他資源tile有無既有regen/refill邏輯可比照，非憑空新設計）。
3. determinism：純調常數值(非新增條件分支)，理論上不影響determinism性質本身，但數值改變會改變模擬結果（同前幾輪先例，非regression）。
4. 這輪不是新機制，範圍應該小——review重點放在「有沒有隱藏耦合」而非機制設計本身（機制已定，只調參數）。

CLEAN後推systems出正式spec（含具體數值建議或A/B測試計畫）。
