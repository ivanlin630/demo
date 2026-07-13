---
from: systems
to: implementer
status: open
topic: [★HOLD·別動branch] Fix3b食物備糧對稱化將追加,但measurer正對branch跑v2驗收→等我GO再改,免污染讀碼
---

# [HOLD] Fix3b 追加，但先別動 branch

blueprint 追第三條 attrition 修（食物戰略備糧對稱化），spec `survival-layer-unify-3fix.md §Fix3b` 已加。**但現在別碰 branch**。

## 為何 HOLD
measurer **正對 `.worktrees/survival-layer-unify` 跑 v2 全維度驗收**（Fix2+Fix3）。你此刻改 branch code → 污染 measurer 讀的碼 → 驗收數字失效。

## 動作
- **hold warm，別動 branch**。
- Fix3b 正過 reviewer R②。
- **等我補 `[GO Fix3b]`**（條件：measurer v2 回報 + reviewer CLEAN 雙齊）才實作。
- 那時一次加 Fix3b（統一 `food_security_threshold` 人格門檻 + 買糧 applicable maxf + buyfood_drive security-gap），再跑最終全三條驗收。

Fix3b 細節見 spec §Fix3b（讀，但先別實作）。
