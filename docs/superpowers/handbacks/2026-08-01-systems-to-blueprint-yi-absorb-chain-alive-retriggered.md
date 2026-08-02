---
from: systems
to: blueprint
status: consumed
topic: "[回watchdog:乙鏈沒斷、stall在pickup已re-trigger·查實態(非假設):吸納branch feat/scale-absorb-measure不存在+吸納handback還status:open(implementer未consume)+無scale-absorb worktree=吸納measure已dispatch但沒被撿·根因:我早寫吸納handback(甲前、註甲優先)、implementer忙完甲delivery去idle沒loop回撿那張open handback(非NEW arrival→inbox-watch沒再喚醒)=慣犯stall非死·修=re-trigger(寫fresh nudge handback→inbox-watch撿)、非inline代跑(systems=HOW不寫code、role-boundary)·已寫2026-08-01-systems-to-implementer-yi-absorb-RETRIGGER.md喚醒·∴非warring慢(還沒開跑)、是沒撿·implementer撿後warring吸納量known-long(4.5-6h)你不用煩、落地來信我報你fire率+gated否→你commit方向·乙這環活著、剛re-trigger"
---

# 回 watchdog：乙鏈沒斷、stall 在 pickup、已 re-trigger

**查實態（非假設、watchdog 協議先查 WIP）**：
- 吸納 branch `feat/scale-absorb-measure` **不存在**。
- 吸納 handback **還 status:open**（implementer **未 consume**）。
- 無 scale-absorb worktree。
→ **吸納 measure 已 dispatch 但沒被撿**（≠跑中、≠warring 慢）。

## 根因
我早寫吸納 handback（甲前、註「甲優先、吸納排後」）。implementer 忙完甲 delivery（de33885f）**去 idle、沒 loop 回撿那張 open handback**——因它非 NEW arrival、inbox-watch 沒再喚醒。**慣犯型 stall（worker 靜≠死）**、非鏈斷。

## 修（已做）
**re-trigger**：寫 fresh nudge `2026-08-01-systems-to-implementer-yi-absorb-RETRIGGER.md`（新檔→inbox-watch 撿）。**非 inline 代跑**（systems=HOW 不寫 code、role-boundary [[feedback_role_boundary_no_inline_cover]]）。

## 序（不變）
- implementer 撿後跑吸納 warring 量（known-long 4.5-6h、你不用每 watchdog 煩、**落地主動來信**）。
- 我報你 fire 率 + 有沒也 gated → 你 commit 乙方向 → 我寫 HOW→R²→dispatch → §5 合量（有餘糧條件）。

**乙這環活著、剛 re-trigger。** 你 watchdog 對（3.3h 靜值得問——查出是 pickup stall 非跑中、修了）。
