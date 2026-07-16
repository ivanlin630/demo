---
from: systems
to: reviewer
status: consumed
topic: [R② 框內] 跨faction磁鐵修(§3b)——finder改rep-選對齊喂-讀;審S-A/S-B邊界守+resolver已跨faction
---

# 對抗② 審：跨 faction rep-磁鐵修（§3b）

spec `specs/2026-07-11-reputation-magnet-slice.md §3b`（blueprint 授權跨 faction 最小版，治磁鐵 inert）。R①免（前提 file:line 坐實）。**R② 審設計 + S-A/S-B 邊界守得住否。**

## 改什麼（治 inert）
磁鐵 inert 因喂-讀 pair 錯配（喂=戰場護我者、讀=容量選 same-faction absorber，不交集）。修=**finder 改 `_find_best_protector`（由 protector_rep argmax，投奔護過我的，跨 faction）取代 `_find_absorber`**——喂-讀同 pair（護過我的保護傘）。

## 請審（框內 refute）
1. **喂-讀對齊真解 inert**：`_find_best_protector` argmax `protector_rep`（aided 喂的護我者）= §2 喂的同組？rep 不再恆 0.5？
2. **★resolver 已跨 faction**：我讀 `_resolve_join`(`interaction:237`) 在 `same_faction`(`:243`) **之前**（註 :225-227 社交跨/同 faction 均可）→ 主張「JOIN 本就跨 faction、resolver 不用改」。**你複核：真的嗎？** cross-faction join 走 `_resolve_join`→`merge_teams` 有無別的 same_faction 暗閘擋？
3. **★S-A/S-B 邊界守**：最小版只「投奔+併入」，**不做**叛離政治/怨氣/忠誠/通牒。spec 有無偷渡 S-B？join=joiner 併入 protector（faction 繼承）——這算 S-A 可接受，還是「跨 faction 叛離」本身就該 S-B？（blueprint 裁 S-A 做投奔本體、政治後果 S-B）。
4. **不動征服平衡**：finder/magnet 只影響投靠，攻擊/征服未觸？
5. **mega-blob**：跨 faction 高 rep 仁君可能吸全圖弱隊→更大 blob（比 same-faction 更廣）。measure-only 觀察夠？還是要防？
6. judge 盤點：`_find_best_protector` vs `_find_absorber`/`_find_strong_neighbor`——新 finder 非冗餘（rep-選 vs 容量/強選）？

verdict to:systems。CLEAN → dispatch implementer。
