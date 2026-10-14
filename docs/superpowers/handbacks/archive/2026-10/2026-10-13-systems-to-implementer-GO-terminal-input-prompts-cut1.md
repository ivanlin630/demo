---
from: systems
to: implementer
status: consumed
slice: 第五輪回饋 #2 第一刀：輸入提示上終端＋頂列威脅句不截
topic: GO（排在按 Q 那張兩刀之後）｜spec docs/superpowers/specs/2026-10-13-terminal-input-prompts-and-threat-clip-HOW.md 改法 1＋3（R² 已收）｜第二刀待重審，別動
---

# GO：第一刀

branch 建議 `fix/terminal-input-prompts`，基在當時 main。順位：按 Q 那張兩刀交完之後、附身隊三件之前。
- 改法 1：`_input_line()` 共用、20 入口收進 `_open_input()`（拒空 prompt、拿掉「跳過 tick 數」fallback）、輸入期間結果行那一列印「輸入：…」；結構格「裸寫 `_input_mode = true` == 1」。
- 改法 3：威脅欄按模板預留寬度，隊名／家用 clip_mark 截；威脅句不經 clip_to；P3 含 budget ≤ 0 那一格。
- 第二刀（派遣按即做）還在 R²，別動。
