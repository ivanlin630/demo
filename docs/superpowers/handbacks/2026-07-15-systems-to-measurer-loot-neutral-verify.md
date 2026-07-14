---
from: systems
to: measurer
status: consumed
topic: "[量測·中性世界] 掠奪對準糧@f8821ada——day24-26殘留thrash消?looter得食?★釐清implementer旗:food-weighting是否inert(有沒有真改target)"
---

# 量測：掠奪對準糧 中性世界驗

掠奪 hunger-weighted prey 完（`_find_weakest_prey` 加連續 food 權重）。branch `feat/loot-hunger-targeting` @ **`f8821ada`**（TDD 5 綠、seeded warring byte-identical base=零退化、憲法 sites=29；worktree `.worktrees/loot-hunger-targeting`，push）。base = 最新 main。

## ★先釐清 implementer 旗（inert 疑慮）
implementer 報「seeded warring byte-identical base + food-weighting 中性世界 inert 觀察待驗」——**這正是要你驗的關鍵**：food-weighting **有沒有真改到 target 選擇**，還是餓世界 target 都無 belief food_est → food 項恆 0 → 行為 = 現行（inert）？
- 若 inert（target 無 food_est belief）→ 修沒生效（另一種「看得到但用不上」），回報 systems（可能感知/belief 前置問題）。
- 若生效（飢餓 looter 真鎖糧多 target）→ 續驗 thrash/得食。

## 要驗（★中性世界，confound 已修，故事 QA）
1. **food-weighting 真生效**：飢餓 looter 掠奪 target＝belief food 高者（specimen trace 對比：修前鎖最弱 vs 修後鎖糧多）。**非 inert**。
2. **day24-26 殘留 thrash 消**：Team26 型 `貿易↔掠奪↔idle` 同快照 thrash → 中性世界歸零/趨零。
3. **餓死 looter 得食**：絕境隊掠奪成功 → food 真回升（trace：掠奪 winner→打贏→food delta>0）；搶不到糧才死＝連貫。
4. **不回歸**：determinism；憲法 sites=29；sated looter 仍鎖最弱（strategic raid 不退化，seeded byte-identical 已初證）。

## 下游
specimen trace → QA 故事複判（掠奪對準糧的連貫窮死）。handback `to:blueprint`（thrash 消否 + 得食否 + inert 釐清）。全量一封信。

## 溯源
raw + measured_at_head `f8821ada`。中性世界（confound 已修）判,擾動世界綠不認。
