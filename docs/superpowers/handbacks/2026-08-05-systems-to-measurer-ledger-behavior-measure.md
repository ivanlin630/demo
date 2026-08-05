---
from: systems
to: measurer
status: consumed
topic: "[失聯帳本 behavior 量(feat/missing-contact-ledger a3c11288、R² merge-gate CLEAN reviewer 親驗硬追蹤坐實:_pick_contact_reaction 真 argmax 四類存 Dict 找最大非 if/elif、test④ 4 單一 trait 驗四類皆可被選中、整併義務 _evaluate_owner_contact 真走共享 _contact_elapsed_days)·驗真效果(非只 gate 綠):①★失聯反應 fire 且人格分化(母隊派出單位逾時→overdue_ratio→失聯 belief→react 4 類:務實統領 redispatch/野心 writeoff/慎重 defensive/義氣 rescue;per-option util dump 證分化非齊一)②領主對久無音訊村查訪 fire(子→母既有+母→子新兩方向一套)③零 god-view 洩漏(失聯 belief 不含 subject 真死活/位置)④determinism byte-identical·★★reviewer 輕量觀察(必查):overdue_ratio 是四類共用乘數→argmax 數學上退化成純比四特質大小(overdue_ratio 只影響 fire 否、非選哪類)——★量 per-team util dump 多樣性:實跑各隊真選出不同 react 類否(非全世界都同一類)?若全同一類=calibration 需 review(共用乘數抹平選擇);godot --path worktree GODOT_TIMEOUT=1200·★長跑掛 specimen→QA 故事(派出→失聯→人格反應鏈)·回 systems→QA→systems merge·地基 KEEP"
---

# 失聯帳本 behavior 量（驗真效果）

R² merge-gate CLEAN（reviewer **親驗硬追蹤坐實**：`_pick_contact_reaction` 真 argmax 四類存 Dict 找最大非 if/elif、test④ 4 單一 trait 驗四類皆可被 argmax 選中、整併義務 `_evaluate_owner_contact` 真走共享 `_contact_elapsed_days`）。→ 量真效果（[[feedback_verify_execution_end]]）。

## 量（湧現式、dump 真值）
1. **★失聯反應 fire + 人格分化**：母隊派出單位（herald/scout/convoy/subteam）逾時 → `overdue_ratio` → 失聯 belief → react 4 類（務實統領 redispatch / 野心 writeoff / 慎重 defensive / 義氣 rescue）；**per-option util dump 證分化非齊一**。
2. **領主對久無音訊村查訪 fire**（子→母既有 `_evaluate_owner_contact` + 母→子新 dispatch_ledger、兩方向一套）。
3. **零 god-view**：失聯 belief 不含 subject 真死活/位置。
4. determinism byte-identical。

## ★★reviewer 輕量觀察（必查）
`overdue_ratio` 是四類 react 共用乘數 → argmax 數學上**退化成純比四特質大小**（overdue_ratio 只影響 **fire 否**、非**選哪類**）。→ **量 per-team util dump 多樣性**：實跑各隊是否真選出**不同** react 類（非全世界都同一類）？**若全同一類＝calibration 需 review**（共用乘數抹平了選擇 tension）。這是 genuine-vs-偽裝的 behavior 端驗證（reviewer 結構過了、behavior 端你補）。

## 交付 + 序
- `godot --path .worktrees/missing-contact-ledger`、`GODOT_TIMEOUT=1200`、禁原地 checkout。
- **★長跑掛 specimen**（`SpecimenDumpHelper`）→ QA 故事（派出→失聯→人格反應鏈、motive→action→outcome）。
- 回 systems → QA → systems merge。落地 `docs/measurements/`。地基 KEEP。
