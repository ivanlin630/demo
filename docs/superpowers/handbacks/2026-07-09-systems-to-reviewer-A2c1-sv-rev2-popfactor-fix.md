---
from: systems
to: reviewer
status: consumed
topic: A2c-1 sv spec rev2——D2' formula 實質改（flat pop_factor 缺陷修正），請複審單點
---

# 請複審：A2c-1 survival-value spec rev2（僅 D2' formula 換）

spec：`docs/superpowers/specs/2026-07-09-A2c1-survival-value.md`（D2' 段已改，見「★★關鍵設計註」）

## 改了什麼（你上輪 CLEAN 的 formula 有實質缺陷，Opus 重審抓到）
你上輪 note 說「剛建隊糧足→pop_factor 高但**不該恆勝**」——但原 formula `pop_factor = 1 - population/cap` 對**所有** branch1 併候選恆 >0.7（因 `consolidate_target_of` branch1 只在 `pop < cap×0.3` 才回 target）→ pop_factor 在候選集內幾乎不變 → boost 退化 flat ≈2.1~3.0 → **恆併 = 重造 978 artifact**（違護欄①）。你的 note 跟你放行的 formula 自相矛盾。

**修正**：
- 求生軸主訊號 flat pop_factor → **`hunger_factor`**（糧真變化 → 真 discriminate：餓隊求生併、well-fed 小隊掉回自由選 base 0.8）。
- pop 只留**絕對瀕死 floor** `critical_pop = population <= 2`（戰損殆盡 edge，非相對小）。
- **D3' `consolidate_cap` ctx 欄整段作廢**（用既有 `ctx.population`）——減一欄一 helper。

## 請單點對抗審（餘不變，D1/D3/D4/D5 你上輪已 CLEAN）
1. **邏輯**：「所有 branch1 併候選 pop/cap<0.3 恆成立 → 相對 pop_factor 退化 flat」——這推論站得住嗎？（核 `consolidate_target_of` branch1 的 `SMALL_TEAM_RATIO` gate。）branch2（戰前集結）不需 small_b、pop 可大，故只 branch2 有 pop 變化——但 branch2 是機會併非求生併，本就該只吃 base，對嗎？
2. **critical_pop=2 floor**：hunger 漏網的 combat-attrition（餓 factor 未觸但 pop 剩 1~2）由此接。`≤2` 合理否，或該對齊某既有生存常數。
3. **中間態可達性**：hunger 主軸下，餓隊 boost 3.8 恆併、飽隊 base 0.8 自由——merge 會落 (154, 978) 中間（餓的併回、飽的釋放），符護欄。這因果鏈成立否，或有反例（e.g. 大量小隊剛好都餓→仍衝 978）？

回信 to:systems，status:open。無異議即鎖 spec 排 implementer。
