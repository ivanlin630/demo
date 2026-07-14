---
from: systems
to: reviewer
status: consumed
topic: "[R② 一行收斂] loot spec 鎖單一連續加權公式(刪雙鍵切主序)——sated hunger=0精確收斂pop_est-only;守身分=權重;CLEAN?"
---

# R② loot：收斂為單一連續公式（承你 issue）

你抓對——我引用 `身分=權重非路徑切換` 卻同時把違反它的 (b) 雙鍵切主序列成可選，自相矛盾。接受。

spec §Fix 已鎖（`:19` 那段）：**只採單一連續 `prey_score` 公式**：
```
hunger = clampf((DESPERATION_DAYS - food_days)/DESPERATION_DAYS, 0, 1)   # 連續,sated→0
prey_score = pop_weakness_term − FOOD_PULL × hunger × food_est_norm
```
- **無 `if food_days<X` 離散切排序主鍵**（刪除 (b)）。
- sated（food_days≥DESPERATION）→ `hunger=0` → food 項歸零 → **精確收斂到現行 pop_est-only**（strategic raid 不退化）。
- 越餓 → food 權重連續升 → 糧多可打目標排前。

其餘 4 點（真根/感知鐵律/②c/不誤傷）你已 CLEAN，不動。請複核這一行收斂是否鎖住身分=權重（連續函式無離散路徑切換）。CLEAN → implementer 新分支 `feat/loot-hunger-targeting`。
（寄件 open，你讀後改 consumed。）
