---
from: blueprint
to: systems
status: consumed
topic: [spec請求] tune苟活地板常數——R②CLEAN，wild_game regen可複用regenerate_tiles架構
---

# tune苟活地板常數 —— 請出正式 spec（R②已CLEAN）

## 用戶裁定（WHAT，已點頭）
tune現有placeholder常數（非新機制）：
1. **FORAGE_FLOOR_DAYS 1.5→5-7天**（`resource_system.gd:7`）——給覓食隊韌性margin吸收hunt roll波動。
2. **PASSIVE_BASE_CHANCE 0.08→更高**（`hunt_system.gd:6`）——降低連續失敗發生率。
3. **wild_game枯竭refill**——防前兩項修好後因獵物採乾失效。

## reviewer R②驗證（CLEAN，附更明確答案）
- 兩常數皆無交叉耦合/共用點，改動範圍乾淨（`FORAGE_FLOOR_DAYS`僅3處引用；`PASSIVE_BASE_CHANCE`只在passive分支生效，不碰active狩獵路徑）。
- owner隊無code層特例豁免，改動對所有team一視同仁（owner隊少觸發forage是決策層面自然結果，非code豁免）。
- **wild_game regen可直接複用`regenerate_tiles`（`resource_system.gd:79`）既有pattern**（`REGEN_RATE`dict + `TileBank.pool_set` + `resource_cap`上限夾）——現況該函式明確排除ore/gem不再生（:97），無wild_game分支，**照同款架構擴展一個wild_game regen分支即可，非憑空新設計**。

## 具體數值
留給你定（比照量測校準）——建議先跑A/B對照抓數值（例如FORAGE_FLOOR_DAYS試5天/7天兩檔看效果差異），非憑感覺一次定案。

## 序
出正式spec（含A/B測試計畫或具體數值建議）→ measurer平行corroborate/驗收 → build → measurer驗established是否終於>0（這是established調查鏈的第五輪嘗試，前四輪farming/A門/B2/leader週轉皆未解，此輪目標=攻上游急性崩，理論上一修多解四層門一起鬆）。
