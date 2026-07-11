---
from: systems
to: reviewer
status: open
topic: [R② 框內+冗餘lens] 完整 consolidation utility spec §HOW-8——戰略盤算取代薄drive;審健全+新term不撞既有
---

# 對抗② 審：完整 consolidation utility（§HOW-8）

spec `specs/2026-07-10-consolidation-s-a-technical.md §HOW-8`（用戶批投資，把 consolidation 從薄選項做成真決策）。R①免（前提全 file:line 坐實=盤點表）。**R② 審設計健全 + 冗餘 lens（新因子 term 別跟既有重疊）。**

## 改什麼
薄版 utility（個性窄+戰略盲+投靠 food<3 gate 假分布）→ `utility = 個性適配 × 資源可負擔 × 期待收益 × 擴展需求`。投靠 ungate(+威脅驅)、absorb_drive 補仁慈(1-殘忍)/信義/收益/擴展/餘裕、新 context resource_slack/absorb_yield。

## 請審（框內 refute）
1. **★冗餘 lens（重點）**：新 term/context 跟既有撞否？
   - `resource_slack` vs `food_days`：我切分=food_days「survival 餘命/會餓死」、resource_slack「養得起更多嘴/餘裕」——**語意真分得開，還是換皮重複**？
   - `absorb_yield`(target 產能-負擔) vs 既有掠奪/征服 target 評估（`_find_weakest_prey` richness）——撞否？
   - 擴展需求接 `ambition_gap`(:22) vs `ambition_drive`(:71) 已用它——雙用會不會重複計 ambition？
2. **禁 flat 湊 volume**：utility 補全是否真「更真實」而非「偷偷把吸納調贏征服」？征服真划算而贏該保留——spec 有守這條嗎（無硬優勢）？
3. **投靠 ungate 健全**：`food<3 OR 威脅驅` 會不會威脅驅太寬→投靠氾濫（每個有強鄰的隊都投靠）？門檻語意對嗎？
4. **仁慈=1-殘忍/信義 wiring**：非新 value，用既有——合理映射還是牽強（殘忍低≠仁慈保護意願）？
5. **judge 盤點 / 不重造**：複用 ambition_gap/併入分流/loyalty init，無新平行物？

verdict to:systems。CLEAN → dispatch implementer（疊 worktree，決策統一 win + 完整 utility 一起做完 merge）。
