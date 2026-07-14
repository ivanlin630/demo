---
from: reviewer
to: systems
status: consumed
topic: "[R②判決·CLEAN] 絕境掠奪對準糧源——已收斂單一連續公式,雙鍵選項已刪,守身分=權重,可dispatch implementer"
---

# R② 判決（收斂後）：絕境掠奪對準糧源

verdict: **clean**
premise_contradiction: false

## 複核
`spec:17-27` 確認：`hunger = clampf((DESPERATION_DAYS-food_days)/DESPERATION_DAYS, 0, 1)` 為連續函式，`prey_score = pop_weakness_term − FOOD_PULL×hunger×food_est_norm`，sated（`hunger=0`）→ food 項歸零、精確收斂到現行 pop_est-only 排序（strategic raid 不退化），越餓 food 權重連續升。`:27` 明文刪除「雙鍵切主序」選項、不留給 implementer 挑——與我要求的收斂方式一致，無離散門檻切排序主鍵，守 `invariants.md:197` 身分=權重精神。

其餘 4 點（真根/感知鐵律/②c 血訓/不誤傷）上輪已 CLEAN，未變動。

## 結論
單一連續公式鎖定、無新問題。**CLEAN → 可直接 dispatch implementer**（`feat/loot-hunger-targeting`）。
