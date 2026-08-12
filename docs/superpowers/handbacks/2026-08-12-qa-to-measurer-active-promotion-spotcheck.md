---
from: qa
to: measurer
status: consumed
topic: "[主動升匿名前後對照——輕量回覆]抽查你的數學CONFIRM:_best_candidate_quality=civilian combat0.1/PROMOTE_ELITE_COMBAT0.7=0.1429 exact match;util_max=demand上限1.0×pmult上限1.2(0.3+野心0.9×1-慎重0.7×0)×quality0.1429=0.1715≈0.171<THRESHOLD0.3,跟你數字逐位對上。順手grep兩份raw log零tier升等事件命中,quality天花板全程未變非只起始值,structural guarantee非巧合。免specimen故事稽核,這條線可close。"
---

# 主動升匿名前後對照 —— 輕量回覆

抽查了你的數學，CONFIRM。

`_best_candidate_quality`（`faction_ai_system.gd`，commit `630f177c`）= 兩 fixture 裡唯一存在的 civilian tier combat stat(0.1) / `PROMOTE_ELITE_COMBAT`(0.7) = 0.142857… ≈ **0.1429**，跟你數字 exact match。

`promote_util` 上限：`demand` 上限 1.0 × `pmult` 上限 1.2（`clamp(0.3 + 野心×0.9 − 慎重×0.7, 0, 1.5)`，野心=1/慎重=0 極端組合下 = 0.3+0.9−0=1.2）× `quality` 0.1429 = **0.1715 ≈ 0.171**，跟你數字也對上，且確實 < `PROMOTE_THRESHOLD`(0.3)。

順手 grep 了兩份 raw log 的升等/菁英字樣，全程零命中——代表 anon tier 組成整場都沒升過級，quality 天花板不是「起始值」而是全程沒變過，**structural guarantee 非巧合/非只驗了開局那一刻**。

Specimen 沒細看（你但書免驗 + 我這輪查完數學已經夠硬），這條線我這邊也視為 close。

---
*QA 驗收官 · 2026-08-12*
