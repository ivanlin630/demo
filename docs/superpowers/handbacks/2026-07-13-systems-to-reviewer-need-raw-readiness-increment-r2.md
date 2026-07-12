---
from: systems
to: reviewer
status: consumed
topic: [R②·增量] 需求 raw 就緒度增補(esteem/actual)——藍圖裁B,只審此語意增量
---

# R② 設計審：高層 raw 就緒度增補（S2.0）

## 前置
- 藍圖裁 B(`blueprint-to-systems-S2-need-model-decision-B`)：高層 raw「離終點多遠」→「就緒度」。
- 增補 spec `docs/superpowers/specs/2026-07-13-need-raw-readiness-increment.md`（`git show HEAD` 後 commit）。
- 藍圖指定：**只審此語意增量**（非重跑全 R①）。

## 增量內容
`NeedHierarchy.compute_raw` 的 **L_ESTEEM/L_ACTUAL 兩行改就緒度公式**（低層 survival/safety/belonging 不動）：
- **esteem** = `food_ready × safe_ready × ambition_gap`（基礎穩+野心有空間才在意地位）。
- **actual** = `ff_ready × pop_ready × faction_ready × gap_a`（接近立國條件+未稱霸才升；solo 無 faction→0）。

## 請 R② 重點查
1. **守 §2 獨立性**：兩式只讀世界訊號（food_days/threat/pop/food_flow/faction 規模/rung/ambition_cap），**不讀其他層 urgency 變數**——確認 sensors 仍互不知彼此 urgency（藍圖裁 B 的核心約束：讀自己就緒訊號≠參照他層 urgency 值）。這是 B 勝 A 的關鍵，須守住。
2. **修 blocker 真達成**：solo govern 測(faction=-1,cap=0)→esteem=0∧actual=0→駐守不再 boost→2 測回綠（coeff 對低就緒 state 近中性）。查公式代入這些 state 確實得 0。
3. **接 established 鏈**：就緒隊(faction+pop+food)→actual>0；稱霸隊→actual=0(gap=0)。查有無邊界洞（如 faction_ready 需 members≥1，剛建 faction 單隊是否符；EXPAND_MIN_POP/ACCUMULATE_FLOW_MIN 門檻複用是否語意一致）。
4. **determinism**：純算術+milestone_met(純讀)，零 randf。
5. **數值有界**：各 factor∈[0,1]（clampf），乘積∈[0,1]，coeff alignment 前提(urgency≤1)不破。

CLEAN 則 implementer 續 S2（S2.0 raw 修正 → S2.3 wire → S2.4~S2.6）。有 blocker 回 verdict。
