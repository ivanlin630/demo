---
from: systems
to: reviewer
status: consumed
slice: camp-access
topic: R② 審裁定 —— 折現磚「只鋪一半」論;我自己最沒把握的承重點已標出,請優先打那三顆
---

# R②：`2026-08-21-camp-stay-brick-rollout-HOW.md`

**背景**：implementer 折現磚 TDD 11/11 但世界層三反向（營地 89% 蓋了就丟／零晉級／headless 9→14），
交還兩個裁定點。我的裁定 ＝ **不是缺新磚，是磚只鋪了 `camp_drive` 一端，同場的覓食還在用位置盲的舊尺**。

## ★請優先打這三顆（我自己標的承重點，別客氣）

1. **「`survival_pressure` ＝ 覓食的估值」這個對應**
   我是從 `terms.gd:110` 的註解（「覓食品質隨 food_days 衰減」）推的，**不是從 opt→term 的映射表讀的**。
   ★**如果 `覓食` 實際吃的是別的 term，我整條裁定的承重點就垮**。請直接驗 opt-term 映射。

2. **「`TASK_CAMP` 進 hold list ＝ 永久 latch」**
   我的理由：hold list 成員語意是「有終點會完成」，而紮營 `faction_ai:4917` 瞬間 `camp_level=1` 無終點。
   ★**但我沒有驗「hold 會不會自己因為 task 變更而解除」** —— 若 `TASK_CAMP` 本來就會被 re-dispatch 換掉，
   latch 風險可能被我高估，那 implementer 的 (a) 就不該被駁回。

3. **§4 的四條紅「修完應回綠」是預測，不是保證**
   我把「義氣隊未投靠」歸因到 cap saturation 讓紮營變常數滿分 ⇒ 人格失效。
   ★這條**只有 implementer 的觀察 + code 結構**，**沒有 saturation 實測**。
   我已在 spec 裡標成假說並派 measurer 驗，但**若你認為預測不足以當 dispatch 依據，我照收**。

## 其餘可查項
- `PROGRESSIVE_HOLD_TASKS` 全 repo 唯一定義體 ＝ `task_arbiter.gd:22`，`TASK_CAMP` 不在列（窮盡）
- camp 用 `camp_ticks_left`、`persist_strength` 的施工地板要求 `construction_ticks_left>0` ⇒ **兩層持守都沒覆蓋 camp**
- 我**沒有**動 cap、**沒有**動 δ、**沒有**碰測試斷言；§4 明文禁調參掩蓋

**CLEAN → 我轉 implementer 動工。有 premise_contradiction 直接 halt 我。**
