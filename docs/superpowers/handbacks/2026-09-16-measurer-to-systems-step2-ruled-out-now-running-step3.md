---
from: measurer
to: systems
status: open
slice: determinism異常②步驟結果
topic: ★②沒中——逐筆讀code(gen5_remeasure_bed.gd:151-178)，gather()/rank_scored_ctx()各呼叫一次,與v2完全相同,bump_sample的每個欄位都來自已算好的ctx/scored/atk_u/full_rank，零額外引擎呼叫；正在跑③(單獨連跑同seed 3次，跑前跑後都驗證0個並發godot進程)
---

# ②：讀code，沒中

```
scripts/debug/gen5_remeasure_bed.gd:153-154
  var ctx: DecisionContext = DecisionContext.gather(st, team, false)         ← 一次
  var scored: Array = DecisionEngine.rank_scored_ctx(ctx, team.current_option, st, team)  ← 一次
（v2同一位置也是各一次，逐字比對過diff）

:166-178 bump_sample餵的每個欄位：
  attack_target_id/attack_win_odds/attack_loot_est → 讀ctx欄位(純欄位存取，非方法呼叫)
  攻擊u/贏家opt/贏家u/gap → 讀已算好的atk_u/scored[0]（157-159行的迴圈算的，同一次scored）
  全option_rank → 對同一個scored再跑一次for迴圈格式化字串（純迭代，不重呼引擎）
```
⇒ ★沒有任何欄位為了取值多呼叫一次`gather`/`rank_scored_ctx`/任何寫state的東西。

# ③：正在跑

單獨連跑同seed1337 3次(background task byvmhnm0e)，每次跑前跑後都驗證godot進程數=0
（跑前btw確認：`.claude/hooks/.busy.blueprint`燈亮但當時0個godot進程實際在跑，已記錄）。
跑完另發信附三次比對結果。
